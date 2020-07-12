#Persistent
#SingleInstance Force

Init:
    Menu Tray, NoStandard
    Menu Tray, Add, Settings
    Menu Tray, Add, Run on startup, RunOnStartup
    Menu Tray, Standard
    RegRead, sensX, HKEY_CURRENT_USER\Software\Studio Plus One, sensX
    RegRead, sensY, HKEY_CURRENT_USER\Software\Studio Plus One, sensY
    RegRead, runOnStartup, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, Studio Plus One

    If (sensX = "") {
        sensX := 4
    }
    
    If (sensY = "") {
        sensY := 4
    }

    If (runOnStartup = "") {
        runOnStartup := false
    } Else {
        runOnStartup := true
        Menu Tray, Check, Run on startup
        RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, Studio Plus One, %A_ScriptFullPath%
    }
return

RunOnStartup:
    If (runOnStartup) {
        Menu %A_ThisMenu%, UnCheck, %A_ThisMenuItem%
        runOnStartup := false
        RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, Studio Plus One
    } Else {
        Menu %A_ThisMenu%, Check, %A_ThisMenuItem%
        runOnStartup := true
        RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, Studio Plus One, %A_ScriptFullPath%
    }
return

Settings:
    Gui New, -Resize, Settings
    Gui Show, W300 H150
    Gui, Add, Text,, Sensitivity X:
    Gui, Add, Edit, vGuiSensXEdit
    Gui, Add, UpDown, vGuiSensX Range1-50, %sensX%
    Gui, Add, Text,, Sensitivity Y:
    Gui, Add, Edit, vGuiSensYEdit
    Gui, Add, UpDown, vGuiSensY Range1-50, %sensY%
    Gui, Add, Button, Default, OK
return

ButtonOK:
    GuiControlGet, sensX,, GuiSensX
    GuiControlGet, sensY,, GuiSensY
    Gui Hide

    RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Studio Plus One, sensX, %sensX%
    RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Studio Plus One, sensY, %sensY%
return

#IfWinActive ahk_exe Studio One.exe
MButton::
    ; hWnd is used to detect unfocused editor window.
    MouseGetPos lastX, lastY
    MouseGetPos startX, startY, hWnd, hControl
    SetTimer Timer, 10
return

MButton Up::
    SetTimer Timer, Off
return

;; finish this feature
^WheelDown::
    MouseGetPos x, y
    PostMessage, 0x20A, 32 << 16 | 0x4 | 0x8, y << 16 | x ,, A
return

^WheelUp::
    MouseGetPos x, y
    PostMessage, 0x20A, -32 << 16 | 0x4 | 0x8, y << 16 | x ,, A
return

^+WheelDown::
    MouseGetPos x, y
    PostMessage, 0x20A, 32 << 16 | 0x8, y << 16 | x ,, A
return

^+WheelUp::
    MouseGetPos x, y
    PostMessage, 0x20A, -32 << 16 | 0x8, y << 16 | x ,, A
return

PostMW(hWnd, delta, sft, x, y)
{
    
    CoordMode, Mouse, Screen
    Modifiers := 0x4*sft 
    PostMessage, 0x20A, delta << 16 | Modifiers, y << 16 | x ,, ahk_id %hWnd%
}

Timer:
    MouseGetPos curX, curY
    dX := (curX - lastX)
    dY := (curY - lastY)
    scrollX := dX * sensX
    scrollY := dY * sensY

    If (dX != 0) {
        PostMW(hWnd, scrollX, true, startX, startY)
    }
    If (dY != 0) {
        PostMW(hWnd, scrollY, false, startX, startY)
    }

    lastX := curX
    lastY := curY
return
