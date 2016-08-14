
/*
 * widget that shows a web page using QT's built-in browser engine
 */

import QtQuick 2.5
import QtWebKit 3.0

Widget {
	id: root
	type: "webview"
	anchors.fill: parent
	
	property string url: undefined // set this URL
	
	function scenePreload() {
		browser.url = root.url
	}
	
	function sceneStart() {}
	function scenePause() {}
	
	WebView {
		id: browser
		anchors.fill: parent
	}
}
