package olib.utils;

class Message {}
typedef MessageHandler<T:Message> = (message:T) -> Void;

class MessageDispatcher
{
    public var listeners(default, null):haxe.ds.StringMap<Array<MessageHandler<Message>>>;

    public function new():Void
    {
        listeners = new haxe.ds.StringMap();
    }

    public function addListener<T:Message>(type:Class<T>, listener:MessageHandler<T>):Void
    {
        var typeName = Type.getClassName(type);
        if (!listeners.exists(typeName))
        {
            listeners.set(typeName, []);
        }
        listeners.get(typeName).push(cast listener);
    }

    public function removeListener<T:Message>(type:Class<T>, listener:MessageHandler<T>):Void
    {
        var typeName = Type.getClassName(type);
        if (listeners.exists(typeName))
        {
            listeners.get(typeName).remove(cast listener);
        }
    }

    public function dispatch<T:Message>(message:T):Void
    {
        var typeName = Type.getClassName(Type.getClass(message));
        if (listeners.exists(typeName))
        {
            for (listener in listeners.get(typeName))
            {
                listener(cast message);
            }
        }
    }
}
