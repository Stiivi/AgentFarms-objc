/** AFGraphView 

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

#import <AppKit/NSView.h>

@class AFGraphElement;
// @class AFGraphLegend;
@class AFRect;
@class AFGraph;
@class NSScroller;

@interface  AFGraphView:NSView
{
    AFGraph           *graph;           /* Graph being displayed */
    AFRect            *graphWindow;     /* Portion of graph */
    AFRect            *graphBounds;     /* Rectangle wrapping whole graph */

    /* Background   */
    BOOL               drawsBackground;
    NSColor           *backgroundColor;

    /* Grid */
    BOOL               drawsGrid;
    NSColor           *gridColor;

    /* Ruler */
    NSColor           *rulerColor;
    BOOL               rulerVisible;
    NSFont            *rulerFont;
    NSDictionary      *tickLabelAttributes;

    /* Layout */
    NSRect             graphFrame;
    NSSize             rulerSize;
    BOOL               autosizesRuler;
    NSSize             paddingSize;
    BOOL               autosizesPadding;

    BOOL               isDragging;
    BOOL               scalesGraphToFit;
    
    /* FIXME */
    id                 legendView;
    BOOL               legendVisible;   

}

- (void)setTitle:(NSString *)aString;
- (NSString *)title;

- (void)addElement:(AFGraphElement *)graph;
- (void)removeElement:(AFGraphElement *)graph;
- (void)removeAllElements;
- (void)setElements:(NSArray *)array;
- (NSArray *)elements;

- (void)setBackgroundColor:(NSColor *)color;
- (NSColor *)backgroundColor;

- (void)setDrawsBackground:(BOOL)flag;
- (BOOL)drawsBackground;

- (void)setGridColor:(NSColor *)color;
- (NSColor *)gridColor;

- (void)setDrawsGrid:(BOOL)flag;
- (BOOL)drawsGrid;

- (void)setRulerVisible:(BOOL)flag;
- (BOOL)rulerVisible;

- (void)setRulerFont:(NSFont *)font;
- (NSFont *)rulerFont;
- (void)setRulerColor:(NSColor *)color;
- (NSColor *)rulerColor;

- (void)setLegendVisible:(BOOL)flag;
- (BOOL)legendVisible;

/*
- (void)setLegendView:(AFGraphLegendView *)aView;
- (AFGraphLegendView *)legendView;
*/

- (AFGraph *)graph;
- (void)setGraph:(AFGraph *)aGraph;

- (void)setRulerSize:(NSSize)size;
- (NSSize)rulerSize;
- (void)setAutosizesRuler:(BOOL)flag;
- (BOOL)autosizesRuler;

- (void)setPaddingSize:(NSSize)size;
- (NSSize)paddingSize;
- (void)setAutosizesPadding:(BOOL)flag;
- (BOOL)autosizesPadding;

- (void)setScalesGraphToFit:(BOOL)flag;
- (BOOL)scalesGraphToFit;
@end
