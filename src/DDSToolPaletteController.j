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

@import <AppKit/CPWindowController.j>

@import "DDSCircle.j"
@import "DDSLine.j"
@import "DDSRectangle.j"
@import "DDSText.j"

@import "ImageCell.j"


DDSArrowToolRow = 0;
DDSRectToolRow = 1;
DDSCircleToolRow = 2;
DDSLineToolRow = 3;
DDSTextToolRow = 4;

DDSSelectedToolDidChangeNotification = @"DDSSelectedToolDidChange";

var sharedToolPaletteController = nil;


@implementation DDSToolPaletteController : CPWindowController
{
	CPCollectionView toolsCollectionView;
}

+ (id)sharedToolPaletteController
{
  if (!sharedToolPaletteController)
{
  sharedToolPaletteController = [[DDSToolPaletteController alloc] init];
}

  return sharedToolPaletteController;
}

- (id)init
{
	var theWindow = [[CPPanel alloc] initWithContentRect:CGRectMake(100, 100, 40, 160) styleMask:/*CPTitledWindowMask |*/ CPClosableWindowMask];
  self = [super initWithWindow:theWindow];
  if (self)
{
  [theWindow setTitle:@"Tools"];
  [theWindow setLevel:CPFloatingWindowLevel];

  var contentView = [theWindow contentView];
  var bounds = [contentView bounds];

  var toolCollectionViewItem = [[CPCollectionViewItem alloc] init];
  [toolCollectionViewItem setView:[[ImageCell alloc] initWithFrame:CGRectMake(0, 0, 36, 36)]];

  toolsCollectionView = [[CPCollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds))];
  [toolsCollectionView setMaxNumberOfColumns:1];
  [toolsCollectionView setMaxNumberOfRows:4];
  [toolsCollectionView setVerticalMargin:0.0];
  [toolsCollectionView setDelegate:self];
  [toolsCollectionView setItemPrototype:toolCollectionViewItem];
  [toolsCollectionView setMinItemSize:CGSizeMake(36, 36)];
  [toolsCollectionView setMaxItemSize:CGSizeMake(48, 48)];
  [toolsCollectionView setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];
  [toolsCollectionView setAllowsMultipleSelection:NO];

  // Associate the content array with the collection view
  [toolsCollectionView setContent:[self imagePathArray]];

  [contentView addSubview:toolsCollectionView];
}

  return self;
}


-(CPArray) imagePathArray
{
	var mainBundle = [CPBundle mainBundle];
	var path1 = [mainBundle pathForResource:@"Arrow.png"];
	var path2 = [mainBundle pathForResource:@"Rectangle.png"];
	var path3 = [mainBundle pathForResource:@"Circle.png"];
	var path4 = [mainBundle pathForResource:@"Line.png"];
	var path5 = [mainBundle pathForResource:@"TextGraphic.png"];
	// Pas de texte pour le moment
 	return [[CPArray alloc] initWithObjects:path1, path2, path3, path4, nil];
}


- (IBAction)selectToolAction:(id)sender
{
  [[CPNotificationCenter defaultCenter] postNotificationName:DDSSelectedToolDidChangeNotification object:self];
}

- (Class)currentGraphicClass
{
	var row = [[toolsCollectionView selectionIndexes] firstIndex];
  var theClass = nil;

	// debugger;

  if (row == DDSRectToolRow) {
    theClass = [DDSRectangle class];
  }
	else if (row == DDSCircleToolRow) {
    theClass = [DDSCircle class];
  }
	else if (row == DDSLineToolRow) {
    theClass = [DDSLine class];
  }
	else if (row == DDSTextToolRow) {
//        theClass = [DDSText class];
	}

  return theClass;
}

- (void)selectArrowTool {
//    [toolButtons selectCellAtRow:DDSArrowToolRow column:0];
  [[CPNotificationCenter defaultCenter] postNotificationName:DDSSelectedToolDidChangeNotification object:self];
}



@end
