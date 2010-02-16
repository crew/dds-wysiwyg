/* ***** BEGIN LICENCE BLOCK *****
 *
 * The Initial Developer of the Original Code is
 * The Northeastern University CCIS Volunteer Systems Group
 *
 * Contributor(s):
 *  Jeff Dlouhy <jdlouhy@ccs.neu.edu>
 *
 * ***** END LICENCE BLOCK ***** */

@import "DDSGraphic.j"
@import <AppKit/CPImage.j>

@implementation DDSImage : DDSGraphic
{
  CPImage mImage;
}

- (id)initWithImage:(CPImage)aImage {
  self = [super init];
  if (self) {
    mImage = aImage;
  }
  return self;
}

- (void)drawContentsInView:(CPView)view isBeingCreateOrEdited:(BOOL)isBeingCreatedOrEditing
{
  if([mImage loadStatus] == CPImageLoadStatusCompleted) {

    var context = [[CPGraphicsContext currentContext] graphicsPort];
    var rect = [self bounds];

    if (mImage) {
      CGContextDrawImage(context, rect, mImage);
    }
  }
}

- (id)serializeToJSON
{
  // Create the object
  var imageJSONObject = {
    "id" : [CPString UUID],
    "type" : [self clutterType],
    "filename" : [mImage filename],
    "x" : [self xPosition],
    "y" :  [self yPosition],
    "width" : [self width],
    "height" : [self height],
    "opacity": 255,
    "visible" : true
  };

  return imageJSONObject;
}

- (CPString)clutterType
{
  return "ClutterTexture";
}

@end
