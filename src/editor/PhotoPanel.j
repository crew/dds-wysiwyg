/* ***** BEGIN LICENCE BLOCK *****
 *
 * The Initial Developer of the Original Code is
 * The Northeastern University CCIS Volunteer Systems Group
 *
 * Contributor(s):
 *  Jeff Dlouhy <jdlouhy@ccs.neu.edu>
 *
 * ***** END LICENCE BLOCK ***** */

@import <AppKit/CPPanel.j>
@import <AppKit/CPShadowView.j>
@import "../slide/DraggableImage.j"

kPhotoDragType = "kPhotoDragType";

@implementation PhotoPanel : CPPanel
{
  CPMutableArray mImages;
}

- (id)init
{
  self = [self initWithContentRect:CGRectMake(0.0, 0.0, 300.0, 400.0) styleMask:CPHUDBackgroundWindowMask | CPClosableWindowMask | CPResizableWindowMask];

  if (self) {
  [self setTitle:@"Photos"];
  [self setFloatingPanel:YES];

  var contentView = [self contentView],
    bounds = [contentView bounds];

  bounds.size.height -= 20.0;

  var photosView = [[CPCollectionView alloc] initWithFrame:bounds];

  [photosView setAutoresizingMask:CPViewWidthSizable];
  [photosView setMinItemSize:CGSizeMake(100, 100)];
  [photosView setMaxItemSize:CGSizeMake(100, 100)];
  [photosView setDelegate:self];

  var itemPrototype = [[CPCollectionViewItem alloc] init];
  var photoView = [[PhotoView alloc] initWithFrame:CGRectMakeZero()];

  [itemPrototype setView:photoView];

  [photosView setItemPrototype:itemPrototype];

  var scrollView = [[CPScrollView alloc] initWithFrame:bounds];

  [scrollView setDocumentView:photosView];
  [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [scrollView setAutohidesScrollers:YES];

  [[scrollView contentView] setBackgroundColor:[CPColor whiteColor]];

  [contentView addSubview:scrollView];

  mImages = [[CPMutableArray alloc] init];
  var filenames = [[CPArray alloc] initWithObjects:"sunbeams.png", "skyline_blue.png", "nuacm-logo.png",
                                   "seal_nu-black.png", "seal-black.png", "seal_nu-white.png", "seal-white.png"];


  for (var i = 0; i < [filenames count]; i++) {
    var filename = "resources/demos/" + [filenames objectAtIndex:i];
    var image = [[CPImage alloc] initWithContentsOfFile:filename];

    var draggableImage = [[DraggableImage alloc] initWithName:"FOO" image:image];
    [image setDelegate:draggableImage];
    [mImages addObject:draggableImage];
  }

  [photosView setContent:mImages];
}

  return self;
}


- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType
{
  return [CPKeyedArchiver archivedDataWithRootObject:[mImages objectAtIndex:[indices firstIndex]]];
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
  return [kPhotoDragType];
}

@end

@implementation PhotoView : CPShadowView
{
  CPImageView mImageView;
  BOOL mIsSelected;
}

- (void)setSelected:(BOOL)isSelected
{
  mIsSelected = isSelected;
}

- (void)setRepresentedObject:(id)anObject
{
  if (!mImageView)
{
  mImageView = [[CPImageView alloc] initWithFrame:CGRectInset([self bounds], 5.0, 5.0)];

  [mImageView setImageScaling:CPScaleProportionally];
  [mImageView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

  [self addSubview:mImageView];
}

  [mImageView setImage:[anObject image]];
}

@end
