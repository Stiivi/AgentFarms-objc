/** AFClassDescription

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

#import "AFClassDescription.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import "AFAttributeDescription.h"
#import "AFRelationshipDescription.h"
#import "NSArray+iterations.h"

@implementation AFClassDescription
- initWithName:(NSString *)aName descriptionDictionary:(NSDictionary *)dict
{
    AFRelationshipDescription *rel;
    AFAttributeDescription *attr;
    NSMutableDictionary    *newDict;
    NSMutableArray         *newArray;
    NSMutableDictionary    *newDict2;
    NSMutableArray         *newArray2;
    NSEnumerator           *enumerator;
    NSDictionary           *adict;
    NSArray                *array;
    
    [super init];
    
    name = [aName copy];
    
    /* Initialise attributes */
 
    newArray = [NSMutableArray array];
    newDict = [NSMutableDictionary dictionary];

    /* temporary creation attributes */
    newArray2 = [NSMutableArray array];
    newDict2 = [NSMutableDictionary dictionary];

    array = [dict objectForKey:@"Attributes"];
    enumerator = [array objectEnumerator];
    
    while( (adict = [enumerator nextObject]) )
    {
        attr = [[AFAttributeDescription alloc] initWithDictionary:adict];
        AUTORELEASE(attr);
        
        if(![attr isForCreation])
        {
            [newDict setObject:attr forKey:[attr identifier]];
            [newArray addObject:attr];
        }
        if(![attr isReadOnly])
        {
            [newDict2 setObject:attr forKey:[attr identifier]];
            [newArray2 addObject:attr];
        }
        
    }
    
    if([newDict count])
    {
        attrDictionary = [[NSDictionary alloc] initWithDictionary:newDict];
        attributes = [[NSArray alloc] initWithArray:newArray];
    }
    
    if([newDict2 count])
    {
        cattrDictionary = [[NSDictionary alloc] initWithDictionary:newDict2];
        creationAttributes = [[NSArray alloc] initWithArray:newArray2];
    }
    
    /* Relationships */
    array = [dict objectForKey:@"Relationships"];
    enumerator = [array objectEnumerator];

    newArray = [NSMutableArray array];
    newDict = [NSMutableDictionary dictionary];
    
    while( (adict = [enumerator nextObject]) )
    {
        rel = [[AFRelationshipDescription alloc] initWithDictionary:adict];
        AUTORELEASE(rel);
        [newDict setObject:rel forKey:[rel identifier]];
        [newArray addObject:rel];
    }
    
    if([newArray count])
    {
        relationships = [[NSArray alloc] initWithArray:newArray];
        relationshipDict = [[NSDictionary alloc] initWithDictionary:newDict];
    }

    isCollection = [dict boolForKey:@"IsCollection"];

    return self;
}
- (void)dealloc
{
    RELEASE(name);
    RELEASE(attributes);
    RELEASE(attrDictionary);
    RELEASE(creationAttributes);
    RELEASE(cattrDictionary);
    RELEASE(relationships);
    RELEASE(relationshipDict);

    [super dealloc];
}

/** Returns class name */
- (NSString *)name
{
    return name;
}

/** Returns array of instance attribute keys.*/
- (NSArray *)attributeKeys
{
    return [attributes makeObjectsPerformSelectorAndCollect:@selector(identifier)];
}

/** Returns array of object prototype attribute keys */
- (NSArray *)creationPropertyKeys
{
    return [creationAttributes makeObjectsPerformSelectorAndCollect:@selector(identifier)];
}

/** Returns array of relationships refering to other single objects. */
- (NSArray *)relationshipDescriptions
{
    return relationships;
}

- (NSArray *)relationshipKeys
{
    AFRelationshipDescription *rel;
    NSMutableArray            *array = [NSMutableArray array];
    NSEnumerator              *enumerator;

    enumerator = [relationships objectEnumerator];

    while( (rel = [enumerator nextObject]) )
    {
        [array addObject:[rel identifier]];
    }

    return [NSArray arrayWithArray:array];
}
- (AFRelationshipDescription *)relationshipWithIdentifier:(NSString *)aString
{
    return [relationshipDict objectForKey:aString];
}

/** Returns a description for attribute with identifier <var>identifier</var>.*/
- (AFAttributeDescription *)attributeWithIdentifier:(NSString *)aName
{
    return [attrDictionary objectForKey:aName];
}

/** Returns a description for attribute at index <var>index</var>.*/
- (AFAttributeDescription *)attributeAtIndex:(int)index
{
    return [attributes objectAtIndex:index];
}

/** Returns a description for object prototype attribuet with identifier <var>identifier</var>.*/
- (AFAttributeDescription *)creationAttributeWithIdentifier:(NSString *)aName
{
    return [cattrDictionary objectForKey:aName];
}

/** Returns number of attributes of class instances. */
- (int)numberOfAttributes
{
    return [attributes count];
}

/** Returns number of attributes of object prototypes */
- (int)numberOfCreationAttributes
{
    return [creationAttributes count];
}
- (BOOL)isCollection
{
    return isCollection;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    // [super encodeWithCoder: coder];

    [coder encodeObject:name];
    
    [coder encodeObject:attributes];
    [coder encodeObject:attrDictionary];
    [coder encodeObject:creationAttributes];
    [coder encodeObject:cattrDictionary];

    [coder encodeObject:relationships];
    [coder encodeObject:relationshipDict];
    [coder encodeValueOfObjCType: @encode(BOOL) at: &isCollection];
}

- initWithCoder:(NSCoder *)decoder
{
    self = [super init]; //[super initWithCoder: decoder];
    
    [decoder decodeValueOfObjCType: @encode(id) at: &name];
    
    [decoder decodeValueOfObjCType: @encode(id) at: &attributes];
    [decoder decodeValueOfObjCType: @encode(id) at: &attrDictionary];
    [decoder decodeValueOfObjCType: @encode(id) at: &creationAttributes];
    [decoder decodeValueOfObjCType: @encode(id) at: &cattrDictionary];

    [decoder decodeValueOfObjCType: @encode(id) at: &relationships];
    [decoder decodeValueOfObjCType: @encode(id) at: &relationshipDict];
    [decoder decodeValueOfObjCType: @encode(BOOL) at: &isCollection];
    return self;
}

@end
