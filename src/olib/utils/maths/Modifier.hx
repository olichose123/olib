package olib.utils.maths;

import olib.models.Model;

class Modifier extends Model
{
    public var description:String;
    public var value:Float;
    public var kind:ModifierKind;
}

enum ModifierKind
{
    FlatBonus; // flat bonus to the base value
    PercentageBonus; // bercentage bonus (+10%) of the base value
    Multiplier; // multiplier (*2) of the total value
}
