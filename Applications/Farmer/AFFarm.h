/** AFFarm
 
    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 Oct 6
    
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

#import <Foundation/NSObject.h>
#import <AgentFarms/AFSimulator.h>

@class AFDistantSimulator;

@class AFModel;
@class AFModelBundle;
@class DescriptionWindowController;
@class FarmLog;
@class ModulesView;
@class NSButton;
@class NSDate;
@class NSDictionary;
@class NSMutableArray;
@class NSStepper;
@class NSTextField;
@class NSWindow;
@class ObjectBrowser;
@class PrototypesBrowser;;

@interface AFFarm:NSObject
{
    NSString    *storePath;
    
    /* Farm */

    AFModel            *model;
    AFModelBundle      *modelBundle;
    NSString           *modelName;
    NSString           *modelPath;

    /* FUTURE */
    NSArray            *collections;
    
}

- initWithModelPath:(NSString *)path;
- initWithModelBundle:(AFModelBundle *)aBundle;

/* Model */
- (AFModel *)model;
- (NSString *)name;
@end
