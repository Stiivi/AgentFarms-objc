/** AFFarmStore
 
    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2003 Aug 10
    
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

#import "AFFarmStore.h"

#import <Foundation/NSArchiver.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

static NSString *AFStoreInfoFile = @"storeInfo";

@interface AFFarmStore(Private)
@end

@implementation AFFarmStore:NSObject
+ storeWithPath:(NSString *)aPath create:(BOOL)flag
{
    AFFarmStore *store = [[AFFarmStore alloc] initWithPath:aPath create:flag];
    return AUTORELEASE(store);
}

/**
    Init
*/
- initWithPath:(NSString *)aPath create:(BOOL)create
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary  *dict;
    NSString      *file;
    BOOL           isDir;
    
    self = [super init];

    if(!create && ![manager fileExistsAtPath:aPath isDirectory:&isDir])
    {
        [NSException raise:@"AFFarmStoreException"
                     format:@"Farm store already exists at '%@'", aPath];
        [self dealloc];
        return nil;
    }
    
    path = RETAIN(aPath);
 
    if(create && ![self create])
    {
        [NSException raise:@"AFFarmStoreException"
                     format:@"Unable to create store at path '%@'", aPath];
        [self dealloc];
        return nil;
    }
 
    dict = [self propertyListWithName:AFStoreInfoFile];
    commitCount = [[dict objectForKey:@"CommitCount"] intValue];

    return self;
}

- (void)dealloc
{
    RELEASE(path);
    [super dealloc];
}

/** Returns store path */
- (NSString *)path
{
    return path;
}

- (BOOL)create
{
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL           isDir;
        
    if([manager fileExistsAtPath:path isDirectory:&isDir])
    {
        return isDir == YES;
    }

    return [manager createDirectoryAtPath:path attributes:nil];
}
/**
    Set store path. Path should not be nil or an empty string. If path does
    not have <code>.afarm</code> extension, it will be added.
*/
- (BOOL)setPath:(NSString *)aPath
{
    if(!aPath || [aPath isEqualToString:@""])
    {
        [NSException raise:@"AFFarmStoreException"
                    format:@"Farm store path should not be nil or empty string."];

        return NO;
    }
    
    ASSIGN(path, aPath);

    return YES;
}

- (NSString *)pathForPropertyListWithName:(NSString *)aString
{
    aString = [aString stringByAppendingPathExtension:@"plist"];
    return [path stringByAppendingPathComponent:aString];
}

- (NSString *)pathForObjectWithName:(NSString *)aString
{
    aString = [aString stringByAppendingPathExtension:@"data"];
    return [path stringByAppendingPathComponent:aString];
}

/** Save all objects and property lists. Not used yet, 
    only for saving commit count. */
- (void)commit
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    commitCount++;
    
    [dict setObject:[NSNumber numberWithInt:commitCount] forKey:@"CommitCount"];
    [self storePropertyList:dict withName:AFStoreInfoFile];
}

- (BOOL)storeObject:(id)anObject withName:(NSString *)objectName
{
    NSString *file;
    
    file = [self pathForObjectWithName:AFStoreInfoFile];
    
    if(![NSArchiver archiveRootObject:anObject toFile:file])
    {
        NSLog(@"Unable to archive object %@ at '%@'", objectName, path);
        return NO;
    }
    return YES;
}

- (BOOL)storePropertyList:(id)plist withName:(NSString *)plistName
{
    NSString *file;
    
    file = [self pathForPropertyListWithName:plistName];
    
    if(![plist writeToFile:file atomically:YES])
    {
        NSLog(@"Unable to archive plist %@ at '%@'", plistName, path);
        return NO;
    }
    return YES;
}

/**
    Restore and return an object.
*/
- (id)objectWithName:(NSString *)objectName
{
    NSString *file;
    id object;

    file = [self pathForObjectWithName:objectName];
    
    object = [NSUnarchiver unarchiveObjectWithFile:file];

    return object;
}

/**
    Restore and return a property list with given name.
*/
- (id)propertyListWithName:(NSString *)plistName
{
    NSString *file;
    id plist;

    file = [self pathForPropertyListWithName:plistName];
    
    plist = [[NSString stringWithContentsOfFile:file] propertyList];

    return plist;
}
@end
