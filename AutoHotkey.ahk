; AutoHotkeys.ahk
; shortcut script for windows keys

/*
Change Logs

2018 08 15 SeJ init
2018 08 28 add window to deskop
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
#!e::Run "launch or switch emacs.ahk"
#!n::Run "Notepad"
#!r::Reload

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

; window to full screen size (not doing a maximize)
#!Up::
WinGetActiveStats, Title, Width, Height, X, Y
If((Width <> A_ScreenWidth) OR (Height <> A_ScreenHeight)) {
  WinMove, %Title%, , 0, 0, (A_ScreenWidth), (A_ScreenHeight)
}
Return

/*
Other Global HotKeys
*/
; Another way out of ScrollLock
~Esc::SetScrollLockState, off

; Shift CapsLock for CapsLock usage
~+LControl::CapsLock

; CapsLock becomes main control key
~CapsLock::LControl


   /*
   Emacs hotkeys
   */
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


/*
MSYS hotkeys
*/
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


/*
Move Window to other virtual Desktop
*/

#!1::
MoveWindowToDesktop(0)
return

#!2::
MoveWindowToDesktop(1)
return

#!3::
MoveWindowToDesktop(2)
return

#!4::
MoveWindowToDesktop(3)
return


MoveWindowToDesktop(next)
{
 ; Launch Win+Tab and open context menu
 Send, #{Tab}
 Sleep, 150
 Send, {AppsKey}

 ; Get context menu info
 WinWait, ahk_class #32768
 SendMessage, 0x1E1, 0, 0
 hMenu := ErrorLevel
 sContents := GetMenu(hMenu)
 StringSplit, itemArray, sContents, `,

 ; Determine what is the current desktop as well as the total number of desktops
 total := 1
 current := 0
 Loop, %itemArray0%
 {
 element := itemArray%A_Index%
 StringSplit, wordArray, element, %A_Space%
 lastWord := wordArray%wordArray0%
 if (lastWord+0)
   {
    if (lastWord > total and current = 0)
		  current := lastWord - 1
		      total := total + 1
	}
 else if (current > 0)
   break
     }
 if (current = 0)
 current := total

     if ((current = total and next = 1) or (current = 1 and next = 0))
       {
	Sleep, 75
	SendInput, {Esc 2}
	return
     }

     else
       {

	; Send input to select desired desktop
       desired := current - 2 + next
	SendInput, {Down}
	SendInput, {Right}
	SendInput, {Down %desired%}
	SendInput, {Enter}

	; Go to desired desktop
	SendInput, {Enter}
	if (next = 1)
	     Send, ^#{Right}
	   else
	     Send, ^#{Left}

     }
   return
}


GetMenu(hMenu)
{
 Loop, % DllCall("GetMenuItemCount", "Uint", hMenu)
 {
 idx := A_Index - 1
 idn := DllCall("GetMenuItemID", "Uint", hMenu, "int", idx)
 nSize++ := DllCall("GetMenuString", "Uint", hMenu, "int", idx, "Uint", 0, "int", 0, "Uint", 0x400)
 nSize := (nSize * (A_IsUnicode ? 2 : 1))
 VarSetCapacity(sString, nSize)
 DllCall("GetMenuString", "Uint", hMenu, "int", idx, "str", sString, "int", nSize, "Uint", 0x400)   ;MF_BYPOSITION
 If !sString
 sString := "---------------------------------------"
 ;sContents .= idx . " : " . idn . A_Tab . A_Tab . sString . "`n"
 sContents .= sString . ","
 If (idn = -1) && (hSubMenu := DllCall("GetSubMenu", "Uint", hMenu, "int", idx))
 sContents .= GetMenu(hSubMenu)
 }
 Return   sContents
}
