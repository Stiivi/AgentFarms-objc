@class NSString;

@protocol AFLog
- (void)log:(NSString*)format,...;
- (void)logError:(NSString*)format,...;
- (void)logWarning:(NSString*)format,...;
- (void)log:(NSString*)format arguments: (va_list)args;
- (void)logError:(NSString*)format arguments: (va_list)args;
- (void)logWarning:(NSString*)format arguments: (va_list)args;
@end
