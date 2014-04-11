package com.tenderowls.owlmaps.model {
import com.tenderowls.owlmaps.OwlMapTile;

/**
 * @author Alexander Morozov <morozov@tenderowls.com>
 */
public class OwlTileFactory implements ITileFactory{
    public function OwlTileFactory() {
    }

    public function getInstance():OwlMapTile {
        return new OwlMapTile(null, null, 0, 0);
    }
}
}
