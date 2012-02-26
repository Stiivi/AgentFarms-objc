/** AFProperty

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 May 19 
    
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

#import "AFProperty.h"


#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>

@implementation AFProperty
+ propertyWithName:(NSString *)aName
       description:(NSDictionary *)dict
{
    AFProperty *prop;
    prop = [[AFProperty alloc] initWithName:aName
                                description:dict];
    return AUTORELEASE(prop);
}

- initWithName:(NSString *)aName
   description:(NSString *)dict
{
    [super init];
    
    if(!aName)
    {
        NSLog(@"Nil property (ignored)");
        [self dealloc];
        return nil;
    }
    name = RETAIN(aName);
    displayName = RETAIN([dict objectForKey:@"DisplayName"]);
    defaultValue = RETAIN([dict objectForKey:@"DefaultValue"]);

    return self;
}
- (NSString *)name
{
    return name;
}
- (NSString *)displayName
{
    return displayName;
}
- (id)defaultValue
{
    return defaultValue;
}
- (void)dealloc
{
    RELEASE(name);
    RELEASE(displayName);
    RELEASE(defaultValue);
    [super dealloc];
}
- (BOOL)isEditable
{
    return (defaultValue != nil);
}
@end
