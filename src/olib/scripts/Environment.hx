package olib.scripts;

class Environment
{
    var interpreter:hscript.Interp;

    public function new()
    {
        interpreter = new hscript.Interp();
    }

    public function run(script:Program):Void
    {
        interpreter.execute(script.program);
    }

    public function setVariable(name:String, value:Dynamic):Void
    {
        interpreter.variables.set(name, value);
    }

    public function getVariable(name:String):Dynamic
    {
        return interpreter.variables.get(name);
    }

    public function listVariables():Iterator<String>
    {
        return interpreter.variables.keys();
    }
}
