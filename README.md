# 💬 Discourse — Modern Blog & Forum Application

A sleek, high-performance, cross-platform Blog & Forum mobile application built with **Flutter**, **Provider** state management, **GoRouter**, and **Supabase Backend Services**.

---

## ✨ Features

- **🔐 User Authentication**:
  - Sign Up & Sign In with strict Email Format Regex validation (`name@example.com`).
  - Human-readable error messages for invalid credentials, existing emails, or connectivity issues.
  - Interactive `FocusNode` text fields that clear placeholder hints immediately upon click/focus.
  - Seamless instant logout redirection powered by `GoRouter`'s `refreshListenable`.

- **📰 Feed & Facebook-Style Post Creation Bar**:
  - Top post creation bar ("*Start a discussion, [FirstName]...*") that scrolls naturally with the feed so floating buttons never block content while doom-scrolling.
  - Adaptive multi-photo grid layout supporting single, dual 50%/50% split, and multi-image attachments.
  - Create, Edit, and Delete post actions restricted to post authors.
  - Clean inline tag creation (`#Design`, `#Flutter`) positioned right under discussion titles.

- **👤 Dynamic User Profiles & Avatars**:
  - Customizable display name, handle (`@username`), short bio, and profile photo avatar.
  - Profile image picker with Supabase Cloud Storage integration and local fallback mode.
  - Real-time avatar synchronization across post cards, comment threads, and top app bars.

- **💬 Recursive Threaded Comments & Replies**:
  - Deeply nested recursive comment tree rendering (`parentId` and `parentAuthorName`).
  - Interactive "Replying to @user" banner with auto-focus input.

- **❤️ Per-Account Like Isolation**:
  - Liking system (`likedUserIds` Set) strictly scoped per active user account.
  - Highlights heart icons (`♥`) exclusively for the logged-in user while accurately reflecting global like counts.

- **🔍 Multi-Field Search Engine**:
  - Dedicated `/search` view with instant real-time filtering across titles, body text, and tags.
  - Hybrid local memory and Supabase cloud database SQL `ilike` query.

- **📜 Personal Activity History Log**:
  - Categorized `/activity` dashboard tracking:
    - **YOUR POSTS**: Discussions published by your account.
    - **YOUR COMMENTS & REPLIES**: Comments and replies composed by your account with quote previews.
    - **LIKED POSTS**: Discussions liked by your account.

- **🎨 Design System**:
  - Styled with custom typography using Google Fonts (`Libre Caslon Text` & `Hanken Grotesk`).
  - Custom 3-Tab Bottom Navigation Bar with warm gold active pill indicators (`#FED488`).
  - Padded top search header without clunky notification icons.

---

## 🛠️ Technology Stack

- **Frontend Framework**: Flutter (Dart)
- **State Management**: Provider (`ChangeNotifier`)
- **Navigation & Routing**: GoRouter
- **Typography & Icons**: Google Fonts (`Libre Caslon Text`, `Hanken Grotesk`), Material Icons
- **Backend & Database**: Supabase (PostgreSQL, Row Level Security, Auth, Storage Buckets)

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or higher)
- [Git](https://git-scm.com/)

### Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Normalcable/Blog-Forum-Application.git
   cd Blog-Forum-Application
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Database Setup (Supabase)**:
   - Copy the contents of [`supabase_schema.sql`](file:///c:/Users/Marlon%20Caleb/Documents/Project%20Workplace/Project_req/supabase_schema.sql) into your Supabase project's **SQL Editor** and click **Run**.
   - Ensure Supabase URL and Anon Key are set up in `lib/config/supabase_config.dart`.

4. **Run the Application**:
   ```bash
   flutter run
   ```

---

## 📱 Testing on Mobile Phone

- **Option A: Mobile Web Server (Same Wi-Fi Network)**
  ```bash
  flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
  ```
  Open `http://<YOUR_PC_IP>:8080` in your phone's browser (Safari/Chrome).

- **Option B: USB Debugging (Android / iOS)**
  Enable USB Debugging on your phone, connect via USB, and run `flutter run`.
