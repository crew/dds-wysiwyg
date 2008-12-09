/* ***** BEGIN LICENCE BLOCK *****
 *
 * The Initial Developer of the Original Code is
 * The Northeastern University CCIS Volunteer Systems Group
 *
 * Contributor(s):
 *  Jeff Dlouhy <jdlouhy@ccs.neu.edu>
 *
 * ***** END LICENCE BLOCK ***** */

@import <AppKit/CALayer.j>
@import <AppKit/CPShadowView.j>

@import "../editor/PhotoPanel.j"
@import "DraggableImage.j"

const kDefaultShadowWeight = 2.0;

@implementation CanvasView : CPView
{
  SlideView mSlideView;
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame]

  if (self) {
    [self setBackgroundColor:[CPColor colorWithCalibratedWhite:0.25 alpha:1.0]];

    mSlideView = [[SlideView alloc] initWithFrame:CGRectInset([self bounds], 20, 20)];
//     [mSlideView setFrameForContentFrame:[CPShadowView frameForContentFrame:[mSlideView frame]
//                                                                 withWeight:CPHeavyShadow]];

    [mSlideView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable]
//    [mSlideView setWeight:CPHeavyShadow];
    [self addSubview:mSlideView];
  }

  return self;
}

-(SlideView)slideView
{
  return mSlideView;
}

- (void)drawRect:(CGRect)aRect
{
  var myFrame = [self frame];
  var containerWidth = myFrame.size.width;
  var containerHeight = myFrame.size.height;
  var slideHeight = (containerWidth / 16) * 9;
  var slideWidth = (containerHeight / 9) * 16;

  if (containerHeight < slideHeight) {
    var xOrg = (containerWidth / 2) - (slideWidth / 2);
    var newRect = CGRectMake(xOrg, 0, slideWidth, containerHeight);
  } else {
    var yOrg = (containerHeight / 2) - (slideHeight / 2);
    var newRect = CGRectMake(0, yOrg, containerWidth, slideHeight);
  }

  var bounds = CGRectInset([self bounds], 5.0, 5.0),
    context = [[CPGraphicsContext currentContext] graphicsPort],
    radius = CGRectGetWidth(bounds) / 2.0;

  // Draw the rectangle
//  CGContextSetStrokeColor(context, [CPColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0]);
//  CGContextSetLineWidth(context, 2.0);
//  CGContextStrokeRect(context, bounds);

//   var colors = [[CPColor blackColor], [CPColor whiteColor]];
//   var points = [CGPointMake(0.0, CGRectGetMaxY(bounds)), CGPointMakeZero()];
//   var greyGradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), colors, points);
//   CGContextDrawLinearGradient(context, greyGradient, CGPointMake(CGRectGetMidX(bounds), CGRectGetMaxY(bounds)), CGPointMakeZero(), nil);
  [mSlideView setFrame:CGRectInset(newRect, 20, 20)];
}

- (SlideView)slideView
{
  return mSlideView;
}

@end

@implementation SlideView : CPView
{
  SlideChildView  mChildView;

  CGPoint mMouseDownPoint;
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame]

  if (self) {
    [self registerForDraggedTypes:[kPhotoDragType]];

    [[CPNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(colorPanelDidChangeColor:)
               name:CPColorPanelColorDidChangeNotification
             object:[CPColorPanel sharedColorPanel]];

  }

  return self;
}

// - (void)performDragOperation:(CPDraggingInfo)aSender
// {
//   var data = [[aSender draggingPasteboard] dataForType:kPhotoDragType];
//   var dragImage = [CPKeyedUnarchiver unarchiveObjectWithData:data];

//   var imageSize = [dragImage size];
//   var imageFrame = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
//   var imageView = [[CPImageView alloc] initWithFrame:imageFrame];

//   [imageView setImage:dragImage];
//   [self addSubview:imageView];
// }

- (void)addDraggableView:(DraggableView)aDraggableView
{
  [[[self window] undoManager] registerUndoWithTarget:self selector:@selector(removeDraggableView:) object:aDraggableView];
  [self addSubview:aDraggableView];
}

- (void)removeDraggableView:(DraggableView)aDraggableView
{
  [[[self window] undoManager] registerUndoWithTarget:self selector:@selector(addDraggableView:) object:aDraggableView];
  [self addSubview:aDraggableView];

  [aDraggableView removeFromSuperview];
}

// Received a draggable "drop"...
- (void)performDragOperation:(CPDraggingInfo)aSender
{
  var draggableView = [CPKeyedUnarchiver unarchiveObjectWithData:[[aSender draggingPasteboard] dataForType:kPhotoDragType]],
      location = [self convertPoint:[aSender draggingLocation] fromView:nil];

  [draggableView setFrameOrigin:CGPointMake(location.x - CGRectGetWidth([draggableView frame]) / 2.0, location.y - CGRectGetHeight([draggableView frame]) / 2.0)];

  [self addDraggableView:draggableView];
}

- (void)colorPanelDidChangeColor:(CPNotification)aNotification
{
  var newColor = [[aNotification object] color];
  [self setBackgroundColor:newColor];
}

- (void)deactivate
{
  [[CPNotificationCenter defaultCenter]
        removeObserver:self
                  name:CPColorPanelColorDidChangeNotification
                object:[CPColorPanel sharedColorPanel]];
}

@end
