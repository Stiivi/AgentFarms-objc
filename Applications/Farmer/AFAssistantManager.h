#import <Foundation/NSObject.h>

@class AFFarmMaster;
@class AFAssistantInfo;
@class NSMutableDictioary;

@interface AFAssistantManager:NSObject
{
    NSMutableDictioary *assistants;
}
+ sharedManager;
- (NSArray *)availableAssistants;
- (AFAssistantInfo *)infoForAssistant:(NSString *)name;
- (id)createAssistant:(NSString *)name forMaster:(AFFarmMaster *)master;
@end

