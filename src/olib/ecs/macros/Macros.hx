package olib.ecs.macros;

import olib.ecs.macros.MacroUtil;
import haxe.macro.Expr;
import haxe.macro.Expr.FunctionArg;
import haxe.macro.Expr.Field;
import haxe.macro.Context;

using haxe.macro.ComplexTypeTools;
using haxe.macro.TypeTools;
using StringTools;

class Macros
{
    macro public static function addPublicFieldInitializersAndSuperAndEntityField():Array<Field>
    {
        // Initial fields get
        var fields = Context.getBuildFields();
        var type = Context.toComplexType(Context.getLocalType());

        var constructor:Field = null;
        try
        {
            constructor = MacroUtil.getFieldByName(fields, "new");
            fields.remove(constructor);
        }
        catch (e:MacroException) {}

        var initializableFields:Array<Field> = MacroUtil.filterFieldsByAccess(fields, [APublic], [AStatic, AFinal, APrivate, AOverride]);
        var constructor_exprs:Array<Expr> = [];
        var constructor_args:Array<FunctionArg> = [];

        initializableFields.sort(function(a, b):Int
        {
            var aa = a.name.toLowerCase();
            var bb = b.name.toLowerCase();
            if (aa < bb)
                return -1;
            if (aa > bb)
                return 1;
            return 0;
        });

        for (field in initializableFields)
        {
            var fname:String = field.name;
            switch (field.kind)
            {
                case FVar(t, e):
                    constructor_exprs.push(macro
                        {
                            if ($i{fname} != null)
                                this.$fname = cast $i{fname};
                        });
                    constructor_args.push({
                        name: field.name,
                        type: t,
                        opt: true,
                    });
                case _:
            }
        }

        constructor_args.insert(0, {name: "ecs", type: macro :olib.ecs.ECS, opt: false});
        constructor_args.insert(0, {name: "entity", type: macro :olib.ecs.Entity, opt: false});
        constructor_exprs.push(macro
            {
                // TODO: set into ecs instance instead
                // all.add(entity, this);
                super(entity, ecs);
            });

        if (constructor == null)
        {
            constructor = {
                name: 'new',
                access: [APublic],
                pos: Context.currentPos(),
                kind: FFun({
                    args: constructor_args,
                    expr: macro $b{constructor_exprs},
                    ret: macro :Void
                })
            };
        }
        else
        {
            for (arg in constructor_args)
                MacroUtil.addArgumentToFunction(constructor, arg);
            for (expr in constructor_exprs)
                MacroUtil.addExpressionToFunction(constructor, expr);
        }

        // add fields to array
        fields.push(constructor);

        // return fields
        return fields;
    }

    // macro public static function addPublicFieldInitializers():Array<Field>
    // {
    //     // Initial fields get
    //     var fields = Context.getBuildFields();
    //     var type = Context.toComplexType(Context.getLocalType());
    //     var constructor:Field = null;
    //     try
    //     {
    //         constructor = MacroUtil.getFieldByName(fields, "new");
    //         fields.remove(constructor);
    //     }
    //     catch (e:MacroException) {}
    //     var initializableFields:Array<Field> = MacroUtil.filterFieldsByAccess(fields, [APublic], [AStatic, AFinal, APrivate, AOverride]);
    //     var constructor_exprs:Array<Expr> = [];
    //     var constructor_args:Array<FunctionArg> = [];
    //     initializableFields.sort(function(a, b):Int
    //     {
    //         var aa = a.name.toLowerCase();
    //         var bb = b.name.toLowerCase();
    //         if (aa < bb)
    //             return -1;
    //         if (aa > bb)
    //             return 1;
    //         return 0;
    //     });
    //     for (field in initializableFields)
    //     {
    //         var fname:String = field.name;
    //         switch (field.kind)
    //         {
    //             case FVar(t, e):
    //                 constructor_exprs.push(macro
    //                     {
    //                         if ($i{fname} != null)
    //                             this.$fname = cast $i{fname};
    //                     });
    //                 constructor_args.push({
    //                     name: field.name,
    //                     type: t,
    //                     opt: true,
    //                 });
    //             case _:
    //         }
    //     }
    //     if (constructor == null)
    //     {
    //         constructor = {
    //             name: 'new',
    //             access: [APublic],
    //             pos: Context.currentPos(),
    //             kind: FFun({
    //                 args: constructor_args,
    //                 expr: macro $b{constructor_exprs},
    //                 ret: macro :Void
    //             })
    //         };
    //     }
    //     else
    //     {
    //         for (arg in constructor_args)
    //             MacroUtil.addArgumentToFunction(constructor, arg);
    //         for (expr in constructor_exprs)
    //             MacroUtil.addExpressionToFunction(constructor, expr);
    //     }
    //     // add fields to array
    //     fields.push(constructor);
    //     // return fields
    //     return fields;
    // }

    macro public static function addSparseSet():Array<Field>
    {
        var fields = Context.getBuildFields();
        var type = Context.toComplexType(Context.getLocalType());

        var all:Field = {
            name: "all",
            access: [APublic, AStatic],
            pos: Context.currentPos(),
            kind: FVar(macro :olib.utils.SparseSet<$type>, macro new olib.utils.SparseSet<$type>())
        };
        fields.push(all);

        return fields;
    }

    macro public static function addTypeFields():Array<Field>
    {
        // Initial fields get
        var fields = Context.getBuildFields();
        var type = Context.toComplexType(Context.getLocalType());

        var typeName:String = MacroUtil.getTypeName(type);
        var typeStaticField:Field = {
            name: 'Type',
            access: [APublic, AStatic, AFinal],
            pos: Context.currentPos(),
            kind: FVar(macro :String, macro $v{typeName})
        };

        // create field
        var typeField:Field = {
            name: 'type',
            access: [APublic],
            pos: Context.currentPos(),
            kind: FProp("default", "null", macro :String, macro $v{typeName})
        };

        // add fields to array
        fields.push(typeStaticField);
        fields.push(typeField);

        // return fields
        return fields;
    }

    macro public static function addGetTypeField():Array<Field>
    {
        // Initial fields get
        var fields = Context.getBuildFields();
        var type = Context.toComplexType(Context.getLocalType());

        var getTypeField:Field = {
            name: 'getType',
            access: [APublic, AOverride],
            pos: Context.currentPos(),
            kind: FFun({
                args: [],
                expr: macro
                {
                    return this.type;
                },
                ret: macro :String
            })
        };
        // add fields to array
        fields.push(getTypeField);
        // return fields
        return fields;
    }

    macro public static function addGetClassField():Array<Field>
    {
        // Initial fields get
        var fields = Context.getBuildFields();
        var type = Context.toComplexType(Context.getLocalType());

        var typeName:String = MacroUtil.getTypeName(type);
        var getClassField:Field = {
            name: 'getClass',
            access: [APublic, AOverride],
            pos: Context.currentPos(),
            kind: FFun({
                args: [],
                expr: macro
                {
                    return $i{typeName};
                },
                ret: macro :Class<olib.ecs.Component>
            })
        };
        // add fields to array
        fields.push(getClassField);
        // return fields
        return fields;
    }

    macro public static function addGetAllField():Array<Field>
    {
        // Initial fields get
        var fields = Context.getBuildFields();
        var type = Context.toComplexType(Context.getLocalType());

        var getAllField:Field = {
            name: 'getAll',
            access: [AOverride],
            pos: Context.currentPos(),
            kind: FFun({
                args: [],
                expr: macro
                {
                    return cast all;
                },
                ret: macro :olib.utils.SparseSet<olib.ecs.Component>
            })
        };
        // add fields to array
        fields.push(getAllField);
        // return fields
        return fields;
    }

    macro public static function addClassField():Array<Field>
    {
        // Initial fields get
        var fields = Context.getBuildFields();
        var type = Context.toComplexType(Context.getLocalType());

        var typeName:String = MacroUtil.getTypeName(type);
        var classField:Field = {
            name: 'Class',
            access: [APublic, AStatic, AFinal],
            pos: Context.currentPos(),
            kind: FVar(macro :Class<olib.ecs.Component>, macro $i{typeName})
        };

        // add fields to array
        fields.push(classField);
        // return fields
        return fields;
    }
}
