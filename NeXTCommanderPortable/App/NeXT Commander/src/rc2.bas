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


Dim Shared As UByte cmda(11) = {4, 0, 75, 1, 0, 0, &h20, 0, 0, 0, 0}, cmdb(11) = {4, 1, 75, 1, 0, 0, &h20, 0, 0, 0, 0}, _
					cmdc(11) = {4, 2, 75, 1, 0, 0, &h20, 0, 0, 0, 0}, cmdsa(11) = {4, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0}, _
					cmdsb(11) = {4, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0}, cmdsc(11) = {4, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0}

Function Rc2DlgProc(ByVal hwnd As HWND, ByVal umsg As UINT, ByVal wparam As WPARAM, ByVal lparam As LPARAM) As Integer
    Dim As Integer ports, status, rcnum, sendstop

	If umsg = WM_INITDIALOG Or umsg = WM_COMMAND Or umsg = WM_TIMER Or umsg = WM_CLOSE Then
		If UBound(rc2s) > 0 Then
			For rcnum = 0 To UBound(rc2s)
				If rc2s(rcnum).hwnd = hwnd Then Exit For
			Next
		EndIf
		If rc2s(rcnum).hwnd = hwnd Then
			ports = rc2s(rcnum).ports
			status = rc2s(rcnum).status
			sendstop = rc2s(rcnum).sendstop
		Else
			If rc2s(rcnum).hwnd <> NULL Then
				rcnum += 1
				ReDim Preserve rc2s(rcnum)
			EndIf
			rc2s(rcnum).hwnd = hwnd
		EndIf
	EndIf


    Select Case umsg
    	Case WM_INITDIALOG
    		SendDlgItemMessage(hwnd, TRB_POWER, TBM_SETRANGE, TRUE, MAKELPARAM(0, 100))
    		SendDlgItemMessage(hwnd, TRB_POWER, TBM_SETPOS, TRUE, 25)
    		SetTimer(hwnd, NULL, 100, NULL)
	    	Return TRUE
    	Case WM_COMMAND
	        Select Case LoWord(wparam)
	        	Case CHK_PORTA
	        		If IsDlgButtonChecked(hwnd, CHK_PORTA) Then rc2s(rcnum).ports Or= 1 Else rc2s(rcnum).ports And= (Not 1)
	        	Case CHK_PORTB
	        		If IsDlgButtonChecked(hwnd, CHK_PORTB) Then rc2s(rcnum).ports Or= 2 Else rc2s(rcnum).ports And= (Not 2)
	        	Case CHK_PORTC
	        		If IsDlgButtonChecked(hwnd, CHK_PORTC) Then rc2s(rcnum).ports Or= 4 Else rc2s(rcnum).ports And= (Not 4)
	        End Select
    	Case WM_TIMER
    		If leaving_command_seceen Then SendMessage(hwnd, WM_CLOSE, NULL, NULL): Return TRUE
			
			If SendDlgItemMessage(hwnd, BTN_FOREWARD, BM_GETSTATE, NULL, NULL) And BST_PUSHED Then
				Dim As UByte pwr = 100 - SendDlgItemMessage(hwnd, TRB_POWER, TBM_GETPOS, NULL, NULL)
    			cmda(2) = pwr: cmdb(2) = pwr: cmdc(2) = pwr
    			If ports And 1 Then NXT.SendDirectCommand(hNXT, FALSE, @cmda(0), 12, NULL, NULL, @status)
    			If ports And 2 Then NXT.SendDirectCommand(hNXT, FALSE, @cmdb(0), 12, NULL, NULL, @status)
    			If ports And 4 Then NXT.SendDirectCommand(hNXT, FALSE, @cmdc(0), 12, NULL, NULL, @status)
    			report_error()
    			rc2s(rcnum).status = status
    			rc2s(rcnum).sendstop = TRUE
			ElseIf SendDlgItemMessage(hwnd, BTN_REVERSE, BM_GETSTATE, NULL, NULL) And BST_PUSHED Then
				Dim As UByte pwr = 100 - SendDlgItemMessage(hwnd, TRB_POWER, TBM_GETPOS, NULL, NULL)
    			cmda(2) = -pwr: cmdb(2) = -pwr: cmdc(2) = -pwr
    			If ports And 1 Then NXT.SendDirectCommand(hNXT, FALSE, @cmda(0), 12, NULL, NULL, @status)
    			If ports And 2 Then NXT.SendDirectCommand(hNXT, FALSE, @cmdb(0), 12, NULL, NULL, @status)
    			If ports And 4 Then NXT.SendDirectCommand(hNXT, FALSE, @cmdc(0), 12, NULL, NULL, @status)
    			report_error()
    			rc2s(rcnum).status = status
    			rc2s(rcnum).sendstop = TRUE
			Else
				If sendstop Then
					If ports And 1 Then NXT.SendDirectCommand(hNXT, FALSE, @cmdsa(0), 12, NULL, NULL, @status)
    				If ports And 2 Then NXT.SendDirectCommand(hNXT, FALSE, @cmdsb(0), 12, NULL, NULL, @status)
    				If ports And 4 Then NXT.SendDirectCommand(hNXT, FALSE, @cmdsc(0), 12, NULL, NULL, @status)
    				report_error()
    				rc2s(rcnum).status = status
    				rc2s(rcnum).sendstop = FALSE
				EndIf
			EndIf
			
    		Return TRUE
    	Case WM_CLOSE
    		EndDialog(hwnd, IDCANCEL)
    		
    		rc2s(rcnum).hwnd = NULL
			rc2s(rcnum).ports = 0
			rc2s(rcnum).status = 0
			rc2s(rcnum).sendstop = FALSE
    		Return TRUE
    End Select

   Return FALSE
End Function


Sub rc2
	hNXT_usecount += 1
	Dim As Integer ret
	ret = DialogBox(GetModuleHandle(NULL), MAKEINTRESOURCE(DLG_RC2), NULL, @Rc2DlgProc)
	If ret = IDOK Then
	ElseIf ret <> IDCANCEL And ret <> IDOK Then
		MessageBox(NULL, "Dialog exited with unknown value. (error?)", "Notice", MB_OK Or MB_ICONINFORMATION)
	EndIf
	hNXT_usecount += 1
End Sub

