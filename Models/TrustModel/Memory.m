#import "Memory.h"

#import <Foundation/NSString.h>
#import "Actions.h"

@implementation Memory
+ memoryWithCapacity:(int)capa
{
    return AUTORELEASE([[self alloc] initWithCapacity:capa]);
}
- initWithCapacity:(int)capa
{    
    self = [super init];

    mem = malloc(capa * sizeof(int));
    memset(mem, 0, capa * sizeof(int));   
    capacity = capa;
    count = 0;
    
    return self;
}
- (void)dealloc
{
    free(mem);
    [super dealloc];
}
- (double)averageTrust
{
    double sum = 0;
    int i;

    if(count == 0)
    {
        return 0.5;
    }

    for(i = 0; i < count; i++)
    {
        sum += mem[i];
    }
    // NSLog(@"Average trust %f / %f  = %f", sum, (double)count, (double)sum / (double)count);
    return sum / (double)count;
}
- (void)rememberAction:(AFAgentAction *)action
{
    int val;
    
    if(action == CooperateAction)
    {
        val = 1;
    }
    else
    {
        val = 0;
    }
    // NSLog(@"Remember %i %i %i", val, count, capacity);
    if(count < capacity)
    {
        mem[count] = val;
        count++;
    }
    else
    {
        memmove(mem+1, mem, (capacity - 1) * sizeof(int));
        mem[capacity] = val;
    }
}
@end

