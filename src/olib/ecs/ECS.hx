package olib.ecs;

import olib.utils.SparseSet;
import olib.utils.SparseSet.IntSparseSet;
import haxe.ds.StringMap;
import olib.ecs.ECSEvent;

typedef ECSCallback = (e:ECSEvent) -> Void;

class ECS
{
    static var entityCounter:Int = 0;
    static var entities:IntSparseSet = new IntSparseSet();

    public static var listeners:StringMap<Array<ECSCallback>> = new StringMap();
    public static var componentTypes:StringMap<SparseSet<Component>> = new StringMap();

    public static function createEntity():Entity
    {
        var e = entityCounter++;
        entities.add(e);
        dispatchEvent(new EntityCreatedEvent(e));
        return e;
    }

    public static function dispatchEvent(e:ECSEvent):Void
    {
        // throw e.getType();
        trace(e.getType());
        var callbacks = listeners.get(e.getType());
        if (callbacks == null)
            return;
        for (callback in callbacks)
        {
            trace("callback!");

            callback(e);
        }
    }

    public static function addEventListener(type:Class<ECSEvent>, callback:ECSCallback):Void
    {
        var typeName = Type.getClassName(type).split('.').pop();
        if (!listeners.exists(typeName))
        {
            listeners.set(typeName, []);
        }
        listeners.get(typeName).push(callback);
    }

    public static function removeEventListener(type:Class<ECSEvent>, callback:ECSCallback):Void
    {
        var typeName = Type.getClassName(type).split('.').pop();
        if (listeners.exists(typeName))
        {
            var callbacks = listeners.get(typeName);
            var index = callbacks.indexOf(callback);
            if (index != -1)
            {
                callbacks.splice(index, 1);
            }
        }
    }
}
