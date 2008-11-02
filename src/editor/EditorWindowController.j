/* ***** BEGIN LICENCE BLOCK *****
 *
 * The Initial Developer of the Original Code is
 * The Northeastern University CCIS Volunteer Systems Group
 *
 * Contributor(s):
 *  Jeff Dlouhy <jdlouhy@ccs.neu.edu>
 *
 * ***** END LICENCE BLOCK ***** */

import <AppKit/CPWindowController.j>
import <AppKit/CPColorPanel.j>

import "PhotoPanel.j"

@implementation EditorWindowController : CPWindowController
{
  CPPanel mInspectorPanel;
  CPPanel mMediaBrowser;
}

-(id)initWithWindow:(CPWindow)aWindow
{
  self = [super initWithWindow:aWindow];

  if (self != nil) {
    var bounds = [[aWindow contentView] bounds];
    mInspectorPanel = [[CPPanel alloc] initWithContentRect:CGRectMake((CGRectGetWidth(bounds) / 2), 0, 225, 125)
                                                 styleMask:CPHUDBackgroundWindowMask | CPClosableWindowMask];
    [mInspectorPanel setFloatingPanel:YES];
    [mInspectorPanel setTitle:"Inspector"];

//     mMediaBrowser = [[CPPanel alloc] initWithContentRect:CGRectMake((CGRectGetWidth(bounds) / 2), (CGRectGetHeight(bounds) / 2), 225, 325)
//                                                styleMask:CPHUDBackgroundWindowMask | CPClosableWindowMask];
//     [mMediaBrowser setFloatingPanel:YES];
//     [mMediaBrowser setTitle:"Media Browser"];

//    var mediaCollection = [[CPCollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([mMediaBrowser frame]), CGRectGetHeight([mMediaBrowser frame]))];
//    [mediaCollection setBackgroundColor:[CPColor whiteColor]];
  //[mMediaBrowser addSubview:mediaCollection];
    mMediaBrowser = [[PhotoPanel alloc] init];
  }

  return self;
}

- (void)showColors:(id)sender
{
//  [[CPColorPanel sharedColorPanel] setPickerMode:CPWheelColorPickerMode];
  [[CPColorPanel sharedColorPanel] orderFront:self];
  var colorPicker = [CPColorPanel sharedColorPanel];

  [colorPicker setTarget:mCurrentCanvasView];
}

- (void)showInspector:(id)sender
{
  [mInspectorPanel orderFront:self];

  var colorWell = [[CPColorWell alloc] initWithFrame:CGRectMake(0, 0 , 30, 40)];
  [[mInspectorPanel contentView] addSubview:colorWell];
}

- (void)showMediaBrowser:(id)sender
{
  [mMediaBrowser orderFront:self];
}

@end
