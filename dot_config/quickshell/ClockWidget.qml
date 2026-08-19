import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Wayland
PanelWindow {
  id: root
  WlrLayershell.namespace: "r-clock"
  anchors { left: true; bottom: true }
  margins { left: 30; bottom: 30 }
  implicitWidth: 400
  implicitHeight: mainLayout.implicitHeight + 50
  aboveWindows: false
  color: "transparent"
  SystemClock {
    id: systemClock
    precision: SystemClock.Seconds
  }
  Rectangle {
    anchors.fill: parent
    color: Theme.background
    radius: Theme.radius
    border { width: 1; color: Theme.borderColor }
    ColumnLayout {
      id: mainLayout
      anchors { fill: parent; margins: 25 }
      spacing: 15
      ColumnLayout {
        Layout.fillWidth: true
        spacing: 10
        Text {
          Layout.alignment: Qt.AlignHCenter
          text: Qt.formatDateTime(systemClock.date, "hh:mm:ss")
          color: Theme.textPrimary
          font { family: Theme.fontFamily; pixelSize: 32; bold: true }
        }
        Rectangle {
          Layout.fillWidth: true
          height: 1
          color: Theme.borderColor
        }
        Text {
          Layout.alignment: Qt.AlignHCenter
          text: (systemClock.date.getDay() || 7) + "/7 " + Qt.formatDateTime(systemClock.date, "dd.MM.yyyy")
          color: Theme.textPrimary
          font { family: Theme.fontFamily; pixelSize: 24; weight: Font.Medium }
        }
      }
      ColumnLayout {
        Layout.fillWidth: true
        spacing: 8
        DayOfWeekRow {
          locale: grid.locale
          Layout.fillWidth: true
          delegate: Text {
            text: model.shortName
            color: Theme.textSecondary
            font { family: Theme.fontFamily; bold: true }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
          }
        }
        MonthGrid {
          id: grid
          month: systemClock.date.getMonth()
          year: systemClock.date.getFullYear()
          locale: Qt.locale("en_US")
          Layout.fillWidth: true
          delegate: Text {
            text: model.day
            font.family: Theme.fontFamily
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: model.today ? Theme.onAccent : (model.isCurrent ? Theme.textPrimary : Theme.textMuted)
            Rectangle {
              anchors { fill: parent; leftMargin: 6; rightMargin: 6 }
              z: -1
              visible: model.today
              color: Theme.accentNormal
              radius: 4
            }
          }
        }
      }
    }
  }
}
