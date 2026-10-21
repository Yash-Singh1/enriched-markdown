package swmansion.enriched.markdown.android.example

import android.app.Activity
import android.os.Bundle
import android.graphics.Color
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Switch
import com.swmansion.enriched.markdown.EnrichedMarkdown
import com.swmansion.enriched.markdown.MarkdownOptions

class AndroidExampleMainActivity : Activity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    val column = LinearLayout(this).apply {
      orientation = LinearLayout.VERTICAL
      setPadding(24.dp, 48.dp, 24.dp, 24.dp)
      setBackgroundColor(Color.WHITE)
    }
    fun label(text: String, size: Float) = TextView(this).apply {
      this.text = text
      textSize = size
      setTextColor(Color.BLACK)
      setPadding(0, 0, 0, 20.dp)
    }
    column.addView(label("Optional indented code", 24f))
    val toggle = Switch(this).apply { text = "Render indented prose"; textSize = 16f }
    column.addView(toggle)
    val status = label("Default / false", 16f)
    column.addView(status)
    val markdown = EnrichedMarkdown(this)
    column.addView(markdown, LinearLayout.LayoutParams(-1, -2))
    markdown.setMarkdownContent("    **Indented prose** with *formatting*.\n\n```js\nconst fenced = true;\n```\n\n~~~text\nTilde fenced control\n~~~")
    toggle.setOnCheckedChangeListener { _, enabled ->
      status.text = if (enabled) "noIndentedCodeBlocks = true" else "Default / false"
      markdown.setOptions(MarkdownOptions())
    }
    setContentView(column)
  }
  private val Int.dp: Int get() = (this * resources.displayMetrics.density).toInt()
}
