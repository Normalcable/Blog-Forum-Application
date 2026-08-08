# 📖 Discourse App — Developer Journal

Welcome to the development diary of **Discourse**, a minimalist web & mobile forum app built with Flutter and Supabase. This document logs the evolution of the application step-by-step.

---

### 🟢 Entry 1: Project Foundation & Routing Setup
> *"Setting the stage for clean navigation and architecture."*

- **Project Initialization**: Created the Flutter project (`project_req`) configured for web and mobile.
- **Core Packages**: Added `go_router` for route management and `provider` for state handling.
- **Navigation Map & Guards**: Implemented `AppRouter` (`lib/router/app_router.dart`) with defined routes (`/login`, `/register`, `/`, `/post/:id`, `/post/create`, `/post/:id/edit`, `/profile`) and authentication guards.
- **App Setup**: Wrapped `MaterialApp.router` in `lib/main.dart` with `MultiProvider`.

---

### 🎨 Entry 2: Translating Frontend UI Templates
> *"Crafting a high-end typography & modern UI experience."*

- **Design System**: Translated the `frontend_ui_template` HTML/CSS source of truth into Flutter widgets using `GoogleFonts` (`Hanken Grotesk` & `Libre Caslon Text`).
- **Screen Implementations**:
  - `LoginScreen` & `RegisterScreen`: Styled authentication cards with clean inputs and action buttons.
  - `FeedScreen`: Clean discussion feed, tag chips, response counters, and floating post creation button.
  - `PostDetailScreen`: Rich article reader view, author header, image placeholders, and a sticky response bar.
  - `CreatePostScreen` & `EditPostScreen`: Bento-style distraction-free post editor with community selector.
  - `ProfileScreen`: User avatar display, editable handle/bio, and a styled log-out action.

---

### 📱 Entry 3: Desktop Mobile Frame Optimization
> *"Ensuring optimal mobile aspect ratio when debugging on desktop browsers."*

- Added a layout `builder` constraint in `MaterialApp.router` (`lib/main.dart`).
- Constrained desktop browser rendering width to a max of `480px` centered on a dark backdrop (`#1A1A1A`), preventing stretched layouts during PC debugging.

---

### ⚡ Entry 4: State Management & Data Models
> *"Moving from static placeholders to reactive Dart state."*

- **Data Models**: Created strongly-typed `UserModel`, `PostModel`, and `CommentModel` classes in `lib/models/`.
- **State Providers**:
  - `PostProvider`: Manages post listing, likes, and CRUD operations.
  - `CommentProvider`: Manages comment threads per post.
  - `AuthProvider`: Manages user authentication state and profile changes.
- **Interactive UI**: Connected all 5 screens to reactive Provider state for real-time local updates.

---

### 🗄️ Entry 5: Supabase Database Schema & Infrastructure
> *"Building the production backend database."*

- **Dependencies**: Added `supabase_flutter` (`^2.17.1`) and `image_picker` (`^1.2.3`).
- **Database Schema**: Created `supabase_schema.sql` defining:
  - Tables: `public.profiles`, `public.posts`, `public.comments`, and `public.post_likes`.
  - Security: Row Level Security (RLS) policies for read/write permissions.
  - Automation: `handle_new_user()` trigger to automatically create a profile entry on user signup.
- **Configuration & Service**: Created `SupabaseConfig` (`lib/config/supabase_config.dart`) and `SupabaseService` (`lib/services/supabase_service.dart`).

---

### 🚀 Entry 6: Live Production Mode & Strict Authentication
> *"Eliminating mock bypasses and going live with real Supabase data."*

- **Strict Auth Validation**: Refactored `LoginScreen` and `RegisterScreen` to validate credentials directly against Supabase Auth, blocking invalid attempts and displaying user error feedback.
- **Live Database Streaming**: Refactored `PostProvider` and `CommentProvider` to remove hardcoded mock placeholders when connected to Supabase and stream real discussions and responses directly from PostgreSQL tables.

---

### 🖼️ Entry 7: Full Media Storage Integration, Comment Deletion & Profile Photo CRUD
> *"Fulfilling complete CRUD operations across posts, responses, and user profiles."*

- **Comment Deletion**: Implemented owner-restricted comment deletion in `SupabaseService.deleteComment`, `CommentProvider.deleteComment`, and updated `PostDetailScreen` with interactive trash action icons.
- **Comment Images**: Enabled image attachment picking, previewing, and multi-image uploads to Supabase Storage (`posts` bucket) for response threads.
- **Profile Photo CRUD**: Wired avatar picking, previewing, uploading to Supabase Storage (`avatars` bucket), and updating `avatar_url` across `AuthProvider`, `ProfileScreen`, and app navigation bars.
- **Post Multi-Image CRUD & Local Fallbacks**: Enhanced post creation and editing with interactive thumbnail previews, selective image removal, and cross-platform image path resolution for seamless offline and online operation.

