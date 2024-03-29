; AutoHotkeys.ahk
; shortcut script for windows keys

/*
Change Logs

2018 08 15 SeJ init
2018 08 28 add window to deskop
2018 10 02 fix caps lock issue & set-up Emacs modifiers
2022 06 13 alternative 2/3 window because Teams does not behave
2023 01 26 add tab + n, p, d as proxies for Emacs movement
*/

/*
Reminder of the Autokey basics
Symbol	Description
#	Win (Windows logo key)
!	Alt
^	Control
+	Shift
&	An ampersand may be used between any two keys or mouse buttons to combine them into a custom hotkey
*/


/*
Script Set-ups
*/

#NoEnv ; recommended for performance and compatibility with future autohotkey releases.
#UseHook
#InstallKeybdHook
#SingleInstance, force
SetBatchLines, -1
     SetWorkingDir %A_ScriptDir%
     SendMode Input


     /*
     Global Launches
     */
     ;Run "movewindow.ahk" ;; ^+m moving a window to other screen
     ;run from start "windows10desktopmanager\windows10.ahk" ;; windows10desktopmanager
     #!e::Run "launch or switch emacs.ahk"
     #!n::Run "Notepad"
     #!r::Reload

     /*
     Other Global HotKeys
     */
     ; CapsLock for LeftControl usage
     SetCapsLockState, AlwaysOff
     +CapsLock::CapsLock
     CapsLock::LControl
     /*
     Emacs hotkeys
     */

#IfWinActive, ahk_class Emacs
     ;; left Control to appskey to be used as super modifier
     LControl::Appskey
     ;; RAlt to numlock to be used as Alt modifier (leave LAlt as meta)
     RAlt::NumLock

#IfWinNotActive ahk_class Emacs
     ;; normalize LControl to be control outside of Emacs
     LControl::LControl
     RAlt::RAlt
	
;; vim navigation with hyper
~Tab & h:: Send {Left}
~Tab & l:: Send {Right}
~Tab & k:: Send {Up}
~Tab & j:: Send {Down}

;; Emacs type navigation
~Tab & n:: Send {Down}
~Tab & p:: Send {UP}
~Tab & d:: Send {Delete}

;; popular hotkeys with hyper
~Tab & c:: Send ^{c}
~Tab & v:: Send ^{v}

/*
MSYS hotkeys
*/
#IfWinActive, ahk_class mintty
!c::Send ^{NumpadIns}
!v::Send +{NumpadIns}

; Everything else again

#IfWinActive
;; remap tab to hyper
;; if tab is tapped, do tab
Alt & Tab::AltTab
;+Tab::Send {Tab}
Tab Up::SetScrollLockState, Off

#If GetKeyState("Tab", "P")
    scrollstate:=GetKeyState("ScrollLock", "T")
        If(scrollstate = 0)
        Send {ScrollLock}

#If
Tab::
Sleep, 150
    tabdown:=GetKeyState("Tab", "P")
    If(tabdown)
{
    Send {ScrollLock}
}
else
{
    Send {Tab}
}
return


/*
window moves within a screen
*/
; cycle on the left hand side
#!Left::
WinGetActiveStats, Title, Width, Height, X, Y
    If((X <> 0) OR (Y <> 0) OR ((Width <> A_ScreenWidth/2) AND (Width <> A_ScreenWidth*2/5)) OR (Height <> A_ScreenHeight)) {
    WinRestore, %Title%
    WinMove, %Title%, , 0, 0, (A_ScreenWidth/2), (A_ScreenHeight)
} else If((X = 0) AND (Y = 0) AND (Width = A_ScreenWidth/2) AND (Height = A_ScreenHeight)) {
        WinMove, %Title%, , 0, 0, (A_ScreenWidth*2/5), (A_ScreenHeight)
    } else {
	  WinMove, %Title%, , 0, 0, (A_ScreenWidth*3/5), (A_ScreenHeight)
}
Return

; 2/3 left hand side directly
#!+Left::
WinGetActiveStats, Title, Width, Height, X, Y
WinRestore, %Title%
WinMove, %Title%, , 0, 0, (A_ScreenWidth*3/5), (A_ScreenHeight)
Return

; cycle on the right hand side
#!Right::
WinGetActiveStats, Title, Width, Height, X, Y
    If(((X <> A_ScreenWidth/2) AND (X <> A_ScreenWidth*3/5)) OR (Y <> 0) OR ((Width <> A_ScreenWidth/2) AND (Width <> A_ScreenWidth*2/5)) OR (Height <> A_ScreenHeight)) {
    WinRestore, %Title%
    WinMove, %Title%, , (A_ScreenWidth/2), 0, (A_ScreenWidth/2), (A_ScreenHeight)
}
else If((X = A_ScreenWidth/2) AND (Y = 0) AND (Width = A_ScreenWidth/2) AND (Height = A_ScreenHeight)) {
        WinMove, %Title%, , (A_ScreenWidth*3/5), 0, (A_ScreenWidth*2/5), (A_ScreenHeight)
    } else {
    WinMove, %Title%, , (A_ScreenWidth*2/5), 0, (A_ScreenWidth*3/5), (A_ScreenHeight)
}
Return

; 2/3 right hand side directly
#!+Right::
WinGetActiveStats, Title, Width, Height, X, Y
WinRestore, %Title%
WinMove, %Title%, , (A_ScreenWidth*2/5), 0, (A_ScreenWidth*3/5), (A_ScreenHeight)
Return

; window to full screen size (not doing a maximize)
#!Up::
WinGetActiveStats, Title, Width, Height, X, Y
    If((Width <> A_ScreenWidth) OR (Height <> A_ScreenHeight)) {
    WinMove, %Title%, , 0, 0, (A_ScreenWidth), (A_ScreenHeight)
}
Return
