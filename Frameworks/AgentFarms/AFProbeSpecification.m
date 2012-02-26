/* 2003 Jul 23 */

#import "AFProbeSpecification.h"

#import <Foundation/NSCoder.h>
#import <Foundation/NSString.h>

@implementation AFProbeSpecification
+ specificationWithObjectReference:(id)aReference propertyIdentifier:(NSString *)aName
{
    return AUTORELEASE([[self alloc] initWithObjectReference:aReference propertyIdentifier:aName]);
}
- initWithObjectReference:(id)aReference propertyIdentifier:(NSString *)aName
{
    self = [super init];
    
    propertyIdentifier = RETAIN(aName);
    objectReference = RETAIN(aReference);
    
    return self;
}
- (id)objectReference
{
    return objectReference;
}
- (NSString *)propertyIdentifier
{
    return propertyIdentifier;
}
- (void)setObjectClassName:(NSString*)aString
{
    ASSIGN(objectClassName, aString);
}
- (NSString *)objectClassName
{
    return objectClassName;
}

- (BOOL)isEqual:(AFProbeSpecification *)spec
{
    if(spec == self)
        return YES;
    if([spec class] != isa)
        return NO;
        
    return [[spec objectReference] isEqual:objectReference] &&
                [[spec propertyIdentifier] isEqual:propertyIdentifier];
}

/* Serialisation */
- (void)encodeWithCoder:(NSCoder *)coder
{
    // [super encodeWithCoder: coder];

    [coder encodeObject:objectReference];
    [coder encodeObject:propertyIdentifier];
    [coder encodeObject:objectClassName];
}
- initWithCoder:(NSCoder *)decoder
{
    self = [super init];// [super initWithCoder: decoder];
    
    [decoder decodeValueOfObjCType: @encode(id) at: &objectReference];
    [decoder decodeValueOfObjCType: @encode(id) at: &propertyIdentifier];
    [decoder decodeValueOfObjCType: @encode(id) at: &objectClassName];

    return self;
}
@end
