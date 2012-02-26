/* 2003 Jul 3 */

#import "AFFarmController.h"

@class NSTextView;

@interface DescriptionWindowController:AFFarmController
{
    NSTextView *textView;
}
- (void)setDescriptionText:(id)aText;
- (id)descriptionText;
@end
