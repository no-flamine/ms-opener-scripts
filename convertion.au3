#include <Array.au3>
#include <File.au3>
Opt ("TrayAutoPause",0)
$aMainPath = "c:\" ; Path to autotests folder

$aDirfile = _FileListToArray(""&$aMainPath&"autotests\files") ;get array of file name
$aFirst_name = StringSplit ($aDirfile[1], ".")  ;get first file name
$aFormat = "docx"

_ArrayDelete($aDirfile, 0)    ;first name is clear


For $element In $aDirfile
	If StringInStr($element, "~$") == 0 Then   ;skip all files, if name started whith ~
		$Stringq = ""&$aMainPath&"autotests\files\"&$element&""  ;path to file
		$Stringw = ""&$aMainPath&"autotests\result\"&$element&""  ;path to file
		ConsoleWrite("x2t.exe "&$Stringq&" "&$Stringw&"."&$aFormat&"")
		Run("x2t.exe """&$Stringq&""" """&$Stringw&"."&$aFormat&"""", "", @SW_SHOWMAXIMIZED) ;open file by path
	    Sleep(1000)
	EndIf
Next


