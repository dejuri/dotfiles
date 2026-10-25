pragma Singleton
import Quickshell

// Relative paths for resources
Singleton {
    readonly property string wallpapers: Quickshell.shellPath("wallpaper")
    readonly property string icons: Quickshell.shellPath("icons")
    readonly property string fonts: Quickshell.shellPath("fonts")
    readonly property string images: Quickshell.shellPath("images")
    readonly property string scripts: Quickshell.shellPath("scripts")

    function fileUrl(path) { return "file://" + path }
    function wallpaper(name) { return fileUrl(wallpapers + "/" + name) }
    function icon(name) { return fileUrl(icons + "/" + name + ".svg") }
    function font(name) { return fileUrl(fonts + "/" + name + ".ttf") }
    function image(name) { return fileUrl(images + "/" + name) }
    function script(name) { return scripts + "/" + name }
}
