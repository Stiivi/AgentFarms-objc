/** Controller
 
    Copyright (c) 2003 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2003 Apr 26
    
    This file is part of the Farmer application.
 
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

#import "AppController.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSUserDefaults.h>

#import <FarmsFarmer/AFLatticeView.h>
#import <FarmsData/AFLattice.h>

@interface AppController(Private)
@end

@implementation AppController
- (void)applicationDidFinishLaunching:(id)notif
{
    AFLattice *lattice;
    int        width = 200, height = 100;
    int        x, y;
    
    lattice = [[AFLattice alloc] initWithWidth:width height:height];
  
    for(x = 0; x < width; x++)
    {
        for(y = 0; y < height; y++)
        {
            [lattice setInt: x
                        atX:x 
                          y:y];
        }
    }
    NSLog(@"View %@", view);
    [view setLattice:lattice];
    [view setNeedsDisplay:YES];
}
@end
