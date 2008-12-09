/* ***** BEGIN LICENCE BLOCK *****
 *
 * The Initial Developer of the Original Code is
 * The Northeastern University CCIS Volunteer Systems Group
 *
 * Contributor(s):
 *  Jeff Dlouhy <jdlouhy@ccs.neu.edu>
 *
 * ***** END LICENCE BLOCK ***** */

import <AppKit/CPDocument.j>

import "../editor/EditorWindowController.j"
import "SlideView.j"

@implementation SlideDocument : CPDocument
{
  EditorWindowController mWindowController;
  SlideView mSlideView;
}

-(void)setDocumentView:(SlideView)aSlideView
{
  if (mSlideView != aSlideView) {
    mSlideView = aSlideView;
  }
}

- (SlideView)documentView
{
  return mSlideView;
}

- (void)windowControllerWillLoadNib:(CPWindowController)aController
{
  [super windowControllerDidLoadNib:aController];
  CPLog("Loaded DOCUMENT");
}

- (void)makeWindowControllers
{
  mainWindow = [[EditorWindow alloc] initWithContentRect:CGRectMakeZero()
                                               styleMask:CPBorderlessBridgeWindowMask];

  mWindowController = [[EditorWindowController alloc] initWithWindow:mainWindow];
  [mWindowController setDocument:initialDoc];
  [mWindowController showWindow:self];
}

@end
