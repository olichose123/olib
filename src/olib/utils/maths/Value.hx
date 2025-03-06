package olib.utils.maths;

import olib.utils.maths.Modifier;
import olib.utils.maths.Modifier.ModifierKind;

class Value
{
    public var base(default, set):Float;
    public var modifiers(default, null):Array<Modifier> = [];
    public var total(default, null):Float;

    public var onTotalChanged(default, null):Array<() -> Value>;

    public function new(base:Float = 0.0)
    {
        this.base = base;
        calculate();
    }

    function set_base(value:Float):Float
    {
        base = value;
        calculate();
        return base;
    }

    public function addModifier(modifier:Modifier):Void
    {
        modifiers.push(modifier);
        calculate();
    }

    public function removeModifier(modifier:Modifier):Void
    {
        modifiers.remove(modifier);
        calculate();
    }

    function calculate():Void
    {
        var total_multipliable:Float = 1.0;
        var total_bonuses:Float = 0.0;

        for (modifier in modifiers)
        {
            switch (modifier.kind)
            {
                case ModifierKind.FlatBonus:
                    total_bonuses += modifier.value;
                case ModifierKind.PercentageBonus:
                    total_bonuses += base * modifier.value;
                case ModifierKind.Multiplier:
                    total_multipliable *= modifier.value;
            }
        }
        trace("---");
        trace("base: " + base);
        trace("total_bonuses: " + total_bonuses);
        trace("total_multipliable: " + total_multipliable);
        this.total = (base + total_bonuses) * total_multipliable;
        if (onTotalChanged != null)
        {
            for (callback in onTotalChanged)
            {
                callback();
            }
        }
    }
}
