package com.tenderowls.owlmaps.layers {
import flash.utils.Dictionary;

/**
 * @author Alexander Morozov <morozov@tenderowls.com>
 */
public class OwlMarkerLayer extends OwlLayer{

    private var markers:Dictionary = new Dictionary();

    public function OwlMarkerLayer() {
    }

    public function addMarker(marker:OwlMarker):void {
        markers[marker.id] = marker;
    }

    public function removeAllMarkers():void {
        markers = new Dictionary();
    }

}
}
