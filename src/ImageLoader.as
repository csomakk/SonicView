package {
import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.filesystem.File;

public class ImageLoader {

	var file:File;

	[Bindable]
	public var lastLoadedImageSource:Bitmap;
	[Bindable]
	public var lastLoadedImagePath:String;

	public function ImageLoader() {
	}

	public function loadImage(nativePath:String):void {
		file = new File();
		file.nativePath= nativePath;
		var dir = file.parent.getDirectoryListing();
		if (file.exists) {
			file.addEventListener(Event.COMPLETE, loadCompleteHandler);
			file.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			file.load();
			lastLoadedImagePath = nativePath;
		}
	}

	private function onIoError(event:IOErrorEvent):void {
		trace('IOERROR');
	}

	private function loadCompleteHandler(event:Event):void {
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadBytesHandler);
		loader.loadBytes(file.data);
	}

	private function loadBytesHandler(event:Event):void {
		var loaderInfo:LoaderInfo = (event.target as LoaderInfo);
		loaderInfo.removeEventListener(Event.COMPLETE, loadBytesHandler);
		lastLoadedImageSource = Bitmap(loaderInfo.content);
	}
}
}
