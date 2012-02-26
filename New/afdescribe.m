/* 2003 Sep 21 */

#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSProcessInfo.h>

#import <DevelopmentKit/DKTemplateMerger.h>
#import <FarmsModel/AFModel.h>
#import <FarmsModel/AFModelBundle.h>

@class NSAutoreleasePool;

void describe_model(AFModelBundle *bundle, NSString *template, NSString *outFile)
{
    DKTemplateMerger *merger;
    AFModel          *model;
    
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
    
    merger = [DKTemplateMerger merger];
    
    [merger setObject:model];
    [merger setTemplate:template];
    
    [merger merge];
    
    [[merger result] writeToFile:outFile atomically:YES];
}

int main(int argc, const char **argv)
{	
    NSAutoreleasePool  *pool;
    NSProcessInfo      *processInfo;
    NSArray            *args;
    NSString           *path;
    NSString           *templateFile;
    NSString           *template;
    NSString           *outFile;
    AFModelBundle      *modelBundle;
    AFModel            *model;
    
    pool = [NSAutoreleasePool new];

    /* FIXME: make is missing framework linking */

    /* Get command line arguments */
    processInfo = [NSProcessInfo processInfo];

    args = [processInfo arguments];
    if([args count] < 4)
    {
        fprintf(stderr,"Usage: %s model_bundle template out_file\n", [[args objectAtIndex:0] cString]);
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
        }
        else
        {
            template = [NSString stringWithContentsOfFile:[args objectAtIndex:2]];
            outFile = [args objectAtIndex:3];
            describe_model(modelBundle, template, outFile);
        }
    }

    RELEASE(pool);

    return 0;
}



