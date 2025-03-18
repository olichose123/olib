package olib.ecs.macros;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.FunctionArg;
import haxe.macro.Expr.Access;
import haxe.Exception;
import haxe.macro.Expr.Field;

using haxe.macro.ComplexTypeTools;
using haxe.macro.TypeTools;

class MacroUtil
{
    public static function filterFieldsByAccess(fields:Array<Field>, accessWhitelist:Array<Access> = null, accessBlacklist:Array<Access> = null):Array<Field>
    {
        if (accessWhitelist == null && accessBlacklist == null)
            return fields;

        if (accessWhitelist == null)
            accessWhitelist = [];

        if (accessBlacklist == null)
            accessBlacklist = [];

        var result:Array<Field> = [];
        for (field in fields)
        {
            var isValid:Bool = true;
            for (access in accessBlacklist)
            {
                if (field.access.contains(access))
                {
                    isValid = false;
                    break;
                }
            }
            if (!isValid)
                continue;
            for (access in accessWhitelist)
            {
                if (!field.access.contains(access))
                {
                    isValid = false;
                    break;
                }
            }
            if (!isValid)
                continue;
            result.push(field);
        }
        return result;
    }

    public static function getFieldByName(fields:Array<Field>, name:String, accessWhitelist:Array<Access> = null, accessBlacklist:Array<Access> = null):Field
    {
        fields = filterFieldsByAccess(fields, accessWhitelist, accessBlacklist);
        for (field in fields)
        {
            if (field.name == name)
                return field;
        }
        throw new MacroException("Field " + name + " not found");
    }

    public static function filterFields(fields:Array<Field>, func:(Field) -> Bool):Array<Field>
    {
        var result:Array<Field> = [];
        for (field in fields)
        {
            if (func(field))
                result.push(field);
        }
        return result;
    }

    public static function addArgumentToFunction(field:Field, functionArg:FunctionArg, addFirst:Bool = false):Void
    {
        switch (field.kind)
        {
            case FFun(f):
                if (addFirst)
                    f.args.unshift(functionArg);
                else
                    f.args.push(functionArg);
            default:
                throw new MacroException("Field " + field.name + " is not a function");
        }
    }

    public static function addExpressionToFunction(field:Field, expression:Expr, addFirst:Bool = false):Void
    {
        switch (field.kind)
        {
            case FFun(f):
                if (addFirst)
                    f.expr = macro $b{[expression, f.expr]};
                else
                    f.expr = macro $b{[f.expr, expression]};
            default:
                throw new MacroException("Field " + field.name + " is not a function");
        }
    }

    public static function getTypeName(type:ComplexType):String
    {
        switch (type)
        {
            case TPath(p):
                if (p.sub != null)
                    return p.sub;
                else
                    return p.name;
            default:
                throw new MacroException("Type " + type + " is not supported");
        }
    }

    public static function getFieldDefaultValue(field:Field):Constant
    {
        switch (field.kind)
        {
            case FVar(t, e):
                switch (e.expr)
                {
                    case EConst(c):
                        return c;
                    case _:
                        throw new MacroException("Field " + field.name + " is not a constant");
                }
            case _:
                throw new MacroException("Field " + field.name + " is not a variable");
        }
    }

    public static function getTypeParameter(type:ComplexType, index:Int):ComplexType
    {
        switch (type)
        {
            case TPath(p):
                if (p.params == null)
                    throw new MacroException("Type " + type + " has no parameters");
                if (index < 0 || index >= p.params.length)
                    throw new MacroException("Type " + type + " has no parameter at index " + index);
                switch (p.params[index])
                {
                    case TPType(t):
                        return t;
                    case _:
                        throw new MacroException("Type " + type + " has no parameter at index " + index);
                }
            case _:
                throw new MacroException("Type " + type + " is not supported");
        }
    }

    public static function getTypeClass(type:Type):ClassType
    {
        switch (type)
        {
            case TInst(t, params):
                return t.get();
            case _:
                throw new MacroException("Type " + type + " is not supported");
        }
    }

    public static function findMetadata(type:Type, name:String):Array<MetadataEntry>
    {
        var meta;
        var entries;
        switch (type)
        {
            case TInst(t, params):
                meta = t.get().meta;
            case _:
                throw new MacroException("Type " + type + " is not supported");
        }
        if (!meta.has(name))
        {
            return null;
        }
        else
        {
            return meta.extract(name);
        }
        return null;
    }

    public static function findMetadataStringValue(type:Type, name:String):String
    {
        var entries = findMetadata(type, name);
        if (entries == null)
            return null;
        if (entries.length == 0)
            return null;

        var exprdef:ExprDef = entries[0].params[0].expr;
        switch (exprdef)
        {
            case EConst(c):
                switch (c)
                {
                    case CString(s):
                        return s;
                    case _:
                        throw new MacroException("Metadata " + name + " is not a string");
                }
            case _:
                throw new MacroException("Metadata " + name + " is not a string");
        }
    }
}

class MacroException extends Exception {}
