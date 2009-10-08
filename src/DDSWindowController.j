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
@import "DDSGraphicContainer.j"
//@import "UploadButton.j"

const kAddSlideItemIdentifier = @"kAddSlideItemIdentifier",
  kRemoveSlideItemIdentifier = @"kRemoveSlideItemIdentifier",
  kMediaInspectorItemIdentifier = @"kMediaInspectorItemIdentifier",
  kInspectorItemIdentifier = @"kInspectorItemIdentifier",
  kPublishSlideItemIdentifier = @"kPublishSlideItemIdentifier",
  kHelpItemIdentifier = @"kHelpItemIdentifier",
  kPreviewSlideItemIdentifier = @"kPreviewSlideItemIdentifier",
  kAdjustItemIdentifier = @"kAdjustItemIdentifier";

@implementation DDSWindowController : CPWindowController
{
//  CPWindow       mWindow;
  CPView         mContentView;
  CPToolbar      mToolbar;
	DDSGraphicContainer mGraphicContainer;
  CPPanel        mMediaPanel;
  CPPanel        mInspectorPanel;
  CPPanel        mAdjustPanel;
  UploadButton   mUploadButton;
}

- (void)awakeFromCib
{
  // mUploadButton = [[UploadButton alloc] initWithFrame: CGRectMake(50, 10, 0, 0)] ;
	// [mUploadButton setTitle:"Select File"] ;
	// //globalURL = [[CPString alloc] initWithString:@"http://host"];
	// //globalURL = [[CPString alloc] initWithString:@"http://0.0.0.0:3000"];
  // globalURL = [[CPString alloc] initWithString:@"http://dds.ccs.neu.edu/dds/assets/add/"];

	// [mUploadButton setURL:globalURL];
	// [mUploadButton setDelegate: self];
	// [mUploadButton sizeToFit];
	// [mUploadButton setAutoresizingMask:CPViewMinXMargin |
	// 			                      CPViewMaxXMargin] ;
	// [[mMediaPanel contentView] addSubview:mUploadButton];

  // console.log('goooo');
  //[[self window] setWindowController:self];
//	var contentView = [[self window] contentView];
// 	mGraphicView = [[DDSGraphicView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(bounds) - 20, CGRectGetHeight(bounds) -20)];
//  [mGraphicView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

  //[mContentView addSubview:mGraphicView];

//  [[self window] makeFirstResponder:mGraphicView];
  var bounds = [mContentView bounds];
  [[self window] setFullBridge:YES]

  mToolbar = [[CPToolbar alloc] initWithIdentifier:@"EditingToolbar"];

  [mToolbar setDelegate:self];
  [[self window] setToolbar:mToolbar];
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

- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
  return [
    kAddSlideItemIdentifier, kRemoveSlideItemIdentifier,
                           kMediaInspectorItemIdentifier, kInspectorItemIdentifier,
                           kPublishSlideItemIdentifier, kHelpItemIdentifier,
                           CPToolbarSeparatorItemIdentifier, kPreviewSlideItemIdentifier,
                           CPToolbarSpaceItemIdentifier, kAdjustItemIdentifier,
                           CPToolbarFlexibleSpaceItemIdentifier];
}

- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
  return [
    kAddSlideItemIdentifier,
                           kRemoveSlideItemIdentifier,
                           CPToolbarSeparatorItemIdentifier,
                           kPreviewSlideItemIdentifier,
                           kPublishSlideItemIdentifier,
                           CPToolbarFlexibleSpaceItemIdentifier,
                           kInspectorItemIdentifier,
                           kMediaInspectorItemIdentifier,
                           kAdjustItemIdentifier
          ];
}

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
  if (anItemIdentifier === kAddSlideItemIdentifier) {
    return [self itemWithImageName:@"blueprint-add.png"
                            imgAlt:@"blueprint-add_alt.png"
                             ident:anItemIdentifier
                             label:@"New Slide"
                            action:@selector(addSlide:)
                              size:CGSizeMake(32,32)];
  }

  else if (anItemIdentifier === kRemoveSlideItemIdentifier) {
    return [self itemWithImageName:@"blueprint-delete.png"
                            imgAlt:@"blueprint-delete_alt.png"
                             ident:anItemIdentifier
                             label:@"Delete Slide"
                            action:@selector(removeSlide:)
                              size:CGSizeMake(32,32)];
  }

  else if (anItemIdentifier === kMediaInspectorItemIdentifier) {
    var item = [self itemWithImageName:@"MediaBrowser.png"
                                imgAlt:@"MediaBrowserAlt.png"
                                 ident:anItemIdentifier
                                 label:@"Media"
                                action:@selector(orderFront:)
                                  size:CGSizeMake(32,32)];

    [item setTarget:mMediaPanel];
    return item;
  }

  else if (anItemIdentifier === kInspectorItemIdentifier) {
    var item =  [self itemWithImageName:@"GetInfo.png"
                                 imgAlt:@"GetInfoAlt.png"
                                  ident:anItemIdentifier
                                  label:@"Inspector"
                                 action:@selector(orderFront:)
                                   size:CGSizeMake(32,32)];

    [item setTarget:mInspectorPanel];
    return item;
  }

  else if (anItemIdentifier === kPublishSlideItemIdentifier) {
    return [self itemWithImageName:@"Publish.png"
                            imgAlt:@"PublishAlt.png"
                             ident:anItemIdentifier
                             label:@"Publish"
                            action:@selector(publishSlide:)
                              size:CGSizeMake(32,32)];
  }

  else if (anItemIdentifier === kHelpItemIdentifier) {
    return [self itemWithImageName:@"Help.png"
                            imgAlt:@"HelpAlt.png"
                             ident:anItemIdentifier
                             label:@"Help"
                            action:@selector(showHelp:)
                              size:CGSizeMake(32,32)];
  }

  else if (anItemIdentifier === kPreviewSlideItemIdentifier) {
    return [self itemWithImageName:@"Play.png"
                            imgAlt:@"PlayAlt.png"
                             ident:anItemIdentifier
                             label:@"Preview"
                            action:@selector(previewSlide:)
                              size:CGSizeMake(32,32)];
  }

  else if (anItemIdentifier === kAdjustItemIdentifier) {
    var item =  [self itemWithImageName:@"HUD.png"
                                 imgAlt:@"HUDAlt.png"
                                  ident:anItemIdentifier
                                  label:@"Adjust"
                                 action:@selector(orderFront:)
                                   size:CGSizeMake(32,32)];

    [item setTarget:mAdjustPanel];
    return item;
  }

  return null;
}

- (CPToolbarItem)itemWithImageName:(CPString)aImgName imgAlt:(CPString)aImgAlt ident:(CPString)anItemIdentifier label:(CPString)aLabel action:(SEL)aSelector size:(CGSize)aSize
{
  var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];
  var mainBundle = [CPBundle mainBundle];

  var image = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:aImgName] size:aSize];
  var highlighted = [[CPImage alloc] initWithContentsOfFile:[mainBundle pathForResource:aImgAlt] size:aSize];

  [toolbarItem setImage:image];
  [toolbarItem setAlternateImage:highlighted];

  [toolbarItem setTarget:self];
  [toolbarItem setAction:aSelector];
  [toolbarItem setLabel:aLabel];

  [toolbarItem setMinSize:CGSizeMake(32, 32)];
  [toolbarItem setMaxSize:CGSizeMake(32, 32)];

  return toolbarItem;
}

- (IBAction)uploadFile:(id)sender
{
  [mUploadButton setValue:@"foo" forParameter:@"name"];
  [mUploadButton setValue:@"this is some text" forParameter:@"description"];
  [mUploadButton submit];
}

@end
