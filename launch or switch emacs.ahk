; launch or switch emacs

; 2018 08 15 SeJ copy from xah and change for my uses


#NoTrayIcon

If WinExist("ahk_class Emacs")
{
  If WinActive("ahk_class Emacs") {
    WinActivateBottom, ahk_class Emacs
      } Else {
    WinActivate
}
}
Else
{
  Run "C:\msys64\usr\bin\runemacs.exe"
  WinWait ahk_class Emacs
  WinActivate
}
Return

ExitApp
