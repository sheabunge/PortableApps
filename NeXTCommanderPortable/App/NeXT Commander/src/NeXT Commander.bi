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


#Include "crt.bi"
#Include "file.bi"
#Include "fbgfx.bi"
#Define WIN_INCLUDEALL
#Include "windows.bi"
#Include "win/shlobj.bi"
#Include "NXT.bi"
#Include "rsrc.bi"
#Include "curl.bi"
#Include "vbcompat.bi"
#Include "plugin/plugin.bi"



#Define VER_STR "0.9.0.0"

#Define NOTIFYICONDATA_V3_SIZE 408

'Ge'll get these when (if) the tray icon is used...
#Define WM_TRAYICON WM_USER + 1000
#Define MENU_OPEN 100
#Define MENU_EXIT 101


Const As String ABOUT_TEXT = "	Version " + VER_STR + !" (Beta)\r\n	Copyright (©) 2011, SavedCoder\r\n\r\n\r\n\r\n" + _
					!"I give ALL credit for my work to God. \r\n\...\"And without him was not any thing made that was made.\" " + _
					!"(John 1:3b)\r\n\r\n\r\n\r\n\r\n" + _
					!"This program is written in FreeBASIC 0.21."


Declare Sub update_nxt_list
Declare Sub update_NXT_info
Declare Function nxt_operation(whatkind As Byte, hwnd As HWND, oldname As String = "", newname As String = "", hdrop As HDROP = NULL) As Byte
Declare Function PasskeyDlgProc(ByVal hwnd As HWND, ByVal umsg As UINT, ByVal wparam As WPARAM, ByVal lparam As LPARAM) As Integer
Declare Function CommandDlgProc(ByVal hwnd As HWND, ByVal umsg As UINT, ByVal wparam As WPARAM, ByVal lparam As LPARAM) As Integer
Declare Function SelectionDlgProc(ByVal hwnd As HWND, ByVal umsg As UINT, ByVal wparam As WPARAM, ByVal lparam As LPARAM) As Integer
Declare Function firmware_dl(hwnd As HWND, mode As Byte) As Integer
Declare Function GeneralDlgProc(ByVal hwnd As HWND, ByVal umsg As UINT, ByVal wparam As WPARAM, ByVal lparam As LPARAM) As Integer
Declare Function TestDlgProc(ByVal hwnd As HWND, ByVal umsg As UINT, ByVal wparam As WPARAM, ByVal lparam As LPARAM) As Integer
Declare Sub monitor
Declare Function Rc1DlgProc(ByVal hwnd As HWND, ByVal umsg As UINT, ByVal wparam As WPARAM, ByVal lparam As LPARAM) As Integer
Declare Sub rc1(hwnd As Any Ptr)
Declare Function LbProc(ByVal hwnd As HWND,ByVal uMsg As UInteger,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As LRESULT
Declare Sub SetMotors(x As Single, y As Single)
Declare Sub rc2
Declare Sub rc3
Declare Sub settings(hwnd As HWND)
Declare Function AboutDlgProc(ByVal hwnd As HWND, ByVal umsg As UINT, ByVal wparam As WPARAM, ByVal lparam As LPARAM) As Integer
Declare Function data_callback Cdecl(ByVal buffer As UByte Ptr, ByVal size As Integer, ByVal nitems As Integer, ByVal outstream As Any Ptr) As Integer
Declare Sub checkthread
Declare Sub checkupdate(manual As Integer = FALSE)
Declare Function UpdateDlgProc(ByVal hwnd As HWND, ByVal umsg As UINT, ByVal wparam As WPARAM, ByVal lparam As LPARAM) As Integer



Type NXT_list_entry
	As ZString * 256 resstr
	As ZString * 16 Name, connection
End Type

Type fileinfo
	As ZString * 20 Name
	As Integer size
End Type

Type monitor_list_entry
	As HWND hwnd
    As Integer sensor_type, sensor_port, status, monitoring
End Type

Type rc2_list_entry
	As HWND hwnd
    As Integer ports, status, sendstop
End Type


Type plugin_list_entry
	As plugin_info info
	As Any Ptr handle
	action As Sub (hNXT As NXT.hNXT, leaving_command_seceen As Integer Ptr)
End Type


Dim Shared As NXT_list_entry NXTs(), known_NXTs()
Dim Shared As fileinfo files()
Dim Shared As Integer ending, update_nxt_list_ending, NXTs_found = -1, NXT_to_command, update_info_ending, _
					hide_on_close, bt_action, usb_action, autostart, TASKBAR_RESTART, firstshow = TRUE, _
					leaving_command_seceen, rc_open, use_bt = TRUE, bt_timeout = 8, PORTABLE, autoupdate = TRUE, _
					update_freq = 2, uc_thread_running, showminimized, showstate, hNXT_usecount
Dim Shared As String battery, friendly_name, free_flash, signal_strengths(3), running_program, _
					protocol_version, firmware_version, bluetooth_address, fn, cfgpath
Dim Shared As Byte bt_addr(5), info_has_changed, known_NXTs_has_changed, selected_files(), reload_files
Dim Shared As Any Ptr NXT_list_lock, known_NXTs_lock, NXT_info_lock, update_list_thread, update_info_thread, check_update_thread
Dim Shared As RECT winpos
Dim Shared As HICON icons(15)
Dim Shared As monitor_list_entry monitors()
Dim Shared As NXT.hNXT hNXT
Dim Shared As ZString * 17 passkey
Dim Shared As rc2_list_entry rc2s()
Dim Shared As plugin_list_entry plugins()


Const As Integer list_update_delay = 100, info_update_delay = 480, command_screen_update_delay = 100


#Macro report_error()
	'Reports and logs an error.
	If status > -1000000000 Then 'Don't blow up over an unplugged NXT.
		If NXT.GetEnglishError(status) <> "" Then
			Dim As String msgtmp = NXT.GetEnglishError(status) + !"\n\nIn file: " + __FILE__ + !"\n\nOn line: " + Trim(Str(__LINE__ - 1)) + !"\n\nStatus: " + Trim(Str(status)) 'Hex(First - status)
			Dim As Integer f = FreeFile
			Open cfgpath + "errorlog.txt" For Append As #f
			Print #f, msgtmp
			Close #f
			MessageBox(NULL, msgtmp, "NeXT Commander", MB_OK)
		EndIf
	EndIf
#EndMacro


'These are left over from version 0.1.0.0.
'#Define bg_gray &hc8, &hc8, &hbf
'#Define lt_gray &he2, &he3, &hda
'#define dk_gray &h55, &h60, &h65
'#define other_gray &hb1, &hb1, &hb1
'#define orange &hfe, &ha8, &h3e
'#define other_orange &hf0, &h90, &h5f
