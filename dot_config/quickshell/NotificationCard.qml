import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
Item {
  id: root
  required property var notification
  property bool paused: false
  property bool hoverPaused: false
  property bool clickDismiss: true
  property bool hovered: false
  property bool pinned: false
  property bool forceTimeout: false
  function togglePin() {
    if (root.pinned) {
      root.forceTimeout = true
      root.progress = 1.0
    }
    root.pinned = !root.pinned
  }
  property real progress: 1.0
  signal removed(int notifId)
  readonly property int notificationId: notification.id
  readonly property bool critical: notification.urgency === NotificationUrgency.Critical
  readonly property int timeoutMs: {
    if (root.critical || notification.resident || root.pinned) return 0
    if (root.forceTimeout) return 5000
    if (notification.expireTimeout > 0) return Math.min(notification.expireTimeout, 120000)
    return 3 * 1000
  }
  readonly property color accentColor: {
    if (notification.urgency === NotificationUrgency.Low) return Theme.accentLow
    if (root.critical) return Theme.accentCritical
    return Theme.accentNormal
  }
  readonly property real borderAlpha: notification.urgency === NotificationUrgency.Low || root.critical ? 0.75 : 0.25
  readonly property color cardBg: {
    if (notification.urgency === NotificationUrgency.Low || root.critical) {
      const c = root.accentColor
      return Qt.rgba(c.r * 0.25, c.g * 0.25, c.b * 0.25, 0.5)
    }
    return Theme.background
  }
  readonly property string iconSource: {
    if (notification.image) return notification.image
    const app = notification.appIcon
    if (!app) return ""
    if (app.charAt(0) === "/" || app.startsWith("file:") || app.startsWith("data:")) return app
    return "image://icon/" + app
  }
  function sanitize(s) {
    return (s || "").replace(/<span\s[^>]*>/gi, "").replace(/<\/span>/gi, "")
  }
  implicitWidth: Theme.cardWidth
  implicitHeight: content.implicitHeight + Theme.cardMargin * 2
  opacity: 0
  transform: Translate {
    id: slide
    y: 20
  }
  Connections {
    target: root.notification
    function onClosed() {
      root.alreadyClosed = true
      if (!root.exiting) root.removed(root.notificationId)
    }
  }
  ParallelAnimation {
    id: exitAnim
    running: root.exiting
    onRunningChanged: if (!running && root.exiting) root.finish()
    NumberAnimation {
      target: root
      property: "opacity"
      to: 0
      duration: 150
      easing.type: Easing.InQuad
    }
    NumberAnimation {
      target: slide
      property: "y"
      to: 12
      duration: 180
      easing.type: Easing.InQuad
    }
  }
  ParallelAnimation {
    id: enterAnim
    NumberAnimation {
      target: root
      property: "opacity"
      to: 1
      duration: 180
      easing.type: Easing.OutCubic
    }
    NumberAnimation {
      target: slide
      property: "y"
      to: 0
      duration: 240
      easing.type: Easing.OutCubic
    }
  }
  Component.onCompleted: enterAnim.start()
  function close(reason, action) {
    if (root.exiting) return
    root.closeReason = reason
    root.pendingAction = action
    root.exiting = true
  }
  function finish() {
    if (!root.alreadyClosed) {
      if (root.closeReason === 1) root.notification.expire()
      else if (root.closeReason === 2) root.notification.dismiss()
      else if (root.closeReason === 3) {
        const wasResident = root.notification.resident
        root.pendingAction.invoke()
        if (wasResident) root.notification.dismiss()
      }
    }
    root.removed(root.notificationId)
  }
  function buildMarkdown() {
    const lines = ["# " + (root.notification.summary || root.notification.appName || "")]
    if (root.notification.body) lines.push(root.sanitize(root.notification.body))
    if (root.notification.actions.length > 0) {
      lines.push(root.notification.actions.map(a => "[ " + (a.text || a.identifier) + " ]").join(" | "))
    }
    return lines.join("\n")
  }
  function copyToClipboard() {
    Quickshell.execDetached(["wl-copy", root.buildMarkdown()])
    root.close(2)
  }
  property bool exiting: false
  property bool alreadyClosed: false
  property int closeReason: 0
  property var pendingAction: null
  Rectangle {
    id: cardBg
    anchors.fill: parent
    color: root.cardBg
    radius: Theme.cardRadius
    border.width: 1
    border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, root.borderAlpha)
  }
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton
    onClicked: if (root.clickDismiss) root.close(2)
    cursorShape: Qt.PointingHandCursor
  }
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.RightButton
    onClicked: root.togglePin()
  }
  HoverHandler {
    onHoveredChanged: root.hovered = hovered
  }
  Text {
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.topMargin: Theme.cardMargin + 6
    anchors.rightMargin: Theme.cardMargin + 40
    visible: root.pinned
    text: "📌"
    color: Theme.textPrimary
    font {
      family: Theme.fontFamily
      pixelSize: 20
    }
  }
  ColumnLayout {
    id: content
    anchors {
      fill: parent
      margins: Theme.cardMargin
    }
    spacing: 6
    RowLayout {
      spacing: 10
      Item {
        implicitWidth: Theme.iconSize
        implicitHeight: Theme.iconSize
        visible: root.iconSource !== ""
        Image {
          id: icon
          anchors.fill: parent
          source: root.iconSource
          sourceSize: Qt.size(Theme.iconSize, Theme.iconSize)
          fillMode: Image.PreserveAspectFit
          smooth: true
          visible: source !== "" && status !== Image.Error
        }
        Rectangle {
          anchors.fill: parent
          radius: Theme.cardRadius / 2
          color: Theme.avatarBg
          visible: !icon.visible
          Text {
            anchors.centerIn: parent
            text: (root.notification.appName || "?")[0].toUpperCase()
            color: Theme.avatarText
            font {
              family: Theme.fontFamily
              pixelSize: 18
              bold: true
            }
          }
        }
      }
      ColumnLayout {
        Layout.fillWidth: true
        spacing: 2
        Text {
          Layout.fillWidth: true
          text: root.notification.appName || ""
          color: Theme.textMuted
          font {
            family: Theme.fontFamily
            pixelSize: Theme.fontSizeApp
          }
          elide: Text.ElideRight
        }
        Text {
          Layout.fillWidth: true
          text: root.notification.summary || ""
          color: Theme.textPrimary
          font {
            family: Theme.fontFamily
            pixelSize: Theme.fontSizeSummary
            bold: true
          }
          wrapMode: Text.Wrap
          maximumLineCount: 2
          elide: Text.ElideRight
        }
        Item {
          Layout.fillWidth: true
          Layout.preferredHeight: 2
          visible: root.timeoutMs > 0
          Rectangle {
            anchors { left: parent.left; bottom: parent.bottom }
            width: parent.width * root.progress
            height: 2
            radius: 1
            color: root.accentColor
          }
        }
      }
      Item {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        Layout.alignment: Qt.AlignTop
        Rectangle {
          anchors.fill: parent
          radius: 7
          color: copyHover.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"
        }
        Text {
          anchors.centerIn: parent
          text: "⧉"
          color: "#ffffff"
          font {
            family: Theme.fontFamily
            pixelSize: 26
          }
        }
        MouseArea {
          id: copyHover
          anchors.fill: parent
          hoverEnabled: true
          acceptedButtons: Qt.LeftButton
          cursorShape: Qt.PointingHandCursor
          onClicked: root.copyToClipboard()
        }
      }
    }
    Text {
      Layout.fillWidth: true
      visible: text !== ""
      text: root.sanitize(root.notification.body)
      color: Theme.textSecondary
      font {
        family: Theme.fontFamily
        pixelSize: Theme.fontSizeBody
      }
      wrapMode: Text.Wrap
      textFormat: Text.StyledText
      maximumLineCount: 4
      elide: Text.ElideRight
    }
      RowLayout {
        Layout.fillWidth: true
        spacing: 6
        visible: root.notification.actions.length > 0
        Repeater {
          model: root.notification.actions
          delegate: Rectangle {
            required property var modelData
            readonly property bool hovered: actionMouse.containsMouse
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            implicitHeight: 30
            radius: 7
            color: hovered ? Theme.buttonBgHover : Theme.buttonBg
            Text {
              id: actionText
              anchors.centerIn: parent
              text: modelData.text || modelData.identifier
              color: hovered ? Theme.buttonTextHover : Theme.buttonText
              font {
                family: Theme.fontFamily
                pixelSize: Theme.fontSizeAction
              }
            }
            MouseArea {
              id: actionMouse
              anchors.fill: parent
              hoverEnabled: true
              acceptedButtons: Qt.LeftButton
              cursorShape: Qt.PointingHandCursor
              onClicked: root.close(3, modelData)
            }
          }
        }
      }
  }
  Timer {
    interval: 50
    running: root.timeoutMs > 0 && !root.hovered && !root.hoverPaused && !root.paused && !root.exiting
    repeat: true
    onTriggered: {
      root.progress -= 50 / root.timeoutMs
      if (root.progress <= 0) root.close(1)
    }
  }
}
