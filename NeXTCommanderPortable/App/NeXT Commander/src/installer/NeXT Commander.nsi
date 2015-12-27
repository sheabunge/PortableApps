/*
Copyright (c) 2011, SavedCoder.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that 
the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the 
   following disclaimer.
2. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. 
   If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not 
   required.
3. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
4. The name of the author may not be used to endorse or promote products derived from this software without specific 
   prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, 
BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE.
*/


!Define APPNAME "NeXT Commander"

Name "${APPNAME}"
OutFile "${APPNAME} Setup.exe"
InstallDir "$PROGRAMFILES\${APPNAME}\"
RequestExecutionLevel Highest
SetOverwrite On
SetCompressor LZMA /SOLID

VIProductVersion "0.9.0.0"
VIAddVersionKey "ProductName" "${APPNAME}"
VIAddVersionKey "Comments" ""
VIAddVersionKey "LegalCopyright" "Copyright (©) 2011, SavedCoder"
VIAddVersionKey "FileDescription" "A program to control every aspect of the Mindstorms NXT."
VIAddVersionKey "FileVersion" "0.9.0.0 (Beta)"



!Define MULTIUSER_EXECUTIONLEVEL Highest
!Define MULTIUSER_MUI
!Define MULTIUSER_INSTALLMODE_COMMANDLINE
!Define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_KEY "Software\${APPNAME}"
!Define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_VALUENAME ""
!Define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_KEY "Software\${APPNAME}"
!Define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_VALUENAME ""
!Define MULTIUSER_INSTALLMODE_INSTDIR "${APPNAME}"
!Include "MultiUser.nsh"
!Include "MUI2.nsh"
!Include "LogicLib.nsh"
;!Include "Sections.nsh"


!Define MUI_ABORTWARNING
!Define MUI_UNABORTWARNING
!Define MUI_HEADERIMAGE
!Define MUI_HEADERIMAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\floppy_installer_blue.bmp"
!Define MUI_HEADERIMAGE_UNBITMAP "${NSISDIR}\Contrib\Graphics\Header\floppy_uninstaller_red.bmp"
!Define MUI_WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\wizard\floppy_installer_blue-nsis_mod.bmp"
!Define MUI_UNWELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\wizard\floppy_uninstaller_red-nsis_mod.bmp"
!Define MUI_ICON "${NSISDIR}\Contrib\Graphics\icons\floppy_installer_blue-vista.ico"
!Define MUI_UNICON "${NSISDIR}\Contrib\Graphics\icons\floppy_uninstaller_red-vista.ico"
!Define MUI_COMPONENTSPAGE_CHECKBITMAP "${NSISDIR}\Contrib\Graphics\checks\modern.bmp"
!Define MUI_ABORTWARNING_CANCEL_DEFAULT
ShowInstDetails Show
ShowUnInstDetails Show

Var /GLOBAL "fh"
Var /GLOBAL "inst4all"
Var /GLOBAL "upgrade"



;-------------------------------
 
  !InsertMacro MUI_PAGE_WELCOME
    !define MUI_LICENSEPAGE_RADIOBUTTONS
    !define MUI_LICENSEPAGE_RADIOBUTTONS_TEXT_ACCEPT "I have read and accept the terms of the License Agreement." 
    !define MUI_PAGE_CUSTOMFUNCTION_SHOW ChangeButtonText
  !InsertMacro MUI_PAGE_LICENSE "license.txt"
    !define MUI_PAGE_CUSTOMFUNCTION_PRE Hide
  !InsertMacro MUI_PAGE_COMPONENTS
    !define MUI_PAGE_CUSTOMFUNCTION_PRE Hide
  !InsertMacro MULTIUSER_PAGE_INSTALLMODE
    !define MUI_PAGE_CUSTOMFUNCTION_PRE Hide
  !InsertMacro MUI_PAGE_DIRECTORY
  !InsertMacro MUI_PAGE_INSTFILES
    #!Define MUI_FINISHPAGE_NOAUTOCLOSE
    #!Define MUI_FINISHPAGE_RUN_TEXT "Open ${APPNAME}."
    !Define MUI_FINISHPAGE_RUN "$INSTDIR\${APPNAME}.exe"
    !Define MUI_FINISHPAGE_SHOWREADEME_TEXT "View readme"
    !Define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\doc\Readme.chm"
  !InsertMacro MUI_PAGE_FINISH

  !InsertMacro MUI_UNPAGE_WELCOME
  !InsertMacro MUI_UNPAGE_CONFIRM
  !InsertMacro MUI_UNPAGE_INSTFILES
  #!Define MUI_UNFINISHPAGE_NOAUTOCLOSE
  !InsertMacro MUI_UNPAGE_FINISH

  !InsertMacro MUI_LANGUAGE "English"

;--------------------------------

Section "${APPNAME} + source" main
  SectionIn RO

  SetOutPath "$INSTDIR\"
  WriteUninstaller "Uninst.exe"
  File "${APPNAME}.exe"
  File "libcurl.dll"

  CreateDirectory "$INSTDIR\plugin"
  SetOutPath "$INSTDIR\plugin"
  

  CreateDirectory "$INSTDIR\src"
  SetOutPath "$INSTDIR\src"
  File "${APPNAME}.bas"
  File "${APPNAME}.bi"
  File "${APPNAME}.rc"
  File "${APPNAME}.fbp"
  File "xpmanifest.xml"
  File "command.bas"
  File "select.bas"
  File "monitors.bas"
  File "settings.bas"
  File "operations.bas"
  File "rc1.bas"
  File "rc2.bas"
  File "rc3.bas"
  File "updater.bas"
  File "rsrc.bi"
  File "TODO"

  CreateDirectory "$INSTDIR\src\icons"
  SetOutPath "$INSTDIR\src\icons"
  File "icons\1.ico"
  File "icons\2.ico"
  File "icons\3.ico"
  File "icons\4.ico"
  File "icons\5.ico"
  File "icons\6.ico"
  File "icons\7.ico"
  File "icons\8.ico"
  File "icons\9.ico"
  File "icons\10.ico"
  File "icons\11.ico"
  File "icons\12.ico"
  File "icons\13.ico"
  File "icons\14.ico"
  File "icons\15.ico"
  File "icons\16.ico"
  File "icons\base_48.png"
  File "icons\main_48.png"
  File "icons\main.ico"
  File "icons\base_256.png"
  File "icons\main_256.png"

  CreateDirectory "$INSTDIR\src\logos"
  SetOutPath "$INSTDIR\src\logos"
  File "logos\logo3.bmp"
  
  CreateDirectory "$INSTDIR\src\plugin"
  SetOutPath "$INSTDIR\src\plugin"
  File "plugin\plugin.bi"
  File "plugin\example.bas"

  CreateDirectory "$INSTDIR\src\installer"
  SetOutPath "$INSTDIR\src\installer"
  File "${APPNAME}.nsi"
  File "${NSISDIR}\Contrib\Graphics\Header\floppy_installer_blue.bmp"
  File "${NSISDIR}\Contrib\Graphics\Header\floppy_uninstaller_red.bmp"
  File "${NSISDIR}\Contrib\Graphics\floppy.7z"
  File "${NSISDIR}\Contrib\Graphics\wizard\floppy_installer_blue-nsis_mod.bmp"
  File "${NSISDIR}\Contrib\Graphics\wizard\floppy_uninstaller_red-nsis_mod.bmp"
  FileOpen $0 "note.txt" "w"
  FileWrite $0 "I made the header images myself (from the icons), and I changed the $\"Nullsoft Install System$\" on the welcome images to a darker color. The file $\"floppy.7z$\" is the original package."
  FileClose $0

  CreateDirectory "$INSTDIR\doc"
  SetOutPath "$INSTDIR\doc"  
  File "Readme.chm"
  File "TODO"

  WriteRegStr SHCTX "Software\${APPNAME}" "" $INSTDIR

  WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
  WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegDWORD SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "NoModify" 1
  WriteRegDWORD SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "NoRepair" 1
SectionEnd


Section "Start Menu shortcuts" shortcut_s
  CreateDirectory "$SMPROGRAMS\${APPNAME}"
  CreateShortCut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\${APPNAME}.exe"
  CreateShortCut "$SMPROGRAMS\${APPNAME}\Readme.lnk" "$INSTDIR\doc\Readme.chm"
  CreateShortCut "$SMPROGRAMS\${APPNAME}\Uninstall.lnk" "$INSTDIR\Uninst.exe"
SectionEnd

Section "Desktop shortcut" shortcut_d
  CreateShortCut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\${APPNAME}.exe"
SectionEnd


!InsertMacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !InsertMacro MUI_DESCRIPTION_TEXT ${main} "${APPNAME}, its required files, and its source"
  !InsertMacro MUI_DESCRIPTION_TEXT ${shortcut_s} "Start Menu shortcuts to ${APPNAME}, its readme file, and its uninstaller."
  !InsertMacro MUI_DESCRIPTION_TEXT ${shortcut_d} "A desktop shortcut for ${APPNAME}."
!InsertMacro MUI_FUNCTION_DESCRIPTION_END


;--------------------------------

Section "Uninstall"

  FileOpen $fh $INSTDIR\inst.cfg r
  FileRead $fh $inst4all
  FileClose $fh

  Delete /RebootOK "$INSTDIR\Uninst.exe"
  Delete /RebootOK "$INSTDIR\${APPNAME}.exe"
  Delete /RebootOK "$INSTDIR\libcurl.dll"

  RmDir "$INSTDIR\plugin"

  Delete /RebootOK "$INSTDIR\src\installer\${APPNAME}.nsi"
  Delete /RebootOK "$INSTDIR\src\installer\floppy_installer_blue.bmp"
  Delete /RebootOK "$INSTDIR\src\installer\floppy_uninstaller_red.bmp"
  Delete /RebootOK "$INSTDIR\src\installer\note.txt"
  Delete /RebootOK "$INSTDIR\src\installer\floppy.7z"
  Delete /RebootOK "$INSTDIR\src\installer\floppy_installer_blue-nsis_mod.bmp"
  Delete /RebootOK "$INSTDIR\src\installer\floppy_uninstaller_red-nsis_mod.bmp"
  RmDir "$INSTDIR\src\installer"

  Delete /RebootOK "$INSTDIR\src\${APPNAME}.bas"
  Delete /RebootOK "$INSTDIR\src\${APPNAME}.bi"
  Delete /RebootOK "$INSTDIR\src\${APPNAME}.rc"
  Delete /RebootOK "$INSTDIR\src\${APPNAME}.fbp"
  Delete /RebootOK "$INSTDIR\src\xpmanifest.xml"
  Delete /RebootOK "$INSTDIR\src\monitors.bas"
  Delete /RebootOK "$INSTDIR\src\select.bas"
  Delete /RebootOK "$INSTDIR\src\command.bas"
  Delete /RebootOK "$INSTDIR\src\settings.bas"
  Delete /RebootOK "$INSTDIR\src\operations.bas"
  Delete /RebootOK "$INSTDIR\src\rc1.bas"
  Delete /RebootOK "$INSTDIR\src\rc2.bas"
  Delete /RebootOK "$INSTDIR\src\rc3.bas"
  Delete /RebootOK "$INSTDIR\src\updater.bas"
  Delete /RebootOK "$INSTDIR\src\rsrc.bi"
  Delete /RebootOK "$INSTDIR\src\TODO"
  Delete /RebootOK "$INSTDIR\src\icons\1.ico"
  Delete /RebootOK "$INSTDIR\src\icons\2.ico"
  Delete /RebootOK "$INSTDIR\src\icons\3.ico"
  Delete /RebootOK "$INSTDIR\src\icons\4.ico"
  Delete /RebootOK "$INSTDIR\src\icons\5.ico"
  Delete /RebootOK "$INSTDIR\src\icons\6.ico"
  Delete /RebootOK "$INSTDIR\src\icons\7.ico"
  Delete /RebootOK "$INSTDIR\src\icons\8.ico"
  Delete /RebootOK "$INSTDIR\src\icons\9.ico"
  Delete /RebootOK "$INSTDIR\src\icons\10.ico"
  Delete /RebootOK "$INSTDIR\src\icons\11.ico"
  Delete /RebootOK "$INSTDIR\src\icons\12.ico"
  Delete /RebootOK "$INSTDIR\src\icons\13.ico"
  Delete /RebootOK "$INSTDIR\src\icons\14.ico"
  Delete /RebootOK "$INSTDIR\src\icons\15.ico"
  Delete /RebootOK "$INSTDIR\src\icons\16.ico"
  Delete /RebootOK "$INSTDIR\src\icons\main.ico"
  Delete /RebootOK "$INSTDIR\src\icons\base_48.png"
  Delete /RebootOK "$INSTDIR\src\icons\main_48.png"
  Delete /RebootOK "$INSTDIR\src\icons\base_256.png"
  Delete /RebootOK "$INSTDIR\src\icons\main_256.png"
  Delete /RebootOK "$INSTDIR\src\logos\logo3.bmp"
  Delete /RebootOK "$INSTDIR\src\plugin\plugin.bi"
  Delete /RebootOK "$INSTDIR\src\plugin\example.bas"

  RmDir "$INSTDIR\src\plugin"
  RmDir "$INSTDIR\src\icons"
  RmDir "$INSTDIR\src\logos"
  RmDir "$INSTDIR\src"
  
  Delete /RebootOK "$INSTDIR\doc\Readme.chm"
  Delete /RebootOK "$INSTDIR\doc\COPYING"
  Delete /RebootOK "$INSTDIR\doc\TODO"
  Rmdir "$INSTDIR\doc"

  RmDir $INSTDIR


  Delete /RebootOK "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk"
  Delete /RebootOK "$SMPROGRAMS\${APPNAME}\Readme.lnk"
  Delete /RebootOK "$SMPROGRAMS\${APPNAME}\Uninstall.lnk"
  RmDir "$SMPROGRAMS\${APPNAME}"
  Delete /RebootOK "$DESKTOP\${APPNAME}.lnk"

  DeleteRegKey /ifempty SHCTX "Software\${APPNAME}"

  DeleteRegKey SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
SectionEnd



Function .onInit
  CheckIfRunning:
  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "NeXT Commander is running.") i .r1 ?e'
  Pop $R0
  ${If} $R0 != 0
    MessageBox MB_OKCANCEL|MB_ICONINFORMATION "NeXT Commander is currently running. Please close it and click OK." IDOK CheckIfRunning

    quit
  ${EndIf}

  !InsertMacro MULTIUSER_INIT
  StrCpy $upgrade "f"
  ${If} $MultiUser.InstallMode == "AllUsers"
    ReadRegStr $0 HKLM "Software\${APPNAME}" ""
    ${If} $0 != ""
      StrCpy $upgrade "t"
    ${EndIf}
  ${Else}
    ReadRegStr $0 HKCU "Software\${APPNAME}" ""
    ${If} $0 != ""
      StrCpy $upgrade "t"
    ${EndIf}
  ${EndIf}
FunctionEnd


Function Hide
  ${If} $upgrade == "t"
    Abort
  ${EndIf}
FunctionEnd


Function ChangeButtonText
  ${If} $upgrade == "t"
    GetDlgItem $2 $HWNDPARENT 1
    SendMessage $2 ${WM_SETTEXT} 0 "STR:Install"
  ${EndIf}
FunctionEnd


Function un.onInit
  !InsertMacro MULTIUSER_UNINIT
FunctionEnd
