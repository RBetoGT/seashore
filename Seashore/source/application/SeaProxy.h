#import "Seashore.h"

/*!
	@class		SeaProxy
	@abstract	Passes various messages to the current document.
	@discussion	The SeaProxy passes various messages on to the current document
				allowing objects in the MainMenu NIB file to interact with the
				current document. Most methods in this class are undocumented.
				The class carries out menu item validation.
				<br><br>
				<b>License:</b> GNU General Public License<br>
				<b>Copyright:</b> Copyright (c) 2002 Mark Pazolli
*/

@interface SeaProxy : NSObject {
}

- (IBAction)exportAsTexture:(id)sender;
- (IBAction)exportAsBrush:(id)sender;

// To methods in SeaView...
- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomNormal:(id)sender;
- (IBAction)zoomToFit:(id)sender;
- (IBAction)zoomOut:(id)sender;

// To methods in SeaWhiteboard...
- (IBAction)toggleSoftProof:(id)sender;

// To methods in SeaSupport
- (IBAction)showSupportSeashore:(id)sender;

// To methods in SeaContent....
- (IBAction)importLayer:(id)sender;
- (IBAction)copyMerged:(id)sender;
- (IBAction)copyLayer:(id)sender;
- (IBAction)flatten:(id)sender;
- (IBAction)mergeLinked:(id)sender;
- (IBAction)mergeDown:(id)sender;
- (IBAction)raiseLayer:(id)sender;
- (IBAction)bringToFront:(id)sender;
- (IBAction)lowerLayer:(id)sender;
- (IBAction)sendToBack:(id)sender;
- (IBAction)deleteLayer:(id)sender;
- (IBAction)addLayer:(id)sender;
- (IBAction)duplicateLayer:(id)sender;
- (IBAction)layerAbove:(id)sender;
- (IBAction)layerBelow:(id)sender;
- (IBAction)setColorSpace:(id)sender;
- (IBAction)toggleLinked:(id)sender;
- (IBAction)clearAllLinks:(id)sender;
- (IBAction)layerFromSelection:(id)sender;
- (IBAction)duplicate:(id)sender;
- (IBAction)changeSelectedChannel:(id)sender;
- (IBAction)changeTrueView:(id)sender;

// To methods in SeaLayer...
- (IBAction)toggleLayerAlpha:(id)sender;

// To methods in SeaAlignment...
- (IBAction)alignLeft:(id)sender;
- (IBAction)alignRight:(id)sender;
- (IBAction)alignHorizontalCenters:(id)sender;
- (IBAction)alignTop:(id)sender;
- (IBAction)alignBottom:(id)sender;
- (IBAction)alignVerticalCenters:(id)sender;
- (IBAction)centerLayerHorizontally:(id)sender;
- (IBAction)centerLayerVertically:(id)sender;

// To methods in SeaResolution...
- (IBAction)setResolution:(id)sender;

// To methods in SeaMargins...
- (IBAction)setMargins:(id)sender;
- (IBAction)condenseLayer:(id)sender;
- (IBAction)condenseToSelection:(id)sender;
- (IBAction)expandLayer:(id)sender;

// To methods in SeaScale...
- (IBAction)setScale:(id)sender;
- (IBAction)setLayerScale:(id)sender;

// To methods in SeaDocRotation...
- (IBAction)rotateDocLeft:(id)sender;
- (IBAction)rotateDocRight:(id)sender;

// To method in SeaRotation...
- (IBAction)setLayerRotation:(id)sender;

// To methods in SeaFlip...
- (IBAction)flipDocHorizontally:(id)sender;
- (IBAction)flipDocVertically:(id)sender;
- (IBAction)flipLayerHorizontally:(id)sender;
- (IBAction)flipLayerVertically:(id)sender;
- (IBAction)flipSelectionHorizontally:(id)sender;
- (IBAction)flipSelectionVertically:(id)sender;

// To methods in SeaPlugins...
- (IBAction)reapplyEffect:(id)sender;

// To methods in Utilities...
- (IBAction)selectTool:(id)sender;
- (IBAction)toggleLayers:(id)sender;
- (IBAction)toggleInformation:(id)sender;
- (IBAction)toggleOptions:(id)sender;
- (IBAction)toggleStatusBar:(id)sender;
- (IBAction)toggleRecentsBar:(id)sender;

// To the ColorView
- (IBAction)activateForegroundColor:(id)sender;
- (IBAction)activateBackgroundColor:(id)sender;
- (IBAction)swapColors:(id)sender;
- (IBAction)defaultColors:(id)sender;

// To crashing...
- (IBAction)crash:(id)sender;

/*!
	@method		validateMenuItem:
	@discussion	Determines whether a given menu item should be enabled or
				disabled.
	@param		menuItem
				The menu item to be validated.
	@result		YES if the menu item should be enabled, NO otherwise.
*/
- (BOOL)validateMenuItem:(id)menuItem;

@end
