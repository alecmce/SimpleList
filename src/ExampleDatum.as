package
{
	import alecmce.list.ListDatum;
	import flash.display.MovieClip;

	public class ExampleDatum implements ListDatum
	{
		private var name:String;

		public function ExampleDatum(name:String)
		{
			this.name = name;
		}

		
		public function apply(mc:MovieClip):void
		{
			mc.label.text = name;
		}
	}
}
