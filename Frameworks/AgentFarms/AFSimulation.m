/*  AFSimulation

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 Feb 18
    
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

#import "AFSimulation.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSEnumerator.h>

#import "AFEnvironment.h"

@implementation AFSimulation
- initWithEnvironment:(AFEnvironment *)env
{
    self = [super init];

    environment = RETAIN(env);

    return self;
}
- (void)dealloc
{
    RELEASE(environment);
    [super dealloc];
}

/** Performs one simulation step with each root object. */
- (void)step
{
    NSEnumerator *enumerator = [[environment rootObjects] objectEnumerator];
    id            object;

    while( (object = [enumerator nextObject]) )
    {
        // NSLog(@"STEP %@", [object className]);
        [object step];
    }
    
    time++;
}
- (unsigned int)time
{
    return time;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // [super encodeWithCoder: aCoder];
}

- initWithCoder:(NSCoder *)aDecoder
{
    return [super init]; //[super initWithCoder: aDecoder];
}
@end
