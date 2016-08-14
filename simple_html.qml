
/*
 * widget that shows simple HTML, see http://doc.qt.io/qt-5/richtext-html-subset.html
 * for a list of supported HTML elements
 * 
 */

import QtQuick 2.5

Widget {
	id: root
	type: "html"
	anchors.fill: parent
	
	property var htmlURL: "simple_html.html" // local or remote HTML file that will be shown
	
	// fetch the HTML file
	function scenePreload() {
		var input = new XMLHttpRequest();
		
		input.open("GET", root.htmlURL);
		
		input.onreadystatechange = function() {
			if (input.readyState == XMLHttpRequest.DONE) {
				textobj.text = input.responseText
			}
		}
		
		input.send()
	}
	
	function sceneStart() {}
	function scenePause() {}
	
	Component.onCompleted: {
		if (root.autoStart) {
			scenePreload()
		}
	}
	
	// Text object centered in the scene
	Text {
		id: textobj
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
		horizontalAlignment: Text.AlignHCenter
		textFormat: Text.RichText
	}
}
