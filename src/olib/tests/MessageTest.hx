package olib.tests;

import olib.utils.Message;
import olib.utils.Message.MessageDispatcher;
import utest.Test;
import utest.Assert;

class MessageTest extends Test
{
    var dispatcher:MessageDispatcher;

    function setupClass():Void
    {
        dispatcher = new MessageDispatcher();
    }

    function testAddListener()
    {
        var callback = function(message:MyFirstMessage) {}

        dispatcher.addListener(MyFirstMessage, callback);
        Assert.isTrue(dispatcher.hasListener(MyFirstMessage, callback));
    }

    function testRemoveListener()
    {
        var callback = function(message:MyFirstMessage) {}
        dispatcher.addListener(MyFirstMessage, callback);
        dispatcher.removeListener(MyFirstMessage, callback);
        Assert.isFalse(dispatcher.hasListener(MyFirstMessage, callback));
    }

    function testDispatchMessage()
    {
        var result = [];
        var callback = function(message:MyFirstMessage)
        {
            result.push(message);
        }

        dispatcher.addListener(MyFirstMessage, callback);
        dispatcher.dispatch(new MyFirstMessage("Hello World"));
        Assert.isTrue(result.length == 1);
    }

    function testDifferentMessageTypes()
    {
        var result1 = [];
        var callback1 = function(message:MyFirstMessage)
        {
            result1.push(message);
        }

        var result2 = [];
        var callback2 = function(message:MySecondMessage)
        {
            result2.push(message);
        }

        dispatcher.addListener(MyFirstMessage, callback1);
        dispatcher.addListener(MySecondMessage, callback2);

        dispatcher.dispatch(new MyFirstMessage("Hello World"));
        dispatcher.dispatch(new MySecondMessage(42));

        Assert.isTrue(result1.length == 1);
        Assert.isTrue(result2.length == 1);

        Assert.equals(result1[0].text, "Hello World");
        Assert.equals(result2[0].number, 42);
    }
}

class MyFirstMessage extends Message
{
    public var text:String;

    public function new(text:String)
    {
        this.text = text;
    }
}

class MySecondMessage extends Message
{
    public var number:Int;

    public function new(number:Int)
    {
        this.number = number;
    }
}
