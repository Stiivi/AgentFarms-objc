/* 2003 Nov 21 */

#include <AppKit/NSDocument.h>

@class AFProject;

@interface FarmProjectController : NSDocument
{
  id buttonRow;
  id objectWell;
  id startButton;
  id window;
  
  AFProject *project;
}
- (void) build: (id)sender;
- (void) start: (id)sender;
@end
