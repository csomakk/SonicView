package {
import flash.display.Stage;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import mx.core.FlexGlobals;

public class HotkeyManager {

	public function HotkeyManager() {
	}

	public function listen(stage:Stage):void {
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	public function onKeyDown(event:KeyboardEvent):void {
		if ([Keyboard.ENTER, Keyboard.NUMPAD_ENTER].indexOf(event.keyCode) != -1 ){
			FlexGlobals.topLevelApplication.fullScreenManager.toggleFullScreen();
		}
	}
}
}
