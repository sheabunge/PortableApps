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


Dim Shared As WNDPROC oldproc
Dim Shared As HWND dlghwnd
Dim Shared As UByte cmdl(11) = {4, 0, 75, 1, 0, 0, &h20, 0, 0, 0, 0}, cmdr(11) = {4, 2, 75, 1, 0, 0, &h20, 0, 0, 0, 0}, _
				cmdstop(11) = {4, 255, 0, 1, 0, 0, 0, 0, 0, 0, 0}
Dim Shared As Integer ldir, rdir


Function Rc1DlgProc(ByVal hwnd As HWND, ByVal umsg As UINT, ByVal wparam As WPARAM, ByVal lparam As LPARAM) As Integer
    Static As Integer lm, rm, controller, controlling, lbw, lbh, x2, y2, mousetrapped, status
	Static As Single x, y
	Static As RECT rect
	Static As HDC hdc
	Static As Point p

    Select Case uMsg
    	Case WM_INITDIALOG
    		lm = -1: rm = -1: controller = -1: controlling = FALSE: ldir = 1: rdir = 1: mousetrapped = FALSE: status = 0
    		'rc_hNXT = NXT.CreateNXT(@NXTs(NXT_to_command).resstr, @status, TRUE)
			'report_error()

			GetWindowRect(GetDlgItem(hwnd, JOYPOS), @rect)
			lbw = rect.right - rect.left
			lbh = rect.bottom - rect.top
			hdc = GetDC(GetDlgItem(hwnd, JOYPOS))
			SetMapMode(hdc, MM_TEXT)
			SelectObject(hdc, GetStockObject(BLACK_BRUSH))
			p.x = -100: p.y = -100
			dlghwnd = hwnd
			oldproc = Cast(WNDPROC, GetWindowLong(GetDlgItem(hwnd, JOYPOS), GWL_WNDPROC))
			SetWindowLong(GetDlgItem(hwnd, JOYPOS), GWL_WNDPROC, Cast(Integer, @LbProc))
			
	    	SetTimer(hwnd, NULL, 50, NULL)
	    	Return TRUE
    	Case WM_COMMAND
	        Select Case LoWord(wparam)
	        	Case RBN_L_PORTA
	        		If IsDlgButtonChecked(hwnd, RBN_L_PORTA) Then lm = RBN_L_PORTA: cmdl(1) = 0
	        	Case RBN_L_PORTB
	        		If IsDlgButtonChecked(hwnd, RBN_L_PORTB) Then lm = RBN_L_PORTB: cmdl(1) = 1
	        	Case RBN_L_PORTC
	        		If IsDlgButtonChecked(hwnd, RBN_L_PORTC) Then lm = RBN_L_PORTC: cmdl(1) = 2
	        	Case RBN_R_PORTA
	        		If IsDlgButtonChecked(hwnd, RBN_R_PORTA) Then rm = RBN_R_PORTA: cmdr(1) = 0
	        	Case RBN_R_PORTB
	        		If IsDlgButtonChecked(hwnd, RBN_R_PORTB) Then rm = RBN_R_PORTB: cmdr(1) = 1
	        	Case RBN_R_PORTC
	        		If IsDlgButtonChecked(hwnd, RBN_R_PORTC) Then rm = RBN_R_PORTC: cmdr(1) = 2
	        	Case RBN_JOYSTICK
	        		If IsDlgButtonChecked(hwnd, RBN_JOYSTICK) Then controller = RBN_JOYSTICK
	        	Case RBN_MOUSE
	        		If IsDlgButtonChecked(hwnd, RBN_MOUSE) Then controller = RBN_MOUSE
	        	Case CHK_L_REV
	        		If IsDlgButtonChecked(hwnd, CHK_L_REV) Then ldir = -1 Else ldir = 1
	        	Case CHK_R_REV
	        		If IsDlgButtonChecked(hwnd, CHK_R_REV) Then rdir = -1 Else rdir = 1
	        	Case IDOK
	        		If controlling Then
	        			SendDlgItemMessage(hwnd, IDOK, WM_SETTEXT, NULL, Cast(LPARAM, @"Start Controlling"))
	        			'EnableWindow(GetDlgItem(hwnd, IDOK), FALSE)
		        		EnableWindow(GetDlgItem(hwnd, RBN_L_PORTA), TRUE)
		        		EnableWindow(GetDlgItem(hwnd, RBN_L_PORTB), TRUE)
		        		EnableWindow(GetDlgItem(hwnd, RBN_L_PORTC), TRUE)
		        		EnableWindow(GetDlgItem(hwnd, RBN_R_PORTA), TRUE)
		        		EnableWindow(GetDlgItem(hwnd, RBN_R_PORTB), TRUE)
		        		EnableWindow(GetDlgItem(hwnd, RBN_R_PORTC), TRUE)
		        		EnableWindow(GetDlgItem(hwnd, RBN_JOYSTICK), TRUE)
		        		EnableWindow(GetDlgItem(hwnd, RBN_MOUSE), TRUE)
		        		EnableWindow(GetDlgItem(hwnd, CHK_L_REV), TRUE)
		        		EnableWindow(GetDlgItem(hwnd, CHK_R_REV), TRUE)
		        		ShowWindow(GetDlgItem(hwnd, STC_STARTMSG), SW_HIDE)
		        		If controller = RBN_JOYSTICK Then
		        			SetROP2(hdc, R2_WHITE)
				    		MoveToEx(hdc, x2 - 4, y2, NULL)
				    		LineTo(hdc, x2 + 5, y2)
				    		MoveToEx(hdc, x2, y2 - 4, NULL)
				    		LineTo(hdc, x2, y2 + 5)
				
							SetROP2(hdc, R2_BLACK)
				    		MoveToEx(hdc, 0, lbh / 2, NULL)
				    		LineTo(hdc, lbw + 1, lbh / 2)
				    		MoveToEx(hdc, lbw / 2, 0, NULL)
				    		LineTo(hdc, lbw / 2, lbh + 1)
				    	endif
		        		controlling = FALSE
		        		SetMotors(0, 0)
	        		Else
	        			If cmdl(1) = cmdr(1) Then MessageBox(hwnd, "You must select different ports for the left and right motors.", "NeXT Commander", MB_OK Or MB_ICONSTOP): Return TRUE
		        		If lm > 0 And rm > 0 And controller > 0 Then
		        			SendDlgItemMessage(hwnd, IDOK, WM_SETTEXT, NULL, Cast(LPARAM, @"Stop Controlling"))
			        		EnableWindow(GetDlgItem(hwnd, RBN_L_PORTA), FALSE)
			        		EnableWindow(GetDlgItem(hwnd, RBN_L_PORTB), FALSE)
			        		EnableWindow(GetDlgItem(hwnd, RBN_L_PORTC), FALSE)
			        		EnableWindow(GetDlgItem(hwnd, RBN_R_PORTA), FALSE)
			        		EnableWindow(GetDlgItem(hwnd, RBN_R_PORTB), FALSE)
			        		EnableWindow(GetDlgItem(hwnd, RBN_R_PORTC), FALSE)
			        		EnableWindow(GetDlgItem(hwnd, RBN_JOYSTICK), FALSE)
			        		EnableWindow(GetDlgItem(hwnd, RBN_MOUSE), FALSE)
			        		EnableWindow(GetDlgItem(hwnd, CHK_L_REV), FALSE)
			        		EnableWindow(GetDlgItem(hwnd, CHK_R_REV), FALSE)
		        			If controller = RBN_JOYSTICK Then
								x2 = -20: y2 = -20
		        			EndIf
		        			If controller = RBN_MOUSE Then ShowWindow(GetDlgItem(hwnd, STC_STARTMSG), SW_SHOW)
		        			controlling = TRUE
		        		EndIf
	        		EndIf
	        End Select
	        If lm > 0 And rm > 0 And controller > 0 Then EnableWindow(GetDlgItem(hwnd, IDOK), TRUE)
    	Case WM_MOUSEMOVE
    		If controller = RBN_MOUSE And controlling And mousetrapped Then
	    		x2 = p.x - rect.left
	    		y2 = p.y - rect.top
	    		SetROP2(hdc, R2_WHITE)
	    		MoveToEx(hdc, x2 - 4, y2, NULL)
	    		LineTo(hdc, x2 + 5, y2)
	    		MoveToEx(hdc, x2, y2 - 4, NULL)
	    		LineTo(hdc, x2, y2 + 5)
	    		GetCursorPos(@p)
	    		'p.x = LoWord(lparam): p.y = HiWord(lparam)
	
				SetROP2(hdc, R2_BLACK)
	    		MoveToEx(hdc, 0, lbh / 2, NULL)
	    		LineTo(hdc, lbw + 1, lbh / 2)
	    		MoveToEx(hdc, lbw / 2, 0, NULL)
	    		LineTo(hdc, lbw / 2, lbh + 1)
	
				x2 = p.x - rect.left
	    		y2 = p.y - rect.top
	    		SetROP2(hdc, R2_NOTXORPEN)
	    		MoveToEx(hdc, x2 - 4, y2, NULL)
	    		LineTo(hdc, x2 + 5, y2)
	    		MoveToEx(hdc, x2, y2 - 4, NULL)
	    		LineTo(hdc, x2, y2 + 5)
	    		
	    		x2 = p.x - rect.left
	    		If x2 < 0 Then x2 = 0
	    		If x2 > lbw Then x2 = lbw
	    		y2 = p.y - rect.top
	    		If y2 < 0 Then y2 = 0
	    		If y2 > lbh Then y2 = lbh
	    		x = (x2 - lbw / 2) / lbw * 2
	    		y = -(y2 - lbh / 2) / lbh * 2
	    		SetMotors(x, y)
    		EndIf
    	Case WM_LBUTTONDOWN
    		If controlling And controller = RBN_MOUSE Then
    			GetCursorPos(@p)
    			If p.x >= rect.left And p.x <= rect.right And p.y >= rect.top And p.x <= rect.bottom Then
    				If mousetrapped Then
    					ClipCursor(NULL)
    					ShowCursor(TRUE)
    					ShowWindow(GetDlgItem(hwnd, STC_STARTMSG), SW_SHOW)
    					ShowWindow(GetDlgItem(hwnd, STC_STOPMSG), SW_HIDE)

    					SetROP2(hdc, R2_WHITE)
			    		MoveToEx(hdc, x2 - 4, y2, NULL)
			    		LineTo(hdc, x2 + 5, y2)
			    		MoveToEx(hdc, x2, y2 - 4, NULL)
			    		LineTo(hdc, x2, y2 + 5)
			    		SetROP2(hdc, R2_BLACK)
			    		MoveToEx(hdc, 0, lbh / 2, NULL)
			    		LineTo(hdc, lbw + 1, lbh / 2)
			    		MoveToEx(hdc, lbw / 2, 0, NULL)
			    		LineTo(hdc, lbw / 2, lbh + 1)

    					mousetrapped = FALSE
    					SetMotors(0, 0)
    				Else
    					ClipCursor(@rect)
    					ShowCursor(FALSE)
    					ShowWindow(GetDlgItem(hwnd, STC_STARTMSG), SW_HIDE)
    					ShowWindow(GetDlgItem(hwnd, STC_STOPMSG), SW_SHOW)
    					mousetrapped = TRUE
    				EndIf
    			EndIf
    		EndIf
    	Case WM_TIMER
    		If leaving_command_seceen Then SendMessage(hwnd, WM_CLOSE, NULL, NULL): Return TRUE
    		If controlling = FALSE Then
	    		SetROP2(hdc, R2_BLACK)
	    		MoveToEx(hdc, 0, lbh / 2, NULL)
	    		LineTo(hdc, lbw + 1, lbh / 2)
	    		MoveToEx(hdc, lbw / 2, 0, NULL)
	    		LineTo(hdc, lbw / 2, lbh + 1)
    		EndIf
    		If controller = RBN_JOYSTICK And controlling Then
    			SetROP2(hdc, R2_WHITE)
	    		MoveToEx(hdc, x2 - 4, y2, NULL)
	    		LineTo(hdc, x2 + 5, y2)
	    		MoveToEx(hdc, x2, y2 - 4, NULL)
	    		LineTo(hdc, x2, y2 + 5)
	
				SetROP2(hdc, R2_BLACK)
	    		MoveToEx(hdc, 0, lbh / 2, NULL)
	    		LineTo(hdc, lbw + 1, lbh / 2)
	    		MoveToEx(hdc, lbw / 2, 0, NULL)
	    		LineTo(hdc, lbw / 2, lbh + 1)
	    		
	    		GetJoystick 0,, x, y: y = -y
				x2 = lbw / 2 + x / 2 * lbw
				y2 = lbh / 2 + -y / 2 * lbh
	
				SetROP2(hdc, R2_NOTXORPEN)
	    		MoveToEx(hdc, x2 - 4, y2, NULL)
	    		LineTo(hdc, x2 + 5, y2)
	    		MoveToEx(hdc, x2, y2 - 4, NULL)
	    		LineTo(hdc, x2, y2 + 5)

	    		SetMotors(x, y)
    		EndIf
    	Case WM_MOVE
    		GetWindowRect(GetDlgItem(hwnd, JOYPOS), @rect)
    	Case WM_CLOSE
    		ReleaseDC(hwnd, hdc)
	    	If OldProc <> 0 Then
      			SetWindowLong(GetDlgItem(hwnd, JOYPOS), GWL_WNDPROC, Cast(Integer, OldProc))
      			OldProc = 0
	    	End If
    		EndDialog(hwnd, IDCANCEL)

    		NXT.SendDirectCommand(hNXT, FALSE, @cmdstop(0), 12, NULL, NULL, @status)
    End Select

   Return FALSE
End Function

Sub SetMotors(x As Single, y As Single)
	Dim As Integer status
	Const PI = 3.141593
	Dim As Single rad, ang, dist, l, r

	rad = PI / 2 - Atan2(y, x)
	If rad < 0 Then rad += 2 * PI
	ang = (rad * 180) / PI

	dist = Sqr(x * x + y * y)
	If dist > 1 Then dist = 1

	Select Case ang
		Case 248 To 269: l = -1: r = 1
		Case 270 To 314
			l = -(1 - (ang - 270) / 44)
			r = 1
		Case 315 To 360
			l = (ang - 315) / 44
			r = 1
		Case 0 To 44
			l = 1
			r = 1 - ang / 44
		Case 45 To 89
			l = 1
			r = -(ang - 45) / 44
		Case 90 To 128: l = 1: r = -1
		Case 134 To 179
			l = -1
			r = -(ang - 134) / 44
		Case 179 To 224
			l = -(1 - (ang - 180) / 44)
			r = -1
	End Select

	cmdl(2) = l * dist * 100 * ldir
	NXT.SendDirectCommand(hNXT, FALSE, @cmdl(0), 12, NULL, NULL, @status)

	cmdr(2) = r * dist * 100 * rdir
	NXT.SendDirectCommand(hNXT, FALSE, @cmdr(0), 12, NULL, NULL, @status)
End Sub


Sub rc1(hwnd As Any Ptr)
	If rc_open Then Exit Sub
	rc_open = TRUE
	hNXT_usecount += 1
	EnableWindow(GetDlgItem(Cast(HWND, hwnd), BTN_RC1), FALSE)
	Dim As Integer ret
	ret = DialogBox(GetModuleHandle(NULL), MAKEINTRESOURCE(DLG_RC1), NULL, @Rc1DlgProc)
	If ret = IDOK Then
	ElseIf ret <> IDCANCEL And ret <> IDOK Then
		MessageBox(NULL, "Dialog exited with unknown value. (error?)", "Notice", MB_OK Or MB_ICONINFORMATION)
	EndIf
	hNXT_usecount -= 1
	rc_open = FALSE
	EnableWindow(GetDlgItem(Cast(HWND, hwnd), BTN_RC1), TRUE)
End Sub


Function LbProc(ByVal hwnd As HWND, ByVal uMsg As UInteger, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As LRESULT
	If umsg = WM_MOUSEMOVE Or umsg = WM_LBUTTONDOWN Then
		SendMessage(dlghwnd, umsg, wparam, lparam)
		Return 0
	Else
		Return CallWindowProc(oldproc, hwnd, uMsg, wParam, lParam)
	End If
End Function
