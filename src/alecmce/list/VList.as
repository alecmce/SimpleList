package alecmce.list
{
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import flash.display.MovieClip;
	
	/**
	 * A simple vertical-list
	 * 
	 * 2010 (c) Alec McEachran
	 * 
	 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
	 */
	public class VList
	{
		private var container:MovieClip;
		private var baseY:int;
		
		private var _items:Vector.<ListItem>;
		private var count:uint;
		
		private var dy:int;
		
		private var _data:Vector.<ListDatum>;
		private var dataLength:Number;
		
		private var _position:Number;
		private var _index:int;
		
		private var _dataChanged:Signal;
		
		/**
		 * Class Constructor
		 * 
		 * @param container The MovieClip that contains a collection of MovieClips
		 * which will comprise the list items
		 */
		public function VList(container:MovieClip)
		{
			this.container = container;
			this.baseY = container.y;
			
			_dataChanged = new Signal(VList);
			
			init();
		}
		
		/**
		 * exposes the list items
		 */
		public function get items():Vector.<ListItem>
		{
			return _items;
		}
		
		/**
		 * set the data that defines the list
		 */
		public function set data(data:Vector.<ListDatum>):void
		{
			if (_data == data)
				return;
			
			_data = data;
			dataLength = _data.length;
			
			updateItems();
			
			_dataChanged.dispatch(this);
		}
		
		/**
		 * get the data that defines the list
		 */
		public function get data():Vector.<ListDatum>
		{
			return _data;
		}
		
		/**
		 * set the list position
		 * 
		 * @param value The index of the top item as a decimal, so that 0.5 corresponds
		 * to the position where half of the first item is visible
		 */
		public function set position(value:Number):void
		{
			_position = value != value ? 0 : value;
			container.y = baseY - _position * dy;
			
			var newIndex:int = _position | 0;
			if (_index == newIndex)
				return;
			
			_index = newIndex;
			updateItems();
		}
		
		/**
		 * retrieve the list position
		 */
		public function get position():Number
		{
			return _position;
		}
		
		/**
		 * retrieve the index of the top-most visible list item 
		 */
		public function get index():int
		{
			return _index;
		}
		
		/**
		 * configure the list item
		 */
		private function init():void
		{
			var children:Vector.<MovieClip> = generateChildren(container);
			this.dy = normalizeHeight(children);
			this._items = generateItems(children);
			this.count = _items.length;
			
			_position = 0;
			_index = 0;
			
			updateItems();
		}
		
		/**
		 * inspects the container and pulls out all the MovieClips
		 * 
		 * @return A Vector of the MovieClip children in the container
		 */
		private function generateChildren(container:MovieClip):Vector.<MovieClip>
		{
			var children:Vector.<MovieClip> = new Vector.<MovieClip>();
			
			var count:uint = container.numChildren;
			for (var i:int = 0; i < count; i++)
			{
				var mc:MovieClip = container.getChildAt(i) as MovieClip;
				if (mc)
					children.push(mc);
			}
			
			return children;
		}
		
		/**
		 * inspects the MovieClip list and normalizes the distance between them
		 * 
		 * @return The mean distance between list items
		 */
		private function normalizeHeight(children:Vector.<MovieClip>):int
		{
			children = children.sort(sort);
			
			var count:uint = children.length;
			var first:MovieClip = children[0];
			var last:MovieClip = children[count - 1];

			var bottom:int = last.getRect(last.parent).top;
			var top:int = first.getRect(first.parent).top;
			var init:int = first.y;
			var dy:int = (bottom - top) / (count - 1);
			
			for (var i:int = 0; i < count; i++)
				children[i].y = init + i * dy;
			
			return dy;
		}
		
		/**
		 * sort the list to ensure the children are top-down
		 */
		private function sort(a:MovieClip, b:MovieClip):int
		{
			return a.y < b.y ? -1 : a.y > b.y ? 1 : 0;
		}
		
		/**
		 * creates a ListItem for each MovieClip
		 * 
		 * @return A vector of ListItem
		 */
		private function generateItems(children:Vector.<MovieClip>):Vector.<ListItem>
		{
			var count:uint = children.length;
			var items:Vector.<ListItem> = new Vector.<ListItem>(count, true);
			
			for (var i:int = 0; i < count; i++)
				items[i] = new ListItem(children[i]);
			
			return items;
		}
		
		/**
		 * appropriately position the list items inside the container and
		 * assign to them the correct data
		 */
		private function updateItems():void
		{
			var i:int = count;
			while (i--)
			{
				var n:int = i + _index;
				var item:ListItem = _items[n % count];
				
				item.mc.y = n * dy;
				item.datum = n < dataLength ? _data[n] : null;
			}
		}
		
		public function get dataChanged():ISignal
		{
			return _dataChanged;
		}
		
	}
}
