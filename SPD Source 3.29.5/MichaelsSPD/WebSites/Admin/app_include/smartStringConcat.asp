<%
'	<!--
'		METADATA TYPE="TypeLib"
'		NAME="Microsoft ActiveX Data Objects Library"
'		UUID="{00000201-0000-0010-8000-00AA006D2EA4}"
'	-->
'-------------------------------------------
'-------------------------------------------
'	http://www.asp101.com/articles/marcus/concatenation/default.asp
'	“…Unfortunately VBScript's string concatenation peformance has an N-squared 
'	cost, i.e. the time taken to add each additional substring is proportional 
'	to the length of the entire string, and thus the total time taken to perform N 
'	concatenations follows an exponential curve, which quickly comes to dwarf the 
'	execution time for the rest of the code in the script.”
'-------------------------------------------
'-------------------------------------------

'Format the time for display as ms
Function FormatMS(Value)
	FormatMS = FormatNumber(1000 * Value, 1)
End Function


'-------------------------------------------
'String concatenation class (using an array)
'-------------------------------------------
'Written by Marcus Tucker, July 2004
'http://marcustucker.com
'-------------------------------------------
Class StrConCatArray
	Private StringCounter
	Private StringArray()
	Private StringLength
	Private InitStringLength
	
	'called at creation of instance
	Private Sub Class_Initialize()
		StringCounter = 0
		InitStringLength = 128
		ReDim StringArray(InitStringLength - 1)
		StringLength = InitStringLength
	End Sub
	
	Private Sub Class_Terminate()
		Erase StringArray
	End Sub

	'add new string to array
	Public Sub Add(byref NewString)
		StringArray(StringCounter) = NewString
		StringCounter = StringCounter + 1
		
		'ReDim array if necessary
		If StringCounter MOD StringLength = 0 Then
			'redimension
			ReDim Preserve StringArray(StringCounter + StringLength - 1)
			
			'double the size of the array next time
			StringLength = StringLength * 2
		End If
	End Sub
	
	'return the concatenated string
	Public Property Get Value
		Value = Join(StringArray, "")
	End Property 
	
	'resets array
	Public Function Clear()
		StringCounter = 0
		
		Redim StringArray(InitStringLength - 1)
		StringLength = InitStringLength
	End Function		
End Class 


'-------------------------------------------
'String concatenation class (using a stream)
'-------------------------------------------
'Written by Marcus Tucker, July 2004
'http://marcustucker.com
'-------------------------------------------
Class StrConCatStream
	Private Stream
	Private StringArray()
	Private StringLength
	
	'called at creation of instance
	Private Sub Class_Initialize()
		Set Stream = Server.CreateObject("ADODB.Stream")
		Stream.Type = 2 'Text
		Stream.Open
	End Sub
	
	Private Sub Class_Terminate()
		Stream.Close
		Set Stream = Nothing
	End Sub

	'add new string to array
	Public Sub Add(byref NewString)
		Stream.WriteText NewString
	End Sub
	
	'return the concatenated string
	Public Property Get Value
		Stream.Position = 0
		Value = Stream.ReadText()
	End Property

	'resets class
	Public Function Clear()
		StringCounter = 0
		Stream.Position = 0
		Call Stream.SetEOS()
	End Function		
End Class
%>