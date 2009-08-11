/* ***** BEGIN LICENCE BLOCK *****
 *
 * The Initial Developer of the Original Code is
 * The Northeastern University CCIS Volunteer Systems Group
 *
 * Contributor(s):
 *  Jeff Dlouhy <jdlouhy@ccs.neu.edu>
 *
 * ***** END LICENCE BLOCK ***** */

@import <AppKit/CPWindowController.j>

@import "DDSGraphicView.j"

@implementation DDSWindowController : CPWindowController
{
	DDSGraphicView mGraphicView;
}

- (id)init
{
	var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMake(100.0, 100.0, 400.0, 300.0)
                                              styleMask:CPTitledWindowMask | CPResizableWindowMask | CPClosableWindowMask];
	var contentView = [theWindow contentView];
  var bounds = [contentView bounds];

	mGraphicView = [[DDSGraphicView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(bounds) - 20, CGRectGetHeight(bounds) -20)];
  [mGraphicView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

  [contentView addSubview:mGraphicView];

	[theWindow makeFirstResponder:mGraphicView];


  self = [super initWithWindow:theWindow];
  if (self) {
  }

  return self;
}

-(DDSGraphicView)graphicView
{
	return mGraphicView;
}

-(void)setGraphicView:(DDSGraphicView)graphicView
{
	mGraphicView = graphicView;
}

- (CPArray)graphics
{
  var graphics = [[self document] graphics];
  if (!graphics) {
		graphics = [CPArray array];
  }
  return graphics;
}

- (CPIndexSet)selectionIndexes
{
  return [[self document] selectionIndexes];
}

- (void)setSelectionIndexes:(CPIndexSet)selectionIndexes
{
	[[self document] setSelectionIndexes:selectionIndexes];
}

@end
