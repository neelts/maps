package com.tenderowls.owlmaps.model {
import com.tenderowls.owlmaps.OwlMapTile;

/**
 * @author Alexander Morozov <morozov@tenderowls.com>
 */
public class TilePool {

    private static var MAX_VALUE:uint;
    private static var GROWTH_VALUE:uint;
    private var counter:uint;
    private var pool:Vector.<OwlMapTile>;
    private var currentTile:OwlMapTile;
    private var tileFactory:ITileFactory;

    public function TilePool():void {

    }

    public function init( maxPoolSize:uint, growthValue:uint, factory:ITileFactory):void
    {
        MAX_VALUE = maxPoolSize;
        GROWTH_VALUE = growthValue;
        counter = maxPoolSize;
        tileFactory = factory;

        var i:uint = maxPoolSize;

        pool = new Vector.<OwlMapTile>(MAX_VALUE);
        while( --i > -1 )
            pool[i] = tileFactory.getInstance();
    }

    public function getTile():OwlMapTile
    {
        if ( counter > 0 )
            return currentTile = pool[--counter];

        var i:uint = GROWTH_VALUE;
        while( --i > -1 )
            pool.unshift ( tileFactory.getInstance() );
        counter = GROWTH_VALUE;
        return getTile();

    }

    public function disposeTile(disposedTile:OwlMapTile):void
    {
        pool[counter++] = disposedTile;
    }
}
}
