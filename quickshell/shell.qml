//@ pragma UseQApplication

import Quickshell
import qs.modules.bar
import qs.modules.controlcenter
import qs.modules.settings
import qs.modules.dock
import qs.modules.clock
import qs.modules.wallpaper
import qs.modules.applauncher

ShellRoot {
    Wallpaper {}
    DesktopClock {}
    Bar {}
    Dock {}
    ControlCenter {}
    AppLauncher {}
    SettingsWindow {}
}
