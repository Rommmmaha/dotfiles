import Quickshell
import QtQuick
import QtQuick.Window
import Quickshell.Wayland
import Quickshell.Io
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
  visible: notifModel.count > 0 || root.historyOpen
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
  property bool historyOpen: false
  readonly property int historyLimit: 50
  function updateHover() {
    for (let i = 0; i < notifRepeater.count; i++) {
      const item = notifRepeater.itemAt(i)
      if (item && item.hovered) return true
    }
    return false
  }
  function addToHistory(notification, receivedAt) {
    historyModel.insert(0, {
      appName: notification.appName || "",
      appIcon: notification.appIcon || "",
      summary: notification.summary || "",
      body: notification.body || "",
      image: notification.image || "",
      urgency: notification.urgency,
      receivedAt: receivedAt.getTime()
    })
    if (historyModel.count > root.historyLimit) historyModel.remove(root.historyLimit)
  }
  ListModel {
    id: notifModel
  }
  ListModel {
    id: historyModel
  }
  Connections {
    target: root.notifications
    function onNotification(n) {
      root.historyOpen = false
      notifModel.insert(0, { notifId: n.id, notif: n, receivedAt: new Date() })
    }
  }
  IpcHandler {
    target: "notifications"
    function toggleHistory() {
      root.historyOpen = !root.historyOpen
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
      Rectangle {
        visible: root.historyOpen
        width: parent.width
        implicitHeight: 42
        radius: Theme.cardRadius
        color: Theme.background
        border.width: 1
        border.color: Theme.borderColor
        Text {
          anchors.left: parent.left
          anchors.leftMargin: 16
          anchors.verticalCenter: parent.verticalCenter
          text: "History"
          color: Theme.textPrimary
          font {
            family: Theme.fontFamily
            pixelSize: Theme.fontSizeSummary
            bold: true
          }
        }
        Rectangle {
          id: clearButton
          anchors.right: parent.right
          anchors.rightMargin: 8
          anchors.verticalCenter: parent.verticalCenter
          implicitWidth: clearLabel.implicitWidth + 18
          implicitHeight: 28
          radius: 7
          color: clearMouse.containsMouse ? Theme.buttonBgHover : Theme.buttonBg
          Text {
            id: clearLabel
            anchors.centerIn: parent
            text: "Clear"
            color: clearMouse.containsMouse ? Theme.buttonTextHover : Theme.buttonText
            font {
              family: Theme.fontFamily
              pixelSize: Theme.fontSizeAction
            }
          }
          MouseArea {
            id: clearMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            onClicked: historyModel.clear()
          }
        }
      }
      Text {
        visible: root.historyOpen && historyModel.count === 0
        width: parent.width
        height: 40
        text: "No timed-out notifications"
        color: Theme.textMuted
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font {
          family: Theme.fontFamily
          pixelSize: Theme.fontSizeBody
        }
      }
      Repeater {
        id: notifRepeater
        model: notifModel
        delegate: NotificationCard {
          required property var modelData
          visible: !root.historyOpen
          notification: modelData.notif
          receivedTime: modelData.receivedAt
          hoverPaused: root.anyHovered
          paused: root.historyOpen
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
          onTimedOut: root.addToHistory(modelData.notif, modelData.receivedAt)
        }
      }
      Repeater {
        id: historyRepeater
        model: historyModel
        delegate: NotificationCard {
          required property var modelData
          visible: root.historyOpen
          notification: ({
            id: -1,
            appName: modelData.appName,
            appIcon: modelData.appIcon,
            summary: modelData.summary,
            body: modelData.body,
            image: modelData.image,
            urgency: modelData.urgency,
            expireTimeout: 0,
            resident: false,
            actions: []
          })
          receivedTime: modelData.receivedAt
          paused: true
          historyMode: true
          clickDismiss: false
          width: parent.width
          height: implicitHeight
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
