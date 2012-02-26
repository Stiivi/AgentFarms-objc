/** AFObjectConnection

    Copyright (c) 2003 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2003 Jul 1 
    
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

#import "AFObjectConnection.h"

#import <Foundation/NSCoder.h>
#import <Foundation/NSString.h>

@implementation AFObjectConnection
- (void)dealloc
{
    RELEASE(sourceName);
    RELEASE(destinationName);
    RELEASE(relationshipName);
    [super dealloc];
}
- (void)setSourceName:(NSString *)name
{
    ASSIGN(sourceName, name);
}
- (NSString *)sourceName
{
    return sourceName;
}
- (void)setDestinationName:(NSString *)name
{
    ASSIGN(destinationName,name);
}
- (NSString *)destinationName
{
    return destinationName;
}
- (void)setRelationshipName:(NSString *)name
{
    ASSIGN(relationshipName, name);
}
- (NSString *)relationshipName
{
    return relationshipName;
}
- (void)encodeWithCoder:(NSCoder *)coder
{
    // [super encodeWithCoder: coder];

    [coder encodeObject:sourceName];
    [coder encodeObject:destinationName];
    [coder encodeObject:relationshipName];
}

- initWithCoder:(NSCoder *)decoder
{
    self = [super init]; // [super initWithCoder: decoder];
    
    [decoder decodeValueOfObjCType: @encode(id) at: &sourceName];
    [decoder decodeValueOfObjCType: @encode(id) at: &destinationName];
    [decoder decodeValueOfObjCType: @encode(id) at: &relationshipName];

    return self;
}

@end
