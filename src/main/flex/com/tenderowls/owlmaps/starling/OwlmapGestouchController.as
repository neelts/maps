package com.tenderowls.owlmaps.starling {

import com.inreflected.ui.touchScroll.ThrowEffect;
import com.inreflected.ui.touchScroll.TouchScrollDecelerationRate;
import com.inreflected.ui.touchScroll.VelocityCalculator;
import com.tenderowls.owlmaps.IOwlMap;
import com.tenderowls.owlmaps.IOwlmapView;
import com.tenderowls.owlmaps.OwlMapObject;

import flash.geom.Point;
import flash.utils.getTimer;

import org.gestouch.events.GestureEvent;
import org.gestouch.gestures.TapGesture;
import org.gestouch.gestures.TransformGesture;
import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

/**
 * @author Aleksey Fomkin (aleksey.fomkin@gmail.com)
 */
public class OwlmapGestouchController {

    public static const DEFAULT_OFFSET_COMMIT_INTERVAL:uint = 300;

    //private var pan:PanGesture;

    private var transform:TransformGesture;

    private var tap:TapGesture;

    private var model:IOwlMap;

    private var view:IOwlmapView;

    private var offset:Point;

    private var throwEffectPosition:Point;

    private var throwEffect:ThrowEffect;

    private var velocityCalculator:VelocityCalculator

    private var offsetCommitTime:uint;

    public function OwlmapGestouchController(model:IOwlMap, view:IOwlmapView) {

        this.model = model;
        this.view = view;

        initGestures();
        initProps();
        init();
    }

    public function update():void {
        // Commit offset
        const offsetCommitTimeDelta:uint = getTimer() - offsetCommitTime;
        const offsetExists:Boolean = offset.x != 0 || offset.y != 0;
        if (offsetExists && (offsetCommitTimeDelta > offsetCommitInterval)) {
            model.offset(offset.x, offset.y);
            offsetCommitTime = getTimer();
            offset.setTo(0, 0);
        }
    }

    public var offsetCommitInterval:uint = DEFAULT_OFFSET_COMMIT_INTERVAL;

    private function init():void {
        model.init(view.width, view.height);
        model.onUpdate.add(whenModelUpdate);
    }

    private function whenModelUpdate():void {
        view.setMapObjects(model.objects);
        view.update(model.tiles);
    }

    private function initProps():void {
        throwEffect = new ThrowEffect()
        velocityCalculator = new VelocityCalculator();
        throwEffectPosition = new Point();
        offset = new Point();
    }

    private function initGestures():void {

        tap = new TapGesture(view);
        tap.addEventListener(GestureEvent.GESTURE_RECOGNIZED, tap_gestureBeganHandler);

        transform = new TransformGesture(view);
        transform.addEventListener(GestureEvent.GESTURE_BEGAN, pan_gestureBeganHandler);
        transform.addEventListener(GestureEvent.GESTURE_CHANGED, pan_gestureChangedHandler);
        transform.addEventListener(GestureEvent.GESTURE_ENDED, pan_gestureEndedHandler);
    }

    private const tile_size:uint = 256;

    /**
     * Visual offset. Changes only view state
     */
    protected function move(offsetX:Number, offsetY:Number, scaleMultiplier:Number = NaN, center:Point = null):void {
        // Current values
        var cX:Number, cY:Number, cScale:Number;
        // New values
        var x:Number, y:Number, scale:Number;
        var eX:Number = 0, eY:Number = 0;

        for each (var id:String in view.getTileIds()) {
            // Fill new values
            cX = view.getTileX(id);
            cY = view.getTileY(id);
            cScale = view.getTileScale(id);

            x = cX + offsetX;
            y = cY + offsetY;

           /* if (!isNaN(scaleMultiplier) || (scaleMultiplier < 0 || scaleMultiplier > 1)) {
                // Calculate scale
                scale = cScale * scaleMultiplier;
                // Explicit
                if (center) {
                    var w:Number = view.width, h:Number = view.height;
                    var dW:Number = w - w * scale, dH:Number = h - h * scale;
                    eX = center.x / w * dW;
                    eY = center.y / h * dH;
                }
            }
            else {
                scale = NaN;
            }*/

            view.setObjectProperties(id, x, y, eX, eY, scale);
        }

        view.mapObjectMove(offsetX, offsetY, scale);

        offset.x += offsetX;
        offset.y += offsetY;
        /*

         if (isNaN(scale) || scale == 0 || scale == 1) {
         for each (var id:String in view.getTileIds()) {
         currX = view.getTileX(id);
         currY = view.getTileY(id);
         view.setTileProperties(id, currX + offsetX, currY + offsetY);
         }
         offset.x += offsetX;
         offset.y += offsetY;
         }
         else {
         for each (id in view.getTileIds()) {

         currX = view.getTileX(id);
         currY = view.getTileY(id);
         currS = view.getTileScale(id);
         xSlot = getTileSlot(currX, center.x, currS);
         ySlot = getTileSlot(currY, center.y, currS);
         trace("slot", xSlot, ySlot);

         var d:Number = (tile_size * currS - tile_size * scale * currS) / 2;
         var xSign:Number = xSlot > 0 ? -1 : 1;
         var ySign:Number = ySlot > 0 ? -1 : 1;

         view.setTileProperties(
         id,
         //currX + xSlot * (tile_size * currS - tile_size * scale * currS),
         currX + (xSlot * 2 * d + d),
         currY + (ySlot * 2 * d + d),
         scale * currS
         );
         }
         }
         */
    }

    /*
     private function getTileSlot(coord:Number, center:Number, scale:Number):int {
     const v:Number = (center - coord) / (tile_size * scale);
     return v + (v > 0 ? 1 : 0);
     }
     */

    private function setupThrowEffect(velocity:Point):void {
        // Handlers
        throwEffect.onUpdateCallback = throwEffectUpdate;
        throwEffect.onCompleteCallback = throwEffectComplete;
        // Velocity
        throwEffect.startingVelocityX = velocity.x;
        throwEffect.startingVelocityY = velocity.y;
        // Position
        throwEffect.startingPositionX = 0;
        throwEffect.startingPositionY = 0;
        throwEffect.minPositionX = Number.NEGATIVE_INFINITY;
        throwEffect.minPositionY = Number.NEGATIVE_INFINITY;
        throwEffect.maxPositionX = Number.POSITIVE_INFINITY;
        throwEffect.maxPositionY = Number.POSITIVE_INFINITY;
        // Size
        throwEffect.viewportWidth = view.width;
        throwEffect.viewportHeight = view.height;
        // Misc
        throwEffect.decelerationRate = TouchScrollDecelerationRate.NORMAL;
        throwEffect.pull = false;
        throwEffect.bounce = false;
        throwEffect.maxBounce = 0;
    }

    private function pan_gestureBeganHandler(event:GestureEvent):void {
        if (throwEffect.isPlaying)
            throwEffect.stop(false);
        velocityCalculator.reset();
        offset.setTo(0, 0);
    }

    private function pan_gestureChangedHandler(event:GestureEvent):void {
        const scale:Number = transform.scale,
                x:Number = transform.offsetX,
                y:Number = transform.offsetY;

        velocityCalculator.addOffsets(x, y);
        move(x, y, scale, transform.location);
    }

    // dispatch gesture end
    private var _onGestureEnd:ISignal = new Signal();
    public function get onGestureEnd():ISignal {
        return _onGestureEnd;
    }

    private function pan_gestureEndedHandler(event:GestureEvent):void {
        const velocity:Point = velocityCalculator.calculateVelocity();
        throwEffectPosition.setTo(0, 0);
        setupThrowEffect(velocity);
        throwEffect.setup();
        throwEffect.play();
    }

    private function throwEffectComplete():void {
        throwEffect.stop();
        _onGestureEnd.dispatch();
    }

    private function throwEffectUpdate(x:Number, y:Number):void {
        const prev:Point = throwEffectPosition;
        move(prev.x - x, prev.y - y);
        prev.setTo(x, y);
    }

    // dispatch clicked object
    private var _onObjectClick:ISignal = new Signal(OwlMapObject);
    public function get onObjectClick():ISignal {
        return _onObjectClick;
    }

    private function tap_gestureBeganHandler(event:GestureEvent):void {
        if (throwEffect.isPlaying) {
            throwEffect.stop(false);
        }
        else {
            var object:OwlMapObject = view.getObjectByLocation(tap.location);
            if (object != null) {
                _onObjectClick.dispatch(object);
            }
        }
    }
}

}
