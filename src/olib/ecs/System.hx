package olib.ecs;

import olib.utils.maths.GameTime;
import olib.utils.IUpdatable;
import olib.ecs.ECSEvent.ComponentRemovedEvent;
import olib.ecs.ECSEvent.ComponentAddedEvent;
import olib.ecs.ECS.ECSCallback;
import olib.ecs.Component.ComponentClass;

class System implements IUpdatable
{
    /**
     * Limits system refreshes per frame. When true, the first call to refreshEntities will trigger a flag.
     * Subsequent calls to refreshEntities will be ignored until the next frame.
     *
     * Usage in conjunction with refreshOnDirty is undefined and not recommended.
    **/
    public var lockRefreshes:Bool = false;

    /**
     * When true, the system will only refresh entities on the next frame.
     * Any call to refreshEntities will be ignored and will instead set a dirty flag.
     * If the system is dirty, it will be refreshed on the next frame.
     *
     * Usage in conjunction with lockRefreshes is undefined and not recommended.
    **/
    public var refreshOnDirty:Bool = false;

    @:noCompletion
    public var refreshSwitch:Bool = false;
    @:noCompletion
    public var isDirty:Bool = false;

    public var active:Bool = true;

    var componentSet:CSet;
    var entities:Array<Entity>;
    var componentClasses:Array<ComponentClass>;
    var componentTypes:Array<Class<Component>>;
    var componentNames:Array<String>;

    public function new(componentSet:CSet)
    {
        this.componentSet = componentSet;
        refreshEntities();
        ECS.addEventListener(ComponentAddedEvent, componentAddedListener);
        ECS.addEventListener(ComponentRemovedEvent, componentRemovedListener);
    }

    public function update(gameTime:GameTime):Int
    {
        if (!active)
            return 0;

        if (lockRefreshes)
            refreshSwitch = false;

        if (refreshOnDirty && isDirty)
        {
            refreshOnDirty = false;
            refreshEntities();
            refreshOnDirty = true;
            isDirty = false;
        }

        return processEntities();
    }

    function refreshEntities():Void
    {
        if (refreshOnDirty)
        {
            isDirty = true;
            return;
        }

        if (lockRefreshes && refreshSwitch)
        {
            return;
        }
        else if (lockRefreshes)
        {
            refreshSwitch = true;
        }
        entities = CSetResolver.resolve(componentSet, null);
        componentClasses = CSetResolver.extractComponentClasses(componentSet);
        componentTypes = [];
        componentNames = [];
        for (componentClass in componentClasses)
        {
            componentTypes.push(componentClass.Class);
        }
        for (componentClass in componentClasses)
        {
            componentNames.push(componentClass.Type);
        }

        onRefresh();
    }

    function componentAddedListener(e:ECSEvent):Void
    {
        var ev:ComponentAddedEvent = cast e;
        var component:Component = ev.component;

        if (componentTypes.contains(component.getClass()))
        {
            refreshEntities();
        }
    }

    function componentRemovedListener(e:ECSEvent):Void
    {
        var ev:ComponentRemovedEvent = cast e;
        var component:Component = ev.component;

        if (componentTypes.contains(component.getClass()))
        {
            refreshEntities();
        }
    }

    function onRefresh():Void
    {
        //
    }

    function processEntity(entity:Entity):Int
    {
        return 1;
    }

    final public function processEntities():Int
    {
        var count = 0;
        for (entity in entities)
        {
            count += processEntity(entity);
        }
        return count;
    }
}

enum CSet
{
    None;
    All;
    AllOf(list:Array<ComponentClass>);
    OneOf(list:Array<ComponentClass>);
    AnyOf(list:Array<ComponentClass>);
    One(type:ComponentClass);
    Or(setA:CSet, setB:CSet);
    And(setA:CSet, setB:CSet);
    Not(set:CSet);
}

class CSetResolver
{
    public static function extractComponentClasses(cset:CSet):Array<ComponentClass>
    {
        var classes = [];

        switch (cset)
        {
            case AllOf(list):
                classes = list;
            case OneOf(list):
                classes = list;
            case AnyOf(list):
                classes = list;
            case One(type):
                classes = [type];
            case Or(setA, setB):
                classes = extractComponentClasses(setA);
                classes.concat(extractComponentClasses(setB));
            case And(setA, setB):
                classes = extractComponentClasses(setA);
                classes.concat(extractComponentClasses(setB));
            case Not(set):
                classes = extractComponentClasses(set);
            case None:
            case All:
        }

        return classes;
    }

    public static function resolve(cset:CSet, ?entities:Array<Entity>):Array<Entity>
    {
        if (entities == null)
        {
            @:privateAccess entities = cast ECS.entities.dense.copy();
        }

        switch (cset)
        {
            case AllOf(list):
                return allOf(list, entities);
            case OneOf(list):
                return oneOf(list, entities);
            case AnyOf(list):
                return anyOf(list, entities);
            case One(type):
                return allOf([type], entities);
            case Or(setA, setB):
                return or(setA, setB, entities);
            case And(setA, setB):
                return and(setA, setB, entities);
            case Not(set):
                return not(set, entities);
            case None:
                throw "not implemented";
            case All:
                return entities;
        }
    }

    static function and(setA:CSet, setB:CSet, entities:Array<Entity>):Array<Entity>
    {
        var a = resolve(setA, entities);
        var b = resolve(setB, entities);
        var result = [];
        for (entity in a)
        {
            if (b.contains(entity))
            {
                result.push(entity);
            }
        }
        return result;
    }

    static function or(setA:CSet, setB:CSet, entities:Array<Entity>):Array<Entity>
    {
        var a = resolve(setA, entities);
        var b = resolve(setB, entities);
        var result = a;
        for (entity in b)
        {
            if (!result.contains(entity))
            {
                result.push(entity);
            }
        }
        return result;
    }

    static function not(set:CSet, entities:Array<Entity>):Array<Entity>
    {
        var excluded = resolve(set, entities);
        var result = [];

        for (entity in entities)
        {
            if (!excluded.contains(entity))
            {
                result.push(entity);
            }
        }

        return result;
    }

    static function allOf(componentList:Array<ComponentClass>, entities:Array<Entity>):Array<Entity>
    {
        var result = [];
        for (entity in entities)
        {
            var hasAll = true;
            for (component in componentList)
            {
                if (!component.all.exists(entity))
                {
                    hasAll = false;
                    break;
                }
            }
            if (hasAll)
            {
                result.push(entity);
            }
        }
        return result;
    }

    static function anyOf(componentList:Array<ComponentClass>, entities:Array<Entity>):Array<Entity>
    {
        var result = [];
        for (entity in entities)
        {
            var hasAny = false;
            for (component in componentList)
            {
                if (component.all.exists(entity))
                {
                    hasAny = true;
                    break;
                }
            }
            if (hasAny)
            {
                result.push(entity);
            }
        }
        return result;
    }

    static function oneOf(componentList:Array<ComponentClass>, entities:Array<Entity>):Array<Entity>
    {
        var result = [];
        for (entity in entities)
        {
            var hasOne = false;
            var hasMany = false;
            for (component in componentList)
            {
                if (component.all.exists(entity))
                {
                    if (hasOne)
                    {
                        hasMany = true;
                        break;
                    }
                    hasOne = true;
                }
            }
            if (!hasMany && hasOne)
            {
                result.push(entity);
            }
        }
        return result;
    }

    static function intersect(a:Array<Int>, b:Array<Int>)
    {
        var result = [];
        for (i in a)
        {
            if (b.contains(i))
            {
                result.push(i);
            }
        }
        return result;
    }
}
