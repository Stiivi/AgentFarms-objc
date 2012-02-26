/** AFNetwork

    Copyright (c) 2003 Stefan Urbanek

    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2003 Sep 20
   
    This file is part of the XY Framework.
 
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

#import "AFNetwork.h"

#import "AFNetworkLink.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import <Foundation/NSSet.h>

@implementation AFNetwork
- init
{
    self = [super init];
    
    objects = [[NSMutableSet alloc] init];
    links = [[NSMutableArray alloc] init];
    linkClass = [AFNetworkLink class];

    return self;
}

- (void)dealloc
{
    RELEASE(objects);
    RELEASE(links);
    [super dealloc];
}

- (void)addObject:(id)anObject
{
    [objects addObject:anObject];
}

- (void)addObjects:(NSArray *)array
{
    [objects addObjectsFromArray:array];
}

- (void)removeObject:(id)anObject
{
    [self unlinkObject:anObject];
    [objects removeObject:anObject];
}

- (void)removeObjects:(NSArray *)array
{
    [self unlinkObjects:array];
    [objects minusSet:[NSSet setWithArray:array]];
}
- (NSArray *)objects
{
    return [objects allObjects];
}

/* Set all objects that are equal to anObject to be the same object anObject */
/*
- (int)unifyObject:(id)anObject
{
    AFNetworkLink *link;
    NSEnumerator  *enumerator;
    NSEnumerator  *linkEnumerator;
    id            object;
    
    enumerator = [objects objectEnumerator];
    
    while( (object = [enumerator nextObject] ))
    {
        if([object isEqual:anObject])
        {
            links = [self linksWithObject:object];
            linkEnumerator = [links objectEnumerator];
            
            while( (link = [linkEnumerator nextObject]) )
            {
                [link replaceObject:object withObject:anObject];
            }
        }
    }
}
*/
/** Checks whether the object <var>anObject</var> is included in the network. */
- (BOOL)containsObject:(id)anObject
{
    return [objects containsObject:anObject];
}

/** Create a link between object <var>anObject</var> and 
    <var>anotherObject</var>*/
- (AFNetworkLink *)linkObject:(id)anObject withObject:(id)anotherObject
{
    AFNetworkLink *link;
    
    if(![objects containsObject:anObject])
    {
        [NSException raise:@"AFNetworkException"
                     format:@"Unable to link. Network does not contain object "
                            @"%@ (source).", anObject];

        return nil;
    }

    if(![objects containsObject:anotherObject])
    {
        [NSException raise:@"AFNetworkException"
                     format:@"Unable to link. Network does not contain object "
                            @"%@ (destination).", anotherObject];
        return nil;
    }
    
    link = [AFNetworkLink linkWithSource:anObject destination:anotherObject];
    [links addObject:link];
    
    return link;
}

/** Remove all links between objects <var>anObject</var> and 
    <var>anotherObject</var>*/
- (void)unlinkObject:(id)anObject withObject:(id)anotherObject
{
    NSEnumerator  *enumerator;
    AFNetworkLink *link;
    
    enumerator = [links objectEnumerator];
    
    while( (link = [enumerator nextObject] ))
    {
        if([[link source] isEqual:anObject] 
                && [[link destination] isEqual:anotherObject]
            || [[link source] isEqual: anotherObject] 
                && [[link destination] isEqual:anObject])
        {
            [links removeObject:link];
        }
    }
}

/** Remove all links from and to an object <var>anObject</var> */
- (void)unlinkObject:(id)anObject
{
    NSEnumerator  *enumerator;
    AFNetworkLink *link;
    
    enumerator = [links objectEnumerator];
    
    while( (link = [enumerator nextObject] ))
    {
        if([[link source] isEqual:anObject] 
            || [[link destination] isEqual:anObject])
        {
            [links removeObject:link];
        }
    }
}


/** Remove all links from and to an object <var>anObject</var> */
- (void)unlinkObjects:(NSArray *)array
{
    NSEnumerator  *enumerator;
    id            object;
    
    enumerator = [array objectEnumerator];
    
    while( (object = [enumerator nextObject] ))
    {
        [self unlinkObject:object];
    }
}

- (BOOL)isLinkedObject:(id)anObject
{
    NSEnumerator  *enumerator;
    AFNetworkLink *link;
    
    enumerator = [links objectEnumerator];
    
    while( (link = [enumerator nextObject] ))
    {
        if([[link source] isEqual: anObject] 
            || [[link destination] isEqual: anObject])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isLinkBetweenObject:(id)anObject andObject:(id)anotherObject
{
    NSEnumerator  *enumerator;
    AFNetworkLink *link;
    
    enumerator = [links objectEnumerator];
    
    while( (link = [enumerator nextObject] ))
    {
        if([[link source] isEqual:anObject] 
                && [[link destination] isEqual:anotherObject]
            || [[link source] isEqual:anotherObject] 
                && [[link destination] isEqual:anObject])
        {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)links
{
    return links;
}

- (NSArray *)linksWithObject:(id)anObject
{
    NSMutableArray *array = [NSMutableArray array];
    NSEnumerator  *enumerator;
    AFNetworkLink *link;
    
    enumerator = [links objectEnumerator];
    
    while( (link = [enumerator nextObject] ))
    {
        if([[link source] isEqual:anObject] 
            || [[link destination] isEqual: anObject])
        {
            [array addObject:anObject];
        }
    }
    return [NSArray arrayWithArray:array];
}

- (NSArray *)linksWithSourceObject:(id)anObject
{
    NSMutableArray *array = [NSMutableArray array];
    NSEnumerator  *enumerator;
    AFNetworkLink *link;
    
    enumerator = [links objectEnumerator];
    
    while( (link = [enumerator nextObject] ))
    {
        if([link source] == anObject)
        {
            [array addObject:anObject];
        }
    }
    return [NSArray arrayWithArray:array];
}

- (NSArray *)linksWithDestinationObject:(id)anObject
{
    NSMutableArray *array = [NSMutableArray array];
    NSEnumerator  *enumerator;
    AFNetworkLink *link;
    
    enumerator = [links objectEnumerator];
    
    while( (link = [enumerator nextObject] ))
    {
        if([link destination] == anObject)
        {
            [array addObject:anObject];
        }
    }
    return [NSArray arrayWithArray:array];
}

/** Set the class for creating links between objects to <var>aClass</var>
    <var>aClass</var> shold be a subclass of AFNetworkLink. If nil is specified,
    then AFNetworkLink is used. */
- (void)setLinkClass:(Class)aClass
{
    if(aClass == nil)
    {
        linkClass = [AFNetworkLink class];
    }
    else
    {
        if([aClass isKindOf:[AFNetworkLink class]]);
        {
            [NSException raise:@"AFNetworkException"
                         format:@"Class %@ is not a subclass of AFNetworkLink class.",
                                NSStringFromClass(aClass)];
            return;
        }

        linkClass = aClass;
    }
}

/** Return class for link. */
- (Class)linkClass
{
    return linkClass;
}

@end
