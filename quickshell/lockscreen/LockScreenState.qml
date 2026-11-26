pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import QtQuick

Singleton {
    id: root

    property bool locked: false
    readonly property bool authenticating: pam.active
    property bool authFailed: false
    property string pendingPassword: ""

    PamContext {
        id: pam

        config: "login"

        onPamMessage: {
            console.log("[lock] PAM message:", pam.message,
                        "| isError:", pam.messageIsError,
                        "| responseRequired:", pam.responseRequired)

            if (pam.responseRequired)
                pam.respond(root.pendingPassword)
        }

        onCompleted: (result) => {
            console.log("[lock] PAM completed, result:", result,
                        "(Success =", PamResult.Success + ")")
            root.pendingPassword = ""

            if (result === PamResult.Success)
                root.unlock()
            else
                root.authFailed = true
        }

        onError: (error) => {
            console.log("[lock] PAM error:", error)
            root.pendingPassword = ""
            root.authFailed = true
        }
    }

    function lock() {
        if (root.locked) return
        authFailed = false
        root.locked = true
    }

    function unlock() {
        authFailed = false
        pendingPassword = ""
        root.locked = false
    }

    function authenticate(password) {
        if (pam.active) return

        authFailed = false
        pendingPassword = password
        pam.start()
    }

    IpcHandler {
        target: "lockscreen"

        function lock(): void { root.lock() }
        function isLocked(): bool { return root.locked }
    }
}
