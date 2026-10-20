package swmansion.enriched.markdown.android.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.swmansion.enriched.markdown.compose.EnrichedMarkdownText
import com.swmansion.enriched.markdown.math.LatexMathPlugin

class AndroidExampleMainActivity : ComponentActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContent {
      MaterialTheme {
        EnrichedMarkdownText(
          markdown = """
# Alternate math delimiters

Inline equation

Answer: \(x_1 + 1\).

Display equation

\[x^2 + y^2 = z^2\]

Dollar math still works

${'$'}u_1 + 1${'$'}

${'$'}${'$'}a^2 + b^2 = c^2${'$'}${'$'}
          """.trimIndent(),
          plugins = listOf(LatexMathPlugin),
          modifier = Modifier.fillMaxSize().background(Color.White)
            .verticalScroll(rememberScrollState()).padding(24.dp),
        )
      }
    }
  }
}
