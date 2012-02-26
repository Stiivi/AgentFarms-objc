/** NSDictionary+convenience
    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 Oct 10
    
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

#import "NSDictionary+convenience.h"

#import <Foundation/NSValue.h>

@implementation NSDictionary(AFConvenience)
- (BOOL)boolForKey:(id)key
{
    return [[self objectForKey:key] boolValue];
}
- (int)intForKey:(id)key
{
    return [[self objectForKey:key] intValue];
}
- (float)floatForKey:(id)key
{
    return [[self objectForKey:key] floatValue];
}
- (double)doubleForKey:(id)key
{
    return [[self objectForKey:key] doubleValue];
}
@end

@implementation NSMutableDictionary(AFConvenience)
- (void)setBool:(BOOL)value forKey:(id)key
{
    [self setObject:[NSNumber numberWithBool:value] forKey:key];
}
- (void)setInt:(int)value forKey:(id)key;
{
    [self setObject:[NSNumber numberWithInt:value] forKey:key];
}
- (void)setFloat:(float)value forKey:(id)key
{
    [self setObject:[NSNumber numberWithFloat:value] forKey:key];
}
- (void)setDouble:(double)value forKey:(id)key
{
    [self setObject:[NSNumber numberWithDouble:value] forKey:key];
}
@end
