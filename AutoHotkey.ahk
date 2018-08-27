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
  SplashTextOn, 400, 300, "WinMove", MaxWindowLeft `n%Title%`n%Width% %Height%`n%X% %Y%`n%A_ScreenWidth% %A_ScreenHeight%
  WinMove, %Title%, , 0, 0, (A_ScreenWidth/2), (A_ScreenHeight)
  Sleep, 500
  SplashTextOff
  Return

#!Right::
  WinGetActiveStats, Title, Width, Height, X, Y
  SplashTextOn, 400, 300, "WinMove", MaxWindowRight `n%Title%`n%Width% %Height%`n%X% %Y%`n%A_ScreenWidth% %A_ScreenHeight%
  WinMove, %Title%, , (A_ScreenWidth/2), 0, (A_ScreenWidth/2), (A_ScreenHeight)
  Sleep, 500
  SplashTextOff
  Return

#!Up::
  WinGetActiveStats, Title, Width, Height, X, Y
  SplashTextOn, 400, 300, "WinMove", MaxWindow `n%Title%`n%Width% %Height%`n%X% %Y%`n%A_ScreenWidth% %A_ScreenHeight%
  WinMove, %Title%, , 0, 0, (A_ScreenWidth), (A_ScreenHeight)
  Sleep, 500
  SplashTextOff
  Return






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
