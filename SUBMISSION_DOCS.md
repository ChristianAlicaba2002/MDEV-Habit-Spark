# Project Submission: HabitSpark

**Project Name:** HabitSpark  
**Developer:** [Your Name]  
**Platform:** Flutter (Android/iOS)  
**Backend:** Firebase (Auth, Firestore, FCM, Storage)

---

## 1. App Description
**HabitSpark** is a premium, high-performance habit-tracking application designed to help users build consistency and achieve their personal goals. Built with a modern **Glassmorphic UI**, the app provides a seamless experience for organizing daily routines, tracking physical activities, and receiving real-time feedback on progress. HabitSpark focuses on "Real-Time Productivity," ensuring that every check-in and goal completion is synchronized instantly across the user's account.

---

## 2. Firestore Database Structure
The application utilizes a highly organized NoSQL structure with **6 core collections** to manage user data, habits, and system interactions.

### `users` (Collection)
Stores detailed user profiles and biometric data for personalized health tracking.
- `id`: String (Document ID)
- `firstName`: String
- `lastName`: String
- `email`: String
- `photoUrl`: String (Base64/URL)
- `age`: Number
- `height`: Number
- `weight`: Number
- `createdAt`: Timestamp

### `categories` (Collection)
Allows users to organize habits into custom groups with unique icons and colors.
- `id`: String
- `userId`: String (Owner)
- `name`: String
- `iconCode`: String (Mapped via IconResolver)
- `colorValue`: Number (Hex Color)
- `position`: Number (For reordering)

### `habits` (Collection)
The primary collection for user-defined tasks and routines.
- `id`: String
- `userId`: String
- `name`: String
- `category`: String (Relationship to Categories)
- `routine`: String (Morning, Afternoon, Evening, Midnight)
- `icon`: String
- `isDone`: Boolean
- `targetGoal`: Number
- `createdAt`: Timestamp

### `habit_logs` (Collection)
Stores historical data for every habit completion to generate analytics.
- `id`: String
- `habitId`: String (Relationship to Habits)
- `userId`: String
- `timestamp`: Timestamp
- `value`: Number

### `notifications` (Collection)
Manages the history of push and system notifications for each user.
- `id`: String
- `userId`: String
- `title`: String
- `body`: String
- `isRead`: Boolean
- `timestamp`: Timestamp

### `feedback` (Collection)
Stores user-submitted feedback and bug reports.
- `id`: String
- `userId`: String
- `message`: String
- `timestamp`: Timestamp

---

## 3. Core Feature List

### 🔐 Authentication
- **Multi-Method Login**: Support for Email/Password and Google Sign-In.
- **Session Persistence**: Users stay logged in across app restarts.
- **Profile Management**: Ability to update personal info and body stats.

### ⚡ Real-Time Functionality
- **Live Habit Tracking**: Checking a habit instantly updates the dashboard and progress bars.
- **Dynamic Categories**: Adding, renaming, or reordering categories reflects across the UI immediately via Firestore streams.
- **Instant Notification Badge**: The unread notification count updates in real-time as the database changes.

### 🛠️ CRUD Operations
- **Habit Management**: Create, view, edit, and delete daily habits.
- **Category Customization**: Users can create custom categories with a dynamic icon picker (self-correcting for Flutter versions).
- **Activity Logging**: Track physical stats like height/weight and activity types.

### 🖼️ File Handling & UI
- **Profile Image Picking**: Integrated with `image_picker` and `image_cropper`.
- **Cloud Display**: Images are stored and displayed within the user profile.
- **Glassmorphism Design**: High-end visual aesthetic with blur effects, gradients, and micro-animations.

### 🔔 Notifications (FCM)
- **Push Notifications**: Integrated with Firebase Cloud Messaging.
- **Trigger Scenarios**:
    1. **Streak Milestones**: Users are notified when they hit a consistency goal.
    2. **Reminders**: System alerts for incomplete daily routines.

---

## 4. Technical Architecture
- **State Management**: Stream-based architecture with `StreamBuilder` for real-time UI.
- **Design System**: Vanilla CSS-inspired Flutter styling with Google Fonts (Outfit).
- **Service Layer**: Decoupled Firebase services for Auth, Firestore, and FCM to ensure maintainable code.
