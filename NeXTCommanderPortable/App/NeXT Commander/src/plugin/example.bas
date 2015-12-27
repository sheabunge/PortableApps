#Lang "fb"
#Include "nxt.bi"
#Include "plugin.bi"
#Include "windows.bi"

#If __FB_OUT_DLL__ = 0
#Error "This plugin must be compiled as a dll."
#EndIf


Declare Sub real_action

Sub info(pi As plugin_info Ptr) Export 'Give NeXT Commander info about this plugin.

	pi->kind = 1 'This is the kind of plugin. Curently the only kind is 1.
	pi->version = 1 'This is the version of this kind of plugin, NOT THE VERSION OF THIS FILE. Curently the only version is 1.
	pi->title = "Example" 'This will be displayed on the plugin's button.
End Sub


Sub action(hNXT As NXT.hNXT, leaving_command_screen As Integer Ptr) Export 'NeXT Commander calls this when the button is clicked.
	'The window will freze until we finish here, 
	'so for any lengthy operation or to display another dialog, 
	'you should launch a separate thread and return.

	Type params
		As NXT.hNXT hNXT
		As Integer Ptr leaving_command_screen
	End Type
	
	Dim As params p
	p.hNXT = hNXT
	p.leaving_command_screen = leaving_command_screen
	
	ThreadCreate(Cast(Any Ptr, @real_action), @p) 'Here we're using a UDT to pass parameters to the thread. You could also use Shared variables.
End Sub


Sub real_action 'This is launched as a separate thread, since otherwise the window would freeze until you click Okay.
	MessageBox(NULL, "This is an example plugin.", "NeXT Commander", MB_OK Or MB_ICONINFORMATION)
End Sub
