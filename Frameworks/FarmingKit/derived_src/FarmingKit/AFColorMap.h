/** AFColorMap

    Copyright (c) 2003 Stefan Urbanek

    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2003 Oct 5
   
    This file is part of the AgentFarms suite.
 
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

#import <AppKit/NSView.h>

@class NSColor;
@class NSArray;

@interface AFColorMap:NSView
{
    NSArray *colors;
    NSColor *undefinedColor;
    int      count;
}
+ colorMapWithGrayGrades:(int)grades;
- initWithGrayGrades:(int)grades;
- (int)count;
- (NSColor *)colorAtIndex:(int)index;
- (NSColor *)undefinedColor;
@end
