#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Menu, Tray, Icon, % A_WinDir "\coffee_icon.ico"

SetTitleMatchMode, 2

; FUNCTIONS

show_Mouse(bShow := True) { ; show/hide the mouse cursor
;-------------------------------------------------------------------------------
    ; WINAPI: SystemParametersInfo, CreateCursor, CopyImage, SetSystemCursor
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms724947.aspx
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648385.aspx
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648031.aspx
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648395.aspx
    ;---------------------------------------------------------------------------
    static BlankCursor
    static CursorList := "32512, 32513, 32514, 32515, 32516, 32640, 32641"
        . ",32642, 32643, 32644, 32645, 32646, 32648, 32649, 32650, 32651"
    local ANDmask, XORmask, CursorHandle

    If bShow ; shortcut for showing the mouse cursor

        Return, DllCall("SystemParametersInfo"
            , "UInt", 0x57              ; UINT  uiAction    (SPI_SETCURSORS)
            , "UInt", 0                 ; UINT  uiParam
            , "Ptr",  0                 ; PVOID pvParam
            , "UInt", 0                 ; UINT  fWinIni
            , "Cdecl Int")              ; return BOOL

    If Not BlankCursor { ; create BlankCursor only once
        VarSetCapacity(ANDmask, 32 * 4, 0xFF)
        VarSetCapacity(XORmask, 32 * 4, 0x00)

        BlankCursor := DllCall("CreateCursor"
            , "Ptr", 0                  ; HINSTANCE  hInst
            , "Int", 0                  ; int        xHotSpot
            , "Int", 0                  ; int        yHotSpot
            , "Int", 32                 ; int        nWidth
            , "Int", 32                 ; int        nHeight
            , "Ptr", &ANDmask           ; const VOID *pvANDPlane
            , "Ptr", &XORmask           ; const VOID *pvXORPlane
            , "Cdecl Ptr")              ; return HCURSOR
    }

    ; set all system cursors to blank, each needs a new copy
    Loop, Parse, CursorList, `,, %A_Space%
    {
        CursorHandle := DllCall("CopyImage"
            , "Ptr",  BlankCursor       ; HANDLE hImage
            , "UInt", 2                 ; UINT   uType      (IMAGE_CURSOR)
            , "Int",  0                 ; int    cxDesired
            , "Int",  0                 ; int    cyDesired
            , "UInt", 0                 ; UINT   fuFlags
            , "Cdecl Ptr")              ; return HANDLE

        DllCall("SetSystemCursor"
            , "Ptr",  CursorHandle      ; HCURSOR hcur
            , "UInt", A_Loopfield       ; DWORD   id
            , "Cdecl Int")              ; return BOOL
    }
}

TurnScreenOff()
{
Gui,Color,000000
Gui,-Caption +AlwaysOnTop
Gui,Show,% "X0 Y0 W" A_ScreenWidth " H" A_ScreenHeight
Winget, id, id, A
WinSet, ExStyle, ^0x80,  ahk_id %id% ; 0x80 is WS_EX_TOOLWINDOW
show_Mouse(False)
}






; KEYS DEFINITIONS

#IfWinActive, Productivity.ahk - Notepad
~^s::
MsgBox, Reloaded
Sleep, 50
Reload
Return
#IfWinActive

#if !WinExist("ahk_exe AutoHotkey.exe")
F1::
	TurnScreenOff()
Return
#if

#if WinExist("ahk_exe AutoHotkey.exe")
Esc::
	Gui, Destroy
	show_Mouse()
Return

~Ctrl Up::
WinWaitNotActive, ahk_exe AutoHotkey.exe

Mylabel:
if WinActive("Task Switching")
{
WinWaitNotActive, Task Switching
}
if WinActive("TickTick")
{
Gui,Destroy
WinWaitNotActive, TickTick
redraw := 1
Goto, Mylabel
}
if WinActive("ahk_exe Zoom.exe")
{
Gui,Destroy
WinWaitNotActive, ahk_exe Zoom.exe
redraw := 1
Goto, Mylabel
}
if WinActive("ahk_exe msedge.exe") and WinActive("Messenger")
{
Gui,Destroy
WinWaitNotActive, Messenger
redraw := 1
Goto, Mylabel
}
if WinActive("ahk_exe msedge.exe") and WinActive("The Time Out")
{
Gui,Destroy
WinWaitNotActive, The Time Out
redraw := 1
Goto, Mylabel
}

if (redraw == 1)
{
TurnScreenOff()
redraw := 0
}
else
{
if WinExist("ahk_exe AutoHotkey.exe") {
	; TrayTip,,Black Screen Reactivated,,16
	WinActivate, ahk_exe AutoHotkey.exe
}
}
Return
#if


^SPACE::  Winset, Alwaysontop, , A
;^SPACE::  WinSet, Style, ^0xC00000, A
^[:: Send {RAlt down}{Left}{RAlt up}
^]:: Send {RAlt down}{Right}{RAlt up}
^e:: Send {RCtrl down}{Tab}{RCtrl up}
^q:: Send {Shift down}{RCtrl down}{Tab}{RCtrl up}{Shift up}
~^+e::Return
~^+q::Return
Alt & Tab::Return

#if !WinActive("‎- LiquidText")
+^,::
^,::
	WinMinimize, A
Return

+^.::
^.::
	WinMaximize, A
Return

/*
+^/::
^/::
	WinRestore, A
Return
*/
#if

#if WinActive("‎- LiquidText")
Up::Send {PgUp}
Down::Send {PgDn}
#if

^+f::
  Clipboard := ""
  Send ^c
  WinGet, id_list2, list,,, Program Manager
  ;ClipWait
  Loop, %id_list2%
  {
  current_id := id_list2%A_Index%
  WinGet, this_exe, ProcessName, ahk_id %current_id%
  WinGetTitle, this_title, ahk_id %current_id%
  WinGetClass, this_class, ahk_id %current_id%
  if !InStr(this_title, "Exam") and (this_exe == "msedge.exe") and (this_title != "")
  ;if !InStr(this_title, "Exam") and (this_class == "Chrome_WidgetWin_1")
  {
  ClipWait
  if !WinActive("ahk_id" current_id)
  {
  ;MsgBox, hehehe
  WinActivate, ahk_id %current_id%
  ;MsgBox, %this_title%
  ;WinWaitActive, ahk_id %current_id%
  
  ;MsgBox, %this_class%
  ;MsgBox, %this_exe%
  }
  break
  }
  }
  Sleep, 50
  Send ^t
  ;msgbox, %this_title%
  ;WinWaitNotActive, %this_title% a decision was made not to use this for
  ; sometimes the script would just get stuck and needs a restart
  ; the risk of doing it this way is deemed lower
  Sleep, 100
  ;Send ^v
  SendInput %Clipboard%
  Sleep, 30
  Send {Enter}
Return

^+a::
  Clipboard := ""
  Send ^c
  ;Sleep, 50
  ClipWait
  WinActivate, ahk_class AcrobatSDIWindow
  WinWaitActive, ahk_class AcrobatSDIWindow
  Send ^f
  Sleep, 120
  ;Send ^v
  SendInput %Clipboard%
  Sleep, 50
  Send {Enter}
Return

^+s::
  Send ^c
  Sleep, 50
  WinActivate, ahk_class Chrome_WidgetWin_1
  WinWaitActive, ahk_class Chrome_WidgetWin_1
  Send !f
  Sleep, 350
  Send ^v
  Sleep, 50
  Send {Enter}
Return

^#f:: Send {F11}

LWin & vk07::return
LWin::return


#If WinActive("ahk_class Notepad++") || WinActive("ahk_exe sublime_text.exe")
; Switch to the adjacent tab to the left
^q::
  Send, {XButton1}
Return
; Switch to the adjacent tab to the right
^e::
  Send, {XButton2}
Return
^t:: Send {LCtrl down}n{LCtrl up}
#If


#IfWinActive, ahk_class AcrobatSDIWindow
^Backspace::Send ^+{Left}{Backspace}
+Enter::Send {RCtrl down}{LShift down}g{LShift up}{RCtrl up}
^g::Send ^+n
#IfWinActive


#IfWinActive, ahk_exe ImageGlass.exe
s:: Send {Left}
f:: Send {Right}
WheelUp:: Send {Left}
WheelDown:: Send {Right}
#IfWinActive

/*
#IfWinActive, ahk_exe WINWORD.EXE
*:: Send ×
#IfWinActive
*/

#IfWinActive, ahk_exe msedge.exe
^o::
Send #e
Return
#IfWinActive

#IfWinActive, ahk_exe WINWORD.EXE
*:: Send ×
^\:: Send !=
#IfWinActive

#IfWinActive, Image Occlusion Enhanced
Esc::Return
#IfWinActive

#IfWinActive, ahk_exe TI-Nspire CX CAS Student Software.exe
^Left::Send ^7
^Right::Send ^1
#IfWinActive

/*
F2::
	Reload
Return
*/