#import "SeaDocument.h"
#import "SeaContent.h"
#import "XBMLayer.h"
#import "XBMContent.h"
#import "bitstring.h"

@implementation XBMLayer

- (id)initWithFile:(FILE *)file offset:(int)offset document:(id)doc sharedInfo:(SharedXBMInfo *)info
{
	unsigned char value;
	char string[9], temp;
	int i, pos = 0;

	// Initialize superclass first
	if (![super initWithDocument:doc])
		return NULL;
	
	// Set the samples per pixel correctly
	int width = info->width; height = info->height;

    if(!width || !height)
        return NULL;

	unsigned char *data = malloc(make_128(width * height * 2));
	memset(data, 0xFF, width * height * 2);

	do {
		// Throw away everything till we get to the good stuff
		do {
			temp = fgetc(file);
		} while ((temp < '0' || temp > '9') && !(ferror(file) || feof(file)));
		
		// Fail if something went wrong
		if (ferror(file) || feof(file)) {
			return NULL;
		}
		
		// Extract the string containing the value
		string[0] = temp;
		i = 0;
		do {
			i++;
			string[i] = fgetc(file);
        } while ((i < 8) && ((string[i] >= '0' && string[i] <= '9') || (string[i] >= 'a' && string[i] <= 'f') || (string[i] >= 'A' && string[i] <= 'F') || string[i] == 'x') && !(ferror(file) || feof(file)));
		
		// Fail if something went wrong
		if (ferror(file) || feof(file)) {
			return NULL;
		}
		
		// Convert the string to a value
		string[i] = 0x00;
		value = strtol(string, NULL, 0);
		
		// Now figure out the bitmap
		i = 0;
		do {
			if (bit_test(&value, i))
				data[pos * 2] = 0x00;
			pos++;
			i++;
		} while (pos < width * height && i < 8 && !(pos % width == 0));
	
	} while (pos < width * height);

    // TODO FIX ME!

    nsdata = [NSData dataWithBytesNoCopy:data length:width*height*2];

	return self;
}

@end
