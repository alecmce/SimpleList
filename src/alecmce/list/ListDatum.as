package alecmce.list
{
	import flash.display.MovieClip;
	
	/**
	 * Defines the methods required for a ListDatum which can be a member of a list
	 * 
	 * 2010 (c) Alec McEachran
	 * 
	 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
	 */
	public interface ListDatum
	{
		
		function apply(mc:MovieClip):void;
		
	}
	
}
