# Table-cell clipboard break evidence

Production base: `926ef06f0c73671467e6b99cbc293e37df091fb7`.
Production head: `9c29d07c6e224f534299e62f83916873d2d4580c`.

The four PNGs are original screenshots captured from the upstream React Native example's native hosts. Before runs use unmodified upstream production code. Both platforms use the same fixture, layout and viewport before and after. The manifests record production source blob IDs and screenshot SHA-256 values.

## Observed output

Before, plain Copy reads `firstboldthird`; after, it reads `first`, `bold`, and `third` on separate cell lines. The copied Markdown changes from five physical lines to three, with one body row containing `| first<br>**bold**<br>third |  |`.

The fixture constructs a table AST with a hard break, a bold span, and a soft break. The actual production table's long-press Copy and Copy as Markdown actions write the OS clipboard. Native paste buttons read that clipboard into native text fields. The source panel counts physical lines from the clipboard value. No expected exporter output is embedded in the fields.

The parser still treats `<br>` literally. These screenshots show exporter output and Markdown source. They do not claim a native parser round-trip. iOS's direct cell renderer concatenates these constructed nodes; Android renders a hard break and a space for the soft break. Rendering does not change in this patch. The clipboard fields show the export change.

## Devices

- iPhone 17 simulator, iOS 26.5. 402 x 874 points at 3x, 1206 x 2622 PNGs.
- Dedicated T3MultilineEvidence emulator, Android 15 / API 35. 1080 x 2400 pixels at density 420. Build `AE3A.240806.036`.

## Reproduction

`fixture/MainActivity.kt` temporarily replaces `apps/react-native-example/android/app/src/main/java/swmansion/enriched/markdown/example/MainActivity.kt`. `fixture/TableClipboardEvidenceTests.mm` temporarily goes into `packages/react-native-enriched-markdown/__tests__/ios/`, where the existing test-source generator discovers it. Neither temporary fixture is in the production PR.

Run each fixture against the recorded base and head. Install dependencies with the checked-in Yarn CLI, run `yarn prepare`, and run `pod install` in the React Native example iOS directory. From the repository root:

```sh
apps/react-native-example/android/gradlew -p apps/react-native-example/android \
  :app:assembleDebug -PreactNativeArchitectures=arm64-v8a --max-workers=4
xcodebuild test \
  -workspace apps/react-native-example/ios/EnrichedMarkdownExample.xcworkspace \
  -scheme EnrichedMarkdownExample -destination 'platform=iOS Simulator,id=<simulator-udid>' \
  -parallel-testing-enabled NO -derivedDataPath apps/react-native-example/ios/build \
  -only-testing:EnrichedMarkdownExampleTests/ENRMTableClipboardEvidenceTests CODE_SIGNING_ALLOWED=NO
```

On each device, long press the table, choose Copy, then tap Paste text/plain. Long press again, choose Copy as Markdown, then tap Paste Markdown source. Capture the whole screen. Each platform uses the same fixture files and device settings before and after. iOS's Finish evidence capture button ends the temporary XCTest.

## Validation

- Android full library JVM lane: 37 tests pass, including 9 clipboard tests. On the unchanged production base, the three clipboard regressions fail.
- iOS full example-host lane: 25 tests pass, including 10 clipboard tests. On the unchanged production base, three clipboard regression methods fail with nine failed assertions. The seven other clipboard methods pass on the base.
- All 109 Jest tests, typecheck, source lint, library/display-benchmark ktlint, changed-file clang-format and whitespace checks pass. Source lint excludes generated build directories and retains one existing inline-style warning.
- Maestro was not run.

Android's host JVM cannot load RaTeX's Android native library, so math preservation is checked through the production cell serializer. The other inline nodes exercise the table view and real menu callback. iOS tests also exercise math through the table view and pasteboard. Literal text and code contents retain their existing serialization; this patch converts break nodes only.
