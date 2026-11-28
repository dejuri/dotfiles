import QtQuick

// A ListView over a list of string keys. Delegates should use ReorderSlot as root
// (it gets `key` and `index` from the model). After a drag `reordered(keys)` is emitted.
ListView {
    id: root

    property var keys: []
    property bool _dirty: false
    signal reordered(var keys)

    interactive: false
    cacheBuffer: 4000

    model: store
    ListModel { id: store }

    function current() {
        const r = []
        for (let i = 0; i < store.count; i++) r.push(store.get(i).key)
        return r
    }

    function sync() {
        const want = root.keys ?? []
        const have = current()
        if (want.length === have.length && want.every((k, i) => k === have[i])) return

        // One item added or removed: change only that one, so it can be animated
        if (want.length === have.length + 1) {
            let i = 0
            while (i < have.length && have[i] === want[i]) i++
            if (want.slice(i + 1).every((k, j) => k === have[i + j])) {
                store.insert(i, { key: want[i] })
                return
            }
        } else if (have.length === want.length + 1) {
            let i = 0
            while (i < want.length && have[i] === want[i]) i++
            if (have.slice(i + 1).every((k, j) => k === want[i + j])) {
                store.remove(i)
                return
            }
        }

        store.clear()
        want.forEach(k => store.append({ key: k }))
    }

    onKeysChanged: sync()
    Component.onCompleted: sync()

    function moveItem(from, to) {
        if (from === to || to < 0 || to >= store.count) return
        store.move(from, to, 1)
        _dirty = true
    }

    function commit() {
        if (!_dirty) return
        _dirty = false
        reordered(current())
    }

    move: Transition { NumberAnimation { properties: "x,y"; duration: 150; easing.type: Easing.OutCubic } }
    displaced: Transition { NumberAnimation { properties: "x,y"; duration: 150; easing.type: Easing.OutCubic } }

    add: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 220 }
            NumberAnimation { property: "scale"; from: 0.5; to: 1; duration: 280; easing.type: Easing.OutBack }
        }
    }
    remove: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; to: 0; duration: 160 }
            NumberAnimation { property: "scale"; to: 0.5; duration: 180; easing.type: Easing.InCubic }
        }
    }
}
