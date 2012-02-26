/** AFModelValidator
    
    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2003 Sep 18
    
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

#import "AFModelValidator.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSEnumerator.h>

#import <AgentFarms/AFModel.h>
#import <AgentFarms/AFObjectConnection.h>
#import <AgentFarms/AFObjectPrototype.h>
#import <AgentFarms/AFClassDescription.h>

/*

Report

Errors:
    Missing class
        name
        where (Descriptions, Prototypes)
            name
    Missing prototype
        name
        where (Connections, Objects)
    Undefine attribute
        name
        where (Prototype)
            name
    Read Only attribute
        name
        where (Prototype)
            name

*/

@implementation AFModelValidator
+ validatorWithModel:(AFModel *)aModel
{
    return AUTORELEASE([[self alloc] initWithModel:aModel]);
}
- initWithModel:(AFModel *)aModel
{
    self = [super init];
    
    model = RETAIN(aModel);
    
    return self;
}
- (void)dealloc
{
    RELEASE(model);
    [super dealloc];
}
- (BOOL)validate
{
    BOOL isValid = YES;

    isValid = [self validateClasses];

    isValid = isValid && [self validatePrototypes];
    isValid = isValid && [self validateConnections];

    return isValid;
}
- (BOOL)validateClasses
{
    AFClassDescription *desc;
    NSEnumerator       *enumerator;
    NSString           *className;
    Class               class;
    BOOL                ok = YES;
    
    enumerator = [[model classDescriptions] objectEnumerator];
    
    NSLog(@"Checking class descriptions...");
    while( (desc = [enumerator nextObject]) )
    {
        className = [desc name];
        class = NSClassFromString(className);
        if(!class)
        {
            NSLog(@"    Missing class %@", className);
            ok = NO;
        }
    }
    return ok;
}    

- (BOOL)validatePrototypes
{
    AFObjectPrototype *proto;
    NSEnumerator      *enumerator;
    NSString          *className;
    Class              class;
    BOOL               ok = YES;
    
    enumerator = [[model prototypes] objectEnumerator];

    NSLog(@"Checking prototypes...");
    while( (proto = [enumerator nextObject]) )
    {
        className = [proto  objectClassName];
        class = NSClassFromString(className);
        if(!class)
        {
            NSLog(@"    Missing class %@", className);
            ok = NO;
        }

        if(![model descriptionForClassWithName:className])
        {
            NSLog(@"    Missing description %@", className);
            ok = NO;
        }
    }

    return ok;
}
- (BOOL)validateConnections
{
    AFClassDescription *desc;
    AFObjectConnection *conn;
    AFObjectPrototype  *proto;
    NSEnumerator       *enumerator;
    NSString           *className;
    NSString           *name;
    BOOL                ok = YES;
    
    enumerator = [[model connections] objectEnumerator];

    NSLog(@"Checking connections...");
    while( (conn = [enumerator nextObject]) )
    {
        name = [conn sourceName];
        if(![model prototypeWithName:name])
        {
            NSLog(@"    Missing prototype %@", name);
            ok = NO;
        }

        name = [conn destinationName];
        proto = [model prototypeWithName:name];
        if(!proto)
        {
            NSLog(@"    Missing prototype %@", name);
            ok = NO;
            
        }
        else
        {
            className = [proto objectClassName];
            desc = [model descriptionForClassWithName:className];
            if(desc)
            {
                name = [conn relationshipName];
                if(![desc relationshipWithIdentifier:name])
                {
                    NSLog(@"    No relationship %@ in %@", name, className);
                    ok = NO;
                }
            }
        }

        
    }

    return ok;
}
@end;
