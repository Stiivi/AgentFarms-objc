/** AFProbe

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 Nov 27
    
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

@class AFEnvironment;
@class AFProbeSpecification;
@class AFNumberCollection;

@interface AFProbe:NSObject
{
    NSString           *propertyIdentifier;
    id                  objectReference;
    id                  target;
    
    AFNumberCollection *collection;
}
/* Creating */
+ probeWithTemplate:(AFProbeSpecification *)template;
+ probeWithPropertyName:(NSString *)propName objectReference:(id)ref;

- initWithTemplate:(AFProbeSpecification *)template;
- initWithPropertyName:(NSString *)propName objectReference:(id)ref;

/* Target and reference */
- (void)setObjectReference:(id)aReference;
- (id)objectReference;
- (id)target;

/* Connecting */
- (BOOL)connectInEnvironment:(AFEnvironment *)aSimulation;
- (BOOL)isConnected;
- (void)disconnect;

/* Probing */
- (double)doubleValue;

- (AFProbeSpecification *)probeSpecification;

/* Collecting */
- (AFNumberCollection *)collection;
- (void)setCollection:(AFNumberCollection *)aCol;
- (void)collect;
@end
