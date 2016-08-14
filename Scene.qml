
/*
 * A scene is the manager object for one widget or several sub-scenes
 */

import QtQuick 2.5

Widget {
	id: scene
	type: "scene"
	
	clip: true
	visible: false
	property var duration: undefined
	property bool autoFlip: true
	
	// state and transition to move out a scene to the left
	states: [
		State {
			name: "out"
			PropertyChanges {
				restoreEntryValues: false;
				
				target: scene;
				x: -scene.width;
			}
		}
	]
	
	transitions: [
		Transition {
			SequentialAnimation {
				NumberAnimation {
					properties: "x";
					easing.type: Easing.InOutQuad;
					duration: 10000
				}
				ScriptAction { script: qante.sceneStarted() }
			}
		}
	]
}
