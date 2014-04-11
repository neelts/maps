package com.tenderowls.owlmaps.model {
import com.tenderowls.owlmaps.OwlMapTile;

/**
 * @author Alexander Morozov <morozov@tenderowls.com>
 */
public interface ITileFactory {
    function getInstance():OwlMapTile;
}
}
