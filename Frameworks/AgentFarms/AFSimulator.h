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


#import <Foundation/NSObject.h>

#import "AFSimulation.h"

extern NSString *AFSimulationDidRunNotification;
extern NSString *AFSimulationDidStopNotification;
extern NSString *AFSimulationTimeAdvanceNotification;
extern NSString *AFSimulatorProbesChangedNotification;

@class AFModel;
@class AFThread;
@class AFModelBundle;
@class AFProbe;
@class AFNumberCollection;
@class AFProbeSpecification;
@class AFObjectDescription;
@class NSLock;
@class NSMutableArray;
@class NSMutableDictionary;
@class NSNotification;
@class NSException;

@protocol AFSimulatorObserver
- (oneway void) simulatorDidRun:(NSString *)tag time:(AFSimulationTime)time;
- (oneway void) simulatorTimeAdvance:(NSString *)tag time:(AFSimulationTime)time;
- (oneway void) simulatorDidStop:(NSString *)tag time:(AFSimulationTime)time;
- (oneway void) simulatorNotification:(bycopy NSNotification *)notification;
@end

@protocol AFSimulator <NSObject>
/** Opens a model from model bundle at path <var>aPath</var>. Returns YES 
    on success, otherwise returns NO. */
- (BOOL)setBundlePath:(NSString *)aPath;
- (void)setModel:(bycopy AFModel *)aModel;

/** Create all simulation objects from prototypes. */
- (void)createSimulation;
- (void)destroySimulation;
- (bycopy NSData *)simulationState;
- (NSString *)identifier;

/** Run simulation for <var>count</var> steps. */
- (oneway void)runSteps:(int)count;
- (oneway void)animateBySteps:(int)count;

/** Stop the simulation */
- (void)stop;

/**
    Return <code>YES</code> if simulation is running, otherwise returns
    <code>NO</code>
*/
- (BOOL)isRunning;
- (int)simulationTime;

/** Set simulation observer to <var>anObject</var> */
- (void)setObserver:(id)anObject;
// - (id)observer;
- (bycopy NSException *)lastException;

/* Object space */
- (bycopy NSArray *)prototypeNames;
- (bycopy NSArray *)prototypeWithName:(NSString *)aName;

- (bycopy NSArray *)rootObjectReferences;
- (bycopy NSArray *)rootObjectNames;
- (bycopy AFObjectDescription *)descriptionForObjectWithReference:(bycopy id)ref;
- (bycopy NSString *)nameForObjectWithReference:(bycopy id)ref;
- (bycopy id)referenceForObjectWithName:(NSString *)aName;

- (bycopy id)referenceForObjectAtIndex:(int)index
                 inObjectWithReference:(bycopy id)ref;

- (bycopy id)referenceForRelationship:(NSString *)relName
                ofObjectWithReference:(bycopy id)ref;

- (void)      setValue:(bycopy id)value
        forPropertyKey:(bycopy NSString *)key
 inObjectWithReference:(bycopy id)ref;
 
/** Probing */
- (void)addProbesFromTemplates:(bycopy NSArray *)descriptions;
- (void)removeAllProbes;
- (bycopy NSArray *)probeDescriptions;

/** Collecting */
- (bycopy AFNumberCollection *)collectionForProbeWithSpecification:(bycopy AFProbeSpecification *)spec;

/* Views */
- (bycopy id)objectForView:(NSString *)anIdent;

/** Scripting */
- (BOOL)isScriptable;
- (bycopy id)executeScriptSource:(bycopy NSString *)aSource language:(bycopy NSString *)language;
- (bycopy NSDictionary *)scriptingCapabilities;
- (bycopy NSString *)objectDebugDump;
@end

@interface AFSimulator: NSObject <AFSimulator>
{
    NSString               *identifier;

    Class                   simulationClass;
    AFModelBundle          *modelBundle;
    AFModel                *model; 

    /* Simulation */
    unsigned int            simulationTime;
    AFSimulation           *simulation;
    AFEnvironment          *environment;
    /* Running */
    BOOL             simulationStopRequest;
    BOOL             simulationIsRunning;
    NSLock          *simulationRunLock;

    /* Observer */
    NSObject<AFSimulatorObserver> *observer;
    NSMutableArray                *probes;

    NSException                   *lastException;
    id scriptingEnvironment;
}

+ simulator;
- (void)addProbe:(AFProbe *)probe;
@end

