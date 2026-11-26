import QtQuick

// Root of a delegate for ReorderList (or any ListView that has moveItem(from, to) and commit()).
// Put the visible content inside it. Dragging moves the content under the cursor,
// and the neighbours are swapped when the dragged item passes their center.
Item {
    id: slot

    required property int index

    default property alias content: holder.data

    readonly property var view: ListView.view
    readonly property bool horiz: view ? view.orientation === ListView.Horizontal : true
    readonly property bool dragging: dh.active
    property bool dragEnabled: true

    property real _startPos: 0
    readonly property real dragOffset: dragging
        ? _startPos + (horiz ? dh.translation.x : dh.translation.y) - (horiz ? x : y)
        : 0

    z: dragging ? 100 : 0

    Item {
        id: holder
        width: slot.width
        height: slot.height
        x: slot.horiz ? slot.dragOffset : 0
        y: slot.horiz ? 0 : slot.dragOffset
        scale: slot.dragging ? 1.08 : 1

        Behavior on x { enabled: !slot.dragging; NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on y { enabled: !slot.dragging; NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    DragHandler {
        id: dh
        enabled: slot.dragEnabled
        target: null
        // Do not let a Flickable (dock, settings page) steal the drag
        grabPermissions: PointerHandler.CanTakeOverFromAnything

        onActiveChanged: {
            if (active) {
                slot._startPos = slot.horiz ? slot.x : slot.y
            } else if (slot.view) {
                slot.view.commit()
            }
        }

        onTranslationChanged: {
            if (!active || !slot.view) return
            const v = slot.view
            const size = slot.horiz ? slot.width : slot.height
            const center = slot._startPos + (slot.horiz ? translation.x : translation.y) + size / 2
            const i = slot.index
            const prev = v.itemAtIndex(i - 1)
            const next = v.itemAtIndex(i + 1)

            if (prev) {
                const c = slot.horiz ? prev.x + prev.width / 2 : prev.y + prev.height / 2
                if (center < c) { v.moveItem(i, i - 1); return }
            }
            if (next) {
                const c = slot.horiz ? next.x + next.width / 2 : next.y + next.height / 2
                if (center > c) v.moveItem(i, i + 1)
            }
        }
    }
}
