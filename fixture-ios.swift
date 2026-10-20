import SwiftUI
import EnrichedMarkdown
import EnrichedMarkdownLaTeX

@main
struct EnrichedMarkdownExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ScrollView {
                EnrichedMarkdownText(#"""
# Alternate math delimiters

Inline equation

Answer: \(x_1 + 1\).

Display equation

\[x^2 + y^2 = z^2\]

Dollar math still works

$u_1 + 1$

$$a^2 + b^2 = c^2$$
"""#)
                    .markdownLaTeX()
                    .padding(24)
            }
            .background(Color.white)
            .preferredColorScheme(.light)
        }
    }
}
