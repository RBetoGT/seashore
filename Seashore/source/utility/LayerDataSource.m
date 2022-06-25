#import "SeaDocument.h"
#import "SeaContent.h"
#import "LayerCell.h"
#import "NSOutlineView_Extensions.h"
#import "SeaLayer.h"
#import "SeaHelpers.h"
#import "SeaController.h"
#import "LayersUtility.h"
#import "LayerSettings.h"

#import "LayerDataSource.h"

#define SEA_LAYER_PBOARD_TYPE   @"Seashore Layer Pasteboard Type"
#define LAYER_THUMB_NAME_COL    @"Layer Details Column"
#define LAYER_VISIBLE_COL       @"Layer Visible Column"
#define INFO_BUTTON_COL         @"Layer Info Column"

@implementation LayerDataSource
- (void)awakeFromNib
{
	// Register to get our custom type, strings, and filenames. Try dragging each into the view!
    [outlineView registerForDraggedTypes:[NSArray arrayWithObjects:SEA_LAYER_PBOARD_TYPE, NSStringPboardType, NSFilenamesPboardType, nil]];
	[outlineView setVerticalMotionCanBeginDrag: YES];

	[outlineView setIndentationPerLevel: 0.0];
	[outlineView setOutlineTableColumn:[outlineView tableColumnWithIdentifier:LAYER_THUMB_NAME_COL]];

    [outlineView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    [outlineView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];

	draggedNodes = nil;
}

- (NSArray *)draggedNodes { return draggedNodes; }
- (NSArray *)selectedNodes { return [outlineView allSelectedItems]; }

// ================================================================
// Target / action methods. (most wired up in IB)
// ================================================================

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSArray *selectedNodes = [self selectedNodes];
    SeaLayer *selectedLayer = [selectedNodes count] > 0 ? [selectedNodes objectAtIndex:0] : NULL;
    int index = (selectedLayer ? [selectedLayer index] : 0);
    
    if(index==[[document contents] activeLayerIndex]){
        return;
    }
    
    [[document helpers] activeLayerWillChange];
    [[document contents] setActiveLayerIndex:index];
    [[document helpers] activeLayerChanged:kLayerSwitched];
}

// ================================================================
//  NSOutlineView data source methods. (The required ones)
// ================================================================

// Required methods. These methods must handle the case of a "nil" item, which indicates the root item.
- (id)outlineView:(NSOutlineView *)olv child:(int)index ofItem:(id)item
{
	if(!document)
		return 0;
	if(item != nil)
		NSLog(@"%@ says olv %@ requested a child at %d for %@ erroniously", self, olv, index, item);
	return [[document contents] layer:index];
}

- (BOOL)outlineView:(NSOutlineView *)olv isItemExpandable:(id)item
{
	// For now, layers cannot have children
	return NO;
}

- (int)outlineView:(NSOutlineView *)olv numberOfChildrenOfItem:(id)item
{
	if(!document)
		return 0;
	// The root node has the number of layers as children
	if(item == nil)
		return [[document contents] layerCount];
	// Other layers do not have children
	return 0;
}

- (id)outlineView:(NSOutlineView *)olv objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	// There is only one colum so there's not much need to worry about this
    if ([[tableColumn identifier] isEqualToString:LAYER_THUMB_NAME_COL]) {
		return [(SeaLayer *)item name];
	}else if([[tableColumn identifier] isEqualToString:LAYER_VISIBLE_COL]){
		return [NSNull null];
	}else if([[tableColumn identifier] isEqualToString:INFO_BUTTON_COL]){
		return [NSNumber numberWithBool:NO];
	}else{
		NSLog(@"Object value for unkown column: %@", tableColumn);
	}
	return nil;
}

// Optional method: needed to allow editing.
- (void)outlineView:(NSOutlineView *)ov setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if ([[tableColumn identifier] isEqualToString:LAYER_THUMB_NAME_COL]) {
		[(SeaLayer *)item setName:object];
	}else if([[tableColumn identifier] isEqualToString:LAYER_VISIBLE_COL]){
        bool visible = [(SeaLayer *)item visible];
		[[document contents] setVisible:!visible forLayer:[(SeaLayer *)item index]];
	}else if([[tableColumn identifier] isEqualToString:INFO_BUTTON_COL]){
        NSPoint p0 = [[ov window] mouseLocationOutsideOfEventStream];
        NSPoint p = [ov convertPoint:p0 fromView:nil];
        int row = [ov rowAtPoint:p];
        int col = [ov columnAtPoint:p];
        NSRect r = [ov frameOfCellAtColumn:col row:row];

//        NSLog(@"point %@ rect %@",NSStringFromPoint(p),NSStringFromRect(r));

        if(p.y > r.origin.y+r.size.height/2) {
            SeaLayer *layer = (SeaLayer*)item;
            bool linked = [layer linked];
            [[document contents] setLinked:!linked forLayer:[layer index]];
        }else {
            p = [[ov window] convertBaseToScreen:p0];
            [[[document layersUtility] layerSettings] showSettings:item from:p];
        }

	}else{
		NSLog(@"Setting the value for unknown column %@", tableColumn);
	}	
}

// We can return a different cell for each row, if we want
- (NSCell *)outlineView:(NSOutlineView *)ov dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	// But we choose to, for now, have one type of data cell
	return [tableColumn dataCell];
}

// To get the "group row" look, we implement this method.
- (BOOL)outlineView:ov isGroupItem:(id)item
{
	// But it is not needed
	return NO;
}

- (BOOL)outlineView:(NSOutlineView *)olv shouldExpandItem:(id)item
{
	// Again, there should be no expanding right now
	return NO;
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if ([[tableColumn identifier] isEqualToString:LAYER_THUMB_NAME_COL]) {
		// Make sure the image and text cell has an image. 
		// We know that the cell at this column is our image and text cell, so grab it
		LayerCell *layerCell = (LayerCell *)cell;
		// Set the image here since the value returned from outlineView:objectValueForTableColumn:... didn't specify the image part...
		[layerCell setImage:[(SeaLayer *)item thumbnail]];
		if([[self selectedNodes] count] > 0 && [[self selectedNodes] objectAtIndex:0] == item){
			[layerCell setSelected: YES];
		}else{
			[layerCell setSelected: NO];
		}
	}else if([[tableColumn identifier] isEqualToString:LAYER_VISIBLE_COL]){
        [cell setRepresentedObject:item];
        [cell setObjectValue:@TRUE];
	}else if([[tableColumn identifier] isEqualToString:INFO_BUTTON_COL]){
        [cell setRepresentedObject:item];
        [cell setObjectValue:@TRUE];
	}else{
		NSLog(@"Will display cell for unkown column %@", tableColumn);
	}
}

- (BOOL)outlineView:(NSOutlineView *)ov shouldSelectItem:(id)item
{
	if([ov clickedColumn]==0)
        return FALSE;
    if([ov clickedColumn]==2)
        return FALSE;
	return YES;
}

- (BOOL)outlineView:(NSOutlineView *)ov shouldTrackCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	// We want to allow tracking for all the button cells, even if we don't allow selecting that particular row. 
	return YES;
}

// ================================================================
//  NSOutlineView data source methods. (dragging related)
// ================================================================

// Create a fileHandle for writing to a new file located in the directory specified by 'dirpath'.  If the file basename.extension already exists at that location, then append "-N" (where N is a whole number starting with 1) until a unique basename-N.extension file is found.  On return oFilename contains the name of the newly created file referenced by the returned NSFileHandle.
NSFileHandle *NewFileHandleForWritingFile(NSString *dirpath, NSString *basename, NSString *extension, NSString **oFilename)
{
    NSString *filename = nil;
    BOOL done = NO;
    int fdForWriting = -1, uniqueNum = 0;
    while (!done) {
        filename = [NSString stringWithFormat:@"%@%@.%@", basename, (uniqueNum ? [NSString stringWithFormat:@"-%ld", (long)uniqueNum] : @""), extension];
        fdForWriting = open([[NSString stringWithFormat:@"%@/%@", dirpath, filename] UTF8String], O_WRONLY | O_CREAT | O_EXCL, 0666);
        if (fdForWriting < 0 && errno == EEXIST) {
            // Try another name.
            uniqueNum++;
        } else {
            done = YES;
        }
    }
	
    NSFileHandle *fileHandle = nil;
    if (fdForWriting>0) {
        fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:fdForWriting closeOnDealloc:YES];
    }
    
    if (oFilename) {
        *oFilename = (fileHandle ? filename : nil);
    }
    
    return fileHandle;
}

// We promised the files, so now lets make good on that promise!
- (NSArray *)outlineView:(NSOutlineView *)outlineView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination forDraggedItems:(NSArray *)items
{
    int i = 0, count = [items count];
    NSMutableArray *filenames = [NSMutableArray array];
    for (i=0; i<count; i++) {
        SeaLayer *layer = (SeaLayer *)[items objectAtIndex:i];
        NSString *filename  = nil;
        NSString *layerName = [layer name];
        layerName = [layerName stringByDeletingPathExtension];

        NSFileHandle *fileHandle = NewFileHandleForWritingFile([dropDestination path], layerName, @"tif", &filename);
        if (fileHandle) {
            [fileHandle writeData: [layer TIFFRepresentation]];
            fileHandle = nil;
            [filenames addObject: filename];
        }
    }
    return ([filenames count] ? filenames : nil);
}

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
{
    draggedNodes = items; // Don't retain since this is just holding temporaral drag information, and it is only used during a drag!  We could put this in the pboard actually.
    
    // Provide data for our custom type, and simple NSStrings.
    [pboard declareTypes:[NSArray arrayWithObjects:SEA_LAYER_PBOARD_TYPE, NSTIFFPboardType, NSFilesPromisePboardType, NSStringPboardType, nil] owner:self];
	
    // the actual data doesn't matter since DragDropSimplePboardType drags aren't recognized by anyone but us!.
    [pboard setData:[NSData data] forType:SEA_LAYER_PBOARD_TYPE]; 
	[pboard setData:[[draggedNodes objectAtIndex:0] TIFFRepresentation] forType:NSTIFFPboardType];

    // Put the promised type we handle on the pasteboard.
    [pboard setPropertyList:[NSArray arrayWithObjects:@"tif", nil] forType:NSFilesPromisePboardType];
	
    // Put string data on the pboard... notice you candrag into TextEdit!
    [pboard setString: [[draggedNodes objectAtIndex: 0] name] forType: NSStringPboardType];
    
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)ov validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(int)childIndex
{
   // This method validates whether or not the proposal is a valid one. Returns NO if the drop should not be allowed.
    BOOL targetNodeIsValid = YES;
	BOOL isOnDropTypeProposal = childIndex==NSOutlineViewDropOnItemIndex;
		
	// Refuse if: dropping "on" the view itself unless we have no data in the view.
	if (item==nil && childIndex==NSOutlineViewDropOnItemIndex){
		// Somehow, we will need to figure out how to handle these types of drops
		targetNodeIsValid = NO;
	}
	// Refuse if: this is a drop on, those are not meaningful to us
	if (targetNodeIsValid && isOnDropTypeProposal==YES){
		targetNodeIsValid = NO;
	}
	    
    // Set the item and child index in case we computed a retargeted one.
    [outlineView setDropItem:item dropChildIndex:childIndex];
    
    return targetNodeIsValid ? NSDragOperationGeneric : NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)ov acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)childIndex
{
	if(draggedNodes){
        SeaLayer *current = [[document contents] activeLayer];
		SeaLayer *layer = [draggedNodes objectAtIndex:0];
		[[document contents] moveLayer: layer toIndex:childIndex];
		[self update];
		draggedNodes = nil;
        [ov selectItems:[NSArray arrayWithObject:current] byExtendingSelection:NO];
		return YES;
	}else {
        [[document contents] layerFromPasteboard:[info draggingPasteboard] atIndex:childIndex];
		return YES;
	}
}

- (IBAction)useGroupGrowLook:(id)sender
{
    [outlineView setNeedsDisplay:YES];
}

- (void)update
{
    if(reloading)
        return;
    reloading=true;
	[outlineView reloadData];
    [outlineView selectRow:[[document contents] activeLayerIndex]];
    reloading=false;
}

@end
