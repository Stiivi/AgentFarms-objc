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

#import <AppKit/NSWindowController.h>
#import <AgentFarms/AFSimulator.h>
#import "AFLog.h"

extern NSString *AFFarmDidLaunchNotification;
extern NSString *AFFarmDestroyedNotification;
extern NSString *AFFarmWillCloseNotification;
extern NSString *AFFarmDidCloseNotification;

extern NSString *AFFarmCreatedNotification;
extern NSString *AFFarmStateChangedNotification;
extern NSString *AFFarmDidStopNotification;
extern NSString *AFFarmTimeAdvancedNotification;

@class AFFarm;
@class AFModel;

enum
{
    AFFarmDisconnectedState,
    AFFarmConnectingState,
    AFFarmEmptyState,
    AFFarmReadyState,
    AFFarmRunningState
};

@interface AFFarmController:NSWindowController
{
    AFFarmController *master;
}
- initWithMaster:(AFFarmController *)controller;

- (AFFarmController *)master;

- (AFFarm *)farm;
- (AFModel *)model;
- (id <AFSimulator>)simulator;

/* Actions */
- (void)restart:(id)sender;
- (void)run: (id)sender;
- (void)watch:(id)sender;

/* State */
- (int)farmState;
- (BOOL)isLaunched;

/* Logging */
- (id <AFLog>)log;
- (void)log:(NSString*)format,...;
- (void)logError:(NSString*)format,...;
- (void)logWarning:(NSString*)format,...;
@end
