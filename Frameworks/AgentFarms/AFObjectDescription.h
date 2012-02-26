/** AFObjectDescription

    Copyright (c) 2002 Stefan Urbanek

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

@class NSMutableDictionary;
@class AFClassDescription;

@interface AFObjectDescription:NSObject
{
    NSMutableDictionary *attributes;
    NSString            *objectClassName;

    NSMutableDictionary *relationshipDictionary;
    
    BOOL isCollection;
}
-     initWithObject:(id)anObject 
    classDescription:(AFClassDescription *)classDesc;
    
- initWithDictionary:(NSDictionary *)dict;
- (NSString *)objectClassName;
- (id)valueForPropertyKey:(NSString *)key;
- (void)setValue:(id)object forPropertyKey:(NSString *)key;
- (NSDictionary *)attributes;

- (id)referenceForRelationship:(NSString *)identifier;
- (void)setReference:(id)ref forRelationship:(NSString *)identifier;

- (BOOL)isCollection;
@end

