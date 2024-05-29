# olib - a game engine on top of heaps.io

*
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
