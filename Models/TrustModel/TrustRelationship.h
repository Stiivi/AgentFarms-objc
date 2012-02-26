#import <Foundation/NSObject.h>

@class Memory;

@interface TrustRelationship:NSObject
{
    Memory *selfMemory;
    Memory *otherMemory;
    BOOL    isNew;
}
- (double)trustToOther;
- (double)trustFromOther;
- (BOOL)isNew;
@end
