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


Sub update_nxt_list
	Dim As NXT.hNXTIterator NXTiter
	Dim As Integer status, a, b, c, d
	Dim As String tmp
	Dim As NXT_list_entry tmp_NXTs()

	Do
		status = 0
		ReDim tmp_NXTs(0)  
		NXTiter = NXT.CreateNXTIterator(USE_BT, BT_TIMEOUT, @status)
		If status = 0 Then
			NXT.GetNXTNameFromIterator(NXTiter, @tmp_NXTs(0).resstr, @status)
			report_error()
			Do
				ReDim Preserve tmp_NXTs(UBound(tmp_NXTs) + 1)
				NXT.GetNXTNameFromIterator(NXTiter, @tmp_NXTs(UBound(tmp_NXTs)).resstr, @status)
				report_error()
				NXT.AdvanceNXTIterator(NXTiter, @status)
			Loop While status = 0 And UBound(tmp_NXTs) < 39
			If status = NXT.Status.NoMoreItemsFound Then status = 0
			report_error()
			ReDim Preserve tmp_NXTs(UBound(tmp_NXTs) - 1)
			
			'tmp_NXTs(UBound(tmp_NXTs)).resstr = "BTH::FifteenCharName::00:16:53:04:05:06::5"
			For a = 0 To UBound(tmp_NXTs)
				If Left(tmp_NXTs(a).resstr, 3) = "BTH" Then
					b = 4
					Do: b += 1: tmp = Mid(tmp_NXTs(a).resstr, b, 1): Loop Until tmp = ":"
					c = b
					Do: c += 1: tmp = Mid(tmp_NXTs(a).resstr, c, 1): Loop Until tmp = ":"
					c -= 1
					tmp_NXTs(a).Name = Mid(tmp_NXTs(a).resstr, b + 1, c - b)
					tmp_NXTs(a).connection = "on Bluetooth"
				Else
					tmp_NXTs(a).Name = "Unfamiliar NXT" 
					MutexLock(known_NXTs_lock)
					For d = 0 To UBound(known_NXTs)
						If known_NXTs(d).resstr = tmp_NXTs(a).resstr Then tmp_NXTs(a).Name = known_NXTs(d).Name
					Next	
					MutexUnLock(known_NXTs_lock)
					b = InStr(tmp_NXTs(a).resstr, ":") - 1
					tmp_NXTs(a).connection = "on " + Left(tmp_NXTs(a).resstr, b)
				End If
			Next

			If Not update_NXT_list_ending Then
				MutexLock(NXT_list_lock)
				NXTs_found = UBound(tmp_NXTs) + 1 
				ReDim NXTs(UBound(tmp_NXTs))
				For a = 0 To UBound(tmp_NXTs)
					NXTs(a) = tmp_NXTs(a)
					NXTs(a) = tmp_NXTs(a)
				Next
				MutexUnLock(NXT_list_lock)
			End If
				
		ElseIf status = NXT.Status.NoMoreItemsFound Then 
			NXTs_found = 0
			status = 0
		End If
		report_error()
		NXT.DestroyNXTIterator(NXTiter, @status)
		status = 0
		'report_error()
		Sleep list_update_delay, 1
	Loop Until update_NXT_list_ending
	update_NXT_list_ending = FALSE
End Sub



Function SelectionDlgProc(ByVal hwnd As HWND, ByVal umsg As UINT, ByVal wparam As WPARAM, ByVal lparam As LPARAM) As Integer
	Static As Integer o_NXTs_found, hidden
	Static As HMENU hmenu
	Static As HICON hicon
	Static As NXT_list_entry oldNXTs()

	Select Case umsg
		Case WM_INITDIALOG
			Dim As Integer sw, sh
			ScreenControl fb.GET_DESKTOP_SIZE, sw, sh
			sw \= 2: sh \= 2
			GetWindowRect(hwnd, @winpos)
			winpos.left = sw - (winpos.right - winpos.left) \ 2
			winpos.top = sh - (winpos.bottom - winpos.top) \ 2
			SetWindowPos(hwnd, NULL, winpos.left, winpos.top, NULL, NULL, SWP_ASYNCWINDOWPOS Or SWP_NOOWNERZORDER Or SWP_NOSIZE Or SWP_NOZORDER Or SWP_NOACTIVATE Or SWP_NOSENDCHANGING)

			SendMessage(hwnd, WM_SETICON, ICON_BIG, Cast(lparam, icons(0)))
			
			Dim As Integer sbparts(1) = {128, -1}
			SendDlgItemMessage(hwnd, SBR_SEL_STATUS, SB_SETPARTS, 2, Cast(lparam, @sbparts(0)))
			SendDlgItemMessage(hwnd, SBR_SEL_STATUS, SB_SETTEXT, 0, Cast(lparam, Cast(lparam, @"Searching for NXTs...")))

			o_NXTs_found = -2746

			SetTimer(hwnd, NULL, 128, NULL)
			AnimateWindow(hwnd, 512, 2 Or 8)

			Return TRUE
		Case WM_COMMAND
			Select Case LoWord(wParam)
				Case BTN_1 To BTN_40
					'A handy trick: I numbered the buttons sequentialy, so it's a matter of arithmatic to figure out which NXT to command.
					If NXTs_found < LoWord(wParam) - BTN_1 + 1 Then Return TRUE
					ThreadWait(update_info_thread)
					
					GetWindowRect(hwnd, @winpos)
					ShowWindow(hwnd, SW_HIDE)
					EnableWindow(hwnd, FALSE)
					
					update_info_ending = FALSE
					update_info_thread = ThreadCreate(Cast(Any Ptr, @update_NXT_info))
					
					NXT_to_command = LoWord(wParam) - BTN_1
					Dim As Integer ret
					ret = DialogBox(GetModuleHandle(NULL), MAKEINTRESOURCE(DLG_COMMAND), hwnd, @CommandDlgProc)
					If ret = IDOK Then
						For b As Integer = BTN_1 To BTN_40
						EnableWindow(GetDlgItem(hwnd, b), FALSE)
						SendDlgItemMessage(hwnd, b, WM_SETTEXT, NULL, Cast(lparam, @""))
						Next
						For n As Integer = 0 To NXTs_found - 1
							Dim As String tmp = NXTs(n).Name + !"\r\r" + NXTs(n).connection
							SendDlgItemMessage(hwnd, BTN_1 + n, WM_SETTEXT, 0, Cast(lparam, StrPtr(tmp)))
							EnableWindow(GetDlgItem(hwnd, BTN_1 + n), TRUE)
						Next
						SetWindowPos(hwnd, NULL, winpos.left, winpos.top, NULL, NULL, SWP_ASYNCWINDOWPOS Or SWP_NOOWNERZORDER Or SWP_NOSIZE Or SWP_NOZORDER Or SWP_NOACTIVATE Or SWP_NOSENDCHANGING)
					ElseIf ret <> IDCANCEL And ret <> IDOK Then
						MessageBox(NULL, "Dialog exited with unknown value. (error?)", "Notice", MB_OK Or MB_ICONINFORMATION)
					EndIf

					EnableWindow(hwnd, TRUE)
					ShowWindow(hwnd, SW_SHOW)
					Return TRUE
				Case BTN_SETTINGS
					settings(hwnd)
					Return TRUE
				Case BTN_FIRMWARE_S
					firmware_dl(hwnd, 0)
				Case MENU_OPEN
					SendMessage(hwnd, WM_TRAYICON, NULL, WM_LBUTTONDOWN)
				Case MENU_EXIT
					Dim As NOTIFYICONDATA nid
					With nid
						.cbSize = NOTIFYICONDATA_V3_SIZE
						.hwnd = hwnd
						.uID = 1
					End With
					Shell_NotifyIcon(NIM_DELETE, @nid)
					DestroyIcon(hicon)
					DestroyMenu(hmenu)
					update_NXT_list_ending = TRUE
					ending = TRUE 
					EndDialog(hwnd, IDCANCEL)
			End Select
		Case WM_TIMER
			If firstshow = TRUE And InStr(LCase(Command), "-background") > 0 Then
				firstshow = FALSE
				ShowWindow(hwnd, SW_HIDE)

				hidden = TRUE
				hicon = LoadIcon(GetModuleHandle(NULL), "SPIN_1")
				hmenu = CreatePopupMenu
				AppendMenu(hmenu, MF_STRING, MENU_OPEN, "Show Window")
				AppendMenu(hmenu, MF_SEPARATOR, NULL, NULL)
				AppendMenu(hmenu, MF_STRING, MENU_EXIT, "Exit")
				
				Dim As NOTIFYICONDATA nid
				With nid
					.cbSize = NOTIFYICONDATA_V3_SIZE
					.hwnd = hwnd
					.uFlags = NIF_ICON Or NIF_TIP Or NIF_MESSAGE
					.szTip = "NeXT Commander"
					.uID = 1
					.uCallbackMessage = WM_TRAYICON
					.hIcon = hicon
					.uVersion = NOTIFYICON_VERSION
				End With
				Shell_NotifyIcon(NIM_ADD, @nid)
				Shell_NotifyIcon(NIM_SETVERSION, @nid)
			EndIf
			
			If NXTs_found = -1 Then Return TRUE
			
			If o_NXTs_found <> NXTs_found Then
				For b As Integer = BTN_1 To BTN_40
					EnableWindow(GetDlgItem(hwnd, b), FALSE)
					SendDlgItemMessage(hwnd, b, WM_SETTEXT, NULL, Cast(lparam, @""))
				Next
				For n As Integer = 0 To NXTs_found - 1
					Dim As String tmp = NXTs(n).Name + !"\r\r" + NXTs(n).connection
					SendDlgItemMessage(hwnd, BTN_1 + n, WM_SETTEXT, 0, Cast(lparam, StrPtr(tmp)))
					EnableWindow(GetDlgItem(hwnd, BTN_1 + n), TRUE)
				Next
	
				Dim As String tmp
				If NXTs_found = 1 Then tmp = "1 NXT Found." Else tmp = Trim(Str(NXTs_found)) + " NXTs Found."
				SendDlgItemMessage(hwnd, SBR_SEL_STATUS, SB_SETTEXT, 0, Cast(lparam, StrPtr(tmp)))
				'SendDlgItemMessage(hwnd, SBR_SEL_STATUS, SB_SETTEXT, 1, @"USB0::0x0694::0x0002::00165307E6E2::RAW")
				
				o_NXTs_found = NXTs_found

				If NXTs_found > 0 Then
					If hidden = TRUE Then
						Dim As Integer n, o
						For n = 0 To UBound(NXTs)
							For o = 0 To UBound(oldNXTs)
								If NXTs(n).resstr = oldNXTs(o).resstr Then o = -1: Exit For
							Next
							If o > -1 Then
								If LCase(Left(NXTs(n).resstr, 3)) = "usb" Then
									If usb_action = 1 Then showstate = 1: SendMessage(hwnd, WM_TRAYICON, NULL, WM_LBUTTONDOWN)
									If usb_action = 2 Then showstate = 2: SendMessage(hwnd, WM_TRAYICON, NULL, WM_LBUTTONDOWN): SendMessage(hwnd, WM_COMMAND, BTN_1 + n, NULL)
								Else
									If bt_action = 1 Then showstate = 1: SendMessage(hwnd, WM_TRAYICON, NULL, WM_LBUTTONDOWN)
									If bt_action = 2 Then showstate = 2: SendMessage(hwnd, WM_TRAYICON, NULL, WM_LBUTTONDOWN): SendMessage(hwnd, WM_COMMAND, BTN_1 + n, NULL)
								EndIf
							EndIf
						Next
					EndIf

					ReDim oldNXTs(UBound(NXTs))
					For n As Integer = 0 To UBound(NXTs)
						oldNXTs(n) = NXTs(n)
					Next
				Else
					ReDim oldNXTs(0)
				EndIf
			EndIf
			Return TRUE
		Case WM_NOTIFY
			Dim As LPNMBCHOTITEM tmp = Cast(LPNMBCHOTITEM, lparam)
			If tmp->hdr.idFrom >= BTN_1 And tmp->hdr.idFrom <= BTN_40 Then
				If tmp->hdr.code = BCN_HOTITEMCHANGE Then
					'Hovered button changed; update statusbar...
					If tmp->dwflags And HICF_ENTERING Then
						If tmp->hdr.idFrom - BTN_1 < NXTs_found Then SendDlgItemMessage(hwnd, SBR_SEL_STATUS, SB_SETTEXT, 1, Cast(lparam, @NXTs(tmp->hdr.idFrom - BTN_1).resstr))
					ElseIf tmp->dwflags And HICF_LEAVING Then
						SendDlgItemMessage(hwnd, SBR_SEL_STATUS, SB_SETTEXT, 1, Cast(lparam, @""))
					EndIf
				EndIf
			EndIf
		Case WM_TRAYICON
			If lparam = WM_RBUTTONDOWN Then
				Dim As Point p
				GetCursorPos(@p)
				TrackPopupMenu(hmenu, TPM_LEFTALIGN Or TPM_RIGHTBUTTON, p.x, p.y, NULL, hwnd, NULL)
			ElseIf lparam = WM_LBUTTONDOWN Then
				Dim As NOTIFYICONDATA nid
				With nid
					.cbSize = NOTIFYICONDATA_V3_SIZE
					.hwnd = hwnd
					.uID = 1
				End With
				Shell_NotifyIcon(NIM_DELETE, @nid)
				DestroyIcon(hicon)
				DestroyMenu(hmenu)

				If showstate = 0 Or showminimized = FALSE Then
					ShowWindow(hwnd, SW_SHOW)
					ShowWindow(hwnd, SW_RESTORE)
					showstate = 0
				ElseIf showstate = 1 And showminimized = TRUE Then
					ShowWindow(hwnd, SW_SHOW)
					Dim As FLASHWINFO fwi
					With fwi
						.cbSize = SizeOf(FLASHWINFO)
						.hwnd = hwnd
						.dwFlags = &hc Or 2 'FLASHW_TIMERNOFG Or FLASHW_TRAY
					End With
					FlashWindowEx(@fwi)
					showstate = 0
				ElseIf showstate = 2 Then
					ShowWindow(hwnd, SW_RESTORE)
				EndIf
				hidden = FALSE
			EndIf
			
			Return TRUE
		Case TASKBAR_RESTART
			'Explorer was restarted. Have to recreate the tray icon, if we're hidden.
			If hidden Then
				Dim As NOTIFYICONDATA nid
				With nid
					.cbSize = NOTIFYICONDATA_V3_SIZE
					.hwnd = hwnd
					.uFlags = NIF_ICON Or NIF_TIP Or NIF_MESSAGE
					.szTip = "NeXT Commander"
					.uID = 1
					.uCallbackMessage = WM_TRAYICON
					.hIcon = hicon
					.uVersion = NOTIFYICON_VERSION
				End With
				Shell_NotifyIcon(NIM_ADD, @nid)
				Shell_NotifyIcon(NIM_SETVERSION, @nid)
			EndIf
		Case WM_CLOSE			
			If hide_on_close = TRUE Then
				hidden = TRUE
				hicon = LoadIcon(GetModuleHandle(NULL), "SPIN_1")
				hmenu = CreatePopupMenu
				AppendMenu(hmenu, MF_STRING, MENU_OPEN, "Show Window")
				AppendMenu(hmenu, MF_SEPARATOR, NULL, NULL)
				AppendMenu(hmenu, MF_STRING, MENU_EXIT, "Exit")
				
				Dim As NOTIFYICONDATA nid
				With nid
					.cbSize = NOTIFYICONDATA_V3_SIZE
					.hwnd = hwnd
					.uFlags = NIF_ICON Or NIF_TIP Or NIF_MESSAGE
					.szTip = "NeXT Commander"
					.uID = 1
					.uCallbackMessage = WM_TRAYICON
					.hIcon = hicon
					.uVersion = NOTIFYICON_VERSION
				End With
				Shell_NotifyIcon(NIM_ADD, @nid)
				Shell_NotifyIcon(NIM_SETVERSION, @nid)
				
				ShowWindow(hwnd, SW_MINIMIZE)
				ShowWindow(hwnd, SW_HIDE)
			Else
				AnimateWindow(hwnd, 512, &h00010000 Or 2 Or 8)
				update_NXT_list_ending = TRUE
				ending = TRUE 
				EndDialog(hwnd, IDCANCEL)
			EndIf
	End Select
	Return FALSE
End Function
