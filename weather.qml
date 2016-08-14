
/*
 * weather shows the current weather using the data from OpenWeathermap.org
 */

import QtQuick 2.5
import QtQuick.XmlListModel 2.0
import QtGraphicalEffects 1.0

Widget {
	id: root
	type: "weather"
	
	anchors.fill: parent
	
	property string cityId: "" // get the Id for your location and set this variable
	property string appId: "" // get your API key from the website, see http://openweathermap.org/appid
	property string lang: "en"
	property string currentURLPrefix: "http://api.openweathermap.org/data/2.5/weather?id="
	property string forecastURLPrefix: "http://api.openweathermap.org/data/2.5/forecast/daily?id="
	property string currentURL: ""
	property string forecastURL: ""
	property string backgroundImage: ""
	property int fetchInterval: 7200000   // fetch feeds every two hours
	property string iconPath: "resources/weather/"
	
	function scenePreload() {
// 		console.log(currentURL + cityId + "&mode=xml&units=metric&appid=" + appId + "&lang=" + lang)
// 		console.log(forecastURL + cityId + "&mode=xml&units=metric&appid=" + appId + "&lang=" + lang)
		if (currentURL == "")
			currentWeather.source = currentURLPrefix + cityId + "&mode=xml&units=metric&appid=" + appId + "&lang=" + lang
		else
			currentWeather.source = currentURL
		
		if (forecastURL == "")
			forecastWeather.source = forecastURLPrefix + cityId + "&mode=xml&units=metric&appid=" + appId + "&lang=" + lang
		else
			forecastWeather.source = forecastURL
	}
	
	function sceneStart() {}
	
	function scenePause() {}
	
	Component.onCompleted: {
		if (root.autoStart) {
			scenePreload()
		}
	}
	
	
	// timer that reloads the data
	Timer {
		interval: root.fetchInterval; running: true; repeat: true
		onTriggered: {
			console.log("reload weather")
			currentWeather.reload()
			forecastWeather.reload()
			
//			scenePreload()
		}
	}
	
	Image {
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
		width: parent.width*0.75 + 20
		height: parent.height*0.75 + 20
		
		source: root.backgroundImage
		z:0
	}
	
	Rectangle {
		id: backgroundRectangle
		z:1
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
		width: parent.width*0.75 + 20
		height: parent.height*0.75 + 20
		color: "#eeeeee"
		opacity: 0.7
		border.width: 1
	}
	
	Text {
		anchors.top: backgroundRectangle.bottom
		anchors.right: backgroundRectangle.right
		font.pixelSize: 12
		text: "Quelle: openweathermap.org"
	}
	
	Text {
		id: errorMsg
		z:2
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
		text: "No weather data yet."
	}
	
	Item {
		id: canvas
		
		visible: false
		z:2
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
		width: parent.width*0.75
		height: parent.height*0.75
		
		Image {
			id: weatherIcon
			
			fillMode: Image.PreserveAspectFit
			anchors.margins: 20
			width:parent.width/2
			height:parent.height/2
			sourceSize.width:width
			sourceSize.height:height
			
			Timer {
				interval: 3000; running: true; repeat: true
				onTriggered: {
					parent.x = Math.random()*50 - 15
					parent.y = Math.random()*10 - 15
				}
			}
			
			Behavior on x {
				NumberAnimation { duration: 3000; easing.type: Easing.InOutSine;}
			}
			Behavior on y {
				NumberAnimation { duration: 3000; easing.type: Easing.InOutSine;}
			}
		}
		
		Text {
			id: temp
			
			anchors.right: parent.right
			height:parent.height/4
			anchors.left: weatherIcon.right
			font.pixelSize: height
			horizontalAlignment: Text.AlignRight
		}
		
		Text {
			id: tempMinMax
			
			anchors.left: weatherIcon.right
			anchors.right: parent.right
			anchors.top: temp.bottom
			height:parent.height/20
			font.pixelSize: height
			horizontalAlignment: Text.AlignRight
		}
		
		Row {
			id: sunriseset
			
// 			width:parent.width
			y: tempMinMax.y + tempMinMax.contentHeight
			height:parent.height/10
			anchors.right: parent.right
// 			layoutDirection: Qt.RightToLeft
			
			Item {
				id: sunRiseCanvas
				clip:true
				height:parent.height-10
				width:sunRiseImg.width
// 				anchors.right: sunRise.left
				
				Image {
					id:sunRiseImg
// 					anchors.right: sunRise.left
	// 				anchors.verticalCenter: parent.verticalCenter
					
					fillMode: Image.PreserveAspectFit
					sourceSize.width:120
					sourceSize.height:parent.height
					height:parent.height
					
					source: iconPath+"weather_01.svg"
					
					SequentialAnimation on y {
						loops: Animation.Infinite
						NumberAnimation { from: 0;  to: -100; duration: 1500}
						ScriptAction { script: sunRiseImg.y = sunRiseImg.height }
						NumberAnimation { from: 100;  to: 0; duration: 1500}
					}
					SequentialAnimation on x {
						loops: Animation.Infinite
						NumberAnimation { from: 0;  to: 20; duration: 1500}
						ScriptAction { script: sunRiseImg.y = -20 }
						NumberAnimation { from: -20;  to: 0; duration: 1500}
					}
				}
			}
			
			Text {
// 				anchors.right: sunSetCanvas.left
				anchors.verticalCenter: parent.verticalCenter
				id: sunRise
				height:parent.height/2
				font.pixelSize: height
			}
			
			Item {
				width: 20
				height: parent.height
			}
			
			Item {
				id: sunSetCanvas
				clip:true
				height:parent.height-10
				width:sunSetImg.width
// 				anchors.right: sunSet.left
				
				Image {
					id:sunSetImg
// 					anchors.right: sunSet.left
	// 				anchors.verticalCenter: parent.verticalCenter
					
					fillMode: Image.PreserveAspectFit
					sourceSize.width:100
					sourceSize.height:parent.height
					height:parent.height
					
					source: iconPath+"weather_01.svg"
					
					SequentialAnimation on y {
						loops: Animation.Infinite
						NumberAnimation { from: 0;  to: 100; duration: 1500}
						ScriptAction { script: sunRiseImg.y = -sunRiseImg.height }
						NumberAnimation { from: -100;  to: 0; duration: 1500}
					}
					SequentialAnimation on x {
						loops: Animation.Infinite
						NumberAnimation { from: 0;  to: 20; duration: 1500}
						ScriptAction { script: sunRiseImg.y = -20 }
						NumberAnimation { from: -20;  to: 0; duration: 1500}
					}
				}
			}
			
			Text {
				anchors.verticalCenter: parent.verticalCenter
				id: sunSet
				height:parent.height/2
				font.pixelSize: height
			}
		}
		
		Row {
			id: forecast
			
			x: 0
			z: 1
			width:parent.width
			anchors.top: sunriseset.bottom
			anchors.bottom: parent.bottom
			
			Repeater {
				id: forecast_repeater
				model: 5
				
				Column {
					width: forecast.width / 5
					height: forecast.height
					spacing: 5
					
					Text {
						anchors.horizontalCenter: parent.horizontalCenter
						height: parent.height/12
						font.pixelSize: height
					}
					
					Image {
						width: parent.width
						height: parent.height/2
						fillMode: Image.PreserveAspectFit
						anchors.horizontalCenter: parent.horizontalCenter
						
						sourceSize.width: width
						sourceSize.height: height
					}
					
					Text {
						anchors.horizontalCenter: parent.horizontalCenter
						horizontalAlignment: Text.AlignHCenter
						height: parent.height/10
						font.pixelSize: height
					}
				}
			}
		}
	}
	
	
	XmlListModel {
		id: currentWeather
		query: "/current"
		
		XmlRole {
			name: "temp"
			query: "temperature/@value/string()"
		}
		
		XmlRole {
			name: "tempMin"
			query: "temperature/@min/string()"
		}
		
		XmlRole {
			name: "tempMax"
			query: "temperature/@max/string()"
		}
		
		XmlRole {
			name: "humidity"
			query: "humidity/@value/string()"
		}
		
		XmlRole {
			name: "windSpeed"
			query: "wind/speed/@value/string()"
		}
		
		XmlRole {
			name: "windSpeedHuman"
			query: "wind/speed/@name/string()"
		}
		
		XmlRole {
			name: "cloudsName"
			query: "clouds/@name/string()"
		}
		
		XmlRole {
			name: "weatherValue"
			query: "weather/@value/string()"
		}
		
		XmlRole {
			name: "weatherIcon"
			query: "weather/@icon/string()"
		}
		
		XmlRole {
			name: "precipitation"
			query: "precipitation/@value/string()"
		}
		
		XmlRole {
			name: "pressure"
			query: "pressure/@value/string()"
		}
		
		XmlRole {
			name: "sunRise"
			query: "city/sun/@rise/string()"
		}
		
		XmlRole {
			name: "sunSet"
			query: "city/sun/@set/string()"
		}
		
		onCountChanged: {
			currentStart()
		}
		
		function currentStart() {
			if (currentWeather.count == 0)
				return
			
			if (forecastWeather.count > 0) {
				canvas.visible = true
				errorMsg.visible = false
			}
			
			weatherIcon.source = iconPath+"weather_"+currentWeather.get(0).weatherIcon.substring(0,2)+".svg"
			temp.text = Math.round(currentWeather.get(0).temp) + "°"
			
			tempMinMax.text = ""
// 			tempMinMax.text += "Wind: "+currentWeather.get(0).windSpeedHuman + "\n"
			tempMinMax.text += "Niederschlag: "+currentWeather.get(0).precipitation+" mm"
			tempMinMax.text += "\nLuftfeuchtigkeit: "+currentWeather.get(0).humidity + "%"
			tempMinMax.text += "\nLuftdruck: "+currentWeather.get(0).pressure+" hPa"
			
			var d = new Date(currentWeather.get(0).sunRise)
			sunRise.text = Qt.formatDateTime(d, "hh:mm")
			
			var d = new Date(currentWeather.get(0).sunSet)
			sunSet.text = Qt.formatDateTime(d, "hh:mm")
		}
	}
	
	XmlListModel {
		id: forecastWeather
		query: "/weatherdata/forecast/time"
		
		
		XmlRole {
			name: "day"
			query: "@day/string()"
		}
		
		XmlRole {
			name: "weatherName"
			query: "symbol/@name/string()"
		}
		
		XmlRole {
			name: "weatherIcon"
			query: "symbol/@var/string()"
		}
		
		XmlRole {
			name: "tempDay"
			query: "temperature/@day/string()"
		}
		
		XmlRole {
			name: "tempMin"
			query: "temperature/@min/string()"
		}
		
		XmlRole {
			name: "tempMax"
			query: "temperature/@max/string()"
		}
		
		onCountChanged: {
			forecastStart()
		}
		
		function forecastStart() {
			var length
			
			if (forecastWeather.count == 0)
				return
			
			if (currentWeather.count > 0) {
				canvas.visible = true
				errorMsg.visible = false
			}
			
			length=forecast_repeater.count
			if (forecastWeather.count < forecast_repeater.count)
				length = forecastWeather.count
			
			for (var i=0; i < length; i++) {
				var d = new Date(forecastWeather.get(i).day)
				forecast_repeater.itemAt(i).children[0].text = Qt.formatDateTime(d, "dddd (dd.)")
				
				forecast_repeater.itemAt(i).children[1].source = iconPath+"weather_"+forecastWeather.get(i).weatherIcon.substring(0,2)+".svg"
				
				forecast_repeater.itemAt(i).children[2].text = "<h3>"+ Math.round(forecastWeather.get(i).tempDay) + "°</h3>"
				forecast_repeater.itemAt(i).children[2].text += "Max: "+ Math.round(forecastWeather.get(i).tempMax) + "°"
				forecast_repeater.itemAt(i).children[2].text += "<br>Min: "+ Math.round(forecastWeather.get(i).tempMin) + "°"
			}
		}
	}
	
}
