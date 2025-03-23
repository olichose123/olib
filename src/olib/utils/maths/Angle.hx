package olib.utils.maths;

import h2d.col.Point;

@:forward(clone, scaled)
abstract Angle(Point) to Point
{
    /**
     * Represents an angle, a direction vector
     * Can easily be converted to and from radians or degrees
     * @param x
     * @param y
    **/
    public inline function new(x:Float = 1, y:Float = 0)
    {
        this = new Point(x, y);
        this.normalize();
    }

    public var x(get, never):Float;

    function get_x():Float
    {
        return this.x;
    }

    public var y(get, never):Float;

    function get_y():Float
    {
        return this.y;
    }

    public inline function ofTwoPoints(x:Float, y:Float, x2:Float, y2:Float):Angle
    {
        this.x = x2 - x;
        this.y = y2 - y;
        this.normalize();
        return cast this;
    }

    public static inline function ofRadians(a:Float):Angle
    {
        return cast new Point(Math.cos(a), Math.sin(a));
    }

    public static inline function ofDegrees(a:Float):Angle
    {
        return ofRadians(a / 180 * Math.PI);
    }

    public inline function toRadians():Float
    {
        return Math.atan2(this.y, this.x);
    }

    public inline function toDegrees():Float
    {
        return toRadians() * 180 / Math.PI;
    }

    @:op(A + B)
    public inline function addAngle(a:Angle):Angle
    {
        return Angle.ofRadians(toRadians() + a.toRadians());
    }

    @:op(A - B)
    public inline function subAngle(a:Angle):Angle
    {
        return Angle.ofRadians(toRadians() - a.toRadians());
    }

    public inline function toString():String
    {
        return 'Angle ${toDegrees()} deg';
    }

    @:op(A * B)
    public inline function dot(a:Angle):Float
    {
        return x * a.x + y * a.y;
    }

    public inline function rotate(a:Float):Void
    {
        var c = Math.cos(a);
        var s = Math.sin(a);
        var x = this.x;
        this.x = x * c - this.y * s;
        this.y = x * s + this.y * c;
    }

    public inline function rotateDeg(a:Float):Void
    {
        rotate(a / 180 * Math.PI);
    }
}
