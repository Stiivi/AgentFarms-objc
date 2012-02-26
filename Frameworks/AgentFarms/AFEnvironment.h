/* 2003 Jul 27 */

#import <Foundation/NSObject.h>

@class AFModel;
@class AFObjectDescription;
@class AFObjectPrototype;
@class NSArray;
@class NSMutableArray;
@class NSMutableDictionary;

@interface AFEnvironment:NSObject
{
    AFModel                *model; 

    NSMutableArray         *objects;
    NSMutableDictionary    *objectNames;
    NSMutableDictionary    *objectNameDictionary;

    NSMutableDictionary    *objDictionary; /* key:ref -> val:obj */
    NSMutableDictionary    *refDictionary; /* key:obj -> val:ref */
    
    unsigned int            nextReference;
}
- (id)objectWithReference:(id)ref;
- (AFObjectDescription *)descriptionForObjectWithReference:(id)ref;
- (id)referenceForObject:(id)anObject;
- (bycopy id)referenceForObjectAtIndex:(int)index
                 inObjectWithReference:(bycopy id)ref;

- (NSArray *)rootObjectReferences;
- (NSArray *)rootObjectNames;

- (id)objectWithName:(NSString *)name;
- (id)referenceForObjectWithName:(NSString *)name;
- (NSString *)nameForObjectWithReference:(id)ref;

- (void)      setValue:(bycopy id)value
        forPropertyKey:(bycopy NSString *)key
 inObjectWithReference:(bycopy id)ref;

- (AFObjectPrototype *)prototypeWithName:(NSString *)name;
@end

