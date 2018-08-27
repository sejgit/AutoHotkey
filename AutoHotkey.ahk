; AutoHotkeys.ahk
; shortcut script for windows keys

; 2018 08 15 SeJ init

; Code

#NoEnv ; recommended for performance and compatibility with future autohotkey releases.
#UseHook
#InstallKeybdHook
#SingleInstance force
SetWorkingDir %A_ScriptDir%

SendMode Input

;; global launches
Run "movewindow.ahk" ;; ^+m moving a window to other screen
#!e::Run "launch or switch emacs.ahk"
#!n::Run "Notepad"
#!r::Reload

;; window moves within screen
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

#!Up::
WinGetActiveStats, Title, Width, Height, X, Y
If((Width <> A_ScreenWidth) OR (Height <> A_ScreenHeight)) {
  WinMove, %Title%, , 0, 0, (A_ScreenWidth), (A_ScreenHeight)
}
Return

;; Another way out of ScrollLock
~Esc::SetScrollLockState, off

;; Shift CapsLock for CapsLock usage
~+LControl::CapsLock

;; CapsLock becomes main control key
~CapsLock::LControl

;; Emacs hotkeys
#IfWinActive, ahk_class Emacs
  CapsLock::AppsKey

#IfWinNotActive ahk_class Emacs
  ;;vim navigation with hyper
  ~Tab & h:: Send {Left}
  ~Tab & l:: Send {Right}
  ~Tab & k:: Send {Up}
  ~Tab & j:: Send {Down}

  ;; popular hotkeys with hyper
  ~Tab & c:: Send ^{c}
  ~Tab & v:: Send ^{v}


;; MSYS hotkeys
#IfWinActive, ahk_class mintty
  !c::Send ^{NumpadIns}
  !v::Send +{NumpadIns}

;; Everything else again
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
