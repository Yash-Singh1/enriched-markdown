package swmansion.enriched.markdown.example

import android.app.Activity
import android.os.Bundle
import android.content.ClipboardManager
import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.widget.*
import android.view.Gravity
import com.facebook.react.bridge.JavaOnlyMap
import com.swmansion.enriched.markdown.parser.MarkdownASTNode
import com.swmansion.enriched.markdown.parser.MarkdownASTNode.NodeType
import com.swmansion.enriched.markdown.segments.TableContainerView
import com.swmansion.enriched.markdown.styles.StyleConfig

class MainActivity : Activity() {
  private val context: Context get() = this
  private fun node(type: NodeType, vararg children: MarkdownASTNode) = MarkdownASTNode(type, children = children.toList())
  private fun text(value: String) = MarkdownASTNode(NodeType.Text, value)
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    window.statusBarColor = Color.WHITE
    window.navigationBarColor = Color.WHITE
    val scroll = ScrollView(this)
    val panel = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL; setPadding(24, 32, 24, 24); setBackgroundColor(Color.WHITE) }
    scroll.addView(panel)
    setContentView(scroll)
    fun label(value: String, size: Float = 14f) = TextView(this).also { it.text = value; it.textSize = size; it.setTextColor(Color.BLACK); it.setPadding(0, 6, 0, 6); panel.addView(it) }
    label("Table clipboard • Android", 22f)
    label("Constructed AST: first + hard break + bold + soft break + third. Native table Copy actions.", 13f)
    val ast = node(NodeType.Table,
      node(NodeType.TableHead, node(NodeType.TableRow, node(NodeType.TableHeaderCell, text("Cell")), node(NodeType.TableHeaderCell, text("Empty")))),
      node(NodeType.TableBody, node(NodeType.TableRow, node(NodeType.TableCell, text("first"), node(NodeType.LineBreak), node(NodeType.Strong, text("bold")), node(NodeType.SoftBreak), text("third")), node(NodeType.TableCell))))
    val view = TableContainerView(this, style())
    view.dynamicProps.copyLabel = "Copy"
    view.dynamicProps.copyAsMarkdownLabel = "Copy as Markdown"
    view.applyTableNode(ast)
    panel.addView(view)
    label("Long press the table, choose Copy, then paste below.", 12f)
    val plainButton = Button(this).apply { text = "Paste text/plain"; panel.addView(this) }
    label("text/plain → native plain-text field", 13f)
    val plain = EditText(this).apply { textSize=16f; typeface=Typeface.MONOSPACE; setTextColor(Color.BLACK); setBackgroundColor(0xffedf3fa.toInt()); setPadding(12,8,12,8); minLines=4; showSoftInputOnFocus=false; panel.addView(this) }
    plainButton.setOnClickListener {
      val clip = (getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager).primaryClip
      plain.setText(clip?.getItemAt(0)?.text?.toString() ?: "Clipboard empty")
    }
    label("Choose Copy as Markdown, then paste its source below.", 12f)
    val mdButton = Button(this).apply { text="Paste Markdown source"; panel.addView(this) }
    val count=label("Markdown source • physical lines: —",13f)
    val md=EditText(this).apply { textSize=12f; typeface=Typeface.MONOSPACE; setTextColor(Color.BLACK); setBackgroundColor(0xffedf3fa.toInt()); setPadding(12,8,12,8); minLines=6; showSoftInputOnFocus=false; panel.addView(this) }
    mdButton.setOnClickListener {
      val copied=(getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager).primaryClip?.getItemAt(0)?.text?.toString() ?: ""
      md.setText(copied)
      count.text="Markdown source • physical lines: ${copied.trimEnd('\n').lines().size}"
    }
    label("Exporter fixture, not parser round-trip. Native <br> parsing is still unsupported. Literal/code content is unchanged.",12f)
  }
  private fun style(): StyleConfig {
    com.facebook.react.uimanager.DisplayMetricsHolder
      .initDisplayMetricsIfNotInitialized(context)

    fun element() =
      JavaOnlyMap().apply {
        listOf(
          "aspectRatio",
          "bulletSize",
          "checkboxBorderRadius",
          "checkboxSize",
          "height",
          "itemSpacing",
          "markerMinWidth",
          "maxHeight",
          "cellPaddingHorizontal",
          "cellPaddingVertical",
          "horizontalOverflow",
          "lineHeight",
          "marginTop",
          "marginBottom",
          "padding",
          "borderRadius",
          "borderWidth",
          "gapWidth",
          "marginLeft",
        ).forEach {
          putDouble(it, 0.0)
        }
        listOf(
          "bulletColor",
          "checkedColor",
          "checkedTextColor",
          "checkmarkColor",
          "headerBackgroundColor",
          "headerTextColor",
          "markerColor",
          "rowEvenBackgroundColor",
          "rowOddBackgroundColor",
          "color",
          "borderColor",
        ).forEach {
          putInt(it, Color.BLACK)
        }
        putString("resizeMode", "contain")
        putString("fontFamily", "")
        putString("fontWeight", "normal")
        putDouble("fontSize", 16.0)
        putDouble("cellPaddingHorizontal", 12.0)
        putDouble("cellPaddingVertical", 6.0)
        putDouble("borderWidth", 1.0)
        putDouble("fontScale", 0.8)
        putDouble("baselineOffsetScale", 0.5)
        putBoolean("underline", false)
        putInt("backgroundColor", Color.TRANSPARENT)
        putInt("headerBackgroundColor", 0xffe6e6e6.toInt())
        putInt("rowEvenBackgroundColor", Color.WHITE)
        putInt("rowOddBackgroundColor", Color.WHITE)
      }
    val style = JavaOnlyMap()
    listOf(
      "inlineMath",
      "table",
      "paragraph",
      "codeBlock",
      "code",
      "blockquote",
      "list",
      "link",
      "strong",
      "em",
      "strikethrough",
      "underline",
      "highlight",
      "image",
      "superscript",
      "subscript",
    ).forEach { style.putMap(it, element()) }
    style.putMap(
      "spoiler",
      element().apply {
        putMap("particles", JavaOnlyMap.of("density", 0.5, "speed", 1.0))
        putMap("solid", JavaOnlyMap.of("borderRadius", 0.0))
      },
    )
    for (level in 1..6) style.putMap("h$level", element())
    style.putMap(
      "taskList",
      JavaOnlyMap.of(
        "checkedColor",
        Color.BLACK,
        "borderColor",
        Color.BLACK,
        "checkmarkColor",
        Color.BLACK,
        "checkedTextColor",
        Color.BLACK,
        "checkboxSize",
        16.0,
        "checkboxBorderRadius",
        0.0,
        "checkedStrikethrough",
        false,
      ),
    )
    return StyleConfig(style, context, false, 0f)
  }
}
