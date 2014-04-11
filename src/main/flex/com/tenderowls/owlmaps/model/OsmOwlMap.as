package com.tenderowls.owlmaps.model {

import com.tenderowls.owlmaps.IOwlMap;
import com.tenderowls.owlmaps.OwlMapObject;
import com.tenderowls.owlmaps.OwlMapTile;
import com.tenderowls.owlmaps.model.provider.IProvider;

import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

/**
 * @author Alexander Morozov <morozov@tenderowls.com>
 */
public class OsmOwlMap implements IOwlMap {

    private static const MAX_ZOOM_LEVEL:uint = 18;

    private var viewPort:OwlViewPort;

    private var onUpdateSignal:Signal = new Signal();

    public function OsmOwlMap(provider:IProvider) {
        viewPort = new OwlViewPort(provider);
    }

    public function init(viewportWidth:Number, viewportHeight:Number):void {
        viewPort.init(viewportWidth, viewportHeight);
    }

    public function centerMap(lat:Number, lon:Number, scale:uint):void {
        viewPort.setCenter(lat, lon, scale);
        onUpdateSignal.dispatch();
    }

    public function offset(x:Number, y:Number):void {
        viewPort.offset(x, y);
        onUpdateSignal.dispatch();
    }

    public function addObject(id:String, lat:Number, lon:Number):void {
        viewPort.addObject(id, lat, lon);
        onUpdateSignal.dispatch();
    }

    public function removeObject(id:String):void {
        viewPort.removeObject(id);
        onUpdateSignal.dispatch();
    }

    public function get tiles():Vector.<OwlMapTile> {
        return viewPort.getTiles();
    }

    public function get objects():Vector.<OwlMapObject> {
        return viewPort.getObjects();
    }

    public function get onUpdate():ISignal {
        return onUpdateSignal;
    }

    public function set zoom(zoom:uint):void {
        viewPort.zoom = zoom;
        onUpdateSignal.dispatch();
    }

    public function get zoom():uint {
        return viewPort.zoom;
    }

    public function get maxZoom():uint {
        return MAX_ZOOM_LEVEL;
    }

    public function update():void {
        onUpdateSignal.dispatch();
    }

    public function addMapObject(object:OwlMapObject):void {
        viewPort.addMapObject(object);
        onUpdateSignal.dispatch();
    }

    public function getCenterLat():Number {
        return viewPort.centerLat;
    }

    public function getCenterLon():Number {
        return viewPort.centerLon;
    }

    public function removeAllObjects():void {
        viewPort.removeAllObjects();
        onUpdateSignal.dispatch();
    }

    public function lonToScreenX(lon:Number):int {
        return viewPort.lonToScreenX(lon);
    }

    public function latToScreenY(lat:Number):int {
        return viewPort.latToScreenY(lat);
    }

    public function get width():int {
        return viewPort.width;
    }

    public function get height():int {
        return viewPort.height;
    }

    public function getBottomLeft():Location {
        return viewPort.getBottomLeft();
    }

    public function getTopRight():Location {
        return viewPort.getTopRight();
    }

}
}
