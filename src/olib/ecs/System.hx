package olib.ecs;

import olib.ecs.Component.ComponentClass;

class System
{
    public function new()
    {
        //
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
                return cast type.all.dense.copy();
            case Or(setA, setB):
                return or(setA, setB, entities);
            case And(setA, setB):
                return and(setA, setB, entities);
            case Not(set):
                return not(set, entities);
            case None:
                return [];
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
