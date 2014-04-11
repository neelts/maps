package com.tenderowls.owlmaps.starling {

import com.tenderowls.owlmaps.IOwlmapView;
import com.tenderowls.owlmaps.OwlMapObject;
import com.tenderowls.owlmaps.OwlMapTile;
import com.tenderowls.owlmaps.layers.OwlLayer;

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import starling.display.Image;
import starling.display.Quad;
import starling.display.QuadBatch;
import starling.display.Sprite;
import starling.events.Event;
import starling.utils.getNextPowerOfTwo;

/**
 * @author Aleksey Fomkin (aleksey.fomkin@gmail.com)
 */
public class StarlingOwlmapView extends Sprite implements IOwlmapView {

    //-------------------------------------------------------------------------
    //
    // Private variables
    //
    //-------------------------------------------------------------------------

    private static const FADE_TIME:Number = 500;

    private var __point:Point;

    private var tileQuadBatch:QuadBatch;

    private var objectQuadBatch:QuadBatch;

    private var scale:Number;

    private var tileCache:TileCache;

    private var schedulePropertiesUpdate:Boolean;

    private var scheduleQuadBatchReset:Boolean;

    private var objectX:Dictionary;

    private var objectY:Dictionary;

    private var objectExplicitX:Dictionary;

    private var objectExplicitY:Dictionary;

    private var objectScale:Dictionary;

    private var urls:Vector.<String>;

    private var ids:Vector.<String>;

    private var background:Quad;

    public var mapObjects:Vector.<OwlMapObject>;

    //-------------------------------------------------------------------------
    //
    //  Public methods
    //
    //-------------------------------------------------------------------------

    public function StarlingOwlmapView() {

        __point = new Point();

        this.background = new Quad(1, 1, 0);
        this.tileQuadBatch = new QuadBatch();
        this.objectQuadBatch = new QuadBatch();

        this.objectX = new Dictionary(true);
        this.objectY = new Dictionary(true);
        this.objectExplicitX = new Dictionary(true);
        this.objectExplicitY = new Dictionary(true);
        this.objectScale = new Dictionary(true);

        addChild(background);
        addChild(tileQuadBatch);
        addChild(objectQuadBatch);

        addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        buildTileCache();
    }

    public function update(tiles:Vector.<OwlMapTile>):void {

        var l:uint = tiles.length;

        urls = new Vector.<String>(l, true);
        ids = new Vector.<String>(l, true);

        for (var i:uint = 0; i < l; i++) {
            var owlTile:OwlMapTile = tiles[i];
            var id:String = owlTile.id;
            objectX[id] = owlTile.viewportX;
            objectY[id] = owlTile.viewportY;
            // Reset scale
            objectExplicitX[id] = 0;
            objectExplicitY[id] = 0;
            objectScale[id] = 1;
            urls[i] = owlTile.url;
            ids[i] = id;
        }

        tileCache.load(ids, urls);
        // scheduleQuadBatchReset = true;
    }

    public function getTileX(id:String):Number {
        return objectX[id];
    }

    public function getTileY(id:String):Number {
        return objectY[id];
    }

    public function getTileScale(id:String):Number {
        return objectScale[id];
    }

    public function setObjectProperties(id:String, x:Number, y:Number, explicitX:Number, explicitY:Number, scale:Number = NaN):void {

        objectExplicitX[id] = explicitX;
        objectExplicitY[id] = explicitY;

        objectX[id] = x;
        objectY[id] = y;

        if (!isNaN(scale)) {
            objectScale[id] = scale;
        }

        tileCacheUpdate();
    }

    public function getTileIds():Vector.<String> {
        return ids;
    }

    //-------------------------------------------------------------------------
    //
    //  Properties
    //
    //-------------------------------------------------------------------------

    //-------------------------------------------------------------------------
    // width
    //-------------------------------------------------------------------------

    private var _width:Number = 256;

    override public function get width():Number {
        return _width;
    }

    override public function set width(value:Number):void {
        if (value != _width) {
            _width = value;
            schedulePropertiesUpdate = true;
        }
    }

    //-------------------------------------------------------------------------
    // height
    //-------------------------------------------------------------------------

    private var _height:Number = 256;

    override public function get height():Number {
        return _height;
    }

    override public function set height(value:Number):void {
        if (value != _height) {
            _height = value;
            schedulePropertiesUpdate = true;
        }
    }

    //-------------------------------------------------------------------------
    // EnterFrameHandler
    //-------------------------------------------------------------------------

    private function enterFrameHandler(event:Event):void {

        if (schedulePropertiesUpdate) {
            clipRect = new Rectangle(0, 0, _width, _height);
            buildTileCache();

            background.width = _width;
            background.height = _height;
            schedulePropertiesUpdate = false;
        }

        if (scheduleQuadBatchReset) {
            resetQuadBatch();
        }
    }

    //-------------------------------------------------------------------------
    // Markers
    //-------------------------------------------------------------------------

    private function drawMapObjects():void {
        if (mapObjects != null) {
            for (var i:int = 0; i < mapObjects.length; i++) {
                var image:Image = mapObjects[i].getImage();
                image.x = mapObjects[i].viewportX;
                image.y = mapObjects[i].viewportY;
                if (image) {
                    if (mapObjects[i].canScale) {
                        image.scaleX = scale;
                        image.scaleY = scale;
                    }
                    objectQuadBatch.addImage(image);
                }
            }
        }
    }

    public function mapObjectMove(offsetX:int, offsetY:int, scale:Number):void {
        for (var i:int = 0; i < mapObjects.length; i++) {
            mapObjects[i].viewportX += offsetX;
            mapObjects[i].viewportY += offsetY;
            if (mapObjects[i].canScale) {
                mapObjects[i].getImage().scaleX = scale;
                mapObjects[i].getImage().scaleY = scale;
            }
        }
    }


    public function getObjectByLocation(location:Point):OwlMapObject {
        for (var i:int = mapObjects.length - 1; i >= 0; i--) {
            if (mapObjects[i].viewportX <= location.x &&
                    (mapObjects[i].viewportX + mapObjects[i].width) >= location.x &&
                    mapObjects[i].viewportY <= location.y &&
                    (mapObjects[i].viewportY + mapObjects[i].height) >= location.y
                    ) {
                return mapObjects[i];
            }
        }
        return null;
    }

    //-------------------------------------------------------------------------
    // Layers
    //-------------------------------------------------------------------------
    public function setMapObjects(objects:Vector.<OwlMapObject>):void {
        this.mapObjects = objects;
    }

    public function addLayer(layer:OwlLayer):void {
    }

    public function hideLayer(layer:OwlLayer):void {
    }

    public function showLayer(layer:OwlLayer):void {
    }

    //-------------------------------------------------------------------------
    //
    //  Private methods
    //
    //-------------------------------------------------------------------------

    private function resetQuadBatch():void {

        var fadeEnd:Boolean = true;
        var items:Vector.<TileCacheItem> = tileCache.items;
        var image:Image;

        tileQuadBatch.reset();
        objectQuadBatch.reset();

        for each (var item:TileCacheItem in items) {
            // Empty texture, or texture which not present in model
            if (item.id == null || ids.indexOf(item.id) < 0) {
                continue;
            }
            if (image == null) {
                image = new Image(item.texture);
            }
            else {
                image.texture = item.texture;
            }

            var deltaT:Number = getTimer() - item.updateTime;
            var alpha:Number = Math.min(deltaT / FADE_TIME, 1);
            if (alpha < 1) {
                fadeEnd = false;
            }

            var scale:Number = objectScale[item.id];
            image.x = objectX[item.id] * scale + objectExplicitX[item.id];
            image.y = objectY[item.id] * scale + objectExplicitY[item.id];
            image.scaleX = scale;
            image.scaleY = scale;

            // FIXME Fomkin: I don't know why, but it works.
            // FIXME If you read this and have some time please
            // FIXME fix this workaround
            image.alpha = alpha - 0.001;

            tileQuadBatch.addImage(image);
        }

        drawMapObjects();

        if (fadeEnd) {
            scheduleQuadBatchReset = false;
        }
    }

    protected function buildTileCache():void {
        // Rebuild tile cache if needs
        if (tileCache == null) {

            /* // Dispose obsolete
             if (tileCache != null) {
             tileCache.dispose();
             }*/

            tileCache = new TileCache(
                    getNextPowerOfTwo(_width + 512),
                    getNextPowerOfTwo(_height + 512), 256);

            tileCache.onUpdate.add(tileCacheUpdate);
        }
    }

    private function tileCacheUpdate():void {
        scheduleQuadBatchReset = true;
    }
}

}