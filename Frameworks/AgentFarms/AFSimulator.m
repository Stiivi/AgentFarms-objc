/** AFSimulator
    
    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 Jan 24
    
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

#import "AFSimulator.h"

#import "AFSimulation.h"
#import "AFProbe.h"
#import "AFModel.h"
#import "AFModelBundle.h"
#import "AFProbeSpecification.h"
#import "AFNumberCollection.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSConnection.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSDistantObject.h>
#import <Foundation/NSException.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSValue.h>

@class STEngine;
@class STLanguage;

Class STEngine_class;
Class STLanguage_class;

NSString *AFSimulationLaunchedNotification = @"AFSimulationLaunchedNotification";
NSString *AFSimulationDidRunNotification = @"AFSimulationDidRunNotification";
NSString *AFSimulationDidStopNotification = @"AFSimulationDidStopNotification";
NSString *AFSimulatorProbesChangedNotification = @"AFSimulatorProbesChangedNotification";

@interface AFSimulator(Private)
- (oneway void)connectToSimulation:(id)anObject 
                        withObject:(id)userObject;
- (void)_wait:(double)delay;
- (void)_performObservation;
- (void)_runSimulationForSteps:(NSNumber *)countObj;
- (void)_simulationDidRun;
- (void)_simulationDidStop;
@end

@implementation AFSimulator
/* Create new simulator */
+ simulator
{
    return AUTORELEASE([[self alloc] init]);
}
- init
{
    [super init];

    /* FIXME: remove this */
    GSDebugAllocationActive(YES);

    identifier = RETAIN([[NSProcessInfo processInfo] globallyUniqueString]);
    probes = [[NSMutableArray alloc] init];
    
    simulationRunLock = [[NSLock alloc] init];

    return self;
}
- (void)dealloc
{
    NSLog(@"DEALLOC %@",self);
    [self releaseObserver];
    RELEASE(identifier);
    RELEASE(model);
    RELEASE(simulationRunLock);
    RELEASE(probes);
    RELEASE(lastException);
    [super dealloc];
}

- (BOOL)setBundlePath:(NSString *)aPath
{
    // NSLog(@"Setting model with path: %@", [aPath class]);

    if([modelBundle isLoaded])
    {
        [NSException raise:@"AFSimulatorException"
                     format:@"Simulation bundle is already loaded."];
        return NO;
    }
    modelBundle = RETAIN([AFModelBundle bundleWithPath:aPath]);
    
    if(!modelBundle)
    {
        NSLog(@"Unable to load model bundle at path '%@'", aPath);
        return NO;
    }
    
    return YES;
}

- (void)setModel:(bycopy AFModel *)aModel
{
    // NSLog(@"Setting model %@ %i", aModel, [aModel isProxy]);
    ASSIGN(model, aModel);
}
/***************************************************************************
    Simulation control
****************************************************************************/
- (void)createSimulation
{
    if(!model)
    {
        [NSException raise:@"AFSimulatorException"
                     format:@"No simulation model set."];
        return;
    }

    if(simulation)
    {
        [NSException raise:@"AFSimulatorException"
                     format:@"Simulation already created."];
        return;
    }
    
    // NSLog(@"Loading model classes...");
    [modelBundle load];
    // NSLog(@"Model classes loaded.");

    environment = [[AFEnvironment alloc] initWithModel:model];
    simulation = [[AFSimulation alloc] initWithEnvironment:environment];

    [self createDefaultProbes];
}
- (void)createDefaultProbes
{
    AFProbeSpecification *template;
    NSEnumerator    *enumerator;
    AFProbe         *probe;
    id               ref;

    /* Create default probes */
    enumerator = [[model probeTemplates] objectEnumerator];
    
    while( (template = [enumerator nextObject]) )
    {
        probe = [AFProbe probeWithTemplate:template];

        /* Convert object name to object reference */
        ref = [environment referenceForObjectWithName:[template objectReference]];
        [probe setObjectReference:ref];
        [self addProbe:probe];
    }
}
- (void)destroySimulation
{
    if(!simulation)
    {
        return;
    }

    [self disconnectProbes];
    [probes removeAllObjects];
    
    DESTROY(simulation);
    simulation = nil;
    simulationTime = 0;

    /** FIXME: use custom thread class */
    [[[NSThread currentThread] threadDictionary] 
                        removeObjectForKey:@"SimulationEnvironment"];

    DESTROY(environment);
    DESTROY(lastException);
}
- (bycopy NSData *)simulationState
{
#if 0
    NSMutableData *state = [NSMutableData data];
    NSArchiver    *archiver;
    
    archiver = [[NSArchiver alloc] initForWritingWithMutableData:data];
    
    RELEASE(archiver);
#endif
    return [NSData data];    
}

- (AFModel *)model
{
    return model;    
}
- (bycopy NSArray *)prototypeNames
{
    return [model prototypeNames];
}
- (bycopy NSArray *)prototypeWithName:(NSString *)aName
{
    return [model prototypeWithName:aName];
}

- (void)_wait:(double)delay
{
    [NSTimer scheduledTimerWithTimeInterval: delay
                                 invocation: nil
                                    repeats: NO];
    [[NSRunLoop currentRunLoop] runUntilDate: 
                        [NSDate dateWithTimeIntervalSinceNow: delay]];
}

- (bycopy NSArray *)rootObjectReferences
{
    return [environment rootObjectReferences];
}
- (bycopy NSArray *)rootObjectNames
{
    return [environment rootObjectNames];
}
- (bycopy AFObjectDescription *)descriptionForObjectWithReference:(id)ref;
{
    return [environment descriptionForObjectWithReference:ref];
}
- (bycopy NSString *)nameForObjectWithReference:(id)ref
{
    return [environment nameForObjectWithReference:ref];
}
- (bycopy id)referenceForObjectWithName:(NSString *)aName
{
    return [environment referenceForObjectWithName:aName];
}
- (bycopy id)referenceForObjectAtIndex:(int)index
                 inObjectWithReference:(bycopy id)ref;
{
    return [environment referenceForObjectAtIndex:index
                            inObjectWithReference:ref];

}
- (bycopy id)referenceForRelationship:(NSString *)relName
                ofObjectWithReference:(bycopy id)ref;
{
    return [environment referenceForRelationship:relName
                          ofObjectWithReference:ref];
}
- (void)      setValue:(bycopy id)value
        forPropertyKey:(bycopy NSString *)key
 inObjectWithReference:(bycopy id)ref
{
    [environment setValue:value forPropertyKey:key inObjectWithReference:ref];
}

/***************************************************************************
    Accessor methods
****************************************************************************/
- (NSString *)identifier
{
    return identifier;
}


/***************************************************************************
    Running
****************************************************************************/
/**
    Returns simulation time.
*/
- (int)simulationTime
{
    return [simulation time];
}

- (BOOL)isLaunched
{
    return simulation ? YES:NO;
}

- (BOOL)isRunning
{
    return simulationIsRunning;
}

/* **************************************************************************
    Running
****************************************************************************/
/** Run simulation for specified number of steps. */
- (oneway void)runSteps:(int)count
{
    if(!simulation)
    {
        NSLog(@"No simulation to run");
        return;
    }

    if(simulationIsRunning)
    {
        [NSException raise:@"AFSimulatorException"
                     format:@"Simulation is already running"];
        return;
    }

    [NSThread detachNewThreadSelector:@selector(_runSimulationForSteps:)
                             toTarget:self
                           withObject:[NSNumber numberWithInt:count]];
}
/** Run the simulation until stop is requested. Notify the observer each 
    count steps. */
- (oneway void)animateBySteps:(int)count
{
    if(!simulation)
    {
        NSLog(@"No simulation to animate");
        return;
    }

    if(simulationIsRunning)
    {
        [NSException raise:@"AFSimulatorException"
                     format:@"Simulation is already running"];
        return;
    }

    [NSThread detachNewThreadSelector:@selector(_animateSimulationBySteps:)
                             toTarget:self
                           withObject:[NSNumber numberWithInt:count]];
}
- (void)stop
{
    if(simulationIsRunning)
    {
        NSLog(@"STOP requested");
        simulationStopRequest = 1;
        while(1)
        {
            if(!simulationIsRunning)
            {
                break;
            }
            [self _wait:0.1];
        }
    }
}

- (void)_runSimulationForSteps:(NSNumber *)countObj
{
    [self _runSimulationForSteps:[countObj intValue] animate:NO];
}

- (void)_animateSimulationBySteps:(NSNumber *)countObj
{
    [self _runSimulationForSteps:[countObj intValue] animate:YES];
}

- (void)_runSimulationForSteps:(int)stepCount animate:(BOOL)animate
{
    NSAutoreleasePool *pool;
    NSDictionary      *dict;
    int                count;
     
    dict = [[NSThread currentThread] threadDictionary];
    [dict setObject:environment forKey:@"SimulationEnvironment"];

    RELEASE(lastException);
    lastException = nil;

    /* NOTE: we are running in another thread. */
    if(!simulationIsRunning)
    {
        [simulationRunLock lock];
        if(!simulationIsRunning)
        {
            pool =  [NSAutoreleasePool new];
            
            simulationIsRunning = YES;
            
            [self performSelectorOnMainThread:@selector(_simulationDidRun)
                                   withObject:nil
                                waitUntilDone:NO];

            NS_DURING
            
                if(simulationTime == 0)
                {
                    NSLog(@"observe first and Kill'em");
                    [self _performObservation];
                }
                
                do
                {
                    count = 0;   
                    while(!simulationStopRequest && (count < stepCount || count == -1))
                    {

                        simulationTime++;
                        [simulation step];

                        [self _performObservation];

                        count ++;
                    }
                    
                    [self performSelectorOnMainThread:@selector(_simulationTimeAdvanced)
                                           withObject:nil
                                        waitUntilDone:YES];
                } while(!simulationStopRequest && animate);
            NS_HANDLER
                NSLog(@"Exception in simulation: %@: %@", [localException name],
                                 [localException reason]);
                ASSIGN(lastException,localException);
            NS_ENDHANDLER

            if(lastException)
            {
                [self performSelectorOnMainThread:@selector(_simulationDidFail)
                                       withObject:nil
                                    waitUntilDone:NO];
            }

            simulationStopRequest = NO;
            simulationIsRunning = NO;

            [simulationRunLock unlock];

            [self performSelectorOnMainThread:@selector(_simulationDidStop)
                                   withObject:nil
                                waitUntilDone:NO];
            DESTROY(pool);
        }
        else
        {
            [simulationRunLock unlock];
            NSLog(@"Warning: Already running. (Simulation-competetive)");
        }
        
        
    }
    else
    {
        NSLog(@"Warning: Already running. (Simulation)");
    }
}

/*************************************************************************
    Delegation
*************************************************************************/
- (void)_simulationDidRun
{
    /* We are in simulation thread */
    [observer simulatorDidRun:identifier time:simulationTime];
}

- (void)_simulationDidStop
{
    /* We are in simulation thread */
    // NSLog(@"STOP F: %i ", [observer respondsToSelector:@selector(simulatorDidFail:time:)]);
    // NSLog(@"STOP S: %i ", [observer respondsToSelector:@selector(simulatorDidStop:time:)]);
    [observer simulatorDidStop:identifier time:simulationTime];
}

- (oneway void)_simulationTimeAdvanced
{
    NSLog(@"Time advance %i (SR %i)", simulationTime, simulationStopRequest);
    [observer simulatorTimeAdvance:identifier time:simulationTime];
}

- (void)_simulationDidFail
{
    /* We are in simulation thread */
    // NSLog(@"BLAH ----x----x----x----");
    // NSLog(@"FAIL F: %i ", [observer respondsToSelector:@selector(simulatorDidFail:time:)]);
    // NSLog(@"FAIL S: %i ", [observer respondsToSelector:@selector(simulatorDidStop:time:)]);
    // [observer simulatorDidFail:identifier time:simulationTime];
}
- (bycopy NSException *)lastException
{
    return lastException;
}
- (void)_performObservation
{
    NSEnumerator *enumerator = [probes objectEnumerator];    
    AFProbe      *probe;
    
    NSDebugLLog(@"AFSimulator", @"Perform observation");

    while( (probe = [enumerator nextObject]) )
    {
        /* Collect value */
        [probe collect];
    }
    
    /*
    [self performSelectorOnMainThread:@selector(_timeDidAdvance:)
                           withObject:props
                        waitUntilDone:NO];
    */
}

- (void)_timeDidAdvance:(id)nothing
{
    /* We are in main thread */
/*
    [observer         simulator:identifier 
             observedProperties:[props properties]
                           time:[props time]];

    AUTORELEASE(props);
*/
}

/** Set simulation observer to be <var>anObject</var>. Observer will receive
notifications about simulation state changes. If the observer is a distant
object, simulator will watch for disconnection. When the new observer is nil, 
previous observer is released.*/
- (void)setObserver:(id <AFSimulatorObserver>)anObject
{
    /* FIXME: unregister previous notification */
    if(anObject == nil)
    {
        [self releaseObserver];
    }
    else
    {
        ASSIGN(observer, anObject);
    
        if([observer isProxy])
        {
            [(NSDistantObject *)observer setProtocolForProxy:@protocol(AFSimulatorObserver)];
            [[NSNotificationCenter defaultCenter]
                addObserver:self
                   selector:@selector(_observerConnectionDidDie:)
                       name:NSConnectionDidDieNotification
                     object:nil];
        }
    }
}
- (void)releaseObserver
{
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                  name:NSConnectionDidDieNotification
                object:nil];
    DESTROY(observer);
}
- (void)_observerConnectionDidDie:(id)notif
{
    NSLog(@"Observer died");

    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                  name:NSConnectionDidDieNotification
                object:nil];
    observer = nil;
}

- (void)postObserverNotificationName:(NSString *)name
{
    NSNotification *notif;
    
    notif = [NSNotification notificationWithName:name object:identifier];
    [observer simulatorNotification: notif];
}
/***************************************************************************
    Probing
****************************************************************************/

- (void)addProbesFromTemplates:(bycopy NSArray *)templates
{
    AFProbeSpecification *template;
    NSEnumerator    *enumerator;
    AFProbe         *probe;

    enumerator = [templates objectEnumerator];
    
    while( (template = [enumerator nextObject]) )
    {
        probe = [AFProbe probeWithTemplate:template];
        [self addProbe:probe];
    }
}

- (void)addProbe:(AFProbe *)probe
{
    AFNumberCollection *collection;
    
    if([probes containsObject:probe])
    {
        NSLog(@"Probe %@ doubled", probe);
    }
    else
    {
        [probe connectInEnvironment:environment];
        NSLog(@"Adding probe %@", probe);

        collection = [[AFNumberCollection alloc] init];
        [collection setOffset:simulationTime];
        [probe setCollection:AUTORELEASE(collection)];
        
        [probes addObject:probe];
        /* FIXME: disconnect when simulation is released */
    }
    [self postObserverNotificationName:AFSimulatorProbesChangedNotification];
}
- (void)removeAllProbes
{
    [probes removeAllObjects];
}
- (bycopy NSArray *)probeDescriptions
{
    AFProbeSpecification *spec;
    NSMutableArray       *array = [NSMutableArray array];
    NSEnumerator         *enumerator;
    AFProbe              *probe;
    
    enumerator = [probes objectEnumerator];
    
    while( (probe = [enumerator nextObject]) )
    {
        spec = [probe probeSpecification];
        [spec setObjectClassName:[[probe target] className]];
        [array addObject:[probe probeSpecification]];
    }
    return [NSArray arrayWithArray:array];
}
- (AFProbe *)probeWithSpecification:(AFProbeSpecification *)aSpec
{
    NSEnumerator *enumerator;
    AFProbe      *probe;
    
    enumerator = [probes objectEnumerator];
    
    while( (probe = [enumerator nextObject]) )
    {
        if([[probe probeSpecification] isEqual:aSpec])
        {
            return probe;
        }
    }
    return nil;
}
/** Disconnect all probes */
- (void)disconnectProbes
{
    NSEnumerator         *enumerator;
    AFProbe              *probe;
    
    enumerator = [probes objectEnumerator];
    
    while( (probe = [enumerator nextObject]) )
    {
        [probe disconnect];
    }
}

/** Connect all probes */
- (void)connectProbes
{
    NSEnumerator         *enumerator;
    AFProbe              *probe;
    
    enumerator = [probes objectEnumerator];
    
    while( (probe = [enumerator nextObject]) )
    {
        [probe connectInEnvironment:environment];
    }
}

- (bycopy AFNumberCollection *)collectionForProbeWithSpecification:(bycopy AFProbeSpecification *)spec
{
    AFProbe *probe = [self probeWithSpecification:spec];

    return [probe collection];
}
/** Scripting */
- (BOOL)initialiseScripting
{

    STEngine_class = NSClassFromString(@"STEngine");
    STLanguage_class = NSClassFromString(@"STLanguage");
    return NO;
}

- (BOOL)isScriptable
{
    return [self initialiseScripting];
}
- (bycopy id)executeScriptSource:(bycopy NSString *)aSource
                        language:(bycopy NSString *)language
{
    STEngine *engine;
    
    engine = [STEngine_class engineForLanguageWithName:language];
    if(!engine)
    {
        [NSException raise:@"AFSimulatorException"
                     format:@"Unable to find scripting engine for language '%@'",
                     language];
        return nil;
    }
    return [engine executeCode:aSource inEnvironment:scriptingEnvironment];
}
- (bycopy NSDictionary *)scriptingCapabilities
{
    NSDictionary *dict;
    
    dict =[NSDictionary dictionaryWithObjectsAndKeys:
                                [STLanguage_class allLanguageNames], @"Languages"];
                                
    return dict;
}

- (bycopy id)objectForView:(NSDictionary *)viewInfo
{
    NSString     *objectName;
    NSString     *relName;
    id            target = nil;
    id            object = nil;

    if(viewInfo)
    {
        /* FIXME: cache the target object */
        objectName = [viewInfo objectForKey:@"Target"];
        relName = [viewInfo objectForKey:@"Identifier"];
        // NSLog(@"-> Getting view %@ %@", objectName, relName);
        target = [environment objectWithName:objectName];
        object = [target valueForKey:relName];
        // NSLog(@"-. Got view for %@ -> %@", target, object);
    }
    
    return object;
}
/** Debug message (FIXME: remove this) */
- (bycopy NSString *)objectDebugDump
{
    return [NSString stringWithCString:GSDebugAllocationList(NO)];
}
@end
