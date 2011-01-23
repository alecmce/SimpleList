package
{
	import alecmce.list.extensions.DragReordering;
	import flash.display.MovieClip;

	public class ExampleWithReordering extends Example
	{
		private var reordering:DragReordering;
		
		public function ExampleWithReordering()
		{
			super();
		}

		override protected function setup(content:MovieClip):void
		{
			super.setup(content);
			
			reordering = new DragReordering(list, 4);
			reordering.isEnabled = true;
		}

	}
}
