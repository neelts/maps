package com.tenderowls.owlmaps.model {
import com.tenderowls.owlmaps.OwlMapObject;

import flash.utils.Dictionary;

/**
 * @author Alexander Morozov <morozov@tenderowls.com>
 */
public class ObjectHashMap {

    private var map:Dictionary = null;

    public function ObjectHashMap(useWeakReferences:Boolean = false):void {
        map = new Dictionary(useWeakReferences);
    }

    public function put(value:OwlMapObject):void {
        map[value.id] = value;
    }

    public function remove(key:String):void {
        map[ key ] = undefined;
        delete map[ key ];
    }

    public function containsKey(key:String):Boolean {
        return map.hasOwnProperty(key);
    }

    public function getObjects():Dictionary {
        return map;
    }

    public function clear():void {
        map = new Dictionary();
    }
}
}
