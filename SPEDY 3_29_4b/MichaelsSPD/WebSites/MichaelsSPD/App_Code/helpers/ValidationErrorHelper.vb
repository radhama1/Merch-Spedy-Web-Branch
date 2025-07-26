Imports System
Imports System.Diagnostics

Imports Microsoft.VisualBasic

Public Class ValidationErrorHelper

    Public Const VAL_ERROR_DATE As String = "{0} must be a valid date."
    Public Const VAL_ERROR_GENERAL As String = "{0} has a validation error."
    Public Const VAL_ERROR_INTEGER As String = "{0} must be a valid integer."
    Public Const VAL_ERROR_INVALID As String = "{0} is not valid."
    Public Const VAL_ERROR_INVALID_VALUE As String = "{0} has a value of, {1}, which is not valid."
    Public Const VAL_ERROR_NUMBER As String = "{0} must be a valid number."
    Public Const VAL_ERROR_RANGE As String = "{0} must be between {1} and {2}."
    Public Const VAL_ERROR_REQUIRED As String = "{0} is a required field."

    Public Const VAL_ERROR_NO_ITEMS As String = "There are no items in this batch.  Batches must have at least one item."


    Public Shared Function GetInvalidErrorString(ByVal field As String, ByVal fieldFormat As String) As String
        Dim strError As String = String.Empty
        Select Case fieldFormat.ToLower()
            Case "date"
                strError = VAL_ERROR_DATE
            Case "integer", "long"
                strError = VAL_ERROR_INTEGER
            Case "decimal", "number"
                strError = VAL_ERROR_NUMBER
            Case Else
                strError = VAL_ERROR_INVALID
        End Select
        strError = String.Format(strError, field)
        Return strError
    End Function

    Public Shared Function GetErrorString(ByVal errType As ErrorType, ByVal ParamArray values() As Object) As String
        Dim strError As String = String.Empty

        Try
            Select Case errType
                Case ErrorType.ErrorCustom
                    If values.Length > 0 Then
                        Dim vals() As Object
                        Dim bFormat As Boolean = False
                        If values.Length >= 2 Then
                            ReDim vals(values.Length - 2)
                            For i As Integer = 0 To values.Length - 2
                                vals(i) = values(i + 1)
                            Next
                            bFormat = True
                        Else
                            ReDim vals(0)
                        End If
                        If bFormat And vals.Length > 0 Then
                            Return String.Format(values(0), vals)
                        Else
                            Return values(0)
                        End If

                    Else
                        Return String.Empty
                    End If

                Case ErrorType.ErrorDate
                    strError = VAL_ERROR_DATE

                Case ErrorType.ErrorGeneral
                    strError = VAL_ERROR_GENERAL

                Case ErrorType.ErrorInteger
                    strError = VAL_ERROR_INTEGER

                Case ErrorType.ErrorInvalid
                    strError = VAL_ERROR_INVALID

                Case ErrorType.ErrorInvalidValue
                    strError = VAL_ERROR_INVALID_VALUE

                Case ErrorType.ErrorNumber
                    strError = VAL_ERROR_NUMBER

                Case ErrorType.ErrorRange
                    strError = VAL_ERROR_RANGE

                Case ErrorType.ErrorRequired
                    strError = VAL_ERROR_REQUIRED

                Case Else
                    Debug.Assert(True)
                    Return String.Empty
            End Select

            If values.Length > 0 Then
                Return String.Format(strError, values)
            Else
                Return strError
            End If
        Catch sfex As FormatException
            Return strError
        Catch ex As Exception
            Return strError
        End Try
        Return strError
    End Function


End Class

Public Enum ErrorType
    ErrorCustom = 0
    ErrorDate
    ErrorGeneral
    ErrorInteger
    ErrorInvalid
    ErrorInvalidValue
    ErrorNumber
    ErrorRange
    ErrorRequired
End Enum