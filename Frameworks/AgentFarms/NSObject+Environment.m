/* 2003 Jul 27 */

#import "NSObject+Environment.h"

#import <Foundation/NSDictionary.h>
#import <Foundation/NSThread.h>

@implementation NSObject(AFEnvironment)
/** Returns an envrionment where object exists. */
- (id)environment
{
    NSDictionary *dict;

    dict = [[NSThread currentThread] threadDictionary];
    
    return [dict objectForKey:@"SimulationEnvironment"];
}
@end
