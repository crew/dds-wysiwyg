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
