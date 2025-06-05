# Flutter Markdown (Maintained Fork)

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

A Very Good Project created by Very Good CLI.

## Installation 💻

**❗ In order to start using Flutter Markdown, you must have the [Flutter SDK][flutter_install_link] installed on your machine.**

> **Note: This repository is a maintained fork of the official [`flutter_markdown`](https://github.com/flutter/packages/tree/860ecdea6c8d7ee36021cf79e7c332982b050060/packages/flutter_markdown) package, which has been discontinued.**
>
> If you were previously using `flutter_markdown`, please point your project to this fork by adding a Git dependency, as shown below:
>
> ```yaml
> # pubspec.yaml example
> dependencies:
>   flutter_markdown:
>     git:
>       url: https://github.com/AndrewDongminYoo/flutter_markdown.git
>       ref: main
> ```

To start using Flutter Markdown (Maintained Fork), add the dependency to your `pubspec.yaml` as shown above, then run:

```sh
flutter pub get
```

If you want to add it directly via the command line (for local testing, for example), run:

```sh
flutter pub add flutter_markdown \
  --git-url https://github.com/AndrewDongminYoo/flutter_markdown.git \
  --git-ref main
```

---

## Continuous Integration 🤖

Flutter Markdown (Maintained Fork) comes with a built-in [GitHub Actions workflow][github_actions_link] powered by [Very Good Workflows][very_good_workflows_link], but you can also integrate your preferred CI/CD solution.

Out of the box, on each pull request and push, the CI workflow will `format`, `lint`, and `test` the code. This ensures consistency and correctness as you add new functionality. The project uses [Very Good Analysis][very_good_analysis_link] for strict analysis rules. Code coverage is enforced using the [Very Good Workflows][very_good_coverage_link].

---

## Running Tests 🧪

For first time users, install the [very_good_cli][very_good_cli_link]:

```sh
dart pub global activate very_good_cli
```

To run all unit tests:

```sh
very_good test --coverage
```

To view the generated coverage report, use [lcov](https://github.com/linux-test-project/lcov):

```sh
# Generate Coverage Report
genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
open coverage/index.html
```

[flutter_install_link]: https://docs.flutter.dev/get-started/install
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://pub.dev/packages/very_good_cli
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
