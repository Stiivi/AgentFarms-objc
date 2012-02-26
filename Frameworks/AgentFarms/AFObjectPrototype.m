/** AFObjectPrototype

    Copyright (c) 2003 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2003 Jun 30
    
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

#import "AFObjectPrototype.h"

#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSKeyValueCoding.h>
#import <Foundation/NSString.h>

@implementation AFObjectPrototype
/** Create new instance of the receiver prototype */
- (id)instantiate
{
    Class         class;
    id            instance;

    // NSLog(@"Instantiating %@", [self objectClassName]);

    class = NSClassFromString([self objectClassName]);
    
    if(!class)
    {
        [NSException raise:@"AFObjectPrototypeException"
                     format:@"Unable to find class '%@'", objectClassName];
        return nil;
    }
        
    instance = [class alloc];
    
    if([instance respondsToSelector:@selector(initWithPrototype:)])
    {
        instance = [instance initWithPrototype:self];
    }
    else
    {
        instance = [instance init];
        [instance takeValuesFromDictionary:attributes];
    }
    
    return AUTORELEASE(instance);
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSString *varName;
    id        val;
    
    varName = NSStringFromSelector([invocation selector]);
    // NSLog(@"Getting %@", varName);

    val = [attributes objectForKey:varName];
    [invocation setReturnValue:&val];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSMethodSignature *signature = nil;
    signature = [super methodSignatureForSelector:sel];

    if(!signature)
    {
        const char *types;
        const char *name;
        const char *ptr;
        int         argc = 0;

        types = GSTypesFromSelector(sel);

        if(!types || strcmp(types, "@8@0:4"))
        {
            name = GSNameFromSelector(sel);
            ptr = name;

            while(*ptr)
            {
                if(*ptr == ':')
                {
                    argc ++;
                }
                ptr++;
            }
            if(argc == 0)
            {
                sel = GSSelectorFromNameAndTypes(name, "@8@0:4");
                types = GSTypesFromSelector(sel);

                signature = [NSMethodSignature signatureWithObjCTypes:types];
            }
        }
        
    }
    return signature;
}
@end
