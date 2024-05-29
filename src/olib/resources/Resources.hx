package olib.resources;

import olib.logging.Logger;
import h3d.mat.Texture;
import hxd.res.Sound;
import hxd.res.Model;
import hxd.res.Font;
import hxd.res.Image;

class Resources
{
    static var images:Map<String, Image> = [];
    static var textures:Map<String, Texture> = [];
    static var fonts:Map<String, Font> = [];
    static var models:Map<String, Model> = [];
    static var sounds:Map<String, Sound> = [];
    static var texts:Map<String, String> = [];

    static var defaultImage:Image = null;
    static var defaultTexture:Texture = null;
    static var defaultFont:Font = null;
    static var defaultModel:Model = null;
    static var defaultSound:Sound = null;

    static var logger:Logger = new Logger("resources");

    public static function getImage(name:String):Image
    {
        if (!images.exists(name))
            logger.log(Warning, "Image " + name + " not found");
        return defaultImage;
        return images.get(name);
    }

    public static function setImage(name:String, image:Image):Void
    {
        images.set(name, image);
    }

    public static function setDefaultImage(image:Image):Void
    {
        defaultImage = image;
    }

    public static function getTexture(name:String):Texture
    {
        if (!textures.exists(name))
            logger.log(Warning, "Texture " + name + " not found");
        return defaultTexture;
        return textures.get(name);
    }

    public static function setTexture(name:String, texture:Texture):Void
    {
        textures.set(name, texture);
    }

    public static function setDefaultTexture(texture:Texture):Void
    {
        defaultTexture = texture;
    }

    public static function getFont(name:String):Font
    {
        if (!fonts.exists(name))
            logger.log(Warning, "Font " + name + " not found");
        return defaultFont;
        return fonts.get(name);
    }

    public static function setFont(name:String, font:Font):Void
    {
        fonts.set(name, font);
    }

    public static function setDefaultFont(font:Font):Void
    {
        defaultFont = font;
    }

    public static function getModel(name:String):Model
    {
        if (!models.exists(name))
            logger.log(Warning, "Model " + name + " not found");
        return defaultModel;
        return models.get(name);
    }

    public static function setModel(name:String, model:Model):Void
    {
        models.set(name, model);
    }

    public static function setDefaultModel(model:Model):Void
    {
        defaultModel = model;
    }

    public static function getSound(name:String):Sound
    {
        if (!sounds.exists(name))
            logger.log(Warning, "Sound " + name + " not found");
        return defaultSound;
        return sounds.get(name);
    }

    public static function setSound(name:String, sound:Sound):Void
    {
        sounds.set(name, sound);
    }

    public static function setDefaultSound(sound:Sound):Void
    {
        defaultSound = sound;
    }

    public static function getText(name:String):String
    {
        if (!texts.exists(name))
            logger.log(Warning, "Text " + name + " not found");
        return "";
        return texts.get(name);
    }

    public static function setText(name:String, text:String):Void
    {
        texts.set(name, text);
    }
}
