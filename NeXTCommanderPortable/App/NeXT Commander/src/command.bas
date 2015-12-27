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


Function CommandDlgProc(ByVal hwnd As HWND, ByVal umsg As UINT, ByVal wparam As WPARAM, ByVal lparam As LPARAM) As Integer
	Static As Integer icon, watch_name, editing_name
	Static As String oldfreespace
	Select Case uMsg
		Case WM_INITDIALOG
			leaving_command_seceen = FALSE
		
			SetWindowPos(hwnd, NULL, winpos.left, winpos.top, NULL, NULL, SWP_ASYNCWINDOWPOS Or SWP_NOOWNERZORDER Or SWP_NOSIZE Or SWP_NOZORDER Or SWP_NOACTIVATE Or SWP_NOSENDCHANGING)
			If showstate = 2 And showminimized Then
				ShowWindow(hwnd, SW_MINIMIZE)
				ShowWindow(hwnd, SW_SHOW)
				Dim As FLASHWINFO fwi
				With fwi
					.cbSize = SizeOf(FLASHWINFO)
					.hwnd = hwnd
					.dwFlags = &hc Or 2 'FLASHW_TIMERNOFG Or FLASHW_TRAY
				End With
				FlashWindowEx(@fwi)
				showstate = 0
			EndIf

			Dim As Integer sbparts(1) = {200, -1}
			SendDlgItemMessage(hwnd, SBR_CMD_STATUS, SB_SETPARTS, 2, Cast(lparam, @sbparts(0)))
			SendDlgItemMessage(hwnd, SBR_CMD_STATUS, SB_SETTEXT, 0, Cast(lparam, @"Retrieving information..."))
			SendDlgItemMessage(hwnd, SBR_CMD_STATUS, SB_SETTEXT, 1, Cast(lparam, StrPtr(NXTs(NXT_to_command).resstr)))

			MutexLock(NXT_info_lock)
			If NXTs(NXT_to_command).Name = "Unfamiliar NXT" Then watch_name = TRUE
			Dim As String tmp = NXTs(NXT_to_command).Name + " - NeXT Commander"
			SendMessage(hwnd, WM_SETTEXT, NULL, Cast(lparam, StrPtr(tmp)))
			MutexUnLock(NXT_info_lock)

			SendDlgItemMessage(hwnd, LSV_FILES, LVM_SETEXTENDEDLISTVIEWSTYLE, NULL, LVS_EX_FULLROWSELECT) 'or LVS_EX_DOUBLEBUFFER ''enables prettier selection rect
			Dim As LVCOLUMN lvc
			With lvc
				.mask = LVCF_TEXT
				.pszText = @""
			End With
			SendDlgItemMessage(hwnd, LSV_FILES, LVM_INSERTCOLUMN, 0, Cast(lparam, @lvc))
			With lvc
				.mask = LVCF_TEXT Or LVCF_WIDTH' Or LVCF_FMT
				.pszText = @"Name"
				.cx = 190
				.fmt = HDF_SORTUP Or HDF_SORTDOWN
			End With
			SendDlgItemMessage(hwnd, LSV_FILES, LVM_INSERTCOLUMN, 1, Cast(lparam, @lvc))
			SendDlgItemMessage(hwnd, LSV_FILES, LVM_DELETECOLUMN, 0, NULL)
			With lvc
				.mask = LVCF_TEXT Or LVCF_WIDTH' Or LVCF_FMT
				.pszText = @"Size"
				.cx = 80
				.fmt = HDF_SORTUP Or HDF_SORTDOWN
			End With
			SendDlgItemMessage(hwnd, LSV_FILES, LVM_INSERTCOLUMN, 2, Cast(lparam, @lvc))

			DragAcceptFiles(hwnd, TRUE)
			
			If NXTs(NXT_to_command).connection = "on Bluetooth" Then EnableWindow(GetDlgItem(hwnd, BTN_FIRMWARE_C), FALSE)

			editing_name = FALSE
			
			If UBound(plugins) > 0 Then
				ShowWindow(GetDlgItem(hwnd, GRP_PLUGINS), SW_SHOW)
				For p As Integer = 0 To UBound(plugins) - 1
					If p > 8 Then Exit For
					SendDlgItemMessage(hwnd, BTN_PLUGIN1 + p, WM_SETTEXT, NULL, Cast(LPARAM, StrPtr(plugins(p).info.title)))
					ShowWindow(GetDlgItem(hwnd, BTN_PLUGIN1 + p), SW_SHOW)
				Next
			EndIf

			SetTimer(hwnd, 0, 128, NULL)
			SetTimer(hwnd, 1, 128, NULL)


			Return TRUE
		Case WM_COMMAND
			Select Case LoWord(wParam)
				Case BTN_DELETE
					nxt_operation(1, hwnd)
					Return TRUE
				Case BTN_EXECUTE
					nxt_operation(3, hwnd)
					Return TRUE
				Case BTN_UPLOAD
					nxt_operation(2, hwnd)
					Return TRUE
				Case BTN_DOWNLOAD
					nxt_operation(5, hwnd)
					Return TRUE
				Case BTN_RENAME
					If editing_name = FALSE Then
						SendDlgItemMessage(hwnd, BTN_RENAME, WM_SETTEXT, NULL, Cast(lparam, @"Rename"))
						ShowWindow(GetDlgItem(hwnd, EDT_NAME), SW_SHOW)
						ShowWindow(GetDlgItem(hwnd, IDCANCEL), SW_SHOW)
						editing_name = TRUE
					Else
						Dim As ZString * 256 newname = ""
						GetDlgItemText(hwnd, EDT_NAME, @newname, SizeOf(newname))
						If newname = "" Then
							MessageBox(hwnd, "The name cannot be blank.", "NeXT Commander", MB_OK Or MB_ICONSTOP): Return TRUE
						EndIf
						If Len(newname) > 15 Then
							MessageBox(hwnd, "This name is too long. You may not use more than fifteen characters.", "NeXT Commander", MB_OK Or MB_ICONSTOP)
							Return TRUE
						EndIf
						If InStr(newname, Any !":*\<>?\"") Then
							If MessageBox(hwnd, !"The name you entered contains one or more of the following characters:   *:\<>?\"\nYou can try To use This Name, but it could cause problems.", "Next Commander", MB_OKCANCEL Or MB_ICONWARNING Or MB_DEFBUTTON2) = IDCANCEL Then Return TRUE
						EndIf
						If Len(newname) > 8 Then
							If MessageBox(hwnd, !"You may use this name, but only the first eight characters will be visible on the NXT's screen.", "NeXT Commander", MB_OKCANCEL Or MB_ICONINFORMATION) = IDCANCEL Then Return TRUE
						EndIf
						SendDlgItemMessage(hwnd, BTN_RENAME, WM_SETTEXT, NULL, Cast(lparam, @"Rename NXT"))
						SendDlgItemMessage(hwnd, EDT_NAME, WM_SETTEXT, NULL, Cast(lparam, @""))
						ShowWindow(GetDlgItem(hwnd, EDT_NAME), SW_HIDE)
						ShowWindow(GetDlgItem(hwnd, IDCANCEL), SW_HIDE)
						nxt_operation(7, hwnd,, newname)
						Dim As String tmp = NXTs(NXT_to_command).Name + " - NeXT Commander"
						SendMessage(hwnd, WM_SETTEXT, NULL, Cast(lparam, StrPtr(tmp)))
						editing_name = FALSE
					EndIf
					Return TRUE
				Case IDCANCEL
					ShowWindow(GetDlgItem(hwnd, EDT_NAME), SW_HIDE)
					ShowWindow(GetDlgItem(hwnd, IDCANCEL), SW_HIDE)
					SendDlgItemMessage(hwnd, BTN_RENAME, WM_SETTEXT, NULL, Cast(lparam, @"Rename NXT"))
					SendDlgItemMessage(hwnd, EDT_NAME, WM_SETTEXT, NULL, Cast(lparam, @""))
					editing_name = FALSE
				Case BTN_FIRMWARE_C
					firmware_dl(hwnd, 1)
				Case BTN_STOP
					nxt_operation(8, hwnd)
				Case BTN_STOPSND
					nxt_operation(9, hwnd)
				Case BTN_MONITOR
					ThreadCreate(Cast(Any Ptr, @monitor))
				Case BTN_RC1
					ThreadCreate(Cast(Any Ptr, @rc1), Cast(Any Ptr, hwnd))
				Case BTN_RC2
					ThreadCreate(Cast(Any Ptr, @rc2), Cast(Any Ptr, hwnd))
				Case BTN_RC3
					ThreadCreate(Cast(Any Ptr, @rc3), Cast(Any Ptr, hwnd))
				Case BTN_PLUGIN1 To BTN_PLUGIN9
					plugins(LoWord(wParam) - BTN_PLUGIN1).action(hNXT, @leaving_command_seceen)
				Case Else
			End Select
		Case WM_TIMER
			If wparam = 0 Then
				SendMessage(hwnd, WM_SETICON, ICON_BIG, Cast(lparam, icons(icon)))
				icon += 1
				If icon > 15 Then icon = 0
			ElseIf wparam = 1 Then
				If update_info_ending Then Return SendMessage(hwnd, WM_CLOSE, NULL, NULL)
				If info_has_changed = FALSE Then Return TRUE
				EnableWindow(hwnd, TRUE)

				MutexLock(NXT_info_lock)
				If watch_name Then
					If NXTs(NXT_to_command).Name <> "Unfamiliar NXT" Then
						watch_name = FALSE
						Dim As String tmp = NXTs(NXT_to_command).Name + " - NeXT Commander"
						SendMessage(hwnd, WM_SETTEXT, NULL, Cast(lparam, StrPtr(tmp)))
					EndIf
				EndIf
				SendDlgItemMessage(hwnd, SBR_CMD_STATUS, SB_SETTEXT, 0, Cast(lparam, @""))
				SendDlgItemMessage(hwnd, STC_BATTERY, WM_SETTEXT, NULL, Cast(lparam, StrPtr(battery)))
				SendDlgItemMessage(hwnd, STC_RUNNINGPROG, WM_SETTEXT, NULL, Cast(lparam, StrPtr(running_program)))
				SendDlgItemMessage(hwnd, STC_FREESPACE, WM_SETTEXT, NULL, Cast(lparam, StrPtr(free_flash)))
				SendDlgItemMessage(hwnd, STC_BTADDR, WM_SETTEXT, NULL, Cast(lparam, StrPtr(bluetooth_address)))
				SendDlgItemMessage(hwnd, STC_BTS0, WM_SETTEXT, NULL, Cast(lparam, StrPtr(signal_strengths(0))))
				SendDlgItemMessage(hwnd, STC_BTS1, WM_SETTEXT, NULL, Cast(lparam, StrPtr(signal_strengths(1))))
				SendDlgItemMessage(hwnd, STC_BTS2, WM_SETTEXT, NULL, Cast(lparam, StrPtr(signal_strengths(2))))
				SendDlgItemMessage(hwnd, STC_BTS3, WM_SETTEXT, NULL, Cast(lparam, StrPtr(signal_strengths(3))))
				SendDlgItemMessage(hwnd, STC_FWVER, WM_SETTEXT, NULL, Cast(lparam, StrPtr(firmware_version)))
				SendDlgItemMessage(hwnd, STC_PROTOVER, WM_SETTEXT, NULL, Cast(lparam, StrPtr(protocol_version)))
				If oldfreespace <> free_flash Or reload_files Then
					Dim As Integer ti = SendDlgItemMessage(hwnd, LSV_FILES, LVM_GETTOPINDEX, NULL, NULL)
					SendDlgItemMessage(hwnd, LSV_FILES, LVM_DELETEALLITEMS, NULL, NULL)
					Dim As LVITEM lvi
					For i As Integer = 0 To UBound(files)
						With lvi
							.mask = LVIF_TEXT Or LVIF_PARAM
							.iItem = i
							.lParam = i
							.iSubItem = 0
							.pszText = @files(i).Name
						End With
						Dim As Integer ip = SendDlgItemMessage(hwnd, LSV_FILES, LVM_INSERTITEM, NULL, Cast(lparam, @lvi))
						Dim As String tmp
						If files(i).size < 1024 Then tmp = Trim(Str(files(i).size)) + " B" Else tmp = Trim(Str(Int(files(i).size / 1024))) + Left(Trim(Str(Frac(files(i).size / 1024))), 4) + " KB"
						With lvi
							.mask = LVIF_TEXT
							.iItem = ip
							.iSubItem = 1
							.pszText = StrPtr(tmp)
						End With
						SendDlgItemMessage(hwnd, LSV_FILES, LVM_SETITEM, NULL, Cast(lparam, @lvi))
					Next
					SendDlgItemMessage(hwnd, LSV_FILES, LVM_ENSUREVISIBLE , ti, TRUE)
					oldfreespace = free_flash
				EndIf
				If running_program <> "(None)" Then EnableWindow(GetDlgItem(hwnd, BTN_STOP), TRUE) Else EnableWindow(GetDlgItem(hwnd, BTN_STOP), FALSE)
				info_has_changed = FALSE
				MutexUnLock(NXT_info_lock)
				SendDlgItemMessage(hwnd, SBR_CMD_STATUS, SB_SETTEXT, 0, Cast(lparam, @""))
				Return TRUE
			EndIf
		Case WM_NOTIFY
			Dim As NMLVDISPINFO Ptr tmp = Cast(NMLVDISPINFO Ptr, lparam)
			If tmp->hdr.idFrom = LSV_FILES Then
				Select Case tmp->hdr.code
					Case LVN_ENDLABELEDIT
						If tmp->item.pszText = NULL Then Return FALSE
						Dim As String txt = *Cast(ZString Ptr, tmp->item.pszText)
							Dim As Integer i = tmp->item.iItem
							Dim As LVITEM lvi
							With lvi
								.mask = LVIF_PARAM
								.iItem = i
								.iSubItem = 0
							End With
							SendDlgItemMessage(hwnd, LSV_FILES, LVM_GETITEM, i, Cast(LPARAM, @lvi))
							nxt_operation(4, hwnd, files(lvi.lParam).name, *Cast(ZString Ptr, tmp->item.pszText))
							free_flash = "Updating..."
							info_has_changed = TRUE
							SetWindowLong(hwnd, DWL_MSGRESULT, TRUE)
							Return TRUE
					Case NM_CLICK
						Dim As Integer selcount
						Dim As ZString * 19 txt
						Dim As String ext
						Dim As LVITEM lvi
						For a As Integer = 0 To SendDlgItemMessage(hwnd, LSV_FILES, LVM_GETITEMCOUNT, 0, 0) - 1
							If SendDlgItemMessage(hwnd, LSV_FILES, LVM_GETITEMSTATE, a, LVIS_SELECTED) Then
								selcount += 1
								With lvi
									.iItem = a
									.iSubItem = 0
									.pszText = @txt
									.cchTextMax = 19
								End With
								SendDlgItemMessage(hwnd, LSV_FILES, LVM_GETITEMTEXT, a, Cast(LPARAM, @lvi))
								ext = LCase(Right(txt, 4))
							EndIf
							If selcount > 1 Then Exit For
						Next
						If selcount = 0 Then
							EnableWindow(GetDlgItem(hwnd, BTN_DELETE), FALSE)
							EnableWindow(GetDlgItem(hwnd, BTN_EXECUTE), FALSE)
							EnableWindow(GetDlgItem(hwnd, BTN_UPLOAD), FALSE)
						ElseIf selcount = 1 Then
							EnableWindow(GetDlgItem(hwnd, BTN_DELETE), TRUE)
							If ext = ".rso" Or ext = ".rxe" Or ext = ".rtm" Or ext = ".nxj" Or ext = ".wav" Then EnableWindow(GetDlgItem(hwnd, BTN_EXECUTE), TRUE) Else EnableWindow(GetDlgItem(hwnd, BTN_EXECUTE), FALSE)
							EnableWindow(GetDlgItem(hwnd, BTN_UPLOAD), TRUE)
						ElseIf selcount > 1 Then
							EnableWindow(GetDlgItem(hwnd, BTN_DELETE), TRUE)
							EnableWindow(GetDlgItem(hwnd, BTN_EXECUTE), FALSE)
							EnableWindow(GetDlgItem(hwnd, BTN_UPLOAD), TRUE)
						EndIf
					Case NM_DBLCLK
						nxt_operation(3, hwnd)
				End Select
			EndIf
			Return FALSE
		Case WM_DROPFILES
			If MessageBox(hwnd, "Download the dropped files?", "NeXT Commander", MB_OK Or MB_ICONQUESTION Or MB_YESNO Or MB_SETFOREGROUND) = IDNO Then DragFinish(Cast(hdrop, wparam)): Return FALSE
			nxt_operation(6, hwnd,,, Cast(HDROP, wparam))
			oldfreespace = ""
			free_flash = "Updating..."
			info_has_changed = TRUE
		Case WM_CLOSE
			oldfreespace = "~NEEDRELOAD~"
			update_info_ending = TRUE
			leaving_command_seceen = TRUE
			DragAcceptFiles(hwnd, FALSE)
			GetWindowRect(hwnd, @winpos)
			EndDialog(hwnd, IDOK)
			Sleep 1
			ReDim monitors(0)
			ReDim rc2s(0)
	End Select
	Return FALSE
End Function



Sub update_NXT_info
	Dim As Integer ierror, a, checked_if_known, is_known, status
	Dim As NXT.hFileIterator iter
	Dim As UByte cmd_get_bat = &hb, cmd_get_prog = &h11, retbuf(), addr(5), sigstren(3), fwmajor, fwminor, protomajor,_
				protominor
	Dim As UInteger bat, avflash, oldavflash = -999, oldbat
	Dim As ZString * 256 resnam, presnam, npresnam
	Dim As ZString * 5 nampat = "*.*"
	Dim As ZString * 16 nam
	Dim As String curprog, oldcurprog, tmp
	Dim As fileinfo tmp_files()
	
	
	MutexLock(NXT_list_lock)
	resnam = NXTs(NXT_to_command).resstr
	MutexUnLock(NXT_list_lock)
	
	npresnam = resnam
	If NXT.IsPaired(@resnam, @status) = FALSE Then
		report_error()
		If DialogBox(GetModuleHandle(NULL), MAKEINTRESOURCE(DLG_PASSKEY), NULL, @PasskeyDlgProc) = IDCANCEL Then 
			update_info_ending = TRUE
			Exit Sub
		EndIf
		NXT.Pair(@resnam, @passkey, @presnam, @status)
		report_error()
		resnam = presnam 
	End If
	hNXT = NXT.CreateNXT(@resnam, @status, TRUE)
	report_error()

	If status = 0 Then
		NXT.GetFirmwareVersion(hNXT, @protomajor, @protominor, @fwmajor, @fwminor, @status)
		report_error()
		If status <= -1000000000 Then
			update_info_ending = TRUE
			GoTo skipupdate
		End If
		MutexLock(NXT_info_lock)
		protocol_version = Trim(Str(protomajor)) + "." + Trim(Str(protominor))
		firmware_version = Trim(Str(fwmajor)) + "." + Trim(Str(fwminor))
		MutexUnLock(NXT_info_lock)

		Do
			startinfoloop:
			ReDim retbuf(3)
			NXT.SendDirectCommand(hNXT, TRUE, @cmd_get_bat, 1, @retbuf(0), 4, @status)
			'Print
			'Print
			'Print status 
			If status = -1073807298 Then
				status = 0
			ElseIf status <= -1000000000 Then
				update_info_ending = TRUE
				GoTo skipupdate
			Else
				report_error()
			End If
			bat = retbuf(3) Shl 8 Or retbuf(2)

			ReDim retbuf(21)
			NXT.SendDirectCommand(hNXT, TRUE, @cmd_get_prog, 1, @retbuf(0), 22, @status)
			'Print status
			If status = -1073807298 Then
				status = 0
			ElseIf status <= -1000000000 Then
				update_info_ending = TRUE
				GoTo skipupdate
			Else
				report_error()
			End If
			oldcurprog = curprog
			curprog = ""
			For a = 2 To 21
				If retbuf(a) > 0 Then curprog += Chr(retbuf(a)) Else Exit For
			Next

			NXT.GetNXTInfo(hNXT, @nam, @addr(0), @sigstren(0), @avflash, @status)
			'Print status
			If status = -1073807298 Then
				status = 0
			ElseIf status <= -1000000000 Then
				update_info_ending = TRUE
				GoTo skipupdate
			Else
				report_error()
			End If

			'status = 0

			If avflash <> oldavflash Or reload_files = TRUE Then
				ReDim tmp_files(0)
				iter = NXT.CreateFileIterator(hNXT, @nampat, @status)
				If status <> NXT.Status.FWFileNotFound Then
					Do
						NXT.GetFileNameFromIterator(iter, @tmp_files(UBound(tmp_files)).name, @status)
						report_error()
		                tmp_files(UBound(tmp_files)).size = NXT.GetFileSizeFromIterator(iter, @status)
		                ReDim Preserve tmp_files(UBound(tmp_files) + 1)
		                NXT.AdvanceFileIterator(iter, @status)
					Loop Until status <> 0
		        	If status = NXT.Status.FWFileNotFound Or status = NXT.Status.FWFileNotLinear Then status = 0
		        	report_error()
		        	NXT.DestroyFileIterator(hNXT, iter, @status)
		        	report_error()
		        	ReDim Preserve tmp_files(UBound(tmp_files) - 1)
				End If
				If status = NXT.Status.FWFileNotFound Then status = 0
				report_error()
			End If
			
			
			
			
			MutexLock(NXT_info_lock)
			If reload_files = TRUE Then MutexUnLock(NXT_info_lock): reload_files = FALSE: avflash = -10: GoTo skipupdate

			If oldcurprog <> curprog Then info_has_changed = TRUE
			If oldbat <> bat Then info_has_changed = TRUE
			battery = Left(Trim(Str(bat / 1000) + "000"), 5) + " V"
			oldbat = bat
			friendly_name = Trim(nam)
			bt_addr(0) = addr(0): bt_addr(1) = addr(1): bt_addr(2) = addr(2): bt_addr(3) = addr(3)
			bt_addr(4) = addr(4): bt_addr(5) = addr(5)
			For a = 0 To 3
				tmp = Trim(Str(CInt(sigstren(a) / 255 * 100))) + "%"
				'tmp = Trim(Str(sigstren(a)))
				If signal_strengths(a) <> tmp Then info_has_changed = TRUE
				signal_strengths(a) = tmp
			Next
			If avflash < 1024 Then free_flash = Trim(Str(avflash)) + " B" Else free_flash = Left(Trim(Str(avflash / 1024)), 6) + " KB"
			If curprog = "" Then running_program = "(None)" Else running_program = curprog
			bluetooth_address = Hex(addr(0)) + ":" + Hex(addr(1)) + ":" + Hex(addr(2)) + ":" + Hex(addr(3)) + ":" + Hex(addr(4)) + ":" + Hex(addr(5))

			If avflash <> oldavflash Or reload_files = TRUE Then
				ReDim Files(UBound(tmp_files))
				For a = 0 To UBound(tmp_files)
					Files(a) = tmp_files(a)
				Next
				oldavflash = avflash
				info_has_changed = TRUE
				reload_files = FALSE
			End If

			If Not checked_if_known Then
				For a = 0 To UBound(known_NXTs)
					If known_NXTs(a).resstr = npresnam Then is_known = TRUE
				Next
				If is_known = FALSE Then
					If known_NXTs(0).Name <> "" Then ReDim Preserve known_NXTs(UBound(known_NXTs) + 1)
					NXTs(NXT_to_command).Name = nam
					known_NXTs(UBound(known_NXTs)).Name = nam
					known_NXTs(UBound(known_NXTs)).resstr = npresnam
					'known_NXTs(UBound(known_NXTs), 0) =   'passkey
					known_NXTs_has_changed = TRUE
					info_has_changed = TRUE
				End If
				checked_if_known = TRUE
			End If		
			MutexUnLock(NXT_info_lock) 
			
			Sleep info_update_delay, 1
			skipupdate:
		Loop Until update_info_ending
		
		While hNXT_usecount > 0
			Sleep 4
		Wend
		NXT.DestroyNXT(hNXT, @status)
		report_error()
	Else
		update_info_ending = TRUE
	End If
End Sub
