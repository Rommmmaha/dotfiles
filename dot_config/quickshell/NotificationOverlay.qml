import Quickshell
import QtQuick
import QtQuick.Window
import Quickshell.Wayland
import Quickshell.Services.Notifications
PanelWindow {
  id: root
  required property var notifications
  WlrLayershell.namespace: "r-notifications"
  WlrLayershell.layer: WlrLayer.Overlay
  exclusiveZone: 0
  aboveWindows: true
  focusable: false
  color: "transparent"
  visible: notifModel.count > 0
  anchors {
    top: true
    right: true
  }
  margins {
    top: 12
    right: 12
    bottom: 12
  }
  implicitWidth: Theme.cardWidth
  readonly property real maxHeight: (Screen.height > 0 ? Screen.height : 800) - margins.top - margins.bottom
  implicitHeight: Math.min(flick.contentHeight, maxHeight)
  property bool anyHovered: false
  function updateHover() {
    for (let i = 0; i < notifRepeater.count; i++) {
      const item = notifRepeater.itemAt(i)
      if (item && item.hovered) return true
    }
    return false
  }
  ListModel {
    id: notifModel
  }
  Connections {
    target: root.notifications
    function onNotification(n) {
      notifModel.insert(0, { notifId: n.id, notif: n, receivedAt: new Date() })
    }
  }
  Flickable {
    id: flick
    anchors.fill: parent
    contentHeight: notifColumn.childrenRect.height
    contentWidth: width
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    interactive: true
    flickableDirection: Flickable.VerticalFlick
    boundsMovement: Flickable.StopAtBounds
    onContentHeightChanged: contentY = Math.min(contentY, Math.max(0, contentHeight - height))
    onHeightChanged: contentY = Math.min(contentY, Math.max(0, contentHeight - height))
    Column {
      id: notifColumn
      width: parent.width
      spacing: Theme.cardSpacing
      Repeater {
        id: notifRepeater
        model: notifModel
        delegate: NotificationCard {
          required property var modelData
          notification: modelData.notif
          receivedTime: modelData.receivedAt
          hoverPaused: root.anyHovered
          width: parent.width
          height: exiting ? 0 : implicitHeight
          Behavior on height {
            NumberAnimation {
              duration: 180
              easing.type: Easing.InOutCubic
            }
          }
          onHoveredChanged: root.anyHovered = root.updateHover()
          onRemoved: notifId => root.removeNotification(notifId)
        }
      }
    }
  }
  WheelHandler {
    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    onWheel: event => {
      const maxY = Math.max(0, flick.contentHeight - flick.height)
      if (maxY <= 0) return
      let dy = 0
      if (event.pixelDelta.y !== 0) dy = -event.pixelDelta.y
      else dy = -event.angleDelta.y / 120 * 60
      const ny = Math.max(0, Math.min(maxY, flick.contentY + dy))
      if (ny !== flick.contentY) {
        flick.contentY = ny
        event.accepted = true
      }
    }
  }
  function removeNotification(notifId) {
    for (let i = 0; i < notifModel.count; i++) {
      if (notifModel.get(i).notifId === notifId) {
        notifModel.remove(i)
        return
      }
    }
  }
}
