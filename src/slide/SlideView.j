/* ***** BEGIN LICENCE BLOCK *****
 *
 * The Initial Developer of the Original Code is
 * The Northeastern University CCIS Volunteer Systems Group
 *
 * Contributor(s):
 *  Jeff Dlouhy <jdlouhy@ccs.neu.edu>
 *
 * ***** END LICENCE BLOCK ***** */

import <AppKit/CALayer.j>
import <AppKit/CPShadowView.j>

import "../editor/PhotoPanel.j"
@import "DraggableView.j"

const kDefaultShadowWeight = 2.0;

@implementation CanvasView : CPShadowView
{
  SlideView mSlideView;
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame]

  if (self) {
    [self setBackgroundColor:[CPColor colorWithCalibratedWhite:0.25 alpha:1.0]];

    mSlideView = [[SlideView alloc] initWithFrame:CGRectInset([self bounds], 20, 20)];
    [mSlideView setFrameForContentFrame:[CPShadowView frameForContentFrame:[mSlideView frame]
                                                                withWeight:CPHeavyShadow]];

    [mSlideView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable]
    [mSlideView setWeight:CPHeavyShadow];
    [self addSubview:mSlideView];
  }

  return self;
}

-(void)mouseDown:(CPEvent)anEvent
{
  CPLog("CANVAS VIEW");
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

  [mSlideView setFrame:CGRectInset(newRect, 20, 20)];
}

- (SlideView)slideView
{
  return mSlideView;
}

@end

@implementation SlideView : CPShadowView
{
  SlideChildView  mChildView;

  CGPoint mMouseDownPoint;
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame]

  if (self) {
    mChildView = [[SlideChildView alloc] initWithSlideView:self];
    [mChildView setBounds:aFrame];
//     [mChildView setAnchorPoint:CGPointMakeZero()];
//     [mChildView setPosition:CGPointMake(5.0, 5.0)];
    [mChildView  setBackgroundColor:[CPColor whiteColor]];

//    [self addSubview:mChildView];

    [self registerForDraggedTypes:[kPhotoDragType]];

    [[CPNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(colorPanelDidChangeColor:)
               name:CPColorPanelColorDidChangeNotification
             object:[CPColorPanel sharedColorPanel]];

    var dragView = [[DraggableItemView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    [self addSubview:dragView];
  }

  return self;
}

- (void)performDragOperation:(CPDraggingInfo)aSender
{
  var data = [[aSender draggingPasteboard] dataForType:kPhotoDragType];
  var dragImage = [CPKeyedUnarchiver unarchiveObjectWithData:data];

  var imageSize = [dragImage size];
  var imageFrame = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
  var imageView = [[CPImageView alloc] initWithFrame:imageFrame];

  [imageView setImage:dragImage];
  [self addSubview:imageView];
}

- (void)colorPanelDidChangeColor:(CPNotification)aNotification
{
  var newColor = [[aNotification object] color];
  [self setBackgroundColor:newColor];
}

-(void)mouseDown:(CPEvent)anEvent
{
  CPLog("SLIDE VIEW");
}

- (BOOL)acceptsFirstResponder
{
  return YES;
}

- (void)deactivate
{
  [[CPNotificationCenter defaultCenter]
        removeObserver:self
                  name:CPColorPanelColorDidChangeNotification
                object:[CPColorPanel sharedColorPanel]];
}

// - (void)mouseDown:(CPEvent)event
// {
//   CPLog("SOMEWHERE");
//   mMouseDownPoint = [self convertPoint:[event locationInWindow]
//                               fromView:nil];
// }


@end

@implementation SlideChildView : CPView
{
  SlideView  mSlideView;
}

- (id)initWithSlideView:(SlideView)aSlideView
{
  self = [super init];

  if (self) {
    mSlideView = aSlideView;
  }

  return self;
}

@end
