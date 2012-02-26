/* 2003 Oct 21 */

@interface AFPlugInManager:NSObject
{
}
- (NSArray *)availablePlugIns;
@end

@interface AFPlugIn:NSObject
{
}
- initWithPath:(NSString *)path;
- (NSBundle *)bundle;
- (id)controller;
@end
