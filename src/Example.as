package
{
	import alecmce.list.ListDatum;
	import alecmce.list.List;
	import alecmce.scrollbar.VScrollbar;

	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;

	public class Example extends Sprite
	{
		[Embed(source="../bin/list.swf")]
		private var assetClass:Class;
		
		protected var list:List;
		private var scrollbar:VScrollbar;
		
		public function Example()
		{
			var asset:* = new assetClass();
			var loader:Loader = asset.getChildAt(0) as Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			addChild(asset);
		}

		private function onComplete(event:Event):void
		{
			var info:LoaderInfo = LoaderInfo(event.target);
			info.removeEventListener(Event.COMPLETE, onComplete);

			var content:MovieClip = info.loader.content as MovieClip;
			
			setup(content);
		}
		
		protected function setup(content:MovieClip):void
		{
			list = new List(content.list);
			list.data = generateData();
			
			scrollbar = new VScrollbar(content.knob, content.groove);
			scrollbar.reposition.add(onReposition);
			scrollbar.setup(4, list.data.length);
			scrollbar.isVisible = list.data.length > 4;
		}
		
		protected function generateData():Vector.<ListDatum>
		{
			var data:Vector.<ListDatum> = new Vector.<ListDatum>();
			data.push(new ExampleDatum("Alpha"));
			data.push(new ExampleDatum("Beta"));
			data.push(new ExampleDatum("Gamma"));
			data.push(new ExampleDatum("Delta"));
			data.push(new ExampleDatum("Epsilon"));
			data.push(new ExampleDatum("Zeta"));
			data.push(new ExampleDatum("Eta"));
			data.push(new ExampleDatum("Theta"));
			
			return data;
		}

		private function onReposition(value:Number):void
		{
			list.position = value;
		}
		
	}
}
