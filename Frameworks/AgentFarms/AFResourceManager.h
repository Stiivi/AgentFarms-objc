/** AFResourceManager

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 Jul 4
    
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

@interface AFResourceManager:NSObject
{
}
+ defaultManager;
+ (NSString *)localFarmsDirectory;

- (NSArray *)libraryPathsForResources:(NSString *)res;
- (NSArray *)allResourcesOfType:(NSString *)type
                    inDirectory:(NSString *)resourceDir;
- (NSString *)pathForResource:(NSString *)resName 
                       ofType:(NSString *)type
                  inDirectory:(NSString *)resDir;
@end
