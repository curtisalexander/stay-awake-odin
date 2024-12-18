[![stay-awake-odin](https://github.com/curtisalexander/stay-awake-odin/actions/workflows/ci.yml/badge.svg)](https://github.com/curtisalexander/stay-awake-odin/actions/workflows/ci.yml)

# stay-awake-odin
Keep a Windows machine awake

## Get
Executable binaries for Windows may be found at the [Releases](https://github.com/curtisalexander/stay-awake-odin/releases) page.

## Usage
The executable `stay-awake.exe` is intended to be run in a terminal in order to keep one's Windows machine awake.

There are two modes one may choose from:
- **System** [Default] &rarr; the machine will not go to sleep but the display could turn off
- **Display** &rarr; the machine will not go to sleep and the display will remain on

### System
The simplest use case is to run the executable without any switches.

```pwsh
stay-awake.exe
```

This will prevent the machine from going to sleep and will await the user pressing the `Enter` key within the terminal before resetting the machine state.

### Display
To keep the machine awake and prevent the display from turning off, utilize the `-display` switch.

```pwsh
stay-awake.exe -display
```

This will prevent the machine from going to sleep (while also keeping the display on) and will await the user pressing the `Enter` key within the terminal before resetting the machine state.

> :memo: As noted in the [Win32 documentation](https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setthreadexecutionstate), use of the `SetThreadExecutionState` function (which is the Win32 function called by `stay-awake.exe`) does **_not_** prevent one from putting their computer to sleep by either closing the lid on their laptop or pressing the power button.  In addition, the screen saver may still execute.

### Help
Result of running `stay-awake.exe -help`

```
Usage:
        stay-awake.exe [-display]
Flags:
        -display  | Keep display on
```

## Testing
Testing - either automated or manual - utilizes the [powercfg](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options) command line tool to validate the execution state set via [SetThreadExecutionState](https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setthreadexecutionstate).

### Automated
Run the [test.bat](test.bat) file which utilizes the [Odin test runner](https://odin-lang.org/docs/testing/).  This _assumes_ that [`sudo`](https://learn.microsoft.com/en-us/windows/sudo/) is setup and available for use from the command line.

```pwsh
.\test.bat
```

The `test.bat` file runs tests with 1 thread.  If tests were run in parallel (the default) then the thread execution state could be overwritten by a different thread and tests would no longer be valid.

Finally, note that there are 5 tests and _each_ test requires elevated (admin) privileges; thus the user will be prompted to run `sudo` 5 times.

### Manual
Run the executable `stay-awake.exe`.  Open PowerShell (or a command prompt) with elevated (admin) privileges.  Execute the following.

```pwsh
powercfg -requests
```

The execution states will be listed along with any programs that have made calls to `SetThreadExecutionState`.  Manually validate execution states are set as expected.

## Compile
First, ensure [Odin](https://odin-lang.org/) has been [installed](https://odin-lang.org/docs/install/) and is available on one's [`PATH`](https://duckduckgo.com/?q=add+to+path+windows&ia=web).  Clone this repository and then run the [build.bat](build.bat) file.
```
git clone https://github.com/curtisalexander/stay-awake-odin.git
cd stay-awake-odin
.\build.bat
```

The resulting executable will be `stay-awake.exe`.

## GitHub Actions
Below is the rough `git tag` dance to delete and/or add tags to [trigger GitHub Actions](https://github.com/curtisalexander/stay-awake-odin/blob/main/.github/workflows/ci.yml#L7-L10).

```pwsh
# delete local tag
git tag --delete v0.1.0

# delete remote tag
git push origin --delete v0.1.0

# add and commit local changes
git add .
git commit -m "commit msg"

# push local changes to remote
git push

# add local tag
git tag -a v0.1.0 -m "v0.1.0"

# push local tag to remote
git push origin --tags
```

## Win32 Docs
The application utilizes [SetThreadExecutionState](https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setthreadexecutionstate) from the [Win32 API](https://docs.microsoft.com/en-us/windows/win32/).

## Prior Implementations
- [`C#`](https://github.com/curtisalexander/stay-awake-cs)
- [`PowerShell`](https://github.com/curtisalexander/stay-awake-ps)
- [`Rust v1`](https://github.com/curtisalexander/stay-awake-rs)
    - Loads `kernel32.dll` and performs a [transmute](https://doc.rust-lang.org/stable/std/mem/fn.transmute.html) to get the function [SetThreadExecutionState](https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setthreadexecutionstate)
- [`Rust v2`](https://github.com/curtisalexander/stay-awake2)
    - Makes use of the [windows crate](https://crates.io/crates/windows) rather than [transmute](https://doc.rust-lang.org/stable/std/mem/fn.transmute.html) as is done in [stay-awake-rs](https://github.com/curtisalexander/stay-awake-rs)

## Alternate Tools
- [Microsoft PowerToys](https://docs.microsoft.com/en-us/windows/powertoys/) includes the [Awake](https://docs.microsoft.com/en-us/windows/powertoys/awake) utility
    - It also utilizes [SetThreadExectionState](https://github.com/microsoft/PowerToys/blob/main/src/modules/awake/Awake/Core/Manager.cs#L108) to keep a Windows machine awake
