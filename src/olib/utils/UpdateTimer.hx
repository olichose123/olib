package olib.utils;

class UpdateTimer implements IUpdatable implements IDisposable
{
    public var duration:Float;
    public var current(default, null):Float;
    public var loop:Bool = false;
    public var callback:UpdateTimer->Void;
    public var active:Bool = true;

    /**
     * [Description]
     * @param duration in seconds
    **/
    public function new(duration:Float)
    {
        this.duration = duration;
        this.current = duration;
    }

    public function update(dt:Float):Int
    {
        if (active)
        {
            current -= dt;
            if (current <= 0)
            {
                callback(this);
                if (loop)
                {
                    current = duration;
                }
                else
                {
                    active = false;
                    current = 0;
                }
            }
        }
        return 1;
    }

    public function dispose():Void
    {
        duration = 0;
        current = 0;
        loop = false;
        active = false;
        callback = null;
    }
}
