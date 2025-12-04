// LoaderToggle.qml - helper for LazyLoader visibility control
import QtQuick
import Quickshell

QtObject {
    id: root

    /** The LazyLoader to manage. */
    required property LazyLoader loader

    /** Whether to activate the loader automatically before showing/toggling. */
    property bool autoLoad: true

    function ensureLoaded() {
        if (!autoLoad)
            return loader.item !== null;

        if (!loader.item)
            loader.active = true;
        return loader.item !== null;
    }

    function toggle(forceVisible) {
        if (!ensureLoaded())
            return;

        if (forceVisible === true) {
            loader.item.visible = true;
            return;
        }

        if (forceVisible === false) {
            loader.item.visible = false;
            return;
        }

        loader.item.visible = !loader.item.visible;
    }

    function show() {
        toggle(true);
    }

    function hide() {
        toggle(false);
    }
}
