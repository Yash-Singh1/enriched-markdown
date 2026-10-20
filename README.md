# Multiline display math precedence evidence

The same native fixture renders `$$ a` as a Setext heading and `b $$` as prose before the parser fix. After the fix it renders one RaTeX display formula, `a = b`. The ordinary Setext heading below it remains a heading.

Before uses consumer `926ef06f0c73671467e6b99cbc293e37df091fb7` and the unchanged parser `76c5fb301d4c952e93c8f9a2be8919d6888555ba`. After uses consumer `069915d50dca665af629ee1da9cec11f7162f9b5`, with parser C/H files byte-identical to `928da08e9b2a5d9d1e20eef0340555cc38af7e57`.

The four PNGs are actual native app captures. Each platform uses the same fixture, example layout, fonts, theme, viewport and device settings before and after. Agent-device captured iOS at 402x874, @1x, on iPhone 17 Pro with iOS 26.5. Android uses a dedicated Pixel 6 AVD with Android 15/API 35 at 1080x2400 and density 420. The iOS Custom math theme toggle is off in both captures. No screenshot was drawn, mocked, or substituted with a web view.

`fixture.md` is the exact Markdown input. `native-fixture.patch` records the temporary example launch, fixture and application-ID edits against the original consumer baseline. Those edits are outside the consumer production commit. For screenshot capture the existing iOS MathScreen starts at the application root, and Android opens its existing TextScreen. Both use the production standalone Enriched Markdown parser and renderer. The consumer commit separately adds regression equations to the regular iOS Math example and focused native Maestro flows.

All 1,027 parser/spec examples and 36 pathological cases pass. Eleven math-spec regressions fail on the unchanged parser. All 21 Android ParserTest instrumentation methods and all 21 iOS LaTeXRenderingTests plus 18 ParserTests pass. Both new native regression methods fail on the unchanged parser. The new iOS renderer method uses the real RaTeX engine. Consumer C++ golden/coexistence checks and the rebuilt WASM bundle pass, including the new math fixture. Formatting, TypeScript, lint and the docs production build pass.

Both focused standalone native Maestro flows pass. Android verifies math accessibility labels. The normal iOS navigation example exposes complete delimited-source fallback under Maestro, so its regression accepts either the exact complete fallback equation or the typeset math label. This does not establish typesetting in that navigation path. The root Math-screen screenshots and real-engine native tests separately verify actual RaTeX typesetting. The full Maestro suite was not run.

The new block precedence applies to complete standalone `$$` paragraphs. A blank line or container boundary ends the search. An inner unescaped dollar or backtick retains the existing inline/block rules. Nested math retains the existing renderer presentation.

`validation.json` records the source revisions, screenshot hashes, device settings and test counts. The authoritative source change is on the parser fork's `fix/multiline-math-block-precedence` branch. The companion consumer branch has the same name.
