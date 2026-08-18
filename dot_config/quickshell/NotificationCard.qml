import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
Item {
  id: root
  required property var notification
  property bool paused: false
  property bool clickDismiss: true
  property bool hovered: false
  signal removed(int notifId)
  readonly property int notificationId: notification.id
  readonly property bool critical: notification.urgency === NotificationUrgency.Critical
  readonly property int timeoutMs: {
    if (root.critical || notification.resident) return 0
    if (notification.expireTimeout > 0) return Math.min(notification.expireTimeout, 120000)
    return 5000
  }
  readonly property color accentColor: {
    if (notification.urgency === NotificationUrgency.Low) return NotificationStyle.accentLow
    if (root.critical) return NotificationStyle.accentCritical
    return NotificationStyle.accentNormal
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
  implicitWidth: NotificationStyle.cardWidth
  implicitHeight: content.implicitHeight + NotificationStyle.cardMargin * 2
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
    color: NotificationStyle.background
    radius: NotificationStyle.cardRadius
    border.width: 1
    border.color: root.accentColor
  }
  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: root.hovered = true
    onExited: root.hovered = false
    onClicked: if (root.clickDismiss) root.close(2)
    cursorShape: Qt.PointingHandCursor
  }
  ColumnLayout {
    id: content
    anchors {
      fill: parent
      margins: NotificationStyle.cardMargin
    }
    spacing: 6
    RowLayout {
      spacing: 10
      Item {
        implicitWidth: NotificationStyle.iconSize
        implicitHeight: NotificationStyle.iconSize
        visible: root.iconSource !== ""
        Image {
          id: icon
          anchors.fill: parent
          source: root.iconSource
          sourceSize: Qt.size(NotificationStyle.iconSize, NotificationStyle.iconSize)
          fillMode: Image.PreserveAspectFit
          smooth: true
          visible: source !== "" && status !== Image.Error
        }
        Rectangle {
          anchors.fill: parent
          radius: NotificationStyle.cardRadius / 2
          color: NotificationStyle.avatarBg
          visible: !icon.visible
          Text {
            anchors.centerIn: parent
            text: (root.notification.appName || "?")[0].toUpperCase()
            color: NotificationStyle.avatarText
            font {
              family: NotificationStyle.fontFamily
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
          color: NotificationStyle.textMuted
          font {
            family: NotificationStyle.fontFamily
            pixelSize: NotificationStyle.fontSizeApp
          }
          elide: Text.ElideRight
        }
        Text {
          Layout.fillWidth: true
          text: root.notification.summary || ""
          color: NotificationStyle.textPrimary
          font {
            family: NotificationStyle.fontFamily
            pixelSize: NotificationStyle.fontSizeSummary
            bold: true
          }
          wrapMode: Text.Wrap
          maximumLineCount: 2
          elide: Text.ElideRight
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
            family: NotificationStyle.fontFamily
            pixelSize: 26
          }
        }
        MouseArea {
          id: copyHover
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.copyToClipboard()
        }
      }
    }
    Text {
      Layout.fillWidth: true
      visible: text !== ""
      text: root.sanitize(root.notification.body)
      color: NotificationStyle.textSecondary
      font {
        family: NotificationStyle.fontFamily
        pixelSize: NotificationStyle.fontSizeBody
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
            color: hovered ? NotificationStyle.buttonBgHover : NotificationStyle.buttonBg
            Text {
              id: actionText
              anchors.centerIn: parent
              text: modelData.text || modelData.identifier
              color: hovered ? NotificationStyle.buttonTextHover : NotificationStyle.buttonText
              font {
                family: NotificationStyle.fontFamily
                pixelSize: NotificationStyle.fontSizeAction
              }
            }
            MouseArea {
              id: actionMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.close(3, modelData)
            }
          }
        }
      }
  }
  Timer {
    interval: root.timeoutMs
    running: root.timeoutMs > 0 && !root.hovered && !root.paused && !root.exiting
    onTriggered: root.close(1)
  }
}
