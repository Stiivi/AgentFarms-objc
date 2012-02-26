/** AFSimulationState
    
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


#import "AFSimulationState.h"

#import <AgentFarms/AFSimulation.h>

#import <Foundation/NSArchiver.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSValue.h>

@implementation AFSimulationState
- initWithSimulation:(AFSimulation *)simulation
{
    [super init];
    
    data = [NSArchiver archivedDataWithRootObject:simulation];
    time = [simulation time];

    RETAIN(data);
    
    return self;
}
- (void)dealloc
{
    RELEASE(data);
    [super dealloc];
}
- (AFSimulation *)simulation
{
    return [NSUnarchiver unarchiveObjectWithData:data];
}
- (NSDictionary *)infoDictionary
{
    NSDictionary *dict;
    
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:time], @"Time",
                                nil,nil];

    return dict;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder: aCoder];
    
    [aCoder encodeObject: data];
    [aCoder encodeValueOfObjCType: @encode(int) at: &time];
}

- initWithCoder:(NSCoder *)aDecoder
{
    [super initWithCoder: aDecoder];

    [aDecoder decodeValueOfObjCType: @encode(id) at: &data];
    [aDecoder decodeValueOfObjCType: @encode(int) at: &time];

    return self;
}
@end
