#import "Seashore.h"

/*!
	@class		LayerDataSource
	@abstract	The view for Layer controls
	@discussion	Draws a background and borders for the buttons.
	<br><br>
	<b>License:</b> GNU General Public License<br>
	<b>Copyright:</b> Copyright (c) 2002 Mark Pazolli	
*/

@class SeaDocument;

@interface LayerDataSource : NSObject {
	// The document this data source is connected to
	__weak IBOutlet SeaDocument *document;

	// The nodes that are being dragged (if any)
	// This should be null during no dragging
    NSArray *draggedNodes;
	
	// A reference back to the outline view
    IBOutlet id outlineView;
    
    BOOL reloading;
	
}

/*!
	@method		draggedNodes
	@discussion	The nodes being dragged
	@result		An NSArray
*/
- (NSArray*)draggedNodes;

/*!
	@method		selectedNodes
	@discussion	The nodes selected
	@result		An NSArray
*/
- (NSArray *)selectedNodes;

/*!
	@method		update
	@discussion	Called when the data changes.
*/
- (void)update;
@end
