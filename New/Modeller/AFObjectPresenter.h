#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>

@interface AFObjectPresenter:NSObject
{
    id presentedObject;
    BOOL isSelected;
}
- (id)presentedObject;
- (void)setPresentedObject:(id)anObject;
- (void)drawInRect:(NSRect)rect;
@end

