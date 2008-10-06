/* ***** BEGIN LICENCE BLOCK *****
 *
 * The Initial Developer of the Original Code is
 * The Northeastern University CCIS Volunteer Systems Group
 *
 * Contributor(s):
 *  Jeff Dlouhy <jdlouhy@ccs.neu.edu>
 *
 * ***** END LICENCE BLOCK ***** */

import <AppKit/CPWindow.j>
import <AppKit/CPView.j>
import <AppKit/CPToolbar.j>
import <AppKit/CPToolbarItem.j>

import "EditorView.j"

const kAddToolbarItemIdentifier = "kAddToolbarItemIdentifier";
const kColorItemIdentifier = "kColorItemIdentifier";
const kInfoItemIdentifier = "kInfoItemIdentifier";
const kMediaItemIdentifier = "kMediaItemIdentifier";
const kPublishItemIdentifier = "kPublishItemIdentifier";

@implementation EditorWindow : CPWindow
{

}

-(id)initWithContentRect:(CGRect)aContentRect styleMask:(unsigned int)aStyleMask
{
  self = [super initWithContentRect:aContentRect styleMask:aStyleMask];

  if (self != nil) {
    var toolbar = [[CPToolbar alloc] initWithIdentifier:"Photos"];
    [toolbar setDelegate:self];
    [toolbar setVisible:true];
    [self setToolbar:toolbar];

    editorView = [[EditorView alloc] initWithFrame:aContentRect];
    [self setContentView:editorView];
  }

  return self;
}

// Toolbar Delegates

- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
  return [kAddToolbarItemIdentifier, kColorItemIdentifier, kPublishItemIdentifier, kMediaItemIdentifier, kInfoItemIdentifier, CPToolbarFlexibleSpaceItemIdentifier];
}

- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
  return [kAddToolbarItemIdentifier, CPToolbarFlexibleSpaceItemIdentifier, kPublishItemIdentifier, CPToolbarFlexibleSpaceItemIdentifier, kMediaItemIdentifier, kColorItemIdentifier, kInfoItemIdentifier];
}

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
  var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier: anItemIdentifier];

 if (anItemIdentifier == kAddToolbarItemIdentifier) {
   var image = [[CPImage alloc] initWithContentsOfFile:"resources/toolbar/images/Frame.png" size:CPSizeMake(32, 32)],
     highlighted = [[CPImage alloc] initWithContentsOfFile:"resources/toolbar/images/Frame_alt.png" size:CPSizeMake(32, 32)];

  [toolbarItem setImage: image];
  [toolbarItem setAlternateImage: highlighted];

  [toolbarItem setTarget:[self windowController]];
  [toolbarItem setAction: @selector(add:)];
  [toolbarItem setLabel: "Add Billboard"];

  [toolbarItem setMinSize:CGSizeMake(32, 32)];
  [toolbarItem setMaxSize:CGSizeMake(32, 32)];
 }
 else if (anItemIdentifier == kColorItemIdentifier) {
   var image = [[CPImage alloc] initWithContentsOfFile:"resources/toolbar/images/colors.png" size:CPSizeMake(32, 32)],
     highlighted = [[CPImage alloc] initWithContentsOfFile:"resources/toolbar/images/colors_alt.png" size:CPSizeMake(32, 32)];

   [toolbarItem setImage: image];
   [toolbarItem setAlternateImage: highlighted];

   [toolbarItem setTarget:[self windowController]];
   [toolbarItem setAction: @selector(showColors:)];
   [toolbarItem setLabel: "Colors"];

   [toolbarItem setMinSize:CGSizeMake(32, 32)];
   [toolbarItem setMaxSize:CGSizeMake(32, 32)];
 }
 else if (anItemIdentifier == kPublishItemIdentifier) {
   var image = [[CPImage alloc] initWithContentsOfFile:"resources/toolbar/images/Photocast.png" size:CPSizeMake(32, 32)],
     highlighted = [[CPImage alloc] initWithContentsOfFile:"resources/toolbar/images/Photocast_alt.png" size:CPSizeMake(32, 32)];

   [toolbarItem setImage: image];
   [toolbarItem setAlternateImage: highlighted];

   [toolbarItem setTarget:[self windowController]];
//   [toolbarItem setAction: @selector(add:)];
   [toolbarItem setLabel: "Publish"];

   [toolbarItem setMinSize:CGSizeMake(32, 32)];
   [toolbarItem setMaxSize:CGSizeMake(32, 32)];
 }
 else if (anItemIdentifier == kMediaItemIdentifier) {
   var image = [[CPImage alloc] initWithContentsOfFile:"resources/toolbar/images/Media_Browser.png" size:CPSizeMake(32, 32)],
      highlighted = [[CPImage alloc] initWithContentsOfFile:"resources/toolbar/images/Media_Browser_alt.png" size:CPSizeMake(32, 32)];

   [toolbarItem setImage: image];
   [toolbarItem setAlternateImage: highlighted];

   [toolbarItem setTarget:[self windowController]];
   [toolbarItem setAction: @selector(showMediaBrowser:)];
   [toolbarItem setLabel: "Media"];

   [toolbarItem setMinSize:CGSizeMake(32, 32)];
   [toolbarItem setMaxSize:CGSizeMake(32, 32)];
 }
 else if (anItemIdentifier == kInfoItemIdentifier) {
   var image = [[CPImage alloc] initWithContentsOfFile:"resources/toolbar/images/Get_Info.png" size:CPSizeMake(32, 32)],
      highlighted = [[CPImage alloc] initWithContentsOfFile:"resources/toolbar/images/Get_Info_alt.png" size:CPSizeMake(32, 32)];

   [toolbarItem setImage: image];
   [toolbarItem setAlternateImage: highlighted];

   [toolbarItem setTarget:[self windowController]];
   [toolbarItem setAction: @selector(showInspector:)];
   [toolbarItem setLabel: "Inspector"];

   [toolbarItem setMinSize:CGSizeMake(32, 32)];
   [toolbarItem setMaxSize:CGSizeMake(32, 32)];
 }

  return toolbarItem;
}

@end
