
/*
 * qante - a QML-based framework for standalone presentations
 *
 *  Copyright (C) 2016 Mario Kicherer (dev@kicherer.org)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.5
import QtQuick.Window 2.2

Item {
	id: qante
	anchors.fill: parent;
	
	property var defaultDuration: 20000 // how long a scene is visible by default
	
	property int sceneIdx: 0
	property var scenes: []
	
	// dynamically load a new QML object from a file
	function loadComponent(parent, qmlfile, args) {
		// load the QML file
		var SliderComponent = Qt.createComponent(qmlfile);
		
		// check if the component is available already
		if (SliderComponent.status != Component.Ready) {
			// check if there was an error
			if (SliderComponent.status == Component.Error) {
				console.debug("Error:"+ SliderComponent.errorString());
			} else {
				// create a callback function that will create the object as soon as the
				// component is ready
				SliderComponent.statusChanged.connect( function(){SliderComponent.createObject(parent, args); } )
			}
		} else {
			// create the object
			return SliderComponent.createObject(parent, args);
		}
	}
	
	function newWidget(parent, widget, args) {
		var wArgs
		var canvas
		
		// copy the arguments and add autostart=false
		wArgs = {}
		for (var i in args)
			wArgs[i] = args[i]
		wArgs["autoStart"] = false
		
		canvas = loadComponent(parent, widget + ".qml", wArgs)
		
		return canvas
	}
	
	// start transition to the next scene
	function flipScene() {
		var next = sceneIdx+1
		if (next == scenes.length)
			next = 0
			
		if (scenes[next].transitions && scenes[next].transitions.length > 0)
			scenes[next].transitions[0].enabled = false
			
		scenes[next].anchors.left = scenes[sceneIdx].right
		initScene(scenes[next])
		
		if (scenes[next].transitions && scenes[next].transitions.length > 0)
			scenes[next].transitions[0].enabled = true
		
		scenes[sceneIdx].state = "out"
		scenes[sceneIdx].pause()
	}
	
	// timer that will call flipScene()
	Timer {
		id: rotTimer
		interval: defaultDuration; running: false; repeat: false
		onTriggered: {
			if (scenes.length > 1 && scenes[sceneIdx].isPausable()) {
				flipScene()
			}
		}
	}
	
	// setup the scene for display
	function initScene(scene) {
		if (scene.loaded == false) {
			scene.preload()
			scene.width = scene.parent.width
			scene.height = scene.parent.height
		}
		scene.state = ""
		scene.makeVisible()
		
		if (scene.duration > 0)
			rotTimer.interval = scene.duration
		else
			rotTimer.interval = defaultDuration
	}
	
	// callback function that is called after the old scene is not visible anymore
	function sceneStarted() {
		var next = sceneIdx+1
		if (next == scenes.length)
			next = 0
		
		// unchain the new scene from the old
		scenes[next].anchors.left = undefined
		scenes[sceneIdx].visible = false
		
		scenes[next].start()
		
		if (scenes[next].autoFlip)
			rotTimer.running = true
		
		sceneIdx = next
	}
	
	function addScene(scene) {
		scenes.push(scene)
	}
	
	// Timer that will start the show after 100ms. Using a constructor to start
	// will fail as parts of the app are not ready yet.
	// TODO find a more reliable way to get notified when everything is ready
	Timer {
		id: start
		interval: 100; running: true; repeat: false
		onTriggered: {
			var args = {}
			// load the screenplay
			var screenplay = loadComponent(qante, "screenplay.qml", args)
			
			// initialize and start the show
			initScene(scenes[0])
			scenes[0].start()
			
			if (scenes[0].autoFlip)
				rotTimer.running = true
		}
	}
}
