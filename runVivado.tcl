proc numberOfCPUs {} {
    # Windows 
    global tcl_platform env
    if {$tcl_platform(platform) eq "windows"} {
        return $env(NUMBER_OF_PROCESSORS)
    }

    # Check for sysctl (OSX, BSD)
    set sysctl [auto_execok "sysctl"]
    if {[llength $sysctl]} {
        if {![catch {exec {*}$sysctl -n "hw.ncpu"} cores]} {
            return $cores
        }
    }

    # Linux,
    if {![catch {open "/proc/cpuinfo"} f]} {
        set cores [regexp -all -line {^processor\s} [read $f]]
        close $f
        if {$cores > 0} {
            return $cores
        }
    }

    return 1
}

foreach arg $argv {
	puts $arg
}

set projectName [lindex $argv 0];
set projectLoc [lindex $argv 1];
set board [lindex $argv 2];


if {$board == "zybo"} {
	set board "xc7z010clg400-1"
	set boardPart "digilentinc.com:zybo:part0:1.0"
	set device "xc7z010_1"
} elseif {$board == "minized"} {
	set board "xc7z007sclg225-1"
	set boardPart "em.avnet.com:minized:part0:1.2"
	set device "xc7z007s_1"
}
set_param general.maxThreads [numberOfCPUs]
create_project $projectName $projectLoc/$projectName -part $board
set_property board_part $boardPart [current_project]
set_property target_language VHDL [current_project]

set files [glob -directory $projectLoc/files *]
foreach f $files {
	if {"[file extension $f]" == ".vhd"} {
		puts "[file tail $f] 1"
		import_files -fileset sources_1 -norecurse $f
	} elseif {"[file extension $f]" == ".bd"} {
		puts "[file tail $f] 2"
		import_files -fileset sources_1 -norecurse $f
	} elseif {"[file extension $f]" == ".xdc"} {
		puts "[file tail $f] 3"
		import_files -fileset constrs_1 -norecurse $f
	}
}

update_compile_order -fileset sources_1

puts "start"

launch_runs impl_1 -to_step write_bitstream -jobs [numberOfCPUs]

wait_on_run impl_1
puts "done"
package require fileutil
foreach bitfile [fileutil::findByPattern $projectLoc/$projectName *.bit] {
	puts "[file tail $bitfile]"
    file copy -force -- $bitfile $projectLoc/files/output.bit
}


