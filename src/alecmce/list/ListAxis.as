package alecmce.list
{
	/**
	 * An axis enumeration for use within the list
	 * 
	 * 2010 (c) Alec McEachran
	 * 
	 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
	 */
	public class ListAxis
	{
		
		public static const X_AXIS:ListAxis = new ListAxis("x");
		public static const Y_AXIS:ListAxis = new ListAxis("y");

		public var property:String;

		public function ListAxis(property:String)
		{
			this.property = property;
		}
		
	}
}
