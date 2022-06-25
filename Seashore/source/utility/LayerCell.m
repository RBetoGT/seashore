#import "LayerCell.h"

@implementation LayerCell

- (id)init
{
    if (self = [super init]) {
        [self setLineBreakMode:NSLineBreakByTruncatingTail];
        [self setSelectable:YES];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    LayerCell *cell = (LayerCell *)[super copyWithZone:zone];
    // The image ivar will be directly copied; we need to retain or copy it.
    cell->image = image;
    return cell;
}

- (void)setImage:(NSImage *)anImage
{
    image = anImage;
}

- (NSImage *)image
{
    return image;
}

- (NSRect)imageRectForBounds:(NSRect)cellFrame
{
    NSRect result;
    if (image != nil) {
        result.size = NSMakeSize(48,48);
        result.origin = cellFrame.origin;
        result.origin.x += 3;
        result.origin.y += ceil((cellFrame.size.height - result.size.height) / 2);
    } else {
        result = NSZeroRect;
    }
    return result;
}

// We could manually implement expansionFrameWithFrame:inView: and drawWithExpansionFrame:inView: or just properly implement titleRectForBounds to get expansion tooltips to automatically work for us
- (NSRect)titleRectForBounds:(NSRect)cellFrame
{
    NSRect result;
    if (image != nil) {
        float imageWidth = [image size].width;
        result = cellFrame;
        result.origin.x += (3 + imageWidth);
        result.size.width -= (3 + imageWidth);
    } else {
        result = NSZeroRect;
    }
    return result;
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent {
    NSRect textFrame, imageFrame;
    NSDivideRect (aRect, &imageFrame, &textFrame, 3 + [image size].width, NSMinXEdge);
    [super editWithFrame: textFrame inView: controlView editor:textObj delegate:anObject event: theEvent];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(int)selStart length:(int)selLength
{
    NSRect textFrame, imageFrame;
    NSDivideRect (aRect, &imageFrame, &textFrame, 3 + [image size].width, NSMinXEdge);
    [super selectWithFrame: textFrame inView: controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	if (image != nil) {
		[NSGraphicsContext saveGraphicsState];
        NSShadow *shadow = [[NSShadow alloc] init];
		[shadow setShadowOffset: NSMakeSize(1, 1)];
		[shadow setShadowBlurRadius:2];
		[shadow setShadowColor:[NSColor shadowColor]];
		[shadow set];
		
		NSRect imageFrame;
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, 8 + 48, NSMinXEdge);
        if ([self drawsBackground]) {
            [[self backgroundColor] set];
            NSRectFill(imageFrame);
        }
        imageFrame.origin.x += 3;
        imageFrame.size.width -= 6;
        imageFrame.size.height -= 6;
        imageFrame.origin.y += 3;

        NSSize imageSize = [image size];

        float image_proportion = imageSize.width / imageSize.height;

        if(image_proportion>1) {
            float new_height = imageFrame.size.width/image_proportion;
            imageFrame.origin.y += (imageFrame.size.height - new_height)/2;
            imageFrame.size.height = new_height;
        }
        else {
            float new_width = image_proportion*imageFrame.size.height;
            imageFrame.origin.x += (imageFrame.size.width - new_width)/2;
            imageFrame.size.width = new_width;
        }

        [[NSImage imageNamed:@"checkerboard"] drawInRect:imageFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction: 1.0];
        
        [NSGraphicsContext restoreGraphicsState];
        
        [image drawInRect:imageFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction: 1.0 respectFlipped:TRUE hints:NULL];
        
		cellFrame.size.height = 18;
		cellFrame.origin.y += 10;
		NSDictionary *attrs;
		if(selected){
			attrs = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:12] , NSFontAttributeName, [NSColor selectedControlTextColor], NSForegroundColorAttributeName, nil];
			[[self stringValue] drawInRect:cellFrame withAttributes:attrs];
		}else{
			attrs = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:12] , NSFontAttributeName, [NSColor controlTextColor], NSForegroundColorAttributeName, nil];
			[[self stringValue] drawInRect:cellFrame withAttributes:attrs];
		}
		
	}else{
		[super drawWithFrame:cellFrame inView:controlView];
	}
}

- (NSSize)cellSize
{
    NSSize cellSize = [super cellSize];
    cellSize.width += (48+8);
    return cellSize;
}

- (void) setSelected:(BOOL)isSelected
{
	selected = isSelected;
}

@end
