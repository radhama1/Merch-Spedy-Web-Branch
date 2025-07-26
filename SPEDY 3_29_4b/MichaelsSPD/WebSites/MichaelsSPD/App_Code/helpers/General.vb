
Public Class General

    'Returns whether there is a current process running by the same name
    Public Shared Function PrevInstance() As Boolean

        If UBound(Diagnostics.Process.GetProcessesByName(Diagnostics.Process.GetCurrentProcess.ProcessName)) > 0 Then
            Return True
        Else
            Return False
        End If

    End Function

    'This function returns the file name given a full file path ex: E:\test\file.txt returns file.txt
    Public Shared Function getFileName(ByVal filePathName As String) As String

        Dim retValue As String = ""

        If filePathName.Contains("\") Then
            retValue = Replace(filePathName, Left(filePathName, filePathName.LastIndexOf("\") + 1), "")
        End If

        Return retValue

    End Function

    'Returns the converted value and a default value if needed
    Public Shared Function SmartValues(ByVal value As Object, ByVal type As String, Optional ByVal defaultValue As Object = "") As Object

        Dim retValue As Object = defaultValue

        Try

            If Not IsDBNull(value) AndAlso Not value Is Nothing Then
                retValue = value
            End If

            Select Case UCase(type.Trim)
                Case UCase("CStr")
                    retValue = CStr(retValue)
                Case UCase("CInt")
                    retValue = CInt(retValue)
                Case UCase("CLng")
                    retValue = CLng(retValue)
                Case UCase("CDbl")
                    retValue = CDbl(retValue)
                Case UCase("CBool")
                    retValue = CBool(retValue)
                Case UCase("CShort")
                    retValue = CShort(retValue)
                Case UCase("CDate")
                    retValue = CDate(retValue)
                Case UCase("CBit")
                    retValue = 0
                    If CBool(value) Then retValue = 1
            End Select

        Catch ex As Exception

            retValue = defaultValue

        End Try

        Return retValue

    End Function

    Public Shared Function EnsureEndsWBackslash(ByVal value As String) As String

        Dim retValue As String = value

        If retValue.Length > 0 Then

            If Not retValue.EndsWith("\") Then
                retValue += "\"
            End If

        End If

        Return retValue

    End Function

    Public Shared Function ExistsInStringArray(ByVal valueToFind As String, ByVal strArray As String(), Optional ByVal caseSensitive As Boolean = False) As Boolean

        Dim retValue As Boolean = False

        valueToFind = Trim(SmartValues(valueToFind, "CStr", ""))

        If valueToFind.Length > 0 AndAlso strArray.Length > 0 Then

            For Each str As String In strArray

                If caseSensitive Then
                    If LCase(valueToFind) = LCase(Trim(SmartValues(str, "CStr", ""))) Then
                        retValue = True
                        Exit For
                    End If
                Else
                    If valueToFind = Trim(SmartValues(str, "CStr", "")) Then
                        retValue = True
                        Exit For
                    End If
                End If

            Next

        End If

        Return retValue

    End Function

    Public Shared Function IsEmail(ByVal strValue As String) As Boolean

        Dim retValue As Boolean = False

        If Len(SmartValues(strValue, "CStr")) > 0 Then

            Dim inputEmail As String = SmartValues(strValue, "CStr")
            Dim strRegex As String = "^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}" & _
                  "\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\" & _
                  ".)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$"

            Dim re As New Regex(strRegex)
            If re.IsMatch(inputEmail) Then
                retValue = True
            End If

        End If

        Return retValue

    End Function

End Class
