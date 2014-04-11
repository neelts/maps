package com.tenderowls.owlmaps {

/**
 * @author Aleksey Fomkin (aleksey.fomkin@gmail.com)
 */
public class OwlMapTile extends OwlMapObject {
    public var url:String;
    public var expectedWidth:int;
    public var expectedHeight:int;

    public function OwlMapTile(id:String, url:String, viewportX:Number, viewportY:Number, eW:int = 256, eH:int = 256) {
        this.url = url;
        this.expectedWidth = eW;
        this.expectedHeight = eH;
        super(id, viewportX, viewportY);
    }
}
}
