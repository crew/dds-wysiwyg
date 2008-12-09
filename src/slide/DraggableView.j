/* ***** BEGIN LICENCE BLOCK *****
 *
 * The Initial Developer of the Original Code is
 * The Northeastern University CCIS Volunteer Systems Group
 *
 * Parts of this code are from Francisco Tolmasky's
 * FloorPlanView demo.
 *
 * Contributor(s):
 *  Jeff Dlouhy <jdlouhy@ccs.neu.edu>
 *
 * ***** END LICENCE BLOCK ***** */

@import <AppKit/CPView.j>

kDraggableViewDragType = "DraggableViewDragType";
kHandleWidth = 10;

kDraggableUpperLeftHandle = 1;
kDraggableUpperMiddleHandle = 2;
kDraggableUpperRightHandle = 3;
kDraggableMiddleLeftHandle = 4;
kDraggableMiddleRightHandle = 5;
kDraggableLowerLeftHandle = 6;
kDraggableLowerMiddleHandle = 7;
kDraggableLowerRightHandle = 8;

@implementation DraggableView : CPView
{
  CPView      mManagedView;

  float       mRotationRadians;
  float       mEditedRotationRadians;

  CGPoint     mDragLocation;
  CGPoint     mEditedOrigin;
}

- (id)initWithManagedView:(CPView)aView
{
  self = [super initWithFrame:[aView frame]];

  if (self) {
    [self setManagedView:aView];
    [self setPostsFrameChangedNotifications:YES];
  }

  return self;
}

-(void)setManagedView:(CPView)aViewToManage
{
  if (aViewToManage != mManagedView) {
    [mManagedView removeFromSuperview];

    mManagedView = aViewToManage;
    [self addSubview:mManagedView];
  }
}

-(CPView)managedView
{
  return mManagedView;
}

- (void)willBeginLiveRotation
{
  mEditedRotationRadians = mRotationRadians;
}

- (void)didEndLiveRotation
{
  [self setEditedRotationRadians:mRotationRadians];
}

- (void)setRotationRadians:(float)radians
{
  mRotationRadians = radians;

  var editorView = [TransformView sharedTransformView];

  if ([editorView draggableView] == self && [editorView rotationRadians] != radians)
    [editorView updateFromDraggableView];

  [self setNeedsDisplay:YES];
}

- (void)setEditedRotationRadians:(float)radians
{
  if (mEditedRotationRadians == radians)
    return;

  [[[self window] undoManager] registerUndoWithTarget:self
                                             selector:@selector(setEditedRotationRadians:)
                                               object:mEditedRotationRadians];

  [self setRotationRadians:radians];
  mEditedRotationRadians = radians;
}

- (float)rotationRadians
{
  return mRotationRadians;
}

- (void)mouseDown:(CPEvent)anEvent
{
  mEditedOrigin = [self frame].origin;
  mDragLocation = [anEvent locationInWindow];

  var curTransformView = [[TransformView sharedTransformView] draggableView];
  // If we are selected and click again, unselect ourselves
  if (self == curTransformView) {
    [[TransformView sharedTransformView] setDraggableView:nil];
  } else {
    [[TransformView sharedTransformView] setDraggableView:self];
  }
}

- (void)mouseDragged:(CPEvent)anEvent
{
  var location = [anEvent locationInWindow],
      origin = [self frame].origin;

  [self setFrameOrigin:CGPointMake(origin.x + location.x - mDragLocation.x, origin.y + location.y - mDragLocation.y)];
  mDragLocation = location;
}

- (void)mouseUp:(CPEvent)anEvent
{
  [self setEditedOrigin:[self frame].origin];
}

- (void)setEditedOrigin:(CGPoint)aPoint
{
  if (CGPointEqualToPoint(mEditedOrigin, aPoint))
    return;

  [[[self window] undoManager] registerUndoWithTarget:self selector:@selector(setEditedOrigin:) object:mEditedOrigin];

  mEditedOrigin = aPoint;

  [self setFrameOrigin:aPoint];
}

- (void)drawHandlesInView:(CPView)view
{
  var bounds = [self bounds];
  [self drawHandleInView:view atPoint:CGPointMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds))];
  [self drawHandleInView:view atPoint:CGPointMake(CGRectGetMidX(bounds), CGRectGetMinY(bounds))];
  [self drawHandleInView:view atPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMinY(bounds))];
  [self drawHandleInView:view atPoint:CGPointMake(CGRectGetMinX(bounds), CGRectGetMidY(bounds))];
  [self drawHandleInView:view atPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMidY(bounds))];
  [self drawHandleInView:view atPoint:CGPointMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds))];
  [self drawHandleInView:view atPoint:CGPointMake(CGRectGetMidX(bounds), CGRectGetMaxY(bounds))];
  [self drawHandleInView:view atPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))];
}

- (void)drawHandleInView:(CPView)view atPoint:(CPPoint)point {

  var originX = point.x;
  var originY = point.y;
  var width = kHandleWidth;
  var height = kHandleWidth;
  var rectBounds = CGRectMake(originX, originY, width, height);
  var handleBounds = rectBounds

  var context = [[CPGraphicsContext currentContext] graphicsPort];

  CGContextSetStrokeColor(context, [CPColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0]);
  CGContextSetLineWidth(context, 2.0);
  CGContextSetAlpha(context, 1.0);

  CGContextStrokeEllipseInRect(context, handleBounds);
 }

// This is just for details... hit test as if we were rotated.  We'd get this for free if we used CALayer instead of CPView.
- (id)hitTest:(CGPoint)aPoint
{
  var radius = CGRectGetWidth([self bounds]) / 2.0,
    managedViewSize = [mManagedView frame].size,
    viewWidth_2 = managedViewSize.width / 2,
    viewHeight_2 = managedViewSize.height / 2;

  point = CGPointMakeCopy(aPoint);

  point.x -= CGRectGetMinX([self frame]) + radius - viewWidth_2;
  point.y -= CGRectGetMinY([self frame]) +  radius - viewHeight_2;

  point = CGPointApplyAffineTransform(point, CGAffineTransformInvert(CGAffineTransformConcat(CGAffineTransformMakeTranslation(-viewWidth_2, -viewHeight_2), CGAffineTransformConcat(CGAffineTransformMakeRotation(mRotationRadians), CGAffineTransformMakeTranslation(viewWidth_2, viewHeight_2)))));

  if (CGRectContainsPoint(CGRectMake(0.0, 0.0, managedViewSize.width, managedViewSize.height), point))
    return self;

  return nil;
}

- (int)handleUnderPoint:(CPPoint)point {

    // Check handles at the corners and on the sides.
    var handle = kDraggableNoHandle;
    var bounds = [self bounds];
    if ([self isHandleAtPoint:CGPointMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds)) underPoint:point]) {
	handle = kDraggableUpperLeftHandle;
    } else if ([self isHandleAtPoint:CGPointMake(CGRectGetMidX(bounds), CGRectGetMinY(bounds)) underPoint:point]) {
	handle = kDraggableUpperMiddleHandle;
    } else if ([self isHandleAtPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMinY(bounds)) underPoint:point]) {
	handle = kDraggableUpperRightHandle;
    } else if ([self isHandleAtPoint:CGPointMake(CGRectGetMinX(bounds), CGRectGetMidY(bounds)) underPoint:point]) {
	handle = kDraggableMiddleLeftHandle;
    } else if ([self isHandleAtPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMidY(bounds)) underPoint:point]) {
	handle = kDraggableMiddleRightHandle;
    } else if ([self isHandleAtPoint:CGPointMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds)) underPoint:point]) {
	handle = kDraggableLowerLeftHandle;
    } else if ([self isHandleAtPoint:CGPointMake(CGRectGetMidX(bounds), CGRectGetMaxY(bounds)) underPoint:point]) {
	handle = kDraggableLowerMiddleHandle;
    } else if ([self isHandleAtPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds)) underPoint:point]) {
	handle = kDraggableLowerRightHandle;
    }
    return handle;

}

- (BOOL)isHandleAtPoint:(NSPoint)handlePoint underPoint:(NSPoint)point {
    // Check a handle-sized rectangle that's centered on the handle point.
  var originX = point.x;
  var originY = point.y;
  var width = kHandleWidth;
  var height = kHandleWidth;
  var rectBounds = CGRectMake(originX, originY, width, height);
  return CPRectContainsPoint(point, rectBounds);
}

- (id)initWithCoder:(CPCoder)aCoder
{
  self = [super initWithCoder:aCoder];

  if (self) {
    mManagedView = [aCoder decodeObjectForKey:"view"];
    [self setPostsFrameChangedNotifications:YES];
  }

  return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:mManagedView forKey:"view"];
}

@end
