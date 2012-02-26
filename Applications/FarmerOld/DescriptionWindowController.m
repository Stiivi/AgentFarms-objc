/* 2003 Jul 3 */

#import "DescriptionWindowController.h"

#import <AppKit/NSWindow.h>

#import <AppKit/NSAttributedString.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSTextView.h>
#import <AppKit/NSWindow.h>

@implementation DescriptionWindowController
- (NSString *)resourceName
{
    return @"DescriptionWindow";
}
- (void)setDescriptionText:(id)aText
{
    [textView setString:nil];
    [textView insertText:aText];
}
- (id)descriptionText
{
    return [textView text];
}
@end
