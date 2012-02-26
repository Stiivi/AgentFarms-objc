/* 2003 Jul 3 */

#import "AFFarmController.h"

@class NSBrowser;
@class NSTableView;
@class AFObjectDescription;
@class AFClassDescription;
@class NSMutableArray;
@class AFGraphView;
@class NSButton;

@interface CollectionBrowser:AFFarmController
{
    NSTableView         *tableView;
    NSMutableArray      *probes;
    NSButton            *previewSwitch;
    NSButton            *scaleSwitch;
    AFGraphView         *graphView;
    
    BOOL                 refreshOnFocus;
}
- (void)refresh:(id)sender;
@end
