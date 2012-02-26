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

#import <Foundation/NSObject.h>

@class NSArray;
@class AFAttributeDescription;
@class AFRelationshipDescription;

@interface AFClassDescription:NSObject
{
    AFClassDescription *superDescription;
    NSString           *name;
    NSArray            *attributes;
    NSDictionary       *attrDictionary;
    NSArray            *creationAttributes;
    NSDictionary       *cattrDictionary;
    
    NSDictionary *relationshipDict;
    NSArray      *relationships;
    
    BOOL                isCollection;
}
- initWithName:(NSString *)name descriptionDictionary:(NSDictionary *)dict;

- (NSString *)name;

- (NSArray *)creationPropertyKeys;
- (int)numberOfCreationAttributes;

- (NSArray *)attributeKeys;
- (int)numberOfAttributes;

- (AFAttributeDescription *)attributeWithIdentifier:(NSString *)aName;
- (AFAttributeDescription *)attributeAtIndex:(int)index;
- (AFAttributeDescription *)creationAttributeWithIdentifier:(NSString *)aName;

- (NSArray *)relationshipDescriptions;
- (AFRelationshipDescription *)relationshipWithIdentifier:(NSString *)aString;

- (AFClassDescription *)superClassDescription;

- (BOOL)isCollection;
@end
