#import <AppKit/NSWindowController.h>

@class NSBrowser;
@class NSTextView;
@class NSForm;
@class NSTableView;
@class AFProject;
@class AFClass;
@class AFMethod;

@interface StructureEditor:NSWindowController
{
    NSBrowser   *classBrowser;
	NSTableView *ivarTable;
	NSForm      *infoForm;
	NSTextView  *descriptionView;

    AFProject  *project;
}
- (void)addInstanceVariable:(id)sender;
- (void)removeInstanceVariable:(id)sender;
- (void)classSelected:(id)sender;
- (void)infoEdited:(id)sender;
- (AFClass *)selectedClass;
@end
