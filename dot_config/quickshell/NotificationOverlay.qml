import Quickshell
import QtQuick
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
  }
  implicitWidth: Theme.cardWidth
  implicitHeight: notifColumn.childrenRect.height
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
      notifModel.insert(0, { notifId: n.id, notif: n })
    }
  }
  Column {
    id: notifColumn
    anchors.fill: parent
    spacing: Theme.cardSpacing
    Repeater {
      id: notifRepeater
      model: notifModel
      delegate: NotificationCard {
        required property var modelData
        notification: modelData.notif
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
  function removeNotification(notifId) {
    for (let i = 0; i < notifModel.count; i++) {
      if (notifModel.get(i).notifId === notifId) {
        notifModel.remove(i)
        return
      }
    }
  }
}
