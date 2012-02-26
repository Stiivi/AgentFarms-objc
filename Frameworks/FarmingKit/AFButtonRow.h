/* 2003 Jul 3 */

#import <AppKit/NSView.h>

@class NSMatrix;
@class NSScrollView;

@interface AFButtonRow:NSView
{
    NSScrollView *scrollView;
    NSMatrix     *matrix;   
    id           *delegate; 
}
- (void)addButtonWithTitle:(NSString *)title
                     image:(NSImage *)image
         representedObject:(id)object;
- (void)removeObjectWithIdentifier:(NSString *)identifier;
- (void)selectedObject;
@end
