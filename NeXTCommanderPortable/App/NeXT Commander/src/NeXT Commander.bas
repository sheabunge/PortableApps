/'
Copyright (c) 2011, SavedCoder.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the 
	following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
   disclaimer in the documentation and/or other materials provided with the distribution.
3. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. 
	If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is 
	not required.
4. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
5. The name of the author may not be used to endorse or promote products derived from this software without specific 
	prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, 
BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE.
'/


'To God be the glory.

#Lang "fb"
#Include "NeXT Commander.bi"


CreateMutex(NULL, NULL, "NeXT Commander is running.") 'Used by the installer to detect when NeXT Commander is running.


ReDim known_NXTs(0)
ReDim files(0)
ReDim monitors(0)
ReDim rc2s(0)
NXT_list_lock = MutexCreate
known_NXTs_lock = MutexCreate
NXT_info_lock = MutexCreate

Dim As Integer ret

'Figure out the settings folder...
cfgpath = String(MAX_PATH, " ")
If SHGetFolderPath(NULL, CSIDL_LOCAL_APPDATA, NULL, SHGFP_TYPE_CURRENT, StrPtr(cfgpath)) = S_OK Then
    cfgpath = Trim(cfgpath) + "\NeXT Commander\etc\"
    MkDir Left(cfgpath, InStrRev(cfgpath, "\etc\")) 'Have to do this because you can only create one directory level at a time.
Else
	MessageBox(NULL, "SHGetFolderPath(NULL, CSIDL_LOCAL_APPDATA, NULL, SHGFP_TYPE_CURRENT, StrPtr(cfgpath)) failed.", "NeXT Commander", MB_OK Or MB_ICONERROR Or MB_SETFOREGROUND)
	End
EndIf
If FileExists(ExePath + "\App\NeXT Commander\portable") Then cfgpath = ExePath + "\Data\": PORTABLE = TRUE
MkDir cfgpath


'Are we configured to autostart?
Dim As HKEY h
RegOpenKeyEx(HKEY_CURRENT_USER, "Software\Microsoft\Windows\CurrentVersion\Run", NULL, KEY_READ, @h)
autostart = -1
ret = RegQueryValueEx(h, "NeXT Commander", NULL, NULL, NULL, NULL)
If ret <> ERROR_SUCCESS Then autostart = FALSE
RegCloseKey(h)
If PORTABLE Then autostart = FALSE

'Are we configured to hide on close? If so, what do we do when we find an NXT?
If FileExists(cfgpath + ".bgopts") Then
	Open cfgpath + ".bgopts" For Input As #1
	Input #1, hide_on_close
	Input #1, bt_action
	Input #1, usb_action
	Input #1, showminimized
	Close #1
EndIf
If hide_on_close = FALSE And InStr(LCase(Command), "-background") Then End 'Don't hide if we're no supposed to!


Kill cfgpath + "errorlog.txt" 'Clear the error log.


'Bluetooth options...
If FileExists(cfgpath + ".btopts") Then
	Open cfgpath + ".btopts" For Input As #1
	Input #1, use_bt
	Input #1, bt_timeout
	Close #1
EndIf

'Auto update settings...
If FileExists(cfgpath + ".updatopts") Then
	Open cfgpath + ".updatopts" For Input As #1
	Input #1, autoupdate
	Input #1, update_freq
	Close #1
EndIf
If PORTABLE Then autoupdate = FALSE


'Load plugins...
ReDim plugins(0)
Dim As Integer plugin_error
fn = Dir(ExePath + "/plugin/*.dll", fbnormal)
While fn <> ""
	plugin_error = TRUE
	plugins(UBound(plugins)).handle = DylibLoad(ExePath + "/plugin/" + fn)
	If plugins(UBound(plugins)).handle Then
		Dim info As Sub (ip As plugin_info Ptr) = DylibSymbol(plugins(UBound(plugins)).handle, "INFO")
		If info Then
			info(@plugins(UBound(plugins)).info)
			If plugins(UBound(plugins)).info.kind = 1 And plugins(UBound(plugins)).info.version = 1 Then
				plugins(UBound(plugins)).action = DylibSymbol(plugins(UBound(plugins)).handle, "ACTION")
				If plugins(UBound(plugins)).action <> NULL Then plugin_error = FALSE
			EndIf
		EndIf
	EndIf

	If plugin_error Then 
		DylibFree(plugins(UBound(plugins)).handle)
		plugins(UBound(plugins)).info.kind = 0
		plugins(UBound(plugins)).info.version = 0
		plugins(UBound(plugins)).info.title = ""
		plugins(UBound(plugins)).action = NULL
	Else
		ReDim Preserve plugins(UBound(plugins) + 1)
	EndIf
	fn = Dir()
Wend
If UBound(plugins) > 8 Then MessageBox(NULL, !"Unfortunately, NeXT Commander has detected more plugins than it can display.\r\nNeXT Commander will still work fine, but only the first nine plugins can be displayed.\r\nHopefully this will be improved in the next version.", "NeXT Commander", MB_OK Or MB_ICONINFORMATION)



'Load the known NXTs list...
Dim As String tmp
Dim As Integer a, b
ChDir ExePath
If FileExists(cfgpath + ".KnownNXTs") Then
	Open cfgpath + ".KnownNXTs" For Input As #1
	Line Input #1, tmp
	Do
    	Line Input #1, known_NXTs(a).Name
    	Line Input #1, known_NXTs(a).resstr
    	If Eof(1) Then Exit Do
    	a += 1
    	ReDim Preserve known_NXTs(a)
	Loop
    Close #1
End If 
'ReDim NXTs(39)
'	For z As Integer = 0 To 39
'	NXTs(z).Name = "AaronNXT"
'	NXTs(z).resstr = Str(z) '"USB0::0x0694::0x0002::00165307E6E2::RAW"
'	NXTs(z).connection = "On USB0"
'	Next
'NXTs_found = 40
'ReDim NXTs(2)
'NXTs(0).Name = "NXT"
'NXTs(0).resstr = Str("USB0::0x0694::0x0002::00165307E6E2::RAW")
'NXTs(0).connection = "On USB0"
'NXTs(1).Name = "Brick0"
'NXTs(1).resstr = Str("USB0::0x0694::0x0002::00165307E6E2::RAW")
'NXTs(1).connection = "On Bluetooth"
'NXTs(2).Name = "Unfamiliar NXT"
'NXTs(2).resstr = Str("USB0::0x0694::0x0002::00165307E6E2::RAW")
'NXTs(2).connection = "On USB1"
'NXTs_found = 3


NXTs_found = -1
update_list_thread = ThreadCreate(Cast(Any Ptr, @update_nxt_list))

If autoupdate Then check_update_thread = ThreadCreate(Cast(Any Ptr, @checkthread))


CoInitialize(NULL) 'Stupid COM... The folder selection dialog needs it though.
InitCommonControls
TASKBAR_RESTART = RegisterWindowMessage("TaskbarCreated") 'So we know if Explorer restarts.

'Load our spinning icon...
For i As Integer = 0 To 15
	icons(i) = LoadIcon(GetModuleHandle(NULL), "SPIN_" + Trim(Str(i + 1)))
Next



'GO, GO, GOOOOO!!!
ret = DialogBox(GetModuleHandle(NULL), MAKEINTRESOURCE(DLG_SELECTION), NULL, @SelectionDlgProc)
If ret = IDOK Then
    
ElseIf ret <> IDCANCEL And ret <> IDOK Then
	MessageBox(NULL, "Dialog exited with unknown value. (error?)", "Notice", MB_OK Or MB_ICONINFORMATION)
EndIf




For i As Integer = 0 To 15
	DestroyIcon(icons(i))
Next

CoUninitialize 'Good! We're done with it.


uc_thread_running = FALSE



If known_NXTs_has_changed Then
	'Save the known NXTs list
	Open cfgpath + ".KnownNXTs" For Output As #1
	Print #1, "DO NOT MODIFY THIS FILE UNLESS YOU ARE ABSOLUTELY SURE YOU KNOW WHAT YOU ARE DOING AND UNDERSTAND HOW THE PARSER WORKS!!!"
	For a = 0 To UBound(known_NXTs)
    	Print #1, known_NXTs(a).Name
    	If a = UBound(known_NXTs) Then Print #1, known_NXTs(a).resstr; Else Print #1, known_NXTs(a).resstr
	Next
    Close #1
End If


'Unload plugins...
For p As Integer = 0 To UBound(plugins) - 1
	DylibFree(plugins(p).handle)
Next



'Can't quit `till our threads do...

ThreadWait(update_list_thread)
ThreadWait(update_info_thread)
ThreadWait(check_update_thread)
MutexDestroy(NXT_list_lock)
MutexDestroy(known_NXTs_lock)
MutexDestroy(NXT_info_lock)

End 'Finished!!











#Include "settings.bas"
#Include "command.bas"
#Include "operations.bas"
#Include "select.bas"
#Include "monitors.bas"
#Include "rc1.bas"
#Include "rc2.bas"
#Include "rc3.bas"
#Include "updater.bas"



Function PasskeyDlgProc(ByVal hwnd As HWND, ByVal umsg As UINT, ByVal wparam As WPARAM, ByVal lparam As LPARAM) As Integer
    'Get the Bluetooth passkey from the user...
    Select Case uMsg
    	Case WM_INITDIALOG
    		SendDlgItemMessage(hwnd, EDT_KEY, EM_LIMITTEXT, 16, NULL)
    		If passkey <> "" Then
    			SendDlgItemMessage(hwnd, EDT_KEY, WM_SETTEXT, NULL, Cast(lparam, @passkey))
    			SendDlgItemMessage(hwnd, EDT_KEY, EM_SETSEL, 0, 16)
    		endif
	    	Return TRUE
    	Case WM_COMMAND
	        Select Case LoWord(wParam)
	        	Case IDCANCEL
	        		EndDialog(hwnd, IDCANCEL)
	        	Case IDOK
	        		GetDlgItemText(hwnd, EDT_KEY, @passkey, SizeOf(passkey))
	        		EndDialog(hwnd, IDOK)
	        End Select
    	Case Else
	    	Return FALSE
    End Select
    
   Return TRUE
End Function
