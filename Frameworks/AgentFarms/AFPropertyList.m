/** AFPropertyList

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 Oct 14 
    
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

#import "AFPropertyList.h"

#import "AFProperty.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSString.h>

@implementation AFPropertyList
+ propertyListWithArray:(NSArray *)anArray
{
    return AUTORELEASE([[AFPropertyList alloc] initWithProperties:anArray]);
}
- initWithProperties:(NSArray *)anArray
{
    NSMutableDictionary *dict;
    NSEnumerator        *enumerator;
    AFProperty          *property;

    [super init];

    ASSIGN(properties, anArray);
    
    dict = [NSMutableDictionary dictionary]; 

    enumerator = [anArray objectEnumerator];
    
    while( (property = [enumerator nextObject]) )
    {
        [dict setObject:property forKey:[property name]];
    }

    nameDictionary = [NSDictionary dictionaryWithDictionary:dict];
    RETAIN(nameDictionary);

    return self;
}
- (void)dealloc
{
    RELEASE(nameDictionary);
    RELEASE(properties);
    [super dealloc];
}
- (NSArray *)propertiesAsArray
{
    return properties;
}
- (NSDictionary *)propertiesAsDictionary
{
    return nameDictionary;
}
- (AFProperty *)propertyWithName:(NSString *)aString
{
    return [nameDictionary objectForKey:aString];
}
- (NSArray *)allNames
{
    return [nameDictionary allKeys];
}
- (int)count
{
    return [properties count];
}
@end
