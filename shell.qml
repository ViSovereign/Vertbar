//@ pragma UseQApplication
import QtQuick
import Quickshell
import qs.vertbar

ShellRoot {
    id: root

    // Vert bar
    Loader {
        active: true
        sourceComponent: Vertbar {}
    }

}