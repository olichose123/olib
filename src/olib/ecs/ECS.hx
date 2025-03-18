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

    public static function destroyEntity(e:Entity):Void
    {
        var components = getEntityComponents(e);
        for (component in components)
        {
            component.remove();
        }
        entities.remove(e);
        dispatchEvent(new EntityDestroyedEvent(e));
    }

    public static function getEntityComponents(e:Entity):Array<Component>
    {
        var components = [];
        for (kv in componentTypes.keyValueIterator())
        {
            if (kv.value.exists(e))
            {
                components.push(kv.value.get(e));
            }
        }
        return components;
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

        if (!listeners.get(typeName).contains(callback))
            listeners.get(typeName).push(callback);
    }

    public static function removeEventListener(type:Class<ECSEvent>, callback:ECSCallback):Void
    {
        var typeName = Type.getClassName(type).split('.').pop();
        if (listeners.exists(typeName))
        {
            var callbacks = listeners.get(typeName).remove(callback);
        }
    }
}
