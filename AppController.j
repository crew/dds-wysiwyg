/* ***** BEGIN LICENCE BLOCK *****
 *
 * The Initial Developer of the Original Code is
 * The Northeastern University CCIS Volunteer Systems Group
 *
 * Contributor(s):
 *  Jeff Dlouhy <jdlouhy@ccs.neu.edu>
 *
 * ***** END LICENCE BLOCK ***** */

import <Foundation/CPObject.j>
import <AppKit/CPDocumentController.j>

import "src/editor/EditorWindow.j"
import "src/slide/SlideDocument.j"

@implementation AppController : CPObject
{
  CPDocumentController mDocumentController;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
  CPLogRegister(CPLogPopup);
  initialDoc = [[SlideDocument alloc] init];
  mDocumentController = [CPDocumentController sharedDocumentController];

  [mDocumentController addDocument:initialDoc];
  [initialDoc makeWindowControllers];

  // Add the menu bar
  [CPMenu setMenuBarVisible:YES];
}

@end

