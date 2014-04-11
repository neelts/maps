package com.tenderowls.owlmaps {
import starling.display.Image;

/**
 * @author Aleksey Fomkin (aleksey.fomkin@gmail.com)
 */
public class OwlMapObject {
    public var id:String;
    public var viewportX:Number;
    public var viewportY:Number;

    public var globalX:uint;
    public var globalY:uint;

    public var lat:Number;
    public var lon:Number

    public var pivotX:int;
    public var pivotY:int;

    protected var _width:int;
    protected var _height:int;

    public var visible:Boolean = true;

    public var canScale:Boolean = false;

    public function OwlMapObject(id:String, viewportX:Number, viewportY:Number, lat:Number = 0, lon:Number = 0) {
        this.id = id;
        this.viewportX = viewportX;
        this.viewportY = viewportY;
        this.lat = lat;
        this.lon = lon;
    }

    public function getImage():Image {
        return null;
    }

    public function get width():int {
        return 1;
    }

    public function get height():int {
        return 1;
    }
}

}
