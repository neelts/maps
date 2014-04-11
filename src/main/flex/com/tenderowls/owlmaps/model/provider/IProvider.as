package com.tenderowls.owlmaps.model.provider {
/**
 * @author Alexander Morozov <morozov@tenderowls.com>
 */
public interface IProvider {

    function getTileWidth():int;

    function getTileHeight():int;

    function getMaxScale():int;

    function getMinScale():int;

    function getUrl(x:uint, y:uint, scale:int):String

}
}
