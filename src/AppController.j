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
@import "CPApplication+MediaKitAdditions.j"

@implementation AppController : CPObject
{
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

  var menuColors = [CPDictionary dictionary];


  [menuColors setObject:[CPColor colorWithCalibratedRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0] forKey:@"CPMenuBarTextColor"];
  [menuColors setObject:[CPColor colorWithCalibratedRed:177.0/255.0 green:177.0/255.0 blue:177.0/255.0 alpha:1.0] forKey:@"CPMenuBarTitleColor"];
  [menuColors setObject:[CPColor clearColor] forKey:@"CPMenuBarTextShadowColor"];
  [menuColors setObject:[CPColor colorWithCalibratedRed:115.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0] forKey:@"CPMenuBarTitleShadowColor"];
  [menuColors setObject:[CPColor whiteColor] forKey:@"CPMenuBarHighlightColor"];
  [menuColors setObject:[CPColor grayColor] forKey:@"CPMenuBarHighlightTextColor"];
  [menuColors setObject:[CPColor clearColor] forKey:@"CPMenuBarHighlightTextShadowColor"];
  [menuColors setObject:[CPColor colorWithCalibratedRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0] forKey:@"CPMenuBarHighlightColor"];

  var bgColor = [CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:@"Resources/menu_background.png" size:CGSizeMake(1.0, 18.0)]];
  [menuColors setObject:bgColor forKey:@"CPMenuBarBackgroundColor"];
  [CPMenu setMenuBarAttributes:menuColors];
}

-(IBAction)createDocument:(id)sender
{
	var sharedDocumentController = [CPDocumentController sharedDocumentController];

	var documents = [sharedDocumentController documents];
	var defaultType = [sharedDocumentController defaultType];

	[sharedDocumentController newDocument:self];
  [sharedDocumentController openUntitledDocumentOfType:@"DDSlide" display:YES];
}


@end
