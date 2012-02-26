/** AFModelBundle

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 Oct 9 
    
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

#import "AFModelBundle.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import <Foundation/NSDictionary.h>

#import "AFModel.h"
#import "AFResourceManager.h"

@implementation AFModelBundle
+ (NSArray *)knownModelBundles
{
    NSMutableArray *array = [NSMutableArray array];
    
    [array addObjectsFromArray:[[AFResourceManager defaultManager] 
                                            allResourcesOfType:@"afmodel"
                                            inDirectory:@"Models"]];
    return [NSArray arrayWithArray:array];
}
+ _pathForBundleWithName:(NSString *)aName
{
    return [[AFResourceManager defaultManager] pathForResource:aName
                                                        ofType:@"afmodel"
                                                   inDirectory:@"Models"];
}
+ (AFModelBundle *)bundleWithName:(NSString *)aName
{
    AFModelBundle *bundle;
    NSString      *path;
    
    path = [self _pathForBundleWithName:aName];
    if(!path)
    {
        [NSException raise:@"AFInvalidArgumentException"
                     format:@"No model bundle with name '%@'", aName];
        return nil;
    }

    bundle = [[AFModelBundle alloc] initWithPath:path];
    
    return AUTORELEASE(bundle);
}

- (NSString *)pathForModelFile
{
    return [self pathForResource:@"Model" ofType:@"plist"];
}
- (NSString *)pathForDocumentationFile
{
    NSString *path;
    path = [self pathForResource:@"Documentation" ofType:@"rtfd"];
    if( (path = [self pathForResource:@"Documentation" ofType:@"rtfd"]) )
    {
        return path;
    }

    if( (path = [self pathForResource:@"Documentation" ofType:@"rtf"]) )
    {
        return path;
    }

    if( (path = [self pathForResource:@"Documentation" ofType:@"txt"]) )
    {
        return path;
    }
    return path;
}

- (AFModel *)model
{
    NSString *file;
    
    if(!model)
    {
        file = [self pathForModelFile];
        model = [[AFModel alloc] initFromFile:[self pathForModelFile]];
    }
    return model;
}
@end
