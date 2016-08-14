
/*
 * Slideshow shows images from a specific subfolder. The images are moved and
 * zoomed in or out to give the still images a dynamic component
 * 
 */

import QtQuick 2.5
import Qt.labs.folderlistmodel 1.0
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0

Widget {
	id: root
	type: "slide"
	
	anchors.fill: parent
	
	/*
	 * User settings
	 *
	 */
	
	property var getPosStart: getPos_zoomOut_start
	property var getPosEnd: getPos_zoomOut_end
	property bool fillScreenAlways: false
	property bool fillScreenLandscape: true
	property bool fillScreenRandom: false
	property string imageFolder: "./"
	property int moveTime: 10000
	property int fadeTime: 3000
	property var nameFilters: ["*.JPG", "*.jpg", "*.png"]
	property string backgroundColor: "#000000"
	property var imageList: undefined
	property var sceneEnd: undefined
	
	/*
	 * Internal variables
	 *
	 */
	
	property bool resume: false
	property bool pausable: true
	property var frontImg
	property var backImg
	property var frontRec
	property var backRec
	property var frontText
	property var backText
	property int imgIdx: 0
	property var imgs: new Array()
	property var updateWindowStart: new Array()
	property var updateWindowStop: new Array()
	signal animEnd
	
	
	/*
	 * Functions
	 *
	 */
	
	function scenePreload() {
		if (imageList) {
			root.imgs = imageList
			
			if (root.imgs.length > 0 && root.autoStart)
				startAnim()
		} else {
			imagelist.folder = root.imageFolder
		}
	}
	
	function sceneStart() {
		if (frontRec == undefined)
			startAnim()
		else
			root.animEnd()
	}
	
	function scenePause() {
	}
	
	function sceneIsPausable() {
		return pausable
	}
	
	Component.onCompleted: {
		if (root.autoStart) {
			started = true
			scenePreload()
		}
	}
	
	// move the number n closer to 0 or 1
	function quart(n) {
		n *= 2;
		
		if (n < 1)
			return 0.5 * n * n * n * n;
		
		n = -0.5 * ((n -= 2) * n * n * n - 2);
		
// 		if (n > 1)
// 			n = 1;
		
		return n;
	}
	
	// find a random point on the X-axis close to the edges
	function getx(w) {
		var x;
		
		x = quart(Math.random())
		x = x*(root.width - w)
		
		return Math.floor(x);
	}
	
	// find a random point on the Y-axis close to the edges
	function gety(h) {
		var y;
		
		y = quart(Math.random())
		y = y*(root.height - h)
		
		return Math.floor(y);
	}
	
	// get a random position in the image
	function getPos_rand(img) {
		var d, x, y, dx, dy, scale, w, h, i
		
		scale = quart(Math.random()) / 2 + 0.5;
		if (scale > 0.8)
			scale = 0.8
		
		w = Math.floor(img.sourceSize.width * scale)
		h = Math.floor(img.sourceSize.height * scale)
		
		// try to find a random position that is not too close to the start position
		i = 0
		d = 0
		while ((d < img.sourceSize.height / 3 || d < img.sourceSize.width / 3) && i < 10) {
			x = getx(w)
			y = gety(h)
			
			dx = img.x - x
			dy = img.y - y
			
			d = Math.sqrt((dx*dx)+(dy*dy))
			
			i += 1;
		}
		
		return {x: x, y: y, w: w, h: h, scale: scale}
	}
	
	// get a random position in the image but start in a "zoomed-in" state
	function getPos_zoomOut_start(img) {
		var d, x, y, dx, dy, scale, w, h, i
		
		// always start already a bit "zoomed out" (displaySize = originalSize * scale)
		scale = 0.9 - Math.random()/3
		
		// do not zoom out if image would be smaller than canvas size
		if (scale * img.sourceSize.width < root.width)
			scale = root.width / img.sourceSize.width
			
		w = Math.floor(img.sourceSize.width * scale)
		h = Math.floor(img.sourceSize.height * scale)
		
		x = getx(w)
		y = gety(h)
		
		return {x: x, y: y, w: w, h: h, scale: scale}
	}
	
	// get a random position in the image but zoom out until the complete image or most of the image can be seen
	function getPos_zoomOut_end(img) {
		var d, x, y, dx, dy, scale, scaleX, scaleY, w, h, i
		var fillScreen = false
		
		if (root.fillScreenRandom)
			fillScreen = (Math.random() > 0.5)
		
		if (root.fillScreenAlways)
			fillScreen = true
		
		if (root.fillScreenLandscape && img.sourceSize.width > img.sourceSize.height)
			fillScreen = true
		
		scaleX = root.width / img.sourceSize.width
		scaleY = root.height / img.sourceSize.height
		
		// show complete image in any case or avoid black borders?
		if (fillScreen)
			scale = Math.max(scaleX, scaleY)
		else
			scale = Math.min(scaleX, scaleY)
		
		w = Math.floor(img.sourceSize.width * scale)
		h = Math.floor(img.sourceSize.height * scale)
		
		// try to find a random position that is not too close to the start position
		i = 0
		d = 0
		while ((d < img.sourceSize.height / 3 || d < img.sourceSize.width / 3) && i < 10) {
			x = getx(w)
			y = gety(h)
			
			dx = img.x - x
			dy = img.y - y
			
			d = Math.sqrt((dx*dx)+(dy*dy))
			
			i += 1;
		}
		
		// if we do not fill the complete screen, ensure that the final image will be centered
		if (!fillScreen && w < root.width)
			x = root.width / 2 - w/2
		if (!fillScreen && h < root.height)
			y = root.height / 2 - h/2
		
		return {x: x, y: y, w: w, h: h, scale: scale}
	}
	
	// create a new target state for the animation
	function createNewState(rec, img, state) {
		var o
		
		if (state == "move") {
			var view
			view = getPosEnd(img)
			o = template_state_move.createObject(root, {statename:"move", ttarget: img, xx: view.x, yy:view.y, ww:view.w, hh:view.h})
		} else
		if (state == "fadein") {
			o = template_state_fade.createObject(root, {statename:"fadein", ttarget: rec, oopacity: 1})
		} else
		if (state == "fadeout") {
			o = template_state_fade.createObject(root, {statename:"fadeout", ttarget: rec, oopacity: 0})
		}
		
		var mylist = []
		mylist.push(o)
		root.states = mylist;
	}
	
	function startAnim() {
		console.log("slide start")
		
		frontRec = repeater.itemAt(0)
		backRec = repeater.itemAt(1)
		frontImg = frontRec.children[1]
		backImg = backRec.children[1]
		
		frontRec.z = 1
		
		backRec.z = 0
		
		frontImg.source = root.imgs[imgIdx][1];
		frontRec.title = root.imgs[imgIdx][0];
		imgIdx++;
		
		// calling with img twice as we want to fade in the image while the
		// background rectangle is already visible
		createNewState(frontRec, frontImg, "fadein")
		
		animation.duration = root.fadeTime;
		animation.easing.type = Easing.InQuad;
		root.state = "fadein";
		animation.duration = root.moveTime;
	}
	
	// determine, prepare and start the next state
	onAnimEnd: {
		if (root.started == false)
			return
		
		if (root.state == "fadeout") {
			// reset transparent front image and bring back image to the front
			frontRec.visible = false
			frontRec.z = 0
			backRec.z = 1
			
			// swap pointers
			var o = frontImg
			frontImg = backImg
			backImg = o
			
			o = frontRec
			frontRec = backRec
			backRec = o
			
			o = frontText
			frontText = backText
			backText = o
			
			// get and initiate new move animation
			animation.duration = root.moveTime;
			animation.easing.type = Easing.InOutQuad;
			createNewState(frontRec, frontImg, "move")
			root.state = "move";
			
			// load image into background
			backImg.source = root.imgs[imgIdx][1];
			backRec.title = root.imgs[imgIdx][0];
// 			backImg.sourceSize.height *= 0.9
// 			backImg.sourceSize.width *= 0.9
			imgIdx++;
			if (imgIdx == root.imgs.length) {
				imgIdx = 0;
			}
			
			pausable = true
			// notify others that we don't block the main thread
			for (var i=0; i<root.updateWindowStart.length; i++) {
				root.updateWindowStart[i]()
			}
			
			
		} else
		if (root.state == "move") {
			if (imgIdx == 1 && root.resume == false && root.sceneEnd) {
				root.resume = true
				root.sceneEnd()
				return;
			} else {
				root.resume = false
			}
			
			// notify others that we will block the main thread
			for (var i=0; i<root.updateWindowStop.length; i++) {
				root.updateWindowStop[i]()
			}
			pausable = false
			
			// make background image visible and initiate fadeout of front image
			backRec.opacity = 1
			backRec.visible = true
			
			// initiate fade-out animation
			animation.duration = root.fadeTime;
			animation.easing.type = Easing.InQuint;
			createNewState(frontRec, frontImg, "fadeout")
			root.state = "fadeout";
			
			
		} else
		if (root.state == "fadein") { // only used for initial fadein
			backImg.source = root.imgs[imgIdx][1];
			backRec.title = root.imgs[imgIdx][0];
			
			imgIdx++;
			if (imgIdx == root.imgs.length)
				imgIdx = 0;
			
			createNewState(frontRec, frontImg, "move")
			root.state = "move";
			
			// notify others that we don't block the main thread
			for (var i=0; i<root.updateWindowStart.length; i++) {
				root.updateWindowStart[i]()
			}
			pausable = true
		}
	}
	
	/*
	 * Objects
	 *
	 */
	
	// FolderListModel and Repeater to get list of images
	FolderListModel {
		id: imagelist
		
		nameFilters: root.nameFilters
		showDirs: false
		showOnlyReadable: true
	}
	
	Repeater {
		model: imagelist
		
		Component {
			Item {
				Component.onCompleted: {
					root.imgs.push(["", filePath]);
					
					if (root.imgs.length == 1 && root.autoStart)
						startAnim()
				}
			}
		}
	}
	
	// template for a state that we will switch to for a move animation
	Component {
		id: template_state_move
		State {
			property var statename
			property var ttarget
			property var xx
			property var yy
			property var ww
			property var hh
			
			name: statename
			PropertyChanges {
				explicit: true;
				restoreEntryValues: false;
				
				target: ttarget;
				x: xx;
				y: yy;
				width: ww;
				height: hh;
			}
		}
	}
	
	// template for a state that we will switch to for a fade animation
	Component {
		id: template_state_fade
		State {
			property var statename
			property var ttarget
			property var oopacity
			
			name: statename
			PropertyChanges {
				explicit: true;
				restoreEntryValues: false;
				
				target: ttarget
				opacity: oopacity
			}
		}
	}
	
	// make two out of one canvas for the images
	Repeater {
		id: repeater
		model: 2
		
		// rectangle as image background
		Rectangle {
			id: rec
			x:0
			y:0
			width: parent.width
			height: parent.height
			
			opacity: 0
			color: root.backgroundColor;
			
			property alias source: image.source
			property alias title: title.text
			
			Rectangle {
				anchors.right: parent.right
				anchors.margins: 20
				z: 1
				height:  parent.height / 15
				color: "#ffffff"
				opacity: 0.5
				
				LinearGradient {
					opacity: 1
					anchors.fill: parent
					
					start: Qt.point(0, 0)
					end: Qt.point(0, parent.height)
					
					gradient: Gradient {
						GradientStop { position: 0.0; color: "white" }
						GradientStop { position: 1.0; color: "#222222" }
					}
				}
				
				Text {
					id: title
					x: 10
					font.pixelSize: parent.height-10
					
					onTextChanged: {
						parent.width = this.contentWidth + 20
						if (this.contentWidth > 0) {
							parent.opacity = 0.5
						} else {
							parent.opacity = 0
						}
					}
				}
			}
			
			Image {
				id: image
				opacity: 1
				autoTransform: true
				fillMode: Image.PreserveAspectCrop
				width: parent.width
				height: parent.height
				// mipmap: true // causes flicker
				cache: false
				asynchronous: true
				
				onStatusChanged: {
					// set initial position
					if (this.status == Image.Ready) {
						var o = getPosStart(this)
						x = o.x
						y = o.y
						width = o.w
						height = o.h
					}
				}
			}
		}
	}
	
	states: []
	
	transitions: [
		Transition {
			SequentialAnimation {
				NumberAnimation {
					id: animation;
					
					properties: "x,y,width,height,opacity";
					easing.type: Easing.InOutQuad;
				}
				ScriptAction { script: root.animEnd() } // signal that animation has finished
			}
		}
	]
}
