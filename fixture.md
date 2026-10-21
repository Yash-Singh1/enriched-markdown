# Table clipboard fixture

Both native example hosts construct the same AST, then call `TableContainerView.applyTableNode`. The table contains two columns and one body row.

```text
Table
  TableHead
    TableRow
      TableHeaderCell(Text("Cell"))
      TableHeaderCell(Text("Empty"))
  TableBody
    TableRow
      TableCell
        Text("first")
        LineBreak
        Strong(Text("bold"))
        SoftBreak
        Text("third")
      TableCell()
```

The screenshots show the production table view and native clipboard readback fields. Long press the real table and select Copy, then tap Paste text/plain. The button reads the text/plain clipboard flavor and inserts it into the native text field. Long press the table again and select Copy as Markdown, then tap Paste Markdown source. This button reads the copied Markdown source from the system clipboard. Its physical line count comes from that clipboard value.

The fixture never supplies expected export output to either field and never writes to the clipboard itself. Production Copy handlers own every clipboard write. Android Copy as Markdown uses a plain-text ClipData item containing Markdown, as it does upstream. iOS regular Copy also advertises a Markdown UTI, which the regressions check separately.

The parser does not yet convert HTML `<br>` into break AST nodes. This is an exporter fixture and a source preview, not a claim that `<br>` round-trips through the native parser. Soft breaks render as spaces on Android. iOS's direct cell rendering in this fixture concatenates these nodes. Neither renderer changes in this patch. The clipboard fields are the evidence of the export change.

The fixture code is local evidence only. It is removed from the upstream commit.
