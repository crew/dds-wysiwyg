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

@implementation DDSRectangle : DDSGraphic

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (CGPath)bezierPathForDrawing
{
	var path = CGPathCreateMutable();
	var rect = [self bounds];

	CGPathAddRect(path, nil, rect);
	CGPathCloseSubpath(path);

  return path;
}

- (id)serializeToJSON
{
  // Create the object
  var rectangleJSONObject = {
    "id" : [CPString UUID],
    "type" : [self clutterType],
    "x" : [self xPosition],
    "y" :  [self yPosition],
    "width" : [self width],
    "height" : [self height],
    "color" : "#"+[[self fillColor] hexString],
    "opacity": 255,
    "visible" : true
  };

  return rectangleJSONObject;
}

- (CPString)clutterType
{
  return "ClutterRectangle";
}

@end
