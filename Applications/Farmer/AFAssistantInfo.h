/* 2003 Jul 17 */

#import <Foundation/NSObject.h>

@class NSBundle;
@class NSImage;
@class NSDictionary;

@interface AFAssistantInfo:NSObject
{
    NSBundle *bundle;

    NSString *name;

    NSString *iconName;
    NSImage  *icon;

    NSString *className;
    Class     controllerClass;
    id        controller;

    NSArray  *notifications;

    BOOL      visibleAtLaunchTime;
    BOOL      instantiateOnCreate;
    int       rank; /* Value from 0 - 100 for ordering, 0-10, 90-100 are reserved */
}
- initWithDictionary:(NSDictionary *)dict 
              bundle:(NSBundle *)aBundle;

- (NSString *)identifier;
- (NSString *)name;
- (NSImage *)icon;
- (NSString *)className;
- (Class)assistantClass;
- (NSArray *)observedNotifications;

- (int)rank;

- (BOOL)visibleAtLaunchTime;
- (BOOL)instantiateOnCreate;
@end
