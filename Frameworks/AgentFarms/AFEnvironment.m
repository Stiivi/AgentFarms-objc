/* 2003 Jul 27 */

#import "AFEnvironment.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

#import "AFModel.h"
#import "AFModelBundle.h"
#import "AFObjectPrototype.h"
#import "AFObjectDescription.h"
#import "AFCollectionDescription.h"
#import "AFRelationshipDescription.h"
#import "AFObjectConnection.h"

@implementation AFEnvironment
- initWithModel:(AFModel *)aModel
{
    AFObjectPrototype  *prototype;
    AFObjectConnection *connection;
    NSMutableArray     *prototypes;
    NSEnumerator       *enumerator;
    NSDictionary       *dict;
    NSString           *objectName;
    NSString           *protoName;
    id                  object;    
    id                  source;
    id                  destination;
    int                 i;
    [super init];

    model = RETAIN(aModel);

    nextReference = 1;

    /* FIXME: This should NOT be here, create separate thread for
              this method and make it asynchronous. */
    [[[NSThread currentThread] threadDictionary] 
                        setObject:self forKey:@"SimulationEnvironment"];

    NSLog(@"-- Creating simulation");

    /* Create objects */
    enumerator = [[model objects] objectEnumerator];
    
    objects = [[NSMutableArray alloc] init];
    objectNames = [[NSMutableDictionary alloc] init];
    objectNameDictionary = [[NSMutableDictionary alloc] init];
    objDictionary = [[NSMutableDictionary alloc] init];
    refDictionary = [[NSMutableDictionary alloc] init];


    prototypes = [NSMutableArray array];
    
    while( (dict = [enumerator nextObject]) )
    {
        objectName = [dict objectForKey:@"Name"];
        protoName = [dict objectForKey:@"Prototype"];
        
        // NSLog(@"  Getting prototype %@", protoName);    
        prototype = [model prototypeWithName:protoName];
        
        if(!prototype)
        {
            /* FIXME: release stuff */
            [NSException raise:@"AFSimulatorException"
                         format:@"Unknown object prototype '%@'", protoName];
            [self dealloc];
            return nil;
        }
        
        // NSLog(@"  Creating object %@:%@", objectName, protoName);
        object = [prototype instantiate];
        // NSLog(@"  Created %@", object);
        
        [objects addObject:object];
        [objectNames setObject:objectName 
                        forKey:[self referenceForObject:object]];
                        
        [prototypes addObject:prototype];
        [objectNameDictionary setObject:object forKey:objectName];
    }

    // NSLog(@"  Connecting objects");
    
    /* Connect objects */

    enumerator = [[model connections] objectEnumerator];
    
    while( (connection = [enumerator nextObject]) )
    {
        source = [objectNameDictionary objectForKey:[connection sourceName]];
        destination = [objectNameDictionary objectForKey:[connection destinationName]];
    
        if(!source)
        {
            [NSException raise:@"AFSimulationException"
                         format:@"Unknown source object '%@'.", 
                         [connection sourceName]];
            continue;
        }
        
        if(!destination)
        {
            [NSException raise:@"AFSimulationException"
                         format:@"Unknown destination object '%@'.", 
                         [connection destinationName]];
            continue;
        }
        /*
        NSLog(@"    Connecting '%@:%@' to '%@:%@' with '%@'",
                    [connection sourceName],source,
                    [connection destinationName],destination,
                    [connection relationshipName]);
        */
        [destination takeValue:source forKey:[connection relationshipName]];
    }

    /* Awake objects after connecting */
    // NSLog(@"  Awakening objects");

    /* Awake objects with corresponding prototypes */

    enumerator = [objects objectEnumerator];
    i = 0;
    
    while( (object = [enumerator nextObject]) )
    {
        // NSLog(@"AWAKE %@", [prototypes objectAtIndex:i]);
        [object awakeWithPrototype:[prototypes objectAtIndex:i]];
        i++;
    }

    NSLog(@"-- Done creating simulation");

    return self;
}
- (void)dealloc
{
    RELEASE(objects);
    RELEASE(objectNameDictionary);
    RELEASE(model);
    
    RELEASE(refDictionary);
    RELEASE(objDictionary);
    
    [super dealloc];
}
/** Returns an array of names of root objects. */
- (NSArray *)rootObjectNames
{
    NSMutableArray *array = [NSMutableArray array];
    NSEnumerator   *enumerator;
    id              obj;
    NSString       *name;
    enumerator = [objects objectEnumerator];
    
    while( (obj = [enumerator nextObject]) )
    {
        name = [objectNames objectForKey:[self referenceForObject:obj]];
        [array addObject:name];
    }
    
    return [NSArray arrayWithArray:array];
}
/** Returns array of references to all simulation root objects. */
- (NSArray *)rootObjectReferences
{
    NSMutableArray    *array = [NSMutableArray array];
    NSEnumerator      *enumerator;
    id                 object;
    
    enumerator = [objects objectEnumerator];
    
    while( (object = [enumerator nextObject]) )
    {
        [array addObject:[self referenceForObject:object]];
    }
    
    return [NSArray arrayWithArray:array];
}

/** Returns a reference for object with name <var>name</var>. If there is no
    object with given name, nil is returned.
    Reference is unique identifier in the scope of the simulation.
    */
- (id)referenceForObjectWithName:(NSString *)name
{
    id obj = [objectNameDictionary objectForKey:name];
    
    return [self referenceForObject:obj];
}

/** Returns an object with name <var>name</var>. If there is no
    object with given name, nil is returned.
    */
- (id)objectWithName:(NSString *)name
{
    return [objectNameDictionary objectForKey:name];
}

/** Returns a reference for object <var>anObject</var>. 
    Reference is unique identifier in the scope of the simulation.
    */
- (id)referenceForObject:(id)anObject
{
    NSNumber *ref;
    NSValue  *objKey;
    NSNumber *newRef;

    /* FIXME: Use map table */
    objKey = [NSValue  valueWithNonretainedObject:anObject];
    ref = [refDictionary objectForKey:objKey];
    
    if(ref)
    {
        return ref;
    }

    newRef = [NSNumber numberWithInt:nextReference];
    
    [refDictionary setObject:newRef
                      forKey:objKey];
                   
    [objDictionary setObject:anObject 
                      forKey:newRef];

    nextReference++;
    
    return newRef;
}

- (bycopy id)referenceForObjectAtIndex:(int)index
                 inObjectWithReference:(bycopy id)ref
{
    id target = [self objectWithReference:ref];
    id object;
    
    if(target)
    {
        object = [target objectAtIndex:index];
        return [self referenceForObject:object];
    }
    else
    {
        return nil;
    }

}

/** Returns object with given reference <var>ref</var>. This method should be
used only by simulator. */
- (id)objectWithReference:(id)ref
{
    return [objDictionary objectForKey:ref];
}

- (AFObjectDescription *)descriptionForObjectWithReference:(id)ref;
{
    AFObjectDescription *desc;
    AFClassDescription  *classDesc;
    NSEnumerator        *enumerator;
    id                   object;
    NSString            *key;
    id                   relRef;
        
    object = [objDictionary objectForKey:ref];
    
    // NSLog(@"Request for desc. objref:%@(%@)", ref, [object className]);
    if(object)
    {
        classDesc = [model descriptionForClassWithName:[object className]];
        if(!classDesc)
        {
            Class class;
            class = [object class];
            
            while(class = [class superClass])
            {
                classDesc = [model descriptionForClassWithName:[class className]];
                if(classDesc)
                {
                    break;
                }
            }
            if(!classDesc)
            {
                NSLog(@"WARNING: No class description '%@'", [object className]);
            }
        }

        desc = [[AFObjectDescription alloc]   initWithObject:object
                                            classDescription:classDesc];

        /* set references */
     
        enumerator = [[classDesc relationshipKeys] objectEnumerator];
        while( (key = [enumerator nextObject]) )
        {
            /* FIXME: check whether key is ivar of type (id) */
            NS_DURING
                relRef = [self referenceForObject:[object valueForKey:key]];
            NS_HANDLER
                [NSException raise:@"AFObjectDescriptionException"
                             format:@"Unable to get reference from object of type %@ for key %@."
                                    @"Reason: %@ (%@)",
                                    [object className],
                                    key,
                                    [localException reason],
                                    [localException name]];
                continue;
                // NSUnknownKeyException
            NS_ENDHANDLER
            [desc setReference:relRef forRelationship:key];
        }

        return AUTORELEASE(desc);
    }
    else
    {
        NSLog(@"No object with reference %@", ref);
        return nil;
    }
}
- (id)referenceForRelationship:(NSString *)relName
         ofObjectWithReference:(id)ref;
{
    AFRelationshipDescription *relDesc;
    AFObjectDescription *desc;
    AFClassDescription  *class;
    NSEnumerator        *enumerator;
    id                   object;
    NSString            *key;
    id                   relRef;

    [self notImplemented:_cmd];
        
    object = [objDictionary objectForKey:ref];
    NSLog(@"Getting %@ for %@", relName, ref);
    if(object)
    {
        class = [model descriptionForClassWithName:[object className]];

        if(!class)
        {
            NSLog(@"WARNING: No description for class '%@'", [object className]);
        }

        relDesc = [class relationshipWithIdentifier:relName];

        if([relDesc isToMany])
        {
            desc = [[AFCollectionDescription alloc]   initWithObject:object
                                                    classDescription:class];
        }
        else
        {
            desc = [[AFObjectDescription alloc]   initWithObject:object
                                                classDescription:class];
            /* set references */
     
            enumerator = [[class relationshipKeys] objectEnumerator];
            while( (key = [enumerator nextObject]) )
            {
                /* FIXME: check whether key is ivar of type (id) */
                NS_DURING
                    relRef = [self referenceForObject:[object valueForKey:key]];
                NS_HANDLER
                    [NSException raise:@"AFObjectDescriptionException"
                                 format:@"Unable to get reference from object of type %@ for key %@."
                                        @"Reason: %@ (%@)",
                                        [object className],
                                        key,
                                        [localException reason],
                                        [localException name]];
                    continue;
                    // NSUnknownKeyException
                NS_ENDHANDLER
                [desc setReference:relRef forRelationship:key];
            }
        }
        return AUTORELEASE(desc);
    }
    else
    {
        NSLog(@"No object with reference %@", ref);
        return nil;
    }
}

- (NSString *)nameForObjectWithReference:(id)ref
{
    return [objectNames objectForKey:ref];
}
- (AFObjectPrototype *)prototypeWithName:(NSString *)name
{
    return [model prototypeWithName:name];
}
- (NSArray *)rootObjects
{
    return objects;
}
- (void)      setValue:(bycopy id)value
        forPropertyKey:(bycopy NSString *)key
 inObjectWithReference:(bycopy id)ref
{
    id object;
    
    object = [self objectWithReference:ref];

    NS_DURING    
        [object takeValue:value forKey:key];
    NS_HANDLER
        [NSException raise:@"AFEnvironmentException"
                     format:@"Unable to set value for object of type %@ for key %@."
                            @"Reason: %@ (%@)",
                            [object className],
                            key,
                            [localException reason],
                            [localException name]];
        // NSUnknownKeyException
    NS_ENDHANDLER
}

@end

