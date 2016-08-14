
/*
 * this QML can be called with qmlscene to debug a single widget
 */

import QtQuick 2.5

Item {
	id: widget
	
	anchors.fill: parent
	
	function loadComponent(parent, qmlfile, args) {
		var SliderComponent = Qt.createComponent(qmlfile);
		
		if (SliderComponent.status != Component.Ready) {
			if (SliderComponent.status == Component.Error)
				console.debug("Error:"+ SliderComponent.errorString());
			else
				SliderComponent.statusChanged.connect( function(){SliderComponent.createObject(parent, args); } )
		} else
			return SliderComponent.createObject(parent, args);
	}
	
	Component.onCompleted: {}
	
	Timer {
		id: start
		interval: 100; running: true; repeat: false
		onTriggered: {
			
			console.log(Qt.application.arguments[Qt.application.arguments.length-2])
			loadComponent(widget, Qt.application.arguments[Qt.application.arguments.length-2], {})
		}
	}
}
