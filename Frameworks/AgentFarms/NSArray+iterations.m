/** NSArray(Iterations)

    Copyright (c) 2003 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2003 Jul 6
    
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

#import"NSArray+iterations.h"

#import <Foundation/NSEnumerator.h>
#import <Foundation/NSNull.h>

#import "AFObjectPrototype.h"

@implementation NSArray(Iterations)
- initWithObjectsFromPrototype:(AFObjectPrototype *)prototype
                         count:(int)count
{
    NSMutableArray *array;
    int             i;
    
    array = [[NSMutableArray alloc] init];
    
    for(i = 0; i < count ; i++)
    {
        [array addObject:[prototype instantiate]];
    }
    
    self = [self initWithArray:array];
    RELEASE(array);
    return self;
}
- (NSArray *)makeObjectsPerformSelectorAndCollect:(SEL)selector
{
    NSEnumerator  *enumerator;
    id             object;
    NSMutableArray *array = [NSMutableArray array];
    
    enumerator = [self objectEnumerator];
    
    while( (object = [enumerator nextObject]) )
    {
        object = [object performSelector:selector];
        if(!object)
        {
            object = [NSNull null];
        }
        [array addObject:object];
    }
    
    return [NSArray arrayWithArray:array];
}
@end
