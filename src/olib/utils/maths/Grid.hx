package olib.utils.maths;

import haxe.Exception;

class Grid<T>
{
    private var data:Array<T>;

    /**
     * The 2D grid's width
    **/
    public var width(default, null):Int = 0;

    /**
     * The 2D grid's height
    **/
    public var height(default, null):Int = 0;

    private var maxItemCount:Int = 0;

    /**
     * Create a new grid with a fixed width and height
     * @param	width
     * @param	height
     * @throws GridError if out of bounds
    **/
    public function new(width:Int, height:Int):Void
    {
        if (width < 1 || height < 1)
        {
            throw new GridError('Grid width ($width) and height ($height) should be positive values');
        }

        this.width = width;
        this.height = height;
        maxItemCount = width * height;

        data = new Array();
    }

    /**
     * Fill the grid with a single value
     * @param data
    **/
    public function fill(data:T):Void
    {
        for (i in 0...width * height)
        {
            this.data[i] = data;
        }
    }

    /**
     * Returns the value at the specified position
     * If y is not set, then x_or_id is considered a 1D id.
     * (ex: the value 3 would be the fourth item, and the value at position (3, 0) on a grid of 10,10)
     * @param	x_or_id Either a 1D position or the X value of a coordinate
     * @param	y If a value, will act as the Y position of a coordinate
     * @return the value present at the specified position
     * @throws GridError if out of bounds
    **/
    public inline function get(x_or_id:Int, ?y:Null<Int>):T
    {
        if (y == null)
        {
            if (x_or_id < 0 || x_or_id > maxItemCount)
                throw new GridError('Grid value must be between 0 and $maxItemCount (got $x_or_id)');

            return data[x_or_id];
        }
        else
        {
            return data[_pos_to_id(x_or_id, y)];
        }
    }

    public inline function getOrNull(x_or_id:Int, ?y:Null<Int>):T
    {
        if (y == null)
        {
            if (x_or_id < 0 || x_or_id > maxItemCount)
                return null;

            return data[x_or_id];
        }
        else
        {
            var i = _pos_to_idOrNull(x_or_id, y);
            if (i == null)
            {
                return null;
            }
            else
            {
                return data[i];
            }
        }
    }

    /**
     * Returns the value at the specified position
     * If y is not set, then x_or_id is considered a 1D id.
     * (ex: the value 3 would be the fourth item, and the value at position (3, 0) on a grid of 10,10)
     * @param	obj The T to set at the specified position
     * @param	x_or_id Either a 1D position or the X value of a coordinate
     * @param	y If a value, will act as the Y position of a coordinate
     * @return The value present before the new one
     * @throws GridError if out of bounds
    **/
    public inline function set(obj:T, x_or_id:Int, ?y:Null<Int>):T
    {
        var old:T = null;
        if (y == null)
        {
            if (x_or_id < 0 || x_or_id > maxItemCount)
                throw new GridError('Grid value must be between 0 and $maxItemCount (got $x_or_id)');

            old = data[x_or_id];
            data[x_or_id] = obj;
            return old;
        }
        else
        {
            var i:Int = _pos_to_id(x_or_id, y);
            old = data[i];
            data[i] = obj;
            return old;
        }
    }

    /**
     * Returns the X value of a coordinate based on a 1D position
     * @param	id the 1D Array position
     * @return the X part of the coordinate represented by the 1D position
     * @throws GridError if out of bounds
    **/
    public inline function _posx(id:Int):Int
    {
        if (id < 0 || id > maxItemCount)
            throw new GridError('Grid value must be between 0 and $maxItemCount (got $id)');

        return id % width;
    }

    /**
     * Returns the y value of a coordinate based on a 1D position
     * @param	id the 1D Array position
     * @return the Y part of the coordinate represented by the 1D position
     * @throws GridError if out of bounds
    **/
    public inline function _posy(id:Int):Int
    {
        if (id < 0 || id > maxItemCount)
            throw new GridError('Grid value must be between 0 and $maxItemCount (got $id)');

        return Std.int(id / width);
    }

    /**
     * Converts a X,Y coordinate into a 1D Array position
     * @param	x
     * @param	y
     * @return a 1D Array position
     * @throws GridError if out of bounds
    **/
    public inline function _pos_to_id(x:Int, y:Int):Int
    {
        if (x < 0 || y < 0 || x >= width || y >= height)
            throw new GridError('Grid (x:$x, y:$y) should be within width(0, $width) and height(0, $height)');

        return y * width + x;
    }

    public inline function _pos_to_idOrNull(x:Int, y:Int):Null<Int>
    {
        if (x < 0 || y < 0 || x >= width || y >= height)
            return null;

        return y * width + x;
    }

    /**
     * Returns a simple, non-representative string representation of this Array
     * in the form of [Grid width height]
     * @return
    **/
    public function toString():String
    {
        return '[Grid w:$width h:$height]';
    }

    /**
     * Enables looping through the values, from left to right then from up to down
     * @return
    **/
    public function iterator():Iterator<T>
    {
        return data.iterator();
    }

    public function toArray():Array<T>
    {
        return data.copy();
    }

    /**
     * Sets this grid's data as a new Array of defined elements
     * @param	arr an Array of T, of correct size
     * @throws GridError if Array is of wrong length
    **/
    public function setData(arr:Array<T>, ?force:Bool = false):Void
    {
        if (arr.length == maxItemCount)
        {
            data = arr;
            maxItemCount = data.length;
        }
        else
        {
            if (!force)
                throw new GridError('Grid setData is of wrong size. Should be an Array of $maxItemCount long instead of ${arr.length}');
            else
            {
                while (arr.length < maxItemCount)
                {
                    arr.push(null);
                }
                data = arr;
                maxItemCount = data.length;
            }
        }
    }

    /**
     * Returns a three by three square representing x y as the middle value
     * and its neighbors. Values out of bounds are null.
     * @param x
     * @param y
     * @return Array<T>
    **/
    public function getNeighbors(x:Int, y:Int):Array<T>
    {
        var result:Array<T> = [];

        result.push(getOrNull(x - 1, y - 1));
        result.push(getOrNull(x, y - 1));
        result.push(getOrNull(x + 1, y - 1));
        result.push(getOrNull(x - 1, y));
        result.push(getOrNull(x, y));
        result.push(getOrNull(x + 1, y));
        result.push(getOrNull(x - 1, y + 1));
        result.push(getOrNull(x, y + 1));
        result.push(getOrNull(x + 1, y + 1));

        return result;
    }

    /**
     * Returns a new grid consisting of a rectangular part of this grid.
     * The new grid contains 1D ids to this grid's Ts
     * @param	x
     * @param	y
     * @param	width
     * @param	height
     * @return
    **/
    public function getSegmentIds(x:Int, y:Int, width:Int, height:Int):Grid<Int>
    {
        if (x < 0 || x >= width || y < 0 || y >= height || width > width || height > height)
            throw new GridError('Grid getSegment is larger than actual grid or out of bounds');

        var g:Grid<Int> = new Grid(width, height);
        var a:Array<Int> = [];

        for (k in y...(y + height))
        {
            for (j in x...(x + width))
            {
                a.push(_pos_to_id(j, k));
            }
        }

        g.setData(a);
        return g;
    }

    /**
     * Returns a new grid consisting of a rectangular part of this grid.
     * The new grid contains Ts
     * @param x
     * @param y
     * @param width
     * @param height
     * @return Grid<T>
    **/
    public function getSegment(x:Int, y:Int, width:Int, height:Int):Grid<T>
    {
        if (x < 0 || x >= width || y < 0 || y >= height || width > width || height > height)
            throw new GridError('Grid getSegment is larger than actual grid or out of bounds');

        var g:Grid<T> = new Grid(width, height);
        var a:Array<T> = [];

        for (k in y...(y + height))
        {
            for (j in x...(x + width))
            {
                a.push(get(j, k));
            }
        }

        g.setData(a);
        return g;
    }
}

class GridError extends Exception {}
