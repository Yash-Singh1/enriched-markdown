# One reusable upstream example

This worktree reuses the upstream React Native example. Native exporter probes live in `apps/react-native-example/repro-native` and the Android example app package. The UI cases live in `apps/react-native-example/src/App.tsx`.

The probes call production library functions. They do not replace any library implementation. The clipboard fixture builds native math attachments, attributed table-cell text and the table-cell AST directly, then writes and reads the system clipboard. HTML output is imported with NSAttributedString on iOS and Html.fromHtml on Android. The UI hides HTML style attributes to keep the content visible; the evidence JSON retains complete output.

From this worktree run `python3 repro/select-revision.py before`, or pass `991`, `994`, `995`. Each PR head has the same upstream base. These selections are independent, not cumulative. The library package versions never change. Rebuild both clients after selecting a revision; the native build tag on screen must match it.

Installed JavaScript dependencies are shared with `../enriched-markdown-latex`. The released RaTeX vendor assets are copied once because CocoaPods does not discover Swift sources inside a directory symlink. No extra sample checkout or native build directory is needed per PR.

Start Metro from `apps/react-native-example` with `node node_modules/react-native/cli.js start --port 8081`.

For iOS, from `apps/react-native-example/ios` run `pod install` whenever changing revision. Then run:

```
RCT_NO_LAUNCH_PACKAGER=1 xcodebuild -workspace EnrichedMarkdownExample.xcworkspace -scheme EnrichedMarkdownExample -configuration Debug -destination 'platform=iOS Simulator,id=B027E45D-A72C-49FC-824A-7850C3111118' -derivedDataPath ../repro-build/ios -jobs 6 CODE_SIGNING_ALLOWED=NO build
```

The app is `apps/react-native-example/repro-build/ios/Build/Products/Debug-iphonesimulator/EnrichedMarkdownExample.app`.

For Android, from `apps/react-native-example/android` run:

```
JAVA_HOME=/Users/yashsingh/Library/Java/JavaVirtualMachines/jbr-21/Contents/Home ANDROID_HOME=/Users/yashsingh/Library/Android/sdk ./gradlew :app:assembleDebug -PreactNativeArchitectures=arm64-v8a --console=plain --no-daemon
```

The APK is `apps/react-native-example/android/app/build/outputs/apk/debug/app-debug.apk`. Reverse TCP 8081 to Metro when running on the emulator.

Both platforms use app id `swmansion.enriched.markdown.example`. Use T3 Code's Device panel and its returned AgentDevice invocation to install, open, inspect and capture the example.

Evidence goes to `../latex-screenshots/Upstream-PR-repros`. PR #991 changes iOS only, so Android is a regression control. PR #995 tests table-cell exporter input directly because upstream's Markdown parser does not implement HTML `<br>` parsing. A `<br>` rendering fixture would test a different change.

PR #995 now uses amended commit 3be6e76a8a9292a487a8d1a04ae8d7611ddb3c16. Its current UI exposes only Cell breaks and Table Markdown. All eight PR #995 screenshots were retaken against the unchanged base and amended head with the same fixture. The removed Formula HTML screenshots and their evidence records were deleted. The legacy formula probe remains unused by the current UI.
