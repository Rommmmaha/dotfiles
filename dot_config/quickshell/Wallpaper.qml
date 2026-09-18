import Quickshell
import Quickshell.Wayland
import QtQuick

Variants {
  model: Quickshell.screens
  PanelWindow {
    required property var modelData
    screen: modelData
    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "r-wallpaper"
    exclusionMode: ExclusionMode.Ignore
    color: "black"
    Image {
      anchors.fill: parent
      source: Theme.wallpaper
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      cache: false
      smooth: true
    }
    MouseArea {
      id: drag
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton
      property real pressX: 0
      property real pressY: 0
      property real curX: 0
      property real curY: 0
      property bool selecting: false
      onPressed: m => {
        pressX = m.x
        pressY = m.y
        curX = m.x
        curY = m.y
        selecting = true
      }
      onPositionChanged: m => {
        if (selecting) {
          curX = m.x
          curY = m.y
        }
      }
      onReleased: selecting = false
      onCanceled: selecting = false
    }
    Rectangle {
      visible: drag.selecting
      x: Math.min(drag.pressX, drag.curX)
      y: Math.min(drag.pressY, drag.curY)
      width: Math.abs(drag.curX - drag.pressX)
      height: Math.abs(drag.curY - drag.pressY)
      color: Qt.rgba(1, 1, 1, 0.15)
      border.color: Qt.rgba(1, 1, 1, 0.9)
      border.width: 1
    }
  }
}
