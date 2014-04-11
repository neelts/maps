package com.tenderowls.owlmaps {

import com.tenderowls.owlmaps.model.Location;

import org.osflash.signals.ISignal;

/**
 * @author Aleksey Fomkin (aleksey.fomkin@gmail.com)
 */
public interface IOwlMap {

    function init(viewportWidth:Number, viewportHeight:Number):void;

    function centerMap(lat:Number, lon:Number, scale:uint):void;

    function getCenterLat():Number;

    function getCenterLon():Number;

    function getBottomLeft():Location;

    function getTopRight():Location;

    function offset(x:Number, y:Number):void;

    function addObject(id:String, lat:Number, lon:Number):void;

    function addMapObject(object:OwlMapObject):void;

    function removeObject(id:String):void;

    function removeAllObjects():void;

    function set zoom(scale:uint):void;

    function get zoom():uint;

    /**
     * Value range of `scale`
     * @see zoom()
     * @see centerMap()
     */
    function get maxZoom():uint;

    /**
     * Performance note: implementation may use object pool
     * for OwlTile instancies.
     */
    function get tiles():Vector.<OwlMapTile>;

    /**
     * Performance note: implementation may use object pool
     * for IOwlMapObject instancies.
     */
    function get objects():Vector.<OwlMapObject>;

    function get onUpdate():ISignal;

    function update():void;

    function lonToScreenX(lat:Number):int;

    function latToScreenY(lon:Number):int;

    function get width():int;

    function get height():int;
}

}