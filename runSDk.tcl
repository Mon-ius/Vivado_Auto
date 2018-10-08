
set projectLoc [lindex $argv 0]
set board [lindex $argv 1]


# Set SDK workspace
setws $projectLoc/SDK

# Create a HW project
createhw -name hw1 -hwspec $projectLoc/SDK/design_1_wrapper.hdf

# Create a BSP project
createbsp -name bsp1 -hwproject hw1 -proc ps7_cortexa9_0 -os standalone

# Create application project
createapp -name hello -hwproject hw1 -bsp bsp1 -proc ps7_cortexa9_0 -os standalone -lang C -app {Hello World}

# Build all projects
projects -build

if {$board == "minized"} {
	package require fileutil
	foreach bitfile [fileutil::findByPattern $projectLoc *.mss] {
		set fp [open $bitfile "r"]
		set data [read $fp]
		close $fp
		set replaced_string [string map {"ps7_uart_0" "ps7_uart_1"} $data]
		puts $replaced_string
		
		set fp [open $bitfile "w+"]
		puts $fp $replaced_string 
	}
}

 