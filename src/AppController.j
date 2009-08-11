/* ***** BEGIN LICENCE BLOCK *****
 *
 * The Initial Developer of the Original Code is
 * The Northeastern University CCIS Volunteer Systems Group
 *
 * Contributor(s):
 *  Jeff Dlouhy <jdlouhy@ccs.neu.edu>
 *
 * ***** END LICENCE BLOCK ***** */

@import <Foundation/CPObject.j>
@import "SlideDocument.j"

const kAddSlideItemIdentifier = @"kAddSlideItemIdentifier",
  kRemoveSlideItemIdentifier = @"kRemoveSlideItemIdentifier",
  kMediaInspectorItemIdentifier = @"kMediaInspectorItemIdentifier",
  kInspectorItemIdentifier = @"kInspectorItemIdentifier",
  kPublishSlideItemIdentifier = @"kPublishSlideItemIdentifier",
  kHelpItemIdentifier = @"kHelpItemIdentifier",
  kPreviewSlideItemIdentifier = @"kPreviewSlideItemIdentifier",
  kAdjustItemIdentifier = @"kAdjustItemIdentifier";

@implementation AppController : CPObject
{
  CPWindow    theWindow; //this "outlet" is connected automatically by the Cib
  CPToolbar   mToolbar;

  IBOutlet mInspectorPanel;
  IBOutlet mAdjustPanel;
  IBOutlet mMediaPanel;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
  // This is called when the application is done loading.
  CPLogRegister(CPLogPopup);
}

- (void)awakeFromCib
{
  // This is called when the cib is done loading.
  // You can implement this method on any object instantiated from a Cib.
  // It's a useful hook for setting up current UI values, and other things.

  // In this case, we want the window from Cib to become our full browser window
  [theWindow setFullBridge:YES];
  mToolbar = [[CPToolbar alloc] initWithIdentifier:@"EditingToolbar"];

  [mToolbar setDelegate:self];
  [theWindow setToolbar:mToolbar];

  var menuColors = [CPDictionary dictionary];

  [menuColors setValue:[CPColor blackColor] forKey:@"CPMenuBarBackgroundColor"];
  [menuColors setValue:[CPColor grayColor] forKey:@"CPMenuBarTextColor"];
  [menuColors setValue:[CPColor whiteColor] forKey:@"CPMenuBarTitleColor"];
  [menuColors setValue:[CPColor clearColor] forKey:@"CPMenuBarTextShadowColor"];
  [menuColors setValue:[CPColor clearColor] forKey:@"CPMenuBarTitleShadowColor"];
  [menuColors setValue:[CPColor whiteColor] forKey:@"CPMenuBarHighlightColor"];
  [menuColors setValue:[CPColor grayColor] forKey:@"CPMenuBarHighlightTextColor"];
  [menuColors setValue:[CPColor clearColor] forKey:@"CPMenuBarHighlightTextShadowColor"];

  [CPMenu setMenuBarAttributes:menuColors];

//   var mainMenu = [[CPApplication sharedApplication] mainMenu];
//   [mainMenu setTheme:[CPTheme themeNamed:"Aristo.HUD"]];


}

-(IBAction)createDocument:(id)sender
{
	var sharedDocumentController = [CPDocumentController sharedDocumentController];

	var documents = [sharedDocumentController documents];
	var defaultType = [sharedDocumentController defaultType];

	[sharedDocumentController newDocument:self];
  [sharedDocumentController openUntitledDocumentOfType:@"DDSlide" display:YES];
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
    if (anItemIdentifier === kAddSlideItemIdentifier)
    {
      return [self itemWithImageName:@"blueprint.png"
                              imgAlt:@"AddAlt.png"
                               ident:anItemIdentifier
                               label:@"New Slide"
                              action:@selector(addSlide:)
                                size:CGSizeMake(32,32)];
    }

    else if (anItemIdentifier === kRemoveSlideItemIdentifier)
    {
      return [self itemWithImageName:@"Remove.png"
                              imgAlt:@"RemoveAlt.png"
                               ident:anItemIdentifier
                               label:@"Delete Slide"
                              action:@selector(removeSlide:)
                                size:CGSizeMake(32,32)];
    }

    else if (anItemIdentifier === kMediaInspectorItemIdentifier)
    {
      var item = [self itemWithImageName:@"MediaBrowser.png"
                                  imgAlt:@"MediaBrowserAlt.png"
                                   ident:anItemIdentifier
                                   label:@"Media"
                                  action:@selector(orderFront:)
                                    size:CGSizeMake(32,32)];

      [item setTarget:mMediaPanel];
      return item;
    }

    else if (anItemIdentifier === kInspectorItemIdentifier)
    {
      var item =  [self itemWithImageName:@"GetInfo.png"
                                   imgAlt:@"GetInfoAlt.png"
                                    ident:anItemIdentifier
                                    label:@"Inspector"
                                   action:@selector(orderFront:)
                                     size:CGSizeMake(32,32)];

      [item setTarget:mInspectorPanel];
      return item;
    }

    else if (anItemIdentifier === kPublishSlideItemIdentifier)
    {
      return [self itemWithImageName:@"Publish.png"
                              imgAlt:@"PublishAlt.png"
                               ident:anItemIdentifier
                               label:@"Publish"
                              action:@selector(publishSlide:)
                                size:CGSizeMake(32,32)];
    }

    else if (anItemIdentifier === kHelpItemIdentifier)
    {
      return [self itemWithImageName:@"Help.png"
                              imgAlt:@"HelpAlt.png"
                               ident:anItemIdentifier
                               label:@"Help"
                              action:@selector(showHelp:)
                                size:CGSizeMake(32,32)];
    }

    else if (anItemIdentifier === kPreviewSlideItemIdentifier)
    {
      return [self itemWithImageName:@"Play.png"
                              imgAlt:@"PlayAlt.png"
                               ident:anItemIdentifier
                               label:@"Preview"
                              action:@selector(previewSlide:)
                                size:CGSizeMake(32,32)];
    }

    else if (anItemIdentifier === kAdjustItemIdentifier)
    {
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

@end
