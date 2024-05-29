package olib.heaps;

import hxd.Window.DisplayMode;
import olib.logging.Logger;
import olib.utils.IDisposable;
import hxd.res.DefaultFont;
import haxe.Exception;
import hxd.Key;

class Application implements IDisposable
{
    // public var loader(default, null):Loader;
    public var engine(default, null):h3d.Engine;
    public var sevents(default, null):hxd.SceneEvents;
    public var scene(default, null):GameScene;

    #if debug
    public var console(default, null):h2d.Console;
    #end

    var isDisposed:Bool;
    var title:String;
    var onInit:(Application) -> Void;
    var updateCount:Int = 0;

    public function new(title:String, onInit:(Application) -> Void):Void
    {
        trace('new application ${title}');
        this.title = title;
        this.onInit = onInit;
        // this.loader = loader;
        hxd.System.start(onSystemReady);
    }

    /**
     * Resize the window to a specified size
     * @param width
     * @param height
    **/
    public function resize(width:Int, height:Int):Void
    {
        trace('resizing application ${width}x${height}');
        hxd.Window.getInstance().resize(width, height);
    }

    public function setScene(scene:GameScene):Void
    {
        trace('setting scene');
        if (this.scene != null)
            @:privateAccess this.scene.onRemoved();
        this.scene = scene;
        @:privateAccess this.scene.onAdded(this);
    }

    /**
     * Stop the application
    **/
    public function exit():Void
    {
        trace('exiting application');
        hxd.System.exit();
    }

    public function dispose()
    {
        trace('disposing application');
        engine.onResized = none;
        engine.onContextLost = none;
        isDisposed = true;
        if (sevents != null)
            sevents.dispose();
    }

    function onSystemReady():Void
    {
        this.engine = @:privateAccess new h3d.Engine();
        engine.onReady = onEngineReady;
        engine.init();
    }

    function onEngineReady():Void
    {
        var initDone = false;
        engine.onReady = none;
        engine.onResized = function()
        {
            if (scene == null || scene.s2d == null)
                return;
            scene.s2d.checkResize();
        };

        sevents = new hxd.SceneEvents();

        init();
        hxd.Timer.skip();
        mainLoop();
        hxd.System.setLoop(mainLoop);
        hxd.Key.initialize();
    }

    function mainLoop()
    {
        hxd.Timer.update();
        sevents.checkEvents();
        if (isDisposed)
            return;
        update(hxd.Timer.dt);
        if (isDisposed)
            return;
        var dt = hxd.Timer.dt;
        if (scene != null)
        {
            if (scene.s2d != null)
                scene.s2d.setElapsedTime(dt);
            if (scene.s3d != null)
                scene.s3d.setElapsedTime(dt);
        }
        engine.render(this);
    }

    /**
     * Initializes the application.
    **/
    function init()
    {
        trace('init application');
        #if debug
        console = new h2d.Console(DefaultFont.get());
        #end

        hxd.Window.getInstance().onClose = onClose;
        hxd.Window.getInstance().title = this.title;
        trace('app is init');
        onInit(this);
    }

    /**
     * Called when the window is being closed.
     * @return Bool
    **/
    function onClose():Bool
    {
        trace('closing window');
        try
        {
            #if debug
            Logger.dump("logs");
            #end
        }
        catch (e:Exception)
        {
            return true;
        }
        return true;
    }

    @:noCompletion
    public function render(e:h3d.Engine)
    {
        if (scene != null)
            @:privateAccess scene.render();
    }

    /**
     * Updates the application each frame
     * @param dt
    **/
    function update(dt:Float)
    {
        #if debug
        if (Key.isPressed(Key.F1))
        {
            trace('show console');
            if (console.parent == null && scene != null && scene.s2d != null)
                scene.s2d.addChild(console);
            console.show();
        }
        #end
        if (scene != null)
            @:privateAccess updateCount = scene.update(dt);
        else
            updateCount = 0;
    }

    /**
     * Simple empty function used for engine callbacks by heaps
    **/
    static function none() {}

    public static function setWindowSize(width:Int, height:Int):Void
    {
        @:privateAccess hxd.Window.getInstance().window.center();
        hxd.Window.getInstance().resize(width, height);
    }

    public static function setWindowScreenMode(screenMode:ScreenMode)
    {
        switch (screenMode)
        {
            case ScreenMode.Windowed:
                hxd.Window.getInstance().displayMode = DisplayMode.Windowed;

            case ScreenMode.Fullscreen:
                hxd.Window.getInstance().displayMode = DisplayMode.Fullscreen;

            case ScreenMode.Borderless:
                hxd.Window.getInstance().displayMode = DisplayMode.Borderless;
        }
    }
}

enum abstract ScreenMode(String)
{
    var Windowed = "windowed";
    var Fullscreen = "fullscreen";
    var Borderless = "borderless";
}
