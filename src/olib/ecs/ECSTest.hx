package olib.ecs;

import olib.utils.maths.GameTime;
import olib.ecs.System.CSetResolver;
import olib.ecs.System.CSet;
import olib.ecs.Component.ComponentClass;
import olib.ecs.ECSEvent.EntityCreatedEvent;
import utest.Assert;
import utest.Test;
import olib.ecs.ECS;
import olib.ecs.ECSEvent;

class ECSTest extends Test
{
    function testComponent():Void
    {
        var entity = ECS.createEntity();
        var c = new MyFirstComponent(entity, "potato", 10, 20);
        Assert.isTrue(MyFirstComponent.all.exists(entity));
        Assert.equals(MyFirstComponent.all.get(entity), c);
        @:privateAccess Assert.equals(c.getAll(), MyFirstComponent.all);
    }

    function testCallback():Void
    {
        // ugly way to update a value by reference
        var arr = [];
        var callback = function(e:ECSEvent)
        {
            arr.push(e);
        }
        ECS.addEventListener(EntityCreatedEvent, callback);
        var entity = ECS.createEntity();
        Assert.isTrue(arr.length == 1);
    }

    function testSystemComponentHandling()
    {
        var entity = ECS.createEntity();
        var component = new MyFirstComponent(entity, "potato", 10, 20);
        var c:ComponentClass = cast MyFirstComponent;
        Assert.isTrue(c.all.exists(entity));
        Assert.equals(c.all.get(entity), component);

        Assert.equals(MyFirstComponent, c.Class);
    }

    function testCSetResolver()
    {
        @:privateAccess ECS.entities.clear();
        @:privateAccess ECS.entityCounter = 0;
        var emily_abcde = ECS.createEntity();
        var johny_abcd = ECS.createEntity();
        var bobby_abc = ECS.createEntity();
        var alice_ab = ECS.createEntity();
        var henry_d = ECS.createEntity();

        new CompA(emily_abcde);
        new CompB(emily_abcde);
        new CompC(emily_abcde);
        new CompD(emily_abcde);
        new CompE(emily_abcde);

        new CompA(johny_abcd);
        new CompB(johny_abcd);
        new CompC(johny_abcd);
        new CompD(johny_abcd);

        new CompA(bobby_abc);
        new CompB(bobby_abc);
        new CompC(bobby_abc);

        new CompA(alice_ab);
        new CompB(alice_ab);

        new CompD(henry_d);

        var set1 = CSet.All;
        var resolved_set1 = CSetResolver.resolve(set1);
        Assert.equals([0, 1, 2, 3, 4].toString(), resolved_set1.toString());

        // var set2 = CSet.None;
        // var resolved_set2 = CSetResolver.resolve(set2);
        // Assert.equals([].toString(), resolved_set2.toString());

        var set3 = CSet.AllOf([cast CompA, cast CompB, cast CompC]);
        var resolved_set3 = CSetResolver.resolve(set3);
        Assert.equals([0, 1, 2].toString(), resolved_set3.toString());

        var set4 = CSet.OneOf([cast CompC, cast CompD]);
        var resolved_set4 = CSetResolver.resolve(set4);
        Assert.equals([2, 4].toString(), resolved_set4.toString());

        var set5 = CSet.AnyOf([cast CompC, cast CompD]);
        var resolved_set5 = CSetResolver.resolve(set5);
        Assert.equals([0, 1, 2, 4].toString(), resolved_set5.toString());

        var set6 = CSet.One(cast CompD);
        var resolved_set6 = CSetResolver.resolve(set6);
        Assert.equals([0, 1, 4].toString(), resolved_set6.toString());

        var set7 = CSet.And(set3, set4);
        var resolved_set7 = CSetResolver.resolve(set7);
        Assert.equals([2].toString(), resolved_set7.toString());

        var set8 = CSet.Or(set3, set4);
        var resolved_set8 = CSetResolver.resolve(set8);
        Assert.equals([0, 1, 2, 4].toString(), resolved_set8.toString());

        var set9 = CSet.Not(CSet.One(cast CompD));
        var resolved_set9 = CSetResolver.resolve(set9);
        Assert.equals([2, 3].toString(), resolved_set9.toString());

        var set10 = CSet.And(CSet.AllOf([cast CompA, cast CompB]), CSet.Not(CSet.AnyOf([cast CompC, cast CompD])));
        var resolved_set10 = CSetResolver.resolve(set10);
        Assert.equals([3].toString(), resolved_set10.toString());
    }

    function sl(a, b)
    {
        return a - b;
    }

    function testSystem()
    {
        @:privateAccess ECS.entities.clear();
        @:privateAccess ECS.entityCounter = 0;
        var emily = ECS.createEntity();
        var johny = ECS.createEntity();

        new SCompA(emily, 0);
        new SCompB(emily, 5);

        new SCompA(johny, 0);
        new SCompB(johny, 10);

        var system = new MySystem();
        system.processEntities();
        Assert.equals(5, cast SCompA.all.get(emily).x);
        Assert.equals(10, cast SCompA.all.get(johny).x);

        SCompB.all.get(emily).remove();
        system.processEntities();
        Assert.equals(5, cast SCompA.all.get(emily).x);
        Assert.equals(20, cast SCompA.all.get(johny).x);

        var mariane = ECS.createEntity();
        new SCompA(mariane, 0);
        system.processEntities();
        Assert.equals(5, cast SCompA.all.get(emily).x);
        Assert.equals(30, cast SCompA.all.get(johny).x);
        Assert.equals(0, cast SCompA.all.get(mariane).x);
        new SCompB(mariane, 15);
        system.processEntities();
        Assert.equals(15, cast SCompA.all.get(mariane).x);
    }
}

class MyFirstComponent extends Component
{
    public var x:Int;
    public var y:Int;
    public var name:String;
}

class CompA extends Component {}
class CompB extends Component {}
class CompC extends Component {}
class CompD extends Component {}
class CompE extends Component {}

class SCompA extends Component
{
    public var x:Int;
}

class SCompB extends Component
{
    public var y:Int;
}

class MySystem extends System
{
    public function new()
    {
        super(CSet.AllOf([cast SCompA, cast SCompB]));
    }

    override function update(gameTime:GameTime):Int
    {
        var count = 0;
        count += super.update(gameTime);

        //

        return count;
    }

    override function processEntity(entity:Entity)
    {
        var a = cast SCompA.all.get(entity);
        var b = cast SCompB.all.get(entity);
        a.x += b.y;
        return 1;
    }
}
