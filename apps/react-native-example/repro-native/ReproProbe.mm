#import <React/RCTBridgeModule.h>
#import <UIKit/UIKit.h>
#import <React/RCTConvert.h>
#import "Revision.h"
#import "../../../packages/react-native-enriched-markdown/ios/utils/HTMLGenerator.h"
#import "../../../packages/react-native-enriched-markdown/ios/utils/MarkdownASTSerializer.h"
#import "../../../packages/react-native-enriched-markdown/ios/styles/StyleConfig.h"
#import "../../../packages/react-native-enriched-markdown/ios/parser/MarkdownASTNode.h"
#import "../../../packages/react-native-enriched-markdown/ios/attachments/ENRMMathInlineAttachment.h"
@interface ReproProbe:NSObject<RCTBridgeModule>
@end
@implementation ReproProbe
RCT_EXPORT_MODULE();
+ (BOOL)requiresMainQueueSetup{return YES;}
- (dispatch_queue_t)methodQueue{return dispatch_get_main_queue();}
- (NSDictionary*)constantsToExport{return @{ @"revision": REPRO_REVISION };}
RCT_EXPORT_METHOD(run:(NSDictionary*)unused kind:(NSString*)kind resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
 StyleConfig *style=[StyleConfig new];
 [unused enumerateKeysAndObjectsUsingBlock:^(NSString *role,id element,BOOL *stop){if(![element isKindOfClass:NSDictionary.class])return;[element enumerateKeysAndObjectsUsingBlock:^(NSString *key,id value,BOOL *innerStop){
 NSString *property=[role stringByAppendingString:[key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] uppercaseString]]];
 NSString *setter=[NSString stringWithFormat:@"set%@%@:",[[property substringToIndex:1] uppercaseString],[property substringFromIndex:1]];
 if([style respondsToSelector:NSSelectorFromString(setter)]&&([value isKindOfClass:NSString.class]||[value isKindOfClass:NSNumber.class])){[style setValue:[key.lowercaseString containsString:@"color"]?[RCTConvert UIColor:value]:value forKey:property];}
 }];}];
 NSString *payload; NSString *pasted=@""; NSString *summary;
 if([kind isEqualToString:@"markdown"]){
  MarkdownASTNode *cell=[[MarkdownASTNode alloc] initWithType:MarkdownNodeTypeTableCell];
  MarkdownASTNode *math=[[MarkdownASTNode alloc] initWithType:MarkdownNodeTypeLatexMathInline];
  MarkdownASTNode *text=[[MarkdownASTNode alloc] initWithType:MarkdownNodeTypeText];text.content=@"x_1";[math addChild:text];[cell addChild:math];
  payload=markdownFromASTNodeChildren(cell);UIPasteboard.generalPasteboard.string=payload;payload=UIPasteboard.generalPasteboard.string;
  summary=[payload isEqualToString:@"$x_1$"]?@"Math delimiters preserved":@"Math delimiters missing";
 } else {
  if([kind isEqualToString:@"formula"]){
   ENRMMathInlineAttachment *math=[ENRMMathInlineAttachment new];math.latex=@"x_1";math.fontSize=19;math.mathTextColor=UIColor.blackColor;
   payload=generateHTML([NSAttributedString attributedStringWithAttachment:math],style);
  }else{
   NSAttributedString *text=[[NSAttributedString alloc] initWithString:@"first\nsecond"];
   payload=generateTableHTML(@[@[@{@"attributedText":text,@"isHeader":@NO}]],style);
  }
  UIPasteboard.generalPasteboard.items=@[@{@"public.html":[payload dataUsingEncoding:NSUTF8StringEncoding]}];
  NSData *html=[UIPasteboard.generalPasteboard dataForPasteboardType:@"public.html"];
  payload=[[NSString alloc] initWithData:html encoding:NSUTF8StringEncoding];
  NSError *error=nil; NSAttributedString *imported=[[NSAttributedString alloc] initWithData:html options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)} documentAttributes:nil error:&error];
  pasted=[imported.string stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]?:error.localizedDescription?:@"";
  summary=[kind isEqualToString:@"formula"]?([payload containsString:@"$x_1$"]?@"Formula delimiters preserved in HTML":@"Formula delimiters missing from HTML") : ([payload containsString:@"first<br>second"]?@"Cell line break preserved":@"Cell line break collapses on paste");
 }
 // Return the cell/paragraph fragment so style boilerplate does not hide the result.
 NSString *fragment=payload;
 NSRange start=[payload rangeOfString:[kind isEqualToString:@"breaks"]?@"<td ":@"<p "];
 if(start.location!=NSNotFound){NSRange end=[payload rangeOfString:[kind isEqualToString:@"breaks"]?@"</td>":@"</p>" options:0 range:NSMakeRange(start.location,payload.length-start.location)];if(end.location!=NSNotFound)fragment=[payload substringWithRange:NSMakeRange(start.location,NSMaxRange(end)-start.location)];}
 NSDictionary *result=@{@"revision":REPRO_REVISION,@"kind":kind,@"payload":fragment?:@"",@"fullHtml":payload?:@"",@"pasted":pasted,@"summary":summary};
 NSString *file=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"repro-%@.json",kind]];[[NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:nil] writeToFile:file atomically:YES];
 resolve(result);
}
@end
