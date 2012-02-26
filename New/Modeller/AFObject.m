/**/

#import "AFObject.h"

#import <Foundation/NSString.h>
#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSArray.h>


@implementation AFObject:NSObject
+ presenterClass
{
    NSString *className;
    className = [[self className] stringByAppendingString:@"Presenter"];
    return NSClassFromString(className);
}
- (NSArray *)outlets
{
    NSArray *array;
    
    array = [NSArray arrayWithObjects:@"One", @"Two", @"Three", nil];
    
    return array;
}
@end

