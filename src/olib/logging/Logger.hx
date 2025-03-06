package olib.logging;

import sys.FileSystem;

using StringTools;
using haxe.EnumTools.EnumValueTools;
using DateTools;

import haxe.PosInfos;
import utest.Test;
import utest.Assert;

class Logger
{
    static var loggers:Array<Logger> = new Array<Logger>();
    public static var defaultLogger:Logger = new Logger("default", #if debug Debug #else Info #end);
    static var log_level_order = [
        LogLevel.Debug => 0,
        LogLevel.Info => 1,
        LogLevel.Warning => 2,
        LogLevel.Error => 3,
        LogLevel.Critical => 4,
    ];

    static var internal_trace:(v:Dynamic, ?infos:PosInfos) -> Void;

    static function trace(v:Dynamic, ?infos:PosInfos):Void
    {
        if (defaultLogger != null)
        {
            var last_param = infos.customParams?.pop();
            var current_log_level = log_level_order[defaultLogger.level];
            if (last_param != null && Std.isOfType(last_param, LogLevel))
            {
                switch (last_param)
                {
                    case LogLevel.Debug:
                        if (current_log_level > 0)
                        {
                            return;
                        }
                    case LogLevel.Info:
                        if (current_log_level > 1)
                        {
                            return;
                        }
                    case LogLevel.Warning:
                        if (current_log_level > 2)
                        {
                            return;
                        }
                    case LogLevel.Error:
                        if (current_log_level > 3)
                        {
                            return;
                        }
                    case LogLevel.Critical:
                        if (current_log_level <= 4)
                        {
                            return;
                        }
                }
                defaultLogger.log(last_param, Std.string(v));
                return;
            }

            defaultLogger.log(LogLevel.Debug, Std.string(v));
        }
        else
        {
            internal_trace(v, infos);
            print(v);
        }
    }

    static function print(message:Dynamic):Void
    {
        #if js
        if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
            (untyped console).log(message);
        #elseif lua
        untyped __define_feature__("use._hx_print", _hx_print(message));
        #elseif sys
        Sys.println(Std.string(message));
        #else
        throw new haxe.exceptions.NotImplementedException();
        #end
    }

    public static function dump(logsPath:String):Void
    {
        for (logger in loggers)
        {
            if (logger.logs.length == 0)
            {
                continue;
            }
            if (FileSystem.exists(logsPath) == false)
            {
                FileSystem.createDirectory(logsPath);
            }
            var logFile = sys.io.File.write(logsPath + "/" + logger.name + ".txt");
            logFile.writeString("Logs for " + logger.name + "\n\n");
            for (log in logger.logs)
            {
                logFile.writeString(log + "\n");
            }
            logFile.close();
        }
    }

    public var name(default, null):String;

    var format:LogFormat;
    var level:LogLevel;
    var logs:Array<String> = [];

    public function new(name:String, ?level:LogLevel, ?format:LogFormat):Void
    {
        if (!~/^[a-z0-9_-]*$/m.match(name))
        {
            throw new haxe.exceptions.ArgumentException("Logger name must match ^[a-zA-Z0-9_-]*$");
        }
        loggers.push(this);
        this.name = name;
        this.format = format == null ? new LogFormat() : format;
        this.level = level == null ? LogLevel.Debug : level;
        if (internal_trace == null)
        {
            internal_trace = haxe.Log.trace;
            haxe.Log.trace = Logger.trace;
        }
    }

    public function log(level:LogLevel, message:String):Void
    {
        if (log_level_order[level] < log_level_order[level])
        {
            return;
        }

        var msg = format.format(this, level, message);
        logs.push(msg);
        print(msg);
    }

    public function debug(message:String):Void
    {
        log(LogLevel.Debug, message);
    }

    public function info(message:String):Void
    {
        log(LogLevel.Info, message);
    }

    public function warning(message:String):Void
    {
        log(LogLevel.Warning, message);
    }

    public function error(message:String):Void
    {
        log(LogLevel.Error, message);
    }
}

enum LogLevel
{
    Debug;
    Info;
    Warning;
    Error;
    Critical;
}

abstract LogFormat(String) from String to String
{
    public static final name = "__name__";
    public static final date = "__date__";
    public static final time = "__time__";
    public static final level = "__level__";
    public static final message = "__message__";

    public inline function new(?s:String)
    {
        this = s == null ? "__time__ - __name__: [__level__] __message__" : s;
    }

    public function format(logger:Logger, msg_level:LogLevel, msg:String):String
    {
        var s = this;
        s = s.replace(name, logger.name);
        s = s.replace(date, Date.now().format("%F"));
        s = s.replace(time, Date.now().format("%T"));
        s = s.replace(level, msg_level.getName());
        s = s.replace(message, msg);
        return s;
    }
}

class LoggerTest extends Test
{
    function testNameRegex():Void
    {
        Assert.raises(function()
        {
            new Logger("My Logger", LogLevel.Debug, new LogFormat());
        }, haxe.exceptions.ArgumentException);

        Assert.raises(function()
        {
            new Logger("My-logger", LogLevel.Debug, new LogFormat());
        }, haxe.exceptions.ArgumentException);

        new Logger("my-logger", LogLevel.Debug, new LogFormat());
    }
}
