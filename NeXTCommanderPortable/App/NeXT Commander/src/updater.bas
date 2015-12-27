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


Dim Shared As String response

Function data_callback Cdecl(ByVal buffer As UByte Ptr, ByVal size As Integer, ByVal nitems As Integer, ByVal outstream As Any Ptr) As Integer
	'LibCurl calls this when there's data.
	Dim As Integer bytes = size * nitems

	'Save the data...
	For a As Integer = 0 To bytes - 1
		response += Chr(buffer[a])
	Next

	Return bytes
End Function


Sub checkthread
	uc_thread_running = TRUE
	Dim As Double lastcheck

	'When did we last check for an update?
	If FileExists(cfgpath + ".lastcheck") Then
		Open cfgpath + ".lastcheck" For Input As #1
		Input #1, lastcheck
		Close
	Else
		'Never.
	EndIf


	Do
		Select Case update_freq
			Case 1: 'Every day.
				If DateDiff("d", lastcheck, Now) >= 1 Then checkupdate: lastcheck = Now
			Case 2: 'Once a week.
				If DateDiff("w", lastcheck, Now) >= 1 Then checkupdate: lastcheck = Now
			Case 3: 'Once a month
				If DateDiff("m", lastcheck, Now) >= 1 Then checkupdate: lastcheck = Now
		End Select
		Sleep 1000
	Loop While uc_thread_running
	
	'Gotta remember when we last checked...
	Open cfgpath + ".lastcheck" For Output As #1
	Print #1, lastcheck
	Close
End Sub


Sub checkupdate(manual As Integer = FALSE)
	Dim As CURL Ptr curl
	Dim As CURLcode res

	curl = curl_easy_init
	If curl = 0 Then Exit Sub
	
	'Ask if there's an update...
	curl_easy_setopt(curl, CURLOPT_URL, "http://nextcommander.sourceforge.net/updater/?version=" + VER_STR)
	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, @data_callback)
	response = "" '!"yes\r\n0.6.0.0\r\n590\r\nhttp://nextcommander.sourceforge.net/updater/?download=yes"
	res = curl_easy_perform(curl)
	curl_easy_cleanup(curl)
	
	'Analyse response...
	If Left(response, 3) = "yes" Then
		Dim As Integer ret, a, b
		Dim As String nvn, fsiz, dlurl

		a = InStr(6, response, !"\r\n")
		nvn = Mid(response, 6, a - 6)
		b = InStr(a + 2, response, !"\r\n")
		fsiz = Mid(response, a + 2, b - a - 2)
		dlurl = Right(response, Len(response) - InStrRev(response, !"\r\n") - 1)
		
		ret = MessageBox(NULL, "A new version (" + nvn + ") is available. Download now? (" + fsiz + " KB)", "NeXT Commander", MB_ICONINFORMATION Or MB_YESNO)
		If ret = IDYES Then
			ShellExecute(NULL, "open", dlurl, NULL, NULL, SW_SHOW)
		EndIf
	Else
		If manual Then 'We don't need to bug the user when an AUTOMATIC check doesn't find a new version.
			MessageBox(NULL, "You are using the latest version.", "NeXT Commander", MB_OK Or MB_ICONINFORMATION)
		EndIf
	EndIf
End Sub

	