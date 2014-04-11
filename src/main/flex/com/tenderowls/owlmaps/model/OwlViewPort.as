package com.tenderowls.owlmaps.model {

import com.tenderowls.owlmaps.OwlMapObject;
import com.tenderowls.owlmaps.OwlMapTile;
import com.tenderowls.owlmaps.model.provider.IProvider;
import com.tenderowls.owlmaps.utils.GeoUtils;

import flash.net.LocalConnection;

import flash.utils.Dictionary;

/**
 * @author Alexander Morozov <morozov@tenderowls.com>
 */
public class OwlViewPort {

    private var objectMap:ObjectHashMap = new ObjectHashMap();

    private var _width:Number;
    private var _height:Number;

    private var _centerX:uint;
    private var _centerY:uint;

    private var _screenX:uint;
    private var _screenY:uint;

    private var _centerLat:Number;
    private var _centerLon:Number;
    private var _zoom:Number;

    private var provider:IProvider;

    public function OwlViewPort(provider:IProvider):void {
        this.provider = provider;
    }

    public function init(viewportWidth:Number, viewportHeight:Number):void {
        _width = viewportWidth;
        _height = viewportHeight;

        //update pixel coordinates by lat lon
        centerLat = _centerLat;
        centerLon = _centerLon;
    }

    public function setCenter(lat:Number, lon:Number, scale:uint):void {
        _zoom = scale;
        centerLat = lat;
        centerLon = lon;
    }

    public function get zoom():Number {
        return _zoom;
    }

    public function set zoom(value:Number):void {
        _zoom = value;
    }

    public function offset(x:int, y:int):void {
        centerX -= x;
        centerY -= y;
    }

    //-------------------------------------------------------------------------
    //  Coordinate transformations
    //-------------------------------------------------------------------------

    private function globalPixelX(x:uint):uint {
        return x << (provider.getMaxScale() - _zoom);
    }

    private function globalPixelY(y:uint):uint {
        return y << (provider.getMaxScale() - _zoom);
    }

    //return x on current zoom
    private function zoomedX(x:uint):uint {
        return x >> (provider.getMaxScale() - _zoom);
    }

    //return y on current zoom
    private function zoomedY(y:uint):uint {
        return y >> (provider.getMaxScale() - _zoom);
    }


    public function latToScreenY(lat:Number):int {
        return GeoUtils.pixelY(lat, zoom) - _screenY;
    }

    public function lonToScreenX(lon:Number):int {
        return GeoUtils.pixelX(lon, zoom) - _screenX;
    }

    //-------------------------------------------------------------------------
    //  Tiles
    //-------------------------------------------------------------------------

    /**
     * Sorting method for partitions.
     */
    private function sortByDistanceFromCenter(tile1:OwlMapTile, tile2:OwlMapTile):Number {
        var x1:Number = tile1.viewportX + tile1.expectedWidth * .5 - this._width / 2;
        var y1:Number = tile1.viewportY + tile1.expectedHeight * .5 - this._height / 2;
        var x2:Number = tile2.viewportX + tile1.expectedWidth * .5 - this._width / 2;
        var y2:Number = tile2.viewportY + tile2.expectedHeight * .5 - this._height / 2;
        return (x1 * x1 + y1 * y1) - (x2 * x2 + y2 * y2);
    }

    public function getTiles():Vector.<OwlMapTile> {

        var result:Vector.<OwlMapTile> = new Vector.<OwlMapTile>();

        var tilesH:int = Math.ceil(this._width / provider.getTileWidth()) + 1;
        var tilesV:int = Math.ceil(this._height / provider.getTileHeight()) + 1;

        var tileX:int = GeoUtils.pixelToTile(_screenX);
        var tileY:int = GeoUtils.pixelToTile(_screenY);

        var stX:int = tileX * provider.getTileWidth() - _screenX;
        var stY:int = tileY * provider.getTileHeight() - _screenY;

        var x:int = 0;
        var y:int = 0;

        for (var i:int = 0; i <= tilesH; i++) {
            for (var j:int = 0; j <= tilesV; j++) {
                var id:String = String(i + tileX) + " " + String(j + tileY);
                x = stX + i * provider.getTileWidth();
                y = stY + j * provider.getTileHeight();
                if (x < this._width && y < this._height) {
                    var tile:OwlMapTile = new OwlMapTile(id, provider.getUrl(i + tileX, j + tileY, zoom), x, y, 256, 256);
                    result.push(tile);
                }
            }
        }

        result.sort(sortByDistanceFromCenter);

        return result;
    }

    //-------------------------------------------------------------------------
    //  Objects
    //-------------------------------------------------------------------------

    public function addMapObject(object:OwlMapObject):void {
        var globalX:int = globalPixelX(GeoUtils.pixelX(object.lon, zoom));
        var globalY:int = globalPixelY(GeoUtils.pixelY(object.lat, zoom));

        object.globalX = globalX;
        object.globalY = globalY;
        objectMap.put(object);
    }

    public function addObject(id:String, lat:Number, lon:Number):void {
        var globalX:int = globalPixelX(GeoUtils.pixelX(lon, zoom));
        var globalY:int = globalPixelY(GeoUtils.pixelY(lat, zoom));

        var object:OwlMapObject = new OwlMapObject(id, GeoUtils.pixelX(lon, zoom), GeoUtils.pixelY(lat, zoom));
        object.globalX = globalX;
        object.globalY = globalY;
        objectMap.put(object);
    }

    public function removeObject(id:String):void {
        objectMap.remove(id);
    }

    public function removeAllObjects():void {
        objectMap.clear();
    }

    public function getObjects():Vector.<OwlMapObject> {
        var leftX:uint = globalPixelX(_screenX);
        var topY:uint = globalPixelY(_screenY);

        var rightX:uint = globalPixelX(_screenX + _width);
        var bottomY:uint = globalPixelY(_screenY + _height);

        var result:Vector.<OwlMapObject> = new Vector.<OwlMapObject>();

        var dict:Dictionary = objectMap.getObjects();
        for each (var object:OwlMapObject in dict) {
            if (object.globalX >= (leftX - object.width) &&
                    object.globalY <= rightX &&
                    object.globalY >= (topY - object.height) &&
                    object.globalY <= bottomY) {
                object.viewportX = zoomedX(object.globalX) - _screenX - object.pivotX;
                object.viewportY = zoomedY(object.globalY) - _screenY - object.pivotY;
                result.push(object);
            }
        }
        return result;
    }

    //-------------------------------------------------------------------------
    //  Getters and setters
    //-------------------------------------------------------------------------

    public function set centerLon(value:Number):void {
        _centerLon = value;
        centerX = GeoUtils.pixelX(value, zoom);
    }

    public function set centerLat(value:Number):void {
        _centerLat = value;
        centerY = GeoUtils.pixelY(value, zoom);
    }

    public function set centerX(value:uint):void {
        _centerX = value;
        _screenX = _centerX - _width / 2;
        _centerLon = GeoUtils.pixelXToLongitude(value, _zoom);
    }

    public function set centerY(value:uint):void {
        _centerY = value;
        _screenY = _centerY - this._height / 2;
        _centerLat = GeoUtils.pixelYToLatitude(value, _zoom);
    }

    public function get centerY():uint {
        return _centerY;
    }

    public function get centerX():uint {
        return _centerX;
    }

    public function get centerLat():Number {
        return _centerLat;
    }

    public function get centerLon():Number {
        return _centerLon;
    }

    public function get width():Number {
        return _width;
    }

    public function get height():Number {
        return _height;
    }

    public function getBottomLeft():Location {
        var location:Location = new Location();
        var x:Number = GeoUtils.pixelXToLongitude(_screenX, _zoom);
        var y:Number = GeoUtils.pixelYToLatitude(_screenY + this.height, _zoom);
        location.lat = x;
        location.lon = y;
        return location;
    }

    public function getTopRight():Location {
        var location:Location = new Location();
        var x:Number = GeoUtils.pixelXToLongitude(_screenX + this.width, _zoom);
        var y:Number = GeoUtils.pixelYToLatitude(_screenY, _zoom);
        location.lat = x;
        location.lon = y;
        return location;
    }
}
}
