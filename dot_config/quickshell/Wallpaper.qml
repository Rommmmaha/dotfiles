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
    mask: Region {}
    color: "black"
    Image {
      anchors.fill: parent
      source: Theme.wallpaper
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      cache: false
      smooth: true
    }
  }
}
