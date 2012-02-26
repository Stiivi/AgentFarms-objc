/* 2003 Jul 3 */

#import <AppKit/NSView.h>

@class NSMatrix;
@class NSScrollView;
@class AFFarm;
@class AFFarmerModule;

@interface ModulesView:NSView
{
    NSScrollView *scrollView;
    NSMatrix     *matrix;   
    AFFarm       *farm; 
}
- (void)addModule:(AFFarmerModule *)module;
@end
