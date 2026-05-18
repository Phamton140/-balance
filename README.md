# +Balance — Premium Personal Finance App

+Balance is a premium personal finance application built for Android and iOS, designed with a focus on local privacy, intuitive mental categorization (Need vs Want), and smooth, elegant glassmorphic interfaces. 

Inspired by modern fintech giants like Apple Wallet, Revolut, Linear, and Arc, +Balance is built entirely **offline** to ensure that all user data remains 100% private and encrypted on-device.

---

## 🎨 Visual Identity

- **Theme**: Futuristic, Sleek Premium Dark Mode
- **Colors**:
  - Background: Deep Dark Space (`#070B14`, `#0B1020`)
  - Primary Green (Positive Cashflow & Needs): `#4ADE80` / `#22C55E`
  - Primary Pink/Red (Outflows & Wants): `#FB7185` / `#F43F5E`
  - Primary Purple/Blue (Stats & Secondary Info): `#818CF8` / `#6366F1`
  - Committed Outflows: Warm Amber (`#F59E0B`)
- **Typography**: Inter (Modern, geometric sans-serif)
- **Aesthetics**: Glassmorphism (semi-transparent blur panels), subtle neon glows, and smooth transitions.

---

## 🛠️ Technology Stack & Architecture

The application strictly adheres to **Clean Architecture** patterns:
- **Presentation Layer**: Riverpod state management, custom views, and high-fidelity widgets.
- **Domain Layer**: Pure Dart entities and abstract repository definitions.
- **Data Layer**: Concrete repository implementations, offline sqflite database mappings, and mock generation helpers.

### Core Dependencies
- **State Management**: `flutter_riverpod` (v2.6+)
- **Local Persistence**: `sqflite` + `path`
- **Charts**: `fl_chart` (custom dark theme configurations)
- **Fonts**: `google_fonts` (Inter)
- **Animations**: `flutter_animate` (glowing, expansion, and fade transitions)
- **Key-Value Cache**: `shared_preferences`

---

## 🚀 Key Features

1. **Animated Splash & Premium Onboarding**: Features an intro slider detailing the core values of +Balance.
2. **Setup Panel**: Set up your name, preferred currency, salary, and savings goals dynamically.
3. **Smart Dashboard**:
   - **Disponible (Available)** and **Comprometido (Committed)** cards.
   - **Lo Necesito vs Lo Quiero** Breakdown: Dynamic sliding bar that displays percentage allocations.
   - **Coach Insights Carousel**: Automatically reviews spending habits locally and generates psychological coach tips.
   - **Flow Trendline**: Dynamic `fl_chart` plotting trends.
4. **Income Management**: Register salary, freelance work, and recursive deposits.
5. **Expense Management**: Log expenses in under 5 seconds with standard categorization and the mandatory **Need vs Want** psychological selector.
6. **Goals (Savings)**: Dynamic goals tracking with circular indicators and monthly calculated milestones.
7. **Debts Control**: Track credit cards, loans, balances, payment minimums, and due dates.
8. **Financial Calendar**: Clean grid plotting payment collections, due bills, and subscription reminders.
9. **PIN Security**: Local keypad secure access checking.

---

## 🛠️ How to Run

1. Make sure Flutter SDK is installed and configured.
2. Clone the repository.
3. Run the following in the root folder:
   ```bash
   flutter pub get
   flutter run
   ```
