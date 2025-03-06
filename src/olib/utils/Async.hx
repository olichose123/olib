package olib.utils;

import haxe.MainLoop;

class Async<Data, Result>
{
    var data:Data;
    var callback:() -> Void;

    public var result:Result;

    /**
     * Call method on its own thread with data as parameter.
     * On completion, call the optional callback method.
     * The result of method(data) will be stored in the result attribute.
     * @param method
     * @return -> Result, data, ?callback):Void
    **/
    public function new(method:(Data) -> Result, data, ?callback):Void
    {
        this.data = data;
        this.callback = callback;
        var asyncFunction = function()
        {
            this.result = method(data);
            if (callback != null)
                callback();
        }

        MainLoop.addThread(asyncFunction);
    }
}
