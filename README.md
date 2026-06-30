# Farm Direct 🌾

**Farm Direct** is a modern, single-codebase marketplace designed to connect Farmers and Buyers directly. By eliminating brokers and middlemen, it secures higher profit margins for farmers and guarantees fresh, cost-effective produce for buyers.

This production-ready application is written in **Flutter** (Dart) and backed by **Supabase** (PostgreSQL, Auth, Realtime, and Storage). It compiles seamlessly to **Android, iOS, Web Browser, and Progressive Web App (PWA)** formats.

---

## 🏗️ Architecture Design

The codebase strictly adheres to **Clean Architecture** decoupled with **MVVM (Model-View-ViewModel)** and the **Repository Pattern**:

```
lib/
├── core/               # Theme layouts, routing, exceptions & constants
├── domain/             # Core business rules
│   ├── entities/       # Pure data models representing business objects
│   ├── repositories/   # Interfaces declaring database operations
│   └── usecases/       # Grouped execution rules (Auth, Products, Orders, Rates)
├── data/               # Remote database API integrations
│   ├── models/         # JSON parser models extending domain entities
│   ├── datasources/    # Remote Supabase CRUD endpoints
│   └── repositories/   # Implementations mapping domain contracts to datasources
└── presentation/       # User Interface
    ├── viewmodels/     # ViewModels managing view states (Notifier)
    ├── widgets/        # Reusable Material 3 custom components
    └── views/          # Screen templates for Splashes, Auth, Farmer & Buyer
```

### 📱 Responsive & PWA Friendly
- **Material 3 Green Theme**: Clean design layout with automatic light/dark mode support.
- **Full PWA Auto-Install Support**: Configurations in `web/index.html` and `web/manifest.json` allow browsers on Android/iOS to install the application instantly.
- **PWA Media Uploads**: Image uploads are handled using binary uploads (`uploadBinary`), avoiding native file system crashes on web and PWA.

---

## 🛠️ Step-by-Step Setup Guide

### 1. Database Setup (Supabase)
1. Go to [Supabase](https://supabase.com/) and create a new project.
2. In the left panel, navigate to the **SQL Editor**.
3. Create a new query, paste the contents of [supabase_schema.sql](file:///c:/xampp/htdocs/New_App_St_Veb/supabase_schema.sql), and click **Run**. This will create:
   - All tables (`users`, `farmer_profiles`, `buyer_profiles`, `products`, `orders`, `order_items`, `payments`, `market_rates`, etc.).
   - Triggers for auto-creating public user profiles when signing up.
   - Sequence generators to auto-generate unique Farmer IDs (`FARM000001` format).
   - Row-Level Security (RLS) policies.
   - Seed data for Indian crop rates.

### 2. Storage Setup (Supabase)
1. In the Supabase Dashboard, navigate to **Storage**.
2. Create three **public** storage buckets with the following names:
   - `farmer_photos` (for farmer profile pictures)
   - `buyer_photos` (for buyer profile pictures)
   - `product_photos` (for crop product pictures)
3. Ensure these buckets are set to public so that images can be loaded via URLs.

### 3. Flutter Configuration
1. Open the file [lib/core/constants/app_constants.dart](file:///c:/xampp/htdocs/New_App_St_Veb/lib/core/constants/app_constants.dart).
2. Replace the placeholders with your Supabase credentials:
   ```dart
   static const String supabaseUrl = 'https://your-project-id.supabase.co';
   static const String supabaseAnonKey = 'your-anon-key-here';
   ```

### 4. Running the Application
Ensure you have the Flutter SDK installed on your machine:
```bash
# Get packages
flutter pub get

# Run on Web/Chrome
flutter run -d chrome

# Run on Android Emulator/Device
flutter run -d android

# Run on iOS Simulator/Device
flutter run -d ios
```

---

## 📦 PWA Deployment & Installation

### Build for Web PWA
To build the application for deployment as a PWA, run:
```bash
flutter build web --web-renderer canvaskit --release
```
The output directory will be in `build/web/`.

### Installation on Devices
1. Host the `build/web/` folder on any HTTPS hosting provider (Netlify, Vercel, Firebase Hosting, or XAMPP locally).
2. Open the URL in Google Chrome (Android/Desktop) or Safari (iOS).
3. **On Android/Chrome**: Tap the "Add to Home screen" banner or select "Install App" from the browser menu.
4. **On iOS/Safari**: Tap the **Share** button (up arrow box) and select **Add to Home Screen**.
