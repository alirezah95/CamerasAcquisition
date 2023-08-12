import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

ApplicationWindow {
    id: _rootWin
    
    width: 720
    height: 600
    visible: true
    title: qsTr("Two Camera Acquisition")

    GridLayout {
        anchors {
            fill: parent
            leftMargin: 8
            rightMargin: 8
            topMargin: 4
            bottomMargin: 4
        }

        columns: 2
        columnSpacing: 8
        rowSpacing: 24

        Rectangle {
            id: _firstCamera

            Layout.fillHeight: true
            Layout.fillWidth: true

            color: "transparent"
            radius: Material.SmallScale
            border.width: 2
            border.color: Material.frameColor
        }

        Rectangle {
            id: _secondCamera

            Layout.fillHeight: true
            Layout.fillWidth: true

            color: "transparent"
            radius: Material.SmallScale
            border.width: 2
            border.color: Material.frameColor
        }

        Rectangle {
            id: _resultImage

            Layout.columnSpan: 2
            Layout.fillHeight: true
            Layout.fillWidth: true

            color: "transparent"
            radius: Material.SmallScale
            border.width: 2
            border.color: Material.frameColor
        }
    }
}
