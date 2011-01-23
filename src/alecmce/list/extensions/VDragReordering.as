package alecmce.list.extensions
{
	import alecmce.list.ListDatum;
	import alecmce.list.ListItem;
	import alecmce.list.VList;

	import com.gskinner.motion.GTween;

	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class VDragReordering
	{
		private static const DURATION:Number = 0.3;
		
		/** how closely you need to get to the next item before the shift is triggered (must be > 0.5) */
		private static const STIFFNESS:Number = 0.6;

		private var list:VList;
		private var items:Vector.<ListItem>;
		private var visibleItems:uint;
		
		private var _isEnabled:Boolean;
		
		private var map:Dictionary;
		private var stage:Stage;
		
		private var dragItem:ListItem;
		private var dragMC:MovieClip;
		private var dragTween:GTween;
		private var startY:Number;
		private var offsetY:Number;
		private var index:int;
		
		private var aboveMC:MovieClip;
		private var aboveTween:GTween;
		private var aboveLimit:Number;
		private var aboveY:Number;
		
		private var belowMC:MovieClip;
		private var belowTween:GTween;
		private var belowLimit:Number;
		private var belowY:Number;

		public function VDragReordering(list:VList, visibleItems:uint)
		{
			this.list = list;
			this.items = list.items;
			this.visibleItems = visibleItems;
			
			map = new Dictionary();
		}

		public function get isEnabled():Boolean
		{
			return _isEnabled;
		}

		public function set isEnabled(isEnabled:Boolean):void
		{
			if (_isEnabled == isEnabled)
				return;
				
			_isEnabled = isEnabled;
			if (_isEnabled)
			{
				addListeners();
			}
			else
			{
				if (dragItem)
					onMouseUp(null);
				
				removeListeners();
			}
		}

		private function addListeners():void
		{
			list.dataChanged.add(onDataChanged);
			
			for each (var item:ListItem in items)
			{
				var mc:MovieClip = targetClip(item);
				map[mc] = item;
				mc.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
		}

		private function removeListeners():void
		{
			for each (var item:ListItem in items)
			{
				var mc:MovieClip = targetClip(item);
				delete map[mc];
				
				mc.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				
				if (stage)
				{	
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
					stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				}
			}
			
			dragItem = null;
			dragMC = null;
			dragTween = null;
			
			aboveMC = null;
			aboveTween = null;
			
			belowMC = null;
			belowTween = null;
		}
		
		/**
		 * Chooses which clip in the ListItem should trigger the reordering drag.
		 * This method is exposed as protected to enable overridding classes to 
		 * modify this for specific use-cases
		 * 
		 * @param item The ListItem to which mouse listeners are added
		 * @return The MovieClip to be interacted with to initiate a drag
		 */
		protected function targetClip(item:ListItem):MovieClip
		{
			return item.mc;
		}
		
		private function onDataChanged(list:VList):void
		{
			var currentlyEnabled:Boolean = isEnabled;
			isEnabled = false;
			isEnabled = currentlyEnabled;
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			dragMC = event.currentTarget as MovieClip;
			dragItem = map[dragMC];
			var parent:DisplayObjectContainer = dragMC.parent;
			parent.setChildIndex(dragMC, parent.numChildren - 1);
			dragTween = new GTween(dragMC, DURATION, null, {onComplete:onTweenComplete});
			index = items.indexOf(map[dragMC]);
			stage = dragMC.stage;
			startY = dragMC.y;
			offsetY = startY - dragMC.parent.mouseY;
			
			getAboveStats();
			getBelowStats();
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		private function getAboveStats():void
		{
			aboveMC = index > 0 ? targetClip(items[index - 1]) : null;
			if (!aboveMC)
				return;
			
			aboveTween = new GTween(aboveMC, DURATION);
			aboveY = aboveMC.y;
			aboveLimit = (aboveY - startY) * STIFFNESS;
		}

		private function getBelowStats():void
		{
			var n:int = items.length - 1;
			var m:int = list.index + visibleItems - 1;
			trace(n, m);
			if (n > m)
				n = m;
			
			belowMC = index < n ? targetClip(items[index + 1]) : null;
			if (!belowMC)
				return;
			
			belowTween = new GTween(belowMC, DURATION);
			belowY = belowMC.y;
			belowLimit = (belowY - startY) * STIFFNESS;
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			var y:Number = dragMC.parent.mouseY + offsetY;
			if (y < startY)
			{
				if (aboveMC)
				{
					if (y - startY < aboveLimit)
						shiftUp();
				}
				else
				{
					y = startY;
				}
			}
			else if (y > startY)
			{
				if (belowMC)
				{
					if (y - startY > belowLimit)
						shiftDown();
				}
				else
				{
					y = startY;
				}
			}
			
			dragMC.y = y;
			event.updateAfterEvent();
		}

		private function shiftUp():void
		{
			var n:int = index - 1;
			
			items[index] = items[n];
			items[n] = dragItem;
			
			var data:Vector.<ListDatum> = list.data;
			var current:ListDatum = data[index];
			data[index] = data[n];
			data[n] = current;
			
			belowTween = aboveTween;
			belowMC = aboveMC;
			belowY = startY;
			belowTween.setValue("y", belowY);

			startY = aboveY;
			belowLimit = (belowY - aboveY) * STIFFNESS;
			
			index = n;
			
			getAboveStats();
		}
		
		private function shiftDown():void
		{
			var n:int = index + 1;
			
			items[index] = items[n];
			items[n] = dragItem;
			
			var data:Vector.<ListDatum> = list.data;
			var current:ListDatum = data[index];
			data[index] = data[n];
			data[n] = current;
			
			aboveTween = belowTween;
			aboveMC = belowMC;
			aboveY = startY;
			aboveTween.setValue("y", aboveY);

			startY = belowY;
			aboveLimit = (aboveY - belowY) * STIFFNESS;
			
			index = n;
			
			getBelowStats();
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			dragTween.setValue("y", startY);
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage = null;
			
			dragItem = null;
			dragMC = null;
			
			isEnabled = false;
		}
		
		private function onTweenComplete(tween:GTween):void
		{
			isEnabled = true;
		}
		
	}
}
