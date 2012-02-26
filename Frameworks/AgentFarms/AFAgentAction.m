/** AFAgentAction

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2001 Nov 24
   
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

#import "AFAgentAction.h"

#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>

AFAgentAction *AFUnknownAgentAction = nil;

static NSMutableDictionary *namedActions = nil;

@implementation AFAgentAction
+ (void)initialize
{
    AFUnknownAgentAction = [[AFAgentAction alloc] init];
    namedActions = [[NSMutableDictionary alloc] init];
    [AFUnknownAgentAction setName:@"AFUnknownAgentAction"];
}
+ actionWithName:(NSString *)aName
{
    return [namedActions objectForKey:aName];
}
+ unknownAction
{
    return AFUnknownAgentAction;
}
- (void)dealloc
{
    RELEASE(description);
    [super dealloc];
}
- (void)setDescription:(NSString *)aString
{
    ASSIGN(description,aString);
}
- (NSString *)actionDescription
{
    return description;
}
- (void)setName:(NSString *)name
{
    [namedActions setObject:self forKey:name];
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ '%@'>",
                            [self className],description];
}
- copyWithZone:(NSZone *)zone
{
    return RETAIN(self);
}
@end
