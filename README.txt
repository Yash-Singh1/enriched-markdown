Alternate LaTeX delimiter native evidence

This branch contains evidence only. It is separate from the implementation PR.

Parser baseline: 76c5fb301d4c952e93c8f9a2be8919d6888555ba
Parser candidate: cdf931f8d2ce4673829eaa69cc2fa90c1bcead09
Consumer baseline: 926ef06f0c73671467e6b99cbc293e37df091fb7
Consumer candidate: c37b5d3df4b5082c1413e73698ebff1b9af98f92

The before builds use unchanged parser C/H files at the baseline SHA. The after
builds use C/H files byte-identical to the candidate SHA. Both platforms run the
actual production standalone Enriched Markdown parser and RaTeX renderer.

Each platform uses identical fixture input, example startup, fonts, appearance,
viewport and device configuration before and after. The screenshots are unedited
native captures, opened and visually inspected individually. iOS uses iPhone 17e,
iOS 26.5, 390x844 points, with its status bar fixed at 9:41. Android uses the
T3LatexEvidence AVD, Android 15/API 35, 1080x2400 pixels at 420 dpi.

Before, the bracket formulas show literal parentheses, brackets, underscores and
carets. After, the inline equation has a typeset subscript and the display
formula has superscripts in a native math block. Both single- and double-dollar
controls remain typeset. These single-line formulas are independent of the
separate multiline-equation/Setext-precedence fix and HTML line-break parsing.

fixture.md is the shared input. fixture-ios.swift, fixture-android.kt and
example-setup.patch record the temporary example startup and application ID.
This setup is outside the production implementation diff.

Validation passed: 1,043 parser spec/pathological checks; 25 math-spec cases,
including 13 that fail on baseline; 22 iOS LaTeXRenderingTests and 18 ParserTests;
21 Android JNI parser tests and 22 math unit tests; both focused standalone
native Maestro flows; 30 shared C++ golden fixture/flag combinations and 12 WASM
combinations; 10 web parser Jest tests, including two failing on baseline;
TypeScript, lint, targeted formatting, docs build, and commit hooks. The full
Maestro suite and the React Native example app native builds were not run for
this feature.

Future Maestro runs must acquire /tmp/enriched-upstream-native-evidence.lock
through testing and driver cleanup, including when using dedicated devices.
