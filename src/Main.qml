import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Item {
    property bool showPassword: false

    Rectangle {
        color: config.backgroundColor
        anchors.fill: parent
    }

    Image {
        id: backgroundImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        visible: false

        Component.onCompleted: {
            if (typeof config.background === "string" && config.background !== "") {
                backgroundImage.source = config.background;
                backgroundImage.visible = true;
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: 600
        height: 24 + 16 + 48 + 16 + 16 + 48 + 16 + 48 + 16 + 48 + 24 + 16
        color: config.boxColor
        border.width: 2
        border.color: config.borderColor
        radius: 16

        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            Column {
                width: parent.width

                Text {
                    id: lblUsername
                    text: qsTr("Username")
                    color: config.textColor
                    font.pixelSize: 16
                    font.weight: Font.Medium
                }

                Rectangle {
                    width: parent.width
                    height: 48
                    radius: 8
                    color: config.buttonColor
                    border.width: 2
                    border.color: usernameField.focus ? config.accentColor : config.borderColor

                    TextField {
                        id: usernameField
                        text: userModel.lastUser
                        anchors.fill: parent
                        font.pixelSize: 16
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        color: config.secondaryTextColor
                        background: null

                        Keys.onPressed: function (event) {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(usernameField.text, passwordField.text, session.currentIndex);
                                event.accepted = true;
                            }
                        }

                        KeyNavigation.backtab: session
                        KeyNavigation.tab: passwordField
                    }
                }
            }

            Column {

                width: parent.width

                Text {
                    id: lblPassword
                    text: qsTr("Password")
                    color: config.textColor
                    font.pixelSize: 16
                    font.weight: Font.Medium
                }

                Rectangle {
                    width: parent.width
                    height: 48
                    radius: 8
                    color: config.buttonColor
                    border.width: 2
                    border.color: passwordField.focus ? config.accentColor : config.borderColor

                    TextField {
                        id: passwordField
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: eyeIcon.left
                        anchors.rightMargin: 16
                        font.pixelSize: 16
                        color: config.secondaryTextColor
                        echoMode: showPassword ? TextInput.Normal : TextInput.Password
                        background: null

                        Keys.onPressed: function (event) {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(usernameField.text, passwordField.text, session.currentIndex);
                                event.accepted = true;
                            }
                        }

                        KeyNavigation.backtab: usernameField
                        KeyNavigation.tab: loginButton
                    }

                    Image {
                        id: eyeIcon
                        width: 24
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        source: showPassword ? config.eyePath : config.eyeSlashPath
                        fillMode: Image.PreserveAspectFit

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: showPassword = !showPassword
                        }
                    }
                }
            }

            Rectangle {
                id: loginButton
                width: parent.width
                height: 48
                color: config.accentColor
                radius: 24
                opacity: loginMouseArea.containsMouse ? 0.9 : 1

                Text {
                    id: lblLogin
                    anchors.centerIn: parent
                    text: qsTr("Login")
                    color: config.onAccentColor
                    font.pixelSize: 16
                }

                MouseArea {
                    id: loginMouseArea
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        sddm.login(usernameField.text, passwordField.text, session.currentIndex);
                    }

                    KeyNavigation.backtab: usernameField
                    KeyNavigation.tab: session
                }
            }

            Row {
                width: parent.width
                spacing: 8

                Column {
                    width: 600 - 24 * 2 - 8 * 2 - 48 * 2
                    spacing: 4
                    anchors.bottom: parent.bottom

                    ComboBox {
                        id: session
                        width: parent.width
                        height: 48
                        font.pixelSize: 14

                        indicator: Image {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            width: 24
                            height: 24
                            source: config.chevronDownPath
                        }
                        model: sessionModel
                        textRole: "name"
                        currentIndex: sessionModel.lastIndex

                        KeyNavigation.backtab: loginButton
                        KeyNavigation.tab: restartButton

                        background: Rectangle {
                            radius: 24
                            border.width: 2
                            border.color: sessionMouseArea.containsMouse ? config.accentColor : config.borderColor
                            color: config.buttonColor

                            MouseArea {
                                id: sessionMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                propagateComposedEvents: false
                                onClicked: {
                                    mouse.accepted = false;
                                    if (session.popup.opened) {
                                        session.popup.close();
                                    } else {
                                        session.popup.open();
                                    }
                                }
                            }
                        }

                        contentItem: Text {
                            text: session.displayText
                            color: config.textColor
                            font.pixelSize: 16
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            anchors.fill: parent
                            anchors.leftMargin: 16
                        }

                        popup: Popup {
                            y: session.height
                            width: session.width
                            implicitHeight: contentItem.implicitHeight
                            padding: 0

                            contentItem: ListView {
                                implicitHeight: contentHeight
                                model: session.popup.visible ? session.delegateModel : null
                                delegate: session.delegate
                                currentIndex: session.highlightedIndex
                            }

                            background: Rectangle {
                                radius: 8
                                border.width: 2
                                border.color: config.borderColor
                                color: config.buttonColor
                            }
                        }

                        delegate: ItemDelegate {
                            width: session.width
                            highlighted: session.highlightedIndex === index
                            contentItem: Text {
                                text: model.name
                                color: config.textColor
                                font.pixelSize: 16
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: highlighted ? config.borderColor : "transparent"
                                radius: 8

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    propagateComposedEvents: true
                                    onClicked: {
                                        mouse.acepted = false;
                                        session.currentIndex = index;
                                        session.popup.close();
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: 48
                    height: 48
                    color: config.buttonColor
                    border.width: 2
                    border.color: (restartButton.containsMouse || restartButton.activeFocus) ? config.accentColor : config.borderColor
                    radius: 24

                    Image {
                        anchors.centerIn: parent
                        source: config.restartPath
                        width: 32
                        height: 32
                    }

                    MouseArea {
                        id: restartButton
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        activeFocusOnTab: true
                        onClicked: {
                            sddm.reboot();
                        }
                    }
                }

                Rectangle {
                    width: 48
                    height: 48
                    color: config.buttonColor
                    border.width: 2
                    border.color: (powerButton.containsMouse || powerButton.activeFocus) ? config.accentColor : config.borderColor
                    radius: 24

                    Image {
                        anchors.centerIn: parent
                        source: config.shutdownPath
                        width: 32
                        height: 32
                    }

                    MouseArea {
                        id: powerButton
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        activeFocusOnTab: true
                        onClicked: {
                            sddm.poweroff();
                        }

                        KeyNavigation.backtab: restartButton
                        KeyNavigation.tab: usernameField
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        if (usernameField.text == "")
            usernameField.focus = true;
        else
            passwordField.focus = true;
    }
}
