package olib.ecs;

import hscript.Expr;
import olib.ecs.System.ComponentSet;
import olib.utils.maths.GameTime;
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
        var ecs = new ECS();
        var entity = ecs.createEntity();
        var c = new MyFirstComponent(entity, ecs, "potato", 10, 20);
        c.x = 3;
        Assert.isTrue(ecs.hasComponent(entity, MyFirstComponent));
        Assert.equals(ecs.getComponent(entity, MyFirstComponent), c);
    }

    function testCallback():Void
    {
        var ecs = new ECS();
        // ugly way to update a value by reference
        var arr = [];
        var callback = function(e:ECSEvent)
        {
            arr.push(e);
        }
        ecs.addEventListener(EntityCreatedEvent, callback);
        var entity = ecs.createEntity();
        Assert.isTrue(arr.length == 1);
    }

    function testSystemComponentHandling()
    {
        var ecs = new ECS();
        var entity = ecs.createEntity();
        var component = new MyFirstComponent(entity, ecs, "potato", 10, 20);
        var c:ComponentClass = cast MyFirstComponent;
        Assert.isTrue(ecs.hasComponent(entity, MyFirstComponent));
        Assert.equals(ecs.getComponent(entity, MyFirstComponent), component);

        Assert.equals(MyFirstComponent, c.Class);
    }

    function testCSetResolver()
    {
        var ecs = new ECS();

        var emily_abcde = ecs.createEntity();
        var johny_abcd = ecs.createEntity();
        var bobby_abc = ecs.createEntity();
        var alice_ab = ecs.createEntity();
        var henry_d = ecs.createEntity();

        new CompA(emily_abcde, ecs);
        new CompB(emily_abcde, ecs);
        new CompC(emily_abcde, ecs);
        new CompD(emily_abcde, ecs);
        new CompE(emily_abcde, ecs);

        new CompA(johny_abcd, ecs);
        new CompB(johny_abcd, ecs);
        new CompC(johny_abcd, ecs);
        new CompD(johny_abcd, ecs);

        new CompA(bobby_abc, ecs);
        new CompB(bobby_abc, ecs);
        new CompC(bobby_abc, ecs);

        new CompA(alice_ab, ecs);
        new CompB(alice_ab, ecs);

        new CompD(henry_d, ecs);

        var set1 = new ComponentSet(CSet.All, ecs);
        var resolved_set1 = set1.resolve();
        Assert.equals([0, 1, 2, 3, 4].toString(), resolved_set1.toString());

        var set2 = new ComponentSet(CSet.None, ecs);
        var resolved_set2 = set2.resolve();
        Assert.equals([].toString(), resolved_set2.toString());

        var set3 = new ComponentSet(CSet.AllOf([cast CompA, cast CompB, cast CompC]), ecs);
        var resolved_set3 = set3.resolve();
        Assert.equals([0, 1, 2].toString(), resolved_set3.toString());

        // var set4 = CSet.OneOf([cast CompC, cast CompD]);
        var set4 = new ComponentSet(CSet.OneOf([cast CompC, cast CompD]), ecs);
        var resolved_set4 = set4.resolve();
        Assert.equals([2, 4].toString(), resolved_set4.toString());

        // var set5 = CSet.AnyOf([cast CompC, cast CompD]);
        var set5 = new ComponentSet(CSet.AnyOf([cast CompC, cast CompD]), ecs);
        var resolved_set5 = set5.resolve();
        Assert.equals([0, 1, 2, 4].toString(), resolved_set5.toString());

        // var set6 = CSet.One(cast CompD);
        var set6 = new ComponentSet(CSet.One(cast CompD), ecs);
        var resolved_set6 = set6.resolve();
        Assert.equals([0, 1, 4].toString(), resolved_set6.toString());

        // var set7 = CSet.And(set3, set4);
        var set7 = new ComponentSet(CSet.And(set3.set, set4.set), ecs);
        var resolved_set7 = set7.resolve();
        Assert.equals([2].toString(), resolved_set7.toString());

        // var set8 = CSet.Or(set3, set4);
        var set8 = new ComponentSet(CSet.Or(set3.set, set4.set), ecs);
        var resolved_set8 = set8.resolve();
        Assert.equals([0, 1, 2, 4].toString(), resolved_set8.toString());

        // var set9 = CSet.Not(CSet.One(cast CompD));
        var set9 = new ComponentSet(CSet.Not(CSet.One(cast CompD)), ecs);
        var resolved_set9 = set9.resolve();
        Assert.equals([2, 3].toString(), resolved_set9.toString());

        // var set10 = ;
        var set10 = new ComponentSet(CSet.And(CSet.AllOf([cast CompA, cast CompB]), CSet.Not(CSet.AnyOf([cast CompC, cast CompD]))), ecs);
        var resolved_set10 = set10.resolve();
        Assert.equals([3].toString(), resolved_set10.toString());
    }

    function sl(a, b)
    {
        return a - b;
    }

    function testSystem()
    {
        var ecs = new ECS();
        var emily = ecs.createEntity();
        var johny = ecs.createEntity();

        new SCompA(emily, ecs, 0);
        new SCompB(emily, ecs, 5);

        new SCompA(johny, ecs, 0);
        new SCompB(johny, ecs, 10);

        var system = new MySystem(ecs);
        system.processEntities();
        // Assert.equals(5, cast SCompA.all.get(emily).x);
        // Assert.equals(10, cast SCompA.all.get(johny).x);
        Assert.equals(5, ecs.getComponent(emily, SCompA).x);
        Assert.equals(10, ecs.getComponent(johny, SCompA).x);

        ecs.getComponent(emily, SCompB).remove();
        system.processEntities();
        // Assert.equals(5, cast SCompA.all.get(emily).x);
        // Assert.equals(20, cast SCompA.all.get(johny).x);
        Assert.equals(5, ecs.getComponent(emily, SCompA).x);
        Assert.equals(20, ecs.getComponent(johny, SCompA).x);

        var mariane = ecs.createEntity();
        new SCompA(mariane, ecs, 0);
        system.processEntities();
        // Assert.equals(5, cast SCompA.all.get(emily).x);
        // Assert.equals(30, cast SCompA.all.get(johny).x);
        // Assert.equals(0, cast SCompA.all.get(mariane).x);
        Assert.equals(5, ecs.getComponent(emily, SCompA).x);
        Assert.equals(30, ecs.getComponent(johny, SCompA).x);
        Assert.equals(0, ecs.getComponent(mariane, SCompA).x);
        new SCompB(mariane, ecs, 15);
        system.processEntities();
        // Assert.equals(15, cast SCompA.all.get(mariane).x);
        Assert.equals(15, ecs.getComponent(mariane, SCompA).x);
    }
}

class MyFirstComponent extends Component
{
    public var x:Int;
    public var y:Int;
    public var name:String;

    public override function toString():String
    {
        return Type;
    }
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
    public function new(ecs:ECS)
    {
        super(new ComponentSet(CSet.AllOf([cast SCompA, cast SCompB]), ecs), ecs);
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
        var a = ecs.getComponent(entity, SCompA);
        var b = ecs.getComponent(entity, SCompB);

        a.x += b.y;
        return 1;
    }
}
