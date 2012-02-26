/* 2003 Jul 3 */

#import "FarmLog.h"

#import <AppKit/NSWindow.h>

#import <AppKit/NSAttributedString.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSTextView.h>
#import <AppKit/NSWindow.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>

#import "AFFarm.h"

static NSDictionary  *normalAttributes;
static NSDictionary  *errorAttributes;
static NSDictionary  *warningAttributes;

@interface FarmLog(AFPrivate)
- (NSString *)formatedMessage:(NSString *)message type:(NSString *)aType;
@end;

@implementation FarmLog
+ (void)initialize
{
    normalAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSColor blackColor], NSForegroundColorAttributeName,
                                [NSFont systemFontOfSize:0], NSFontAttributeName,
                                nil, nil];
    errorAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSColor redColor], NSForegroundColorAttributeName,
                                [NSFont boldSystemFontOfSize:0], NSFontAttributeName,
                                nil, nil];

    warningAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSColor blueColor], NSForegroundColorAttributeName,
                                [NSFont boldSystemFontOfSize:0], NSFontAttributeName,
                                nil, nil];
}
- (NSString *)windowNibName
{
    return @"LogWindow";
}
- (void)log:(NSString*)format,...
{
    va_list   args;

    va_start(args, format);

    [self log:format arguments:args];
}

- (void)log:(NSString*)format arguments: (va_list)args

{
    NSAttributedString *astring;
    NSString *message;

    message = [NSString stringWithFormat: format arguments: args];
    // NSLog(@"%@", message);

    message = [self formatedMessage:message type:nil];

    astring = [[NSAttributedString alloc] initWithString:message
                                              attributes:normalAttributes];
    
    [textView insertText:astring];
}
- (void)logError:(NSString*)format,...
{
    va_list             args;

    va_start(args, format);
    
    [self logError:format arguments:args];
}
- (void)logError:(NSString*)format arguments: (va_list)args

{
    NSAttributedString *astring;
    NSString           *message;

    message = [NSString stringWithFormat: format arguments: args];
    NSLog(@"ERROR: %@", message);

    message = [self formatedMessage:message type:@"Error"];

    astring = [[NSAttributedString alloc] initWithString:message
                                              attributes:errorAttributes];
    [textView insertText:astring];

    RELEASE(astring);
}

- (void)logWarning:(NSString*)format,...
{
    va_list             args;

    va_start(args, format);
    
    [self logWarning:format arguments:args];
}
- (void)logWarning:(NSString*)format arguments: (va_list)args

{
    NSAttributedString *astring;
    NSString           *message;

    message = [NSString stringWithFormat: format arguments: args];
    NSLog(@"WARNING: %@", message);

    message = [self formatedMessage:message type:@"Warning"];

    astring = [[NSAttributedString alloc] initWithString:message
                                              attributes:warningAttributes];
    [textView insertText:astring];

    RELEASE(astring);
}
- (void)clear:(id)sender
{
    NSLog(@"Log clear not implemented");
}
- (void)setShowsDate:(BOOL)flag
{
    showsDate = flag;
}
- (BOOL)showsDate
{
    return showsDate;
}
- (NSString *)formatedMessage:(NSString *)message type:(NSString *)aType
{
    if(aType && ![aType isEqualToString:@""])
    {
        aType = [aType stringByAppendingString:@": "];
    }
    else
    {
        aType = @"";
    }

    if(showsDate)
    {
        message = [NSString stringWithFormat:@"%@ %@%@\n",[NSCalendarDate date], aType, message];
    }
    else
    {
        message = [NSString stringWithFormat:@"%@%@\n", aType, message];
    }

    return message;
}
@end
