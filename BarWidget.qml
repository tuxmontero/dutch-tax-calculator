import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
  id: root

  moduleName: "jonathan.dutch-tax-calculator"
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "€"
    tooltipText: "Dutch tax calculator"

    onPressed: {
      if (root.bar && root.bar.shell)
        root.bar.shell.toggle(root.moduleName, "{}")
    }
  }
}
