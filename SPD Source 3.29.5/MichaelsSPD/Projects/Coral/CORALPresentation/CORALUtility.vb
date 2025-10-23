Imports System.Text
Imports System.Text.RegularExpressions

Public Class CORALUtility

    Public Shared Function FixNull(ByVal objData As Object, ByVal objType As Type) As Object
        'Utility funcion that will take in a value and a type and check to see if its DBNull.  If we do have a DBNull value
        'we set it to whatever the default null value woudl be for visual basic.
        If IsDBNull(objData) Then
            Select Case System.Type.GetTypeCode(objType)
                Case TypeCode.Int16, TypeCode.Int32, TypeCode.Int64, _
                    TypeCode.Decimal, TypeCode.Double, _
                    TypeCode.Single, TypeCode.UInt16, TypeCode.UInt32, _
                    TypeCode.UInt64
                    Return 0
                Case TypeCode.String
                    Return ""
                Case TypeCode.DateTime
                    Return DateTime.MinValue
                Case TypeCode.Boolean
                    Return False
                Case Else
                    Return Nothing
            End Select
        Else
            Return objData
        End If
    End Function

    Public Shared Function FindStringInArray(ByVal myString As String, ByVal myArray As String()) As Integer
        'Searches through an array of strings looking for a matched value and returns the position it was FIRST
        'located, regardless of sort.  Needed to create this because of issues using array.binarysearch when the
        'string array contained unsorted strings that represent integers
        Dim x As Integer

        For x = 0 To myArray.GetUpperBound(0) 'get lenght of the array and loop through it
            If myArray(x) = myString Then 'check for a match
                Return x 'we hit a match, return the position
            End If
        Next
        Return -1 'there was no match, return a negative number
    End Function

    Public Shared Function ReplaceFlash(ByVal strHTML As String) As String
        Dim objString As String
        Dim replaceString As New StringBuilder

        Dim myMatches As MatchCollection
        Dim myMatch As Match

        myMatches = Regex.Matches(strHTML, "<object(.|\n|)*?</object>", RegexOptions.IgnoreCase)
        For Each myMatch In myMatches
            'Get the string from our match
            objString = myMatch.Value

            'elininate line feeds as that will break the javascript
            objString = Regex.Replace(objString, "\n", "")
            objString = Regex.Replace(objString, "\r", "")
            objString = Regex.Replace(objString, "\f", "")

            'create the new string to be inserted
            replaceString.Append("<script language=javascript>")
            replaceString.Append("InsertFlashMovie('")
            replaceString.Append(objString)
            replaceString.Append("');</script>")

            'insert the string
            strHTML = Regex.Replace(strHTML, "<object(.|\n|)*?</object>", replaceString.ToString, RegexOptions.IgnoreCase)
        Next

        Return strHTML
    End Function

    Public Shared Function CleanURL(ByVal strRefURL As String) As String
        strRefURL = Replace(strRefURL, "http://", "")
        strRefURL = Replace(strRefURL, "https://", "")
        strRefURL = Replace(strRefURL, "www", "")
        If Left(strRefURL, 1) = "." Then
            strRefURL = Mid(strRefURL, 2, strRefURL.Length)
        End If
        If InStr(strRefURL, "/") > 0 Then
            strRefURL = Mid(strRefURL, 1, InStr(strRefURL, "/") - 1)
        End If
        Return Trim(strRefURL)
    End Function
End Class
