import QtQuick
import QtQuick.Controls
import qs.Commons as Commons
import qs.Ui as Ui
import "Cars.js" as Catalog

Ui.Panel {
    id: root
    moduleName: "krysto.most-wanted"
    ipcTarget: "krysto.most-wanted"
    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight
    property int selectedIndex: 33
    property bool driving: true
    property bool slideshow: false
    property string query: ""
    property string category: "all"
    readonly property var car: Catalog.cars[selectedIndex]
    readonly property var filtered: Catalog.cars.map(function(c,i) { return i }).filter(function(i) {
        var c=Catalog.cars[i];
        return (root.category === "all" || c.group === root.category) && (c.name+" "+(c.driver||"")).toLowerCase().indexOf(root.query.toLowerCase()) >= 0;
    })
    function advance(delta) {
        if (!filtered.length) return;
        var pos=filtered.indexOf(selectedIndex);
        selectedIndex=filtered[(pos+delta+filtered.length)%filtered.length];
    }
    function chooseFirst() { if (filtered.length && filtered.indexOf(selectedIndex)<0) selectedIndex=filtered[0] }
    onFilteredChanged: chooseFirst()
    Commons.Translations { id: strings; directory: Qt.resolvedUrl("i18n") }
    Timer {
        interval: 5000; repeat: true
        running: root.slideshow && root.opened
        onTriggered: root.advance(1)
    }
    Ui.WidgetButton {
        id: button
        anchors.fill: parent
        bar: root.bar
        fixedWidth: vertical ? -1 : Commons.Style.space(88)
        fixedHeight: vertical ? Commons.Style.space(40) : -1
        hasVisualContent: true
        labelVisible: false
        tooltipText: "NFS · Most Wanted 2005"
        onPressed: function(button) {
            if (button === Qt.RightButton) root.advance(1);
            else if (button === Qt.MiddleButton) root.driving=!root.driving;
            else root.toggle();
        }
        onWheelMoved: function(delta) { root.advance(delta < 0 ? 1 : -1) }
        Road {
            anchors.centerIn: parent
            width: parent.width - Commons.Style.space(6)
            height: Math.min(parent.height - Commons.Style.space(2), Commons.Style.space(28))
            car: root.car; driving: root.driving; miniature: true
        }
    }
    Ui.KeyboardPanel {
        id: panel
        owner: root; anchorItem: button; bar: root.bar; open: root.opened
        focusTarget: panel.loadedContent
        contentWidth: Commons.Style.space(460)
        contentHeight: Commons.Style.space(640)
        content: FocusScope {
            anchors.fill: parent
            Keys.onPressed: function(event) {
                var key=Commons.Util.readingKey(event);
                if(key===Qt.Key_Escape) { root.close(); event.accepted=true }
                else if(key===Qt.Key_Left) { root.advance(-1); event.accepted=true }
                else if(key===Qt.Key_Right) { root.advance(1); event.accepted=true }
                else if(key===Qt.Key_Space && !search.activeFocus) { root.driving=!root.driving; event.accepted=true }
            }
            Column {
                anchors.fill: parent
                spacing: Commons.Style.space(10)
                Text {
                    text: "MOST WANTED / 2005"; textFormat: Text.PlainText
                    color: Commons.Color.accent; font.family: Commons.Style.font.family
                    font.pixelSize: Commons.Style.space(22); font.bold: true
                }
                Road {
                    width: parent.width; height: Commons.Style.space(190)
                    car: root.car; driving: root.driving && root.opened
                    MouseArea {
                        anchors.fill: parent
                        onWheel: function(wheel) { root.advance(wheel.angleDelta.y < 0 ? 1 : -1); wheel.accepted=true }
                    }
                }
                Row {
                    width: parent.width; spacing: Commons.Style.space(8)
                    Ui.Button {
                        text: Commons.I18n.rightToLeft ? "›" : "‹"; focusable: true
                        onClicked: root.advance(-1)
                    }
                    Column {
                        width: parent.width - Commons.Style.space(100)
                        Text {
                            width: parent.width; text: root.car.name; textFormat: Text.PlainText
                            color: Commons.Color.foreground; font.family: Commons.Style.font.family
                            font.pixelSize: Commons.Style.space(17); font.bold: true; elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Text {
                            width: parent.width
                            text: root.car.driver ? "#"+Commons.I18n.formatNumber(root.car.rank)+" · "+root.car.driver : strings.t(root.car.group)
                            textFormat: Text.PlainText; color: Commons.Color.muted
                            font.family: Commons.Style.font.family; font.pixelSize: Commons.Style.space(12)
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                    Ui.Button {
                        text: Commons.I18n.rightToLeft ? "‹" : "›"; focusable: true
                        onClicked: root.advance(1)
                    }
                }
                Row {
                    spacing: Commons.Style.space(6)
                    Ui.Button { text: strings.t(root.driving ? "pause" : "drive"); onClicked: root.driving=!root.driving; focusable: true }
                    Ui.Button { text: strings.t("auto"); selected: root.slideshow; onClicked: root.slideshow=!root.slideshow; focusable: true }
                    Ui.Button { text: strings.t("random"); onClicked: { if(root.filtered.length) root.selectedIndex=root.filtered[Math.floor(Math.random()*root.filtered.length)] } focusable: true }
                }
                Row {
                    spacing: Commons.Style.space(4)
                    Repeater {
                        model: ["all", "career", "bonus", "blacklist"]
                        Ui.Button {
                            required property string modelData
                            text: strings.t(modelData); selected: root.category===modelData
                            onClicked: root.category=modelData; focusable: true
                            horizontalPadding: Commons.Style.space(8)
                        }
                    }
                }
                Rectangle {
                    width: parent.width; height: Commons.Style.space(32)
                    color: Commons.Color.background; radius: Commons.Style.space(5)
                    border.color: search.activeFocus ? Commons.Color.accent : Commons.Color.muted
                    TextInput {
                        id: search
                        anchors.fill: parent; anchors.margins: Commons.Style.space(7)
                        color: Commons.Color.foreground; font.family: Commons.Style.font.family
                        font.pixelSize: Commons.Style.space(13); selectByMouse: true; clip: true
                        onTextChanged: root.query=text
                        Text {
                            visible: !search.text && !search.activeFocus; text: strings.t("search")
                            textFormat: Text.PlainText; color: Commons.Color.muted; font: search.font
                        }
                    }
                }
                ListView {
                    id: list
                    width: parent.width; height: Commons.Style.space(120)
                    model: root.filtered; spacing: Commons.Style.space(2); clip: true
                    currentIndex: root.filtered.indexOf(root.selectedIndex)
                    onCurrentIndexChanged: if(currentIndex >= 0) positionViewAtIndex(currentIndex,ListView.Contain)
                    ScrollBar.vertical: ScrollBar {}
                    delegate: Ui.Button {
                        required property int modelData
                        width: list.width - Commons.Style.space(12)
                        text: Catalog.cars[modelData].name + (Catalog.cars[modelData].driver ? " · "+Catalog.cars[modelData].driver : "")
                        selected: root.selectedIndex===modelData; leftAlign: true
                        fontSize: Commons.Style.space(12); verticalPadding: Commons.Style.space(4)
                        onClicked: root.selectedIndex=modelData
                    }
                    Text {
                        anchors.centerIn: parent; visible: root.filtered.length===0
                        text: strings.t("empty"); textFormat: Text.PlainText
                        color: Commons.Color.muted; font.family: Commons.Style.font.family
                    }
                }
                Text {
                    text: strings.t("hint").arg(Commons.I18n.formatNumber(root.filtered.length))
                    textFormat: Text.PlainText; color: Commons.Color.muted
                    font.family: Commons.Style.font.family; font.pixelSize: Commons.Style.space(10)
                }
            }
        }
    }
}
