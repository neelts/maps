package com.tenderowls.owlmaps.layers {
import com.tenderowls.owlmaps.OwlMapObject;

/**
 * @author Alexander Morozov <morozov@tenderowls.com>
 */
public class OwlLayer {

    public var visible:Boolean = true;

    public function OwlLayer() {
    }

    public function hide():void {
        visible = false;
    }

    public function show():void {
        visible = true;
    }

    public function getObjects():Vector.<OwlMapObject> {
        return null;
    }
}
}
