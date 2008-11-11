/* ***** BEGIN LICENCE BLOCK *****
 *
 * The Initial Developer of the Original Code is
 * The Northeastern University CCIS Volunteer Systems Group
 *
 * Contributor(s):
 *  Jeff Dlouhy <jdlouhy@ccs.neu.edu>
 *
 * ***** END LICENCE BLOCK ***** */

import <AppKit/CPView.j>
import <AppKit/CPShadowView.j>
import <AppKit/CPCollectionView.j>
import <AppKit/CPGraphicsContext.j>

import <AppKit/CGGradient.j>
import <AppKit/CGColorSpace.j>

import "../slide/SlideView.j"

@implementation EditorView : CPView
{
  CPCollectionView mCanvasPreviewCollection;
  CPView mCanvasContainerView;
  CanvasView mCurrentCanvasView;

  CPArray mSideSlides;
}

-(void)viewDidMoveToWindow
{
  // Left List
  [self setupCanvasListView];
  // Border
  [self setupBorder];
  // Main Content
  [self setupCanvas];
}

- (void)setupCanvasListView
{
  var bounds = [self bounds];
  var listScrollView = [[CPScrollView alloc] initWithFrame: CGRectMake(0, 0, 199, CGRectGetHeight(bounds))];
  [listScrollView setAutohidesScrollers: YES];

  var previewsListItem = [[CPCollectionViewItem alloc] init];
  [previewsListItem setView: [[PreviewListCell alloc] initWithFrame:CGRectMakeZero()]];

  mCanvasPreviewCollection = [[CPCollectionView alloc] initWithFrame: CGRectMake(0, 0, 199, CGRectGetHeight(bounds))];

  [mCanvasPreviewCollection setDelegate: self];
  [mCanvasPreviewCollection setItemPrototype:previewsListItem];

  [mCanvasPreviewCollection setMinItemSize:CGSizeMake(20.0, 90.0)];
  [mCanvasPreviewCollection setMaxItemSize:CGSizeMake(1000.0, 55.0)];
  [mCanvasPreviewCollection setMaxNumberOfColumns:1];

  [mCanvasPreviewCollection setVerticalMargin:0.0];
  [mCanvasPreviewCollection setAutoresizingMask: CPViewWidthSizable];

  [listScrollView setDocumentView: mCanvasPreviewCollection];
  [[listScrollView contentView] setBackgroundColor: [CPColor colorWithCalibratedRed:213.0/255.0 green:221.0/255.0 blue:230.0/255.0 alpha:1.0]];

  [self addSubview: listScrollView];

  mSideSlides = [CPArray array];
}


-(BOOL)acceptsFirstResponder
{
  return NO;
}

- (void)mouseUp:(CPEvent)event
{

}

- (void)setupBorder
{
  var bounds = [self bounds];
  var borderView = [[CPView alloc] initWithFrame:CGRectMake(199, 0, 1, CGRectGetHeight(bounds))];

  [borderView setBackgroundColor: [CPColor blackColor]];
  [borderView setAutoresizingMask: CPViewHeightSizable];

  [self addSubview: borderView];
}

- (void)setupCanvas
{
  var bounds = [self  bounds];
  mCanvasContainerView = [[CPView alloc] initWithFrame:CGRectMake(200, 0, CGRectGetWidth(bounds) - 200, CGRectGetHeight(bounds))];

  [mCanvasContainerView setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];
  [mCanvasContainerView setBackgroundColor:[CPColor colorWithCalibratedWhite:0.25 alpha:1.0]];

  [self addSubview:mCanvasContainerView];

  mCurrentCanvasView = [[CanvasView alloc] initWithFrame:CGRectMakeZero()];
  [mCanvasContainerView addSubview:mCurrentCanvasView];
}

- (void)setCurrentCanvas:(CanvasView)newCanvas
{
  if (newCanvas != mCurrentCanvasView) {
    var subviews = [mCanvasContainerView subviews];

    for (i = 0; i < [subviews count]; i++){
      [[subviews objectAtIndex:i] removeFromSuperview];
    }

    mCurrentCanvasView = newCanvas;
    [mCanvasContainerView addSubview:mCurrentCanvasView];
  }
}

// Actions

- (void)add:(id)sender
{
  var newCanvas = [[CanvasView alloc] initWithFrame:[mCanvasContainerView bounds]];
  [newCanvas setAutoresizingMask: CPViewHeightSizable | CPViewWidthSizable];
  [self addCanvasView:newCanvas];
}

- (void)addCanvasView:(CanvasView)aCanvas
{
  [mSideSlides addObject:aCanvas];
  [mCanvasPreviewCollection setContent:[mSideSlides copy]];
  [mCanvasPreviewCollection setSelectionIndexes:[CPIndexSet indexSetWithIndex:[mSideSlides indexOfObject:aCanvas]]];
}

// Collection View Delegates

- (void)collectionViewDidChangeSelection:(CPCollectionView)aCollectionView
{
  if (aCollectionView == mCanvasPreviewCollection) {
    var listIndex = [[mCanvasPreviewCollection selectionIndexes] firstIndex];
    selectedCanvas = [[mCanvasPreviewCollection items] objectAtIndex:listIndex];

    var canvasView = [selectedCanvas representedObject];
    [self setCurrentCanvas:canvasView];
  }
}

@end

@implementation PreviewListCell : CPView
{
  CPTextField     label;
  CPView          highlightView;
}

- (void)setRepresentedObject:(JSObject)anObject
{
  // Quick Hack
  var width = CGRectGetHeight([self bounds]) * 0.80;
  var borderView = [[CPShadowView alloc] initWithFrame:CGRectMake(47, 10, 110, 70)];
  [borderView setBackgroundColor:[CPColor whiteColor]];

  var blueView = [[CPShadowView alloc] initWithFrame:CGRectInset([borderView bounds], 5, 5)];
  [blueView setBackgroundColor:[CPColor colorWithHexString:"5793D1"]];
  [borderView addSubview:blueView];

  [self addSubview:borderView];
}

- (void)setSelected:(BOOL)flag
{
  if(!highlightView) {
    highlightView = [[CPView alloc] initWithFrame:CGRectCreateCopy([self bounds])];
    [highlightView setBackgroundColor:[CPColor grayColor]];
  }

  if(flag) {
    [self addSubview:highlightView positioned:CPWindowBelow relativeTo:label];
    [label setTextColor:[CPColor whiteColor]];
  }
  else {
    [highlightView removeFromSuperview];
    [label setTextColor:[CPColor blackColor]];
  }
}

@end
