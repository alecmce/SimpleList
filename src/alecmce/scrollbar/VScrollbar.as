package alecmce.scrollbar
{
	import com.gskinner.motion.GTween;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * A simple vertical scroll-bar
	 * 
	 * 2010 (c) Alec McEachran
	 * 
	 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
	 */
	public class VScrollbar
	{
		private static const DURATION:Number = 0.3;

		private var knob:MovieClip;
		private var stage:Stage;
		private var groove:MovieClip;
		
		private var knobRectangle:Rectangle;
		private var grooveRectangle:Rectangle;
		
		private var _isVisible:Boolean;
		
		private var offsetY:int;
		private var top:int;
		private var bottom:int;
		private var visible:uint;
		private var count:uint;
		private var scalar:Number;
		
		private var tween:GTween;
		private var position:Number;
		
		private var _reposition:Signal;

		public function VScrollbar(knob:MovieClip, groove:MovieClip)
		{
			this.knob = knob;
			this.groove = groove;
			
			knobRectangle = knob.getRect(knob);
			grooveRectangle = groove.getRect(groove);
			
			tween = new GTween(knob, DURATION, null, {onChange:onChange});
			
			_reposition = new Signal(Number);
			
			_isVisible = false;
			knob.visible = false;
			groove.visible = false;
		}
		
		public function get reposition():ISignal
		{
			return _reposition;
		}
		
		public function setup(visible:uint, count:uint):void
		{
			this.visible = visible;
			this.count = count;
			
			var proportion:Number = visible / count;
			knob.scaleY = proportion;

			knob.y = top = groove.y + grooveRectangle.top - (knobRectangle.top * proportion);
			bottom = groove.y + grooveRectangle.bottom - (knobRectangle.bottom * proportion);
			scalar = (count - visible) / (bottom - top);
		}
		
		public function get isVisible():Boolean
		{
			return _isVisible;
		}

		public function set isVisible(isVisible:Boolean):void
		{
			if (_isVisible == isVisible)
				return;
			
			_isVisible = isVisible;
			knob.visible = isVisible;
			groove.visible = isVisible;
			
			if (isVisible)
				addListeners();
			else
				removeListeners();
		}
		
		private function addListeners():void
		{
			knob.useHandCursor = true;
			knob.buttonMode = true;
			
			stage = knob.stage;
			if (stage)
				knob.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		private function removeListeners():void
		{
			knob.useHandCursor = false;
			knob.buttonMode = false;
			
			knob.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			offsetY = knob.y - stage.mouseY;
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			var y:int = stage.mouseY + offsetY;
			y = y < top ? top : y > bottom ? bottom : y;
			knob.y = y;
			
			position = (knob.y - top) * scalar;
			_reposition.dispatch(position);
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			knob.stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			knob.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);

			var target:int = (Math.round(position - 0.2) / scalar) + top;
			tween.setValue("y", target);
		}
		
		private function onChange(tween:GTween):void
		{
			position = (knob.y - top) * scalar;
			_reposition.dispatch(position);
		}
		
	}
}
	