@interface AFInspectorPanel:NSPanel
{
    NSDictionary  *inspectorDictionary; /* NSDictionary of NSArrays */
    NSView        *sharedView;
    NSTablView    *inspectorView;
}
+ sharedInspectorPanel;
/* Inspector oriented */
- registerInspector:(id)inspector
     withIdentifier:(NSString *)identifier;
- registerInspector:(id)inspector
     withIdentifier:(NSString *)identifier
         forClasse:(Class)classe;

- removeInspector:(id)inspector;
- removeInspectorForClass:(Class)aClass;
- (NSArray *)inspectorsForClass:(Class)aClass;
@end


...
    ObjectInspector *objectInspector;
    DescriptionInspector *descInspector;
    
    [inspectorPanel registerInspector:objectInspector
                             forClass:[NSObject class]];
    [inspectorPanel registerInspector:descriptionInspector
                           forClasses:nil];
                           
    [inspectorPanel removeInspector:objectInspector];
    [inspectorPanel removeClass:class];
    

                           
