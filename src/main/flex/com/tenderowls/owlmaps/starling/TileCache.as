package com.tenderowls.owlmaps.starling {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.ImageDecodingPolicy;
import flash.system.LoaderContext;
import flash.utils.Dictionary;
import flash.utils.Timer;
import flash.utils.getTimer;

import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

import starling.core.Starling;

import starling.display.Image;
import starling.display.Sprite;

import starling.textures.RenderTexture;

import starling.textures.Texture;

/**
 * @author Aleksey Fomkin (aleksey.fomkin@gmail.com)
 */
public class TileCache {

    private static const UPLOAD_INTERVAL:uint = 80;

    private static const UPLOAD_COUNT:uint = 1;

    private var texture:RenderTexture;

    private var currentSlot:uint;

    private var size:uint;

    private var __rect:Rectangle;

    private var __point:Point;

    private var loaderIndex:Dictionary;

    private var ids:Vector.<String>;

    private var uploadTasks:Dictionary;

    private var timer:Timer;

    //-------------------------------------------------------------------------
    //
    //  Public methods
    //
    //-------------------------------------------------------------------------

    public function TileCache(width:uint, height:uint, size:uint) {
        // Check arguments
        if ((size & (size - 1)) || (width % size) || (height % size))
            throw new ArgumentError();

        this.size = size;
        this._width = 2048;
        this._height = 2048;

        initData();
        initTiles();
        initProps();
        initTimer();
    }

    public function load(ids:Vector.<String>, urls:Vector.<String>):void {
        if (ids.length != urls.length) {
            throw new ArgumentError("ids.length and urls.length must equals");
        }

        var id:String;
        var url:String;

        cleanupUploadTasks(ids);

        for (var loader:* in loaderIndex) {
            id = loaderIndex[loader];
            if (ids.indexOf(id) < 0) {
                try {
                    Loader(loader).close();
                }
                catch (error:Error) {
                    // It happens when queue of requests inside Flash runtime
                    // is too big, and loader has no time to start working.
                    // I don't know cheap way to figure out loading
                    // started or not.
                }
                delete loaderIndex[loader];
            }
        }

        var l:int = ids.length;

        var tileLoader:Loader;
        for (var i:int = 0; i < l; i++) {

            id = ids[i];
            url = urls[i];

            if (findItemById(id)) {
                continue;
            }

            tileLoader = findLoaderById(id);

            if (tileLoader == null) {
                var loaderContext:LoaderContext = new LoaderContext();
                loaderContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
                tileLoader = new Loader();
                tileLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler);
                tileLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loader_errorHandler);
                tileLoader.load(new URLRequest(url), loaderContext);
            }

            loaderIndex[tileLoader] = id;
        }

        this.ids = ids;
    }

    public function dispose():void {
        _onUpdate.removeAll();
        texture.dispose();
        for (var loader:* in loaderIndex) {
            Loader(loader).close();
        }
        timer.stop();
        cleanupUploadTasks(new <String>[]);
    }

    //-------------------------------------------------------------------------
    //
    //  Private methods
    //
    //-------------------------------------------------------------------------

    private function loader_errorHandler(event:IOErrorEvent):void {
        trace(event.text);
        const loader:Loader = LoaderInfo(event.target).loader;
        // Remove loader and url from index
        forgetLoader(loader);
    }

    private function loader_completeHandler(event:Event):void {

        const loader:Loader = LoaderInfo(event.target).loader
                , id:String = loaderIndex[loader]
                , content:Bitmap = Bitmap(loader.content)
                , source:BitmapData = content.bitmapData;

        uploadTasks[id] = function():void {
            // Check that current slot has actual data.
            // If it is then use next slot
            if (ids.indexOf(_items[currentSlot].id) > -1)
                nextSlot();

            const point:Point = calculateSlotPosition(currentSlot)
                    , item:TileCacheItem = _items[currentSlot]
                    , matrix:Matrix = new Matrix();

            // Update texture
            matrix.translate(point.x, point.y);

            var tmp:Texture = Texture.fromBitmapData(source, false, true);
            var image:Image = new Image(tmp);
           // var time:uint = getTimer();
            texture.draw(image, matrix);
          //  trace((getTimer()-time));
            tmp.dispose();

            // Update item
            item.updateTime = getTimer();
            item.id = id;
            item.slot = currentSlot;
            // Dispose resolver
            source.dispose();
            nextSlot();
        }

        forgetLoader(loader);
    }

    private function timer_timerHandler(event:TimerEvent):void {
        var i:int = 0;
        for (var id:String in uploadTasks) {
            if (i++ == UPLOAD_COUNT)
                break;
            uploadTasks[id]();
            delete uploadTasks[id];
        }
        _onUpdate.dispatch();
    }

    private function cleanupUploadTasks(ids:Vector.<String>):void {
        for (var id:String in uploadTasks) {
            if (ids.indexOf(id) < 0) {
                delete uploadTasks[id];
            }
        }
    }

    private function findLoaderById(id:String):Loader {
        for (var loader:* in loaderIndex) {
            if (loaderIndex[loader] == id)
                return loader;
        }
        return null;
    }

    private function findItemById(id:String):TileCacheItem {
        var result:TileCacheItem;
        for each (var item:TileCacheItem in _items) {
            if (item.id == id) {
                result = item;
                break;
            }
        }
        return result;
    }

    private function calculateSlotPosition(slot:uint):Point {
        const slotsInRow:uint = _width / size
                , slotsInCol:uint = _height / size
                , y:uint = slot / slotsInCol
                , x:uint = uint(slot % slotsInRow)

        __point.setTo(x * size, y * size);
        return __point.clone();
    }

    private function forgetLoader(loader:Loader):void {
        loader.unloadAndStop();
        delete loaderIndex[loader];
    }

    private function nextSlot():void {
        const maxSlot:uint = (_width * _height) / (size * size) - 1;
        currentSlot = currentSlot >= maxSlot ? 0 : currentSlot + 1;
    }

    private function initTimer():void {
        timer = new Timer(UPLOAD_INTERVAL);
        timer.addEventListener(TimerEvent.TIMER, timer_timerHandler);
        timer.start();
    }

    private function initProps():void {
        __point = new Point();
        __rect = new Rectangle(0, 0, size, size);
        _onUpdate = new Signal();

        uploadTasks = new Dictionary();
        loaderIndex = new Dictionary(true);
    }

    private function initData():void {
        this.texture = new RenderTexture(width, height);
    }

    private function initTiles():void {
        const maxSlots:uint = (_width * _height) / (size * size);

        _items = new Vector.<TileCacheItem>(maxSlots, true);

        var i:uint = 0;
        for (var y:int = 0; y < (_height / size); y++) {
            for (var x:int = 0; x < (_width / size); x++) {
                var rect:Rectangle = new Rectangle(x * size, y * size, size, size);
                _items[i++] = new TileCacheItem(texture, rect);
            }
        }
    }

    //-------------------------------------------------------------------------
    //
    //  Properties methods
    //
    //-------------------------------------------------------------------------

    //-------------------------------------------------------------------------
    //  onUpdate
    //-------------------------------------------------------------------------

    private var _onUpdate:ISignal;

    public function get onUpdate():ISignal {
        return _onUpdate;
    }

    //-------------------------------------------------------------------------
    //  tiles
    //-------------------------------------------------------------------------

    private var _items:Vector.<TileCacheItem>;

    public function get items():Vector.<TileCacheItem> {
        return _items;
    }

    //-------------------------------------------------------------------------
    //  width
    //-------------------------------------------------------------------------

    private var _width:uint;

    public function get width():uint {
        return _width;
    }

    //-------------------------------------------------------------------------
    //  height
    //-------------------------------------------------------------------------

    private var _height:uint;

    public function get height():uint {
        return _height;
    }
}

}