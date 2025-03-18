package olib.ecs;

import olib.ecs.ECSEvent.ComponentAddedEvent;
import olib.ecs.ECSEvent.ComponentRemovedEvent;
import olib.utils.SparseSet;
import olib.utils.IDisposable;

@:autoBuild(olib.ecs.macros.Macros.addPublicFieldInitializersAndSuperAndEntityField())
// @:autoBuild(olib.ecs.macros.Macros.addSparseSet())
@:autoBuild(olib.ecs.macros.Macros.addTypeFields())
@:autoBuild(olib.ecs.macros.Macros.addClassField())
@:autoBuild(olib.ecs.macros.Macros.addGetClassField())
class Component implements IDisposable
{
    public var entity(default, null):Entity;

    var ecs:ECS;

    public function new(?entity:Entity, ecs:ECS)
    {
        if (ecs == null)
            throw "ECS cannot be null";

        this.ecs = ecs;

        if (entity != null)
            addTo(entity);
    }

    public function getClass():Class<Component>
    {
        throw "not implemented";
    }

    function addTo(entity:Entity):Void
    {
        if (this.entity != null)
        {
            throw "Component already owned by an entity";
        }
        ecs.addComponent(this, entity);
        // this.entity = entity;
        // ecs.entities.add(entity);
        // ecs.dispatchEvent(new ComponentAddedEvent(entity, this));
    }

    public function remove():Void
    {
        if (entity == null)
            throw "Component not owned by any entity";
        ecs.removeComponent(this);
        // getAll().remove(entity);
        // var e = entity;
        // entity = null;
        // ecs.dispatchEvent(new ComponentRemovedEvent(e, this));
    }

    public function dispose():Void
    {
        ecs.removeComponent(this);
        ecs = null;
        entity = null;
    }

    public function toString():String
    {
        return "Component";
    }
}

typedef ComponentClass =
{
    var Type(default, null):String;
    var Class:Class<Component>;
}
