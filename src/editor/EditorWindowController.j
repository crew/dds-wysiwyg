/* ***** BEGIN LICENCE BLOCK *****
 *
 * The Initial Developer of the Original Code is
 * The Northeastern University CCIS Volunteer Systems Group
 *
 * Contributor(s):
 *  Jeff Dlouhy <jdlouhy@ccs.neu.edu>
 *
 * ***** END LICENCE BLOCK ***** */

@import <AppKit/CPWindowController.j>
@import <AppKit/CPColorPanel.j>
@import <Foundation/CPURLConnection.j>

@import "PhotoPanel.j"
@import "../slide/SlideView.j"
@import "../slide/DraggableImage.j"

const kBigPictureBaseURL = "http://bigpicture.ccs.neu.edu/";

@implementation EditorWindowController : CPWindowController
{
  CPPanel mInspectorPanel;
  CPPanel mMediaBrowser;

  CPURLConnection mPostConnection;
  CPURLConnection mGetAssetConnection;
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
  [[CPColorPanel sharedColorPanel] orderFront:self];
  var colorPicker = [CPColorPanel sharedColorPanel];

//   var currentSlideView = [[self document] documentView];
//   [colorPicker setTarget:currentSlideView];
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

- (void)spitOutViewXML:(id)sender
{
  CPLog([self subviewsToXML]);
}

- (NSString)subviewsToXML
{
  var currentSlideView = [[self document] documentView];

  slideSubviews = [currentSlideView subviews];
//  return [self generateXMLForDraggableImage:[[slideSubviews objectAtIndex:0] draggableImage]];
  for (var subview in slideSubviews) {
    //return [self generateXMLForImage:subview];
    //  CPLog([self DumpObjectIndented:subview indent:""]);
    CPLog([subview JSON]);
  }
  return "";
}

-(NSString)DumpObjectIndented:(id)obj indent:(id)indent
{
  var result = "";
  if (indent == null) indent = "";

  for (var property in obj)
  {
    var value = obj[property];
    if (typeof value == 'string')
      value = "'" + value + "'";
    else if (typeof value == 'object')
    {
      if (value instanceof Array)
      {
        // Just let JS convert the Array to a string!
        value = "[ " + value + " ]";
      }
      else
      {
        // Recursive dump
        // (replace "  " by "\t" or something else if you prefer)
        var od = [self DumpObjectIndented:value indent:(indent + "  ")];
        // If you like { on the same line as the key
        //value = "{\n" + od + "\n" + indent + "}";
        // If you prefer { and } to be aligned
        value = "\n" + indent + "{\n" + od + "\n" + indent + "}";
      }
    }
    result += indent + "'" + property + "' : " + value + ",\n";
  }
  return result.replace(/,\n$/, "");
}

- (NSString)generateXMLForDraggableImage:(DraggableImage)aDraggableImage
{
  var filename = [[aDraggableImage image] filename],
    xPos = CGRectGetMinX([aDraggableImage frame]),
    yPos = CGRectGetMinY([aDraggableImage frame]),
    width = CGRectGetMaxX([aDraggableImage frame]),
    height = CGRectGetMaxY([aDraggableImage frame]);

  return "<image x=\"" + xPos + "\" y=\"" + yPos +"\" width=\"" + width + "\" height=\"" + height + "\">" + filename + "</image>";
}

- (void)sendDummyJSON
{
  var request = [CPURLRequest requestWithURL: kBigPictureBaseURL+"dds/slide/57/assets/foo"];

  [request setHTTPMethod: "POST"];
  [request setHTTPBody:"Jesse The Body Ventura!"];

  mPostConnection = [CPURLConnection connectionWithRequest:request delegate:self];

  var request_2 = [CPURLRequest requestWithURL:kBigPictureBaseURL+"dds/slide/57/assets/22"];

  [request setHTTPMethod: "GET"];

  mGetAssetConnection = [CPURLConnection connectionWithRequest:request_2 delegate:self];
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)data
{
    //get a javascript object from the json response
    var result = CPJSObjectCreateWithJSON(data);

    //check if we're talking about the delete connection
    if (aConnection == mGetAssetConnection)
      CPLog(result);

    //clear out this connection's reference
    [self clearConnection:aConnection];
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPError)anError
{
    if (aConnection == mPostConnection)
        alert("There was an error adding this asset. Please try again in a moment.");

    [self clearConnection:aConnection];
}

- (void)clearConnection:(CPURLConnection)aConnection
{
    //we no longer need to hold on to a reference to this connection
    if (aConnection == mPostConnection)
        mPostConnection = nil;
}

@end
