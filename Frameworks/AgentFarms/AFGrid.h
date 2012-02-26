/** AFGrid

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

#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>

typedef enum
{
    AFNoGridDirection,
    AFUpGridDirection,
    AFRightGridDirection,
    AFDownGridDirection,
    AFLeftGridDirection
} AFGridDirection;

@class NSArray;
@class NSMutableArray;

@interface AFGrid:NSObject
{
    NSMutableArray *objects;
    NSMutableArray *points;
    
    unsigned int width, height;
    
    BOOL wraps;
}
- initWithWidth:(unsigned int)w height:(unsigned int)h;

- (void)putObject:(id)anObject atLocation:(NSPoint)point;
- (NSPoint)locationOfObject:(id)anObject;
- (BOOL)containsObject:(id)anObject;
- (void)moveObject:(id)anObject direction:(AFGridDirection)dir;
- (void)removeObject:(id)anObject;
- (void)removeAllObjects;
- (NSArray *)allObjects;
- (BOOL)wraps;
- (void)setWraps:(BOOL)flag;
@end
