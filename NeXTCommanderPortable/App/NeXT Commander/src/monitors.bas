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


Function MonitorDlgProc(ByVal hwnd As HWND, ByVal umsg As UINT, ByVal wparam As WPARAM, ByVal lparam As LPARAM) As Integer
    Dim As Integer sensor_type = -1, sensor_port = -1, monnum, status

	If umsg = WM_INITDIALOG Or umsg = WM_COMMAND Or umsg = WM_TIMER Or umsg = WM_CLOSE Then
		If UBound(monitors) > 0 Then
			For monnum = 0 To UBound(monitors)
				If monitors(monnum).hwnd = hwnd Then Exit For
			Next
		EndIf
		If monitors(monnum).hwnd = hwnd Then
			sensor_type = monitors(monnum).sensor_type
			sensor_port = monitors(monnum).sensor_port
			status = monitors(monnum).status
		Else
			If monitors(monnum).hwnd <> NULL Then
				monnum += 1
				ReDim Preserve monitors(monnum)
			EndIf
			monitors(monnum).hwnd = hwnd
		EndIf
	EndIf


    Select Case uMsg
    	Case WM_INITDIALOG
    		SendDlgItemMessage(hwnd, PGB_LEVEL1, PBM_SETRANGE, 0, MAKELPARAM(0, 1023))
    		SendDlgItemMessage(hwnd, PGB_LEVEL2, PBM_SETRANGE, 0, MAKELPARAM(0, 1023))
    		SendDlgItemMessage(hwnd, PGB_LEVEL1, PBM_SETPOS, 1023, NULL)
    		SetTimer(hwnd, NULL, 100, NULL)
	    	Return TRUE
    	Case WM_COMMAND
	        Select Case LoWord(wParam)
	        	Case RBN_TOUCH, RBN_TEMPERATURE_C, RBN_LIGHT_O, RBN_ROTATION_O, RBN_LIGHT_A, RBN_LIGHT_I, RBN_SOUND_DB, _
	        			RBN_SOUND_DBA, RBN_TEMPERATURE_F, RBN_ULTRASONIC, RBN_COLOR, RBN_MOTOR
	        		If IsDlgButtonChecked(hwnd, LoWord(wParam)) = BST_UNCHECKED Then Return TRUE
	        		sensor_type = LoWord(wParam)
	        		If sensor_port > 0 Then EnableWindow(GetDlgItem(hwnd, BTN_STARTMON), TRUE)
	        		monitors(monnum).sensor_type = sensor_type
	        		Return TRUE
	        	Case RBN_PORT1, RBN_PORT2, RBN_PORT3, RBN_PORT4, RBN_PORTA, RBN_PORTB, RBN_PORTC 
	        		If IsDlgButtonChecked(hwnd, LoWord(wParam)) = BST_UNCHECKED Then Return TRUE
	        		sensor_port = LoWord(wParam)
	        		If sensor_type > 0 Then EnableWindow(GetDlgItem(hwnd, BTN_STARTMON), TRUE)
					monitors(monnum).sensor_port = sensor_port
	        		Return TRUE
	        	Case BTN_STARTMON
	        		If sensor_type <> RBN_MOTOR And (sensor_port = RBN_PORTA Or sensor_port = RBN_PORTB Or sensor_port = RBN_PORTC) Then
	        			MessageBox(hwnd, "Sensors cannot be used with motor ports.", "NeXT Commander", MB_ICONINFORMATION Or MB_OK): Return TRUE
	        		EndIf
	        		If sensor_type = RBN_MOTOR And sensor_port <> RBN_PORTA and sensor_port <> RBN_PORTB and sensor_port <> RBN_PORTC Then
	        			MessageBox(hwnd, "Motors cannot be used with sensor ports.", "NeXT Commander", MB_ICONINFORMATION Or MB_OK): Return TRUE
	        		EndIf
	        		If sensor_type = RBN_COLOR Then MessageBox(hwnd, "Color sensor monitoring is not yet implemented.", "NeXT Commander", MB_ICONINFORMATION Or MB_OK): Return TRUE
	        		If sensor_type = -1 Or sensor_port = -1 Then EnableWindow(GetDlgItem(hwnd, BTN_STARTMON), FALSE): Return TRUE
	        		ShowWindow(GetDlgItem(hwnd, BTN_STARTMON), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_TOUCH), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_TEMPERATURE_C), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_TEMPERATURE_F), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_LIGHT_O), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_ROTATION_O), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_LIGHT_A), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_LIGHT_I), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_SOUND_DB), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_SOUND_DBA), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_ULTRASONIC), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_COLOR), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_MOTOR), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_PORTA), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_PORTB), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_PORTC), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_PORT1), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_PORT2), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_PORT3), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, RBN_PORT4), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, IDC_GRP4), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, IDC_GRP5), SW_HIDE)
	        		ShowWindow(GetDlgItem(hwnd, STC_LEVEL1), SW_SHOW)
	        		If sensor_type <> RBN_TEMPERATURE_F And sensor_type <> RBN_TEMPERATURE_C And sensor_type <> RBN_MOTOR And sensor_type <> RBN_ROTATION_O And sensor_type <> RBN_COLOR  Then
	        			ShowWindow(GetDlgItem(hwnd, PGB_LEVEL1), SW_SHOW)
	        			ShowWindow(GetDlgItem(hwnd, PGB_LEVEL2), SW_SHOW)
	        		EndIf
	        		ShowWindow(GetDlgItem(hwnd, STC_LEVEL2), SW_SHOW)
	        		ShowWindow(GetDlgItem(hwnd, STC_STATUS), SW_SHOW)
	        		If sensor_type <> RBN_MOTOR Then
	        			ShowWindow(GetDlgItem(hwnd, STC_LABEL1), SW_SHOW)
	        			ShowWindow(GetDlgItem(hwnd, STC_LABEL2), SW_SHOW)
	        		EndIf

	        		Dim As String s, p, l
	        		If sensor_type = RBN_TOUCH Then s = "Touch"
	        		If sensor_type = RBN_TEMPERATURE_F Then s = "Temperature(F)"
	        		If sensor_type = RBN_TEMPERATURE_C Then s = "Temperature(C)"
	        		If sensor_type = RBN_LIGHT_O Then s = "Light*"
	        		If sensor_type = RBN_ROTATION_O Then s = "Rotation*"
	        		If sensor_type = RBN_LIGHT_I Then s = "Ambient Light"
	        		If sensor_type = RBN_LIGHT_A Then s = "Reflected Light"
	        		If sensor_type = RBN_SOUND_DB Then s = "Sound(DB)"
	        		If sensor_type = RBN_SOUND_DBA Then s = "Sound(DBA)"
	        		If sensor_type = RBN_ULTRASONIC Then s = "Ultrasonic"
	        		If sensor_type = RBN_MOTOR Then s = "Motor"
	        		If sensor_type = RBN_COLOR Then s = "Color"
	        		If sensor_port = RBN_PORT1 Then p = "1"
					If sensor_port = RBN_PORT2 Then p = "2"
					If sensor_port = RBN_PORT3 Then p = "3"
					If sensor_port = RBN_PORT4 Then p = "4"
					If sensor_port = RBN_PORTA Then p = "A"
					If sensor_port = RBN_PORTB Then p = "B"
					If sensor_port = RBN_PORTC Then p = "C"
					l = s + " on port " + p
					SendDlgItemMessage(hwnd, STC_STATUS, WM_SETTEXT, NULL, Cast(LPARAM, StrPtr(l)))

					If sensor_type <> RBN_MOTOR Then
						Dim As UByte cmdset(3)
						cmdset(0) = 5
						If sensor_port = RBN_PORT1 Then cmdset(1) = 0
						If sensor_port = RBN_PORT2 Then cmdset(1) = 1
						If sensor_port = RBN_PORT3 Then cmdset(1) = 2
						If sensor_port = RBN_PORT4 Then cmdset(1) = 3

						If sensor_type = RBN_TOUCH Then cmdset(2) = 1: cmdset(3) = &h20
						If sensor_type = RBN_TEMPERATURE_C Then cmdset(2) = 2: cmdset(3) = &ha0
						If sensor_type = RBN_TEMPERATURE_F Then cmdset(2) = 2: cmdset(3) = &hc0
						If sensor_type = RBN_LIGHT_O Then cmdset(2) = 3: cmdset(3) = 0'??
						If sensor_type = RBN_ROTATION_O Then cmdset(2) = 4: cmdset(3) = &he0
						If sensor_type = RBN_LIGHT_A Then cmdset(2) = 5: cmdset(3) = &h80
						If sensor_type = RBN_LIGHT_I Then cmdset(2) = 6: cmdset(3) = &h80
						If sensor_type = RBN_SOUND_DB Then cmdset(2) = 7: cmdset(3) = &h80
						If sensor_type = RBN_SOUND_DBA Then cmdset(2) = 8: cmdset(3) = &h80
						If sensor_type = RBN_ULTRASONIC Then cmdset(2) = &hb: cmdset(3) = 0
						
						NXT.SendDirectCommand(hNXT, FALSE, @cmdset(0), 4, NULL, NULL, @status)
						report_error()
						
						If sensor_type = RBN_ULTRASONIC Then
							SendDlgItemMessage(hwnd, STC_LABEL1, WM_SETTEXT, NULL, Cast(LPARAM, @""))
							SendDlgItemMessage(hwnd, STC_LABEL2, WM_SETTEXT, NULL, Cast(LPARAM, @""))
							Sleep 20
							Dim As UByte cmdset2(6) = {&hf, 0, 3, 0, 2, &h41, 2}
							If sensor_port = RBN_PORT1 Then cmdset2(1) = 0
							If sensor_port = RBN_PORT2 Then cmdset2(1) = 1
							If sensor_port = RBN_PORT3 Then cmdset2(1) = 2
							If sensor_port = RBN_PORT4 Then cmdset2(1) = 3
							
							NXT.SendDirectCommand(hNXT, FALSE, @cmdset2(0), 7, NULL, NULL, @status)
							report_error()
						EndIf
						If sensor_type = RBN_MOTOR Then
							SendDlgItemMessage(hwnd, STC_LABEL1, WM_SETTEXT, NULL, Cast(LPARAM, @""))
							SendDlgItemMessage(hwnd, STC_LABEL2, WM_SETTEXT, NULL, Cast(LPARAM, @""))
						EndIf
						If sensor_type = RBN_TEMPERATURE_F Or sensor_type = RBN_TEMPERATURE_C Then SendDlgItemMessage(hwnd, STC_LABEL1, WM_SETTEXT, NULL, Cast(LPARAM, @"Temperature"))
						If sensor_type = RBN_ROTATION_O Then
							SendDlgItemMessage(hwnd, STC_LABEL1, WM_SETTEXT, NULL, Cast(LPARAM, @"Steps"))
							SendDlgItemMessage(hwnd, STC_LABEL2, WM_SETTEXT, NULL, Cast(LPARAM, @"Rotations"))
						EndIf
					EndIf
					monitors(monnum).sensor_type = sensor_type
					monitors(monnum).sensor_port = sensor_port
					monitors(monnum).status = status
					monitors(monnum).monitoring = TRUE
	        End Select
    	Case WM_TIMER
    		If leaving_command_seceen Then SendMessage(hwnd, WM_CLOSE, NULL, NULL): Return TRUE

    		If hNXT <> NULL And monitors(monnum).monitoring Then
	    		Dim As String st1, st2
	    		Dim As Integer pbval1, pbval2
    			If sensor_type <> RBN_MOTOR And sensor_type <> RBN_ULTRASONIC And sensor_type <> RBN_COLOR Then
					Dim As UByte cmdget(1), retbuf(14)
					cmdget(0) = 7
					If sensor_port = RBN_PORT1 Then cmdget(1) = 0
					If sensor_port = RBN_PORT2 Then cmdget(1) = 1
					If sensor_port = RBN_PORT3 Then cmdget(1) = 2
					If sensor_port = RBN_PORT4 Then cmdget(1) = 3

					NXT.SendDirectCommand(hNXT, TRUE, @cmdget(0), 4, @retbuf(0), 15, @status)
					report_error()
					If retbuf(3) = FALSE Then Return TRUE
					If sensor_type = RBN_TOUCH Then
						pbval1 = 1023 - retbuf(12)
						If retbuf(11) = 0 Then st1 = "Not pressed": pbval1 = 1023 Else st1 = "Pressed": pbval1 = 0
						pbval2 = retbuf(10) Shl 8 Or retbuf(9)
						st2 = Trim(Str(retbuf(10) Shl 8 Or retbuf(9)))
					ElseIf sensor_type = RBN_LIGHT_A Or RBN_LIGHT_I Or RBN_SOUND_DB Or RBN_SOUND_DBA Then
						pbval1 = 1023 - (retbuf(12) Shl 8 Or retbuf(11) / 100 * 1023)
						st1 = Trim(Str(retbuf(12) Shl 8 Or retbuf(11)))
						pbval2 = retbuf(10) Shl 8 Or retbuf(9)
						st2 = Trim(Str(retbuf(10) Shl 8 Or retbuf(9)))
					ElseIf sensor_type = RBN_LIGHT_O Then
						pbval1 = 1023 - (retbuf(12) Shl 8 Or retbuf(11) / 100 * 1023)
						st1 = Trim(Str(retbuf(12) Shl 8 Or retbuf(11)))
						pbval2 = retbuf(10) Shl 8 Or retbuf(9)
						st2 = Trim(Str(retbuf(10) Shl 8 Or retbuf(9)))
					ElseIf sensor_type = RBN_TEMPERATURE_F Then
						st1 = Trim(Str(retbuf(12) Shl 8 Or retbuf(11))) + " °F"
						st2 = Trim(Str(retbuf(10) Shl 8 Or retbuf(9)))
					ElseIf sensor_type = RBN_TEMPERATURE_C Then
						st1 = Trim(Str(retbuf(12) Shl 8 Or retbuf(11))) + " °C"
						st2 = Trim(Str(retbuf(10) Shl 8 Or retbuf(9)))
					ElseIf sensor_type = RBN_ROTATION_O Then
						st1 = Trim(Str(retbuf(12) Shl 8 Or retbuf(11)))
						st2 = Trim(Str((retbuf(12) Shl 8 Or retbuf(11)) \ 16))
					EndIf

    			ElseIf sensor_type = RBN_ULTRASONIC Then
    				Dim As UByte cmdclr(1) = {&h10, 0}, clretbuf(18), dist
    				If sensor_port = RBN_PORT1 Then cmdclr(1) = 0
					If sensor_port = RBN_PORT2 Then cmdclr(1) = 1
					If sensor_port = RBN_PORT3 Then cmdclr(1) = 2
					If sensor_port = RBN_PORT4 Then cmdclr(1) = 3
					NXT.SendDirectCommand(hNXT, TRUE, @cmdclr(0), 2, @clretbuf(0), 19, @status)
					report_error()
					
					Dim As UByte cmdget1(5) = {&hf, 0, 2, 1, 2, &h42}
					If sensor_port = RBN_PORT1 Then cmdget1(1) = 0
					If sensor_port = RBN_PORT2 Then cmdget1(1) = 1
					If sensor_port = RBN_PORT3 Then cmdget1(1) = 2
					If sensor_port = RBN_PORT4 Then cmdget1(1) = 3
					NXT.SendDirectCommand(hNXT, FALSE, @cmdget1(0), 6, NULL, 0, @status)
					report_error()
					Sleep 50

					Dim As UByte cmdstat(1) = {&he, 0}, statretbuf(2)
					If sensor_port = RBN_PORT1 Then cmdstat(1) = 0
					If sensor_port = RBN_PORT2 Then cmdstat(1) = 1
					If sensor_port = RBN_PORT3 Then cmdstat(1) = 2
					If sensor_port = RBN_PORT4 Then cmdstat(1) = 3
					NXT.SendDirectCommand(hNXT, TRUE, @cmdstat(0), 2, @statretbuf(0), 3, @status)
					report_error()
					
					If statretbuf(1) = 0 And statretbuf(2) > 0 Then
						Dim As UByte cmdget2(1) = {&h10, 0}, retbuf(18)
						If sensor_port = RBN_PORT1 Then cmdget2(1) = 0
						If sensor_port = RBN_PORT2 Then cmdget2(1) = 1
						If sensor_port = RBN_PORT3 Then cmdget2(1) = 2
						If sensor_port = RBN_PORT4 Then cmdget2(1) = 3
						NXT.SendDirectCommand(hNXT, TRUE, @cmdget2(0), 2, @retbuf(0), 19, @status)
						report_error()
						dist = retbuf(3)
					Else
						Return TRUE
					EndIf

					If dist < 255 Then
						pbval2 = 1023 - (dist * 1024 / 200)
						st2 = Trim(Str(dist)) + "cm"
						dist = CInt(dist / 2.54)
						pbval1 = pbval2
						st1 = Trim(Str(dist)) + "in."
					Else
						pbval1 = 1023
						st1 = "No range"
						pbval2 = 1023
						st2 = "No range"
					EndIf
    			ElseIf sensor_type = RBN_MOTOR Then
    				Dim As UByte cmdget(1) = {6, 0}, retbuf(23)
    				If sensor_port = RBN_PORTA Then cmdget(1) = 0
					If sensor_port = RBN_PORTB Then cmdget(1) = 1
					If sensor_port = RBN_PORTC Then cmdget(1) = 2
					NXT.SendDirectCommand(hNXT, TRUE, @cmdget(0), 2, @retbuf(0), 24, @status)
					report_error()
					Dim As Integer tmp = retbuf(23) Shl 24 Or retbuf(22) Shl 16 Or retbuf(21) Shl 8 Or retbuf(20)
					st1 = Trim(Str(tmp)) + " degrees"
					st2 = Trim(Str(tmp \ 360)) + " rotations"
    			EndIf

    			SendDlgItemMessage(hwnd, PGB_LEVEL1, PBM_SETPOS, pbval1, NULL)
				SendDlgItemMessage(hwnd, STC_LEVEL1, WM_SETTEXT, NULL, Cast(LPARAM, StrPtr(st1)))
				SendDlgItemMessage(hwnd, PGB_LEVEL2, PBM_SETPOS, pbval2, NULL)
				SendDlgItemMessage(hwnd, STC_LEVEL2, WM_SETTEXT, NULL, Cast(LPARAM, StrPtr(st2)))
				monitors(monnum).status = status
    		EndIf
    		Return TRUE
    	Case WM_CLOSE
    		EndDialog(hwnd, IDCANCEL)
    		If hNXT <> NULL Then
	    		If sensor_type <> RBN_MOTOR Then
	    			If sensor_type = RBN_ULTRASONIC Then
						Dim As UByte cmdset2(6) = {&hf, 0, 3, 0, 2, &h41, 0}
						If sensor_port = RBN_PORT1 Then cmdset2(1) = 0
						If sensor_port = RBN_PORT2 Then cmdset2(1) = 1
						If sensor_port = RBN_PORT3 Then cmdset2(1) = 2
						If sensor_port = RBN_PORT4 Then cmdset2(1) = 3
						
						NXT.SendDirectCommand(hNXT, FALSE, @cmdset2(0), 7, NULL, NULL, @status)
						report_error()
	    			EndIf

					Dim As UByte cmdset(3)
					cmdset(0) = 5
					If sensor_port = RBN_PORT1 Then cmdset(1) = 0
					If sensor_port = RBN_PORT2 Then cmdset(1) = 1
					If sensor_port = RBN_PORT3 Then cmdset(1) = 2
					If sensor_port = RBN_PORT4 Then cmdset(1) = 3
					cmdset(2) = 0
					cmdset(3) = 0
					NXT.SendDirectCommand(hNXT, FALSE, @cmdset(0), 4, NULL, NULL, @status)
					report_error()
	    		EndIf
    		EndIf
    		
    		'Clear everything so we know it's not in use...
    		monitors(monnum).hwnd = NULL
			monitors(monnum).sensor_type = 0
			monitors(monnum).sensor_port = 0
			monitors(monnum).status = 0
			monitors(monnum).monitoring = FALSE
    		Return TRUE
    End Select

   Return FALSE
End Function


Sub monitor
	'Displays a monitor dialog.
	hNXT_usecount += 1
	Dim As Integer ret
	ret = DialogBox(GetModuleHandle(NULL), MAKEINTRESOURCE(DLG_MONITOR), NULL, @MonitorDlgProc)
	If ret = IDOK Then
	ElseIf ret <> IDCANCEL And ret <> IDOK Then
		MessageBox(NULL, "Dialog exited with unknown value. (error?)", "Notice", MB_OK Or MB_ICONINFORMATION)
	EndIf
	hNXT_usecount += 1
End Sub
