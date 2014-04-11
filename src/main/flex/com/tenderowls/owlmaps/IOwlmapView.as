package com.tenderowls.owlmaps {
import com.tenderowls.owlmaps.layers.OwlLayer;

import flash.geom.Point;

/**
 * @author Aleksey Fomkin (aleksey.fomkin@gmail.com)
 */
public interface IOwlmapView {

    function get width():Number;

    function get height():Number;

    function getTileY(id:String):Number;

    function getTileX(id:String):Number;

    function getTileIds():Vector.<String>;

    function setObjectProperties(id:String, x:Number, y:Number, explicitX:Number, explicitY:Number, scale:Number = NaN):void;

    function mapObjectMove(offsetX:int, offsetY:int, scale:Number):void;

    function update(tiles:Vector.<OwlMapTile>):void;

    function getTileScale(id:String):Number;

    function addLayer(layer:OwlLayer):void;

    function hideLayer(layer:OwlLayer):void;

    function showLayer(layer:OwlLayer):void;

    function setMapObjects(objects:Vector.<OwlMapObject>):void;

    function getObjectByLocation(location:Point):OwlMapObject;
}
}
