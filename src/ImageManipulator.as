package {
import flash.filesystem.File;

public class ImageManipulator {

	public function ImageManipulator() {
	}

	public function deleteFile(nativePath:String, useTrash:Boolean = true):void {
		var file:File = new File(nativePath);
		if (useTrash) {
			file.moveToTrashAsync()
		} else {
			file.deleteFileAsync();
		}
	}

}
}
