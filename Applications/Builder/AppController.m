#import "FarmBuilder.h"

#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>

#import "FarmProjectController.h"

#import <AppKit/NSDocumentController.h>

@implementation FarmBuilder
- init
{
    [super init];
    
    projectControllers = [[NSMutableArray alloc] init];
    
    return self;
}
- (void)dealloc
{
    RELEASE(projectControllers);
    [super dealloc];
}
- (void)applicationDidFinishLaunching:(id)notif
{
   [[NSDocumentController sharedDocumentController] newDocument:nil];
}
@end
