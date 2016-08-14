
/*
 * widget is the base class for all visible objects
 */

import QtQuick 2.5

Item {
	id: widget
	
	clip: true
	visible: true
	
	property string type: "widget"
	property bool autoStart: true
	property bool loaded: false
	property bool started: false
	
	// load all data before we and our children are visible
	function preload() {
		if (this.scenePreload == undefined) {
			for (var i=0; i<widget.children.length; i++) {
				console.log("preload " + widget.children[i].type)
				widget.children[i].scenePreload()
			}
		} else {
			console.log("preload " + widget.type)
			this.scenePreload()
		}
		
		loaded = true
	}
	
	// start presenting our data
	function start() {
		if (this.sceneStart == undefined) {
			for (var i=0; i<widget.children.length; i++) {
				widget.children[i].started = true
				console.log("start " + widget.children[i].type)
				widget.children[i].sceneStart()
			}
		} else {
			console.log("start " + widget.type)
			this.sceneStart()
		}
		
		this.started = true
	}
	
	// pause presentation
	function pause() {
		if (this.scenePause == undefined) {
			for (var i=0; i<widget.children.length; i++) {
				console.log("pause " + widget.children[i].type)
				widget.children[i].scenePause()
				widget.children[i].started = false
			}
		} else {
			console.log("pause " + widget.type)
			this.scenePause()
		}
		
		started = false
	}
	
	function isPausable() {
		var pausable = true
		if (this.sceneIsPausable == undefined) {
			for (var i=0; i<widget.children.length; i++) {
				if (widget.children[i].sceneIsPausable != undefined) {
					console.log("isPausable " + widget.children[i].type)
					pausable = widget.children[i].sceneIsPausable()
					if (pausable == false)
						return false
				}
			}
			return true
		} else {
			console.log("isPausable " + widget.type)
			return this.sceneIsPausable()
		}
	}
	
	function makeVisible() {
		for (var i=0; i<widget.children.length; i++) {
			widget.children[i].visible = true
		}
		this.visible = true
	}
}
