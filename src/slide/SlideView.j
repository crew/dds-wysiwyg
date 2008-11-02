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

    [self registerForDraggedTypes:[kPhotoDragType]];
  }

  return self;
}

- (void)performDragOperation:(CPDraggingInfo)aSender
{
  var data = [[aSender draggingPasteboard] dataForType:kPhotoDragType];
  [self addSubview:[CPKeyedUnarchiver unarchiveObjectWithData:data]];
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
  CALayer     mRootLayer;
  VinylLayer  mViynlLayer;

  CGPoint mMouseDownPoint;
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame]

  if (self) {
    mRootLayer = [CALayer layer];

    [self setWantsLayer:YES];
    [self setLayer:mRootLayer];
    [mRootLayer setBackgroundColor:[CPColor whiteColor]];

    mViynlLayer = [[VinylLayer alloc] initWithSlideView:self];
    [mViynlLayer setBounds:aFrame];
    [mViynlLayer setAnchorPoint:CGPointMakeZero()];
    [mViynlLayer setPosition:CGPointMake(40.0, 40.0)];

    [mRootLayer addSublayer:mViynlLayer];
    [mViynlLayer setNeedsDisplay];
  }

  return self;
}


- (void)mouseDown:(CPEvent)event
{
  mMouseDownPoint = [self convertPoint:[event locationInWindow]
                              fromView:nil];
}

@end

@implementation VinylLayer : CALayer
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
