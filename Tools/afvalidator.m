/* 2003 Jun 14 */

#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSProcessInfo.h>

#import <AFModelValidator.h>
#import <AgentFarms/AFModel.h>
#import <AgentFarms/AFModelBundle.h>
#import <Foundation/NSDistributedNotificationCenter.h>

const int MAX_SEQUENCES = 100; /* Maximal number of simulator sequence numbers */

@class NSAutoreleasePool;
@class AFModelBundle;

int validate_model_bundle(AFModelBundle *bundle)
{
    AFModelValidator *validator;
    AFModel *model;
    
    if(![bundle load])
    {
        NSLog(@"Unable to load bundle '%@'", [bundle bundlePath]);
        return;
    };
    
    model = [bundle model];
    
    if(!model)
    {
        NSLog(@"Unable to load get model");
        return;
    }
    
    validator = [AFModelValidator validatorWithModel:model];
    
    if([validator validate])
    {
        NSLog(@"Model is VALID.");
        return 0;
    }
    else
    {
        NSLog(@"Model is BROKEN.");
        return 1;
    }
}

int main(int argc, const char **argv)
{	
    NSAutoreleasePool  *pool;
    NSProcessInfo      *processInfo;
    NSArray            *args;
    NSString           *path;
    AFModelBundle      *modelBundle;
    AFModel            *model;
    int                 retval = 0;
    
    pool = [NSAutoreleasePool new];

    /* FIXME: make is missing framework linking */

    /* Get command line arguments */
    processInfo = [NSProcessInfo processInfo];

    args = [processInfo arguments];
    if([args count] < 2)
    {
        fprintf(stderr,"Usage: %s model_bundle\n", [[args objectAtIndex:0] cString]);
        retval = 3;
    }    
    else
    {
        path = [args objectAtIndex:1];
        
        if(![path isAbsolutePath])
        {
            NSString *cwd;
            cwd = [[NSFileManager defaultManager] currentDirectoryPath];
            path = [cwd stringByAppendingPathComponent:path];
        }
        modelBundle = [AFModelBundle bundleWithPath:path];
        if(!modelBundle)
        {
            fprintf(stderr,"Unable to open bundle %s\n", [path cString]);
            retval = 2;
        }
        else
        {
            retval = validate_model_bundle(modelBundle);
        }
    }

    RELEASE(pool);

    return retval;
}



