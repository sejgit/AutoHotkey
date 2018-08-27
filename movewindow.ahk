#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;Move selected window to swap monitor
^![::
   DetectHiddenWindows, Off
  WindArray := {}
SysGet, OutputVar, MonitorCount
  ; This will be the GUI name
  WinName = Move Window Between Monitor
  WinGet, OpenWindow, List

  If OutputVar = 1
    {
     MsgBox, 4112, No multimonitor connected, Minimum 2 display unit is required to execute this script. Please connect to another display., 4
     Exit
    }
If !WinExist(WinName)
{
 Gui,+AlwaysOnTop
 Gui, Font, s11, Arial
 Gui, Add, DropDownList, gShowToolTip x7 y9 w260 vWindowMove,Pick a Window||
 Gui, Add, Button, x282 y8 w50 h28 gPosChoice, Swap
}
Else
{
 Gui, Destroy
 Gui,+AlwaysOnTop
 Gui, Font, s11, Arial
 Gui, Add, DropDownList, gShowToolTip x7 y9 w260 vWindowMove,Pick a Window||
 Gui, Add, Button, x282 y8 w50 h28 gPosChoice, Swap
}

Loop, %OpenWindow%
{

 id := OpenWindow%A_Index%
 WinGetTitle Title, ahk_id %id%
 WinGet, style, style, ahk_id %id%
 WinGet, ClsID, ID, ahk_id %id%

 If !(style & 0xC00000) or (title = "")
 continue
 WinGetClass class, ahk_id %id%
 If (class = "ApplicationFrameWindow")
 {
  WinGetText, text, ahk_id %id%
  If (text = "")
  {
   WinGet, style, style, ahk_id %id%
   If !(style = "0xB4CF0000")	 ; the window isn't minimized
   continue
  }
 }

 GuiControl,,WindowMove, %Title%
 WindArray.Insert(Title, ClsID)


}

Gui, Show,  h45 w345, %WinName%
  hwnd:=WinExist(WinName)
  Return

  ShowToolTip:
  Gui,Submit,NoHide
  ;remove any previous tooltip
  GoSub RemoveToolTip

  if (InStr(WindowMove, "Pick a Window", true) = 0 and WindowMove!="")
    {

     ControlGetPos,x,y,w,h,ComboBox1,ahk_id %hwnd%

     ToolTip %WindowMove%,x,y+h,10

     SetTimer,RemoveToolTip,-3000
    }
Return


PosChoice:
Gui, Submit, NoHide
  if (InStr(WindowMove, "Pick a Window", true) = 0 and WindowMove!="")
    {
     ;return Associative array value
    IDValue:= WindArray[WindowMove]

     if WinExist("ahk_id " IDValue)
     {
      ;WinActivate, Ahk_ID %IDValue%
      MoveIt(IDValue)
     }
     else
       {

	GoSub ^![ ; Recall it again to refresh status

		 }
     GoSub RemoveToolTip
    }
Return

RemoveToolTip:
ToolTip,,,,10
  Return

  GuiClose:
  Gui, Destroy
  Return

  /*
  Function to move a given window from 1 monitor to another.
  use WinGet, activeWindowHwnd, ID, A or ahk_class Notepad++
  MoveIt(activeWindowHwnd)
    */

    MoveIt(activeWindowHwnd)
{
 ; Count number of active monitor.
 SysGet, OutputVar, MonitorCount

 if OutputVar > 1
 {

  ;WinGet, activeWindowHwnd, ID, A
  WinActivate, Ahk_ID %activeWindowHwnd%
  activeMonitorHwnd := MDMF_FromHWND(activeWindowHwnd)
  monitors := MDMF_Enum()

  monitorHwndList := []
  For currentMonitorHwnd, info In monitors
  monitorHwndList[A_Index] := currentMonitorHwnd

  nextMonitorHwnd := ""
  For currentMonitorHwnd, info In monitors
  If (currentMonitorHwnd = activeMonitorHwnd)
  nextMonitorHwnd := (A_Index=monitorHwndList.MaxIndex() ? monitorHwndList[1] : monitorHwndList[A_Index+1])

  activeMonitor := MDMF_GetInfo(activeMonitorHwnd)
  nextMonitor := MDMF_GetInfo(nextMonitorHwnd)

  WinGetPos, x, y, w, h, ahk_id %activeWindowHwnd%
  activeWindow := {Left:x, Top:y, Right:x+w, Bottom:y+h}

 relativePercPos := {}
 relativePercPos.Left := (activeWindow.Left-activeMonitor.Left)/(activeMonitor.Right-activeMonitor.Left)
  relativePercPos.Top := (activeWindow.Top-activeMonitor.Top)/(activeMonitor.Bottom-activeMonitor.Top)
  relativePercPos.Right := (activeWindow.Right-activeMonitor.Left)/(activeMonitor.Right-activeMonitor.Left)
  relativePercPos.Bottom := (activeWindow.Bottom-activeMonitor.Top)/(activeMonitor.Bottom-activeMonitor.Top)

  ;MsgBox % activeWindow.Top "`n" activeWindow.Left " - " activeWindow.Right "`n" activeWindow.Bottom
  ;MsgBox % relativePercPos.Top*100 "`n" relativePercPos.Left*100 " - " relativePercPos.Right*100 "`n" relativePercPos.Bottom*100

  activeWindowNewPos := {}
 activeWindowNewPos.Left := nextMonitor.Left+(nextMonitor.Right-nextMonitor.Left)*relativePercPos.Left
  activeWindowNewPos.Top := nextMonitor.Top+(nextMonitor.Bottom-nextMonitor.Top)*relativePercPos.Top

  WinMove, Ahk_ID %activeWindowHwnd%,, activeWindowNewPos.Left, activeWindowNewPos.Top
 }

 winmaximize, Ahk_ID %activeWindowHwnd%
 Return
}
;Credits to "just me" for the following code:

; ======================================================================================================================
; Multiple Display Monitors Functions -> msdn.microsoft.com/en-us/library/dd145072(v=vs.85).aspx =======================
; ======================================================================================================================
; Enumerates display monitors and returns an object containing the properties of all monitors or the specified monitor.
; ======================================================================================================================
MDMF_Enum(HMON := "") {
		       Static EnumProc := RegisterCallback("MDMF_EnumProc")
		       Static Monitors := {}
		       If (HMON = "") ; new enumeration
		       Monitors := {}
		       If (Monitors.MaxIndex() = "") ; enumerate
		       If !DllCall("User32.dll\EnumDisplayMonitors", "Ptr", 0, "Ptr", 0, "Ptr", EnumProc, "Ptr", &Monitors, "UInt")
		       Return False
		       Return (HMON = "") ? Monitors : Monitors.HasKey(HMON) ? Monitors[HMON] : False
}
; ======================================================================================================================
;  Callback function that is called by the MDMF_Enum function.
; ======================================================================================================================
MDMF_EnumProc(HMON, HDC, PRECT, ObjectAddr) {
 Monitors := Object(ObjectAddr)
 Monitors[HMON] := MDMF_GetInfo(HMON)
 Return True
}
; ======================================================================================================================
;  Retrieves the display monitor that has the largest area of intersection with a specified window.
; ======================================================================================================================
MDMF_FromHWND(HWND) {
		     Return DllCall("User32.dll\MonitorFromWindow", "Ptr", HWND, "UInt", 0, "UPtr")
}
; ======================================================================================================================
; Retrieves the display monitor that contains a specified point.
; If either X or Y is empty, the function will use the current cursor position for this value.
; ======================================================================================================================
MDMF_FromPoint(X := "", Y := "") {
				  VarSetCapacity(PT, 8, 0)
				  If (X = "") || (Y = "") {
							   DllCall("User32.dll\GetCursorPos", "Ptr", &PT)
							   If (X = "")
							   X := NumGet(PT, 0, "Int")
							   If (Y = "")
							   Y := NumGet(PT, 4, "Int")
				  }
				  Return DllCall("User32.dll\MonitorFromPoint", "Int64", (X & 0xFFFFFFFF) | (Y << 32), "UInt", 0, "UPtr")
}
; ======================================================================================================================
; Retrieves the display monitor that has the largest area of intersection with a specified rectangle.
; Parameters are consistent with the common AHK definition of a rectangle, which is X, Y, W, H instead of
; Left, Top, Right, Bottom.
; ======================================================================================================================
MDMF_FromRect(X, Y, W, H) {
			   VarSetCapacity(RC, 16, 0)
			   NumPut(X, RC, 0, "Int"), NumPut(Y, RC, 4, Int), NumPut(X + W, RC, 8, "Int"), NumPut(Y + H, RC, 12, "Int")
			   Return DllCall("User32.dll\MonitorFromRect", "Ptr", &RC, "UInt", 0, "UPtr")
}
; ======================================================================================================================
; Retrieves information about a display monitor.
; ======================================================================================================================
MDMF_GetInfo(HMON) {
		    NumPut(VarSetCapacity(MIEX, 40 + (32 << !!A_IsUnicode)), MIEX, 0, "UInt")
		    If DllCall("User32.dll\GetMonitorInfo", "Ptr", HMON, "Ptr", &MIEX) {
		    MonName := StrGet(&MIEX + 40, 32)    ; CCHDEVICENAME = 32
		    MonNum := RegExReplace(MonName, ".*(\d+)$", "$1")
		    Return {Name:      (Name := StrGet(&MIEX + 40, 32))
			    , Num:       RegExReplace(Name, ".*(\d+)$", "$1")
			    , Left:      NumGet(MIEX, 4, "Int")    ; display rectangle
			    , Top:       NumGet(MIEX, 8, "Int")    ; "
			    , Right:     NumGet(MIEX, 12, "Int")   ; "
			    , Bottom:    NumGet(MIEX, 16, "Int")   ; "
			    , WALeft:    NumGet(MIEX, 20, "Int")   ; work area
			    , WATop:     NumGet(MIEX, 24, "Int")   ; "
			    , WARight:   NumGet(MIEX, 28, "Int")   ; "
			    , WABottom:  NumGet(MIEX, 32, "Int")   ; "
			    , Primary:   NumGet(MIEX, 36, "UInt")} ; contains a non-zero value for the primary monitor.
		    }
		    Return False
}
