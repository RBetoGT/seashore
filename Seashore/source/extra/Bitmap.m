#include "Bitmap.h"
#import "bitstring.h"

#import <Accelerate/Accelerate.h>

void convertRGBA2GrayA(unsigned char *dbitmap, unsigned char *ibitmap, int width, int height)
{
    int i, ispp=4;
    
    for (i = 0; i < width * height; i++) {
        dbitmap[i * 2] = ((int)ibitmap[i * ispp] + (int)ibitmap[i * ispp + 1] + (int)ibitmap[i * ispp + 2]) / 3;
        if (ispp == 4) dbitmap[i * 2 + 1] = ibitmap[i * 4 + 3];
    }
}

/*
 convert NSImageRep to a format Seashore can work with, which is RGBA, or GrayA. If spp is 4, then RGBA, if 2, the GrayA
 */
unsigned char *convertImageRep(NSImageRep *imageRep,int spp) {
    
    int width = (int)[imageRep pixelsWide];
    int height = (int)[imageRep pixelsHigh];
    
    unsigned char *buffer = calloc(width*height*4,sizeof(unsigned char));
    
    if(!buffer){
        return NULL;
    }
    
    NSBitmapImageRep *bitmapWhoseFormatIKnow = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&buffer pixelsWide:width pixelsHigh:height
                                                                                    bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO
                                                                                   colorSpaceName:MyRGBSpace bytesPerRow:width*4
                                                                                     bitsPerPixel:8*4];
    
    [bitmapWhoseFormatIKnow setSize:[imageRep size]];
    
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext *ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmapWhoseFormatIKnow];
    [NSGraphicsContext setCurrentContext:ctx];
    [imageRep draw];
    [NSGraphicsContext restoreGraphicsState];
    
    unpremultiplyBitmap(4,buffer,buffer,width*height);
    
    if(spp==2) {
        unsigned char *dbuffer = calloc(width*height*2,sizeof(unsigned char));
        CHECK_MALLOC(dbuffer);
        convertRGBA2GrayA(dbuffer,buffer,width,height);
        free(buffer);
        buffer=dbuffer;
    }
    
    return buffer;
}

unsigned char *stripAlpha(unsigned char *srcData,int width,int height,int spp) {
    int i,j;
    bool hasAlpha = false;
    unsigned char *destData;
    
    // Determine whether or not an alpha channel would be redundant
    for (i = 0; i < width * height && hasAlpha == NO; i++) {
        if (srcData[(i + 1) * spp - 1] != 255)
            hasAlpha = YES;
    }
    
    // Strip the alpha channel if necessary
    if (!hasAlpha) {
        spp--;
        destData = malloc(width * height * spp);
        for (i = 0; i < width * height; i++) {
            for (j = 0; j < spp; j++)
                destData[i * spp + j] = srcData[i * (spp + 1) + j];
        }
        return destData;
    }
    else
        return srcData;

}

inline void stripAlphaToWhite(int spp, unsigned char *output, unsigned char *input, int length)
{
	const int alphaPos = spp - 1;
	const int outputSPP = spp - 1;
	unsigned char alpha;
	double alphaRatio;
	int t1, t2, newValue;
	int i, k;
	
	memset(output, 255, length * outputSPP);
	
	for (i = 0; i < length; i++) {
		
		alpha = input[i * spp + alphaPos];
		
		if (alpha == 255) {
			for (k = 0; k < outputSPP; k++)
				output[i * outputSPP + k] = input[i * spp + k];
		}
		else {
			if (alpha != 0) {

				alphaRatio = 255.0 / alpha;
				for (k = 0; k < outputSPP; k++) {
					newValue = 0.5 + input[i * spp + k] * alphaRatio;
					newValue = MIN(newValue, 255);
					output[i * outputSPP + k] = int_mult(newValue, alpha, t1) + int_mult(255, (255 - alpha), t2);
				}
				
			}
		}
	
	} 
}

inline void premultiplyBitmap(int spp, unsigned char *output, unsigned char *input, int length)
{
//    vImage_Buffer inB;
//    vImage_Buffer outB;
//
//    inB.data = input;
//    inB.rowBytes = length*spp;
//    inB.width = length;
//    inB.height = 1;
//
//    outB.data = output;
//    outB.rowBytes = length*spp;
//    outB.width = length;
//    outB.height = 1;
    
//    vImagePremultiplyData_RGBA8888(&inB,&outB,0);

    int i, j, alphaPos, temp;

    for (i = 0; i < length; i++) {
        alphaPos = (i + 1) * spp - 1;
        if (input[alphaPos] == 255) {
            for (j = 0; j < spp; j++)
                output[i * spp + j] = input[i * spp + j];
        }
        else {
            if (input[alphaPos] != 0) {
                for (j = 0; j < spp - 1; j++)
                    output[i * spp + j] = int_mult(input[i * spp + j], input[alphaPos], temp);
                output[alphaPos] = input[alphaPos];
            }
            else {
                for (j = 0; j < spp; j++)
                    output[i * spp + j] = 0;
            }
        }
    }
}

inline void unpremultiplyBitmap(int spp, unsigned char *output, unsigned char *input, int length)
{
//    vImage_Buffer inB;
//    vImage_Buffer outB;
//
//    inB.data = input;
//    inB.rowBytes = length*spp;
//    inB.width = length;
//    inB.height = 1;
//
//    outB.data = output;
//    outB.rowBytes = length*spp;
//    outB.width = length;
//    outB.height = 1;
//
//    vImageUnpremultiplyData_RGBA8888(&inB,&outB,0);

    int i, j, alphaPos, newValue;
    double alphaRatio;

    for (i = 0; i < length; i++) {
        alphaPos = (i + 1) * spp - 1;
        if (input[alphaPos] == 255) {
            for (j = 0; j < spp; j++)
                output[i * spp + j] = input[i * spp + j];
        }
        else {
            if (input[alphaPos] != 0) {
                alphaRatio = 255.0 / input[alphaPos];
                for (j = 0; j < spp - 1; j++) {
                    newValue = 0.5 + input[i * spp + j] * alphaRatio;
                    newValue = MIN(newValue, 255);
                    output[i * spp + j] = newValue;
                }
                output[alphaPos] = input[alphaPos];
            }
            else {
                for (j = 0; j < spp; j++)
                    output[i * spp + j] = 0;
            }
        }
    }
}

inline unsigned char averagedComponentValue(int spp, unsigned char *data, int width, int height, int component, int radius, IntPoint where)
{
	int total, count;
	int i, j;
	
	if (radius == 0) {
		return data[(where.y * width + where.x) * spp + component];
	}

	total = 0;
	count = 0;
	for (j = where.y - radius; j <= where.y + radius; j++) {
		for (i = where.x - radius; i <= where.x + radius; i++) {
			if (i >= 0 && i < width && j >= 0 && j < height) {
				total += data[(j * width + i) * spp + component];
				count++;
			}
		}
	}
    if(count==0)
        return 0;
		
	return (total / count);
}

NSImage *getTinted(NSImage *src,NSColor *tint){
    NSImage *copy = [src copy];
    NSRect imageRect = NSMakeRect(0,0,[copy size].width,[copy size].height);
    [copy lockFocus];
    [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeSourceAtop];
    [tint set];
    [NSBezierPath fillRect:imageRect];
    [copy unlockFocus];
    return copy;
}


