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


Function GeneralDlgProc(ByVal hwnd As HWND, ByVal umsg As UINT, ByVal wparam As WPARAM, ByVal lparam As LPARAM) As Integer
    Select Case uMsg
    	Case WM_INITDIALOG
	    	If hide_on_close = TRUE Then
	    		CheckDlgButton(hwnd, CHK_BACKGROUND, BST_CHECKED)
	    		EnableWindow(GetDlgItem(hwnd, GRP_BLUETOOTH), TRUE)
				EnableWindow(GetDlgItem(hwnd, RBN_USB_SEL), TRUE)
				EnableWindow(GetDlgItem(hwnd, RBN_USB_CMD), TRUE)
				EnableWindow(GetDlgItem(hwnd, GRP_USB), TRUE)
				EnableWindow(GetDlgItem(hwnd, RBN_BTH_SEL), TRUE)
				EnableWindow(GetDlgItem(hwnd, RBN_BTH_CMD), TRUE)
				EnableWindow(GetDlgItem(hwnd, CHK_AUTOSTART), TRUE)
				EnableWindow(GetDlgItem(hwnd, RBN_BTH_IGNORE), TRUE)
				EnableWindow(GetDlgItem(hwnd, RBN_USB_IGNORE), TRUE)
				If usb_action + bt_action > 0 Then EnableWindow(GetDlgItem(hwnd, CHK_MINIMIZED), TRUE)
	    	EndIf
	    	If use_bt Then
    			EnableWindow(GetDlgItem(hwnd, EDT_BTTIMEOUT), TRUE)
    			EnableWindow(GetDlgItem(hwnd, STC_BTSTLBL1), TRUE)
    			EnableWindow(GetDlgItem(hwnd, STC_BTSTLBL2), TRUE)
	    	EndIf
	    	If bt_action = 1 Then CheckRadioButton(hwnd, RBN_BTH_SEL, RBN_BTH_IGNORE, RBN_BTH_SEL)
	    	If bt_action = 2 Then CheckRadioButton(hwnd, RBN_BTH_SEL, RBN_BTH_IGNORE, RBN_BTH_CMD)
	    	If bt_action = 0 Then CheckRadioButton(hwnd, RBN_BTH_SEL, RBN_BTH_IGNORE, RBN_BTH_IGNORE)
	    	If usb_action = 1 Then CheckRadioButton(hwnd, RBN_USB_SEL, RBN_USB_IGNORE, RBN_USB_SEL)
	    	If usb_action = 2 Then CheckRadioButton(hwnd, RBN_USB_SEL, RBN_USB_IGNORE, RBN_USB_CMD)
	    	If usb_action = 0 Then CheckRadioButton(hwnd, RBN_USB_SEL, RBN_USB_IGNORE, RBN_USB_IGNORE)
			If autostart Then CheckDlgButton(hwnd, CHK_AUTOSTART, BST_CHECKED)
			If PORTABLE Then EnableWindow(GetDlgItem(hwnd, CHK_AUTOSTART), FALSE) 'Autostart isn't portable.
			If use_bt Then CheckDlgButton(hwnd, CHK_BLUETOOTH, BST_CHECKED)
			Dim As String tmp = Trim(Str(bt_timeout))
			SendDlgItemMessage(hwnd, EDT_BTTIMEOUT, WM_SETTEXT, NULL, Cast(LPARAM, StrPtr(tmp)))
			SendDlgItemMessage(hwnd, EDT_BTTIMEOUT, EM_LIMITTEXT, 2, NULL)
			If showminimized Then CheckDlgButton(hwnd, CHK_MINIMIZED, BST_CHECKED)
			
			If autoupdate Then CheckDlgButton(hwnd, CHK_AUTOUPDATE, BST_CHECKED): EnableWindow(GetDlgItem(hwnd, CBO_UPDATEFREQ), TRUE)
			SendDlgItemMessage(hwnd, CBO_UPDATEFREQ, CB_SETITEMDATA, SendDlgItemMessage(hwnd, CBO_UPDATEFREQ, CB_ADDSTRING, NULL, Cast(LPARAM, @"Day")), 1)
    		SendDlgItemMessage(hwnd, CBO_UPDATEFREQ, CB_SETITEMDATA, SendDlgItemMessage(hwnd, CBO_UPDATEFREQ, CB_ADDSTRING, NULL, Cast(LPARAM, @"Week")), 2)
    		SendDlgItemMessage(hwnd, CBO_UPDATEFREQ, CB_SETITEMDATA, SendDlgItemMessage(hwnd, CBO_UPDATEFREQ, CB_ADDSTRING, NULL, Cast(LPARAM, @"Month")), 3)
	    	SendDlgItemMessage(hwnd, CBO_UPDATEFREQ, CB_SETCURSEL, 0, NULL)
	    	If PORTABLE Then EnableWindow(GetDlgItem(hwnd, CHK_AUTOUPDATE), FALSE): EnableWindow(GetDlgItem(hwnd, BTN_CHECKUPDATE), FALSE)
	    	
	    	If PORTABLE Then ShowWindow(GetDlgItem(hwnd, STC_PORTABLE), SW_SHOW)
			
	    	Return TRUE
    	Case WM_COMMAND
	        Select Case LoWord(wParam)
	        	Case CHK_BACKGROUND
	        		SendMessage(GetParent(hwnd), PSM_CHANGED, Cast(WPARAM, hwnd), NULL)
	        		If IsDlgButtonChecked(hwnd, CHK_BACKGROUND) Then
	        			EnableWindow(GetDlgItem(hwnd, GRP_BLUETOOTH), TRUE)
	    				EnableWindow(GetDlgItem(hwnd, RBN_USB_SEL), TRUE)
	    				EnableWindow(GetDlgItem(hwnd, RBN_USB_CMD), TRUE)
	    				EnableWindow(GetDlgItem(hwnd, GRP_USB), TRUE)
	    				EnableWindow(GetDlgItem(hwnd, RBN_BTH_SEL), TRUE)
	    				EnableWindow(GetDlgItem(hwnd, RBN_BTH_CMD), TRUE)
	    				EnableWindow(GetDlgItem(hwnd, CHK_AUTOSTART), TRUE)
	    				EnableWindow(GetDlgItem(hwnd, RBN_BTH_IGNORE), TRUE)
	    				EnableWindow(GetDlgItem(hwnd, RBN_USB_IGNORE), TRUE)
	    				If IsDlgButtonChecked(hwnd, RBN_BTH_IGNORE) And IsDlgButtonChecked(hwnd, RBN_USB_IGNORE)Then EnableWindow(GetDlgItem(hwnd, CHK_MINIMIZED), FALSE) Else EnableWindow(GetDlgItem(hwnd, CHK_MINIMIZED), TRUE)
	    			Else
	    				EnableWindow(GetDlgItem(hwnd, GRP_BLUETOOTH), FALSE)
	    				EnableWindow(GetDlgItem(hwnd, RBN_USB_SEL), FALSE)
	    				EnableWindow(GetDlgItem(hwnd, RBN_USB_CMD), FALSE)
	    				EnableWindow(GetDlgItem(hwnd, GRP_USB), FALSE)
	    				EnableWindow(GetDlgItem(hwnd, RBN_BTH_SEL), FALSE)
	    				EnableWindow(GetDlgItem(hwnd, RBN_BTH_CMD), FALSE)
	    				EnableWindow(GetDlgItem(hwnd, CHK_AUTOSTART), FALSE)
	    				EnableWindow(GetDlgItem(hwnd, RBN_BTH_IGNORE), FALSE)
	    				EnableWindow(GetDlgItem(hwnd, RBN_USB_IGNORE), FALSE)
	    				EnableWindow(GetDlgItem(hwnd, CHK_MINIMIZED), FALSE)
	        		EndIf
	        	Case EDT_BTTIMEOUT
	        		If HiWord(wparam) = EN_KILLFOCUS Then
	        			If GetDlgItemInt(hwnd, EDT_BTTIMEOUT, NULL, FALSE) = 0 Then
	        				SendDlgItemMessage(hwnd, EDT_BTTIMEOUT, WM_SETTEXT, NULL, Cast(LPARAM, @"1"))
	        			EndIf
	        		ElseIf HiWord(wparam) = EN_CHANGE Then SendMessage(GetParent(hwnd), PSM_CHANGED, Cast(WPARAM, hwnd), NULL)
	        		EndIf
	        	Case RBN_USB_SEL
	        		SendMessage(GetParent(hwnd), PSM_CHANGED, Cast(WPARAM, hwnd), NULL)
	        		If IsDlgButtonChecked(hwnd, RBN_BTH_IGNORE) And IsDlgButtonChecked(hwnd, RBN_USB_IGNORE)Then EnableWindow(GetDlgItem(hwnd, CHK_MINIMIZED), FALSE) Else EnableWindow(GetDlgItem(hwnd, CHK_MINIMIZED), TRUE)
	        	Case RBN_USB_CMD
	        		SendMessage(GetParent(hwnd), PSM_CHANGED, Cast(WPARAM, hwnd), NULL)
	        		If IsDlgButtonChecked(hwnd, RBN_BTH_IGNORE) And IsDlgButtonChecked(hwnd, RBN_USB_IGNORE)Then EnableWindow(GetDlgItem(hwnd, CHK_MINIMIZED), FALSE) Else EnableWindow(GetDlgItem(hwnd, CHK_MINIMIZED), TRUE)
	        	Case RBN_BTH_SEL
	        		SendMessage(GetParent(hwnd), PSM_CHANGED, Cast(WPARAM, hwnd), NULL)
	        		If IsDlgButtonChecked(hwnd, RBN_BTH_IGNORE) And IsDlgButtonChecked(hwnd, RBN_USB_IGNORE)Then EnableWindow(GetDlgItem(hwnd, CHK_MINIMIZED), FALSE) Else EnableWindow(GetDlgItem(hwnd, CHK_MINIMIZED), TRUE)
	        	Case RBN_BTH_CMD
	        		SendMessage(GetParent(hwnd), PSM_CHANGED, Cast(WPARAM, hwnd), NULL)
	        		If IsDlgButtonChecked(hwnd, RBN_BTH_IGNORE) And IsDlgButtonChecked(hwnd, RBN_USB_IGNORE)Then EnableWindow(GetDlgItem(hwnd, CHK_MINIMIZED), FALSE) Else EnableWindow(GetDlgItem(hwnd, CHK_MINIMIZED), TRUE)
	        	Case CHK_AUTOSTART
	        		SendMessage(GetParent(hwnd), PSM_CHANGED, Cast(WPARAM, hwnd), NULL)
	        	Case RBN_USB_IGNORE
	        		SendMessage(GetParent(hwnd), PSM_CHANGED, Cast(WPARAM, hwnd), NULL)
	        		If IsDlgButtonChecked(hwnd, RBN_BTH_IGNORE) And IsDlgButtonChecked(hwnd, RBN_USB_IGNORE)Then EnableWindow(GetDlgItem(hwnd, CHK_MINIMIZED), FALSE) Else EnableWindow(GetDlgItem(hwnd, CHK_MINIMIZED), TRUE)
	        	Case RBN_BTH_IGNORE
	        		SendMessage(GetParent(hwnd), PSM_CHANGED, Cast(WPARAM, hwnd), NULL)
	        		If IsDlgButtonChecked(hwnd, RBN_BTH_IGNORE) And IsDlgButtonChecked(hwnd, RBN_USB_IGNORE)Then EnableWindow(GetDlgItem(hwnd, CHK_MINIMIZED), FALSE) Else EnableWindow(GetDlgItem(hwnd, CHK_MINIMIZED), TRUE)
	        	Case CHK_MINIMIZED
	        		SendMessage(GetParent(hwnd), PSM_CHANGED, Cast(WPARAM, hwnd), NULL)
	        	Case CHK_BLUETOOTH
	        		SendMessage(GetParent(hwnd), PSM_CHANGED, Cast(WPARAM, hwnd), NULL)
	        		If IsDlgButtonChecked(hwnd, CHK_BLUETOOTH) Then
	        			EnableWindow(GetDlgItem(hwnd, EDT_BTTIMEOUT), TRUE)
	        			EnableWindow(GetDlgItem(hwnd, STC_BTSTLBL1), TRUE)
	        			EnableWindow(GetDlgItem(hwnd, STC_BTSTLBL2), TRUE)
	        		Else
	    				EnableWindow(GetDlgItem(hwnd, EDT_BTTIMEOUT), FALSE)
	    				EnableWindow(GetDlgItem(hwnd, STC_BTSTLBL1), FALSE)
	    				EnableWindow(GetDlgItem(hwnd, STC_BTSTLBL2), FALSE)
	        		EndIf
	        	Case CHK_AUTOUPDATE
	        		SendMessage(GetParent(hwnd), PSM_CHANGED, Cast(WPARAM, hwnd), NULL)
	        		If IsDlgButtonChecked(hwnd, CHK_AUTOUPDATE) Then
	        			EnableWindow(GetDlgItem(hwnd, CBO_UPDATEFREQ), TRUE)
	        		Else
	        			EnableWindow(GetDlgItem(hwnd, CBO_UPDATEFREQ), FALSE)
	        		EndIf
	        	Case BTN_CHECKUPDATE
	        		checkupdate(TRUE)
	        End Select
    	Case WM_NOTIFY
			Dim As LPPSHNOTIFY tmp = Cast(LPPSHNOTIFY, lparam)
			If tmp->hdr.code = PSN_APPLY Then
				'Apply button clicked.
        		MkDir Left(cfgpath, InStrRev(cfgpath, "\etc\"))
				MkDir cfgpath
        		If IsDlgButtonChecked(hwnd, CHK_BACKGROUND) Then hide_on_close = TRUE Else hide_on_close = FALSE
        		If IsDlgButtonChecked(hwnd, RBN_BTH_SEL) Then bt_action = 1
        		If IsDlgButtonChecked(hwnd, RBN_BTH_CMD) Then bt_action = 2
        		If IsDlgButtonChecked(hwnd, RBN_BTH_IGNORE) Then bt_action = 0
        		If IsDlgButtonChecked(hwnd, RBN_USB_SEL) Then usb_action = 1
        		If IsDlgButtonChecked(hwnd, RBN_USB_CMD) Then usb_action = 2
        		If IsDlgButtonChecked(hwnd, RBN_USB_IGNORE) Then usb_action = 0
        		If IsDlgButtonChecked(hwnd, CHK_BLUETOOTH) Then use_bt = TRUE Else use_bt = FALSE
        		bt_timeout = GetDlgItemInt(hwnd, EDT_BTTIMEOUT, NULL, FALSE)
        		If IsDlgButtonChecked(hwnd, CHK_AUTOUPDATE) Then autoupdate = TRUE Else autoupdate = FALSE
        		update_freq = SendDlgItemMessage(hwnd, CBO_UPDATEFREQ, CB_GETITEMDATA, SendDlgItemMessage(hwnd, CBO_UPDATEFREQ, CB_GETCURSEL, NULL, NULL), NULL)
        		If autoupdate = FALSE Then
        			uc_thread_running = FALSE
        		Else
        			If uc_thread_running = FALSE Then check_update_thread = ThreadCreate(Cast(Any Ptr, @checkthread))
        		EndIf
        		If PORTABLE = FALSE Then 'This isn't portable.
	        		If IsDlgButtonChecked(hwnd, CHK_AUTOSTART) Then
	        			Dim As HKEY h
						Dim As String fn = Chr(34) + Command(0) + Chr(34) + !" \"-background\""
						RegOpenKeyEx(HKEY_CURRENT_USER, "Software\Microsoft\Windows\CurrentVersion\Run", NULL, KEY_WRITE, @h)
						RegSetValueEx(h, "NeXT Commander", NULL, REG_SZ, StrPtr(fn), Len(fn) + 1)
						RegCloseKey(h)
						autostart = TRUE
	        		Else
						Dim As HKEY h
						Dim As String fn = Command(0)
						RegOpenKeyEx(HKEY_CURRENT_USER, "Software\Microsoft\Windows\CurrentVersion\Run", NULL, KEY_WRITE, @h)
						RegDeleteValue(h, "NeXT Commander")
						RegCloseKey(h)
						autostart = FALSE
	        		EndIf
        		EndIf
        		If IsDlgButtonChecked(hwnd, CHK_MINIMIZED) And usb_action + bt_action > 0 Then showminimized = TRUE Else showminimized = FALSE
        		
        		'Save settings...
        		Open cfgpath + ".bgopts" For Output As #1
        		Print #1, hide_on_close
        		Print #1, bt_action
        		Print #1, usb_action
        		Print #1, showminimized
        		Close #1
        		Open cfgpath + ".btopts" For Output As #1
        		Print #1, use_bt
        		Print #1, bt_timeout
        		Close #1
        		Open cfgpath + ".updatopts" For Output As #1
        		Print #1, autoupdate
        		Print #1, update_freq
        		Close #1
			EndIf
    End Select

   Return FALSE
End Function


Function AboutDlgProc(ByVal hwnd As HWND, ByVal umsg As UINT, ByVal wparam As WPARAM, ByVal lparam As LPARAM) As Integer
    Select Case uMsg
    	Case WM_INITDIALOG
	    	SendDlgItemMessage(hwnd, STC_ABOUT, WM_SETTEXT, NULL, Cast(LPARAM, StrPtr(ABOUT_TEXT)))
	    	Return TRUE
    	Case WM_COMMAND
	        Select Case LoWord(wParam)
	        	Case Else
	        End Select
    End Select

   Return FALSE
End Function



Sub settings(hwnd As HWND)
	'Displays the settings screen.
	Dim As PROPSHEETPAGE pspgs(2)
	With pspgs(0)
		.dwSize = SizeOf(PROPSHEETPAGE)
		.hInstance = GetModuleHandle(NULL)
		.pszTemplate = MAKEINTRESOURCE(DLG_SETTINGS)
		.pfnDlgProc = @GeneralDlgProc
	End With
	With pspgs(1)
		.dwSize = SizeOf(PROPSHEETPAGE)
		.hInstance = GetModuleHandle(NULL)
		.pszTemplate = MAKEINTRESOURCE(DLG_ABOUT)
		.pfnDlgProc = @AboutDlgProc
	End With
	
	Dim As PROPSHEETHEADER psh
	With psh
		.dwSize = SizeOf(PROPSHEETHEADER)
		.dwFlags = PSH_PROPSHEETPAGE Or PSH_NOCONTEXTHELP
		.hwndParent = hwnd
		.hInstance = GetModuleHandle(NULL)
		.pszCaption = @"NeXT Commander Settings"
		.nPages = 2
		.nStartPage = 0
		.ppsp = @pspgs(0)
	End With
	PropertySheet(@psh) 'Display it!
	
End Sub
