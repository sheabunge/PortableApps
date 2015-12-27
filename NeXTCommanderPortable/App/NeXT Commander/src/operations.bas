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


Function nxt_operation(whatkind As Byte, hwnd As HWND, oldname As String = "", newname As String = "", hdrop As HDROP = NULL) As Byte
	'This does most of the work for the command screen.
	
	Dim As Integer ierror, a, checked_if_known, is_known, ok, file_size, leaving_folder_sel, mbret, cancel, status
	Dim As NXT.hFile file
	Dim As ZString * 256 resnam, presnam, npresnam
	Dim As ZString * 4 nampat = "*.*"
	Dim As BROWSEINFO bi
    Dim As LPITEMIDLIST shlret
    Dim As OPENFILENAME ofn
    Dim As String fl, fn, ft
    Dim As ZString * MAX_PATH + 1 path
    Static As Integer dontlock


	KillTimer(hwnd, 1)
	If dontlock = FALSE Then MutexLock(NXT_info_lock)
	MutexLock(NXT_list_lock)
	resnam = NXTs(NXT_to_command).resstr
	MutexUnLock(NXT_list_lock)

	If status = 0 Then
	    Select Case whatkind
	    	Case 1
	    		'Delete.
	            mbret = MessageBox(hwnd, "Really delete the selected file(s)?", "NeXT Commander", MB_YESNO Or MB_ICONQUESTION) ' Or MB_SETFOREGROUND
	            If mbret = IDYES Then
		            Dim As lvitem lvi
		    		Dim As Integer f
					For a As Integer = 0 To SendDlgItemMessage(hwnd, LSV_FILES, LVM_GETITEMCOUNT, 0, 0) - 1
						If (SendDlgItemMessage(hwnd, LSV_FILES, LVM_GETITEMSTATE, a, LVIS_SELECTED) And LVIS_SELECTED) Then
							With lvi
								.mask = LVIF_PARAM
								.iItem = a
								.iSubItem = 0
							End With
							SendDlgItemMessage(hwnd, LSV_FILES, LVM_GETITEM, a, Cast(LPARAM, @lvi))
							f = lvi.lparam
				            file = NXT.CreateFile(hNXT, @files(f).Name, @status)
				            report_error()
				            If status = 0 Then
				            	SendDlgItemMessage(hwnd, SBR_CMD_STATUS, SB_SETTEXT, 0, Cast(lparam, @"Deleting..."))
				            	NXT.DeleteFile(file, @status)
				            	report_error()
				            	If status = 0 Then SendDlgItemMessage(hwnd, LSV_FILES, LVM_DELETEITEM, a, NULL)
				            	If status = NXT.Status.FWFileIsBusy Then status = 0
				            	'If status <> 0 Then MessageBox(hwnd, "Unable to remove file!", "NeXT Commander", MB_OK Or MB_ICONERROR Or MB_SETFOREGROUND)
				            	NXT.DestroyFile(hNXT, file, @status)
				            	report_error()
				            	reload_files = TRUE
				            Else
				            	MessageBox(hwnd, "Unable to create file object!", "NeXT Commander", MB_OK Or MB_ICONERROR Or MB_SETFOREGROUND)
				            End If
						EndIf
					Next
	            End If
	    	Case 2
	    		'Upload.
	            bi.hwndOwner = hwnd
                bi.lpszTitle = @"Where should the uploaded file(s) be placed?"
                bi.ulFlags = BIF_USENEWUI Or BIF_RETURNONLYFSDIRS Or BIF_VALIDATE
                
                'Get the path...
                Do
                    ok = FALSE: cancel = FALSE: leaving_folder_sel = FALSE
                    shlret = SHBrowseForFolder(@bi) 
                    If shlret = NULL Then
                        leaving_folder_sel = TRUE
                        cancel = TRUE
                    Else
                        SHGetPathFromIDList(shlret, path) 
                        CoTaskMemFree(shlret)
                        If path = "" Then
                        	MessageBox(hwnd, "Invalid location!", "NeXT Commander", MB_OK Or MB_ICONERROR Or MB_SETFOREGROUND)
                        Else	
                        	ok = TRUE: leaving_folder_sel = TRUE
                        End If
                    End If
                Loop Until leaving_folder_sel

	        	If ok Then
	        		'Upload!
	        		Dim As lvitem lvi
		    		Dim As Integer f, b
					For a As Integer = 0 To SendDlgItemMessage(hwnd, LSV_FILES, LVM_GETITEMCOUNT, 0, 0) - 1
						If (SendDlgItemMessage(hwnd, LSV_FILES, LVM_GETITEMSTATE, a, LVIS_SELECTED) And LVIS_SELECTED) Then
							With lvi
								.mask = LVIF_PARAM
								.iItem = a
								.iSubItem = 0
							End With
							SendDlgItemMessage(hwnd, LSV_FILES, LVM_GETITEM, a, Cast(LPARAM, @lvi))
							f = lvi.lparam
			        		If FileExists(Trim(path) + "\" + files(f).Name) Then
		                		mbret = MessageBox(hwnd, "File already exists. Overwrite?", "NeXT Commander", MB_YESNO Or MB_ICONQUESTION Or MB_SETFOREGROUND)
		            			If mbret = IDNO Then GoTo skip
			        		End If
			        		SendDlgItemMessage(hwnd, SBR_CMD_STATUS, SB_SETTEXT, 0, Cast(lparam, @"Uploading..."))
				            file = NXT.CreateFile(hNXT, @files(f).Name, @status)
				            report_error()
				            file_size = NXT.GetFileSize(file, @status)
				            report_error()
				            Dim filebuf(file_size - 1) As UByte
				            NXT.OpenFileForRead(file, @status)
				            report_error()
				            NXT.ReadFile(file, @filebuf(0), file_size, @status)
				            report_error()
				            NXT.CloseFile(file, @status)
				            report_error()
				            NXT.DestroyFile(hNXT, file, @status)
				            report_error()
				            Open path + "\" + files(f).Name For Binary Access write As #1
				            If Err = 0 Then
				            	Put #1,, filebuf()
				            	Close #1
				            Else
				            	MessageBox(hwnd, "Unable to create file!", "NeXT Commander", MB_OK Or MB_ICONERROR Or MB_SETFOREGROUND)
				            End If
						EndIf
						skip:
				    Next
	        	End If
	    	Case 3
	    		'Start program or sound.
	    		Dim As lvitem lvi
	    		Dim As Integer f, b
				For a As Integer = 0 To SendDlgItemMessage(hwnd, LSV_FILES, LVM_GETITEMCOUNT, 0, 0) - 1
					If SendDlgItemMessage(hwnd, LSV_FILES, LVM_GETITEMSTATE, a, LVIS_SELECTED) Then
						With lvi
							.mask = LVIF_PARAM
							.iItem = a
							.iSubItem = 0
						End With
						SendDlgItemMessage(hwnd, LSV_FILES, LVM_GETITEM, a, Cast(LPARAM, @lvi))
						f = lvi.lparam
			    		Select Case LCase(Right(files(f).Name, 4))
			    			Case ".rxe", ".rtm", ".nxj"
			    				'Program.
			    				If running_program <> "(None)" Then
			    					If MessageBox(hwnd, "A program is already running. Cancel it?", "NeXT Commander", MB_ICONQUESTION Or MB_YESNO) = IDYES Then
			    						dontlock = TRUE
			    						nxt_operation(8, hwnd)
			    						dontlock = FALSE
			    						Sleep 1000
			    					Else
			    						GoTo finish
			    					EndIf
			    				EndIf

			    				Dim As UByte spdc (20)
			    				For b = 1 To Len(files(f).Name)
			    					spdc(b) = Asc(Mid(files(f).Name, b, 1))
			    				Next
			    				NXT.SendDirectCommand(hNXT, FALSE, @spdc(0), 21, NULL, NULL, @status)
			    				report_error()
			    			Case ".rso", ".wav"
			    				'Sound.
			    				Dim As UByte psdc (21)
			    				psdc(0) = 2
			    				For b = 1 To Len(files(f).Name)
			    					psdc(b + 1) = Asc(Mid(files(f).Name, b, 1))
			    				Next
			    				NXT.SendDirectCommand(hNXT, FALSE, @psdc(0), 22, NULL, NULL, @status)
			    				report_error()
			    		End Select
					EndIf
				Next
	    	Case 4
	    		'Rename. (file)
	    		file = NXT.CreateFile(hNXT, StrPtr(newname), @status)
	    		report_error()
        		NXT.OpenFileForWrite(file, file_size, @status)
        		If status = NXT.Status.FileIsEmpty Then status = 0
        		If status = NXT.Status.FWFileAlreadyExists Then
        			status = 0
        			NXT.CloseFile(file, @status)
        			report_error()
        			mbret = MessageBox(hwnd, "A file with this name already exists.", "NeXT Commander", MB_OK Or MB_ICONERROR Or MB_SETFOREGROUND)
        			NXT.DestroyFile(hNXT, file, @status)
        			report_error()
        			GoTo finish
        		Else
        			report_error()
        		End If
    			NXT.CloseFile(file, @status)
    			report_error()
        		NXT.DestroyFile(hNXT, file, @status)
        		report_error()
        		status = 0

	    		file = NXT.CreateFile(hNXT, StrPtr(oldname), @status)
	    		report_error()
	            file_size = NXT.GetFileSize(file, @status)
	            report_error()
	            Dim filebuf(file_size - 1) As UByte
	            NXT.OpenFileForRead(file, @status)
	            report_error()
	            NXT.ReadFile(file, @filebuf(0), file_size, @status)
	            report_error()
	            NXT.CloseFile(file, @status)
	            report_error()
	            NXT.DeleteFile(file, @status)
	            report_error()
	            NXT.DestroyFile(hNXT, file, @status)
	            report_error()

	            file = NXT.CreateFile(hNXT, StrPtr(newname), @status)
	            report_error()
        		NXT.OpenFileForWrite(file, file_size, @status)
        		report_error()
    			NXT.WriteFile(file, @filebuf(0), file_size, @status)
    			report_error()
    			NXT.CloseFile(file, @status)
    			report_error()
        		NXT.DestroyFile(hNXT, file, @status)
        		report_error()
        		reload_files = TRUE
	    	Case 5
	    		'Download.
                
                'Get filename(s)...
            	fl = String(MAX_PATH, 0)
            	fn = String(MAX_PATH, 0)
            	ft = String(MAX_PATH, 0)
                ok = FALSE
                With ofn
					.lStructSize = SizeOf(OPENFILENAME)
					.hwndOwner = hwnd
					.hInstance = GetModuleHandle(NULL)
					.lpstrFilter = StrPtr(!"NXT Files (*.ric, *.rxe, *.rso, *.rcd, *.rbt, *.rbtx, *.nbc, *.nxc, *.txt)\0*.ric;*.rxe;*.rso;*.rcd;*.rbt;*.rbtx;*.nbc;*.nxc;*.txt\0All Files (*.*)\0*.*\0\0")
					.nFilterIndex = 1
					.lpstrFile = StrPtr(fl)
					.nMaxFile = Len(fl)
					.lpstrFileTitle = StrPtr(ft)
					.nMaxFileTitle = Len(ft)
					.lpstrInitialDir = NULL
					.lpstrTitle	= StrPtr("Please select a file to download.")
					.Flags = OFN_EXPLORER Or OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_HIDEREADONLY Or OFN_ALLOWMULTISELECT
				End With
                If GetOpenFileName(@ofn) = NULL Then
					MessageBox(hwnd, "GetOpenFileName(@ofn) returned NULL.", "NeXT Commander", MB_OK Or MB_ICONERROR Or MB_SETFOREGROUND)
                Else
                    ok = TRUE
                End If

	        	
	        	'Download it (them)...
	        	If ok Then
	        		Dim As Integer e = InStr(fl, Chr(0) + Chr(0))
					Dim As Integer a = InStr(fl, Chr(0)) + 1
					path = Left(fl, InStr(fl, Chr(0)))

					Do
						If a - 1 = e Then
							'One file selected.
							fn = fl
						Else
							'Multiple files selected.
							ft = Mid(fl, a, InStr(a, fl, Chr(0)) - a)
							fn = path + "\" + ft
							a = InStr(a, fl, Chr(0)) + 1
						EndIf
						
		        		Open fn For Binary Access Read As #1
			            If Err = 0 Then
			            	file_size = Lof(1)
			            	If file_size > 0 Then
			            		Dim filebuf(file_size - 1) As UByte
			            		Get #1,, filebuf()
			            		SendDlgItemMessage(hwnd, SBR_CMD_STATUS, SB_SETTEXT, 0, Cast(lparam, @"Downloading..."))
			            		file = NXT.CreateFile(hNXT, StrPtr(ft), @status)
			            		report_error()
			            		NXT.OpenFileForWrite(file, file_size, @status)
			            		report_error()
			            		If status = NXT.Status.FWFileAlreadyExists Then
			            			NXT.CloseFile(file, @status)
			            			report_error()
			            			mbret = MessageBox(hwnd, "File already exists. Overwrite?", "NeXT Commander", MB_YESNO Or MB_ICONQUESTION Or MB_SETFOREGROUND)
			            			If mbret = IDYES Then
			            				NXT.DeleteFile(file, @status)
			            				report_error()
			            			End If
			            		End If
			            		If mbret = IDYES Or mbret = 0 Then
			            			NXT.WriteFile(file, @filebuf(0), file_size, @status)
			            			report_error()
			            			NXT.CloseFile(file, @status)
			            			report_error()
			            		End If
			            		NXT.DestroyFile(hNXT, file, @status)
			            		report_error()
			            		reload_files = TRUE
			            	Else
			            		MessageBox(hwnd, "Empty files cannot be downloaded.", "NeXT Commander", MB_OK Or MB_ICONERROR Or MB_SETFOREGROUND)
			            	End If
			            	Close #1
			            Else
			            	MessageBox(hwnd, !"Unable to access file:\r\n" + fn, "NeXT Commander", MB_OK Or MB_ICONEXCLAMATION Or MB_SETFOREGROUND)
			            End If
					Loop While a < e
	        	End If
	    	Case 6
	    		'Download. (Drag `n drop)
				Dim As ZString * MAX_PATH + 1 fn
				For a = 0 To DragQueryFile(hdrop, &hFFFFFFFF, NULL, NULL) - 1 'Go thru the list of files...
					DragQueryFile(hdrop, a, @fn, MAX_PATH)
					If Not FileExists(fn) Then MessageBox(hwnd, "Please don't drop folders here. They aren't supported.", "NeXT Commander", MB_OK Or MB_ICONERROR Or MB_SETFOREGROUND): Continue For
					Open fn For Binary Access Read As #1
		            If Err = 0 Then
		            	file_size = Lof(1)
		            	If file_size > 0 Then 'Can't download zero-byte files.
		            		Dim filebuf(file_size - 1) As UByte
		            		Get #1,, filebuf()
		            		SendDlgItemMessage(hwnd, SBR_CMD_STATUS, SB_SETTEXT, 0, Cast(lparam, @"Downloading..."))
		            		Dim As String tmp = Right(fn, Len(fn) - InStrRev(fn, "\"))
		            		file = NXT.CreateFile(hNXT, StrPtr(tmp), @status)
			            	If status = NXT.Status.FWFileAlreadyExists Then status = 0 'status = NXT.Status.FWIllegalFilename Or status = NXT.Status.InvalidFilename Or '''Had these in an earlier version, not sure why...
		            		report_error()
		            		If status = 0 Then
			            		NXT.OpenFileForWrite(file, file_size, @status)
			            		report_error()
			            		If status = NXT.Status.FWFileAlreadyExists Then
			            			NXT.CloseFile(file, @status)
			            			report_error()
			            			mbret = MessageBox(hwnd, "File already exists. Overwrite?", "NeXT Commander", MB_YESNO Or MB_ICONQUESTION Or MB_SETFOREGROUND)
			            			If mbret = IDYES Then
			            				NXT.DeleteFile(file, @status)
			            				report_error()
			            			End If
			            		End If
			            		If mbret = IDYES Or mbret = 0 Then
			            			NXT.WriteFile(file, @filebuf(0), file_size, @status)
			            			report_error()
			            			NXT.CloseFile(file, @status)
			            			report_error()
			            		End If
			            		reload_files = TRUE
		            		EndIf
		            		NXT.DestroyFile(hNXT, file, @status)
		            		report_error()
		            	Else
		            		MessageBox(hwnd, "Empty files cannot be downloaded.", "NeXT Commander", MB_OK Or MB_ICONERROR Or MB_SETFOREGROUND)
		            	End If
		            	Close #1
		            Else
		            	MessageBox(hwnd, !"Unable to access file \"" + fn + !"\"!", "NeXT Commander", MB_OK Or MB_ICONERROR Or MB_SETFOREGROUND)
		            End If
				Next
				DragFinish(hdrop)
	    	Case 7
	    		'Rename (NXT)
	    		NXT.SetName(hNXT, StrPtr(newname), @status)
	    		report_error()
	    		known_NXTs(NXT_to_command).Name = newname
	    		known_NXTs_has_changed = TRUE
	    		NXTs(NXT_to_command).Name = newname
	    	Case 8
	    		'Stop running program.
	    		Dim As UByte spdc = 1
				NXT.SendDirectCommand(hNXT, FALSE, @spdc, 1, NULL, NULL, @status)
				report_error()
	    	Case 9
	    		'Stop sound.
	    		Dim As UByte ssdc = &hc
				NXT.SendDirectCommand(hNXT, FALSE, @ssdc, 1, NULL, NULL, @status)
				report_error()
	    End Select
	End If

	finish:
	MutexUnLock(NXT_info_lock)
	SetTimer(hwnd, 1, 128, NULL)
	Return status
End Function



Function firmware_dl(hwnd As HWND, mode As Byte) As Integer
	'Download firmware to NXT.
	Dim As ZString * 256 resstr
	Dim As NXT.hNXT hNXT
	Dim As Integer ok, leaving_file_sel, status, file_size
	Dim As OPENFILENAME ofn
	Dim As ZString * MAX_PATH dlfn_P

	'Get filename...
	Do
        ok = FALSE: leaving_file_sel = FALSE
        With ofn
			.lStructSize = SizeOf(OPENFILENAME)
			.hwndOwner = hwnd
			.hInstance = GetModuleHandle(NULL)
			.lpstrFilter = StrPtr(!"NXT Firmware (*.rfw)\0*.rfw;\0\0")
			.nFilterIndex = 1
			.lpstrFile = @dlfn_p
			.nMaxFile = SizeOf(dlfn_p)
			.lpstrInitialDir = NULL
			.lpstrTitle	= StrPtr("Please select the firmware file to download.")
			.Flags = OFN_EXPLORER Or OFN_FILEMUSTEXIST Or OFN_PATHMUSTEXIST Or OFN_HIDEREADONLY
		End With
        If GetOpenFileName(@ofn) = NULL Then
            leaving_file_sel = TRUE
        Else
            ok = TRUE: leaving_file_sel = TRUE
        End If
    Loop Until leaving_file_sel
	
	'Procede...
	If ok Then
		Open dlfn_p For Binary Access Read As #1
        If Err = 0 Then
        	file_size = Lof(1)
        	If file_size = 262144 Then 'Sanity check
        		
        		'Load the firmware into buffer...
        		Dim filebuf(file_size - 1) As UByte
        		Get #1,, filebuf()
        		Close #1

				If mode = 1 Then
					If MessageBox(hwnd, !"Downloading firmware will erase all files and reset most settings on the NXT.\nIf you are unsure whether you should continue, CANCEL NOW. This is your last chance to cancel.", "NeXT Commander", MB_OKCANCEL Or MB_ICONWARNING) = IDCANCEL Then Return FALSE
	    			
	    			'Need to do a little housekeeping since we were called from the command screen...
	    			EnableWindow(hwnd, FALSE)
	    			SendDlgItemMessage(hwnd, SBR_CMD_STATUS, SB_SETTEXT, 0, Cast(lparam, @"Stopping info thread"))
	    			update_info_ending = TRUE
	    			ThreadWait(update_info_thread)
	
					'Reboot into SAMBA mode...
					SendDlgItemMessage(hwnd, SBR_CMD_STATUS, SB_GETTEXT, 0, Cast(lparam, @"Rebooting NXT into FW download mode."))
	    			NXT.BootIntoFirmwareDownloadMode(@NXTs(NXT_to_command).resstr, @status)
					report_error()
				Else
					EnableWindow(hwnd, FALSE)
				EndIf
				
				If status = 0 Then
					'Here we goooooo!
					If mode = 0 Then
						SendDlgItemMessage(hwnd, SBR_SEL_STATUS, SB_SETTEXT, 0, Cast(lparam, @"Locating NXT"))
					Else
						SendDlgItemMessage(hwnd, SBR_CMD_STATUS, SB_SETTEXT, 0, Cast(lparam, @"Locating NXT"))
					EndIf
					
					'Locate NXT
					Dim As Single t = Timer
					Do
						status = 0
						Sleep 100
						NXT.FindDeviceInFirmwareDownloadMode(@resstr, @status)
						If Timer - t > 16 Then
							If MessageBox(hwnd, !"Unable to find an NXT in firmware download mode.\rThe NXT MUST be conected by USB.", "NeXT Commander", MB_RETRYCANCEL Or MB_ICONINFORMATION Or MB_SETFOREGROUND) = IDCANCEL Then EnableWindow(hwnd, TRUE): Return FALSE Else t = Timer
						EndIf
					Loop Until status = 0
					
					'Found it!
					hNXT = NXT.CreateNXT(@resstr, @status, FALSE)
					report_error()
					If mode = 0 Then
						SendDlgItemMessage(hwnd, SBR_SEL_STATUS, SB_SETTEXT, 0, Cast(lparam, @"Downloading Firmware"))
					Else
						SendDlgItemMessage(hwnd, SBR_CMD_STATUS, SB_SETTEXT, 0, Cast(lparam, @"Downloading Firmware"))
					EndIf
					NXT.DownloadFirmware(hNXT, @filebuf(0), file_size, @status) 'Yeah, that's it: only one line for the actual download.
					
					status = 0'DownloadFirmware always returns nonzero (I think...); don't scare the user with a nonexistant error.
					
					NXT.DestroyNXT(hNXT, @status)
	    			report_error()
	    			If mode = 0 Then
	    				SendDlgItemMessage(hwnd, SBR_SEL_STATUS, SB_SETTEXT, 0, Cast(lparam, @""))
	    			Else
	    				SendDlgItemMessage(hwnd, SBR_CMD_STATUS, SB_SETTEXT, 0, Cast(lparam, @""))
	    			EndIf
	    			If mode = 1 Then
	    				'More housekeeping for the command screen...
						update_info_ending = FALSE
						Sleep 2000
						update_info_thread = ThreadCreate(Cast(Any Ptr, @update_NXT_info))
	    			EndIf
					EnableWindow(hwnd, TRUE)
				EndIf
        	Else
        		'Wrong size.
        		Close #1
        		MessageBox(hwnd, "Invalid file!", "NeXT Commander", MB_OK Or MB_ICONERROR Or MB_SETFOREGROUND)
        	End If
        Else
        	MessageBox(hwnd, "Unable to access file!", "NeXT Commander", MB_OK Or MB_ICONERROR Or MB_SETFOREGROUND)
        End If
	End If
End Function
