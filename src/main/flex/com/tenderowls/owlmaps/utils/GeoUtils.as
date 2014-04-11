package com.tenderowls.owlmaps.utils {
/**
 * @author Alexander Morozov <morozov@tenderowls.com>
 */
public class GeoUtils {


    public static const DEG_RAD:Number = PI / 180;
    public static const RAD_DEG:Number = 180 / PI;
    private static const PI:Number = Math.PI;
    public static const MAX_LONGITUDE:uint = 67108864;
    public static const MAX_LATITUDE:uint = 67108864;
    private static const C_LONGITUDE:Number = 360 / MAX_LONGITUDE;
    private static const C_LATITUDE:Number = 2 * PI / MAX_LATITUDE;
    private static const C_LATITUDE2:Number = MAX_LATITUDE / 2;
    public static const EARTH_RADIUS:uint = 6378137;
    public static const PIXELS_PER_TILE:uint = 256;


    public static function mapSize(zoom:uint):Number {
        return 256<<zoom;
    }

    public static function groundResolution(latitude:Number, zoom:int):Number {
        return Math.cos(latitude * Math.PI / 180) * 2 * Math.PI * EARTH_RADIUS / mapSize(zoom);
    }

    public static function pixelX(longitude:Number, zoom:int):uint {
        var x:Number = ((longitude + 180) / 360) * mapSize(zoom);
        return x;
    }


    public static function pixelY(latitude:Number, zoom:int):uint {
        var mapSize:int = PIXELS_PER_TILE * (1 << zoom); // 256 * 2^zoom
        var sinLatitude:Number = Math.sin(latitude * Math.PI / 180);
        var y:Number = 0.5 - Math.log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * Math.PI);
        var pixelY:int = (y * mapSize + 0.5);
        return pixelY;
    }

    public static function pixelXToLongitude(pixelX:int, zoom:int):Number {
        var mapSize:Number = GeoUtils.mapSize(zoom);
        var x:Number = pixelX / mapSize - 0.5;
        return 360 * x;
    }

    public static function pixelYToLatitude(pixelY:int, zoom:int):Number {
        var mapSize:Number = GeoUtils.mapSize(zoom);
        var y:Number = 0.5 - pixelY / mapSize;
        var latitude:Number = 90 - 360 * Math.atan(Math.exp(-y * 2 * Math.PI)) / Math.PI;
        return latitude;
    }

    public static function pixelToTile(pixel:int):int {
        return pixel / 256;
    }

    public static function pixelOffsetForTile(pixel:int):int {
        return pixel % PIXELS_PER_TILE;
    }

    public static function lon2tile(lon:Number, zoom:Number):Number {
        return (Math.floor((lon + 180) / 360 * Math.pow(2, zoom)));
    }

    public static function lat2tile(lat:Number, zoom:uint):Number {
        return (Math.floor((1 - Math.log(Math.tan(lat * Math.PI / 180) + 1 / Math.cos(lat * Math.PI / 180)) / Math.PI) / 2 * Math.pow(2, zoom)));
    }

    public static function tile2lon(x:uint, z:uint):Number {
        return (x / Math.pow(2, z) * 360 - 180);
    }

    public static function tile2lat(y:uint, z:uint):Number {
        var n:Number = Math.PI - 2 * Math.PI * y / Math.pow(2, z);
        return (180 / Math.PI * Math.atan(0.5 * (Math.exp(n) - Math.exp(-n))));
    }

    /**
     * Converts x coordinate to lon.
     */
    public static function x2lon(x:Number):Number
    {
        return x * C_LONGITUDE - 180;
    }

    /**
     * Converts lon to x coordinate.
     */
    public static function lon2x(lon:Number):Number
    {
        return (lon + 180) / C_LONGITUDE
    }

    /**
     * Converts y coordinate to lat.
     */
    public static function y2lat(y:Number):Number
    {
        return Math.atan(sinh(PI - (C_LATITUDE * y))) * RAD_DEG;
    }

    /**
     * Converts lat to y coordinate.
     */
    public static function lat2y(lat:Number):Number
    {
        var latRad:Number = lat * DEG_RAD;
        return (1 - Math.log(Math.tan(latRad) + 1 / Math.cos(latRad)) / PI) * C_LATITUDE2;
    }

    /**
     * Returns the hyperbolic sine of value.
     */
    public static function sinh(value:Number):Number
    {
        return (Math.exp(value) - Math.exp(-value)) / 2;
    }

}
}
