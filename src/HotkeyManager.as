package {
import flash.display.Stage;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import mx.core.FlexGlobals;

public class HotkeyManager {

	private var stage:Stage;

	public function HotkeyManager() {
	}

	public function listen(stage:Stage):void {
		this.stage = stage;
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	public function onKeyDown(event:KeyboardEvent):void {
		switch (event.keyCode) {
			case Keyboard.ENTER:
			case Keyboard.NUMPAD_ENTER:
				FlexGlobals.topLevelApplication.fullScreenManager.toggleFullScreen();
				break;
			case Keyboard.ESCAPE:
				if (FlexGlobals.topLevelApplication.fullScreenManager.isFullScreen()) {
					FlexGlobals.topLevelApplication.fullScreenManager.toggleFullScreen()
				} else {
					stage.nativeWindow.close();
				}
				break;
			case Keyboard.RIGHT:
				(FlexGlobals.topLevelApplication as Main).imageLoader.loadNext();
				break;
			case Keyboard.LEFT:
				(FlexGlobals.topLevelApplication as Main).imageLoader.loadPrev();
				break;
			case Keyboard.B:
				(FlexGlobals.topLevelApplication as Main).toggleBackground();
				break;
			case Keyboard.I:
				(FlexGlobals.topLevelApplication as Main).toggleInfo();
				break;
			case Keyboard.DELETE:
			case Keyboard.BACKSPACE:
				(FlexGlobals.topLevelApplication as Main).deleteCurrentFile(!event.shiftKey);
				break;
		}
	}
}
}
