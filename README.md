# Biometrics Dashboard

Interactive biometrics visualization dashboard built with Flutter.

This project is a small, self-contained app demonstrating:
- synchronized time-series charts for HRV, Resting Heart Rate (RHR), and Steps
- support for small (90-day) and large (~10k+) datasets
- client-side decimation to keep charts responsive on large datasets
- simple annotation/journal overlay and range selection
- simulated backend behavior (latency + failures) and caching

---

## Features

- Responsive dashboard UI (mobile & desktop widths)
- Summary cards (avg HRV / RHR / Steps)
- Interactive charts using fl_chart with pinch-to-zoom and pan
- Annotations/journals shown on charts
- Dataset toggle (normal vs large)
- Client-side LTTB decimation for large datasets
- Data validation pipeline and simple repository + caching
- Simulated backend latency and failure to exercise error handling / retry

---

## Quick start

Prerequisites
- Flutter (Dart SDK >= the version in pubspec.yaml; tested with a stable Flutter matching SDK constraints)
- A device or emulator (flutter doctor to validate)

Install & run
1. Clone the repo
   git clone https://github.com/Yeee12/biometrics_dashboard.git
2. Fetch dependencies
   flutter pub get
3. Run on a connected device or emulator
   flutter run

Run tests
- Run all tests:
  flutter test

Profile & benchmark
- Run the app in profile mode to measure performance:
  flutter run --profile -d <device-id>
- Build a profile APK:
  flutter build apk --profile

---

## Project structure (high level)

- lib/
    - core/constants/ (AppConstants and global config)
    - data/
        - models/ (json_serializable models)
        - repositories/ (BiometricRepository, JournalRepository — load & cache)
        - services/ (DataDecimator, DataValidator)
    - domain/ (entities like TimeRange)
    - presentation/
        - providers/ (Riverpod providers / state)
        - screens/ (dashboard_screen.dart)
        - widgets/ (biometric_chart.dart and related UI)
- assets/data/ (sample datasets: biometric_90d.json, large dataset generator)
- test/ (unit + widget tests)

This layering keeps responsibilities separated:
- data layer: loading, validating, and transforming raw data
- domain layer: simple business types and logic
- presentation layer: state + UI only

## Libraries & rationale

- flutter_riverpod — solid, testable state management without widget-coupling; provider composition makes the state flows clear.
- fl_chart — flexible charting with good customization for a small demo; supports many of the visuals needed.
- json_serializable + build_runner — safe, simple JSON model generation for BiometricData.
- intl — date/number formatting for UI labels.
- collection — small utilities used in data manipulation.

Why these choices
- Prioritized developer ergonomics and low setup friction over heavy, production-only analytics frameworks.
- fl_chart provides interactive features needed (pinch/zoom) quickly; if you need extremely large datasets or GPU-accelerated plotting, consider specialized charting libs.

## Decimation (what, where, why)

Why decimate?
- Large time-series (10k+ points) cause slow paints and degraded interactivity.
- Decimation reduces the number of plotted points while aiming to preserve the visual shape.

Algorithm
- The app uses LTTB (Largest-Triangle-Three-Buckets) style decimation implemented in the data decimator service.
- The decision to decimate is made via DataDecimator.shouldDecimate(...) — when the filtered dataset length exceeds the configured threshold the UI shows a "✓ LTTB decimation applied" note (see UI in the header/Performance Note card).

Tradeoffs
- Pros: preserves the overall curve shape, dramatically reduces number of render points, increases responsiveness.
- Cons: may hide very narrow spikes/outliers if they fall between buckets; not suitable if every single raw sample must be visible.

Where to adjust
- Thresholds and decimation parameters are configured in lib/core/constants/app_constants.dart (e.g., AppConstants.decimationThreshold). Tweak according to target devices or UI density.

When not to decimate
- When downstream analytics require every sample (export/alerts), run decimation only for rendering, not for storage or export.

## Performance notes & tips

- The repository simulates network latency and failures to exercise retry and error states. Configuration is in AppConstants:
    - minLatencyMs, maxLatencyMs (e.g. 700–1200 ms)
    - failureRate is non-zero to simulate transient errors (e.g. 0.1)
- BiometricRepository caches loaded datasets to avoid repeated decoding work.
- For profiling:
    - Use Flutter DevTools (CPU & memory profiling, timeline) while running in profile mode.
    - Watch GPU & raster times for chart-heavy screens.
- Optimization ideas if needed:
    - Run decimation in an isolate (compute) to avoid UI jank.
    - Reduce number of FlSpot points (decimation) and simplify gradients/paints.
    - Cache rendered chart bitmaps for complex, mostly-static views.
    - Limit rebuilds: make widgets const where possible and narrow provider subscriptions.

## Tests

Current test coverage
- test/ includes a unit test and a widget test covering core paths and a critical UI component.
- To run tests:
  flutter test

Recommendations
- Add unit tests for DataDecimator (LTTB results, edge-cases).
- Add repository tests to verify caching, simulated latency/failure, and large dataset generation.
- Add more widget/integration tests for interactions (zoom, pan, annotations).

## Tradeoffs & scope (summary of what was intentionally left out)

What was cut and why
- No server/backend: data is loaded from assets and optionally generated; this reduces infra complexity for a demo.
- No authentication or multi-user support: out of scope for an interactive demo.
- No long-term storage or sync (e.g., cloud backups): increases complexity and cost.
- No export to CSV/GPX: omitted to keep the UI focused on visualization and to avoid extra I/O code paths.
- Advanced analytics (e.g., ML anomaly detection) kept out to maintain a small, focused codebase.

Mitigations
- The code is structured so adding server sync, auth, or exports can be done at the repository/service layer without major UI rewrites.

---

## Development notes & where to look in the code

- BiometricRepository
    - lib/data/repositories/biometric_repository.dart
    - Responsible for loading asset JSON, generating / interpolating larger datasets, caching, and simulating latency/failure.
    - Look for _simulateLatency and _simulateFailure to tweak behavior.

- Data validation & decimation
    - lib/data/services/data_validator.dart — input validation rules (date bounds, HRV/RHR/steps ranges).
    - lib/data/services/data_decimator.dart — decimation logic and threshold check (used by the UI).

- UI & charts
    - lib/presentation/screens/dashboard_screen.dart — overall screen layout, performance note, dataset toggle, range selector.
    - lib/presentation/widgets/charts/biometric_chart.dart — chart rendering, spots creation, grid/axis logic, pan/zoom instruction.

- Constants
    - lib/core/constants/app_constants.dart — colors, thresholds, simulated latency/failure settings, chart padding etc.

## Contributing

- Follow existing style and Riverpod patterns.
- Add tests for new behavior and run flutter test locally.
- Use build_runner when changing models:
  flutter pub run build_runner build --delete-conflicting-outputs

## Known limitations

- Small test suite (only one unit + one widget test currently).
- Rendering may still be slow on very old devices; you can reduce AppConstants.decimationThreshold or further offload processing to isolates.
- No continuous integration configured (recommended: add a GitHub Actions workflow to run flutter analyze and flutter test).