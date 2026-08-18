pragma Singleton
import Quickshell
import QtQuick
Singleton {
  readonly property string fontFamily: "Adwaita"
  readonly property int cardWidth: 360
  readonly property int cardMargin: 20
  readonly property int cardRadius: 24
  readonly property int cardSpacing: 8
  readonly property int iconSize: 44
  readonly property color background: Qt.rgba(0, 0, 0, 0.5)
  readonly property color borderColor: Qt.rgba(1, 1, 1, 0.2)
  readonly property color textPrimary: "#ffffff"
  readonly property color textSecondary: "#dddddd"
  readonly property color textMuted: "#999999"
  readonly property color buttonBg: Qt.rgba(1, 1, 1, 0.1)
  readonly property color buttonBgHover: Qt.rgba(1, 1, 1, 0.8)
  readonly property color buttonText: "#ffffff"
  readonly property color buttonTextHover: "#111111"
  readonly property color avatarBg: "#ffffff"
  readonly property color avatarText: "#111111"
  readonly property color accentLow: "#5aa9e6"
  readonly property color accentNormal: "#ffffff"
  readonly property color accentCritical: "#ff6b6b"
  readonly property int fontSizeApp: 12
  readonly property int fontSizeSummary: 16
  readonly property int fontSizeBody: 13
  readonly property int fontSizeAction: 13
}
