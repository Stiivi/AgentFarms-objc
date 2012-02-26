/* TrustModelWorld

    Written by: @@AUTHOR@@
    Date: 2003 Oct 5
    
 */

#import <Foundation/NSObject.h>

@class TrustRelationship;
@class TrustAgent;
@class AFAgentAction;
#import "Actions.h"

@interface TrustCouple:NSObject
{
    TrustRelationship *leftRelationship;
    TrustRelationship *rightRelationship;
    TrustAgent        *leftAgent;
    TrustAgent        *rightAgent;
}
- initWithLeftAgent:(TrustAgent *)lAgent rightAgent:(TrustAgent *)rAgent;
- leftRelationship;
- rightRelationship;
- leftAgent;
- rightAgent;
- (void)rememberLeftAction:(AFAgentAction *)leftAction 
               rightAction:(AFAgentAction *)rightAction;

@end
