package olib.utils;

import olib.logging.Logger.LogLevel;
import haxe.Exception;
import olib.utils.IDisposable;

class Task<Params, Output> implements IDisposable
{
    public var params(default, null):Params;
    public var output(default, null):Output;
    public var error(default, null):Dynamic;
    public var has_init(default, null):Bool = false;
    public var has_run(default, null):Bool = false;
    public var has_error(default, null):Bool = false;

    public static function runTask(task:Task<Dynamic, Dynamic>, skipErrors:Bool = false, disposeAfter:Bool = false):Task<Dynamic, Dynamic>
    {
        task.processInit();
        if (task.has_error)
            if (!skipErrors)
                throw task.error;
            else
                trace(Std.string(task.error), LogLevel.Error);
        task.processRun();
        if (task.has_error)
            if (!skipErrors)
                throw task.error;
            else
                trace(Std.string(task.error), LogLevel.Error);
        if (disposeAfter)
            task.dispose();
        return task;
    }

    public function new(p:Params):Void
    {
        params = p;
    }

    public function dispose():Void
    {
        params = null;
        output = null;
        error = null;
        has_run = true;
        has_error = false;
    }

    @:noCompletion
    public function processInit():Void
    {
        if (has_init)
            throw new TaskException("Task has already been initialized");
        try
        {
            init(params);
            has_init = true;
        }
        catch (e)
        {
            has_error = true;
            error = e;
        }
    }

    // to override
    function init(p:Params):Void {}

    @:noCompletion
    public function processRun():Void
    {
        if (!has_init)
            throw new TaskException("Task must be initialized before running");
        if (has_run)
            throw new TaskException("Task has already been run");

        has_run = true;
        try
        {
            output = run(params);
        }
        catch (e)
        {
            has_error = true;
            error = e;
        }
    }

    // to override
    function run(p:Params):Output
    {
        throw new TaskException("Not implemented");
    }
}

class TaskList implements IDisposable
{
    public var tasks(default, null):Array<Task<Dynamic, Dynamic>> = [];
    public var init_tasks(default, null):Array<Task<Dynamic, Dynamic>> = [];
    public var completed_tasks(default, null):Array<Task<Dynamic, Dynamic>> = [];

    public function new():Void {}

    public function addTask(task:Task<Dynamic, Dynamic>):Void
    {
        tasks.push(task);
    }

    public function initOne():Int
    {
        if (tasks.length > 0)
        {
            var task = tasks.shift();
            task.processInit();
            if (!task.has_error)
                init_tasks.push(task);
        }
        return tasks.length;
    }

    public function processOne():Int
    {
        if (tasks.length > 0)
        {
            var task = init_tasks.shift();
            task.processRun();
            if (!task.has_error)
                completed_tasks.push(task);
            return tasks.length;
        }
        return 0;
    }

    public function dispose():Void
    {
        tasks.resize(0);
        init_tasks.resize(0);
        completed_tasks.resize(0);

        tasks = null;
        init_tasks = null;
        completed_tasks = null;
    }
}

class TaskException extends Exception {}
