#import <AppKit/NSWindowController.h>

@class NSBrowser;
@class NSTextView;
@class AFProject;
@class AFClass;
@class AFMethod;

@interface BehaviourBrowserController:NSWindowController
{
    NSBrowser  *classBrowser;
    NSBrowser  *methodBrowser;
    NSTextView *methodSourceView;
    NSTextView *methodDescriptionView;
    
    AFProject  *project;
}
- addClass:(id)sender;
- removeClass:(id)sender;
- addMethod:(id)sender;
- removeMethod:(id)sender;
- (AFClass *)selectedClass;
- (AFMethod *)selectedMethod;
@end
