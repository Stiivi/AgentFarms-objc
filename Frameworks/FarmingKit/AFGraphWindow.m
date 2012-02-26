/** AFGraphWindow

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2002 Oct 24
   
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

#import "AFGraphWindow.h"

#import "AFGraphView.h"
#import "AFGraphElement.h"
#import "AFGeometry.h"

@implementation AFGraphWindow
- init
{
    [super init];
    
    windowType = AFGraphScalesToFit;
    
    return self;
}
- initFromGraphView:(AFGraphView *)view
{
    [super init];
    
    if([view scalesToFit])
    {
        window = RETAIN([view graphBounds]);
        windowType = AFGraphScalesToFit;
    }
    else
    {
        window = RETAIN([view graphWindow]);
        windowType = AFGraphFixedWindow;
    }

    return self;
}
/**************************************************************************
    Graph window
**************************************************************************/
- (void)dealloc
{
    RELEASE(window);
    [super dealloc];
}
- (void)applyToGraphViews:(NSArray *)array
{
    NSEnumerator *enumerator = [array objectEnumerator];
    AFGraphView  *view;
    
    while( (view = [enumerator nextObject]) )
    {
        [self applyToGraphView:view];
    }
    
}

- (void)applyToGraphView:(AFGraphView *)graphView;
{
    [graphView setGraphWindow:window];

    if(windowType == AFGraphScalesToFit)
    {
        [graphView setScalesToFit:YES];
    }
    else
    {
        [graphView setScalesToFit:NO];
    }
}
- (void)setWindowRect:(AFRect *)rect
{
    ASSIGN(window,rect);
}
- (AFRect *)windowRect
{
    return window;
}
- (void)setWindowType:(int)type
{
    windowType = type;
}
- (int)windowType
{
    return windowType;
}
@end
