# olib - a game engine on top of heaps.io

### Application
Create a windowed application with the olib.heaps.Application class.

```haxe
class Main
{
    public static function main()
    {
        var app = new Application("myApp", onInit);
    }

    static function onInit(app)
    {
        // create and set scenes
        app.setScene(myScene1);

        // exit the app
        app.exit();

        // configure based on settings
        Application.setWindowScreenMode(Windowed);
        Application.setWindowSize(800, 600);
    }
}

```

### GameScene
A GameScene is an update and render loop that runs inside an application. An application can only have one GameScene running at a time. It is used to split parts of a game into chunks.

A GameScene has both a 2d and a 3d canvas (heaps h2d.Scene and heaps h3d.scene.Scene).

Examples:
- A splash screen scene
- A main menu scene
- a main game loop scene
- a pause menu scene
- a game over scene


```haxe
class MyScene extends GameScene
{
    override function init()
    {
        // initialize your scene here
    }

    override function update(gameTime:GameTime):Int
    {
        // update your items here.
        // It is recommended to return the number of items
        // that were updated this frame.
        // DO NOT call super.update(gameTime) as it will throw an error.

        return 0;
    }

    // the rendering is done by the engine, so you don't need to do anything here.
    // function render():Void
    // {
    //     if (s2d != null)
    //         s2d.render(application.engine);
    //     if (s3d != null)
    //         s3d.render(application.engine);
    // }

    override function onAdded(application:Application)
    {
        // when the scene is added to the application, you can execute logic
        super.onAdded(application);
    }

    override function onRemoved()
    {
        // when the scene is removed from the application, you can also execute logic
        super.onRemoved();
    }
}

```

Now it's time to add the scene to the application:
```haxe
app.setScene(new MyScene()); // or use an already instantiated scene
```

### Locale
Localized text. A Locale object represents a language, with a set of key-value pairs. The keys are the identifiers of the localized text, and the values are the localized text itself. If in debug or manually set, can log each missing key to a logger. The Locale object can be serialized to a file, and deserialized from a file.

Suppose a locale json file:
```jsonc
{
    "type": "Locale", // required for the parser to know what to create
    "name": "en_US", // required as the model key (see olib_model library)
    "data": {

        "hello_world":"Hello, World!",
        "goodbye_world": "Goodbye, World!"
        // note the absence of a "missing_key" key and value here
    }
}
```

```haxe
// let's create a loader (or use sys.io)
var loader = new Loader("test_data");

// load the locale file
var locale_path = "en_US_locale.json";
var locale_data = loader.load(locale_path).toText();

// create a Locale (which extends from olib.models.Model, of the olib_model library)
var locale:Locale = Locale.parser.fromJson(locale_data, locale_path);

// we configure the system to log all missing keys (so we can add them to the locale file manually)
Locale.reportMissingKeys = true;

// set the current locale
Locale.current = locale;

// this will raise a warning in the "locale" Logger, but only once. In all cases it will return "missing_key" as it has no value.
trace(Locale.get("missing_key"));

// These two commande will work, as there are values for these keys in the locale file.
trace(Locale.get("hello_world"));
trace(Locale.get("goodbye_world"));

// we dump the logs to see the "locale.txt" log file in logs/
Logger.dump("logs");
```

The resulting logs:
```
Logs for locale

20:59:05 [Warning] Missing key: missing_key

```

### Logger
Create named loggers. Each logger can have its own minimum level and format. Log messages can be dumped to files. Each manager, or each mod, could have its own logger to better track bugs.

```haxe
import olib.logging.Logger;

// create named loggers, with a minimum level and a format
var l1 = new Logger("l1", Debug, new LogFormat());
var l2 = new Logger("l2", Debug, "__date__ __time__ (!__level__!): __message__");

// log messages
l1.log(Warning, "Oups!");
l2.log(Debug, "Hello, World!");

// dump logs to a folder "logs", where each logger has its own file
Logger.dump("logs");
```

### Scripts
Using hscript, execute code at runtime in specialized environments. Extract functions and execute them as needed. Perfect for modding or scripting.

```haxe
import olib.scripts.Script;
import olib.scripts.Script.Environment;

// create an environment
var myEnv = new Environment();

// add a logger
myEnv.variables.set("logger", new Logger("test-script", Debug));

// define a script
var myScript = new Script("myScript", "
    function potato(a, b)
    {
        logger.info('potato');
        return banana(a) + b;
    }

    function banana(a)
    {
        logger.warning('banana');
        return a * 2;
    }
");

// compile the script
myScript.compile(); // can be compiled with custom configured parser

// run the script
myEnv.run(myScript);

// extract the potato function
var potato = myEnv.variables.get("potato");

// call the function
trace(potato(1, 2));

// dump the logs
Logger.dump("logs");
```

Alternatively, you can pass an existing object to the environment, and call its functions from the script, as is what is happening with the logger in the example above.

**Why not simply use hscript systems?:** I wanted something I could iterate on, so that's why it looks like a simple wrapper around hscript.
