/** AFFarm
 
    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 Oct 6
    
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

#import "AFFarm.h"

#import <Foundation/NSDebug.h>
#import <Foundation/NSArchiver.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>

#import <AgentFarms/AFModel.h>
#import <AgentFarms/AFModelBundle.h>
#import <FarmingKit/AFFarmStore.h>

@interface AFFarm(Private)
@end

@implementation AFFarm
- initWithModelPath:(NSString *)path
{
    AFModelBundle *bundle;

    /* FIXME */
    [self notImplemented:_cmd];
    [self dealloc];
    return nil;

    bundle = (AFModelBundle *)[AFModelBundle bundleWithPath:path];
    
    if(!bundle)
    {
        [NSException raise:@"AFFarmException"
                     format:@"Unable to load model bundle at path '%@'", path];
        [self dealloc];
        return nil;
    }
    
    return [self initWithModelBundle:bundle];
}

- initWithModelBundle:(AFModelBundle *)aBundle
{
    self = [super init];

    if(!aBundle)
    {
        [NSException raise:@"AFFarmException"
                     format:@"No model bundle specified."];
        [self dealloc];
        return nil;
    }

    modelBundle = RETAIN(aBundle);

    modelPath = RETAIN([modelBundle bundlePath]);
    model = [modelBundle model];
    modelName = RETAIN([model name]);

    return self;
}

- (void)dealloc
{
    NSLog(@"AFFarm DEALLOC %@", self);
    RELEASE(model);
    RELEASE(modelBundle);
    RELEASE(modelPath);
    RELEASE(modelName);

    [super dealloc];
}

/* Accessor methods */
- (AFModel *)model
{
    return model;
}
- (NSString *)name
{
    return modelName;
}
@end
