/** AFGraphElement

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2002 Oct 6
   
    This file is part of the AgentFarmsViewsramework.
 
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

enum
{
    AFSolidLineDashStyle = 0,
    AFDashedLineDashStyle,
    AFDashDotLineDashStyle
};

@class NSColor;
@class AFRect;

@interface AFGraphElement:NSObject<NSCoding>
{
    NSString *label;
    NSColor  *color;
    float     lineWidth;
}
+ (void)setDefaultColor:(NSColor *)aColor;
+ (NSColor *)defaultColor;

- (void)setLabel:(NSString *)aString;
- (NSString *)label;

- (void)setColor:(NSColor *)aColor;
- (NSColor *)color;

- (void)setLineWidth:(float)width;
- (float)lineWidth;

- (void)setLineDashType:(int)type;
- (int)lineDashType;

- (double)minX;
- (double)minY;
- (double)maxX;
- (double)maxY;

- (AFRect *)bounds;

- (void)drawLegendSampleInRect:(NSRect)frame;
@end
