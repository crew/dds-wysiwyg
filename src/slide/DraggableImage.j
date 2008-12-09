/* ***** BEGIN LICENCE BLOCK *****
 *
 * The Initial Developer of the Original Code is
 * The Northeastern University CCIS Volunteer Systems Group
 *
 * Parts of this code are from Francisco Tolmasky's
 * FloorPlanView demo.
 *
 * Contributor(s):
 *  Jeff Dlouhy <jdlouhy@ccs.neu.edu>
 *
 * ***** END LICENCE BLOCK ***** */

@import <AppKit/CPView.j>
@import <Foundation/CPDictionary.j>
@import "DraggableView.j"

DraggableImageDragType = "DraggableImageDragType";

@implementation DraggableImage : DraggableView
{
  CPString    name;
  CPImage     image;

  float       rotationRadians;
  float       editedRotationRadians;

  CGPoint     dragLocation;
  CGPoint     editedOrigin;
}

- (id)initWithName:(CPString)aName image:(CPImage)anImage
{
  var imageSize = [anImage size],
    imageWidth = imageSize.width,
    imageHeight = imageSize.height;

  self = [super initWithFrame:CGRectMake(0.0, 0.0, imageWidth, imageHeight)];

  if (self) {
    name = aName;
    image = anImage;

    [self setPostsFrameChangedNotifications:YES];
  }

  return self;
}

- (CPString)name
{
  return name;
}

-(void)imageDidLoad:(CPImage)anImage
{
  var imageSize = [anImage size],
    imageWidth = imageSize.width,
    imageHeight = imageSize.height;

  [self setFrame:CGRectMake(0.0, 0.0, imageWidth, imageHeight)];
}

- (CPImage)image
{
  return image;
}

- (void)willBeginLiveRotation
{
  editedRotationRadians = rotationRadians;
}

- (void)didEndLiveRotation
{
  [self setEditedRotationRadians:rotationRadians];
}

- (void)setRotationRadians:(float)radians
{
  rotationRadians = radians;

//   var editorView = [TransformImageView sharedTransformImageView];

//   if ([editorView draggableImage] == self && [editorView rotationRadians] != radians)
//     [editorView updateFromDraggableImage];

  [self setNeedsDisplay:YES];
}

- (void)setEditedRotationRadians:(float)radians
{
  if (editedRotationRadians == radians)
    return;

  [[[self window] undoManager] registerUndoWithTarget:self selector:@selector(setEditedRotationRadians:) object:editedRotationRadians];

  [self setRotationRadians:radians];

  editedRotationRadians = radians;
}

- (float)rotationRadians
{
  return rotationRadians;
}

- (void)mouseDown:(CPEvent)anEvent
{
  editedOrigin = [self frame].origin;
  dragLocation = [anEvent locationInWindow];
}

- (void)mouseDragged:(CPEvent)anEvent
{
  var location = [anEvent locationInWindow],
    origin = [self frame].origin;

  [self setFrameOrigin:CGPointMake(origin.x + location.x - dragLocation.x, origin.y + location.y - dragLocation.y)];

  dragLocation = location;
}

- (void)mouseUp:(CPEvent)anEvent
{
  [self setEditedOrigin:[self frame].origin];
}

- (void)setEditedOrigin:(CGPoint)aPoint
{
  if (CGPointEqualToPoint(editedOrigin, aPoint))
    return;

  [[[self window] undoManager] registerUndoWithTarget:self selector:@selector(setEditedOrigin:) object:editedOrigin];

  editedOrigin = aPoint;

  [self setFrameOrigin:aPoint];
}

// This is just for details... hit test as if we were rotated.  We'd get this for free if we used CALayer instead of CPView.
- (id)hitTest:(CGPoint)aPoint
{
  var radius = CGRectGetWidth([self bounds]) / 2.0,
    imageSize = [image size],
    imageWidth_2 = imageSize.width / 2,
    imageHeight_2 = imageSize.height / 2;

  point = CGPointMakeCopy(aPoint);

  point.x -= CGRectGetMinX([self frame]) + radius - imageWidth_2;
  point.y -= CGRectGetMinY([self frame]) +  radius - imageHeight_2;

  point = CGPointApplyAffineTransform(point, CGAffineTransformInvert(CGAffineTransformConcat(CGAffineTransformMakeTranslation(-imageWidth_2, -imageHeight_2), CGAffineTransformConcat(CGAffineTransformMakeRotation(rotationRadians), CGAffineTransformMakeTranslation(imageWidth_2, imageHeight_2)))));

  if (CGRectContainsPoint(CGRectMake(0.0, 0.0, imageSize.width, imageSize.height), point))
    return self;

  return nil;
}

- (void)drawRect:(CGRect)aRect
{
//  [super drawHandlesInView:self];

  if ([image loadStatus] != CPImageLoadStatusCompleted) {
    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setNeedsDisplay:)
                                                 name:CPImageDidLoadNotification
                                               object:image];
    return;
  }

  var context = [[CPGraphicsContext currentContext] graphicsPort],
    bounds = [self bounds],
    imageSize = [image size];
//  CPLog([self JSON]);
//  CGContextTranslateCTM(context, FLOOR(CGRectGetWidth(bounds) / 2.0), FLOOR(CGRectGetHeight(bounds) / 2.0));
//  CGContextRotateCTM(context, rotationRadians);
  CGContextDrawImage(context, CGRectInset(bounds, 5, 5), image);
}

- (id)initWithCoder:(CPCoder)aCoder
{
  self = [super initWithCoder:aCoder];

  if (self)
{
  name = [aCoder decodeObjectForKey:"name"];
  image = [aCoder decodeObjectForKey:"image"];

  [self setPostsFrameChangedNotifications:YES];
}

  return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
  [super encodeWithCoder:aCoder];

  [aCoder encodeObject:name forKey:"name"];
  [aCoder encodeObject:image forKey:"image"];
}

- (NSString)JSON
{
  var id = "\"id\" : \"" + [[[self image] filename] lastPathComponent] +"\",";
  var type = "\"type\" : \"ClutterTexture\",";
  var x = "\"x\" : "+ ((CGRectGetMinX([self frame]) / CGRectGetMaxX([self frame])) * 16)+",";
  var y = "\"y\" : "+ ((CGRectGetMinY([self frame]) / CGRectGetMaxY([self frame])) * 9)+",";
  var width = "\"width\" : "+ (CGRectGetMaxX([self frame]) / CGRectGetMaxX([[self superview] frame])) +",";
  var height = "\"height\" : "+ CGRectGetMaxY([self frame])+",";
  var visible = "\"visible\" : true,";
  return "{ " + id + type + x + y + width + height + visible + "}";
}

@end
