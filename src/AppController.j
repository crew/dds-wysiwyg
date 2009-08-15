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

  [menuColors setValue:[CPColor blackColor] forKey:@"CPMenuBarBackgroundColor"];
  [menuColors setValue:[CPColor grayColor] forKey:@"CPMenuBarTextColor"];
  [menuColors setValue:[CPColor whiteColor] forKey:@"CPMenuBarTitleColor"];
  [menuColors setValue:[CPColor clearColor] forKey:@"CPMenuBarTextShadowColor"];
  [menuColors setValue:[CPColor clearColor] forKey:@"CPMenuBarTitleShadowColor"];
  [menuColors setValue:[CPColor whiteColor] forKey:@"CPMenuBarHighlightColor"];
  [menuColors setValue:[CPColor grayColor] forKey:@"CPMenuBarHighlightTextColor"];
  [menuColors setValue:[CPColor clearColor] forKey:@"CPMenuBarHighlightTextShadowColor"];

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
