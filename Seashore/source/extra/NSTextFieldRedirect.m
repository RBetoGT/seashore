#import "NSTextFieldRedirect.h"
#import "SeaDocument.h"
#import "SeaController.h"
#import "OptionsUtility.h"
#import "SeaTools.h"
#import "TextTool.h"

@implementation NSTextFieldRedirect

- (void)changeSpecialFont:(id)sender
{
	[[[gCurrentDocument optionsUtility] getOptions:kTextTool] changeFont:sender];
}

@end
