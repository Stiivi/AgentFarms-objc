/* NSArray+additions 

    Written by: Stefan Urbanek
    Date: 2002 Oct 9
*/


#import "NSArray+additions.h"

@implementation NSArray(AFAdditions)
- (id)randomObject
{
    int count = [self count];
    
    if(count)
    {
        return [self objectAtIndex:rand() % count];
    }
    else
    {
        return nil;
    }
}
@end
