/*
 * LucidOS SDDM Login Theme — Main.qml
 * ============================================================
 * This is the main QML file for the LucidOS SDDM login screen.
 *
 * CURRENT STATUS: Alpha 0.1 Placeholder
 * This file provides a minimal but functional login screen that:
 * - Shows the LucidOS wallpaper as background
 * - Provides a basic login form
 * - Uses the Lucid Glass color palette
 *
 * TODO (Alpha 0.2):
 * - Add glass blur effect on the login card (BackgroundBlur component)
 * - Add LucidOS logo SVG
 * - Add smooth login animations
 * - Add clock widget with proper typography
 * - Add user avatar support
 * - Test on multiple screen resolutions
 *
 * DEVELOPMENT:
 * To test this theme without logging out:
 *   sddm-greeter --test-mode --theme /usr/share/sddm/themes/lucidos
 *
 * Reference: https://github.com/sddm/sddm/wiki/Theming
 * ============================================================
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0

Rectangle {
    id: root

    // Screen dimensions
    width: Screen.width
    height: Screen.height

    // -----------------------------------------------------------------------
    // Background — the Lucid Glass wallpaper
    // -----------------------------------------------------------------------
    Image {
        id: background
        anchors.fill: parent
        source: config.background || "/usr/share/backgrounds/lucidos-wallpaper.svg"
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: false
    }

    // Subtle dark overlay to ensure text readability
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.35
    }

    // -----------------------------------------------------------------------
    // Date and Time — top center
    // -----------------------------------------------------------------------
    ColumnLayout {
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: parent.height * 0.12
        }
        spacing: 8

        Text {
            id: clockTime
            Layout.alignment: Qt.AlignHCenter
            color: "#e0e7ff"
            font.family: "Noto Sans"
            font.pixelSize: 72
            font.weight: Font.Light
            text: Qt.formatTime(new Date(), "hh:mm")
            style: Text.Raised
            styleColor: "#00000066"
        }

        Text {
            id: clockDate
            Layout.alignment: Qt.AlignHCenter
            color: "#94a3b8"
            font.family: "Noto Sans"
            font.pixelSize: 18
            font.weight: Font.Normal
            text: Qt.formatDate(new Date(), "dddd, MMMM d")
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                clockTime.text = Qt.formatTime(new Date(), "hh:mm")
                clockDate.text = Qt.formatDate(new Date(), "dddd, MMMM d")
            }
        }
    }

    // -----------------------------------------------------------------------
    // Login Card — center of screen
    // TODO (Alpha 0.2): Add BackgroundBlur for glass effect
    // -----------------------------------------------------------------------
    Rectangle {
        id: loginCard
        anchors.centerIn: parent
        width: 380
        height: 340

        // Glass-like background
        // TODO (Alpha 0.2): Replace with actual blur using ShaderEffect or
        // BackgroundBlur from Qt Quick Extras
        color: "#0a1128"
        opacity: 0.88
        radius: 20

        // Glass edge border
        border {
            color: "#6366f1"
            width: 1
        }

        // Drop shadow effect (simple)
        layer.enabled: true

        ColumnLayout {
            anchors {
                fill: parent
                margins: 32
            }
            spacing: 16

            // LucidOS title
            Text {
                Layout.alignment: Qt.AlignHCenter
                color: "#e0e7ff"
                font.family: "Noto Sans"
                font.pixelSize: 22
                font.weight: Font.Medium
                text: "LucidOS"
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                color: "#64748b"
                font.family: "Noto Sans"
                font.pixelSize: 12
                text: "Alpha 0.1"
            }

            // Username field
            Rectangle {
                Layout.fillWidth: true
                height: 44
                color: "#111827"
                radius: 8
                border.color: usernameField.activeFocus ? "#6366f1" : "#1e293b"
                border.width: 1

                TextField {
                    id: usernameField
                    anchors {
                        fill: parent
                        margins: 2
                    }
                    placeholderText: "Username"
                    font.family: "Noto Sans"
                    font.pixelSize: 14
                    color: "#e0e7ff"
                    background: Rectangle { color: "transparent" }
                    leftPadding: 12
                    Keys.onTabPressed: passwordField.forceActiveFocus()
                    Keys.onReturnPressed: passwordField.forceActiveFocus()
                }
            }

            // Password field
            Rectangle {
                Layout.fillWidth: true
                height: 44
                color: "#111827"
                radius: 8
                border.color: passwordField.activeFocus ? "#6366f1" : "#1e293b"
                border.width: 1

                TextField {
                    id: passwordField
                    anchors {
                        fill: parent
                        margins: 2
                    }
                    placeholderText: "Password"
                    font.family: "Noto Sans"
                    font.pixelSize: 14
                    color: "#e0e7ff"
                    echoMode: TextInput.Password
                    background: Rectangle { color: "transparent" }
                    leftPadding: 12
                    Keys.onReturnPressed: loginButton.clicked()
                }
            }

            // Login button
            Button {
                id: loginButton
                Layout.fillWidth: true
                height: 44

                contentItem: Text {
                    text: "Sign In"
                    color: "#ffffff"
                    font.family: "Noto Sans"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: loginButton.hovered ? "#4f46e5" : "#3730a3"
                    radius: 8
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                onClicked: {
                    if (usernameField.text !== "" && passwordField.text !== "") {
                        sddm.login(usernameField.text, passwordField.text, sessionCombo.currentIndex)
                    }
                }
            }

            // Error message area
            Text {
                id: errorMessage
                Layout.alignment: Qt.AlignHCenter
                color: "#f87171"
                font.family: "Noto Sans"
                font.pixelSize: 12
                text: ""
                visible: text !== ""
                wrapMode: Text.WordWrap
            }
        }
    }

    // -----------------------------------------------------------------------
    // Session selector — bottom center
    // -----------------------------------------------------------------------
    ComboBox {
        id: sessionCombo
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 32
        }
        width: 200
        model: sessionModel
        textRole: "name"
        currentIndex: sessionModel.lastIndex

        contentItem: Text {
            leftPadding: 8
            text: sessionCombo.displayText
            color: "#94a3b8"
            font.family: "Noto Sans"
            font.pixelSize: 12
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: "#111827"
            opacity: 0.75
            radius: 6
            border.color: "#1e293b"
        }
    }

    // -----------------------------------------------------------------------
    // SDDM signal connections
    // -----------------------------------------------------------------------
    Connections {
        target: sddm

        function onLoginFailed() {
            errorMessage.text = "Incorrect username or password."
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
    }

    // Focus the username field on load
    Component.onCompleted: {
        usernameField.forceActiveFocus()
    }
}
