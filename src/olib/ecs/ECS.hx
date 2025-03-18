package olib.ecs;

import olib.ecs.Component.ComponentClass;
import haxe.ds.IntMap;
import olib.utils.SparseSet;
import olib.utils.SparseSet.IntSparseSet;
import haxe.ds.StringMap;
import olib.ecs.ECSEvent;

typedef ECSCallback = (e:ECSEvent) -> Void;

class ECS
{
    public var entityCounter(default, null):Int = 0;
    public var entities(default, null):IntSparseSet;
    public var listeners(default, null):StringMap<Array<ECSCallback>>;
    public var componentsByName(default, null):StringMap<SparseSet<Component>>;
    public var componentsByCC(default, null):Map<ComponentClass, SparseSet<Component>>;

    public function new()
    {
        entities = new IntSparseSet();
        listeners = new StringMap();
        componentsByName = new StringMap();
        componentsByCC = new Map<ComponentClass, SparseSet<Component>>();
    }

    public function addComponent(component:Component, entity:Entity):Void
    {
        if (component.entity != null)
        {
            throw "Component already owned by an entity";
        }

        @:privateAccess component.entity = entity;
        var cl:ComponentClass = cast component.getClass();
        var set:SparseSet<Component>;

        if (!componentsByCC.exists(cl))
        {
            set = new SparseSet<Component>();
            componentsByCC.set(cl, set);
        }
        else
        {
            set = componentsByCC.get(cl);
        }
        set.add(entity, component);

        if (!componentsByName.exists(cl.Type))
        {
            componentsByName.set(cl.Type, set);
        }
        dispatchEvent(new ComponentAddedEvent(entity, component));
    }

    public function getComponent<T:Component>(entity:Entity, cl:Class<T>):T
    {
        var cc:ComponentClass = cast cl;
        return cast componentsByCC.get(cc).get(entity);
    }

    public function hasComponent<T:Component>(entity:Entity, cl:Class<T>):Bool
    {
        var cc:ComponentClass = cast cl;
        return cast componentsByCC.get(cc).exists(entity);
    }

    public function removeComponent(component:Component):Void
    {
        if (component.entity == null)
            return;

        var cl:ComponentClass = cast component.getClass();
        var set:SparseSet<Component> = componentsByCC.get(cl);
        if (set != null)
        {
            set.remove(component.entity);
            dispatchEvent(new ComponentRemovedEvent(component.entity, component));
        }
    }

    public function createEntity():Entity
    {
        var e = entityCounter++;
        entities.add(e);
        dispatchEvent(new EntityCreatedEvent(e));
        return e;
    }

    public function destroyEntity(e:Entity):Void
    {
        var components = getEntityComponents(e);
        for (component in components)
            component.remove();

        entities.remove(e);
        dispatchEvent(new EntityDestroyedEvent(e));
    }

    public function getEntityComponents(e:Entity):Array<Component>
    {
        var components = [];

        for (kv in componentsByName.keyValueIterator())
        {
            if (kv.value.exists(e))
            {
                components.push(kv.value.get(e));
            }
        }
        return components;
    }

    public function dispatchEvent(e:ECSEvent):Void
    {
        var callbacks = listeners.get(e.getType());
        if (callbacks == null)
            return;
        for (callback in callbacks)
        {
            callback(e);
        }
    }

    public function addEventListener(type:Class<ECSEvent>, callback:ECSCallback):Void
    {
        var typeName = Type.getClassName(type).split('.').pop();
        if (!listeners.exists(typeName))
        {
            listeners.set(typeName, []);
        }

        if (!listeners.get(typeName).contains(callback))
            listeners.get(typeName).push(callback);
    }

    public function removeEventListener(type:Class<ECSEvent>, callback:ECSCallback):Void
    {
        var typeName = Type.getClassName(type).split('.').pop();
        if (listeners.exists(typeName))
        {
            var callbacks = listeners.get(typeName).remove(callback);
        }
    }
}
