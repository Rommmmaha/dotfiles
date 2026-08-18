import Quickshell
import Quickshell.Services.Notifications
ShellRoot {
  NotificationServer {
    id: notifications
    bodySupported: true
    imageSupported: true
    actionsSupported: true
    onNotification: n => {
      n.tracked = true
    }
  }
  ClockWidget {}
  NotificationOverlay {
    notifications: notifications
  }
}
