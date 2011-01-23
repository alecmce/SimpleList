package
{
	import alecmce.list.extensions.VDragReordering;
	import flash.display.MovieClip;

	public class ExampleWithReordering extends Example
	{
		private var reordering:VDragReordering;
		
		public function ExampleWithReordering()
		{
			super();
		}

		override protected function setup(content:MovieClip):void
		{
			super.setup(content);
			
			reordering = new VDragReordering(list, 4);
			reordering.isEnabled = true;
		}

	}
}
