<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================

function SmartValues(Value, whatType)
    If Not IsNull(Value) And Value <> "" Then
        Select Case whatType
            Case "CStr", "String"
                SmartValues = CStr(Value)
            Case "CCur", "Currency"
                SmartValues = CCur(Value)
            Case "CLng", "Long"
                SmartValues = CLng(Value)
            Case "CInt", "Integer"
                SmartValues = CLng(Value)
            Case "CSng", "Single"
                SmartValues = CSng(Value)
            Case "CDbl", "Double"
                SmartValues = CDbl(Value)
            Case "Cbool", "CBool", "Boolean"
                SmartValues = CBool(Value)
            Case "CByte"
                SmartValues = CByte(Value)
            Case "CDate", "Date", "DateTime"
                If Value = "00/00/0000" Then
                    SmartValues = ""
                Else
                    SmartValues = CDate(Value)
                End If
            Case "FormatNumber"
                SmartValues = FormatNumber(Value,2,0,0,-1)
            Case "FormatCurrency"
                SmartValues = FormatCurrency(Value,2,-1,0,-1)
			Case Else
                SmartValues = Value
        End Select
    Else
		Select Case whatType
			Case "FormatNumber"
				SmartValues = FormatNumber(0,2,0,0,-1)
			Case "FormatCurrency"
				SmartValues = FormatCurrency(0,2,-1,0,-1)
			Case "Integer"
				SmartValues = CLng(0)
			Case "Long"
			    SmartValues = CLng(0)
			Case "Boolean"
				SmartValues = False
			Case "Currency"
				SmartValues = CCur(0.0)
			Case "Double"
				SmartValues = CDbl(0.0)
			Case Else
				SmartValues = ""
		End Select
    End If
End function
%>