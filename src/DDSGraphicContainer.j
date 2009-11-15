/* ***** BEGIN LICENCE BLOCK *****
 *
 * The Initial Developer of the Original Code is
 * The Northeastern University CCIS Volunteer Systems Group
 *
 * Contributor(s):
 *  Jeff Dlouhy <jdlouhy@ccs.neu.edu>
 *
 * ***** END LICENCE BLOCK ***** */

@import <AppKit/CPView.j>
@import <AppKit/CPShadowView.j>

@import "DDSGraphicView.j"

@implementation DDSGraphicContainer : CPView
{
  DDSGraphicView mGraphicView;
  CPShadowView mShadowView;
}

- (void)awakeFromCib
{
  var bgColor = [CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/container_bg.png" size:CGSizeMake(1.0, 760.0)]];
  [self setBackgroundColor:bgColor];
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame];

  if (self) {
    mGraphicView = [[DDSGraphicView alloc] initWithFrame:CGRectInset([self bounds], 20, 20)];
    [mGraphicView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];
    [mGraphicView setAutoresizesSubviews:YES];
    [self addSubview:mGraphicView];

    // Add shadow
    var mShadowView = [[CPShadowView alloc] initWithFrame:CGRectMakeZero()];
    [mShadowView setFrameForContentFrame:[mGraphicView frame]];
    [mShadowView setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
    [self addSubview:mShadowView];
    [self addSubview:mGraphicView];
  }

  return self;
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

  [mGraphicView setFrame:CGRectInset(newRect, 20, 20)];
  [mShadowView setFrame:CGRectInset(newRect, 16, 16)];
}
