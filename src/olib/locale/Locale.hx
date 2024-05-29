package olib.locale;

import olib.logging.Logger;
import olib.models.Model;

class Locale extends Model
{
    public static var reportMissingKeys:Bool = #if debug true #else false #end;
    public static var logger:Logger = new Logger("locale", Warning);
    public static var current:Locale;

    public static function get(key:String):String
    {
        if (current == null)
        {
            logger.log(Error, 'Current locale is null. Creating default locale "en"');
            current = new Locale('en', null);
        }
        return current.fromKey(key);
    }

    var data(default, null):Map<String, String>;

    public function new(data:Map<String, String>)
    {
        this.data = data;
    }

    public function fromKey(key:String):String
    {
        if (data == null)
        {
            logger.log(Error, 'Locale data is null');
            this.data = new Map<String, String>();
        }

        if (!data.exists(key))
        {
            data.set(key, key);
            if (reportMissingKeys)
            {
                logger.log(Warning, 'Missing key: $key');
            }
            return key;
        }
        return data.get(key);
    }
}
