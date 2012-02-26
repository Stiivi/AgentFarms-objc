/** AFModel

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 Jul 4 
    
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

#import "AFModel.h"

#import "AFResourceManager.h"
#import "NSDictionary+convenience.h"
#import "AFGraphInfo.h"
#import "AFProperty.h"
#import "AFPropertyList.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>

#import "AFClassDescription.h"
#import "AFObjectPrototype.h"
#import "AFObjectConnection.h"
#import "AFProbeSpecification.h"

@interface AFModel(AFPrivate)
- (void)_initClassDescriptions:(NSDictionary *)dict;
- (void)_initPrototypes:(NSDictionary *)dict;
- (void)_initObjects:(NSArray *)array;
- (void)_initConnections:(NSArray *)array;
- (void)_initProbes:(NSDictionary *)dict;
@end

@implementation AFModel
+ modelFromFile:(NSString *)file
{
    AFModel *model;
    
    model = [[self alloc] initFromFile:file];
    
    return AUTORELEASE(model);
}
- initFromFile:(NSString *)file
{
    NSDictionary *modelDict;
    
    [super init];
        
    modelDict = [NSDictionary dictionaryWithContentsOfFile:file];
           
    if(!modelDict)
    {
        [NSException raise:@"AFModelException"
                     format:@"Unable to read model description '%@'", file];
        [self dealloc];
        return nil;
    }
    
    name = [modelDict objectForKey:@"Name"];
    
    defaultStepCount = [modelDict intForKey:@"StepTimeUnits"];
    if(!defaultStepCount)
    {
        defaultStepCount = 1;
    }

    if(!name || [name isEqualToString:@""])
    {
        name = @"Unnamed";
    }
    else
    {
        RETAIN(name);
    }

    [self _initClassDescriptions:[modelDict objectForKey:@"Classes"]];
    [self _initPrototypes:[modelDict objectForKey:@"Prototypes"]];
    [self _initObjects:[modelDict objectForKey:@"Objects"]];
    [self _initConnections:[modelDict objectForKey:@"Connections"]];
    [self _initProbes:[modelDict objectForKey:@"Probes"]];
    [self _initViews:[modelDict objectForKey:@"Views"]];

    return self;
}

- (void)_initClassDescriptions:(NSDictionary *)dict
{
    AFClassDescription *desc;
    NSEnumerator       *enumerator;
    NSDictionary       *classDict;
    NSString           *className;
    NSString           *path;
    NSDictionary       *stdDict;
    
    classDescriptions = [NSMutableDictionary dictionary];
    
    enumerator = [dict keyEnumerator];
    
    while( (className = [enumerator nextObject]) )
    {
        // NSLog(@"Model Class %@", className);

        classDict = [dict objectForKey:className];
        desc = [[AFClassDescription alloc] initWithName:className
                                     descriptionDictionary:classDict];
        [(NSMutableDictionary *)classDescriptions setObject:AUTORELEASE(desc) forKey:className];
    }

    /* Standard descriptions */
    path = [[NSBundle bundleForClass:[self class]] 
                        pathForResource:@"ClassDescriptions" ofType:@"plist"];
    stdDict = [NSDictionary dictionaryWithContentsOfFile:path];
    enumerator = [stdDict keyEnumerator];
    
    while( (className = [enumerator nextObject]) )
    {
        /* NSLog(@"Standard Class %@", className); */

        classDict = [stdDict objectForKey:className];
        desc = [[AFClassDescription alloc] initWithName:className
                                     descriptionDictionary:classDict];
        [(NSMutableDictionary *)classDescriptions setObject:AUTORELEASE(desc) forKey:className];
    }
    
    if([classDescriptions count])
    {
        classDescriptions = [[NSDictionary alloc] 
                                    initWithDictionary:classDescriptions];
    }
    else
    {
        classDescriptions = nil;
    }
}
- (void)_initPrototypes:(NSDictionary *)dict
{
    AFObjectPrototype *desc;
    NSEnumerator        *enumerator;
    NSDictionary        *protoDict;
    NSString            *protoName;
    
    prototypes = [NSMutableDictionary dictionary];
    
    enumerator = [dict keyEnumerator];
    
    while( (protoName = [enumerator nextObject]) )
    {
        // NSLog(@"Model Prototype %@", protoName);
        protoDict = [dict objectForKey:protoName];
        desc = [[AFObjectPrototype alloc] initWithDictionary:protoDict];
        [(NSMutableDictionary *)prototypes setObject:AUTORELEASE(desc) forKey:protoName];
    }
    
    if([prototypes count])
    {
        prototypes = [[NSDictionary alloc] 
                                    initWithDictionary:prototypes];
    }
    else
    {
        prototypes = nil;
    }
}
- (void)_initObjects:(NSArray *)array
{
    objects = RETAIN(array);
}

- (void)_initConnections:(NSArray *)array
{
    AFObjectConnection *connection;
    NSEnumerator       *enumerator;
    NSDictionary       *conDict;
    
    enumerator = [array objectEnumerator];
    
    connections = [NSMutableArray array];
    
    while( (conDict = [enumerator nextObject]) )
    {
        connection = [[AFObjectConnection alloc] init];
        
        [connection setDestinationName:[conDict objectForKey:@"Destination"]];
        [connection setRelationshipName:[conDict objectForKey:@"Relationship"]];
        [connection setSourceName:[conDict objectForKey:@"Source"]];

        [(NSMutableArray *)connections addObject:AUTORELEASE(connection)];
    }
    
    if([connections count])
    {
        connections = [[NSArray alloc] initWithArray:connections];
    }
    else
    {
        connections = nil;
    }
}
- (void)_initProbes:(NSDictionary *)dict
{
    AFProbeSpecification *temp;
    NSMutableArray  *array;
    NSEnumerator    *enumerator;
    NSDictionary    *probeDict;

    array = [NSMutableArray array];
    
    enumerator = [dict objectEnumerator];
    
    while( (probeDict = [enumerator nextObject]) )
    {
        temp = [AFProbeSpecification specificationWithObjectReference:[probeDict objectForKey:@"Target"]
                                               propertyIdentifier:[probeDict objectForKey:@"Property"]];
        
        
        [array addObject:temp];
    }
    
    if([array count])
    {
        probes = [[NSArray alloc] initWithArray:array];
    }
    else
    {
        probes = nil;
    }
}
- (void)_initViews:(NSDictionary *)dict
{
    NSMutableArray *array;
    NSEnumerator   *enumerator;
    NSDictionary   *viewDict;

    array = [NSMutableArray array];
    
    enumerator = [dict objectEnumerator];
    
    while( (viewDict = [enumerator nextObject]) )
    {
        /* FIXME: do something here with viewDict */
        [array addObject:viewDict];
    }
    
    if([array count])
    {
        views = [[NSArray alloc] initWithArray:array];
    }
    else
    {
        views = nil;
    }
}
- (void)dealloc
{
    RELEASE(name);
    RELEASE(classDescriptions);
    RELEASE(objects);
    RELEASE(connections);
    RELEASE(prototypes);
    RELEASE(views);
    RELEASE(probes);
        
    [super dealloc];
}

- (NSString *)name
{
    return name;
}

- (int)defaultStepCount
{
    return defaultStepCount;
}

- (NSDictionary *)prototypes
{
    return prototypes;
}
- (bycopy NSArray *)prototypeNames
{
    return [prototypes allKeys];
}
- (AFObjectPrototype *)prototypeWithName:(NSString *)aName
{
    return [prototypes objectForKey:aName];
}
- (NSArray *)objects
{
    return objects;
}
- (NSArray *)connections
{
    return connections;
}
- (AFClassDescription *)descriptionForClassWithName:(NSString *)aName
{
    return [classDescriptions objectForKey:aName];
}
- (NSArray *)probeTemplates
{
    return probes;
}
- (NSArray *)classDescriptions
{
    return classDescriptions;
}
- (NSArray *)views
{
    return views;
}

/*****************************************************************************
* Properties
*****************************************************************************/

/*****************************************************************************
* Persistence
*****************************************************************************/

/* Serialisation */
- (void)encodeWithCoder:(NSCoder *)coder
{
    // [super encodeWithCoder: coder];

    [coder encodeObject:name];
    [coder encodeObject:classDescriptions];
    [coder encodeObject:prototypes];
    [coder encodeObject:objects];
    [coder encodeObject:connections];
    [coder encodeObject:probes];
    [coder encodeValueOfObjCType: @encode(int) at: &defaultStepCount];
}

- initWithCoder:(NSCoder *)decoder
{
    self = [super init];// [super initWithCoder: decoder];
    
    [decoder decodeValueOfObjCType: @encode(id) at: &name];
    [decoder decodeValueOfObjCType: @encode(id) at: &classDescriptions];
    [decoder decodeValueOfObjCType: @encode(id) at: &prototypes];
    [decoder decodeValueOfObjCType: @encode(id) at: &objects];
    [decoder decodeValueOfObjCType: @encode(id) at: &connections];
    [decoder decodeValueOfObjCType: @encode(id) at: &probes];
    [decoder decodeValueOfObjCType: @encode(int) at: &defaultStepCount];

    return self;
}
@end
