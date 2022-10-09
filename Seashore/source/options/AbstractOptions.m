#import "AbstractOptions.h"
#import "SeaController.h"
#import "ToolboxUtility.h"
#import "SeaPrefs.h"
#import "SeaDocument.h"
#import "AspectRatio.h"
#import "TextureUtility.h"

static int lastTool = -1;
static BOOL forceAlt = NO;

@implementation AbstractOptions

- (void)activate:(id)sender
{
	int curTool;
	
	document = sender;
	curTool = [[document toolboxUtility] tool];
	if (lastTool != curTool) {
		[self updateModifiers:0];
		lastTool = curTool;
	}
}

- (IBAction)update:(id)sender
{
}

- (void)forceAlt
{
	forceAlt = YES;
    int modifiers = [self modifier];
    [self updateModifiers:modifiers];
}

- (void)unforceAlt
{
	if (forceAlt) {
        forceAlt = NO;
		[self updateModifiers:0];
	}
}

- (void)updateModifiers:(unsigned int)modifiers
{
	int index;
	
	if (modifierPopup) {

        if(forceAlt){
            modifiers |= NSAlternateKeyMask;
        }
	
		if ((modifiers & NSAlternateKeyMask) >> 19 && (modifiers & NSControlKeyMask) >> 18) {
			index = [modifierPopup indexOfItemWithTag:kAltControlModifier];
			if (index > 0) [modifierPopup selectItemAtIndex:index];
		}
		else if ((modifiers & NSShiftKeyMask) >> 17 && (modifiers & NSControlKeyMask) >> 18) {
			index = [modifierPopup indexOfItemWithTag:kShiftControlModifier];
			if (index > 0) [modifierPopup selectItemAtIndex:index];
		}
		else if ((modifiers & NSControlKeyMask) >> 18) {
			index = [modifierPopup indexOfItemWithTag:kControlModifier];
			if (index > 0) [modifierPopup selectItemAtIndex:index];
		}
		else if ((modifiers & NSShiftKeyMask) >> 17) {
			index = [modifierPopup indexOfItemWithTag:kShiftModifier];
			if (index > 0) [modifierPopup selectItemAtIndex:index];
		}
		else if ((modifiers & NSAlternateKeyMask) >> 19) {
			index = [modifierPopup indexOfItemWithTag:kAltModifier];
			if (index > 0) [modifierPopup selectItemAtIndex:index];
		}
		else {
			[modifierPopup selectItemAtIndex:kNoModifier];
		}
	}
}

- (int)modifier
{
	return [[modifierPopup selectedItem] tag];
}

- (IBAction)modifierPopupChanged:(id)sender
{
//
}

- (BOOL)useTextures
{
    return [[document toolboxUtility] foregroundIsTexture];
}

- (void)shutdown
{
}

- (id)view
{
	return view;
}

@end
