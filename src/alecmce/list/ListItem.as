package alecmce.list
{
	import flash.display.MovieClip;
	
	/**
	 * An internal helper class for the different list types
	 * 
	 * 2010 (c) Alec McEachran
	 * 
	 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
	 */
	final internal class ListItem
	{
		
		private var _mc:MovieClip;
		private var _datum:ListDatum;

		public function ListItem(mc:MovieClip)
		{
			_mc = mc;
			_mc.visible = false;
		}

		public function get mc():MovieClip
		{
			return _mc;
		}

		public function get datum():ListDatum
		{
			return _datum;
		}

		public function set datum(datum:ListDatum):void
		{
			if (_datum == datum)
				return;
			
			_datum = datum;
			_mc.visible = _datum != null;
			
			if (_datum)
				_datum.apply(_mc);
		}
		
	}
	
}
