/**  AFFarmStore

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2002 Jul 18

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

#import "AFSimulatorManager.h"

#import "../AFExterns.h"
#import "AFSimulator.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSConnection.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSDistantObject.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSException.h>

static AFSimulatorManager *defaultManager = nil;

@interface AFSimulatorReference:NSObject<NSCoding>
@end

@implementation AFSimulatorReference
- (NSString *)description
{
    return @"Unknown simulator";
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder: aCoder];
    /* nothing here */
}

- initWithCoder:(NSCoder *)aDecoder
{
    [super initWithCoder: aDecoder];
    /* nothing here */
    return self;
}
@end

/***************************************************************************
    AFDistantSimulatorReference
***************************************************************************/

@interface AFDistantSimulatorReference:AFSimulatorReference
{
    NSString *name;
    NSString *host;
}
- initWithName:(NSString *)aName host:(NSString *)aHost;
- (NSString *)objectName;
- (NSString *)host;
@end

@implementation AFDistantSimulatorReference
+ referenceWithName:(NSString *)aName host:(NSString *)aHost
{
    AFDistantSimulatorReference *ref;
    
    ref = [[AFDistantSimulatorReference alloc] 
                                initWithName:aName host:aHost];

    return AUTORELEASE(ref);
}

- initWithName:(NSString *)aName host:(NSString *)aHost
{
    [super init];

    name = RETAIN(aName);
    host = RETAIN(aHost);
    
    return self;
}
- (void)dealloc
{
    RELEASE(name);
    RELEASE(host);
    [super dealloc];
}
- copyWithZone:(NSZone *)zone
{
    AFDistantSimulatorReference *ref = [AFDistantSimulatorReference allocWithZone:zone];

    return [ref initWithName:name host:host];
}
- (NSString *)objectName
{
    return name;
}
- (NSString *)host
{
    return host;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@@%@", name, host];
}
- (BOOL)isEqual:(id)anObject
{
    if(self == anObject)
    {
        return YES;
    }
    else if( ![[anObject class] isEqual:[AFDistantSimulatorReference class]] )
    {
        return NO;
    }
    else if( [name isEqualToString: [anObject objectName]] )
    {
        if( [host isEqualToString:[anObject host]] 
            || ((host == nil || [host isEqualToString:@""]) 
                && ([anObject host] == nil 
                    || [[anObject host] isEqualToString:@""]) ) )
        {                
            return YES;
        }
    }
    
    return NO;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder: aCoder];
    [aCoder encodeObject: name];
    [aCoder encodeObject: host];
}

- initWithCoder:(NSCoder *)aDecoder
{
    [super initWithCoder: aDecoder];
    [aDecoder decodeValueOfObjCType: @encode(id) at: &name];
    [aDecoder decodeValueOfObjCType: @encode(id) at: &host];
    return self;
}
@end

/***************************************************************************
    AFDistantSimulator
***************************************************************************/
#if 0
@interface AFDistantSimulator:NSObject<AFSimulator>
{
    AFSimulator *simulator;
    NSString    *identifier;
}
@end

@implementation AFDistantSimulator
- initWithSimulator:(AFSimulator *)stor
{
    [super init];
    simulator = RETAIN(stor);
    return self;
}
- (BOOL)retainFarmWithIdentifier:(NSString *)ident
{
    ASSIGN(identifier,ident);

    return [simulator retainFarmWithIdentifier:ident];
}
- (void)dealloc
{
    RELEASE(identifier);
    RELEASE(simulator);
    [super dealloc];
}
- (void)forwardInvocation:(NSInvocation *)invocation
{
    if(![simulator isRetainedFarmWithIdentifier:identifier])
    {
        [NSException raise:AFGenericException
                     format:@"Simulator is retainet by another farm"];
    }
    
    [invocation setTarget:simulator];
    [invocation invoke];
}
@end
#endif
/***************************************************************************
    AFSimulatorManager
***************************************************************************/

@implementation AFSimulatorManager
+ localManager
{
    if(!defaultManager)
    {
        defaultManager = [[AFSimulatorManager alloc] init];
    }
    
    return defaultManager;
}

- init
{
    [super init];
    
    simulators = [[NSMutableDictionary alloc] init];
    
    return self;
}
- (void)dealloc
{
    RELEASE(simulators);
    [super dealloc];
}

- (AFSimulator *)simulatorWithName:(NSString *)name host:(NSString *)host
{
    AFSimulator *simulator;
    id           ref;
    
    ref = [AFDistantSimulatorReference referenceWithName:name host:host];

    simulator = [simulators objectForKey:ref];
    
    if(simulator)
    {
        NSDebugLog(@"Found simulator with reference '%@'", ref);
        return simulator;
    }

    NSDebugLog(@"Contacting simulator '%@' at host '%@'", name, host);
 
    simulator = (AFSimulator *)
                   [NSConnection rootProxyForConnectionWithRegisteredName:name 
                                                                     host:host];
                                                                  
    if(!simulator)
    {
        return nil;
    }
    
    if(![simulator respondsToSelector:@selector(setSimulation:)])
    {
        NSLog(@"Warning: Distant object '%@' at host '%@' is not a simulator",
                name, host);
    }
    
    [(NSDistantObject *)simulator setProtocolForProxy:@protocol(AFSimulator)];

    [simulators setObject:simulator forKey:ref];

    return simulator;
}

- (AFSimulator *)simulatorWithReference:(id)ref
{
    AFSimulator *simulator = nil;

    simulator = [simulators objectForKey:ref];
    
    if(simulator)
    {
        NSDebugLog(@"Found simulator '%@'", ref);
        return simulator;
    }
    else
    {
        if([ref isKindOfClass:[AFDistantSimulatorReference class]])
        {
            simulator = [self simulatorWithName:[ref objectName] 
                                           host:[ref host]];
        }
        else
        {
            [NSException raise:AFInternalInconsistencyException
                         format:@"Unknown simulator reference class '%@'",
                         [ref className]];
        }
    }

    return simulator;
}

- (id)referenceForSimulator:(AFSimulator *)simulator
{
    NSEnumerator *enumerator;
    NSArray      *keys = [simulators allKeys];
    id            ref = nil;
    
    enumerator = [keys objectEnumerator];

    while( (ref = [enumerator nextObject]) )
    {
        if( [simulators objectForKey:ref] == simulator )
        {
            break;
        }
    }
    
    return ref;
}

- (void)releaseSimulator:(AFSimulator *)simulator
{
    [simulator releaseFarm];
}
@end
