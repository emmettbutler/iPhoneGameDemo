iOS presentation slides notes
=============================

XCode
    Full-fledged IDE with static code analysis, debugging tools
    One-stop shop for preparing an iOS app for launch
    Nice interface to required .plist files
Objective-C
    Thin top layer above C (and C++)
    Adds classes, inheritance, runtime reflection, messages
    Additional types provided by Foundation (NS) framework
    Not really *pointers* but object IDs (related to passing model, similar to python)
    syntax
        function calls, parameter access
        in keyword
        nil - the *null id* or id of no object
        @"string literals"
        @[] - array displays
        @{} - dict displays
        displays call convenience constructors (which require nil-termination if used directly)
        NSLog for console logging, supports string formatting
    runtime reflection / selectors
        @selector is an object of type SEL
        not a function pointer, but a message
        evaluated at runtime when message is sent to object via a callback
        similar to python in that attributes are checked at runtime
        different, since this only happens for methods via selectors
        http://stackoverflow.com/questions/297680/how-do-sel-and-selector-work-in-iphone-sdk
    calling model
        http://stackoverflow.com/questions/1344476/how-to-pass-values-by-reference-in-objective-c-iphone
        pass by id (changes to a pointer (id) param have no effect on outside scope)
        pass by reference achieved with two-star indirection
    reference counting
        with power comes responsibility
        each object holds a count of how many references exist to it
        http://www.peachpit.com/articles/article.aspx?p=377302&seqNum=2
        before an object pointer is reassigned, the object it points to should
        be released (since one reference to the object is being removed)
        similarly, when a new pointer to an object is created, the object should
        be retained (one more reference)
        retain increases reference count by one
        release decreases count and calls dealloc if count is 0
        autorelease pool is a list of objects to call release on later
        [[SomeClass alloc] init] = manually managed (by convention)
        [SomeClass initForConvenience] = *convenience constructior*, conventionally
            autoreleases object
        ARC
            compiler automatically generates reference-counting code
            http://clang.llvm.org/docs/AutomaticReferenceCounting.html
    defining classes
    @property
        objc: allows function calls to look syntactically like property accesses
            also requires @synthesize, which creates methods for property members
        python: allows function calls to look syntactically like property accesses
        only difference is that objc creates the functions on your behalf, python
            requires you to create the function
        essentially, @synthesize creates the equivalent of python __getattr__ and __setattr__
        these are python *calculated properites* that are accessible via attribute lookup
        (ie dot notation)
        the objc @property declares these generated methods as calculated properties
        http://stackoverflow.com/questions/5172021/how-to-use-properties-in-objective-c
iOS and Cocoa
    What is Cocoa?
        Collection of Obj-C frameworks for iOS development
            Foundation
                Base classes for arrays, dicts, ints, strings, etc
                Generally prefixed with *NS* - NextStep OS heritage
            UIKit
                ViewControllers, Buttons, Window - core iOS UI elements
        Mostly accessible via Obj-C, but Python and other API bindings exist
    Interfacing an app with iOS
        .plists define lots of app metadata (reqiured device capabilities, icon files)
        reserved image filenames for iTunes and app icon images
UI creation
    MVC / Model-View-Controller
        Separates data model from data visualization
    Models
        Hold and manage data
        Subclasses of NSObject (ie, basic objects)
        Analogous to Django ORM models, just without the built-in ORM part
    Views
        Subclasses of UIView, contain ViewElements (Buttons, Sliders)
        Objects used to build UI (subviews) with addSubview
        Can draw themselves and respond to input
        Elements must be added as subviews
        Frames - rectangular screen regions for drawing
        Drawing code follows the painter model - ie order matters
        Cocoa provides a drawing library for more advanced custom graphics
    Controllers
        Workhorses - provide feedback between models and views
        A *ViewController* manages one screen of data by convention
        UIViewController
            Has a *view* member which represents the top-level UIView for a screen
    Example with Twitter built-in VC and hand-rolled
    Handling external events
        App Delegate sits between your app and the OS
        notifies about external events so your app can respond
    Knowing what device you are on
Miscellany
    OpenGL contexts in views
