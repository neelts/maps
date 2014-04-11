package com.tenderowls.owlmaps.model.provider {
/**
 * @author Alexander Morozov <morozov@tenderowls.com>
 */
public class OsmProvider implements IProvider{

    private const urlTemplates:Vector.<String> = Vector.<String>([
        "http://a.tile.openstreetmap.org/${z}/${x}/${y}.png",
        "http://b.tile.openstreetmap.org/${z}/${x}/${y}.png",
        "http://c.tile.openstreetmap.org/${z}/${x}/${y}.png"]);

    private static const WIDTH:uint = 256;
    private static const HEIGHT:uint = 256;
    private static const MAX_SCALE:uint = 18;
    private static const MIN_SCALE:uint = 1;

    public function OsmProvider():void{

    }


    public function getTileWidth():int{
        return WIDTH;
    }

    public function getTileHeight():int{
        return HEIGHT;
    }

    public function getMaxScale():int {
        return MAX_SCALE;
    }

    public function getMinScale():int {
        return MIN_SCALE;
    }

    /**
     * Returns url of tile by global xy coordinates.
     */
    public function getUrl(x:uint, y:uint, scale:int):String {
        var id:int = x / 5 + y / 3 + scale;
        var url:String = urlTemplates[(id < 0 ? -id : id) % urlTemplates.length];
        url = url.replace("${x}", x);
        url = url.replace("${y}", y);
        url = url.replace("${z}", scale);
        return url;
    }
}
}
