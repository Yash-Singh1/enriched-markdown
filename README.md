# Exact inline HTML line breaks

These are unedited screenshots from actual Enriched Markdown native example builds. Both platforms use the same Markdown fixture before and after, the original bundled Montserrat/Courier Prime fonts, the same TextScreen and theme, and the same viewport and device configuration on each platform.

Before uses unchanged parser `76c5fb301d4c952e93c8f9a2be8919d6888555ba` and consumer `926ef06f0c73671467e6b99cbc293e37df091fb7`. After uses parser C/H files byte-identical to `2af33db3f29d392cb372a2a0a5857a8ff1d4f6ca` and consumer `6f46511054de462382979f8132c53431a14dba64`. Final parser test-build and whitespace amendments did not change the C/H files in the native builds.

- iOS: iPhone 17 simulator, iOS 26.5. Native screenshot at 402x874 points.
- Android: dedicated Pixel 6 Pro AVD, Android 15 / API 35, 1440x3120 at 560 dpi.

The paragraph changes from literal tags to four lines, Pine/Oak/Birch/Elm. The first table cell changes from literal tags to three lines, Red/Green/Blue. The code-span controls in the adjacent cell and ordinary paragraph remain literal. Escaped tags, character references, tags with attributes and malformed tags remain literal. Table widths and row heights adjust naturally to the multiline cell content.

## Validation

The exact native fixture is in `fixture.md`. Both before/after pairs were inspected. These captures use the production standalone native parser bridges and renderers. The normal React Native iOS playground is verified separately by the new Maestro flow.

- Parser callback tests fail on the unchanged baseline and pass on the candidate. They compare full text-event output with an existing Markdown hard break, exercise disabled-HTML policies, and preserve controls.
- All 1,029 parser spec/pathological cases pass, including 31 pathological tests.
- Shared C++ golden AST, exported-symbol and coexistence checks pass. The rebuilt committed WASM parser agrees with the same fixture corpus.
- 24 focused iOS tests, 26 Android parser instrumentation tests and 525 Android UI unit tests pass. Android builds compile all four configured ABIs.
- Focused Maestro assertions pass on both standalone native examples and in the normal React Native iOS playground.
- Package prepare, TypeScript, 109 Jest tests, lint/formatting/whitespace checks, commit hooks and the docs production build pass.

The native setup only replaces the example's sample Markdown, opens its TextScreen initially and uses private app identifiers. The iOS evidence build resolves the same vendored RaTeX version through a local SwiftPM path to avoid a shared download-cache collision. Android evidence uses Gradle 9.4.1; the package lint check uses its original 9.5.1 wrapper. These temporary setup accommodations are excluded from the PR.

The parser extension is opt-in to preserve existing CommonMark and disabled-HTML callers. The consumer enables the new flag beside NOHTMLSPANS. General HTML rendering, raw HTML-block/video parsing, math features and clipboard/exporters are unchanged. A standalone br tag that parses as an HTML block keeps the existing block policy.
