package stay_awake

import "core:flags"
import "core:fmt"
import "core:os"

foreign import kernel32 "system:Kernel32.lib"

// https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setthreadexecutionstate
EXECUTION_STATE :: u32

// 	Enables away mode. This value must be specified with ES_CONTINUOUS.

// Away mode should be used only by media-recording and media-distribution applications
// that must perform critical background processing on desktop computers while the computer appears to be sleeping.
ES_AWAYMODE_REQUIRED :: EXECUTION_STATE(0x00000040)

// Informs the system that the state being set should remain in effect until the next call that uses ES_CONTINUOUS
// and one of the other state flags is cleared.
ES_CONTINUOUS :: EXECUTION_STATE(0x80000000)

// Forces the display to be on by resetting the display idle timer.
ES_DISPLAY_REQUIRED :: EXECUTION_STATE(0x00000002)

// Forces the system to be in the working state by resetting the system idle timer.
ES_SYSTEM_REQUIRED :: EXECUTION_STATE(0x00000001)

// This value is not supported. If ES_USER_PRESENT is combined with other esFlags values, the call will fail and
// none of the specified states will be set.
ES_USER_PRESENT :: EXECUTION_STATE(0x00000004)

@(default_calling_convention="system")
foreign kernel32 {
	SetThreadExecutionState :: proc(esFlags: EXECUTION_STATE) -> EXECUTION_STATE ---
}

// Execution State Helpers
ES_CONTINUOUS_BOR_ES_DISPLAY_REQUIRED_BOR_ES_SYSTEM_REQUIRED :: EXECUTION_STATE(ES_CONTINUOUS | ES_DISPLAY_REQUIRED | ES_SYSTEM_REQUIRED)
ES_CONTINUOUS_BOR_ES_SYSTEM_REQUIRED :: EXECUTION_STATE(ES_CONTINUOUS | ES_SYSTEM_REQUIRED)

// Procs
execution_state_as_string :: proc(es: EXECUTION_STATE) -> string {
	switch es {
	case ES_CONTINUOUS:
		return "ES_CONTINUOUS"
	case ES_DISPLAY_REQUIRED:
		return "ES_DISPLAY_REQUIRED"
	case ES_SYSTEM_REQUIRED:
		return "ES_SYSTEM_REQUIRED"
	case ES_CONTINUOUS_BOR_ES_DISPLAY_REQUIRED_BOR_ES_SYSTEM_REQUIRED:
		return "ES_CONTINUOUS | ES_DISPLAY_REQUIRED | ES_SYSTEM_REQUIRED"
	case ES_CONTINUOUS_BOR_ES_SYSTEM_REQUIRED:
		return "ES_CONTINUOUS | ES_SYSTEM_REQUIRED"
	case:
		return "???"
	}
}

update_execution_state :: proc(es: EXECUTION_STATE) -> EXECUTION_STATE {
	return SetThreadExecutionState(es)
}

reset_execution_state :: proc(debug: bool) {
	next_es : EXECUTION_STATE = ES_CONTINUOUS
	next_es_label : string = execution_state_as_string(next_es)
	prev_es : EXECUTION_STATE = update_execution_state(next_es)
	prev_es_label : string = execution_state_as_string(prev_es)

	if debug {
		fmt.println()
		fmt.printfln("%s", colorize(ON_CYAN, "--- DEBUG CONTINUE   ---"))
	    fmt.printfln("next_es is %#v (%#x)", next_es, next_es)
	    fmt.printfln("prev_es is %#v (%#x)", prev_es, prev_es)
		fmt.printfln("%s", colorize(ON_CYAN, "--- DEBUG END        ---"))
	}

	fmt.printfln("\nReset thread execution state:\n    %s ==> %v (%#x)\n      %s ==> %v (%#x)", colorize(RED, "From"), prev_es_label, prev_es, colorize(BLUE, "To"), next_es_label, next_es)
}

// Colors
ESC    :: "\033["
RESET  :: ESC + "0m"

RED    :: ESC + "31m"
GREEN  :: ESC + "32m"
YELLOW :: ESC + "33m"
BLUE   :: ESC + "34m"
PURPLE :: ESC + "35m"
CYAN   :: ESC + "36m"

ON_CYAN :: ESC + "46m"

colorize :: proc(color: string, str: string) -> string {
	return fmt.aprintf("%s%s%s", color, str, RESET)
}


// Main
main :: proc() {
	// CLI
	Options :: struct {
		display: bool `usage:"Keep display on"`,
		debug: bool `args:"hidden" usage:"Print debug info"`,
	}

	opt: Options
	style: flags.Parsing_Style = .Odin
	flags.parse_or_exit(&opt, os.args, style)


	// Initialize
	req_es : EXECUTION_STATE

	if opt.display {
		req_es = ES_DISPLAY_REQUIRED | ES_SYSTEM_REQUIRED
        fmt.printfln("Running in ``%s`` mode ==> the machine will not go to sleep and the display will remain on", colorize(GREEN, "Display"))
	} else {
		req_es = ES_SYSTEM_REQUIRED
        fmt.printfln("Running in ``%s`` mode ==> the machine will not go to sleep", colorize(GREEN, "System"))
	}


	// state to set - must combine with ES_CONTINUOUS
	next_es : EXECUTION_STATE = ES_CONTINUOUS | req_es
	next_es_label : string = execution_state_as_string(next_es)

	// set thread execution state
	prev_es : EXECUTION_STATE = update_execution_state(next_es)
	prev_es_label : string = execution_state_as_string(prev_es)

	if opt.debug {
		fmt.println()
		fmt.printfln("%s", colorize(ON_CYAN, "--- DEBUG START   ---"))
		fmt.printfln("Opt is %#v", opt)
	    fmt.printfln("req_es is %#v (%#x)", req_es, req_es)
	    fmt.printfln("next_es is %#v (%#x)", next_es, next_es)
	    fmt.printfln("prev_es is %#v (%#x)", prev_es, prev_es)
		fmt.printfln("%s", colorize(ON_CYAN, "--- DEBUG END     ---"))
	}

	defer reset_execution_state(opt.debug)

	fmt.printfln("\nSet thread execution state:\n    %s ==> %v (%#x) \n      %s ==> %v (%#x)", colorize(PURPLE, "From"), prev_es_label, prev_es, colorize(CYAN, "To"), next_es_label, next_es)

	buf: [256]byte
	fmt.printf("\nPress ``%s`` key to reset ", colorize(YELLOW, "Enter"))
	_, err := os.read(os.stdin, buf[:])
	if err != nil {
		fmt.eprintln("Error reading: ", err)
		return
	}

}