package olib.ecs;

import olib.ecs.ECSEvent.ComponentAddedEvent;
import olib.ecs.ECSEvent.ComponentRemovedEvent;
import olib.utils.SparseSet;
import olib.utils.IDisposable;

@:autoBuild(olib.ecs.macros.Macros.addPublicFieldInitializers())
@:autoBuild(olib.ecs.macros.Macros.addSparseSet())
@:autoBuild(olib.ecs.macros.Macros.addEntityField())
@:autoBuild(olib.ecs.macros.Macros.addTypeFields())
@:autoBuild(olib.ecs.macros.Macros.addGetAllField())
@:autoBuild(olib.ecs.macros.Macros.addClassField())
@:autoBuild(olib.ecs.macros.Macros.addGetClassField())
class Component implements IDisposable
{
    public var entity(default, null):Entity;

    public function new(?entity:Entity)
    {
        if (entity != null)
        {
            addTo(entity);
        }
    }

    public function getClass():Class<Component>
    {
        throw "not implemented";
    }

    public function getAll():SparseSet<Component>
    {
        throw "not implemented";
    }

    public function addTo(entity:Entity):Void
    {
        if (this.entity != null)
        {
            throw "Component already owned by an entity";
        }
        this.entity = entity;
        @:privateAccess ECS.entities.add(entity);
        ECS.dispatchEvent(new ComponentAddedEvent(entity, this));
    }

    public function remove():Void
    {
        if (entity != null)
        {
            getAll().remove(entity);
            var e = entity;
            entity = null;
            ECS.dispatchEvent(new ComponentRemovedEvent(e, this));
        }
        else
        {
            throw "Component not owned by any entity";
        }
    }

    public function dispose():Void
    {
        getAll().remove(entity);
        ECS.dispatchEvent(new ComponentRemovedEvent(entity, this));
        entity = null;
    }

    public function toString():String
    {
        return "Component";
    }
}

typedef ComponentClass =
{
    var all:SparseSet<Component>;
    var Type(default, null):String;
    var Class:Class<Component>;
}
