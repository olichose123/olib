package olib.heaps;

import olib.utils.GameTime;
import olib.utils.IDisposable;

@:allow(oli.heaps.Application)
class GameScene implements IDisposable
{
    public var application(default, null):Application;
    public var isDisposed(default, null):Bool = false;
    public var s3d(default, null):h3d.scene.Scene;
    public var s2d(default, null):h2d.Scene;

    public function new():Void
    {
        s3d = new h3d.scene.Scene();
        s2d = new h2d.Scene();
    }

    function onAdded(application:Application):Void
    {
        this.application = application;
        application.sevents.addScene(s2d);
        application.sevents.addScene(s3d);
        init();
    }

    function onRemoved():Void
    {
        application.sevents.removeScene(s2d);
        application.sevents.removeScene(s3d);
        application = null;
    }

    public function dispose():Void
    {
        if (application != null)
            trace("Disposing a gamescene that is still attached to an application");
        isDisposed = true;
        if (s2d != null)
            s2d.dispose();
        if (s3d != null)
            s3d.dispose();
    }

    function init():Void {}

    function update(gameTime:GameTime):Int
    {
        throw new haxe.exceptions.NotImplementedException();
    }

    function render():Void
    {
        if (s2d != null)
            s2d.render(application.engine);
        if (s3d != null)
            s3d.render(application.engine);
    }
}
