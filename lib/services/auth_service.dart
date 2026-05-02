import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:habit_spark/models/user_model.dart';
import 'package:habit_spark/services/fcm_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '82887882958-lkomt7qtpbgg34bp05tfndqnu9fd49n5.apps.googleusercontent.com',
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Save user data to Firestore
  Future<void> saveUserModel(UserModel user) async {
    try {
      // Get FCM token
      final fcmToken = await FCMService().getToken();
      
      // Add FCM token to user data
      final userData = user.toMap();
      if (fcmToken != null) {
        userData['fcmToken'] = fcmToken;
      }
      
      await _firestore.collection('users').doc(user.uuid).set(userData);
    } catch (e) {
      throw 'Failed to save user data: $e';
    }
  }
  
  // Get user data from Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch user data: $e';
    }
  }
  
  // Get user data stream for real-time updates
  Stream<UserModel?> getUserDataStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null; // User cancelled

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential = await _auth_signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null && userCredential.additionalUserInfo?.isNewUser == true) {
        // Create user model for new Google user
        final userModel = UserModel(
          uuid: user.uid,
          firstName: user.displayName?.split(' ').first ?? 'User',
          lastName: user.displayName?.split(' ').length == 2 ? user.displayName!.split(' ').last : '',
          email: user.email ?? '',
          birthDate: '', // Unknown
          password: '', // Not used for Google
          photoUrl: user.photoURL ?? '',
          createdAt: DateTime.now().toIso8601String(),
        );
        
        await saveUserModel(userModel);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Google sign-in failed: $e';
    }
  }

  // Private helper to avoid direct call to _auth.signInWithCredential in the middle
  Future<UserCredential> _auth_signInWithCredential(AuthCredential credential) {
    return _auth.signInWithCredential(credential);
  }

  // Reset password via email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update profile fields in Firestore
  Future<void> updateProfile(String userId, Map<String, dynamic> fields) async {
    try {
      await _firestore.collection('users').doc(userId).update(fields);
    } catch (e) {
      throw 'Failed to update profile: $e';
    }
  }

  // Re-authenticate and change password
  Future<void> reauthenticateAndChangePassword(String currentPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        // Create credentials with current password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        // Re-authenticate
        await user.reauthenticateWithCredential(credential);
        
        // Update password
        await user.updatePassword(newPassword);
      } else {
        throw 'User not found or email is missing.';
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Change password (requires recent login)
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
