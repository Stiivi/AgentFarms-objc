/** AFModel

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 Jul 4 
    
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

@class AFPropertyList;
@class NSDicitonary;
@class NSBundle;
@class AFObjectPrototype;
@class AFClassDescription;

@interface AFModel:NSObject<NSCoding>
{    
    NSString *name;
    
    int       defaultStepCount;
    
    NSDictionary *classDescriptions;
    NSDictionary *prototypes;
    NSArray      *objects;
    NSArray      *connections;
    NSArray      *probes;
    NSArray      *views;
}
+ modelFromFile:(NSString *)file;
- initFromFile:(NSString *)file;

- (NSString *)name;
- (int)defaultStepCount;

- (NSDictionary *)prototypes;
- (bycopy NSArray *)prototypeNames;

- (NSArray *)objects;
- (NSArray *)connections;

- (AFObjectPrototype *)prototypeWithName:(NSString *)aName;
- (NSArray *)objects;
- (NSArray *)connections;
- (NSArray *)views;

- (NSArray *)classDescriptions;
- (NSArray *)requiredClasses;

- (AFClassDescription *)descriptionForClassWithName:(NSString *)name;

- (NSArray *)probeTemplates;
@end
