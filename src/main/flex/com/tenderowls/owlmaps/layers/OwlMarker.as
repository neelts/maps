package com.tenderowls.owlmaps.layers {
import com.tenderowls.owlmaps.OwlMapObject;


import starling.display.Image;

/**
 * @author Alexander Morozov <morozov@tenderowls.com>
 */
public class OwlMarker extends OwlMapObject {

    private var image:Image;

    public function OwlMarker(id:String, lat:Number, lon:Number, icon:Image, pivotX:int = 0, pivotY:int = 0) {
        this.image = icon;
        this.pivotX = pivotX;
        this.pivotY = pivotY;
        this.lat = lat;
        this.lon = lon;
        this._width = image.width;
        this._height = image.height;
        super(id, 0, 0, lat, lon);
    }

    override public function getImage():Image {
        return image;
    }

    override public function get width():int {
        return image.width;
    }

    override public function get height():int {
        return image.height;
    }
}
}
