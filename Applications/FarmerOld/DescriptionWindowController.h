/* 2003 Jul 3 */

#import "WindowController.h"

@class NSTextView;

@interface DescriptionWindowController:WindowController
{
    NSTextView *textView;
}
- (void)setDescriptionText:(id)aText;
- (id)descriptionText;
@end
