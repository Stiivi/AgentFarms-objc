/** AFObjectDescription

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

#import "AFObjectDescription.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>
#import "AFClassDescription.h"
#import "AFClassDescription.h"

@implementation AFObjectDescription
-     initWithObject:(id)anObject 
    classDescription:(AFClassDescription *)classDesc
{
    NSEnumerator        *enumerator = nil;
    NSString            *key;
    
    self = [super init];
    
    if(!anObject)
    {
        NSLog(@"WARNING: Description for nil object - ignore");
        [self dealloc];
        return nil;
    }

    objectClassName = RETAIN([classDesc name]);

    attributes = [[NSMutableDictionary alloc] init];
    enumerator = [[classDesc attributeKeys] objectEnumerator];
    while( (key = [enumerator nextObject]) )
    {
        /* FIXME: Slow */
        NS_DURING
            [attributes setObject:[anObject valueForKey:key] forKey:key];
        NS_HANDLER
            [NSException raise:@"AFObjectDescriptionException"
                         format:@"Unable to get value from object of type %@ for key %@."
                               @"Reason: %@ (%@)",
                                [anObject className],
                                key,
                                [localException reason],
                                [localException name]];
            // NSUnknownKeyException
        NS_ENDHANDLER
    }

    relationshipDictionary = [[NSMutableDictionary alloc] init];

    isCollection = [classDesc isCollection];
    
    return self;
}
- initWithDictionary:(NSDictionary *)dict
{
    [super init];

    objectClassName = RETAIN([dict objectForKey:@"Class"]);
    attributes = [[NSMutableDictionary alloc] initWithDictionary: 
                                        [dict objectForKey:@"Attributes"]];
    
    relationshipDictionary = [[NSMutableDictionary alloc] init];
    /* FIXME: do some check here of attribs. */
    return self;
}
- (void) dealloc
{
    RELEASE(attributes);
    RELEASE(objectClassName);
    RELEASE(relationshipDictionary);
    [super dealloc];
}
- (NSString *)objectClassName
{
    return objectClassName;
}
- (id)valueForPropertyKey:(NSString *)key
{
    return [attributes objectForKey:key];
}
- (NSDictionary *)attributes
{
    return attributes;
}
- (void)setValue:(id)object forPropertyKey:(NSString *)key
{
    [attributes setObject:object forKey:key];
}

- (id)referenceForRelationship:(NSString *)identifier
{
    return [relationshipDictionary objectForKey:identifier];
}

- (void)setReference:(id)ref forRelationship:(NSString *)identifier
{
    [relationshipDictionary setObject:ref forKey:identifier];
}

- (BOOL)isCollection
{
    return isCollection;
}

/* Serialisation */
- (void)encodeWithCoder:(NSCoder *)coder
{
    // [super encodeWithCoder: coder];

    [coder encodeObject:objectClassName];
    [coder encodeObject:attributes];
    [coder encodeObject:relationshipDictionary];
    [coder encodeValueOfObjCType: @encode(BOOL) at: &isCollection];
}

- initWithCoder:(NSCoder *)decoder
{
    self = [super init]; //[super initWithCoder: decoder];
    
    [decoder decodeValueOfObjCType: @encode(id) at: &objectClassName];
    [decoder decodeValueOfObjCType: @encode(id) at: &attributes];
    [decoder decodeValueOfObjCType: @encode(id) at: &relationshipDictionary];
    [decoder decodeValueOfObjCType: @encode(BOOL) at: &isCollection];

    return self;
}
@end

