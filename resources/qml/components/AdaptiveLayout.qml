// SPDX-FileCopyrightText: 2021 Nheko Contributors
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import im.nheko 1.0

Container {
    //Component.onCompleted: {
    //    parent.width = Qt.binding(function() { return calculatedWidth; })
    //}

    id: container

    property bool singlePageMode: width < 800
    property int splitterGrabMargin: Nheko.paddingSmall
    property int pageIndex: 0
    property Component handle

    handle: Rectangle {
        z: 3
        color: Nheko.theme.separator
        height: container.height
        width: visible ? 1 : 0
        anchors.right: parent.right
    }

    property Component handleToucharea

    handleToucharea: Item {
        id: splitter

        property int minimumWidth: parent.minimumWidth
        property int maximumWidth: parent.maximumWidth
        property int collapsedWidth: parent.collapsedWidth
        property bool collapsible: parent.collapsible
        property int calculatedWidth: {
            if (!visible)
                return 0;
            else if (container.singlePageMode)
                return container.width;
            else
                return (collapsible && x < minimumWidth) ? collapsedWidth : x;
        }

        //visible: !container.singlePageMode
        enabled: !container.singlePageMode
        height: container.height
        width: 1
        x: parent.preferredWidth
        z: 3

        DragHandler {
            id: dragHandler

            enabled: !container.singlePageMode
            xAxis.enabled: true
            yAxis.enabled: false
            xAxis.minimum: splitter.minimumWidth - 1
            xAxis.maximum: splitter.maximumWidth
            margin: container.splitterGrabMargin
            dragThreshold: 0
            grabPermissions: PointerHandler.CanTakeOverFromAnything | PointerHandler.ApprovesTakeOverByHandlersOfSameType
            cursorShape: Qt.SizeHorCursor
            onActiveChanged: {
                if (!active)
                    splitter.parent.preferredWidth = splitter.x;

            }
        }

        HoverHandler {
            enabled: !container.singlePageMode
            margin: container.splitterGrabMargin
            cursorShape: Qt.SizeHorCursor
        }

    }

    anchors.fill: parent
    Component.onCompleted: {
        for (var i = 0; i < count - 1; i++) {
            let handle_ = handle.createObject(contentChildren[i]);
            let split_ = handleToucharea.createObject(contentChildren[i]);
            contentChildren[i].width = Qt.binding(function() {
                return split_.calculatedWidth;
            });
            contentChildren[i].splitterWidth = Qt.binding(function() {
                return handle_.width;
            });
        }
        contentChildren[count - 1].width = Qt.binding(function() {
            if (container.singlePageMode) {
                return container.width;
            } else {
                var w = container.width;
                for (var i = 0; i < count - 1; i++) {
                    if (contentChildren[i].width)
                        w = w - contentChildren[i].width;

                }
                return w;
            }
        });
        contentChildren[count - 1].splitterWidth = 0;
        for (var i = 0; i < count; i++) {
            contentChildren[i].height = Qt.binding(function() {
                return container.height;
            });
            contentChildren[i].children[0].height = Qt.binding(function() {
                return container.height;
            });
        }
    }

    contentItem: ListView {
        id: view

        model: container.contentModel
        snapMode: ListView.SnapOneItem
        orientation: ListView.Horizontal
        highlightRangeMode: ListView.StrictlyEnforceRange
        interactive: false
        highlightMoveDuration: container.singlePageMode ? 200 : 0
        currentIndex: container.singlePageMode ? container.pageIndex : 0
    }

}
