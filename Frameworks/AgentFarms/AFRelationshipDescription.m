/** AFRelationshipDescription

    Copyright (c) 2003 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2003 Jul 26
    
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

#import "AFRelationshipDescription.h"

#import <Foundation/NSCoder.h>

@implementation AFRelationshipDescription
- initWithDictionary:(NSDictionary *)dict 
{
    self = [super init];
    
    name = RETAIN([dict objectForKey:@"Name"]);
    identifier = RETAIN([dict objectForKey:@"Identifier"]);
    objectClassName = RETAIN([dict objectForKey:@"Class"]);
    if([[dict objectForKey:@"Type"] isEqualToString:@"Collection"])
    {
        isToMany = YES;
    }
    
    return self;
}
- (void)dealloc
{
    RELEASE(name);
    RELEASE(identifier);
    RELEASE(objectClassName);
    [super dealloc];
}
- (NSString *)name
{
    return name;
}
- (NSString *)identifier
{
    return identifier;
}
- (BOOL)isToMany
{
    return isToMany;
}
- (NSString *)objectClassName
{
    return objectClassName;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    // [super encodeWithCoder: coder];

    [coder encodeObject:name];
    [coder encodeObject:identifier];
    [coder encodeObject:objectClassName];
    [coder encodeValueOfObjCType: @encode(BOOL) at: &isToMany];
}

- initWithCoder:(NSCoder *)decoder
{
    self = [super init]; //[super initWithCoder: decoder];
    
    [decoder decodeValueOfObjCType: @encode(id) at: &name];
    [decoder decodeValueOfObjCType: @encode(id) at: &identifier];
    [decoder decodeValueOfObjCType: @encode(id) at: &objectClassName];
    [decoder decodeValueOfObjCType: @encode(BOOL) at: &isToMany];
    return self;
}


@end
