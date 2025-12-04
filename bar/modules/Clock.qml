// Clock.qml
import QtQuick
import "../../_services"
import "../../_styles"

Rectangle {
	height: 25
	width: 65
	radius: 30
	color: Styles.primary_container
	
	Text {
		anchors.centerIn: parent
		text: Time.time
		color: Styles.primary
		font: Qt.font({ 
			pixelSize: 17, 
			family: Styles.mainFont, 
			bold: true })
	}

}