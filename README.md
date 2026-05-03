# Element Bike Catalog - Premium Digital Showroom

![Element Bike UI](https://www.elementbike.id/wp-content/uploads/2021/04/Logo-Element-Bike-Horizontal-300x75.png)

A high-end, premium Flutter application designed for **Element Bike**. This project transforms a standard e-commerce interface into an immersive digital showroom featuring glassmorphic UI elements, editorial-grade typography, and a robust administrative management portal.

## Key Features

- **Premium Showroom (Home):** A sophisticated product catalog with a floating glassmorphic navigation bar and high-contrast branding.
- **Immersive Details:** Digital showroom-style detail views with sliver-based scrolling, technical specification grids, and persistent action bars.
- **Quick Collection Access:** One-tap "Add to Collection" directly from the catalog with robust, persistent SnackBar feedback.
- **Shopping Bag (Cart):** A refined checkout experience with real-time total calculations and a premium order confirmation flow.
- **Management Portal (Admin):** Professional inventory management system with real-time statistics and secure PIN-protected access.
- **Persistence:** Local data persistence using `sqflite` ensures your collection and catalog remain intact across sessions.
- **Global Navigation:** Robust navigation patterns that handle complex async interactions and persistent notifications.

## 🛠️ Technology Stack

- **Framework:** Flutter (Material 3)
- **State Management:** Provider (ChangeNotifier)
- **Database:** SQLite (via `sqflite`)
- **Typography:** Google Fonts (Outfit Family)
- **Design Pattern:** Editorial Showroom / Glassmorphism

## 📦 Dependencies

The project utilizes the following core dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0        # Local database persistence
  path: ^1.9.0           # File path utilities
  provider: ^6.1.1       # Reactive state management
  google_fonts: ^6.1.0   # Premium editorial typography
  cupertino_icons: ^1.0.8 # iOS-style iconography support
```

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.10.0 or higher)
- [Dart SDK](https://dart.dev/get-started/install)
- An Android/iOS Emulator or Physical Device, or Chrome for Web testing.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/flutter_uts.git
   cd flutter_uts
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

### Admin Access
To access the **Management Portal (Admin Screen)**:
1. Navigate to the **Profile** icon in the floating navigation bar.
2. Enter the security PIN: `1234`.

---

**Developed with ❤️ by Senior UI/UX Designer & Flutter Engineer**
