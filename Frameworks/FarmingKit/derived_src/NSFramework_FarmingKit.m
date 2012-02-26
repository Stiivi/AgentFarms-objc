#include <Foundation/NSString.h>
@interface NSFramework_FarmingKit
+ (NSString *)frameworkEnv;
+ (NSString *)frameworkPath;
+ (NSString *)frameworkVersion;
+ (NSString **)frameworkClasses;
@end
@implementation NSFramework_FarmingKit
+ (NSString *)frameworkEnv { return @"GNUSTEP_LOCAL_ROOT"; }
+ (NSString *)frameworkPath { return nil; }
+ (NSString *)frameworkVersion { return @"A"; }
static NSString *allClasses[] = {@"AFButtonRow", @"AFButtonRowCell", @"AFColorMap", @"AFFarmStore", @"AFPoint", @"AFRect", @"AFSize", @"AFGraph", @"AFGraphElement", @"AFGraphView", @"AFGraphWindow", @"AFLatticeView", @"AFSequenceGraphElement", NULL};
+ (NSString **)frameworkClasses { return allClasses; }
@end
