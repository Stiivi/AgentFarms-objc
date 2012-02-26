/* AFNumberCollection

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2002 Sep 30
   
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


#import "AFNumberCollection.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSString.h>
#import <Foundation/NSZone.h>

static NSZone *defaultZone = NULL;

@implementation AFNumberCollection
+ (void)initialize
{
    defaultZone = NSDefaultMallocZone();
}

/** Return new number collection containing numbers from 
    array <var>anArray</var>
*/
+ collectionWithArray:(NSArray *)anArray
{
    return AUTORELEASE([[self alloc] initWithArray:anArray]);
}

/** Initializes the collection with numbers from array <var>anArray</var>.

    <init />
*/
- initWithArray:(NSArray *)anArray
{
    double num;
    int    numberCount;

    numberCount = [anArray count];
    
    [self initWithCapacity:numberCount];
    
    for(count = 0; count < numberCount; count++)
    {
        num = [[anArray objectAtIndex:count] doubleValue];
        numbers[count] = num;

        /* FIXME */
        if(!count)
        {
            max = min = num;
        }
        else
        {
            if(num > max)
            {
                max = num;
            }
            else if(num < min)
            {
                min = num;
            }
        }
        sum += num;
    }
    
    return self;
}

/** Initialize the receiver with starting capacity <var>aSize</var>. 

    <init />
*/
- initWithCapacity:(unsigned)aSize
{
    [super init];
    
    capacity = aSize;
    
    numbers = NSZoneMalloc(defaultZone, sizeof(double) * capacity);
    
    return self;
}
- (void)dealloc
{
    NSZoneFree(defaultZone, numbers);
    RELEASE(userInfo);
    [super dealloc];
}
- init
{
    return [self initWithCapacity:100];
}

/** Return number at index <var>index</var> */
- (double)numberAtIndex:(unsigned int)index
{
    if(index > count)
    {
        [NSException raise:@"XYRangeException"
                     format:@"Collection index (%i) out of range (%i)", 
                     index, count];
        return 0;
    }
    
    return numbers[index];
}

/** Inserts a number <var>num</var> into the collection */
- (void)collectNumber:(double)num
{
    if(count >= capacity)
    {
        capacity *= 2;
        numbers = NSZoneRealloc(defaultZone, numbers, sizeof(double)*capacity);
    }
    numbers[count] = num;

    if(!count)
    {
        max = min = num;
    }
    else
    {
        if(num > max)
        {
            max = num;
        }
        else if(num < min)
        {
            min = num;
        }
    }
    sum += num;
    
    count ++;
}

/** Empty the collection */
- (void)removeAllNumbers
{
    count = 0;
    min = max = sum = 0.0;
}
- (unsigned int)count
{
    return count;
}

/** Get minimum number of the receiver collection */
- (double)minValue
{
    return min;
}

/** Get maxumum number of the receiver collection */
- (double)maxValue
{
    return max;
}

/** Get average value of the receiver collection */
- (double)averageValue
{
    return sum / (double)count;
}

/** Return direct pointer to number array. */
- (double *)numbers
{
    return numbers;
}

- (void)appendCollection:(AFNumberCollection *)collection
{
    unsigned int otherSize = [collection count];
    
    if(otherSize + count >= capacity)
    {
        capacity += otherSize;
        numbers = NSZoneRealloc(defaultZone, numbers, sizeof(double)*capacity);
    }

    memcpy(numbers + count, [collection numbers], otherSize);
    
    count += otherSize;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // [super encodeWithCoder: aCoder];
    
    [aCoder encodeValueOfObjCType: @encode(unsigned) at: &count];
    [aCoder encodeArrayOfObjCType: @encode(double) count:count at: numbers];
    [aCoder encodeValueOfObjCType: @encode(double) at: &min];
    [aCoder encodeValueOfObjCType: @encode(double) at: &max];
    [aCoder encodeValueOfObjCType: @encode(double) at: &sum];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    // self = [super initWithCoder: aDecoder];
    self = [super init];
    
    [aDecoder decodeValueOfObjCType: @encode(unsigned) at: &count];

    capacity = count;
    numbers = NSZoneMalloc(defaultZone, sizeof(double)*capacity);
    [aDecoder decodeArrayOfObjCType: @encode(double) count:count at: numbers];

    [aDecoder decodeValueOfObjCType: @encode(double) at: &min];
    [aDecoder decodeValueOfObjCType: @encode(double) at: &max];
    [aDecoder decodeValueOfObjCType: @encode(double) at: &sum];

    NSLog(@"init numbers:%p count:%i capa:%i", numbers, count, capacity);

    return self;
}
- (void)setOffset:(unsigned int)newOffset
{
    offset = newOffset;
}
- (unsigned int)offset
{
    return offset;
}
- (void)setUserInfo:(NSDictionary *)dict
{
    ASSIGN(userInfo,dict);
}

/** UserInfo contains keys:

        SimulationRun - number
        Scenario      - string (scenario identifier)

*/

- (NSDictionary *)userInfo
{
    return userInfo;
}

@end
