/* 2003 Jul 17 */

#import <Foundation/NSObject.h>

@class NSBundle;
@class NSImage;
@class AFFarm;
@class NSDictionary;

@interface AFFarmerModule:NSObject
{
    AFFarm   *farm;

    NSBundle *bundle;

    NSString *name;

    NSString *iconName;
    NSImage  *icon;

    NSString *className;
    Class     controllerClass;
    id        controller;

    NSArray  *notifications;
}
- initWithFarm:(AFFarm *)aFarm
    dictionary:(NSDictionary *)dict 
        bundle:(NSBundle *)aBundle;

- (NSString *)identifier;
- (NSString *)name;
- (NSImage *)icon;
- (NSString *)className;
- (Class)controllerClass;
- (id)controller;
- (AFFarm *)farm;
@end
