/** AFProbe

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 Nov 27
    
    This file is part of the AgentFarms project.
 
    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.
 
    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.
 
    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 */

#import "AFProbe.h"
#import "AFEnvironment.h"
#import "AFProbeSpecification.h"
#import "AFNumberCollection.h"

#import <Foundation/NSException.h>
#import <Foundation/NSKeyValueCoding.h>
#import <Foundation/NSString.h>


@implementation AFProbe:NSObject
+ probeWithTemplate:(AFProbeSpecification *)template
{
    return AUTORELEASE([[self alloc] initWithTemplate:template]);
}
+ probeWithPropertyName:(NSString *)propName objectReference:(id)ref
{
    return AUTORELEASE([[self alloc] initWithPropertyName:propName
                                         objectReference:ref]);
}
- initWithTemplate:(AFProbeSpecification *)template
{
    self = [super init];
    propertyIdentifier = RETAIN([template propertyIdentifier]);
    objectReference = RETAIN([template objectReference]);
    return self;
}
- initWithPropertyName:(NSString *)propName objectReference:(id)ref
{
    self = [super init];
    propertyIdentifier = RETAIN(propName);
    objectReference = RETAIN(ref);
    return self;
}

- (void)dealloc
{
    RELEASE(propertyIdentifier);
    RELEASE(objectReference);
    RELEASE(collection);
    RELEASE(target);
    [super dealloc];
}

/** Connects the probe to the objcet with given reference in the scope of 
    a simuilation <var>aSimulation</var>*/
- (BOOL)connectInEnvironment:(AFEnvironment *)anEnvironment
{
    if(target)
    {
        [NSException raise:@"AFProbeException"
                     format:@"Probe %@ is already connected.", propertyIdentifier];
        return NO;
    }

    target = [anEnvironment objectWithReference:objectReference];
    
    if(!target)
    {
        NSLog(@"Unable to connect probe %@. No object with reference %@", 
                propertyIdentifier, objectReference);
        return NO;                
    }
    
    RETAIN(target);

    return YES;
}
/** Disconnects from probed target. You should call this method when target 
    object is no more interesting for the simulation and it is about to be 
    deallocated. */
- (void)disconnect
{
    DESTROY(target);
}

/** Return YES if probe is connected to its target */
- (BOOL)isConnected
{
    return (target != nil);
}

/** Get double value for probed property */
- (double)doubleValue
{
    // NSLog(@"--> probing for %@ in %@", propertyIdentifier, [target className]);
    return [[target valueForKey:propertyIdentifier] doubleValue];
}
- (id)target
{
    return target;
}
- (id)objectReference
{
    return objectReference;
}
- (NSString *)propertyIdentifier
{
    return propertyIdentifier;
}
- (BOOL)isEqual:(id)anObject
{
    if(anObject == self)
        return YES;
    if([anObject class] != isa)
        return NO;
        
    return [[anObject objectReference] isEqual:objectReference] &&
                [[anObject propertyIdentifier] isEqual:propertyIdentifier];
}
- (NSString *)description
{
    NSString *str;
    
    str = [NSString stringWithFormat:@"<%@ %@(%@):%@>",
            [self className],
            objectReference,
            target,
            propertyIdentifier];
    return str;
}
- (void)setObjectReference:(id)aReference
{
    if(target)
    {
        [NSException raise:@"AFProbeException"
                     format:@"Should not set object reference of connected probe."];
        return; 
    }
    
    ASSIGN(objectReference,aReference);
}
- (AFProbeSpecification *)probeSpecification
{
    AFProbeSpecification *spec;
    
    spec = [AFProbeSpecification specificationWithObjectReference:objectReference
                                        propertyIdentifier:propertyIdentifier];
    return spec;
}

/** Associate a collection with the probe. After probing, a value will be collected. */
- (AFNumberCollection *)collection
{
    return collection;
}
- (void)setCollection:(AFNumberCollection *)aCol
{
    ASSIGN(collection,aCol);
}
- (void)collect
{
    [collection collectNumber:[self doubleValue]];
}
@end
