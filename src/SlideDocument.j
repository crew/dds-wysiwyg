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

@import <AppKit/CPDocument.j>
@import <AppKit/CPWindowController.j>
@import <AppKit/CPWindow.j>

@import "DDSWindowController.j"
@import "DDSGraphic.j"
@import "DDSRectangle.j"
@import "DDSLine.j"
@import "DDSCircle.j"

@implementation SlideDocument : CPDocument
{
	CPArray mGraphics;
	CPIndexSet mSelectionIndexes;
	CPMutableSet mUndoGroupInsertedGraphics;

	CPString mTest;
}

- (id)init
{
  self = [super init];
  if (self) {
  mGraphics = [CPArray array];
  mSelectionIndexes = [CPIndexSet indexSet];

  mTest = @"cappuccino";

  var graphic = [[DDSRectangle alloc] init];
  [graphic setXPosition:10.0];
  [graphic setYPosition:10.0];
  [graphic setWidth:100.0];
  [graphic setHeight:100.0];
  [graphic setIsDrawingFill:YES];
  [graphic setFillColor:[CPColor redColor]];
  [graphic setStrokeColor:[CPColor blueColor]];

  [mGraphics addObject:graphic];

  graphic = [[DDSRectangle alloc] init];
  [graphic setXPosition:100.0];
  [graphic setYPosition:20.0];
  [graphic setWidth:100.0];
  [graphic setHeight:100.0];
  [graphic setIsDrawingFill:YES];
  [graphic setFillColor:[CPColor greenColor]];
  [graphic setStrokeColor:[CPColor blueColor]];

  [mGraphics addObject:graphic];

  graphic = [[DDSCircle alloc] init];
  [graphic setXPosition:150.0];
  [graphic setYPosition:150.0];
  [graphic setWidth:100.0];
  [graphic setHeight:100.0];
  [graphic setIsDrawingFill:YES];
  [graphic setFillColor:[CPColor blueColor]];
  [graphic setStrokeColor:[CPColor redColor]];

  [mGraphics addObject:graphic];

  graphic = [[DDSLine alloc] init];
  [graphic setBeginPoint:CPPointMake(200.0, 10.0)];
  [graphic setEndPoint:CPPointMake(250.0, 110.0)];
  [graphic setStrokeColor:[CPColor greenColor]];

  [mGraphics addObject:graphic];

  [mSelectionIndexes addIndex:0];
  [mSelectionIndexes addIndex:2];
  }
  return self;
}

- (CPArray)graphics
{
  return mGraphics;
}

- (CPIndexSet)selectionIndexes
{
  return mSelectionIndexes;
}

- (void)setSelectionIndexes:(CPIndexSet)selectionIndexes
{
	mSelectionIndexes = selectionIndexes;
}

- (CPString)windowCibName
{
  return @"EditorWindow";
}

- (void)makeWindowControllers
{
//  console.trace();
  var controller = [[DDSWindowController alloc] initWithWindowCibName:[self windowCibName]];
  [self addWindowController:controller];
}


@end
