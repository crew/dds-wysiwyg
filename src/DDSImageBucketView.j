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

PhotoDragType = "PhotoDragType";

@implementation DDSImageBucketView : CPView
{
  CPArray images;
}

- (void)awakeFromCib
{
  CPLog("SOo");
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame];

  // self = [self initWithContentRect:CGRectMake(0.0, 0.0, 300.0, 400.0) styleMask:CPHUDBackgroundWindowMask | CPClosableWindowMask | CPResizableWindowMask];
  CPLog("SOo");
  if (self) {
    [self setTitle:@"Photos"];
    [self setFloatingPanel:YES];

    var bounds = [contentView bounds];

    var photosView = [[CPCollectionView alloc] initWithFrame:bounds];

    [photosView setAutoresizingMask:CPViewWidthSizable];
    [photosView setMinItemSize:CGSizeMake(100, 100)];
    [photosView setMaxItemSize:CGSizeMake(100, 100)];
    [photosView setDelegate:self];

    var itemPrototype = [[CPCollectionViewItem alloc] init];

    [itemPrototype setView:[[PhotoView alloc] initWithFrame:CGRectMakeZero()]];

    [photosView setItemPrototype:itemPrototype];

    var scrollView = [[CPScrollView alloc] initWithFrame:bounds];

    [scrollView setDocumentView:photosView];
    [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [scrollView setAutohidesScrollers:YES];

    [[scrollView contentView] setBackgroundColor:[CPColor whiteColor]];

    [contentView addSubview:scrollView];

    images = [ [[CPImage alloc] initWithContentsOfFile:@"Resources/blueprint.png"
                                                  size:CGSizeMake(500.0, 430.0)],
               [[CPImage alloc] initWithContentsOfFile:@"Resources/blueprint.png"
                                                  size:CGSizeMake(500.0, 375.0)] ];

    [photosView setContent:images];
  }

  return self;
}

- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType
{
  return [CPKeyedArchiver archivedDataWithRootObject:[images objectAtIndex:[indices firstIndex]]];
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
  return [PhotoDragType];
}

@end


@implementation PhotoView : CPImageView
{
  CPImageView _imageView;
}

- (void)setSelected:(BOOL)isSelected
{
  [self setBackgroundColor:isSelected ? [CPColor grayColor] : nil];
}

- (void)setRepresentedObject:(id)anObject
{
  if (!_imageView)
{
  _imageView = [[CPImageView alloc] initWithFrame:CGRectInset([self bounds], 5.0, 5.0)];

  [_imageView setImageScaling:CPScaleProportionally];
  [_imageView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

  [self addSubview:_imageView];
}

  [_imageView setImage:anObject];
}

@end
