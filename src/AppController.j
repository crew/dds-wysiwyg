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

}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
  // This is called when the application is done loading.
  CPLogRegister(CPLogPopup);
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
