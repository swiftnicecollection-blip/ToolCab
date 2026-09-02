# Contributing to ToolCab

Thank you for your interest in contributing to ToolCab! This document provides guidelines for contributing to the project.

## Development Setup

### Prerequisites

- Flutter SDK `>=3.3.0`
- Dart SDK `>=3.3.0`
- Git

### Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/yourusername/toolcab.git
   cd toolcab
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Verify setup:
   ```bash
   flutter analyze
   flutter test
   ```

## Branch Naming

Use descriptive branch prefixes:

- `feature/` — New features (e.g., `feature/add-export-options`)
- `fix/` — Bug fixes (e.g., `fix/pdf-merge-error`)
- `docs/` — Documentation updates (e.g., `docs/update-readme`)
- `refactor/` — Code refactoring (e.g., `refactor/cleanup-controllers`)

## Coding Standards

### Dart Style

- Follow the [Dart Style Guide](https://dart.dev/effective-dart/style)
- Use `dart format .` to format code before committing
- Keep lines under 80 characters where practical

### Naming Conventions

| Concept | Convention | Example |
|---------|------------|---------|
| Files | `snake_case.dart` | `app_routes.dart` |
| Classes | `PascalCase` | `AppRoutes` |
| Constants | `camelCase` | `routeName` |
| Controllers | `XxxController` | `HomeController` |
| Bindings | `XxxBinding` | `HomeBinding` |
| Widgets | `XxxWidget` | `PremiumCard` |
| Repositories | `XxxRepository` | `HistoryRepository` |
| Services | `XxxService` | `StorageService` |

### Architecture Guidelines

- Follow the existing feature-based structure
- Keep controllers lean — move business logic to services
- Use reactive state management with GetX observables
- Dispose controllers and services properly
- Write self-documenting code with clear variable names

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/core/utils/validators_test.dart
```

### Writing Tests

- Add tests for new functionality
- Test edge cases and error conditions
- Keep tests focused and independent

## Pull Requests

1. Create a feature branch from `main`
2. Make focused, atomic commits
3. Write clear commit messages
4. Ensure all tests pass:
   ```bash
   flutter analyze
   flutter test
   ```
5. Update documentation if needed
6. Submit a pull request with a clear description

### PR Description Template

```
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring

## Testing
How was this tested?

## Checklist
- [ ] Code follows style guidelines
- [ ] Tests pass
- [ ] Documentation updated
- [ ] No breaking changes
```

## Bug Reports

When reporting bugs, include:

- Clear description of the issue
- Steps to reproduce
- Expected behavior
- Actual behavior
- Platform (Web/Android/iOS)
- Flutter version (`flutter --version`)

## Feature Requests

Feature requests are welcome! Please provide:

- Clear description of the feature
- Use case and benefits
- Potential implementation approach

## Code Review

All submissions require review. Reviewers will check for:

- Code quality and readability
- Adherence to architecture patterns
- Test coverage
- Documentation completeness
- Performance considerations

## Questions?

Feel free to open an issue for questions or join discussions.

Thank you for contributing to ToolCab!
