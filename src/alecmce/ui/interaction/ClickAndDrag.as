package alecmce.ui.interaction 
{
	import org.osflash.signals.Signal;

	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;

	public class ClickAndDrag
	{
		private var _enabled:Boolean;
		private var _master:InteractiveObject;
		
		private var _beginDrag:Signal;
		private var _clicked:Signal;
		private var _dragging:Signal;
		private var _endDrag:Signal;
		
		private var _isDragging:Boolean;
		private var _offsetX:Number;
		private var _offsetY:Number;

		public function ClickAndDrag(master:InteractiveObject)
		{
			_master = master;
			_beginDrag = new Signal(InteractiveObject);
			_clicked = new Signal(InteractiveObject);
			_dragging = new Signal(InteractiveObject);
			_endDrag = new Signal(InteractiveObject);

			enabled = true;
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(enabled:Boolean):void
		{
			if (_enabled == enabled)
				return;
			
			_enabled = enabled;
		
			if (_enabled)
				addListeners();
			else
				removeListeners();
		}
		
		public function finalize():void
		{
			_enabled = false;
			removeListeners();
			_beginDrag.removeAll();
			_dragging.removeAll();
			_endDrag.removeAll();
			_master = null;
		}

		private function addListeners():void
		{
			_master.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		}
		
		private function removeListeners():void
		{
			_master.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			_master.stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			_master.stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			_master.stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			_master.stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			
			_isDragging = false;
			_offsetX = _master.x - _master.parent.mouseX;
			_offsetY = _master.y - _master.parent.mouseY;
			
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			_master.x = _master.parent.mouseX + _offsetX;
			_master.y = _master.parent.mouseY + _offsetY;
			event.updateAfterEvent();
			
			if (_isDragging)
			{
				_dragging.dispatch(_master);
			}
			else
			{
				_isDragging = true;
				_beginDrag.dispatch(_master);
			}
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			_master.stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			_master.stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			
			if (_isDragging)
				_endDrag.dispatch(_master);
			else
				_clicked.dispatch(_master);
		}

		public function get dragging():Signal
		{
			return _dragging;
		}
		
		public function get beginDrag():Signal
		{
			return _beginDrag;
		}
		
		public function get endDrag():Signal
		{
			return _endDrag;
		}
		
		public function get clicked():Signal
		{
			return _clicked;
		}
	}
}