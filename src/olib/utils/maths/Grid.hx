package olib.utils.maths;

import haxe.Exception;

class Grid<Object>
{
    private var mData:Array<Object>;

    /**
     * The 2D grid's width
    **/
    public var width(default, null):Int = 0;

    /**
     * The 2D grid's height
    **/
    public var height(default, null):Int = 0;

    private var mMax:Int = 0;

    /**
     * Create a new grid with a fixed width and height
     * @param	aWidth
     * @param	aHeight
     * @throws GridError if out of bounds
    **/
    public function new(aWidth:Int, aHeight:Int):Void
    {
        if (aWidth < 1 || aHeight < 1)
        {
            throw new GridError('Grid width ($aWidth) and height ($aHeight) should be positive values');
        }

        width = aWidth;
        height = aHeight;
        mMax = width * height;

        mData = new Array();
    }

    /**
     * Fill the grid with a single value
     * @param aData
    **/
    public function fill(aData:Object):Void
    {
        for (i in 0...width * height)
        {
            mData[i] = aData;
        }
    }

    /**
     * Returns the value at the specified position
     * If aY is not set, then aX_or_id is considered a 1D id.
     * (ex: the value 3 would be the fourth item, and the value at position (3, 0) on a grid of 10,10)
     * @param	aX_or_id Either a 1D position or the X value of a coordinate
     * @param	aY If a value, will act as the Y position of a coordinate
     * @return the value present at the specified position
     * @throws GridError if out of bounds
    **/
    public inline function get(aX_or_id:Int, ?aY:Null<Int>):Object
    {
        if (aY == null)
        {
            if (aX_or_id < 0 || aX_or_id > mMax)
                throw new GridError('Grid value must be between 0 and $mMax (got $aX_or_id)');

            return mData[aX_or_id];
        }
        else
        {
            return mData[_pos_to_id(aX_or_id, aY)];
        }
    }

    public inline function getOrNull(aX_or_id:Int, ?aY:Null<Int>):Object
    {
        if (aY == null)
        {
            if (aX_or_id < 0 || aX_or_id > mMax)
                return null;

            return mData[aX_or_id];
        }
        else
        {
            var i = _pos_to_idOrNull(aX_or_id, aY);
            if (i == null)
            {
                return null;
            }
            else
            {
                return mData[i];
            }
        }
    }

    /**
     * Returns the value at the specified position
     * If aY is not set, then aX_or_id is considered a 1D id.
     * (ex: the value 3 would be the fourth item, and the value at position (3, 0) on a grid of 10,10)
     * @param	aObj The object to set at the specified position
     * @param	aX_or_id Either a 1D position or the X value of a coordinate
     * @param	aY If a value, will act as the Y position of a coordinate
     * @return The value present before the new one
     * @throws GridError if out of bounds
    **/
    public inline function set(aObj:Object, aX_or_id:Int, ?aY:Null<Int>):Object
    {
        var old:Object = null;
        if (aY == null)
        {
            if (aX_or_id < 0 || aX_or_id > mMax)
                throw new GridError('Grid value must be between 0 and $mMax (got $aX_or_id)');

            old = mData[aX_or_id];
            mData[aX_or_id] = aObj;
            return old;
        }
        else
        {
            var i:Int = _pos_to_id(aX_or_id, aY);
            old = mData[i];
            mData[i] = aObj;
            return old;
        }
    }

    /**
     * Returns the X value of a coordinate based on a 1D position
     * @param	aId the 1D array position
     * @return the X part of the coordinate represented by the 1D position
     * @throws GridError if out of bounds
    **/
    public inline function _posx(aId:Int):Int
    {
        if (aId < 0 || aId > mMax)
            throw new GridError('Grid value must be between 0 and $mMax (got $aId)');

        return aId % width;
    }

    /**
     * Returns the y value of a coordinate based on a 1D position
     * @param	aId the 1D array position
     * @return the Y part of the coordinate represented by the 1D position
     * @throws GridError if out of bounds
    **/
    public inline function _posy(aId:Int):Int
    {
        if (aId < 0 || aId > mMax)
            throw new GridError('Grid value must be between 0 and $mMax (got $aId)');

        return Std.int(aId / width);
    }

    /**
     * Converts a X,Y coordinate into a 1D array position
     * @param	aX
     * @param	aY
     * @return a 1D array position
     * @throws GridError if out of bounds
    **/
    public inline function _pos_to_id(aX:Int, aY:Int):Int
    {
        if (aX < 0 || aY < 0 || aX >= width || aY >= height)
            throw new GridError('Grid (x:$aX, y:$aY) should be within width(0, $width) and height(0, $height)');

        return aY * width + aX;
    }

    public inline function _pos_to_idOrNull(aX:Int, aY:Int):Null<Int>
    {
        if (aX < 0 || aY < 0 || aX >= width || aY >= height)
            return null;

        return aY * width + aX;
    }

    /**
     * Returns a simple, non-representative string representation of this array
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
    public function iterator():Iterator<Object>
    {
        return mData.iterator();
    }

    public function toArray():Array<Object>
    {
        return mData.copy();
    }

    /**
     * Sets this grid's data as a new array of defined elements
     * @param	aArr an array of Object, of correct size
     * @throws GridError if array is of wrong length
    **/
    public function setData(aArr:Array<Object>, ?force:Bool = false):Void
    {
        if (aArr.length == mMax)
        {
            mData = aArr;
            mMax = mData.length;
        }
        else
        {
            if (!force)
                throw new GridError('Grid setData is of wrong size. Should be an array of $mMax long instead of ${aArr.length}');
            else
            {
                while (aArr.length < mMax)
                {
                    aArr.push(null);
                }
                mData = aArr;
                mMax = mData.length;
            }
        }
    }

    /**
     * Returns a three by three square representing aX aY as the middle value
     * and its neighbors. Values out of bounds are null.
     * @param aX
     * @param aY
     * @return Array<Object>
    **/
    public function getNeighbors(aX:Int, aY:Int):Array<Object>
    {
        var result:Array<Object> = [];

        result.push(getOrNull(aX - 1, aY - 1));
        result.push(getOrNull(aX, aY - 1));
        result.push(getOrNull(aX + 1, aY - 1));
        result.push(getOrNull(aX - 1, aY));
        result.push(getOrNull(aX, aY));
        result.push(getOrNull(aX + 1, aY));
        result.push(getOrNull(aX - 1, aY + 1));
        result.push(getOrNull(aX, aY + 1));
        result.push(getOrNull(aX + 1, aY + 1));

        return result;
    }

    /**
     * Returns a new grid consisting of a rectangular part of this grid.
     * The new grid contains 1D ids to this grid's objects
     * @param	aX
     * @param	aY
     * @param	aWidth
     * @param	aHeight
     * @return
    **/
    public function getSegment(aX:Int, aY:Int, aWidth:Int, aHeight:Int):Grid<Int>
    {
        if (aX < 0 || aX >= width || aY < 0 || aY >= height || aWidth > width || aHeight > height)
            throw new GridError('Grid getSegment is larger than actual grid or out of bounds');

        var g:Grid<Int> = new Grid(aWidth, aHeight);
        var a:Array<Int> = [];

        for (k in aY...(aY + aHeight))
        {
            for (j in aX...(aX + aWidth))
            {
                a.push(_pos_to_id(j, k));
            }
        }

        g.setData(a);
        return g;
    }
}

class GridError extends Exception {}
