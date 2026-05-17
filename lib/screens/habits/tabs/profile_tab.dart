import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:habit_spark/models/habit.dart';
import 'package:habit_spark/models/user_model.dart';
import 'package:habit_spark/services/auth_service.dart';
import 'package:habit_spark/services/streak_service.dart';
import 'package:habit_spark/screens/misc/personal_information_page.dart';
import 'package:habit_spark/widgets/glass_widgets.dart';
import 'package:habit_spark/screens/misc/smart_nudges_page.dart';
import 'package:habit_spark/screens/misc/notifications_page.dart';
import 'package:habit_spark/widgets/skeleton_loaders.dart';
import 'package:habit_spark/constants/app_colors.dart';
import 'package:habit_spark/screens/misc/body_stats_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:habit_spark/services/storage_service.dart';
import 'package:habit_spark/services/notification_service.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:habit_spark/l10n/app_localizations.dart';
import 'package:habit_spark/services/language_service.dart';

class ProfileTab extends StatefulWidget {
  final String userId;
  final AuthService authService;
  final StreakService streakService;
  final List<Habit> habits;
  final VoidCallback onBackTap;

  const ProfileTab({
    super.key,
    required this.userId,
    required this.authService,
    required this.streakService,
    required this.habits,
    required this.onBackTap,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isRefreshing = false;
  bool _isUploading = false;
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile == null) return;

      // Crop the image
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        maxWidth: 400,
        maxHeight: 400,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 70,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: const Color(0xFF1A3333),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            activeControlsWidgetColor: AppColors.primary,
          ),
          IOSUiSettings(
            title: 'Crop Profile Picture',
            aspectRatioLockEnabled: true,
            resetButtonHidden: true,
          ),
        ],
      );

      if (croppedFile == null) return;

      setState(() => _isUploading = true);

      // Convert image to Base64 to bypass Storage billing requirements
      final bytes = await File(croppedFile.path).readAsBytes();
      final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      // Update Firestore directly
      await widget.authService.updateProfile(widget.userId, {'photoUrl': base64String});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showImageSourceSelection(UserModel? userData) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        borderRadius: 32,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Profile Picture',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.camera, color: AppColors.primary),
              ),
              title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.photo, color: AppColors.primary),
              ),
              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            if (userData?.photoUrl != null && userData!.photoUrl.isNotEmpty)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.trash, color: Colors.red),
                ),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  HapticFeedback.mediumImpact();
                  try {
                    setState(() => _isUploading = true);
                    await widget.authService.updateProfile(widget.userId, {'photoUrl': ''});
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile picture removed!'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isUploading = false);
                  }
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirmation),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              await widget.authService.signOut();
            },
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = LanguageService();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        borderRadius: 32,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.selectLanguage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildLanguageOption(context, 'en', 'English', '🇺🇸'),
            _buildLanguageOption(context, 'es', 'Español', '🇪🇸'),
            _buildLanguageOption(context, 'fr', 'Français', '🇫🇷'),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String code, String name, String flag) {
    final languageService = LanguageService();
    final isSelected = languageService.currentLocale.languageCode == code;
    
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name, style: TextStyle(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(CupertinoIcons.checkmark_alt, color: AppColors.primary) : null,
      onTap: () {
        languageService.changeLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<UserModel?>(
      stream: widget.authService.getUserDataStream(widget.userId),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        final user = widget.authService.currentUser;
        final displayName = '${userData?.firstName ?? ''} ${userData?.lastName ?? ''}'.trim();
        final name = displayName.isEmpty ? user?.email?.split('@')[0] ?? 'User' : displayName;
        final username = '@${userData?.email.split('@')[0] ?? 'user123'}';

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0D1B1B),
                Color(0xFF162A2A),
                Color(0xFF1A3333),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.primary,
                backgroundColor: const Color(0xFF1E2E2E),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: _isRefreshing
                    ? [const SliverProfileSkeleton()]
                    : [
                    // ── Modern Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RoundIconButton(
                              icon: CupertinoIcons.arrow_left,
                              onTap: widget.onBackTap,
                              outlined: true,
                              isSquare: true,
                            ),
                            Text(
                              l10n.profileTab,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            StreamBuilder<int>(
                              stream: NotificationService().getUnreadCountStream(widget.userId),
                              builder: (context, snapshot) {
                                final unreadCount = snapshot.data ?? 0;
                                return Stack(
                                  children: [
                                    RoundIconButton(
                                      icon: CupertinoIcons.bell,
                                      onTap: () {
                                        HapticFeedback.mediumImpact();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => NotificationsPage(),
                                          ),
                                        );
                                      },
                                      outlined: true,
                                      isSquare: true,
                                    ),
                                    if (unreadCount > 0)
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primary.withOpacity(0.5),
                                                blurRadius: 4,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ),
                                          child: Text(
                                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Premium Profile Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: GlassCard(
                          padding: const EdgeInsets.all(24),
                          borderRadius: 32,
                          blur: 25,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              const Color(0xFF7dcfff).withOpacity(0.8),
                                              const Color(0xFFbb9af7).withOpacity(0.8),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF7dcfff).withOpacity(0.25),
                                              blurRadius: 15,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF1A3333),
                                            shape: BoxShape.circle,
                                          ),
                                          child: CircleAvatar(
                                            radius: 45,
                                            backgroundColor: Colors.white.withOpacity(0.05),
                                            backgroundImage: (userData?.photoUrl != null && userData!.photoUrl.isNotEmpty)
                                                ? (userData!.photoUrl.startsWith('data:image')
                                                    ? MemoryImage(base64Decode(userData!.photoUrl.split(',').last)) as ImageProvider
                                                    : NetworkImage(userData!.photoUrl) as ImageProvider)
                                                : null,
                                            child: (userData?.photoUrl == null || userData!.photoUrl.isEmpty)
                                                ? Text(
                                                    (user?.email?.substring(0, 1).toUpperCase()) ?? 'U',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 36,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () => _showImageSourceSelection(userData),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: const Color(0xFF1A3333), width: 2),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.primary.withOpacity(0.5),
                                                  blurRadius: 10,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: _isUploading
                                                ? const SizedBox(
                                                    width: 14,
                                                    height: 14,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                                                    ),
                                                  )
                                                : const Icon(
                                                    CupertinoIcons.camera_fill,
                                                    size: 14,
                                                    color: Colors.white,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          username,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.5),
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        _ProfileCompletionBar(progress: 0.8),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              Row(
                                children: [
                                  _StatPill(
                                    label: 'Age',
                                    value: userData?.age != null ? '${userData!.age}' : '21',
                                    unit: 'y.o',
                                  ),
                                  const SizedBox(width: 12),
                                  _StatPill(
                                    label: 'Height',
                                    value: userData?.height != null ? '${userData!.height!.toInt()}' : '165',
                                    unit: 'cm',
                                  ),
                                  const SizedBox(width: 12),
                                  _StatPill(
                                    label: 'Weight',
                                    value: userData?.weight != null ? '${userData!.weight!.toInt()}' : '63',
                                    unit: 'kg',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Settings Sections
                    _SectionHeader(title: l10n.accountSettings),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _GlassSettingTile(
                            icon: CupertinoIcons.person,
                            title: l10n.personalInformation,
                            subtitle: l10n.personalInformationSubtitle,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PersonalInformationPage(
                                  userId: widget.userId,
                                  authService: widget.authService,
                                  initialData: userData,
                                ),
                              ),
                            ),
                          ),
                          _GlassSettingTile(
                            icon: CupertinoIcons.briefcase,
                            title: 'Body Stats',
                            subtitle: 'Manage your body statistics',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BodyStatsPage(
                                  userId: widget.userId,
                                  authService: widget.authService,
                                  initialData: userData,
                                ),
                              ),
                            ),
                          ),
                          _GlassSettingTile(
                            icon: CupertinoIcons.sparkles,
                            title: 'Smart Nudges',
                            subtitle: 'Align with your natural flow',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SmartNudgesPage(
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            },
                          ),
                          _GlassSettingTile(
                            icon: CupertinoIcons.globe,
                            title: l10n.language,
                            subtitle: l10n.languageSubtitle,
                            onTap: () => _showLanguageSelection(context),
                          ),
                        ]),
                      ),
                    ),

                    // ── Logout Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                        child: GestureDetector(
                          onTap: () => _showLogoutConfirmation(context),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.red.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(CupertinoIcons.arrow_right_to_line, color: Colors.red, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.logout,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        l10n.logoutDescription,
                                        style: TextStyle(
                                          color: Colors.red.withOpacity(0.6),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(CupertinoIcons.chevron_right, color: Colors.red.withOpacity(0.4), size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileCompletionBar extends StatelessWidget {
  final double progress;
  const _ProfileCompletionBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile Completion',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _StatPill({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool hasToggle;

  const _GlassSettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.hasToggle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        opacity: 0.08,
        blur: 0,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
          trailing: hasToggle
              ? CupertinoSwitch(
                  value: true,
                  onChanged: (v) {},
                  activeColor: AppColors.primary,
                )
              : Icon(
                  CupertinoIcons.chevron_right,
                  color: Colors.white.withOpacity(0.3),
                  size: 18,
                ),
        ),
      ),
    );
  }
}
