Here is your **README.md in pure Markdown** (ready to copy & paste):

````markdown
# arch CLI

Flutter Clean Architecture Project & Module Generator.

`arch` is a powerful Dart CLI tool that scaffolds **production-ready Flutter projects** using **Clean Architecture** with best practices and pre-configured tooling.

---

## ✨ Features

- ✅ Clean Architecture structure
- ✅ Dio + Retrofit API client setup
- ✅ Environment variables using `envied`
- ✅ Localization (ARB + Flutter l10n)
- ✅ GoRouter navigation setup
- ✅ Multi-flavor support (optional)
- ✅ Dependency Injection pre-configured
- ✅ Theming system (multiple color schemes)
- ✅ Pagination utilities
- ✅ Authentication & Onboarding ready modules
- ✅ Module generation with multiple state management options

---



## 📦 Installation

Activate globally from pub.dev:

```bash
dart pub global activate arch
````

Make sure the Dart pub cache bin is in your PATH:

```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

Verify installation:

```bash
arch --version
```

---

## 🚀 Usage

### Create a New Project

```bash
arch --create project
```

You will be guided through interactive setup:

* Project name
* Description
* Owner URL
* Android bundle id
* iOS bundle id
* Target platforms
* Architecture pattern
* Navigation type
* API client
* License selection

---

### Create a Feature Module

```bash
arch --create module
```

You will be asked to choose:

* Module name
* State management:

  * Bloc
  * Cubit
  * HydratedBloc
  * HydratedCubit
  * None

---

## 📁 Generated Project Structure

```
lib/
├── app/
│   ├── constants/
│   ├── environment/
│   ├── generated/
│   ├── l10n/
│   ├── router/
│   ├── theme/
│   └── view/
├── core/
│   ├── clients/
│   ├── di/
│   ├── extensions/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── onboarding/
│   └── splash/
├── main_development.dart
└── main_production.dart
```

---

## 🧩 Module Generator Output

When generating a module, the following structure is created:

```
features/<module_name>/
├── data/
├── domain/
└── presentation/
```

With selected state management:

* Bloc
* Cubit
* HydratedBloc
* HydratedCubit
* None

---

## ⚙️ Requirements

* Dart >= 3.0.0
* Flutter >= 3.10.0
* Git installed
* macOS / Linux / Windows supported

---

## 🧪 Development

Run locally while developing:

```bash
dart run bin/main.dart --create project
```

---

## 🤝 Contributing

Contributions are welcome.

1. Fork the repository
2. Create a new branch
3. Commit your changes
4. Push to GitHub
5. Open a Pull Request

---

