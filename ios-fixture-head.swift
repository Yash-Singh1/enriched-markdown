import SwiftUI
import EnrichedMarkdown

@main
struct EnrichedMarkdownExampleApp: App {
    var body: some Scene {
        WindowGroup { IndentedCodeEvidence().preferredColorScheme(.light) }
    }
}

struct IndentedCodeEvidence: View {
    @State private var enabled = false
    private let markdown = "    **Indented prose** with *formatting*.\n\n```js\nconst fenced = true;\n```\n\n~~~text\nTilde fenced control\n~~~"
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Optional indented code").font(.title2.bold())
            Toggle("Render indented prose", isOn: $enabled)
            Text(enabled ? "noIndentedCodeBlocks = true" : "Default / false").font(.callout)
            EnrichedMarkdownText(markdown, options: parsingOptions)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
        .padding(24)
        .background(Color.white)
    }
    private var parsingOptions: MarkdownParsingOptions {
        // EVIDENCE_OPTIONS
        MarkdownParsingOptions(noIndentedCodeBlocks: enabled)
    }
}
