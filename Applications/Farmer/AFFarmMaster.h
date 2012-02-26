/** AFFarmController
 
    Copyright (c) 2004 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2004 Feb 4
    
    This file is part of the Farmer application.
 
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

#import "AFFarmController.h"
#import "AFLog.h"


#import <AgentFarms/AFDistantSimulator.h>

@class NSButton;
@class NSTextField;
@class NSStepper;
@class AFFarm;
@class AFModel;
@class AFButtonRow;
@class FarmLog;

@interface AFFarmMaster:AFFarmController
{
    AFFarm      *farm;
    NSString    *storePath;
    
    AFButtonRow *assistantsView;
    
    /* Farm */

    AFDistantSimulator *simulator;

    /* State */

    int          farmState;
    BOOL         stopRequested;
    BOOL         isAnimating;

    /* Gui */

    NSButton           *runButton;
    NSButton           *forwardButton;
    NSButton           *restartButton;
    NSTextField        *timeField;       

    NSStepper          *stepCountStepper;
    NSTextField        *stepCountField;
        
    NSDate             *lastStepTime;

    /* Farm assistants */
    id<AFLog>            farmLog;
    NSMutableDictionary *assistants;
    
    NSString *modelPath; /* FIXME: remove this */
}
- (void)createFarmFromBundle:(AFModelBundle *)bundle;
- initWithModelBundle:(AFModelBundle *)aBundle;

/* Actions */
- (void)orderFrontFarmWindow:(id)sender;

/* Simulator/simulation controll */
- (void)launchSimulation;
- (void)restartSimulation;
- (void)connectToSimulator;

/* State */
- (void)setFarmState:(int)newState;


@end
