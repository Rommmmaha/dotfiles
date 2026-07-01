import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Wayland
ShellRoot {
  SystemClock {
    id: systemClock
    precision: SystemClock.Seconds
  }
  PanelWindow {
    id: mainWindow
    WlrLayershell.namespace: "r-clock"
    anchors { left: true; bottom: true }
    margins { left: 30; bottom: 30 }
    implicitWidth: 400
    implicitHeight: mainLayout.implicitHeight + 50
    aboveWindows: false
    color: "transparent"
    Rectangle {
      anchors.fill: parent
      color: Qt.rgba(0, 0, 0, 0.4)
      radius: 24
      border { width: 1; color: Qt.rgba(1, 1, 1, 0.2) }
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
            color: "#fff"
            font { family: "Adwaita"; pixelSize: 32; bold: true }
          }
          Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(1, 1, 1, 0.2)
          }
          Text {
            Layout.alignment: Qt.AlignHCenter
            text: (systemClock.date.getDay() || 7) + "/7 " + Qt.formatDateTime(systemClock.date, "dd.MM.yyyy")
            color: "#fff"
            font { family: "Adwaita"; pixelSize: 24; weight: Font.Medium }
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
              color: "#ddd"
              font { family: "Adwaita"; bold: true }
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
              font.family: "Adwaita"
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
              color: model.today ? "#000" : (model.isCurrent ? "#fff" : "#999")
              Rectangle {
                anchors { fill: parent; leftMargin: 6; rightMargin: 6 }
                z: -1
                visible: model.today
                color: "#fff"
                radius: 4
              }
            }
          }
        }
      }
    }
  }
}