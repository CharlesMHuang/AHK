#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Menu, Tray, Icon, % A_WinDir "\keys_icon.ico"

SetTitleMatchMode, 2

; FUNCTIONS

backspace_up_instead_of_back()
{
/*
This is defined as a function so that the variable, focused, does
not pollute the global namespace when this script is integrated
into a larger AHK script.
The combination Alt+Up in Windows Explorer goes up one level in the
directory tree. This is what backspace used to do in Windows XP.
ControlGetFocus is issued because if for example the user is in the process
of renaming a file, or is using the search field, then backspace should not
be overridden.
On Windows 10, the following control IDs were found with the Window Spy to
be areas where backspace should be overridden:
DirectUIHWND2
DirectUIHWND3
SysTreeView321
Additionally, the following IDs were identified for controls where backspace
should not be overridden:
Edit1         : Address field is active.
Edit2         : Rename folder/file is active.
DirectUIHWND1 : Search field is active.
*/

ControlGetFocus focused, A
if (focused = "DirectUIHWND2")
or (focused = "DirectUIHWND3")
or (focused = "SysTreeView321")
	SendInput, !{Up}
else
	SendInput, {Backspace}
}



; KEYS DEFINITIONS

#IfWinActive, Function Keys.ahk - Notepad
~^s::
MsgBox, Reloaded
Sleep, 50
Reload
Return
#IfWinActive

Ctrl & Tab::AltTab
Ctrl & `::ShiftAltTab

#if WinActive("ahk_exe explorer.exe") and !WinActive("Task Switching")
^Backspace::Send ^+{Left}{Backspace}

^t:: Send {LWin down}e{LWin up}

$Backspace::
    backspace_up_instead_of_back()
return
#if

F6:: Send {f4}
F8:: Send {Media_Play_Pause}
F9:: Send {Media_Next}
F10:: Send {Volume_Mute}



#if !WinActive("ManicTime")
F11:: Send {Volume_Down}
F12:: Send {Volume_Up}
#if

F3::
	Reload
Return