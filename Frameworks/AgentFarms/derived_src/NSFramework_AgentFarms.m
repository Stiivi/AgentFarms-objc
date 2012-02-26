#include <Foundation/NSString.h>
@interface NSFramework_AgentFarms
+ (NSString *)frameworkEnv;
+ (NSString *)frameworkPath;
+ (NSString *)frameworkVersion;
+ (NSString **)frameworkClasses;
@end
@implementation NSFramework_AgentFarms
+ (NSString *)frameworkEnv { return @"GNUSTEP_LOCAL_ROOT"; }
+ (NSString *)frameworkPath { return nil; }
+ (NSString *)frameworkVersion { return @"A"; }
static NSString *allClasses[] = {@"AFAgentAction", @"AFAttributeDescription", @"AFClassDescription", @"AFCollectionDescription", @"AFDistantSimulator", @"AFEnvironment", @"AFGraphInfo", @"AFGrid", @"AFGridPoint", @"AFLattice", @"AFModel", @"AFModelBundle", @"AFNetwork", @"AFNetworkLink", @"AFNumberCollection", @"AFObjectConnection", @"AFObjectDescription", @"AFObjectPrototype", @"AFProbe", @"AFProbeSpecification", @"AFProperty", @"AFPropertyList", @"AFRelationshipDescription", @"AFSimulation", @"AFSimulator", @"AFResourceManager", NULL};
+ (NSString **)frameworkClasses { return allClasses; }
@end
