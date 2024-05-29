package olib.scripts;

@:allow(olib.scripts.Environment)
class Program
{
    static var parser = new hscript.Parser();

    public var script(default, null):Script;

    var expr:hscript.Expr;

    public function new(script:Script)
    {
        this.script = script;
        this.expr = parser.parseString(script);
    }
}

abstract Script(String) from String to String
{
    public function new(script:String)
    {
        this = script;
    }

    public function toProgram():Program
    {
        return new Program(this);
    }
}
