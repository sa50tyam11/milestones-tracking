<p align="center">
  <h1 align="center">🩺 BalAarogya (ShishuCare)</h1>
  <p align="center">
    <strong>Early Childhood Development & Nutritional Risk Screening</strong>
  </p>
  <p align="center">
    A mobile-first Flutter application that empowers parents, caregivers, and community health workers to monitor a child's developmental milestones, growth patterns, and vaccination schedule — all offline, all on-device.
  </p>
</p>

---

## 🧠 The Problem

India has over **26 million children born every year**. Many developmental delays — cognitive, motor, language, and social — go undetected until school age, when early intervention would have had the greatest impact. The reasons are systemic:

- **Limited access to paediatricians** in rural and semi-urban areas
- **Lack of awareness** among parents about age-appropriate developmental milestones
- **No structured, accessible screening tools** available in the hands of caregivers
- **Fragmented vaccination tracking** leading to missed or delayed immunizations
- **Growth faltering (stunting, wasting, underweight)** often identified too late

> Early identification of developmental concerns and nutritional risk can change a child's trajectory — but only if screening is **accessible, simple, and available where the child lives**.

---

## 💡 What BalAarogya Does

BalAarogya (बाल आरोग्य — "Child Health") is a **screening platform** that puts evidence-based child health monitoring directly into the hands of caregivers. It is **not** a diagnostic tool — it identifies areas that may benefit from professional evaluation.

### 🎯 Core Modules

| Module | What It Does | Data Source |
|--------|-------------|-------------|
| **Developmental Milestone Screening** | Age-appropriate checklist covering cognitive, motor, language & social domains | CDC's 159 milestones across 12 age groups (2 months – 5 years) |
| **Growth & Nutritional Assessment** | Weight-for-age, length/height-for-age, weight-for-length/height, head circumference Z-score calculation | WHO Child Growth Standards (LMS method) |
| **Vaccination Tracker** | Per-child dose ledger aligned with India's Universal Immunization Programme (UIP) | MoHFW UIP schedule (draft reference) |
| **Composite Dashboard** | Unified view of all screening results with risk indicators | Aggregated from all modules |
| **Assessment History** | Chronological record of past screenings and growth measurements | Local device storage |

---

## ✨ Key Features

### 📋 Milestone Screening
- **159 CDC milestones** organized into 12 age-appropriate checklists
- Automatically selects milestones at or below the child's current age
- Tracks skills the child can do, cannot yet do, or where the caregiver is unsure
- Flags **lost skills** and **caregiver concerns** for professional follow-up
- Generates a detailed screening report with domain-wise breakdown

### 📈 Growth Monitoring (WHO Standards)
- Separate **boys' and girls'** growth references (birth to 5 years)
- Calculates Z-scores for:
  - Weight-for-age (underweight screening)
  - Length/Height-for-age (stunting screening)
  - Weight-for-length/height (wasting screening)
  - Head circumference-for-age (optional)
- Handles **premature births** with corrected-age adjustments
- Validates against implausible values — never silently reports a normal result
- Preserves historical raw measurements across visits

### 💉 Vaccination Tracker
- Offline, per-child immunization dose ledger
- Records dates, information sources, and corrections
- Supports reversible dose removals
- Japanese Encephalitis (JE) context awareness
- **Note**: Automated due/overdue assessment is disabled pending clinical review

### 🔒 Privacy-First Design
- **100% offline** — no API keys, no cloud sync, no backend servers
- All data stored locally on the device (SharedPreferences)
- No child data is ever transmitted to CDC, WHO, or any external service
- Clearing browser/app storage removes all locally saved profiles and records

---

## 🏗️ Architecture

```
lib/
├── core/                    # App-wide constants, routes, theme, validation
│   ├── constants/           # Enums, app strings (medical language policy enforced)
│   ├── routes/              # Named route definitions
│   ├── theme/               # Material Design theme configuration
│   └── validation/          # Form input validators
├── models/                  # Data classes
│   ├── child.dart           # Child profile with birth history
│   ├── milestone.dart       # CDC milestone definitions
│   ├── growth_assessment.dart   # WHO growth measurement + Z-scores
│   ├── vaccine.dart         # Vaccine definitions
│   └── ...                  # Assessment sessions, results, findings
├── providers/               # State management (Provider/ChangeNotifier)
│   ├── child_provider.dart      # Active child state
│   ├── milestone_provider.dart  # Milestone assessment state
│   └── dashboard_provider.dart  # Composite dashboard state
├── repositories/            # Business logic layer (age-based filtering)
├── services/                # Data layer
│   ├── milestone_service.dart           # Parses milestones.json
│   ├── milestone_scoring_service.dart   # Scoring logic
│   ├── growth_assessment_service.dart   # WHO Z-score calculation
│   ├── who_growth_reference.dart        # LMS table loader
│   ├── vaccination_schedule_service.dart # UIP schedule logic
│   └── local_storage_service.dart       # SharedPreferences persistence
├── screens/                 # UI screens organized by feature
│   ├── splash/              # App loading screen
│   ├── home/                # Welcome + home screens
│   ├── registration/        # Parent & child registration
│   ├── milestone/           # Milestone assessment + results
│   ├── growth/              # Growth measurement + WHO charts
│   ├── vaccination/         # Immunization tracking
│   ├── dashboard/           # Composite results dashboard
│   └── history/             # Past assessment records
├── widgets/                 # Reusable UI components
└── main.dart                # App entry point with DI setup
```

**State Management**: Provider pattern with dependency injection via `MultiProvider`

**Data Flow**: `Service (JSON/WHO data) → Repository (business logic) → Provider (state) → Screen (UI)`

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** ≥ 3.12.2 — [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Android Studio** (for Android deployment) or **Chrome** (for web)
- **Git** — [Install Git](https://git-scm.com/)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/sa50tyam11/milestones-tracking.git
cd milestones-tracking

# 2. Install dependencies
flutter pub get

# 3. Run on Chrome (web)
flutter run -d chrome

# 4. Or run on a connected Android device
flutter run -d <device-id>

# 5. Or build a release APK
flutter build apk --release
```

### Verify Code Quality

```bash
flutter analyze       # Static analysis
flutter test          # Run unit tests
flutter build web --release   # Production web build
```

---

## 📊 Data Sources & References

| Data | Source | License |
|------|--------|---------|
| Developmental Milestones | [CDC Milestones Checklist by Age](https://www.cdc.gov/act-early/resources/milestones-checklist-by-age.html) | Public domain (U.S. Government) |
| Growth Standards | [WHO Child Growth Standards](https://www.who.int/tools/child-growth-standards) | See [WHO_ANTHRO_LICENSE.md](assets/data/WHO_ANTHRO_LICENSE.md) |
| Vaccination Schedule | India's Universal Immunization Programme (UIP) | Draft reference — see [UIP_INTEGRATION.md](assets/data/UIP_INTEGRATION.md) |

Detailed reference provenance, calculation boundaries, and redistribution terms: [WHO_REFERENCE.md](assets/data/WHO_REFERENCE.md)

---

## ⚠️ Medical Disclaimer

> **BalAarogya is a screening platform, not a diagnostic tool.**
>
> - It provides **developmental screening guidance only**
> - It does **not** diagnose any medical condition
> - Results identify areas that **may benefit from further professional evaluation**
> - Always consult a **qualified healthcare professional** for medical advice
>
> Before clinical deployment, obtain independent clinical validation and review privacy, storage security, accessibility, and reference-data redistribution requirements.

### Medical Language Policy

All user-facing text in this application follows strict screening language:
- ✅ *"developmental concern"*, *"risk"*, *"further evaluation recommended"*
- ❌ Never *"diagnosis"*, *"has autism"*, *"confirmed deficiency"*

---

## 🛣️ Roadmap

- [ ] Localization support (Hindi, regional languages)
- [ ] Cloud sync with healthcare provider systems
- [ ] Automated vaccination due/overdue alerts (pending clinical review)
- [ ] Composite risk scoring across all modules
- [ ] Accessibility improvements (screen reader, high contrast)
- [ ] Export screening reports as PDF

---

## 🤝 Contributing

Contributions are welcome! Please ensure:

1. All user-facing strings go in `lib/core/constants/app_strings.dart`
2. Medical language policy is strictly followed
3. No hardcoded text in widget files
4. Run `flutter analyze` and `flutter test` before submitting

---

## 📄 License

This project is for educational and research purposes. See individual data source licenses:
- [WHO Anthro License](assets/data/WHO_ANTHRO_LICENSE.md)
- [UIP Integration Provenance](assets/data/UIP_INTEGRATION.md)
- [WHO Reference Documentation](assets/data/WHO_REFERENCE.md)

---

<p align="center">
  <sub>Built with ❤️ for every child's healthy start</sub>
</p>
