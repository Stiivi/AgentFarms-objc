/*2002 Oct 9 */

#import "NSDictionary+additions.h"

@implementation NSMutableDictionary(AFAdditions)
- (id)getAndRemoveObjectForKey:(id)key;
{
    id object;
    
    object = [self objectForKey:key];
    
    if(object)
    {
        [self removeObjectForKey:key];
    }
    
    return object;
}
@end
