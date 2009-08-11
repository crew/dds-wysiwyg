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

DDSLineBeginHandle = 1;
DDSLineEndHandle = 2;

@implementation DDSLine : DDSGraphic
{
  BOOL _pointsRight;
  BOOL _pointsDown;
}

- (CPPoint)beginPoint {
  // Convert from our odd storage format to something natural.
  var bounds = [self bounds];
  var x = _pointsRight ? CGRectGetMinX(bounds) : CGRectGetMaxX(bounds);
  var y = _pointsDown ? CGRectGetMinY(bounds) : CGRectGetMaxY(bounds);
  return CPPointMake(x, y);
}

- (CPPoint)endPoint {
  // Convert from our odd storage format to something natural.
  var bounds = [self bounds];
  var x = _pointsRight ? CGRectGetMaxX(bounds) : CGRectGetMinX(bounds);
  var y = _pointsDown ? CGRectGetMaxY(bounds) : CGRectGetMinY(bounds);
  return CPPointMake(x, y);
}

+ (CPArray)boundsWithBeginPoint:(CPPoint)beginPoint endPoint:(CPPoint)endPoint
{
  // Convert the begin and end points of the line to its bounds and flags specifying the direction in which it points.
  var pointsRight = beginPoint.x < endPoint.x;
  var pointsDown = beginPoint.y < endPoint.y;
  var xPosition = pointsRight ? beginPoint.x : endPoint.x;
  var yPosition = pointsDown ? beginPoint.y : endPoint.y;
  var width = Math.abs(endPoint.x - beginPoint.x);
  var height = Math.abs(endPoint.y - beginPoint.y);

  return [CPArray arrayWithObjects:CPRectMake(xPosition, yPosition, width, height), pointsRight, pointsDown, nil];
}

- (void)setBeginPoint:(CPPoint)beginPoint
{
  // It's easiest to compute the results of setting these points together.
	var array = [[self class] boundsWithBeginPoint:beginPoint endPoint:[self endPoint]];

  [self setBounds:[array objectAtIndex:0]];
	_pointsRight = [array objectAtIndex:1];
	_pointsDown = [array objectAtIndex:2];
}


- (void)setEndPoint:(NSPoint)endPoint {

  // It's easiest to compute the results of setting these points together.
  var array = [[self class] boundsWithBeginPoint:[self beginPoint] endPoint:endPoint];

  [self setBounds:[array objectAtIndex:0]];
	_pointsRight = [array objectAtIndex:1];
	_pointsDown = [array objectAtIndex:2];
}


- (BOOL)isDrawingFill {
  // You can't fill a line.
  return NO;
}


- (BOOL)isDrawingStroke {
  // You can't not stroke a line.
  return YES;
}


- (CGPath)bezierPathForDrawing
{
	var path = CGPathCreateMutable();
	var beginPoint = [self beginPoint];
	var endPoint = [self endPoint];

	CGPathMoveToPoint(path, nil, beginPoint.x, beginPoint.y);
	CGPathAddLineToPoint(path, nil, endPoint.x, endPoint.y);
	CGPathCloseSubpath(path);

  return path;
}

- (void)drawHandlesInView:(CPView)view
{
  // A line only has two handles.
  [self drawHandleInView:view atPoint:[self beginPoint]];
  [self drawHandleInView:view atPoint:[self endPoint]];
}

+ (int)creationSizingHandle
{
  // When the user creates a line and is dragging around a handle to size it they're dragging the end of the line.
  return DDSLineEndHandle;
}

- (BOOL)isContentsUnderPoint:(CPPoint)point
{
//	debugger;

  // Do a gross check against the bounds.
  var isContentsUnderPoint = NO;

  if (CGRectContainsPoint([self bounds], point))
{
  // Let the user click within the stroke width plus some slop.
  var acceptableDistance = ([self strokeWidth] / 2.0) + 2.0;

  // Before doing anything avoid a divide by zero error.
  var beginPoint = [self beginPoint];
  var endPoint = [self endPoint];
  var xDelta = endPoint.x - beginPoint.x;
  if (xDelta == 0.0 && Math.abs(point.x - beginPoint.x) <= acceptableDistance)
{
  isContentsUnderPoint = YES;
}
  else
{
  // Do a weak approximation of distance to the line segment.
  var slope = (endPoint.y - beginPoint.y) / xDelta;
  if (Math.abs(((point.x - beginPoint.x) * slope) - (point.y - beginPoint.y)) <= acceptableDistance)
{
  isContentsUnderPoint = YES;
}
}
}

  return isContentsUnderPoint;
}


- (int)handleUnderPoint:(CPPoint)point
{
  // A line just has handles at its ends.
  var handle = DDSGraphicNoHandle;

  if ([self isHandleAtPoint:[self beginPoint] underPoint:point]) {
		handle = DDSLineBeginHandle;
  }
	else if ([self isHandleAtPoint:[self endPoint] underPoint:point]) {
		handle = DDSLineEndHandle;
  }

  return handle;
}


- (int)resizeByMovingHandle:(int)handle toPoint:(CPPoint)point
{
	// debugger;

  // A line just has handles at its ends.
  if (handle == DDSLineBeginHandle) {
		[self setBeginPoint:point];
  }
	else if (handle == DDSLineEndHandle) {
		[self setEndPoint:point];
  } // else a cataclysm occurred.

    // We don't have to do the kind of handle flipping that DDSGraphic does.
  return handle;
}

- (void)setColor:(CPColor)color
{
  // Because lines aren't filled we'll consider the stroke's color to be the one.
  [self setStrokeColor:color];
}


@end
