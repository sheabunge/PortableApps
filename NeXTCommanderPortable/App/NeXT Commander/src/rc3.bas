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


Function Rc3DlgProc(ByVal hwnd As HWND, ByVal umsg As UINT, ByVal wparam As WPARAM, ByVal lparam As LPARAM) As Integer
    Dim As Integer status

    Select Case umsg
    	Case WM_INITDIALOG
    		SendDlgItemMessage(hwnd, CBO_PORT, CB_SETITEMDATA, SendDlgItemMessage(hwnd, CBO_PORT, CB_ADDSTRING, NULL, Cast(LPARAM, @"Port A")), 0)
    		SendDlgItemMessage(hwnd, CBO_PORT, CB_SETITEMDATA, SendDlgItemMessage(hwnd, CBO_PORT, CB_ADDSTRING, NULL, Cast(LPARAM, @"Port B")), 1)
    		SendDlgItemMessage(hwnd, CBO_PORT, CB_SETITEMDATA, SendDlgItemMessage(hwnd, CBO_PORT, CB_ADDSTRING, NULL, Cast(LPARAM, @"Port C")), 2)
    		SendDlgItemMessage(hwnd, CBO_PORT, CB_SETITEMDATA, SendDlgItemMessage(hwnd, CBO_PORT, CB_ADDSTRING, NULL, Cast(LPARAM, @"All Ports")), &hff)
	    	SendDlgItemMessage(hwnd, CBO_PORT, CB_SETCURSEL, 0, NULL)
	    	
	    	SendDlgItemMessage(hwnd, CBO_MODE, CB_SETITEMDATA, SendDlgItemMessage(hwnd, CBO_MODE, CB_ADDSTRING, NULL, Cast(LPARAM, @"On")), 1)
    		SendDlgItemMessage(hwnd, CBO_MODE, CB_SETITEMDATA, SendDlgItemMessage(hwnd, CBO_MODE, CB_ADDSTRING, NULL, Cast(LPARAM, @"Brake")), 2)
    		SendDlgItemMessage(hwnd, CBO_MODE, CB_SETITEMDATA, SendDlgItemMessage(hwnd, CBO_MODE, CB_ADDSTRING, NULL, Cast(LPARAM, @"On + Regulated")), 4)
	    	SendDlgItemMessage(hwnd, CBO_MODE, CB_SETCURSEL, 0, NULL)
	    	
	    	SendDlgItemMessage(hwnd, CBO_REGMODE, CB_SETITEMDATA, SendDlgItemMessage(hwnd, CBO_REGMODE, CB_ADDSTRING, NULL, Cast(LPARAM, @"No Regulation")), 0)
    		SendDlgItemMessage(hwnd, CBO_REGMODE, CB_SETITEMDATA, SendDlgItemMessage(hwnd, CBO_REGMODE, CB_ADDSTRING, NULL, Cast(LPARAM, @"Power Control")), 1)
    		SendDlgItemMessage(hwnd, CBO_REGMODE, CB_SETITEMDATA, SendDlgItemMessage(hwnd, CBO_REGMODE, CB_ADDSTRING, NULL, Cast(LPARAM, @"Synchronize")), 2)
	    	SendDlgItemMessage(hwnd, CBO_REGMODE, CB_SETCURSEL, 0, NULL)
	    	
	    	SendDlgItemMessage(hwnd, CBO_RUNSTATE, CB_SETITEMDATA, SendDlgItemMessage(hwnd, CBO_RUNSTATE, CB_ADDSTRING, NULL, Cast(LPARAM, @"Idle")), 0)
    		SendDlgItemMessage(hwnd, CBO_RUNSTATE, CB_SETITEMDATA, SendDlgItemMessage(hwnd, CBO_RUNSTATE, CB_ADDSTRING, NULL, Cast(LPARAM, @"Ramp Up")), &h10)
    		SendDlgItemMessage(hwnd, CBO_RUNSTATE, CB_SETITEMDATA, SendDlgItemMessage(hwnd, CBO_RUNSTATE, CB_ADDSTRING, NULL, Cast(LPARAM, @"Running")), &h20)
    		SendDlgItemMessage(hwnd, CBO_RUNSTATE, CB_SETITEMDATA, SendDlgItemMessage(hwnd, CBO_RUNSTATE, CB_ADDSTRING, NULL, Cast(LPARAM, @"Ramp Down")), &h40)
	    	SendDlgItemMessage(hwnd, CBO_RUNSTATE, CB_SETCURSEL, 0, NULL)
	    	
	    	SendDlgItemMessage(hwnd, EDT_PWR, EM_LIMITTEXT, 4, NULL)
	    	SendDlgItemMessage(hwnd, EDT_TURNRATIO, EM_LIMITTEXT, 4, NULL)
	    	SendDlgItemMessage(hwnd, EDT_PWR_PREV, WM_SETTEXT, NULL, Cast(LPARAM, @"0"))
	    	SendDlgItemMessage(hwnd, EDT_TURNRATIO_PREV, WM_SETTEXT, NULL, Cast(LPARAM, @"0"))
	    	
	    	SendDlgItemMessage(hwnd, UDN_PWR, UDM_SETRANGE32, -100, 100)
	    	SendDlgItemMessage(hwnd, UDN_TURNRATIO, UDM_SETRANGE32, -100, 100)
	    	
	    	SetTimer(hwnd, NULL, 100, NULL)
	    	
	    	Return TRUE
    	Case WM_COMMAND
	        Select Case LoWord(wparam)
	        	Case IDOK
	        		Dim As UByte cmd(11), retbuf(2)
	        		cmd(0) = 4
	        		cmd(1) = SendDlgItemMessage(hwnd, CBO_PORT, CB_GETITEMDATA, SendDlgItemMessage(hwnd, CBO_PORT, CB_GETCURSEL, NULL, NULL), NULL)
	        		cmd(2) = GetDlgItemInt(hwnd, EDT_PWR, NULL, TRUE)
	        		cmd(3) = SendDlgItemMessage(hwnd, CBO_MODE, CB_GETITEMDATA, SendDlgItemMessage(hwnd, CBO_MODE, CB_GETCURSEL, NULL, NULL), NULL)
	        		cmd(4) = SendDlgItemMessage(hwnd, CBO_REGMODE, CB_GETITEMDATA, SendDlgItemMessage(hwnd, CBO_REGMODE, CB_GETCURSEL, NULL, NULL), NULL)
	        		cmd(5) = GetDlgItemInt(hwnd, EDT_TURNRATIO, NULL, TRUE)
	        		cmd(6) = SendDlgItemMessage(hwnd, CBO_RUNSTATE, CB_GETITEMDATA, SendDlgItemMessage(hwnd, CBO_RUNSTATE, CB_GETCURSEL, NULL, NULL), NULL)
	        		cmd(7) = GetDlgItemInt(hwnd, EDT_TACHOLIMIT, NULL, TRUE)
	        		cmd(9) = GetDlgItemInt(hwnd, EDT_TACHOLIMIT, NULL, TRUE) Shl 8
	        		cmd(10) = GetDlgItemInt(hwnd, EDT_TACHOLIMIT, NULL, TRUE) Shl 16
	        		cmd(11) = GetDlgItemInt(hwnd, EDT_TACHOLIMIT, NULL, TRUE) Shl 24
	        		NXT.SendDirectCommand(hNXT, TRUE, @cmd(0), 12, @retbuf(0), 3, @status)
	        		report_error()
	        		status = NXT.ConvertFirmwareStatus(retbuf(2))
	        		report_error()
	        	Case EDT_PWR
	        		If HiWord(wparam) = EN_UPDATE Then
	        			Dim As ZString * 5 tmp
	        			GetDlgItemText(hwnd, EDT_PWR, @tmp, 5)
	        			If tmp = "" Then SendDlgItemMessage(hwnd, EDT_PWR_PREV, WM_SETTEXT, NULL, Cast(LPARAM, @tmp)): Return TRUE
	        			If Left(tmp, 1) <> "-" And (Left(tmp, 1) < "0" Or Left(tmp, 1) > "9") Then GoTo pwr_invalid
	        			If Mid(tmp, 2, 1) <> "" And (Mid(tmp, 2, 1) < "0" Or Mid(tmp, 2, 1) > "9") Then GoTo pwr_invalid
	        			If Mid(tmp, 3, 1) <> "" And (Mid(tmp, 3, 1) < "0" Or Mid(tmp, 3, 1) > "9") Then GoTo pwr_invalid
	        			If Mid(tmp, 4, 1) <> "" And (Mid(tmp, 4, 1) < "0" Or Mid(tmp, 4, 1) > "9") Then GoTo pwr_invalid
	        			SendDlgItemMessage(hwnd, EDT_PWR_PREV, WM_SETTEXT, NULL, Cast(LPARAM, @tmp))
	        			Return TRUE
	        			
	        			pwr_invalid:
	        			MessageBeep(MB_OK)
	        			GetDlgItemText(hwnd, EDT_PWR_PREV, @tmp, 5)
	        			Dim As Integer p
	        			SendDlgItemMessage(hwnd, EDT_PWR, EM_GETSEL, Cast(WPARAM, @p), NULL)
	        			SendDlgItemMessage(hwnd, EDT_PWR, WM_SETTEXT, NULL, Cast(LPARAM, @tmp))
	        			SendDlgItemMessage(hwnd, EDT_PWR, EM_SETSEL, p - 1, p - 1)
	        			Return TRUE
	        		ElseIf HiWord(wparam) = EN_KILLFOCUS Then
	        			Dim As ZString * 5 tmp
	        			GetDlgItemText(hwnd, EDT_PWR, @tmp, 5)
	        			If ValInt(tmp) > 100 Then tmp = "100"
	        			If ValInt(tmp) < -100 Then tmp = "-100"
	        			SendDlgItemMessage(hwnd, EDT_PWR, WM_SETTEXT, NULL, Cast(LPARAM, @tmp))
	        			SendDlgItemMessage(hwnd, EDT_PWR_PREV, WM_SETTEXT, NULL, Cast(LPARAM, @tmp))
	        		EndIf
	        	Case EDT_TURNRATIO
	        		If HiWord(wparam) = EN_UPDATE Then
	        			Dim As ZString * 5 tmp
	        			GetDlgItemText(hwnd, EDT_TURNRATIO, @tmp, 5)
	        			If tmp = "" Then SendDlgItemMessage(hwnd, EDT_TURNRATIO_PREV, WM_SETTEXT, NULL, Cast(LPARAM, @tmp)): Return TRUE
	        			If Left(tmp, 1) <> "-" And (Left(tmp, 1) < "0" Or Left(tmp, 1) > "9") Then GoTo trn_invalid
	        			If Mid(tmp, 2, 1) <> "" And (Mid(tmp, 2, 1) < "0" Or Mid(tmp, 2, 1) > "9") Then GoTo trn_invalid
	        			If Mid(tmp, 3, 1) <> "" And (Mid(tmp, 3, 1) < "0" Or Mid(tmp, 3, 1) > "9") Then GoTo trn_invalid
	        			If Mid(tmp, 4, 1) <> "" And (Mid(tmp, 4, 1) < "0" Or Mid(tmp, 4, 1) > "9") Then GoTo trn_invalid
	        			SendDlgItemMessage(hwnd, EDT_TURNRATIO_PREV, WM_SETTEXT, NULL, Cast(LPARAM, @tmp))
	        			Return TRUE
	        			
	        			trn_invalid:
	        			MessageBeep(MB_OK)
	        			GetDlgItemText(hwnd, EDT_TURNRATIO_PREV, @tmp, 5)
	        			Dim As Integer p
	        			SendDlgItemMessage(hwnd, EDT_TURNRATIO, EM_GETSEL, Cast(WPARAM, @p), NULL)
	        			SendDlgItemMessage(hwnd, EDT_TURNRATIO, WM_SETTEXT, NULL, Cast(LPARAM, @tmp))
	        			SendDlgItemMessage(hwnd, EDT_TURNRATIO, EM_SETSEL, p - 1, p - 1)
	        			Return TRUE
	        		ElseIf HiWord(wparam) = EN_KILLFOCUS Then
	        			Dim As ZString * 5 tmp
	        			GetDlgItemText(hwnd, EDT_TURNRATIO, @tmp, 5)
	        			If ValInt(tmp) > 100 Then tmp = "100"
	        			If ValInt(tmp) < -100 Then tmp = "-100"
	        			SendDlgItemMessage(hwnd, EDT_TURNRATIO, WM_SETTEXT, NULL, Cast(LPARAM, @tmp))
	        			SendDlgItemMessage(hwnd, EDT_TURNRATIO_PREV, WM_SETTEXT, NULL, Cast(LPARAM, @tmp))
	        		EndIf
	        End Select
    	Case WM_TIMER
    		If leaving_command_seceen Then SendMessage(hwnd, WM_CLOSE, NULL, NULL): Return TRUE
    		Return TRUE
    	Case WM_CLOSE
    		KillTimer(hwnd, 0)
    		EndDialog(hwnd, IDCANCEL)
    		Return TRUE
    End Select

   Return FALSE
End Function


Sub rc3
	hNXT_usecount += 1
	Dim As Integer ret
	ret = DialogBox(GetModuleHandle(NULL), MAKEINTRESOURCE(DLG_RC3), NULL, @Rc3DlgProc)
	If ret = IDOK Then
	ElseIf ret <> IDCANCEL And ret <> IDOK Then
		MessageBox(NULL, "Dialog exited with unknown value. (error?)", "Notice", MB_OK Or MB_ICONINFORMATION)
	EndIf
	hNXT_usecount += 1
End Sub
