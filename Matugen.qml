pragma Singleton

import Quickshell
import QtQuick

Singleton {
	readonly property var colors: QtObject {

		readonly property color background: "#19120c"
		readonly property color error: "#ffb4ab"
		readonly property color error_container: "#93000a"
		readonly property color inverse_on_surface: "#372f28"
		readonly property color inverse_primary: "#865319"
		readonly property color inverse_surface: "#efe0d5"
		readonly property color on_background: "#efe0d5"
		readonly property color on_error: "#690005"
		readonly property color on_error_container: "#ffdad6"
		readonly property color on_primary: "#4a2800"
		readonly property color on_primary_container: "#ffdcbe"
		readonly property color on_primary_fixed: "#2d1600"
		readonly property color on_primary_fixed_variant: "#6a3c01"
		readonly property color on_secondary: "#402c18"
		readonly property color on_secondary_container: "#ffdcbf"
		readonly property color on_secondary_fixed: "#291806"
		readonly property color on_secondary_fixed_variant: "#59422d"
		readonly property color on_surface: "#efe0d5"
		readonly property color on_surface_variant: "#d5c3b5"
		readonly property color on_tertiary: "#2b3410"
		readonly property color on_tertiary_container: "#dce8b4"
		readonly property color on_tertiary_fixed: "#161e00"
		readonly property color on_tertiary_fixed_variant: "#414b24"
		readonly property color outline: "#9e8e81"
		readonly property color outline_variant: "#51453a"
		readonly property color primary: "#fdb975"
		readonly property color primary_container: "#6a3c01"
		readonly property color primary_fixed: "#ffdcbe"
		readonly property color primary_fixed_dim: "#fdb975"
		readonly property color scrim: "#000000"
		readonly property color secondary: "#e1c1a4"
		readonly property color secondary_container: "#59422d"
		readonly property color secondary_fixed: "#ffdcbf"
		readonly property color secondary_fixed_dim: "#e1c1a4"
		readonly property color shadow: "#000000"
		readonly property color surface: "#19120c"
		readonly property color surface_bright: "#403830"
		readonly property color surface_container: "#261e18"
		readonly property color surface_container_high: "#302822"
		readonly property color surface_container_highest: "#3c332c"
		readonly property color surface_container_low: "#211a14"
		readonly property color surface_container_lowest: "#130d07"
		readonly property color surface_dim: "#19120c"
		readonly property color surface_tint: "#fdb975"

		readonly property color surface_variant: "#51453a"
		readonly property color tertiary: "#c0cc9a"
		readonly property color tertiary_container: "#414b24"
		readonly property color tertiary_fixed: "#dce8b4"
		readonly property color tertiary_fixed_dim: "#c0cc9a"
	}

}