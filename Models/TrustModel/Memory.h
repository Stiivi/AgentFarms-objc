/* TrustModelWorld

    Written by: @@AUTHOR@@
    Date: @@DATE@@
    
 */

#import <Foundation/NSObject.h>

@class AFAgentAction;

@interface Memory:NSObject
{
    int *mem;
    int count;
    int capacity;
}
+ memoryWithCapacity:(int)capa;
- initWithCapacity:(int)capa;
- (void)rememberAction:(AFAgentAction *)action;
- (double)averageTrust;
@end;
