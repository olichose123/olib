package olib.tests;

import olib.logging.Logger;
import utest.Assert;
import utest.Test;

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
