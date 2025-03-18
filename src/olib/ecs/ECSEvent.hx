package olib.ecs;

import olib.ecs.Entity;

@:autoBuild(olib.ecs.macros.Macros.addTypeFields())
@:autoBuild(olib.ecs.macros.Macros.addGetTypeField())
class ECSEvent
{
    public var entity:Entity;

    public function getType():String
    {
        throw "not implemented";
    }

    public function new(entity:Entity)
    {
        this.entity = entity;
    }
}

class EntityCreatedEvent extends ECSEvent
{
    public function new(entity:Entity)
    {
        super(entity);
    }
}

class EntityDestroyedEvent extends ECSEvent
{
    public function new(entity:Entity)
    {
        super(entity);
    }
}

class ComponentAddedEvent extends ECSEvent
{
    public var component:Component;

    public function new(entity:Entity, component:Component)
    {
        super(entity);
        this.component = component;
    }
}

class ComponentRemovedEvent extends ECSEvent
{
    public var component:Component;

    public function new(entity:Entity, component:Component)
    {
        super(entity);
        this.component = component;
    }
}
