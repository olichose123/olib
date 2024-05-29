package olib.scripts;

import haxe.Exception;
import hscript.Expr;

class Script
{
    public var name(default, null):String;
    public var code(default, null):String;
    public var expr(default, null):Expr;

    public function new(name:String, code:String)
    {
        this.name = name;
        this.code = code;
    }

    public function compile(?parser:hscript.Parser)
    {
        if (parser == null)
            parser = new hscript.Parser();

        if (expr == null)
        {
            try
            {
                expr = parser.parseString(code);
            }
            catch (e:hscript.Expr.Error)
            {
                throw new ScriptError('Script $name: Parsing error at line ${e.line}');
            }
        }
        else
        {
            throw new ScriptError('Script $name: Already compiled');
        }
    }
}

class Environment
{
    var interp:hscript.Interp;

    public var variables(get, null):Map<String, Dynamic>;

    public function get_variables():Map<String, Dynamic>
    {
        return interp.variables;
    }

    public function new()
    {
        interp = new hscript.Interp();
    }

    public function run(script:Script)
    {
        if (script.expr == null)
            throw new ScriptError('Script $script.name: Not compiled');

        interp.execute(script.expr);
    }
}

class ScriptError extends Exception {}
