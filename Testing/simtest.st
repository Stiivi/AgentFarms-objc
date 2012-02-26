" 2003 Jun 13 "

    Environment includeFramework: 'AFSimulator'.

" known bundles "
    bundles := AFModelBundle knownModelBundles.
    
    Transcript showLine: 'Known model bundles:'.
    bundles do: [ :bundle | Transcript showLine: ('  ', bundle)].
    
    bundle := AFModelBundle bundleWithName: 'SourceFinder'.
    
    Transcript showLine: bundle model name.
    
    
