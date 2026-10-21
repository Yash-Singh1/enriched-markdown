#import "../../ios/segments/TableContainerView.h"
#import "../../ios/parser/MarkdownASTNode.h"
#import "../../ios/utils/PasteboardUtils.h"
#import <XCTest/XCTest.h>

@interface ENRMTableClipboardEvidenceController : UIViewController
@property(nonatomic, strong) TableContainerView *table;
@property(nonatomic, strong) UITextView *plain;
@property(nonatomic, strong) UITextView *source;
@property(nonatomic, strong) UILabel *count;
@property(nonatomic, strong) XCTestExpectation *done;
@end
@implementation ENRMTableClipboardEvidenceController
- (MarkdownASTNode *)node:(MarkdownNodeType)type children:(NSArray *)children {
  MarkdownASTNode *n=[[MarkdownASTNode alloc] initWithType:type];
  for (MarkdownASTNode *c in children) [n addChild:c];
  return n;
}
- (MarkdownASTNode *)text:(NSString *)value {
  MarkdownASTNode *n=[self node:MarkdownNodeTypeText children:@[]]; n.content=value; return n;
}
- (UILabel *)label:(NSString *)value size:(CGFloat)size stack:(UIStackView *)stack {
  UILabel *l=[UILabel new]; l.text=value; l.font=[UIFont systemFontOfSize:size]; l.numberOfLines=0; [stack addArrangedSubview:l]; return l;
}
- (UITextView *)field:(CGFloat)size height:(CGFloat)height stack:(UIStackView *)stack {
  UITextView *t=[UITextView new]; t.font=[UIFont monospacedSystemFontOfSize:size weight:UIFontWeightRegular]; t.backgroundColor=[UIColor colorWithRed:.93 green:.95 blue:.98 alpha:1]; t.textColor=UIColor.blackColor; t.editable=NO; [t.heightAnchor constraintEqualToConstant:height].active=YES; [stack addArrangedSubview:t]; return t;
}
- (void)button:(NSString *)value action:(SEL)action stack:(UIStackView *)stack {
  UIButton *b=[UIButton buttonWithType:UIButtonTypeSystem]; [b setTitle:value forState:UIControlStateNormal]; [b addTarget:self action:action forControlEvents:UIControlEventTouchUpInside]; [b.heightAnchor constraintEqualToConstant:36].active=YES; [stack addArrangedSubview:b];
}
- (void)viewDidLoad {
  [super viewDidLoad]; self.view.backgroundColor=UIColor.whiteColor;
  self.overrideUserInterfaceStyle=UIUserInterfaceStyleLight;
  UIStackView *stack=[UIStackView new]; stack.axis=UILayoutConstraintAxisVertical; stack.spacing=8; stack.translatesAutoresizingMaskIntoConstraints=NO; [self.view addSubview:stack];
  [NSLayoutConstraint activateConstraints:@[[stack.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],[stack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],[stack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]]];
  [self label:@"Table clipboard • iOS" size:23 stack:stack];
  [self label:@"Constructed AST: first + hard break + bold + soft break + third. Native table Copy actions." size:13 stack:stack];
  MarkdownASTNode *header=[self node:MarkdownNodeTypeTableHead children:@[[self node:MarkdownNodeTypeTableRow children:@[[self node:MarkdownNodeTypeTableHeaderCell children:@[[self text:@"Cell"]]],[self node:MarkdownNodeTypeTableHeaderCell children:@[[self text:@"Empty"]]]]]]];
  MarkdownASTNode *body=[self node:MarkdownNodeTypeTableBody children:@[[self node:MarkdownNodeTypeTableRow children:@[[self node:MarkdownNodeTypeTableCell children:@[[self text:@"first"],[self node:MarkdownNodeTypeLineBreak children:@[]],[self node:MarkdownNodeTypeStrong children:@[[self text:@"bold"]]],[self node:MarkdownNodeTypeSoftBreak children:@[]],[self text:@"third"]]],[self node:MarkdownNodeTypeTableCell children:@[]]]]]];
  StyleConfig *config=[StyleConfig new];
  [config setTableFontSize:16]; [config setTableColor:UIColor.blackColor];
  [config setTableHeaderTextColor:UIColor.blackColor]; [config setTableHeaderBackgroundColor:[UIColor colorWithWhite:.9 alpha:1]];
  [config setTableRowEvenBackgroundColor:UIColor.whiteColor]; [config setTableRowOddBackgroundColor:UIColor.whiteColor];
  [config setTableBorderColor:UIColor.grayColor]; [config setTableBorderWidth:1];
  [config setTableCellPaddingHorizontal:12]; [config setTableCellPaddingVertical:6];
  self.table=[[TableContainerView alloc] initWithConfig:config];
  [self.table applyTableNode:[self node:MarkdownNodeTypeTable children:@[header,body]]];
  self.table.dynamicProps.copyLabel=@"Copy"; self.table.dynamicProps.copyAsMarkdownLabel=@"Copy as Markdown";
  CGFloat h=[self.table measureHeight:350]; [self.table.heightAnchor constraintEqualToConstant:h].active=YES; [stack addArrangedSubview:self.table];
  [self label:@"Long press the table, choose Copy, then paste below." size:12 stack:stack];
  [self button:@"Paste text/plain" action:@selector(pastePlain) stack:stack];
  [self label:@"text/plain → native plain-text field" size:13 stack:stack];
  self.plain=[self field:16 height:112 stack:stack];
  [self label:@"Choose Copy as Markdown, then paste its source below." size:12 stack:stack];
  [self button:@"Paste Markdown source" action:@selector(pasteSource) stack:stack];
  self.count=[self label:@"Markdown source • physical lines: —" size:13 stack:stack];
  self.source=[self field:12 height:136 stack:stack];
  [self label:@"Exporter fixture, not parser round-trip. Native <br> parsing is still unsupported. Literal/code content is unchanged." size:12 stack:stack];
  [self button:@"Finish evidence capture" action:@selector(finish) stack:stack];
}
- (void)pastePlain {
  id value=UIPasteboard.generalPasteboard.items.firstObject[kUTIPlainText];
  NSString *text=[value isKindOfClass:NSString.class] ? value : [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
  self.plain.text=@""; [self.plain insertText:text ?: @""];
}
- (void)pasteSource {
  NSString *text=UIPasteboard.generalPasteboard.string ?: @"";
  self.source.text=@""; [self.source insertText:text];
  NSUInteger lines=[[text stringByTrimmingCharactersInSet:NSCharacterSet.newlineCharacterSet] componentsSeparatedByString:@"\n"].count;
  self.count.text=[NSString stringWithFormat:@"Markdown source • physical lines: %lu",(unsigned long)lines];
}
- (void)finish { [self.done fulfill]; }
@end
@interface ENRMTableClipboardEvidenceTests : XCTestCase
@end
@implementation ENRMTableClipboardEvidenceTests
- (void)testNativeClipboardEvidence {
  ENRMTableClipboardEvidenceController *controller=[ENRMTableClipboardEvidenceController new];
  controller.done=[self expectationWithDescription:@"Evidence captured"];
  UIWindowScene *scene=(UIWindowScene *)UIApplication.sharedApplication.connectedScenes.anyObject;
  UIWindow *window=scene.windows.firstObject;
  window.rootViewController=controller; [window makeKeyAndVisible];
  [self waitForExpectationsWithTimeout:600 handler:nil];
}
@end
