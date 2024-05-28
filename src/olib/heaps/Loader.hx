package olib.heaps;

import hxd.fs.FileEntry;
import haxe.io.Bytes;
#if sys
import sys.io.File;
#end
import hxd.fs.LocalFileSystem;

class Loader extends hxd.res.Loader
{
    public var root(default, null):String;

    public function new(path:String, ?config:String):Void
    {
        root = path;
        var fs = new LocalFileSystem(path, config);
        super(fs);
    }

    /**
     * Save a file to disk
     * @param data
     * @param path
    **/
    public function save(data:Bytes, path:String):Void
    {
        #if sys
        File.saveBytes(haxe.io.Path.join([root, path]), data);
        #else
        throw new haxe.exceptions.NotImplementedException();
        #end
    }

    public function scan(path:String, pattern:EReg, depth:Int = 0, ?minDepth:Int = -1):Array<FileEntry>
    {
        // if depth is equal to minDepth, go deeper, otherwise, scan
        var entries = this.fs.dir(path);
        var result = [];

        if (depth > minDepth)
        {
            for (entry in entries)
            {
                if (!entry.isDirectory)
                {
                    if (pattern.match(entry.name))
                    {
                        result.push(entry);
                    }
                }
                else if (depth > 0)
                {
                    result = result.concat(scan(entry.path, pattern, depth - 1));
                }
            }
        }
        else
        {
            for (entry in entries)
            {
                if (entry.isDirectory)
                {
                    result = result.concat(scan(entry.path, pattern, depth - 1));
                }
            }
        }
        return result;
    }
}
