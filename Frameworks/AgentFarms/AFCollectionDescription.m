/** AFCollectionDescription

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

#import "AFCollectionDescription.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>
#import "AFClassDescription.h"

@implementation AFCollectionDescription
-     initWithObject:(id)anObject 
    classDescription:(AFClassDescription *)classDesc
{
    NSEnumerator        *enumerator = nil;
    NSString            *key;
    
    self = [super init];
    
    /* FIXME: check if anObject is a collection */

    if(!anObject)
    {
        [self dealloc];
        return nil;
    }

    count = [anObject count];
    
    return self;
}
- initWithDictionary:(NSDictionary *)dict
{
    [super init];

    count = RETAIN([dict objectForKey:@"Count"]);

    return self;
}
- (BOOL)isCollection
{
    return YES;
}
- (int)count
{
    return count;
}

/* Serialisation */
- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder: coder];

    [coder encodeValueOfObjCType: @encode(int) at: &count];
}

- initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder: decoder];
    
    [decoder decodeValueOfObjCType: @encode(int) at: &count];

    return self;
}
@end

