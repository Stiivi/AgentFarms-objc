/* NSArray
 
    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2003 Sep 18
   
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

#import "NSArray+additions.h"

#import "AFObjectPrototype.h"

@implementation NSArray(AgentFarms)
+ (NSArray *)arrayWithObjectsFromPrototype:(AFObjectPrototype *)prototype
                                     count:(int)count;
{
    NSMutableArray *array;
    int i;
    id  object;
    
    array = [NSMutableArray array];
    
    for(i = 0; i < count ; i++)
    {
        object = [prototype instantiate];
        [array addObject:object];
    }
    
    return AUTORELEASE([[self alloc] initWithArray:array]);
}
@end

@implementation NSMutableArray(AgentFarms)
/** Remove all objects that are dead, that means, all objects that return NO
    on isLive method. */
- (int)removeDeadObjects
{
    NSEnumerator *enumerator = [self objectEnumerator];
    id            object;
    int           count = 0;
    
    while( (object = [enumerator nextObject]) )
    {
        if(![object isLive])
        {
            [self removeObject:object];
            count ++;
        }
    }
    
    return count;
}
@end
