/* 2003 Jun 7 */

#import <AppKit/NSView.h>

#import <Vector.h>

@class NSTimer;
@class AFNetworkViewObject;
@class NSForm;
@class AFNetwork;
@interface AFNetworkView:NSView
{
    AFNetwork      *network;

    NSTimer        *animationTimer;

    int             animationFrame;
    int             updateFrequency;
    int             framesPerSecond;
    
    AFNetworkViewObject    *selectedObject;

    Vector          zero;
    double          centerMass;
    
    double          gravityCoeficient;
    double          stringCoeficient;
    double          temperature;
    
    NSForm *paramsForm;
    NSForm *frequencyForm;
    NSForm *temperatureField;
    
    NSPoint dragPoint;
}

- (void)setRootObject:(id)anObject;

- (NSRect)objectsBounds;
@end


