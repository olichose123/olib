package olib.utils;

/**
 * SparseSet is a data structure that allows for fast lookups and removals of elements.
 * It is implemented as a sparse array, where the dense array contains the elements and the sparse array contains the indices of the elements in the dense array.
 * This allows for O(1) lookups and removals.
**/
class SparseSet<T>
{
    public var items(default, null):Array<T>;
    public var dense(default, null):Array<Null<Int>>;
    public var sparse(default, null):Array<Null<Int>>;
    public var size(default, null):Int = 0;

    public function new()
    {
        items = [];
        dense = [];
        sparse = [];
    }

    public function exists(index:Int):Bool
    {
        return index >= 0 && sparse[index] != null && sparse[index] < size && dense[sparse[index]] == index && items[sparse[index]] != null;
    }

    public function getIndex(index:Int):Null<Int>
    {
        return sparse[index];
    }

    public function get(index:Int):T
    {
        return items[sparse[index]];
    }

    public function add(index:Int, item:T):Int
    {
        if (exists(index))
            return sparse[index];

        dense[size] = index;
        sparse[index] = size;
        items[size] = item;
        size++;
        return size - 1;
    }

    public function remove(index:Int):Void
    {
        if (!exists(index))
            return;

        items[sparse[index]] = items[size - 1];
        dense[sparse[index]] = dense[size - 1];
        sparse[dense[size - 1]] = sparse[index];
        sparse[index] = null;
        size--;
    }

    public function clear():Void
    {
        size = 0;
        items.resize(0);
        dense.resize(0);
        sparse.resize(0);
    }

    @:noCompletion
    public function clean():Void
    {
        items.resize(size);
        dense.resize(size);
        var i = sparse.length - 1;
        while (i >= 0)
        {
            if (sparse[i] == null)
            {
                sparse.resize(i--);
            }
            else
            {
                break;
            }
        }
    }

    public function toString():String
    {
        return 'SparseSet len:${size}, dense:${dense.length}, items:${items.length}, sparse:${sparse.length}';
    }

    public function iterator():Iterator<T>
    {
        return new SparseSetIterator(items, size);
    }

    public function keyValueIterator():KeyValueIterator<Int, T>
    {
        return new SparseSetKVIterator(items, dense, size);
    }
}

private class SparseSetIterator<T>
{
    var index:Int = 0;
    var arr:Array<T>;
    var size:Int;

    public function new(arr:Array<T>, size:Int)
    {
        this.arr = arr;
        this.size = size;
    }

    public function hasNext():Bool
    {
        return index < size;
    }

    public function next():T
    {
        return arr[index++];
    }
}

private class SparseSetKVIterator<K, V>
{
    var index:Int = 0;
    var items:Array<V>;
    var dense:Array<K>;
    var size:Int;

    public function new(items:Array<V>, dense:Array<K>, size:Int)
    {
        this.items = items;
        this.dense = dense;
        this.size = size;
    }

    public function hasNext():Bool
    {
        return index < size;
    }

    public function next():{key:K, value:V}
    {
        return {key: dense[index], value: items[index++]};
    }
}

/**
 * Pure implementation of a sparse set.
**/
class IntSparseSet
{
    public var dense(default, null):Array<Null<Int>>;
    public var sparse(default, null):Array<Null<Int>>;
    public var size(default, null):Int = 0;

    public function new()
    {
        dense = [];
        sparse = [];
    }

    public function exists(element:Int):Bool
    {
        return element >= 0 && sparse[element] != null && sparse[element] < size && dense[sparse[element]] == element;
    }

    public function getIndex(element:Int):Null<Int>
    {
        return sparse[element];
    }

    public function add(element:Int):Int
    {
        if (exists(element))
            return sparse[element];

        dense[size] = element;
        sparse[element] = size;
        size++;
        return size - 1;
    }

    public function remove(element:Int):Void
    {
        if (!exists(element))
            return;

        dense[sparse[element]] = dense[size - 1];
        sparse[dense[size - 1]] = sparse[element];
        sparse[element] = null;
        size--;
    }

    public function clear():Void
    {
        size = 0;
        dense.resize(0);
        sparse.resize(0);
    }

    @:noCompletion
    public function clean():Void
    {
        dense.resize(size);
        var i = sparse.length - 1;
        while (i >= 0)
        {
            if (sparse[i] == null)
            {
                sparse.resize(i--);
            }
            else
            {
                break;
            }
        }
    }

    public function iterator():Iterator<Int>
    {
        return new IntSparseSetIterator(dense, size);
    }

    public function toString()
    {
        return 'SparseSet len:${size}, dense:${dense.length}, sparse:${sparse.length}';
    }
}

private class IntSparseSetIterator
{
    var index:Int = 0;
    var arr:Array<Int>;
    var size:Int;

    public function new(arr:Array<Int>, size:Int)
    {
        this.arr = arr;
        this.size = size;
    }

    public function hasNext():Bool
    {
        return index < size;
    }

    public function next():Int
    {
        return arr[index++];
    }
}
