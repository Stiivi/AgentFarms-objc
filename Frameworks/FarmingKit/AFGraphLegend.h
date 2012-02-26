/** AFGraphLegend 

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2003 May 17
   
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


#import <AppKit/NSView.h>

@class AFGraph;
@class AFGraphView;
@class NSFont;
@class NSColor;

@interface AFGraphLegend:NSObject
{
    AFGraph     *graph;
    
    NSFont      *titleFont;
    NSFont      *elementFont;
    
    NSString    *title;
    
    BOOL         isBordered;
    BOOL         drawsBackground;
    NSColor     *backgroundColor;
    
    float        margin;
}
- (void)setGraph:(AFGraph *)aGraph;
- (AFGraph *)graph;

- (void)setTitle:(NSString *)aString;
- (NSString *)title;

- (void)setTitleFont:(NSFont *)aFont;
- (NSFont *)titleFont;

- (void)setElementFont:(NSFont *)aFont;
- (NSFont *)elementFont;

- (void)setBordered:(BOOL)flag;
- (BOOL)isBordered;

- (void)setDrawsBackground:(BOOL)flag;
- (void)drawsBackground;
- (void)setBackgroundColor:(NSColor *)color;
- (NSColor *)backgroundColor;

- (void)setMargin:(float)value;
- (float)margin;
@end
