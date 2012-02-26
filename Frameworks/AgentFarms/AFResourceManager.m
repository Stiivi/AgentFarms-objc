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

#import "AFResourceManager.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSUserDefaults.h>

AFResourceManager *defaultResourceManager = nil;

static BOOL create_directory(NSString *path)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *par = [path stringByDeletingLastPathComponent];

    if( [fm fileExistsAtPath:path] )
    {
        return YES;
    }
    else if( ![fm fileExistsAtPath:par] )
    {
        if(!create_directory(par))
        {
            return NO;
        }
    }

    return [fm createDirectoryAtPath:path attributes:nil];
}

@interface AFResourceManager(Private)
- (NSString *)fileExtensionForResourcesOfType:(NSString *)aType;
- (NSString *)_directoryForResourcesOfType:(NSString *)aType;
@end

@implementation AFResourceManager:NSObject
+ defaultManager
{
    if(!defaultResourceManager)
    {
        defaultResourceManager = [[AFResourceManager alloc] init];
    }
    return defaultResourceManager;
}

- (NSArray *)libraryPathsForResources:(NSString *)res
{
    NSMutableArray *array = [NSMutableArray array];
    NSFileManager  *manager = [NSFileManager defaultManager];
    NSEnumerator   *enumerator;
    NSString       *path;
    NSArray        *paths;

    paths = NSStandardLibraryPaths();

    enumerator = [paths objectEnumerator];
    
    while( (path = [enumerator nextObject]) )
    {
        path = [path stringByAppendingPathComponent:@"AgentFarms"];
        if(res)
        {
            path = [path stringByAppendingPathComponent:res];
        }
        if( [manager fileExistsAtPath:path] )
        {
            [array addObject:path];
        }
    }
    
    return [NSArray arrayWithArray:array];
}

- (NSArray *)allResourcesOfType:(NSString *)type
                    inDirectory:(NSString *)resourceDir
{
    NSMutableArray *array = [NSMutableArray array];
    NSFileManager  *manager = [NSFileManager defaultManager];
    NSEnumerator   *enumerator;
    NSString       *path;
    NSArray        *paths;

    paths = [self libraryPathsForResources:resourceDir];

    enumerator = [paths objectEnumerator];
    
    while( (path = [enumerator nextObject]) )
    {
        [array addObjectsFromArray:[manager directoryContentsAtPath:path]];
    }
    
    enumerator = [[NSSet setWithArray:array] objectEnumerator];
    
    [array removeAllObjects];
    
    while( (path = [enumerator nextObject]) )
    {
        if([[path pathExtension] isEqualToString:type])
        {
            [array addObject:[path stringByDeletingPathExtension]];
        }
    }
    
    return [NSArray arrayWithArray:array];
}

- (NSString *)pathForResource:(NSString *)resName 
                       ofType:(NSString *)type
                  inDirectory:(NSString *)resDir
{
    NSFileManager  *manager = [NSFileManager defaultManager];
    NSEnumerator   *enumerator;
    NSString       *path;
    NSString       *file;
    NSArray        *paths;

    paths = [self libraryPathsForResources:resDir];

    enumerator = [paths objectEnumerator];
    
    while( (path = [enumerator nextObject]) )
    {
        file = [path stringByAppendingPathComponent:resName];
        file = [file stringByAppendingPathExtension:type];
        
        if( [manager fileExistsAtPath:file] )
        {
            return file;
        }
    }
    
    NSLog(@"Warning: Resource '%@' of type '%@' in '%@' not found",
           resName, type, resDir);
           
    return nil;
}

+ (NSString *)localFarmsDirectory
{                                                                               
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSString       *path = nil;
    NSArray        *paths;
                                                                 
    path = [defs objectForKey:@"AFFarmsDirectory"];
    
    if(!path || [path isEqualToString:@""])
    {
        paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                    NSUserDomainMask, YES); 
        path = [paths objectAtIndex: 0];

        path = [path stringByAppendingPathComponent:@"AgentFarms"];
        path = [path stringByAppendingPathComponent:@"Farms"];

    }
    
    create_directory(path);
    return path;
}
@end
