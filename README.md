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
