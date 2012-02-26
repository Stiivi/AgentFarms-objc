#import "AFFarmProject.h"

#import <Foundation/NSString.h>
#import "AFClass.h"

@implementation AFFarmProject
- (id)init
{
    NSArray *headers;
    AFClass *class;
    
    self = [super init];
    
    /* FIXME: remove this */    
    headers = [NSArray arrayWithObject:@"Foundation/NSObject.h"];
    
    class = [AFClass emptyClassWithName:@"World"];
    [class setInterfaceHeaders:headers];
    [self addClass:class];
    
    class = [AFClass emptyClassWithName:@"Agent"];
    [class setInterfaceHeaders:headers];
    [self addClass:class];
    
    return self;
}
- (NSString *)makefileType
{
    return @"BUNDLE";  
}
- (NSString *)makefileName
{
    return @"bundle.make";
}
- (NSString *)resultFileName
{
    return [[self name] stringByAppendingPathExtension:@"bundle"];
}
- (BOOL)renameClass:(AFClass *)class toName:(NSString *)newName
{
    [class setName:newName];
    [self _postProjectNotificationName:DKProjectClassesChangedNotification];
    return YES;
}
@end
