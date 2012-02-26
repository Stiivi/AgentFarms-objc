/* 2003 Jul 3 */

#import "WindowController.h"

@class NSBrowser;
@class NSTableView;
@class AFObjectPrototype;
@class AFClassDescription;

@interface PrototypesBrowser:WindowController
{
    NSBrowser   *browser;
    NSTableView *tableView;
    
    NSArray     *prototypeNames;
    
    AFObjectPrototype        *prototype;
    AFClassDescription *classDescription;
}
- (void)refresh:(id)sender;
@end
