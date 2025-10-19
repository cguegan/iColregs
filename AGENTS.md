# Repository Guidelines

## Project Structure & Module Organization
- `App/`: Entry point and app lifecycle (`iColregsApp`).
- `Core/`: Primary modules.
  - `Models/`: Data contracts (`PartModel`, `RuleModel`, etc.).
  - `Services/`: Data loading (`AppService`) and search orchestration (`SearchService`).
  - `Helpers/`: Shared utilities (search/highlighting helpers).
  - `Views/`: SwiftUI surfaces (`ColregsView`, `IpadSplitView`, etc.).
- `Data/`: Bundled JSON sources for rules/annexes (English/French).
- `Original Texts/`: Markdown references used within the app.

## Build, Test, and Development Commands
- `open iColregs.xcodeproj`: Launch project in Xcode.
- `xcodebuild -scheme iColregs -sdk iphonesimulator`: CLI build for simulator targets.
- Tests currently run via Xcode’s test navigator; add CLI scripts if automated testing is introduced.

## Coding Style & Naming Conventions
- Swift files use 2-space indentation and `lowerCamelCase` for properties/functions; types and views use `UpperCamelCase`.
- Keep filenames aligned with the primary type (e.g., `SearchService.swift`).
- Break SwiftUI modifier chains into logical groups (layout, typography, state) and prefer struct-level helpers for complex view logic.

## Testing Guidelines
- Manual verification via iOS simulator is required; automated suites are not yet configured.
- When adding tests, place them under `iColregsTests/` (create if absent) and name methods `testFeatureName_Scenario()`.
- Validate both English and French flows when updating shared UI logic (`language` parameter).

## Commit & Pull Request Guidelines
- Use concise, imperative commit messages (e.g., “Add search highlighting”).
- Group related changes per commit; separate UI and data updates when practical.
- Pull requests should include:
  - Summary of changes with impacted views/services.
  - Screenshots or screen recordings for UI work (iPad + iPhone when relevant).
  - Linked issues/tasks and any follow-up steps.

## Security & Configuration Tips
- JSON data ships with the bundle—avoid committing private or production secrets.
- Code defaults to system accent colors; confirm accessibility contrast before merging.
