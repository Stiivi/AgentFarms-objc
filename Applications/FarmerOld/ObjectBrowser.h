/* 2003 Jul 3 */

#import "WindowController.h"

@class NSBrowser;
@class NSTableView;
@class AFObjectDescription;
@class AFClassDescription;
@class NSMutableArray;

@interface ObjectBrowser:WindowController
{
    NSBrowser           *browser;
    NSTableView         *tableView;

    BOOL                 refreshOnFocus;
}
- (void)refresh:(id)sender;
@end
