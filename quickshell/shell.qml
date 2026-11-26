//@ pragma UseQApplication

import Quickshell
import qs.modules.bar
import qs.modules.controlcenter
import qs.modules.settings
import qs.modules.dock
import qs.modules.clock
import qs.modules.wallpaper
import qs.modules.applauncher
import qs.modules.volumemenu
import qs.modules.osd
import qs.lockscreen

ShellRoot {
    Wallpaper {}
    DesktopClock {}
    Bar {}
    Dock {}
    ControlCenter {}
    VolumeMenu {}
    VolumeOsd {}
    AppLauncher {}
    SettingsWindow {}
    LockScreen {}
}
