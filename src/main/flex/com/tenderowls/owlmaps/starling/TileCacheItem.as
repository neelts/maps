package com.tenderowls.owlmaps.starling {

import flash.geom.Rectangle;

import starling.textures.Texture;

/**
 * @author Aleksey Fomkin (aleksey.fomkin@gmail.com)
 */
public class TileCacheItem {

    public var texture:Texture;

    public var id:String;

    public var updateTime:uint;

    public var slot:int = -1;

    public function TileCacheItem(rootTexture:Texture, rect:Rectangle) {
        this.texture = Texture.fromTexture(rootTexture, rect);
    }
}

}
