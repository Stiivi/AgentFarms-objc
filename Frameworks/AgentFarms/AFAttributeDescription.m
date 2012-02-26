/** AFAttributeDescription

    Copyright (c) 2003 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2003 Jun 30
    
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

#import "AFAttributeDescription.h"

#import <Foundation/NSCoder.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>

#import "NSDictionary+convenience.h"

@implementation AFAttributeDescription:NSObject
- initWithDictionary:(NSDictionary *)dict
{
    [super init];
    
    identifier = RETAIN([dict objectForKey:@"Identifier"]);
    name = RETAIN([dict objectForKey:@"Name"]);
    isReadOnly = [dict boolForKey:@"ReadOnly"];
    isForCreation = [dict boolForKey:@"ForCreation"];
    return self;
}

- (NSString *)identifier
{
    return identifier;
}
- (NSString *)name
{
    return name;
}
- (void)dealloc
{
    RELEASE(name);
    RELEASE(identifier);
    [super dealloc];
}

- (BOOL)isReadOnly
{
    return isReadOnly;
}
- (BOOL)isForCreation
{
    return isForCreation;
}
- (BOOL)isChangeable
{
    return isReadOnly != YES;
}
- (void)encodeWithCoder:(NSCoder *)coder
{
    // [super encodeWithCoder: coder];

    [coder encodeObject:name];
    [coder encodeObject:identifier];
    [coder encodeValueOfObjCType: @encode(BOOL) at: &isReadOnly];
    [coder encodeValueOfObjCType: @encode(BOOL) at: &isForCreation];
}

- initWithCoder:(NSCoder *)decoder
{
    self = [super init]; //[super initWithCoder: decoder];
    
    [decoder decodeValueOfObjCType: @encode(id) at: &name];
    [decoder decodeValueOfObjCType: @encode(id) at: &identifier];
    [decoder decodeValueOfObjCType: @encode(BOOL) at: &isReadOnly];
    [decoder decodeValueOfObjCType: @encode(BOOL) at: &isForCreation];
    return self;
}

@end
