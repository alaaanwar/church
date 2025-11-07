## Quick orientation

- This is a small Flutter quiz app (Arabic RTL). Primary UX lives in `lib/quiz_screen.dart`.
- Questions are loaded from a JSON URL (placeholder in code) or can be read from the bundled `assets/questions.json` listed in `pubspec.yaml`.

## Big-picture architecture

- Single-screen quiz flow implemented as a StatefulWidget (`QuizScreen`).
  - State: `questions`, `current`, `score`, `loading`, `showAnswer`, `selectedIndex`.
  - Navigation: on finish uses `Navigator.pushReplacement` to `ResultScreen` (`lib/result_screen.dart`).
- Data model: `Question` defined in `lib/question_model.dart` (fields: `id`, `question`, `options`, `answerIndex`).
- Networking: uses the `http` package to fetch a raw JSON file (URL defined in `lib/quiz_screen.dart`).

## Project-specific patterns & conventions

- RTL Arabic UI: text and alignment are right-to-left; when changing UI, check `TextAlign` and `Alignment.centerRight` usages in `quiz_screen.dart`.
- Simple state management: no external state library — keep mutations localized in `_QuizScreenState`.
- Short animations/timers: after answering the app waits ~800ms before moving to the next question. Avoid long blocking operations there.
- Error handling: failures to fetch JSON set `loading=false` and log via `debugPrint` — there is no user-facing retry flow.

## Integration points / external dependencies

- `http` (see `pubspec.yaml`) for fetching `questions.json` from a remote raw URL (e.g. GitHub raw link).
- Local asset sample: `assets/questions.json` — used as an example payload (same JSON schema as remote).

## Common developer workflows (commands)

- Install deps and run:
  - `flutter pub get`
  - `flutter run` (or `flutter run -d windows` / `-d chrome` as appropriate)
- Run tests (note: default widget test is stale and references a different app class):
  - `flutter test` — expect to update `test/widget_test.dart` before relying on tests.

## “Where to change things” — common edits

- To point the app to your questions JSON: edit `lib/quiz_screen.dart` and replace `questionsUrl` with a raw GitHub/gist URL or your hosted JSON. Example:
  `https://raw.githubusercontent.com/<user>/<repo>/main/questions.json`
- To use the bundled asset instead of remote HTTP: replace the fetch with `rootBundle.loadString('assets/questions.json')` and decode the JSON (ensure `import 'package:flutter/services.dart';`).

## Files to inspect when making changes

- `lib/quiz_screen.dart` — main logic, UI, and network placeholder. Primary touchpoint for feature work.
- `lib/question_model.dart` — schema for questions; keep JSON shape compatible with this factory.
- `assets/questions.json` — example payload and schema reference.
- `lib/result_screen.dart` — end-of-quiz UI and navigation behavior.
- `pubspec.yaml` — confirms asset inclusion and `http` dependency.

## Tests & CI notes

- There is a default `test/widget_test.dart` that still expects the template `MyApp`. Update tests to construct `QuizApp`/`QuizScreen` and mock network or use the asset file.
- No CI config found in repo root — keep tests lightweight and widget-level for this small app.

## Safety checks for PRs

- Verify the remote JSON URL you add is accessible (HTTP 200) and follows the same schema as `assets/questions.json`.
- Keep UI/strings RTL-safe when changing layouts; verify on a device/emulator.

If any of the above is unclear or you want the file to include examples for switching to asset-loading or a sample updated test, tell me which example you prefer and I'll add it.
