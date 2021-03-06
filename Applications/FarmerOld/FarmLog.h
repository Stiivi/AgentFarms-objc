/* 2003 Jul 3 */

#import "WindowController.h"

@class NSTextView;

@interface FarmLog:WindowController
{
    NSTextView *textView;
    BOOL        showsDate;
}
- (void)log:(NSString*)format,...;
- (void)logError:(NSString*)format,...;
- (void)logWarning:(NSString*)format,...;
- (void)clear:(id)sender;

- (void)log:(NSString*)format arguments: (va_list)args;
- (void)logError:(NSString*)format arguments: (va_list)args;
- (void)logWarning:(NSString*)format arguments: (va_list)args;

- (void)setShowsDate:(BOOL)flag;
- (BOOL)showsDate;
@end
