#include <Array.au3>
#include <File.au3>
Opt ("TrayAutoPause",0)
$aOfficePath = "C:\Program Files (x86)\Microsoft Office\Office15\" ; Path to Office folder in Programm Files\Microsoft Office



$FolderWithFiles = ""&@WorkingDir&"\files"
HotKeySet("{NUMPAD1}","Pause")
HotKeySet("{NUMPAD2}","Start")

Global $GT=0


Func Pause()

   While 1
	  If $GT == 1 Then
		 ConsoleWrite("$GT=" & $GT & @CRLF)
		 $GT = 0
		 ExitLoop(1)
	  EndIf
   WEnd

EndFunc

Func Start()
   $GT=1
EndFunc


Func GetListOfFileName($FolderWithFiles)
   ; Get files list b5y folder path
   ; $FolderWithFiles - is a String of path to filder
Local $FileList
$FileList = _FileListToArray(""&$FolderWithFiles&"") ;get array of file name
_ArrayDelete($FileList, 0)    ;first name is clear
Return($FileList)
EndFunc

Func GetProgrammByFormat($Format)
   ; $Format - is a String, like "docx"
   ; Return string with name of programm for open file with this format
   Local $aProgram
Switch $Format
	Case ".docx"
      $aProgram = "WINWORD.EXE"
   Case ".rtf"
      $aProgram = "WINWORD.EXE"
	Case ".xlsx"
		$aProgram = "EXCEL.EXE"
	Case ".pptx"
		$aProgram = "POWERPNT.EXE"
EndSwitch
   Return $aProgram
EndFunc

Func GetScreenShot($ScrPath)
; $ScrName- is a name with format
; ---Example:---
; $ScrPath = "name.jpeg"
; GetScreenShot($ScrName)
Local $aBit
If @OSArch == "X86" Then       ;get the architecture type of the currently running operating system
 $aBit = "32"
Else
 $aBit = "64"
EndIf
 RunWait(""&@WorkingDir&"\tools"&$aBit&"\nircmd.exe savescreenshot """&@WorkingDir&"\screenshots\"&$ScrPath&"""""" ) ;get screen
EndFunc

Func GetFormatByPath($Path)
   ; Path - is a String(filename or file path) WITH FORMAT
   ; Return only format like string
Return(_PathSplit($Path, "","","","")[4])
EndFunc

Func DeleteAndCreateScrDir()
     ;DirRemove(""&@WorkingDir&"\screenshots", 1)
     DirCreate(""&@WorkingDir&"\screenshots")
     DirCreate(""&@WorkingDir&"\screenshots\errors")
     DirCreate(""&@WorkingDir&"\screenshots\error_name_part")
     DirCreate(""&@WorkingDir&"\screenshots\error_safe_mode")
EndFunc

Func WaitErrors()

   Local $ErrorsTitle = CreateArrayOfErrorsTitle()
   Local $ErrorsText = CreateArrayOfErrorsText()


	  For $errorelement In $ErrorsTitle
		 For $textelement In $ErrorsText
			If WinExists($errorelement,"в безопасном режиме") Then
				   ;ConsoleWrite("SAFE_MODE")
				   ControlClick($errorelement,"в безопасном режиме","&Да")
				   Return("Eror_safe_mode")
		   ElseIf WinExists($errorelement, $textelement) OR WinExists("[CLASS:bosa_sdm_msword]") OR WinExists("Поиск обновлений слайдов") Then
			if WinExists ($errorelement,"хотите открыть его") Then
			   ControlClick("Microsoft Excel","хотите открыть его","Д&а")
			   if WinExists("Введите пароль") Then
				  Return "0"
			   EndIf
			EndIf
			       Return("Error")
			ElseIf  WinExists("Microsoft Excel","Выполнить попытку восстановления?") Then
			       ControlClick("Microsoft Excel","Ошибка в части содержимого в книге","Д&а")
					 Sleep(200)
				  if WinExists("Исправления в","Удаленные записи") Then
					 WinClose("Исправления в")
			        Return("Error_name_part")
				  EndIf
			EndIf
		 Next
	  Next
   ;Next

ConsoleWrite("RETURN ZERO")

return ("0")
EndFunc

Func CreateArrayOfErrorsTitle()
   Local $TitleErrors[3]
  $TitleErrors[0] = "Microsoft Excel"
  $TitleErrors[1] = "Microsoft Word"
  $TitleErrors[2] = "Microsoft PowerPoint"
  Return($TitleErrors)
EndFunc

Func CreateArrayOfErrorsText()
  Local $TextErrors[10]
  $TextErrors[0] = "ошибка"
  $TextErrors[1] = "внимательны"
  $TextErrors[2] = "При последней попытке открыть файл"
  ;Excel
  $TextErrors[3] = "в части содержимого в книге"
  ;Power Point
  $TextErrors[4] = "проблему с содержимым"
  $TextErrors[5] = "Не удается открыть файл"
  $TextErrors[6] = "не удалось прочитать"
  ;WORD
  $TextErrors[7] = "расстановки переносов"
  $TextErrors[8] = "создан в предварительной версии"
  $TextErrors[9] = "Не удалось открыть файл"

  Return($TextErrors)
EndFunc

Func FileAndScreenshotMove($ErrorMessage, $String, $element)

		 $str ="\"

	 Switch $ErrorMessage
	 Case "Error"
		 $str = "\screenshots\errors\"
     Case "Error_name_part"
		 $str = "\screenshots\error_name_part\"
	 Case "Eror_safe_mode"
		 $str ="\screenshots\error_safe_mode\"
	 EndSwitch

	  ;ConsoleWrite("FileAndScreenshotMove $ErrorMessage=" & $ErrorMessage & @CRLF)
	  ;ConsoleWrite("$String="&$String)
	  ;ConsoleWrite("$element="&$element)

		 if $ErrorMessage <> "0" Then
			ConsoleWrite("FM" & @CRLF)
			ConsoleWrite("str="& $str & @CRLF)
			ConsoleWrite($ErrorMessage & @CRLF)
			ConsoleWrite(""&@WorkingDir&"\screenshots\" & $element & ".jpeg" & @CRLF )
			ConsoleWrite(""&@WorkingDir & $str & $element & ".jpeg" & @CRLF)

		   FileMove( $String, ""&@WorkingDir&$str&$element&"", 1)
		   ;ConsoleWrite("FileMove=" & FileMove( $String, ""&@WorkingDir&$str&$element&"", 1))
		   FileMove( ""&@WorkingDir&"\screenshots\"&$element&".jpeg", ""&@WorkingDir&$str&$element&".jpeg", 1)
		 EndIf
EndFunc

Func OpenAllFilesAndTakeScreenshot()
DeleteAndCreateScrDir()
Local $FileNames
Local $ErrorMessage
$FileNames = GetListOfFileName($FolderWithFiles)

;ConsoleWrite($FileNames)

For $element In $FileNames
   If StringInStr($element, "~$") == 0 Then
		 $String = ""&$FolderWithFiles&"\"&$element&""  ;path to file
		 Run(""&$aOfficePath&""&GetProgrammByFormat(GetFormatByPath($element))&" """&$String&"""", "", @SW_SHOWMAXIMIZED) ;open file by path


		 if(GetFormatByPath($element) == ".pptx" OR GetFormatByPath($element) == ".xlsx") Then
			ConsoleWrite(".xlsx")
			Sleep(4000)
		 Else
			Sleep(2000)
		 EndIF

		 $ErrorMessage = WaitErrors()

		 Sleep(500)

		 If ($ErrorMessage == "0" OR $ErrorMessage == "Error" OR $ErrorMessage == "Error_name_part" OR $ErrorMessage == "Eror_safe_mode" OR WinWaitActive($element) ) Then
			ConsoleWrite(@CRLF & "$ErrorMessage in OpenAll=" & $ErrorMessage & @CRLF)
			ConsoleWrite("$element=" & $element & @CRLF)
			GetScreenShot(""&$element&".jpeg")
			Sleep(500)
		 EndIf

         ProcessClose(GetProgrammByFormat(GetFormatByPath($element))) ;close program

		 Sleep(1000)

		 FileAndScreenshotMove($ErrorMessage, $String, $element)

	  ;ElseIf StringInStr($element, "~$") == 1  Then
	  ;FileDelete(""&$FolderWithFiles& "\" & $element&"")
	  EndIf

   Next
EndFunc

OpenAllFilesAndTakeScreenshot()


#comments-start
ERRORS

WORD

При расстановке переносов
создан в предварительной версии
Серьезная ошибка
Не удалось открыть файл

НЕ УСПЕЛИ ОТКРЫТЬСЯ(на скриншоте виодно открытие)
#comments-end
