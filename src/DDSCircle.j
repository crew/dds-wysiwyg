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

@implementation DDSCircle : DDSGraphic

- (CGPath)bezierPathForDrawing {

	var path = CGPathCreateMutable();
	var rect = [self bounds];

	CGPathAddArc(path, nil, CGRectGetMidX(rect), CGRectGetMidY(rect), CGRectGetWidth(rect) / 2.0, 0.0, 2.0 * Math.PI, YES);
	CGPathCloseSubpath(path);

  return path;
}

// Better thing to implement witc cappuccino
/*
  - (BOOL)isContentsUnderPoint:(CPPoint)point {
  // Just check to see if the point is in the path.
  return [[self bezierPathForDrawing] containsPoint:point];
  }
*/

@end
