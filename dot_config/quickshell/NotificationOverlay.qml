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
  WlrLayershell.keyboardFocus: root.historyOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  exclusiveZone: 0
  aboveWindows: true
  focusable: root.historyOpen
  color: "transparent"
  visible: notifModel.count > 0 || root.historyOpen
  anchors {
    top: true
    right: true
    left: root.historyOpen
    bottom: root.historyOpen
  }
  margins {
    right: 12
  }
  implicitWidth: Theme.cardWidth
  readonly property real maxHeight: Screen.height > 0 ? Screen.height : 800
  readonly property real panelHeight: Math.min(flick.contentHeight, root.maxHeight)
  implicitHeight: root.historyOpen ? root.maxHeight : root.panelHeight
  property bool anyHovered: false
  property bool historyOpen: false
  readonly property int historyLimit: 50
  property int nextHistoryId: 0
  onHistoryOpenChanged: {
    if (root.historyOpen) {
      flick.contentY = 0
      keyFocus.forceActiveFocus()
    }
  }
  function updateHover() {
    for (let i = 0; i < notifRepeater.count; i++) {
      const item = notifRepeater.itemAt(i)
      if (item && item.hovered) return true
    }
    return false
  }
  function addToHistory(notification, receivedAt) {
    historyModel.insert(0, {
      historyId: root.nextHistoryId++,
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
  function removeHistory(historyId) {
    for (let i = 0; i < historyModel.count; i++) {
      if (historyModel.get(i).historyId === historyId) {
        historyModel.remove(i)
        return
      }
    }
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
      notifModel.insert(0, { notifId: n.id, notif: n, receivedAt: new Date() })
    }
  }
  IpcHandler {
    target: "notifications"
    function toggleHistory() {
      root.historyOpen = !root.historyOpen
    }
  }
  MouseArea {
    id: outsideClick
    anchors.fill: parent
    enabled: root.historyOpen
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    onClicked: root.historyOpen = false
  }
  Item {
    id: panelArea
    anchors.top: parent.top
    anchors.right: parent.right
    width: Theme.cardWidth
    height: root.panelHeight
    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    }
    Flickable {
      id: flick
      anchors.fill: parent
      contentHeight: notifColumn.childrenRect.height + 24
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
        y: 12
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
            radius: implicitHeight / 2
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
        Rectangle {
          visible: root.historyOpen && historyModel.count === 0
          width: parent.width
          implicitHeight: 80
          radius: Theme.cardRadius
          color: Theme.background
          border.width: 1
          border.color: Theme.borderColor
          Text {
            anchors.centerIn: parent
            text: "No timed-out notifications"
            color: Theme.textMuted
            font {
              family: Theme.fontFamily
              pixelSize: Theme.fontSizeBody
            }
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
            onSwiped: modelData.notif.dismiss()
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
            onSwiped: root.removeHistory(modelData.historyId)
          }
        }
      }
    }
  }
  FocusScope {
    id: keyFocus
    anchors.fill: parent
    focus: root.historyOpen
    Keys.onPressed: event => {
      if (root.historyOpen) {
        root.historyOpen = false
        event.accepted = true
      }
    }
  }
  Timer {
    id: swipeReset
    interval: 250
    onTriggered: {
      scroller.swipeDelta = 0
      scroller.swipeTarget = null
    }
  }
  WheelHandler {
    id: scroller
    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    property real swipeDelta: 0
    property var swipeTarget: null
    function cardAt(p) {
      const rep = root.historyOpen ? historyRepeater : notifRepeater
      for (let i = 0; i < rep.count; i++) {
        const item = rep.itemAt(i)
        if (!item || !item.visible) continue
        const q = item.mapFromItem(null, p.x, p.y)
        if (q.x >= 0 && q.y >= 0 && q.x <= item.width && q.y <= item.height) return item
      }
      return null
    }
    onWheel: event => {
      const px = event.pixelDelta
      const ad = event.angleDelta
      const dx = px.x !== 0 ? px.x : ad.x
      const dy = px.y !== 0 ? px.y : ad.y
      if (Math.abs(dx) > Math.abs(dy)) {
        swipeReset.restart()
        if (!scroller.swipeTarget) scroller.swipeTarget = scroller.cardAt(scroller.point.scenePosition)
        scroller.swipeDelta += dx
        if (scroller.swipeTarget && Math.abs(scroller.swipeDelta) > 60) {
          scroller.swipeTarget.swipeOut(scroller.swipeDelta > 0 ? 1 : -1)
          scroller.swipeDelta = 0
          scroller.swipeTarget = null
        }
        event.accepted = true
        return
      }
      const maxY = Math.max(0, flick.contentHeight - flick.height)
      if (maxY <= 0) return
      let delta = 0
      if (px.y !== 0) delta = -px.y
      else delta = -ad.y / 120 * 60
      const ny = Math.max(0, Math.min(maxY, flick.contentY + delta))
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
