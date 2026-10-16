import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui
import "TaxModel.js" as TaxModel

Item {
  id: root

  property var shell: null
  property var manifest: null
  property bool opened: false
  property string salaryText: "60000"
  property string period: "year"
  property int taxYear: 2026
  property bool addHoliday: false
  property bool older: false
  property bool socialSecurity: true
  property bool ruling: false
  property string rulingType: "normal"

  readonly property var estimate: TaxModel.calculate({
    income: salaryText,
    period: period,
    year: taxYear,
    addHoliday: addHoliday,
    older: older,
    socialSecurity: socialSecurity,
    ruling: ruling,
    rulingType: rulingType
  })

  function formatEuro(amount) {
    var cents = Math.round(Math.abs(Number(amount) || 0) * 100)
    var euros = Math.floor(cents / 100).toString()
    var decimal = (cents % 100).toString()
    while (decimal.length < 2) decimal = "0" + decimal
    euros = euros.replace(/\B(?=(\d{3})+(?!\d))/g, ".")
    return (amount < 0 ? "−" : "") + "€ " + euros + "," + decimal
  }

  function formatPercent(value) {
    return (Math.round((Number(value) || 0) * 1000) / 10).toString().replace(".", ",") + "%"
  }

  function open(payloadJson) {
    var payload = {}
    try {
      payload = JSON.parse(payloadJson || "{}") || {}
    } catch (e) {
      payload = {}
    }
    if (payload.income !== undefined) salaryText = String(payload.income)
    if (payload.year === 2025 || payload.year === 2026) taxYear = payload.year
    opened = true
    Qt.callLater(function() { salaryField.forceActiveFocus() })
  }

  function close() {
    opened = false
  }

  function dismiss() {
    if (shell && typeof shell.hide === "function")
      shell.hide("jonathan.dutch-tax-calculator")
    else
      close()
  }

  PanelWindow {
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "jonathan-dutch-tax-calculator"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Rectangle {
      anchors.fill: parent
      color: Qt.rgba(0, 0, 0, 0.54)

      MouseArea {
        anchors.fill: parent
        onClicked: root.dismiss()
      }
    }

    Item {
      id: keyCatcher
      anchors.fill: parent
      focus: root.opened
      Keys.onEscapePressed: root.dismiss()

      Rectangle {
        anchors.fill: parent
        color: "transparent"
        MouseArea { anchors.fill: parent; onClicked: {} }
      }

      BorderSurface {
        id: card
        width: Math.min(Style.space(560), Math.max(Style.space(320), keyCatcher.width - Style.space(36)))
        height: Math.min(Style.space(760), Math.max(Style.space(420), keyCatcher.height - Style.space(36)))
        anchors.centerIn: parent
        color: Color.popups.background
        borderSpec: Border.surfaceSpec("popups", "border", Color.popups.border, Math.max(1, Style.space(2)))
        radius: Style.cornerRadius

        MouseArea { anchors.fill: parent; onClicked: {} }

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: Style.space(24)
          spacing: Style.space(14)

          RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
              Layout.fillWidth: true
              spacing: Style.space(2)
              Text {
                text: "DUTCH TAX ESTIMATE"
                color: Color.accent
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: true
                font.letterSpacing: 1.6
              }
              Text {
                text: "What you take home"
                color: Color.popups.text
                font.family: Style.font.family
                font.pixelSize: Style.font.title
                font.bold: true
              }
            }

            Button {
              text: "×"
              tooltipText: "Close"
              foreground: Color.popups.text
              fontSize: Style.font.title
              onClicked: root.dismiss()
            }
          }

          Flickable {
            id: scroller
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: form.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
              id: form
              width: scroller.width
              spacing: Style.space(14)

              RowLayout {
                Layout.fillWidth: true
                Text {
                  text: "Tax year"
                  color: Color.popups.text
                  font.family: Style.font.family
                  font.pixelSize: Style.font.body
                  Layout.fillWidth: true
                }
                Dropdown {
                  value: String(root.taxYear)
                  options: ["2025", "2026"]
                  showLabel: false
                  implicitWidth: Style.space(130)
                  onChanged: root.taxYear = Number(value)
                }
              }

              ColumnLayout {
                Layout.fillWidth: true
                spacing: Style.space(5)
                Text {
                  text: "Gross salary before tax"
                  color: Color.popups.text
                  font.family: Style.font.family
                  font.pixelSize: Style.font.body
                  font.bold: true
                }
                RowLayout {
                  Layout.fillWidth: true
                  TextField {
                    id: salaryField
                    Layout.fillWidth: true
                    text: root.salaryText
                    placeholderText: "e.g. 60000"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    onTextChanged: root.salaryText = text
                  }
                  Text {
                    text: "EUR"
                    color: Qt.darker(Color.popups.text, 1.3)
                    font.family: Style.font.family
                    font.pixelSize: Style.font.bodySmall
                  }
                }
                RowLayout {
                  spacing: Style.space(6)
                  Button {
                    text: "Per year"
                    selected: root.period === "year"
                    foreground: Color.popups.text
                    onClicked: root.period = "year"
                  }
                  Button {
                    text: "Per month"
                    selected: root.period === "month"
                    foreground: Color.popups.text
                    onClicked: root.period = "month"
                  }
                  Text {
                    Layout.fillWidth: true
                    text: root.period === "month" ? "× 12 for annual estimate" : "Annual gross amount"
                    color: Qt.darker(Color.popups.text, 1.5)
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    wrapMode: Text.Wrap
                  }
                }
              }

              Toggle {
                Layout.fillWidth: true
                label: "Add 8% holiday pay"
                description: "Adds vakantiegeld to the taxable gross salary."
                checked: root.addHoliday
                onClicked: root.addHoliday = !root.addHoliday
              }

              Toggle {
                Layout.fillWidth: true
                label: "Dutch social insurance applies"
                description: "AOW, Anw and Wlz contributions are included."
                checked: root.socialSecurity
                onClicked: root.socialSecurity = !root.socialSecurity
              }

              Toggle {
                Layout.fillWidth: true
                label: "At AOW age all year"
                description: "Use only if you are at AOW age for the full tax year."
                checked: root.older
                onClicked: root.older = !root.older
              }

              Toggle {
                Layout.fillWidth: true
                label: "30% ruling applies"
                description: "Only enable if you have an approved ruling."
                checked: root.ruling
                onClicked: root.ruling = !root.ruling
              }

              Dropdown {
                visible: root.ruling
                Layout.fillWidth: true
                label: "Ruling category"
                value: root.rulingType
                options: [
                  { value: "normal", label: "Standard" },
                  { value: "young", label: "Under 30 with qualifying Master's degree" },
                  { value: "research", label: "Scientific researcher" }
                ]
                onChanged: root.rulingType = value
              }

              BorderSurface {
                Layout.fillWidth: true
                implicitHeight: summary.implicitHeight + Style.space(28)
                color: Style.normalFillFor(Color.popups.text, Color.accent)
                borderSpec: Border.controlSpec("normal", Color.popups.text, Color.accent)
                radius: Style.cornerRadius

                ColumnLayout {
                  id: summary
                  anchors.fill: parent
                  anchors.margins: Style.space(16)
                  spacing: Style.space(8)

                  Text {
                    text: root.estimate.valid ? root.formatEuro(root.estimate.netMonth) : "—"
                    color: Color.accent
                    font.family: Style.font.family
                    font.pixelSize: Style.font.display
                    font.bold: true
                  }
                  Text {
                    text: "ESTIMATED NET PER MONTH · " + root.taxYear
                    color: Qt.darker(Color.popups.text, 1.3)
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    font.bold: true
                    font.letterSpacing: 0.8
                  }
                  Text {
                    visible: root.estimate.valid
                    text: root.formatEuro(root.estimate.netYear) + " net per year  ·  "
                      + root.formatPercent(root.estimate.effectiveRate) + " effective tax"
                    color: Color.popups.text
                    font.family: Style.font.family
                    font.pixelSize: Style.font.bodySmall
                    wrapMode: Text.Wrap
                  }
                  Text {
                    visible: !root.estimate.valid
                    text: root.estimate.error || "Enter a valid salary to calculate."
                    color: Color.urgent
                    font.family: Style.font.family
                    font.pixelSize: Style.font.bodySmall
                  }
                }
              }

              PanelSeparator { foreground: Color.popups.text }

              Text {
                text: "ANNUAL BREAKDOWN"
                color: Qt.darker(Color.popups.text, 1.35)
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: true
                font.letterSpacing: 1.2
              }

              ColumnLayout {
                Layout.fillWidth: true
                spacing: Style.space(7)
                visible: root.estimate.valid

                RowLayout {
                  Layout.fillWidth: true
                  Text { text: "Gross salary"; color: Color.popups.text; font.family: Style.font.family; font.pixelSize: Style.font.bodySmall; Layout.fillWidth: true }
                  Text { text: root.formatEuro(root.estimate.grossYear); color: Color.popups.text; font.family: Style.font.family; font.pixelSize: Style.font.bodySmall }
                }
                RowLayout {
                  Layout.fillWidth: true
                  Text { text: "Payroll tax + social insurance"; color: Color.popups.text; font.family: Style.font.family; font.pixelSize: Style.font.bodySmall; Layout.fillWidth: true }
                  Text { text: "−" + root.formatEuro(root.estimate.taxBeforeCredits); color: Color.popups.text; font.family: Style.font.family; font.pixelSize: Style.font.bodySmall }
                }
                RowLayout {
                  Layout.fillWidth: true
                  Text { text: "General tax credit"; color: Color.popups.text; font.family: Style.font.family; font.pixelSize: Style.font.bodySmall; Layout.fillWidth: true }
                  Text { text: root.formatEuro(root.estimate.generalCredit); color: Color.popups.text; font.family: Style.font.family; font.pixelSize: Style.font.bodySmall }
                }
                RowLayout {
                  Layout.fillWidth: true
                  Text { text: "Labour tax credit"; color: Color.popups.text; font.family: Style.font.family; font.pixelSize: Style.font.bodySmall; Layout.fillWidth: true }
                  Text { text: root.formatEuro(root.estimate.laborCredit); color: Color.popups.text; font.family: Style.font.family; font.pixelSize: Style.font.bodySmall }
                }
                RowLayout {
                  Layout.fillWidth: true
                  visible: root.estimate.elderCredit > 0
                  Text { text: "Senior tax credit"; color: Color.popups.text; font.family: Style.font.family; font.pixelSize: Style.font.bodySmall; Layout.fillWidth: true }
                  Text { text: root.formatEuro(root.estimate.elderCredit); color: Color.popups.text; font.family: Style.font.family; font.pixelSize: Style.font.bodySmall }
                }
                RowLayout {
                  Layout.fillWidth: true
                  Text { text: "Estimated tax due"; color: Color.popups.text; font.family: Style.font.family; font.pixelSize: Style.font.bodySmall; font.bold: true; Layout.fillWidth: true }
                  Text { text: root.formatEuro(root.estimate.taxAfterCredits); color: Color.popups.text; font.family: Style.font.family; font.pixelSize: Style.font.bodySmall; font.bold: true }
                }
              }

              Text {
                Layout.fillWidth: true
                text: "Estimate for Box 1 salary income. Pension deductions, other income, Box 2/3, personal deductions and partial-year residence are not included."
                color: Qt.darker(Color.popups.text, 1.5)
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                wrapMode: Text.WordWrap
              }

              Button {
                text: "Open thetax.nl for a detailed calculation ↗"
                foreground: Color.popups.text
                onClicked: Qt.openUrlExternally("https://thetax.nl")
              }
            }
          }
        }
      }
    }
  }
}
