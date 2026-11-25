package swmansion.enriched.markdown.example
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.graphics.Color
import android.text.*
import com.facebook.react.ReactPackage
import com.facebook.react.bridge.*
import com.facebook.react.uimanager.ViewManager
import com.swmansion.enriched.markdown.parser.MarkdownASTNode
import com.swmansion.enriched.markdown.styles.StyleConfig
import com.swmansion.enriched.markdown.utils.common.serialization.MarkdownASTSerializer
import com.swmansion.enriched.markdown.utils.text.conversion.HTMLGenerator
import com.swmansion.enriched.markdown.spans.MathInlineSpan
class ReproProbe(val context:ReactApplicationContext):ReactContextBaseJavaModule(context){
 override fun getName()="ReproProbe"
 override fun getConstants():Map<String,Any> = mapOf("revision" to ReproRevision.value)
 @ReactMethod fun run(styleMap:ReadableMap,kind:String,promise:Promise){context.runOnUiQueueThread {try{
 val style=StyleConfig(styleMap,context,false,0f)
 val clipboard=context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
 var pasted=""
 val raw=when(kind){
 "markdown"->{ val math=MarkdownASTNode(MarkdownASTNode.NodeType.LatexMathInline,children=listOf(MarkdownASTNode(MarkdownASTNode.NodeType.Text,"x_1")));MarkdownASTSerializer.serializeChildren(MarkdownASTNode(MarkdownASTNode.NodeType.TableCell,children=listOf(math)))}
 "breaks"->HTMLGenerator.generateTableHTML(listOf(listOf(Triple(SpannableString("first\nsecond") as CharSequence,false,Layout.Alignment.ALIGN_NORMAL))),style)
 else->{val text=SpannableString("\uFFFC");text.setSpan(MathInlineSpan(context,"x_1",19f,Color.BLACK,null),0,1,Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);HTMLGenerator.generateHTML(text,style)}
 }
 clipboard.setPrimaryClip(if(kind=="markdown")ClipData.newPlainText("Markdown",raw)else ClipData.newHtmlText("HTML fixture","",raw))
 val item=clipboard.primaryClip!!.getItemAt(0)
 val actual=if(kind=="markdown") item.text.toString() else item.htmlText!!
 if(kind!="markdown")pasted=Html.fromHtml(actual,Html.FROM_HTML_MODE_LEGACY).toString().trim()
 val summary=when(kind){"markdown"->if(actual=="\$x_1\$")"Math delimiters preserved" else "Math delimiters missing";"breaks"->if(actual.contains("first<br>second"))"Cell line break preserved"else "Cell line break collapses on paste";else->if(actual.contains("\$x_1\$"))"Formula delimiters preserved in HTML"else "Formula delimiters missing from HTML"}
 val tag=if(kind=="breaks")"td" else "p"
 val fragment=Regex("<$tag\\b[^>]*>.*?</$tag>",RegexOption.DOT_MATCHES_ALL).find(actual)?.value?:actual
 java.io.File(context.filesDir,"repro-$kind.json").writeText(org.json.JSONObject(mapOf("revision" to ReproRevision.value,"kind" to kind,"payload" to fragment,"fullHtml" to actual,"pasted" to pasted,"summary" to summary)).toString(2))
 promise.resolve(Arguments.createMap().apply{putString("payload",fragment);putString("fullHtml",actual);putString("pasted",pasted);putString("summary",summary)})
 }catch(e:Throwable){promise.reject("repro",e)}}}
}
class ReproPackage:ReactPackage{
 override fun createNativeModules(context:ReactApplicationContext)=listOf<NativeModule>(ReproProbe(context))
 override fun createViewManagers(context:ReactApplicationContext)=emptyList<ViewManager<*,*>>()
}
