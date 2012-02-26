/* 2003 Jul 23 */

#import <Foundation/NSObject.h>

@interface AFProbeSpecification:NSObject
{
    id        objectReference;
    NSString *propertyIdentifier;
    NSString *objectClassName;
}
+ specificationWithObjectReference:(id)aReference propertyIdentifier:(NSString *)aName;
- initWithObjectReference:(id)aReference propertyIdentifier:(NSString *)aName;

- (void)setObjectClassName:(NSString*)aString;
- (NSString *)objectClassName;

- (id)objectReference;
- (NSString *)propertyIdentifier;
@end
