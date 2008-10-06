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

import "src/editor/EditorWindow.j"
import "src/editor/EditorWindowController.j"
import "src/slide/SlideDocument.j"

@implementation AppController : CPObject
{
  EditorWindowController mWindowController;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
//  CPLogRegister(CPLogPopup);
  initialDoc = [[SlideDocument alloc] init];
  mainWindow = [[EditorWindow alloc] initWithContentRect:CGRectMakeZero()
                                               styleMask:CPBorderlessBridgeWindowMask];
  mWindowController = [[EditorWindowController alloc] initWithWindow:mainWindow];
  [mWindowController setDocument:initialDoc];
  [mWindowController showWindow:self];

  // Add the menu bar
  [CPMenu setMenuBarVisible:YES];
}




@end

