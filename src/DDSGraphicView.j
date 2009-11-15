/* ***** BEGIN LICENCE BLOCK *****
 *
 * The Initial Developer of the Original Code is
 * The Northeastern University CCIS Volunteer Systems Group
 *
 * Contributor(s):
 *  Jeff Dlouhy <jdlouhy@ccs.neu.edu>
 *
 * ***** END LICENCE BLOCK ***** */

@import <AppKit/CPView.j>
@import <AppKit/CPColor.j>
@import <AppKit/CPGraphicsContext.j>

@import "DDSToolPaletteController.j"
@import "DDSGraphic.j"
@import "DDSGrid.j"

// The default value by which repetitively pasted sets of graphics are offset from each other,
// so the user can paste repeatedly and not end up with a pile of graphics that overlay each other
// so perfectly only the top set can be selected with the mouse.
DDSGraphicViewDefaultPasteCascadeDelta = 10.0;

// Width Divisor Constant
const kRatioWidth = 1920;
// Height Divisor Constant
const kRatioHeight = 1080;

@implementation DDSGraphicView : CPView
{
	// The grid that is drawn in the view and used to constrain graphics as they're created and moved.
	// In Sketch this is just a cache of a value that canonically lives in the DDSWindowController
	// to which this view's grid property is bound (see DDSWindowController's comments for an explanation of why the grid lives there).
  DDSGrid _grid;

  // The graphic that is being created right now, if a graphic is being created right now (not explicitly retained, because it's always allocated and forgotten about in the same method).
  DDSGraphic _creatingGraphic;

  // The graphic that is being edited right now, the view that it gave us to present its editing interface, and the last known frame of that view, if a graphic is being edited right now. We have to record the editing view frame because when it changes we need its old value, and the old value isn't available when this view gets the NSViewFrameDidChangeNotification. Also, the reserved thickness for the horizontal ruler accessory view before editing began, so we can restore it after editing is done. (We could do the same for the vertical ruler, but so far in Sketch there are no vertical ruler accessory views.)
  DDSGraphic _editingGraphic;
  CPView _editingView;
  CPRect _editingViewFrame;

  // The bounds of the marquee selection, if marquee selection is being done right now, NSZeroRect otherwise.
  CPRect _marqueeSelectionBounds;

  // Whether or not selection handles are being hidden while the user moves graphics.
  BOOL _isHidingHandles;

  // Sometimes we temporarily hide the selection handles when the user moves graphics using the keyboard. When we do that this is the timer to start showing them again.
  CPTimer _handleShowingTimer;

  // The state of the cascading of graphics that we do during repeated pastes.
  int _pasteboardChangeCount;
  int _pasteCascadeNumber;
  CPPoint _pasteCascadeDelta;


	// For mouse tracking
	DDSGraphic _resizedGraphic;
	int _resizedHandle;
	BOOL _didMove;
	BOOL _isMoving;
  CPPoint _lastPoint;
	CPPoint _selOriginOffset;
	CPArray _selGraphics;

	// Marquee tracking
	CPPoint _originalMouseLocation;
	CPIndexSet _oldSelectionIndexes;
}


- (id)initWithFrame:(CPRect)frame
{
  self = [super initWithFrame:frame];
  if (self){
  _marqueeSelectionBounds = CPRectMakeZero();

  // Initalize the cascading of pasted graphics.
  _pasteboardChangeCount = -1;
  _pasteCascadeNumber = 0;
  _pasteCascadeDelta = CPMakePoint(DDSGraphicViewDefaultPasteCascadeDelta, DDSGraphicViewDefaultPasteCascadeDelta);
  [self registerForDraggedTypes:[CPImagesPboardType]];
}
  return self;
}

- (CPArray)graphics
{
 var graphics = [[[self window] windowController] graphics];
  if (!graphics) {
		graphics = [CPArray array];
  }
  return graphics;
}

- (CPIndexSet)selectionIndexes
{
  var selectionIndexes = [[[self window] windowController] selectionIndexes];
  if (!selectionIndexes) {
		selectionIndexes = [CPIndexSet indexSet];
  }
  return selectionIndexes;
}

- (CPArray)mutableGraphics
{
  return [self graphics];
}

- (void)changeSelectionIndexes:(CPIndexSet)indexes
{
  var selectionIndexes = [[[self window] windowController] setSelectionIndexes:indexes];
}

- (CPArray)selectedGraphics
{
  // Simple, because we made sure -graphics and -selectionIndexes never return nil.
  return [[self graphics] objectsAtIndexes:[self selectionIndexes]];
}

// An override of the NSView method.
- (void)drawRect:(CPRect)rect
{
  var context = [[CPGraphicsContext currentContext] graphicsPort];

  // Draw the background background.
  CGContextSetFillColor(context, [CPColor whiteColor]);
  CGContextFillRect(context, rect);

  // Draw the grid.
  [_grid drawRect:rect inView:self];

  // Draw every graphic that intersects the rectangle to be drawn. The frontmost graphics have the lowest indexes.
  var graphics = [self graphics];
  var selectionIndexes = [self selectionIndexes];

  var graphicCount = [graphics count];
  for (var index = graphicCount - 1; index>=0; index--) {
    var graphic = [graphics objectAtIndex:index];
    var graphicDrawingBounds = [graphic drawingBounds];
    if (CPRectIntersectsRect(rect, graphicDrawingBounds)) {
      // Figure out whether or not to draw selection handles on the graphic. Selection handles are drawn for all selected objects except:
      // - While the selected objects are being moved.
      // - For the object actually being created or edited, if there is one.
      var drawSelectionHandles = NO;
      if (!_isHidingHandles && graphic!=_creatingGraphic && graphic!=_editingGraphic) {
        drawSelectionHandles = [selectionIndexes containsIndex:index];
      }

      // Draw the graphic, possibly with selection handles.
      CGContextSaveGState(context);

      // [NSBezierPath clipRect:graphicDrawingBounds];
      [graphic drawContentsInView:self isBeingCreateOrEdited:(graphic==_creatingGraphic || graphic==_editingGraphic)];
      if (drawSelectionHandles) {
        [graphic drawHandlesInView:self];
      }

      CGContextRestoreGState(context);
    }
  }

  // If the user is in the middle of selecting draw the selection rectangle.
  if (!CPRectIsEmpty(_marqueeSelectionBounds)) {
    CGContextSetStrokeColor(context, [CPColor lightGrayColor]);
    CGContextStrokeRect(context, _marqueeSelectionBounds);
    //CGContextStrokeRectWithWidth(context, _marqueeSelectionBounds, 1.0);
  }
}




- (void)setNeedsDisplayForEditingViewFrameChangeNotification:(CPNotification)viewFrameDidChangeNotification
{
  // If the editing view got smaller we have to redraw where it was or cruft will be left on the screen.
	// If the editing view got larger we might be doing some redundant invalidation (not a big deal),
	// but we're not doing any redundant drawing (which might be a big deal).
	// If the editing view actually moved then we might be doing substantial redundant drawing, but so far that wouldn't happen in Sketch.
  // In Sketch this prevents cruft being left on the screen when the user
	// 1) creates a great big text area and fills it up with text,
	// 2) sizes the text area so not all of the text fits,
	// 3) starts editing the text area but doesn't actually change it, so the text area hasn't been automatically
	// resized and the text editing view is actually bigger than the text area,
	// and 4) deletes so much text in one motion (Select All, then Cut) that the text editing view suddenly becomes smaller than the text area.
	// In every other text editing situation the text editing view's invalidation or the fact that the DDSText's "drawingBounds"
	// changes is enough to cause the proper redrawing.
  var newEditingViewFrame = [[viewFrameDidChangeNotification object] frame];
  [self setNeedsDisplayInRect:CPRectUnion(_editingViewFrame, newEditingViewFrame)];
  _editingViewFrame = newEditingViewFrame;
}


- (void)startEditingGraphic:(DDSGraphic)graphic
{
  // It's the responsibility of invokers to not invoke this method when editing has already been started.
  // CPAssert((!_editingGraphic && !_editingView), @"-[DDSGraphicView startEditingGraphic:] is being mis-invoked.");

  // Can the graphic even provide an editing view?
  _editingView = [graphic newEditingViewWithSuperviewBounds:[self bounds]];
  if (_editingView)
{
  // Keep a pointer to the graphic around so we can ask it to draw its "being edited" look, and eventually send it a -finalizeEditingView: message.
  _editingGraphic = graphic;

  // If the editing view adds a ruler accessory view we're going to remove it when editing is done, so we have to remember the old reserved accessory view thickness so we can restore it. Otherwise there will be a big blank space in the ruler.
  // _oldReservedThicknessForRulerAccessoryView = [[[self enclosingScrollView] horizontalRulerView] reservedThicknessForAccessoryView];

  // Make the editing view a subview of this one. It was the graphic's job to make sure that it was created with the right frame and bounds.
  [self addSubview:_editingView];

  // Make the editing view the first responder so it takes key events and relevant menu item commands.
  [[self window] makeFirstResponder:_editingView];

  // Get notified if the editing view's frame gets smaller, because we may have to force redrawing when that happens. Record the view's frame because it won't be available when we get the notification.
  [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplayForEditingViewFrameChangeNotification:) name:CPViewFrameDidChangeNotification object:_editingView];
  _editingViewFrame = [_editingView frame];

  // Give the graphic being edited a chance to draw one more time. In Sketch, DDSText draws a focus ring.
  [self setNeedsDisplayInRect:[_editingGraphic drawingBounds]];
}

}


- (void)stopEditing
{
  // Make it harmless to invoke this method unnecessarily.
  if (_editingView)
{

  // Undo what we did in -startEditingGraphic:.
  [[CPNotificationCenter defaultCenter] removeObserver:self name:CPViewFrameDidChangeNotification object:_editingView];

  // Pull the editing view out of this one. When editing is being stopped because the user has clicked in this view, outside of the editing view, NSWindow will have already made this view the window's first responder, and that's good. However, when editing is being stopped because the edited graphic is being removed (by undoing or scripting, for example), the invocation of -[NSView removeFromSuperview] we do here will leave the window as its own first responder, and that would be bad, so also fix the window's first responder if appropriate. It wouldn't be appropriate to steal first-respondership from sibling views here.
  var makeSelfFirstResponder = [[self window] firstResponder] == _editingView ? YES : NO;
  [_editingView removeFromSuperview];
  if (makeSelfFirstResponder) {
    [[self window] makeFirstResponder:self];
  }

  // If the editing view added a ruler accessory view then remove it because it's not applicable anymore, and get rid of the blank space in the ruler that would otherwise result. In Sketch the NSTextViews created by DDSTexts leave horizontal ruler accessory views.
  // NSRulerView *horizontalRulerView = [[self enclosingScrollView] horizontalRulerView];
  // [horizontalRulerView setAccessoryView:nil];
  // [horizontalRulerView setReservedThicknessForAccessoryView:_oldReservedThicknessForRulerAccessoryView];

  // Give the graphic that created the editing view a chance to tear down their relationships and then forget about them both.
  [_editingGraphic finalizeEditingView:_editingView];
  _editingGraphic = nil;
  _editingView = nil;

}

}

- (CPDictionary)graphicUnderPoint:(CPPoint)point
{
  var graphicToReturn = nil;
	var outIndex = 0;
	var outIsSelected = NO;
	var outHandle = DDSGraphicNoHandle;

  // Search through all of the graphics, front to back, looking for one that claims that the point is on a selection handle
	// (if it's selected) or in the contents of the graphic itself.
  var graphics = [self graphics];
  var selectionIndexes = [self selectionIndexes];
  var graphicCount = [graphics count];
  for (var index = 0; index<graphicCount; index++)
{
  var graphic = [graphics objectAtIndex:index];

  // Do a quick check to weed out graphics that aren't even in the neighborhood.
  if (CPRectContainsPoint([graphic drawingBounds], point))
{
  // Check the graphic's selection handles first, because they take precedence when they overlap the graphic's contents.
  var graphicIsSelected = [selectionIndexes containsIndex:index];
  if (graphicIsSelected)
{
  // If the graphic is selected, we can see it's handles and try to select one with the mouse
  var handle = [graphic handleUnderPoint:point];
  if (handle != DDSGraphicNoHandle)
{
  // The user clicked on a handle of a selected graphic.
  graphicToReturn = graphic;
  outHandle = handle;
}
}

  if (! graphicToReturn)
{
  var clickedOnGraphicContents = [graphic isContentsUnderPoint:point];
  if (clickedOnGraphicContents)
{
  // The user clicked on the contents of a graphic.
  graphicToReturn = graphic;
  outHandle = DDSGraphicNoHandle;
}
}

  if (graphicToReturn)
{
  // Return values and stop looking.
  outIndex = index;
  outIsSelected = graphicIsSelected;
  break;
}

}

}

	// DDSL : Be aware, we can not use nil for graphicToReturn but [CPNull null]
	if (! graphicToReturn)
{
  graphicToReturn = [CPNull null]
    }

	var objects = [CPArray arrayWithObjects:graphicToReturn, [CPNumber numberWithInt:outIndex],
                 [CPNumber numberWithBool:outIsSelected], [CPNumber numberWithInt:outHandle], nil];
	var keys = [CPArray arrayWithObjects:@"graphic", @"index", @"isSelected", @"handle", nil];
  return [CPDictionary dictionaryWithObjects:objects forKeys:keys];
}


- (void)moveSelectedGraphicsWithEvent:(CPEvent)event
{
  var type = [event type];

  if (type == CPLeftMouseUp)
{
  // if (echoToRulers)  {
  //    [self stopEchoingMoveToRulers];
  // }

  if (_isMoving)
{
  _isHidingHandles = NO;

  [self setNeedsDisplayInRect:[DDSGraphic drawingBoundsOfGraphics:_selGraphics]];
  if (_didMove)
{
  // Only if we really moved.
  // [[self undoManager] setActionName:NSLocalizedStringFromTable(@"Move", @"UndoStrings", @"Action name for moves.")];
}
}

  return;
}

  if (type == CPLeftMouseDown)
{
  _selGraphics = [self selectedGraphics];
  var c = [_selGraphics count];
  //var echoToRulers = [[self enclosingScrollView] rulersVisible];
  var selBounds = [[DDSGraphic self] boundsOfGraphics:_selGraphics];

  _didMove = NO;
  _isMoving = NO;

  _lastPoint = [self convertPoint:[event locationInWindow] fromView:nil];
  _selOriginOffset = CPMakePoint((_lastPoint.x - selBounds.origin.x), (_lastPoint.y - selBounds.origin.y));

  // if (echoToRulers) {
  //    [self beginEchoingMoveToRulers:selBounds];
  // }

}
  else if (type == CPLeftMouseDragged)
{
  [self autoscroll:event];
  var curPoint = [self convertPoint:[event locationInWindow] fromView:nil];
  if (!_isMoving && ((Math.abs(curPoint.x - _lastPoint.x) >= 2.0) || (Math.abs(curPoint.y - _lastPoint.y) >= 2.0)))
{
  _isMoving = YES;
  _isHidingHandles = YES;
}

  if (_isMoving)
{
  if (_grid)
{
  var boundsOrigin = CPMakePoint((curPoint.x - _selOriginOffset.x), (curPoint.y - _selOriginOffset.y));
  boundsOrigin  = [_grid constrainedPoint:boundsOrigin];
  curPoint.x = (boundsOrigin.x + _selOriginOffset.x);
  curPoint.y = (boundsOrigin.y + _selOriginOffset.y);
}

  if (! CPPointEqualToPoint(_lastPoint, curPoint))
{
  [[DDSGraphic class] translateGraphics:_selGraphics byX:(curPoint.x - _lastPoint.x) y:(curPoint.y - _lastPoint.y)];
  _didMove = YES;

  [self setNeedsDisplay:YES];

  // if (echoToRulers) {
  //	[self continueEchoingMoveToRulers:NSMakeRect(curPoint.x - selOriginOffset.x, curPoint.y - selOriginOffset.y, NSWidth(selBounds),NSHeight(selBounds))];
  // }

  // Adjust the delta that is used for cascading pastes.
  // Pasting and then moving the pasted graphic is the way you determine the cascade delta for subsequent pastes.
  _pasteCascadeDelta.x += (curPoint.x - _lastPoint.x);
  _pasteCascadeDelta.y += (curPoint.y - _lastPoint.y);
}

  _lastPoint = curPoint;
}
}

  [CPApp setTarget:self selector:@selector(moveSelectedGraphicsWithEvent:) forNextEventMatchingMask:CPLeftMouseDraggedMask | CPLeftMouseUpMask untilDate:nil inMode:nil dequeue:YES];
}


/*
  - (void)old_moveSelectedGraphicsWithEvent:(CPEvent)event
  {
  var lastPoint, curPoint;
  var selGraphics = [self selectedGraphics];
  var c;
  var didMove = NO, isMoving = NO;
  //var echoToRulers = [[self enclosingScrollView] rulersVisible];
  var selBounds = [[DDSGraphic self] boundsOfGraphics:selGraphics];

  c = [selGraphics count];

  lastPoint = [self convertPoint:[event locationInWindow] fromView:nil];
  var selOriginOffset = CPMakePoint((lastPoint.x - selBounds.origin.x), (lastPoint.y - selBounds.origin.y));

	// if (echoToRulers) {
  //    [self beginEchoingMoveToRulers:selBounds];
  // }

  while ([event type] != CPLeftMouseUp)
	{
  event = [[self window] nextEventMatchingMask:(CPLeftMouseDraggedMask | CPLeftMouseUpMask)];
  [self autoscroll:event];
  curPoint = [self convertPoint:[event locationInWindow] fromView:nil];
  if (!isMoving && ((Math.abs(curPoint.x - lastPoint.x) >= 2.0) || (Math.abs(curPoint.y - lastPoint.y) >= 2.0)))
  {
  isMoving = YES;
  _isHidingHandles = YES;
  }

  if (isMoving)
  {
  if (_grid)
  {
  var boundsOrigin = CPMakePoint((curPoint.x - selOriginOffset.x), (curPoint.y - selOriginOffset.y));
  boundsOrigin  = [_grid constrainedPoint:boundsOrigin];
  curPoint.x = (boundsOrigin.x + selOriginOffset.x);
  curPoint.y = (boundsOrigin.y + selOriginOffset.y);
  }

  if (! CPPointEqualToPoint(lastPoint, curPoint))
  {
  [[DDSGraphic class] translateGraphics:selGraphics byX:(curPoint.x - lastPoint.x) y:(curPoint.y - lastPoint.y)];
  didMove = YES;

  // if (echoToRulers) {
  //	[self continueEchoingMoveToRulers:NSMakeRect(curPoint.x - selOriginOffset.x, curPoint.y - selOriginOffset.y, NSWidth(selBounds),NSHeight(selBounds))];
  // }

  // Adjust the delta that is used for cascading pastes.
  // Pasting and then moving the pasted graphic is the way you determine the cascade delta for subsequent pastes.
  _pasteCascadeDelta.x += (curPoint.x - lastPoint.x);
  _pasteCascadeDelta.y += (curPoint.y - lastPoint.y);
  }

  lastPoint = curPoint;
  }
  }

  // if (echoToRulers)  {
  //    [self stopEchoingMoveToRulers];
  // }

  if (isMoving)
	{
  _isHidingHandles = NO;

  [self setNeedsDisplayInRect:[DDSGraphic drawingBoundsOfGraphics:selGraphics]];
  if (didMove)
  {
  // Only if we really moved.
  // [[self undoManager] setActionName:NSLocalizedStringFromTable(@"Move", @"UndoStrings", @"Action name for moves.")];
  }
  }
  }
*/

-(void) resizeGraphic:(CPEvent)event
{
  var type = [event type];

  if (type == CPLeftMouseUp)
{
  // DDSL : We use resizeGraphic: to resize the newly created object or to resize ususal objects
  if (_creatingGraphic)
{
  // Did we really create a graphic? Don't check with !NSIsEmptyRect(createdGraphicBounds) because the bounds of
  // a perfectly horizontal or vertical line is "empty" but of course we want to let people create those.
  var createdGraphicBounds = [_creatingGraphic bounds];
  if (CPRectGetWidth(createdGraphicBounds) != 0.0 || CPRectGetHeight(createdGraphicBounds) != 0.0)
{
  // Select it.
  [self changeSelectionIndexes:[CPIndexSet indexSetWithIndex:0]];

  // The graphic wasn't sized to nothing during mouse tracking. Present its editing interface it if it's that kind of graphic (like Sketch's DDSTexts).
  // Invokers of the method we're in right now should have already cleared out _editingView.
  [self startEditingGraphic:_creatingGraphic];

  // Overwrite whatever undo action name was registered during all of that with a more specific one.
  // [undoManager setActionName:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Create %@", @"UndoStrings", @"Action name for newly created graphics. Class name is inserted at the substitution."), [[NSBundle mainBundle] localizedStringForKey:NSStringFromClass(graphicClass) value:@"" table:@"GraphicClassNames"]]];

  // Balance the invocation of -[NSUndoManager beginUndoGrouping] that we did up above.
  // [undoManager endUndoGrouping];
}

  [self setNeedsDisplay:YES];

  // Done.
  _creatingGraphic = nil;
}

  return;
}

	if (type == CPLeftMouseDragged)
{
  [self autoscroll:event];

  var handleLocation = [self convertPoint:[event locationInWindow] fromView:nil];

  if (_grid) {
    handleLocation = [_grid constrainedPoint:handleLocation];
  }

  _resizedHandle = [_resizedGraphic resizeByMovingHandle:_resizedHandle toPoint:handleLocation];

  [self setNeedsDisplay:YES];
}

	[CPApp setTarget:self selector:@selector(resizeGraphic:) forNextEventMatchingMask:CPLeftMouseDraggedMask | CPLeftMouseUpMask untilDate:nil inMode:nil dequeue:YES];
}

- (void)resizeGraphic:(DDSGraphic)graphic usingHandle:(int)handle withEvent:(CPEvent)event
{
//	debugger;
	_resizedGraphic = graphic;
	_resizedHandle = handle;

	[self resizeGraphic:event];

//	debugger;
}

- (CPIndexSet)indexesOfGraphicsIntersectingRect:(CPRect)rect
{
  var indexSetToReturn = [CPMutableIndexSet indexSet];
  var graphics = [self graphics];
  var graphicCount = [graphics count];
  for (var index = 0; index<graphicCount; index++)
{
  var graphic = [graphics objectAtIndex:index];
  if (CPRectIntersectsRect(rect, [graphic drawingBounds]))
{
  [indexSetToReturn addIndex:index];
}
}
  return indexSetToReturn;
}

- (void)createGraphicOfClass:(Class)graphicClass withEvent:(CPEvent)event
{
  // Before we invoke -[NSUndoManager beginUndoGrouping] turn off automatic per-event-loop group creation.
	// If we don't turn it off now, -beginUndoGrouping will actually create _two_ undo groups:
	// the top-level automatically-created one and then the nested one that we're explicitly creating.
	// When we invoke -undoNestedGroup down below, the automatically-created undo group will be left on the undo stack.
	// It will be ended automatically at the end of the event loop, which is good, and it will be empty, which is expected,
	// but it will be left on the undo stack so the user will see a useless undo action in the Edit menu, which is bad.
	// Is this a bug in NSUndoManager? Well it's certainly surprising that NSUndoManager isn't bright enough to ignore empty undo groups,
	// especially ones that it itself created automatically, so NSUndoManager could definitely use a little improvement here.

  // NSUndoManager *undoManager = [self undoManager];
  // BOOL undoManagerWasGroupingByEvent = [undoManager groupsByEvent];
  // [undoManager setGroupsByEvent:NO];

  // We will want to undo the creation of the graphic if the user sizes it to nothing, so create a new group for everything undoable that's going to happen during graphic creation.
  // [undoManager beginUndoGrouping];

  // Clear the selection.
  [self changeSelectionIndexes:[CPIndexSet indexSet]];

  // Where is the mouse pointer as graphic creation is starting? Should the location be constrained to the grid?
  var graphicOrigin = [self convertPoint:[event locationInWindow] fromView:nil];
  if (_grid) {
		graphicOrigin = [_grid constrainedPoint:graphicOrigin];
  }

  // Create the new graphic and set what little we know of its location.
  _creatingGraphic = [[graphicClass alloc] init];
  [_creatingGraphic setBounds:CPMakeRect(graphicOrigin.x, graphicOrigin.y, 0.0, 0.0)];

  // Add it to the set of graphics right away so that it will show up in other views of the same array of graphics as the user sizes it.
  var mutableGraphics = [self mutableGraphics];
  [mutableGraphics insertObject:_creatingGraphic atIndex:0];

  // Let the user size the new graphic until they let go of the mouse. Because different kinds of graphics have different kinds of handles,
	// first ask the graphic class what handle the user is dragging during this initial sizing.
  [self resizeGraphic:_creatingGraphic usingHandle:[graphicClass creationSizingHandle] withEvent:event];

/*
// Why don't we do [undoManager endUndoGrouping] here, once, instead of twice in the following paragraphs? Because of the [undoManager setGroupsByEvent:NO] game we're playing. If we invoke -[NSUndoManager setActionName:] down below after invoking [undoManager endUndoGrouping] there won't be any open undo group, and NSUndoManager will raise an exception. If we weren't playing the [undoManager setGroupsByEvent:NO] game then it would be OK to invoke -[NSUndoManager setActionName:] after invoking [undoManager endUndoGrouping] because the action name would apply to the top-level automatically-created undo group, which is fine.

// Did we really create a graphic? Don't check with !NSIsEmptyRect(createdGraphicBounds) because the bounds of
// a perfectly horizontal or vertical line is "empty" but of course we want to let people create those.
var createdGraphicBounds = [_creatingGraphic bounds];
if (CPRectGetWidth(createdGraphicBounds) != 0.0 || CPRectGetHeight(createdGraphicBounds) != 0.0)
{
// Select it.
[self changeSelectionIndexes:[CPIndexSet indexSetWithIndex:0]];

// The graphic wasn't sized to nothing during mouse tracking. Present its editing interface it if it's that kind of graphic (like Sketch's DDSTexts).
// Invokers of the method we're in right now should have already cleared out _editingView.
[self startEditingGraphic:_creatingGraphic];

// Overwrite whatever undo action name was registered during all of that with a more specific one.
// [undoManager setActionName:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Create %@", @"UndoStrings", @"Action name for newly created graphics. Class name is inserted at the substitution."), [[NSBundle mainBundle] localizedStringForKey:NSStringFromClass(graphicClass) value:@"" table:@"GraphicClassNames"]]];

// Balance the invocation of -[NSUndoManager beginUndoGrouping] that we did up above.
// [undoManager endUndoGrouping];

}
else
{

// Balance the invocation of -[NSUndoManager beginUndoGrouping] that we did up above.
//[undoManager endUndoGrouping];

// The graphic was sized to nothing during mouse tracking. Undo everything that was just done. Disable undo registration while undoing so that we don't create a spurious redo action.
//[undoManager disableUndoRegistration];
//[undoManager undoNestedGroup];
//[undoManager enableUndoRegistration];

}

// Balance the invocation of -[NSUndoManager setGroupsByEvent:] that we did up above. We're careful to restore the old value instead of merely invoking -setGroupsByEvent:YES because we don't know that the method we're in right now won't in the future be invoked by some other method that plays its own NSUndoManager games.
// [undoManager setGroupsByEvent:undoManagerWasGroupingByEvent];

// Done.
_creatingGraphic = nil;
*/

  }


- (void)marqueeSelectWithEvent:(CPEvent)event
{
	var type = [event type];

  if (type == CPLeftMouseUp)
{
  //debugger;
  // Schedule the drawing of the place wherew the rubber band isn't anymore.

  // We may need to increase the _marqueeSelectionBounds of some pixels
  //[self setNeedsDisplayInRect:_marqueeSelectionBounds];
  [self setNeedsDisplay:YES];

  // Make it not there.
  _marqueeSelectionBounds = CPRectMakeZero();

  _oldSelectionIndexes = nil;
  return;
}

  if (type == CPLeftMouseDown)
{
  _oldSelectionIndexes = [self selectionIndexes];

  _originalMouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
}
  else if (type == CPLeftMouseDragged)
{
  [self autoscroll:event];
  var currentMouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];

  // console.log("CPLeftMouseDragged");

  // Figure out a new a selection rectangle based on the mouse location.
  var newMarqueeSelectionBounds = CPMakeRect(Math.min(_originalMouseLocation.x, currentMouseLocation.x),
                                             Math.min(_originalMouseLocation.y, currentMouseLocation.y),
                                             Math.abs(currentMouseLocation.x - _originalMouseLocation.x),
                                             Math.abs(currentMouseLocation.y - _originalMouseLocation.y));
  if (! CPRectEqualToRect(newMarqueeSelectionBounds, _marqueeSelectionBounds))
{
  // Erase the old selection rectangle and draw the new one.
  [self setNeedsDisplayInRect:_marqueeSelectionBounds];
  _marqueeSelectionBounds = newMarqueeSelectionBounds;
  [self setNeedsDisplayInRect:_marqueeSelectionBounds];

  // Either select or deselect all of the graphics that intersect the selection rectangle.
  var indexesOfGraphicsInRubberBand = [self indexesOfGraphicsIntersectingRect:_marqueeSelectionBounds];
  var newSelectionIndexes = [_oldSelectionIndexes mutableCopy];
  for (var index = [indexesOfGraphicsInRubberBand firstIndex];
       index!=CPNotFound; index = [indexesOfGraphicsInRubberBand indexGreaterThanIndex:index])
{
  if ([newSelectionIndexes containsIndex:index])
{
  [newSelectionIndexes removeIndex:index];
}
  else
{
  [newSelectionIndexes addIndex:index];
}
}
  [self changeSelectionIndexes:newSelectionIndexes];
  [self setNeedsDisplay:YES];
}
}

  [CPApp setTarget:self selector:@selector(marqueeSelectWithEvent:) forNextEventMatchingMask:CPLeftMouseDraggedMask | CPLeftMouseUpMask untilDate:nil inMode:nil dequeue:YES];
}

/*
  - (void)Old_marqueeSelectWithEvent:(CPEvent)event
  {
  // Dequeue and handle mouse events until the user lets go of the mouse button.
  var oldSelectionIndexes = [self selectionIndexes];
  var originalMouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
  while ([event type] != CPLeftMouseUp)
	{
  debugger;
  event = [[self window] nextEventMatchingMask:(CPLeftMouseDraggedMask | CPLeftMouseUpMask)];
  [self autoscroll:event];
  var currentMouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];

  // Figure out a new a selection rectangle based on the mouse location.
  var newMarqueeSelectionBounds = CPMakeRect(fmin(originalMouseLocation.x, currentMouseLocation.x),
  fmin(originalMouseLocation.y, currentMouseLocation.y),
  fabs(currentMouseLocation.x - originalMouseLocation.x),
  fabs(currentMouseLocation.y - originalMouseLocation.y));
  if (! CPRectEqualToRect(newMarqueeSelectionBounds, _marqueeSelectionBounds))
  {
  // Erase the old selection rectangle and draw the new one.
  [self setNeedsDisplayInRect:_marqueeSelectionBounds];
  _marqueeSelectionBounds = newMarqueeSelectionBounds;
  [self setNeedsDisplayInRect:_marqueeSelectionBounds];

  // Either select or deselect all of the graphics that intersect the selection rectangle.
  var indexesOfGraphicsInRubberBand = [self indexesOfGraphicsIntersectingRect:_marqueeSelectionBounds];
  var newSelectionIndexes = [oldSelectionIndexes mutableCopy];
  for (var index = [indexesOfGraphicsInRubberBand firstIndex];
  index!=CPNotFound; index = [indexesOfGraphicsInRubberBand indexGreaterThanIndex:index])
  {
  if ([newSelectionIndexes containsIndex:index])
  {
  [newSelectionIndexes removeIndex:index];
  }
  else
  {
  [newSelectionIndexes addIndex:index];
  }
  }
  [self changeSelectionIndexes:newSelectionIndexes];
  }
  }

  // Schedule the drawing of the place wherew the rubber band isn't anymore.
  [self setNeedsDisplayInRect:_marqueeSelectionBounds];

  // Make it not there.
  _marqueeSelectionBounds = CPRectMakeZero();

  }
*/

/*
 * Since nextEventMatchingMask is not implemented, we have to write something equivalent
 *
// No. Just swallow mouse events until the user lets go of the mouse button. We don't even bother autoscrolling here.
while ([event type]!=CPLeftMouseUp) {
event = [[self window] nextEventMatchingMask:(CPLeftMouseDraggedMask | CPLeftMouseUpMask)];
}
*/

- (void)swallowMouseEvents:(CPEvent)event
{
  var type = [event type];

  if (type == CPLeftMouseUp)
{
//  console.log("swallowMouseEvents");
  return;
}

  [CPApp setTarget:self selector:@selector(swallowMouseEvents:) forNextEventMatchingMask:CPLeftMouseDraggedMask | CPLeftMouseUpMask untilDate:nil inMode:nil dequeue:YES];
}


- (void)selectAndTrackMouseWithEvent:(CPEvent)event
{
  // Are we changing the existing selection instead of setting a new one?
  var modifyingExistingSelection = ([event modifierFlags] & CPShiftKeyMask) ? YES : NO;

  // Has the user clicked on a graphic?
  var mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
  var dict = [self graphicUnderPoint:mouseLocation];
  var clickedGraphic = [dict objectForKey:@"graphic"];
	var clickedGraphicIndex = [[dict objectForKey:@"index"] intValue];
	var clickedGraphicIsSelected = [[dict objectForKey:@"isSelected"] boolValue];
	var clickedGraphicHandle = [[dict objectForKey:@"handle"] intValue];

	if (clickedGraphic != [CPNull null])
{
  // Clicking on a graphic knob takes precedence.
  if (clickedGraphicHandle != DDSGraphicNoHandle)
{
  // The user clicked on a graphic's handle. Let the user drag it around.
  [self resizeGraphic:clickedGraphic usingHandle:clickedGraphicHandle withEvent:event];
}
  else
{
  //debugger;

  // The user clicked on a graphic's contents. Update the selection.
  if (modifyingExistingSelection)
{
  if (clickedGraphicIsSelected)
{

  // Remove the graphic from the selection.
  var newSelectionIndexes = [[self selectionIndexes] mutableCopy];
  [newSelectionIndexes removeIndex:clickedGraphicIndex];
  [self changeSelectionIndexes:newSelectionIndexes];
  clickedGraphicIsSelected = NO;

}
  else
{

  // Add the graphic to the selection.
  var newSelectionIndexes = [[self selectionIndexes] mutableCopy];
  [newSelectionIndexes addIndex:clickedGraphicIndex];
  [self changeSelectionIndexes:newSelectionIndexes];
  clickedGraphicIsSelected = YES;

}

  [self setNeedsDisplay:YES];
}
  else
{

  // If the graphic wasn't selected before then it is now, and none of the rest are.
  if (!clickedGraphicIsSelected) {
    [self changeSelectionIndexes:[CPIndexSet indexSetWithIndex:clickedGraphicIndex]];
    clickedGraphicIsSelected = YES;

    [self setNeedsDisplay:YES];
  }

}

  // Is the graphic that the user has clicked on now selected?
  if (clickedGraphicIsSelected)
{
  // Yes. Let the user move all of the selected objects.
  [self moveSelectedGraphicsWithEvent:event];
}
  else
{
  // No. Just swallow mouse events until the user lets go of the mouse button. We don't even bother autoscrolling here.
  [self swallowMouseEvents:event];
}

}

}
	else
{
  // The user clicked somewhere other than on a graphic. Clear the selection, unless the user is holding down the shift key.
  if (! modifyingExistingSelection) {
    [self changeSelectionIndexes:[CPIndexSet indexSet]];
  }

  // The user clicked on a point where there is no graphic. Select and deselect graphics until the user lets go of the mouse button.
  [self marqueeSelectWithEvent:event];

//		[self setNeedsDisplay:YES];
}

}


// An override of the NSView method.
- (BOOL)acceptsFirstMouse:(CPEvent)event
{
  // In general we don't want to make people click once to activate the window then again to actually do something, but we do want to help users not accidentally throw away the current selection, if there is one.
  return [[self selectionIndexes] count] > 0 ? NO : YES;
}

- (void)mouseDown:(CPEvent)event
{
	// debugger;

  // If a graphic has been being edited (in Sketch DDSTexts are the only ones that are "editable" in this sense) then end editing.
  [self stopEditing];

  // Is a tool other than the Selection tool selected?
  var graphicClassToInstantiate = [[DDSToolPaletteController sharedToolPaletteController] currentGraphicClass];
  if (graphicClassToInstantiate)
{
  // Create a new graphic and then track to size it.
  [self createGraphicOfClass:graphicClassToInstantiate withEvent:event];
}
	else
{
  // Double-clicking with the selection tool always means "start editing," or "do nothing" if no editable graphic is double-clicked on.
  var doubleClickedGraphic = nil;
  if ([event clickCount] > 1)
{
  var mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
  var dict = [self graphicUnderPoint:mouseLocation];
  doubleClickedGraphic = [dict objectForKey:@"graphic"];
  if (doubleClickedGraphic != [CPNull null])
{
  [self startEditingGraphic:doubleClickedGraphic];
}
}

  if (!doubleClickedGraphic)
{
  // Update the selection and/or move graphics or resize graphics.
  [self selectAndTrackMouseWithEvent:event];
}

}
}


// An override of the NSResponder method. NSResponder's implementation would just forward the message to the next responder (an NSClipView, in Sketch's case) and our overrides like -delete: would never be invoked.
- (void)keyDown:(CPEvent)event
{
  // Ask the key binding manager to interpret the event for us.
  [self interpretKeyEvents:[CPArray arrayWithObject:event]];
}


- (IBAction)delete:(id)sender
{
  // Pretty simple.
  [[self mutableGraphics] removeObjectsAtIndexes:[self selectionIndexes]];
}

// Overrides of the NSResponder(NSStandardKeyBindingMethods) methods.
- (void)deleteBackward:(id)sender
{
  [self delete:sender];
}
- (void)deleteForward:(id)sender
{
  [self delete:sender];
}


- (void)invalidateHandlesOfGraphics:(CPArray)graphics
{
  var i, c = [graphics count];
  for (i=0; i<c; i++) {
		[self setNeedsDisplayInRect:[[graphics objectAtIndex:i] drawingBounds]];
  }
}

- (void)unhideHandlesForTimer:(CPTimer)timer
{
  _isHidingHandles = NO;
  _handleShowingTimer = nil;
  [self setNeedsDisplayInRect:[DDSGraphic drawingBoundsOfGraphics:[self selectedGraphics]]];
}

- (void)hideHandlesMomentarily
{
  [_handleShowingTimer invalidate];
  _handleShowingTimer = [CPTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(unhideHandlesForTimer:) userInfo:nil repeats:NO];
  _isHidingHandles = YES;
  [self setNeedsDisplayInRect:[DDSGraphic drawingBoundsOfGraphics:[self selectedGraphics]]];
}

- (void)moveSelectedGraphicsByX:(float)x y:(float)y
{
  // Don't do anything if there's nothing to do.
  var selectedGraphics = [self selectedGraphics];
  if ([selectedGraphics count] > 0) {
    // Don't draw and redraw the selection rectangles while the user holds an arrow key to autorepeat.
    [self hideHandlesMomentarily];

    // Move the selected graphics.
    [[DDSGraphic class] translateGraphics:selectedGraphics byX:x y:y];
  }
}


// Overrides of the NSResponder(NSStandardKeyBindingMethods) methods.
- (void)moveBackward:(id)sender {
  [self moveSelectedGraphicsByX:-1.0 y:0.0];
}

- (void)moveForward:(id)sender {
  [self moveSelectedGraphicsByX:1.0 y:0.0];
}

- (void)moveUp:(id)sender {
  [self moveSelectedGraphicsByX:0.0 y:-1.0];
}

- (void)moveDown:(id)sender {
  [self moveSelectedGraphicsByX:0.0 y:1.0];
}


// An override of the NSResponder method.
- (BOOL)acceptsFirstResponder
{
  // This view can of course handle lots of action messages.
  return YES;
}

// An override of the NSView method.
- (BOOL)isOpaque
{
  // Our override of -drawRect: always draws a background.
  return YES;
}

- (IBAction)makeJSON:(id)sender
{
  CPLog([self serializeToJSON]);
}

- (CPString)serializeToJSON
{
  // Create the object
  var viewJSONObject = { "id" : "slide",
                         "type" : "ClutterGroup"};

  viewJSONObject.children = [];

  for(var i=0; [[self graphics] count] > i; i++) {
    var sView = [[self graphics] objectAtIndex:i];
    var sViewJSON = [sView serializeToJSON];

    viewJSONObject.children[i] = sViewJSON;
  }

  var chCnt = 0;
  var chldrn = viewJSONObject.children;
  var viewRect = [self frame];
  for (chCnt = 0; chCnt < chldrn.length; chCnt++) {
    var graphic = chldrn[chCnt];
    var gWidth = graphic["width"];
    var gHeight = graphic["height"];
    var gXPosn = graphic["x"];
    var gYPosn = graphic["y"];

    graphic["width"] = [self convertPart:gWidth ofWhole:CPRectGetWidth(viewRect) toWhole:kRatioWidth];
    graphic["x"] = [self convertPart:gXPosn ofWhole:CPRectGetWidth(viewRect) toWhole:kRatioWidth];
    graphic["height"] = [self convertPart:gHeight ofWhole:CPRectGetHeight(viewRect) toWhole:kRatioHeight];
    graphic["y"] = [self convertPart:gYPosn ofWhole:CPRectGetHeight(viewRect) toWhole:kRatioHeight];
  }

  return [CPString JSONFromObject:viewJSONObject];
}

- (int)convertPart:(float)aPart ofWhole:(float)aWhole toWhole:(int)aNewWhole
{
  var crossMult = aPart * aNewWhole;
  var divOrigWhole = crossMult / aWhole;

  return Math.floor(divOrigWhole);
}

- (void)performDragOperation:(CPDraggingInfo)aSender
{
  var draggedImage = [CPKeyedUnarchiver unarchiveObjectWithData:[[aSender draggingPasteboard] dataForType:CPImagesPboardType]];

  var graphic = [[DDSRectangle alloc] init];
  [graphic setXPosition:100.0];
  [graphic setYPosition:100.0];
  [graphic setWidth:1000.0];
  [graphic setHeight:100.0];
  [graphic setIsDrawingFill:YES];
  [graphic setFillColor:[CPColor redColor]];
  [graphic setStrokeColor:[CPColor blueColor]];

  [[self graphics] addObject:graphic];
}

- (void)draggingEntered:(CPDraggingInfo)aSender
{

}

- (void)draggingExited:(CPDraggingInfo)aSender
{

}

@end
