package alecmce.list
{
	import flash.display.MovieClip;
	
	/**
	 * A simple horizontal-list
	 * 
	 * 2010 (c) Alec McEachran
	 * 
	 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
	 */
	public class HList
	{
		private var container:MovieClip;
		private var baseX:int;
		
		private var items:Vector.<ListItem>;
		private var count:uint;
		
		private var dx:int;
		
		private var _data:Vector.<ListDatum>;
		private var dataLength:Number;
		
		private var _position:Number;
		private var _index:int;
		
		/**
		 * Class Constructor
		 * 
		 * @param container The MovieClip that contains a collection of MovieClips
		 * which will comprise the list items
		 */
		public function HList(container:MovieClip)
		{
			this.container = container;
			this.baseX = container.x;
			
			init();
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
			container.x = baseX - _position * dx;
			
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
			this.dx = normalizeHeight(children);
			this.items = generateItems(children);
			this.count = items.length;
			
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

			var right:int = last.getRect(last.parent).left;
			var left:int = first.getRect(first.parent).left;
			var init:int = first.x;
			var dx:int = (right - left) / (count - 1);
			
			for (var i:int = 0; i < count; i++)
				children[i].x = init + i * dx;
			
			return dx;
		}
		
		/**
		 * sort the list to ensure the children are top-down
		 */
		private function sort(a:MovieClip, b:MovieClip):int
		{
			return a.x < b.x ? -1 : a.x > b.x ? 1 : 0;
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
				var item:ListItem = items[n % count];
				
				item.mc.x = n * dx;
				item.datum = n < dataLength ? _data[n] : null;
			}
		}
		
		
		
	}
}
