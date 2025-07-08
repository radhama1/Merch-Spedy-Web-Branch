Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Text.StringBuilder
Imports Microsoft.VisualBasic

Namespace Utilities

    Public Class DataHelper

        Public Shared Function SmartValues(ByVal Value As Object, ByVal whatType As String, Optional ByVal useNull As Boolean = False) As Object
            whatType = whatType.ToLower()
            Select Case whatType
                Case "cstr", "string", "str", "varchar", "nvarchar", "char", "text", "listvalue", "special"
                    If IsDBNull(Value) Then
                        Return New String("")
                    Else
                        Return Convert.ToString(Value)
                    End If
                Case "cdec", "decimal", "number", "money"
                    Dim ret As Decimal = IIf(useNull, Decimal.MinValue, 0.0)
                    If Not IsDBNull(Value) And IsNumeric(Value) Then
                        ret = Convert.ToDecimal(Value)
                    End If
                    Return ret
                Case "ccur", "currency", "cdbl", "double"
                    Dim ret As Double = IIf(useNull, Double.MinValue, 0.0)
                    If Not IsDBNull(Value) And IsNumeric(Value) Then
                        ret = Convert.ToDouble(Value)
                    End If
                    Return ret
                Case "clng", "long", "bigint"
                    Dim ret As Long = IIf(useNull, Long.MinValue, 0)
                    If Not IsDBNull(Value) And IsNumeric(Value) Then
                        If Value.ToString().Contains(".") Then
                            ret = Convert.ToInt64(Int(Convert.ToDecimal(Value)))
                        Else
                            ret = Convert.ToInt64(Value)
                        End If
                    End If
                    Return ret
                Case "cint", "integer", "int"
                    Dim ret As Integer = IIf(useNull, Integer.MinValue, 0)
                    If Not IsDBNull(Value) And IsNumeric(Value) Then
                        If Value.ToString().Contains(".") Then
                            ret = Convert.ToInt32(Int(Convert.ToDecimal(Value)))
                        Else
                            ret = Convert.ToInt32(Value)
                        End If
                        'ret = Int(Value)
                    End If
                    Return ret
                Case "smallint", "int16"
                    Dim ret As Int16 = IIf(useNull, Int16.MinValue, 0)
                    If Not IsDBNull(Value) And IsNumeric(Value) Then
                        'ret = Convert.ToInt32(Value)
                        ret = Convert.ToInt16(Value)
                    End If
                    Return ret
                Case "csng", "single"
                    Dim ret As Single = IIf(useNull, Single.MinValue, 0.0)
                    If Not IsDBNull(Value) And IsNumeric(Value) Then
                        ret = Convert.ToSingle(Value)
                    End If
                    Return ret
                Case "cbool", "boolean", "bit"
                    Dim ret As Boolean = False
                    If Not IsDBNull(Value) Then
                        If TypeOf Value Is String Then
                            If Value = "1" Or Value = "-1" Then
                                ret = True
                            End If
                        Else
                            Try
                                ret = Convert.ToBoolean(Value)
                            Catch ex As Exception
                                ret = False
                            End Try
                        End If
                    End If
                    Return ret
                Case "cbyte", "byte"
                    Dim ret As Byte = 0
                    If Not IsDBNull(Value) Then
                        Return Convert.ToByte(Value)
                    End If
                    Return ret
                Case "cdate", "date", "datetime"
                    Dim ret As Date
                    If useNull Then
                        ret = Date.MinValue
                    End If
                    If Not IsDBNull(Value) AndAlso IsDate(Value) Then
                        If Not Value.ToString() = "00/00/0000" Then
                            ret = Convert.ToDateTime(Value)
                        End If
                    End If
                    Return ret
                Case "formatdate"
                    Dim ret As Date = Date.MinValue
                    If Not IsDBNull(Value) AndAlso IsDate(Value) Then
                        ret = Convert.ToDateTime(Value)
                    End If
                    If ret = Date.MinValue Then
                        Return New String("")
                    Else
                        Return ret.ToString("M/d/yyyy")
                    End If
                Case "guid"
                    Dim ret As System.Guid = System.Guid.Empty
                    If Not IsDBNull(Value) Then
                        ret = Value
                    End If
                    Return ret
                Case "formatnumber"
                    If Not IsDBNull(Value) And IsNumeric(Value) Then
                        Return FormatNumber(Value, 2, -1, 0, -1)
                    Else
                        If useNull Then
                            Return String.Empty
                        Else
                            Return FormatNumber(0, 2, -1, 0, -1)
                        End If
                    End If
                Case "formatnumber3"
                    If Not IsDBNull(Value) And IsNumeric(Value) Then
                        Return FormatNumber(Value, 3, -1, 0, -1)
                    Else
                        If useNull Then
                            Return String.Empty
                        Else
                            Return FormatNumber(0, 3, -1, 0, -1)
                        End If
                    End If
                Case "formatnumber4"
                    If Not IsDBNull(Value) And IsNumeric(Value) Then
                        Return FormatNumber(Value, 4, -1, 0, -1)
                    Else
                        If useNull Then
                            Return String.Empty
                        Else
                            Return FormatNumber(0, 4, -1, 0, -1)
                        End If
                    End If
                Case "formatcurrency"
                    If Not IsDBNull(Value) And IsNumeric(Value) Then
                        Return FormatCurrency(Value, 2, 0, 0, -1)
                    Else
                        If useNull Then
                            Return String.Empty
                        Else
                            Return FormatCurrency(0, 2, 0, 0, -1)
                        End If
                    End If
                Case "formatcurrency4"
                    If Not IsDBNull(Value) And IsNumeric(Value) Then
                        Return FormatCurrency(Value, 4, 0, 0, -1)
                    Else
                        If useNull Then
                            Return String.Empty
                        Else
                            Return FormatCurrency(0, 4, 0, 0, -1)
                        End If
                    End If
                Case "formatnumber0"
                    If Not IsDBNull(Value) And IsNumeric(Value) Then
                        Return FormatNumber(Value, -1, -1, 0, -1)
                    Else
                        If useNull Then
                            Return String.Empty
                        Else
                            Return FormatNumber(0, -1, -1, 0, -1)
                        End If
                    End If
                Case "percent"
                    Dim ret As String = String.Empty
                    If Not IsDBNull(Value) AndAlso IsNumeric(Value) AndAlso Not IsEmpty(Value) Then
                        'ret = (Convert.ToDecimal(Value) * 100).ToString() & "%"
                        ret = FormatNumber((Convert.ToDecimal(Value) * 100), 2, -1, 0, -1) & "%"
                    End If
                    Return ret

                Case "percentvalue"
                    Dim ret As String = String.Empty
                    If Not IsDBNull(Value) And IsNumeric(Value) AndAlso Not IsEmpty(Value) Then
                        'ret = (Convert.ToDecimal(Value) * 100).ToString() & "%"
                        Return FormatNumber((Convert.ToDecimal(Value) * 100), 2, -1, 0, -1)
                    End If
                    Return ret

                Case "stringucase", "stringu", "ucase"
                    If IsDBNull(Value) Then
                        Return New String("")
                    Else
                        Return Convert.ToString(Value).ToUpper()
                    End If
                Case "stringlcase", "stringl", "lcase"
                    If IsDBNull(Value) Then
                        Return New String("")
                    Else
                        Return Convert.ToString(Value).ToLower()
                    End If
                Case "stringrs", "stringreplacespecial"
                    If IsDBNull(Value) Then
                        Return New String("")
                    Else
                        Return ReplaceSpecialChars(Convert.ToString(Value))
                    End If
                Case "stringrsu", "stringreplacespecialucase"
                    If IsDBNull(Value) Then
                        Return New String("")
                    Else
                        Return ReplaceSpecialChars(Convert.ToString(Value)).ToUpper()
                    End If

                Case Else
                    Return New String("")
            End Select
        End Function

        Public Shared Function SmartValues(ByVal Value As Object, ByVal whatType As String, ByVal useNull As Boolean, ByVal defObjOnError As Object, Optional ByVal Precision As Integer = 2) As Object
            whatType = whatType.ToLower()
            Select Case whatType
                Case "cstr", "string", "str", "varchar", "nvarchar", "char", "text"
                    If IsDBNull(Value) Then
                        Return New String("")
                    Else
                        Return Convert.ToString(Value)
                    End If
                Case "cdec", "decimal", "number"
                    Dim ret As Decimal = IIf(useNull, Decimal.MinValue, 0.0)
                    Try
                        If Value IsNot Nothing AndAlso Value.ToString().Trim.Length > 0 Then
                            ret = CDec(Convert.ToDecimal(Value).ToString("n" & Precision))
                        Else
                            Return defObjOnError
                        End If
                    Catch ex As Exception
                        Return defObjOnError
                    End Try

                    Return ret
                Case "ccur", "currency", "cdbl", "double"
                    Dim ret As Double = IIf(useNull, Double.MinValue, 0.0)
                    Try
                        If Value IsNot Nothing AndAlso Value.ToString().Trim.Length > 0 Then
                            ret = Convert.ToDouble(Value)
                        Else
                            Return defObjOnError
                        End If
                    Catch ex As Exception
                        Return defObjOnError
                    End Try
                    Return ret
                Case "clng", "long", "bigint"
                    Dim ret As Long = IIf(useNull, Long.MinValue, 0)
                    Try
                        If Value IsNot Nothing AndAlso Value.ToString().Trim.Length > 0 Then
                            ret = Convert.ToInt64(Value)
                        Else
                            Return defObjOnError
                        End If
                    Catch ex As Exception
                        Return defObjOnError
                    End Try
                    Return ret
                Case "cint", "integer", "int"
                    Dim ret As Integer = IIf(useNull, Integer.MinValue, 0)
                    Try
                        If Value IsNot Nothing AndAlso (Value.ToString().Trim.Length > 0 And IsNumeric(Value)) Then
                            If Value.ToString().Contains(".") Then
                                ret = Convert.ToInt32(Int(Convert.ToDecimal(Value)))
                            Else
                                ret = Convert.ToInt32(Value)
                            End If
                        Else
                            Return defObjOnError
                        End If
                    Catch ex As Exception
                        Return defObjOnError
                    End Try
                    Return ret
                Case "smallint", "int16"
                    Dim ret As Int16 = IIf(useNull, Int16.MinValue, 0)
                    Try
                        If Value IsNot Nothing AndAlso Value.ToString().Trim.Length > 0 Then
                            ret = Convert.ToInt16(Value)
                        Else
                            Return defObjOnError
                        End If
                    Catch ex As Exception
                        Return defObjOnError
                    End Try

                    Return ret
                Case "csng", "single"
                    Dim ret As Single = IIf(useNull, Single.MinValue, 0.0)
                    Try
                        If Value IsNot Nothing AndAlso Value.ToString().Trim.Length > 0 Then
                            ret = Convert.ToSingle(Value)
                        Else
                            Return defObjOnError
                        End If
                    Catch ex As Exception
                        Return defObjOnError
                    End Try
                    Return ret
                Case "cbool", "boolean", "bit"
                    Dim ret As Boolean = False
                    If Value IsNot Nothing AndAlso Not IsDBNull(Value) Then
                        If TypeOf Value Is String Then
                            If Value = "1" Or Value = "-1" Then
                                ret = True
                            End If
                        Else
                            Try
                                ret = Convert.ToBoolean(Value)
                            Catch ex As Exception
                                ret = False
                            End Try
                        End If
                    End If
                    Return ret
                Case "cbyte", "byte"
                    Dim ret As Byte = 0
                    Try
                        If Value IsNot Nothing AndAlso Value.ToString().Trim.Length > 0 Then
                            ret = Convert.ToByte(Value)
                        End If
                    Catch ex As Exception
                        Return defObjOnError
                    End Try
                    Return ret
                Case "cdate", "date", "datetime"
                    Dim ret As Date
                    If useNull Then ret = Date.MinValue
                    Try
                        If Value IsNot Nothing AndAlso Value.ToString().Trim().Length > 0 Then
                            ret = Convert.ToDateTime(Value)
                        Else
                            Return defObjOnError
                        End If
                    Catch ex As Exception
                        Return defObjOnError
                    End Try
                    Return ret
                Case "formatdate"
                    Dim ret As Date = Date.MinValue
                    If Value IsNot Nothing AndAlso Not IsDBNull(Value) AndAlso IsDate(Value) Then
                        ret = Convert.ToDateTime(Value)
                    End If
                    If ret = Date.MinValue Then
                        Return New String("")
                    Else
                        Return ret.ToString("M/d/yyyy")
                    End If
                Case "guid"
                    Dim ret As System.Guid = System.Guid.Empty
                    If Not IsDBNull(Value) Then
                        ret = Value
                    End If
                    Return ret
                Case "formatnumber"
                    If Not IsDBNull(Value) AndAlso IsNumeric(Value) Then
                        Return FormatNumber(Value, Precision, -1, 0, -1)
                    Else
                        If useNull Then
                            Return String.Empty
                        Else
                            Return FormatNumber(0, Precision, -1, 0, -1)
                        End If
                    End If
                Case "formatnumber3"
                    If Not IsDBNull(Value) AndAlso IsNumeric(Value) Then
                        Return FormatNumber(Value, 3, -1, 0, -1)
                    Else
                        If useNull Then
                            Return String.Empty
                        Else
                            Return FormatNumber(0, 3, -1, 0, -1)
                        End If
                    End If
                Case "formatnumber4"
                    If Not IsDBNull(Value) AndAlso IsNumeric(Value) Then
                        Return FormatNumber(Value, 4, -1, 0, -1)
                    Else
                        If useNull Then
                            Return String.Empty
                        Else
                            Return FormatNumber(0, 4, -1, 0, -1)
                        End If
                    End If
                Case "formatcurrency"
                    If Not IsDBNull(Value) AndAlso IsNumeric(Value) Then
                        Return FormatCurrency(Value, Precision, 0, 0, -1)
                    Else
                        If useNull Then
                            Return String.Empty
                        Else
                            Return FormatCurrency(0, Precision, 0, 0, -1)
                        End If
                    End If
                Case "formatcurrency4"
                    If Not IsDBNull(Value) AndAlso IsNumeric(Value) Then
                        Return FormatCurrency(Value, 4, 0, 0, -1)
                    Else
                        If useNull Then
                            Return String.Empty
                        Else
                            Return FormatCurrency(0, 4, 0, 0, -1)
                        End If
                    End If
                Case "formatnumber0"
                    If Not IsDBNull(Value) AndAlso IsNumeric(Value) Then
                        Return FormatNumber(Value, -1, -1, 0, -1)
                    Else
                        If useNull Then
                            Return String.Empty
                        Else
                            Return FormatNumber(0, -1, -1, 0, -1)
                        End If
                    End If

                Case "percent"
                    Dim ret As String = String.Empty
                    If Not IsDBNull(Value) And IsNumeric(Value) AndAlso Not IsEmpty(Value) Then
                        'ret = (Convert.ToDecimal(Value) * 100).ToString() & "%"
                        ret = FormatNumber((Convert.ToDecimal(Value) * 100), 2, -1, 0, -1) & "%"
                    End If
                    Return ret

                Case "percentvalue"
                    Dim ret As String = String.Empty
                    If Not IsDBNull(Value) And IsNumeric(Value) AndAlso Not IsEmpty(Value) Then
                        'ret = (Convert.ToDecimal(Value) * 100).ToString() & "%"
                        Return FormatNumber((Convert.ToDecimal(Value) * 100), 2, -1, 0, -1)
                    End If
                    Return ret

                Case "stringucase", "stringu", "ucase"
                    If IsDBNull(Value) Then
                        Return New String("")
                    Else
                        Return Convert.ToString(Value).ToUpper()
                    End If
                Case "stringlcase", "stringl", "lcase"
                    If IsDBNull(Value) Then
                        Return New String("")
                    Else
                        Return Convert.ToString(Value).ToLower()
                    End If
                Case "stringrs", "stringreplacespecial"
                    If IsDBNull(Value) Then
                        Return New String("")
                    Else
                        Return ReplaceSpecialChars(Convert.ToString(Value))
                    End If
                Case "stringrsu", "stringreplacespecialucase"
                    If IsDBNull(Value) Then
                        Return New String("")
                    Else
                        Return ReplaceSpecialChars(Convert.ToString(Value)).ToUpper()
                    End If

                Case Else
                    Return New String("")
            End Select
        End Function

        Public Shared Function SmartValuesDBNull(ByVal value As Object, Optional ByVal ConvertEmptyStringToNothing As Boolean = False) As Object

            If IsDBNull(value) Then
                Return Nothing
            Else
                If ConvertEmptyStringToNothing AndAlso TypeOf value Is String AndAlso value.ToString.Trim() = String.Empty Then
                    Return Nothing
                Else
                    Return value
                End If
            End If

        End Function

        'Returns the converted value and a default value if needed
        Public Shared Function SmartValue(ByVal value As Object, ByVal type As String, Optional ByVal defaultValue As Object = Nothing) As Object

            Dim retValue As Object = defaultValue

            Try

                If Not IsDBNull(value) AndAlso Not value Is Nothing Then
                    retValue = value
                ElseIf IsDBNull(value) Then
                    Return retValue
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

        Public Shared Function SmartValueDB(ByVal value As Object, ByVal type As String, Optional ByVal defaultValue As Object = Nothing) As Object

            If SmartValue(value, "CStr", "").Trim().Length = 0 Then
                Return DBNull.Value
            Else
                If defaultValue Is Nothing Then
                    Return SmartValue(value, type, DBNull.Value)
                Else
                    Return SmartValue(value, type, defaultValue)
                End If

            End If

        End Function

        Public Shared Function DBSmartValues(ByVal Value As Object, ByVal whatType As String, Optional ByVal useNull As Boolean = False) As Object
            whatType = whatType.ToLower()
            Select Case whatType
                Case "cstr", "string", "str", "varchar", "nvarchar", "char", "text"
                    If IsDBNull(Value) OrElse Value = String.Empty Then
                        If useNull Then
                            Return DBNull.Value
                        Else
                            Return String.Empty
                        End If
                    Else
                        Return Convert.ToString(Value)
                    End If
                Case "cdec", "decimal", "number"
                    If Not IsDBNull(Value) And IsNumeric(Value) Then
                        If Convert.ToDecimal(Value) = Decimal.MinValue Then
                            Return IIf(useNull, DBNull.Value, 0.0)
                        Else
                            Return Convert.ToDecimal(Value)
                        End If
                    Else
                        Return IIf(useNull, DBNull.Value, 0.0)
                    End If
                Case "ccur", "currency", "cdbl", "double"
                    If Not IsDBNull(Value) And IsNumeric(Value) Then
                        If Convert.ToDouble(Value) = Double.MinValue Then
                            Return IIf(useNull, DBNull.Value, 0.0)
                        Else
                            Return Convert.ToDouble(Value)
                        End If
                    Else
                        Return IIf(useNull, DBNull.Value, 0.0)
                    End If
                Case "clng", "long", "bigint"
                    If Not IsDBNull(Value) And IsNumeric(Value) Then
                        If Convert.ToInt64(Value) = Long.MinValue Then
                            Return IIf(useNull, DBNull.Value, 0.0)
                        Else
                            Return Convert.ToInt64(Value)
                        End If
                    Else
                        Return IIf(useNull, DBNull.Value, 0.0)
                    End If
                Case "cint", "integer", "int"
                    If Not IsDBNull(Value) And IsNumeric(Value) Then
                        If Convert.ToInt32(Value) = Integer.MinValue Then
                            Return IIf(useNull, DBNull.Value, 0)
                        Else
                            Return Convert.ToInt32(Value)
                        End If
                    Else
                        Return IIf(useNull, DBNull.Value, 0)
                    End If
                Case "smallint", "int16"
                    If Not IsDBNull(Value) And IsNumeric(Value) Then
                        If Convert.ToInt16(Value) = Int16.MinValue Then
                            Return IIf(useNull, DBNull.Value, 0)
                        Else
                            Return Convert.ToInt16(Value)
                        End If
                    Else
                        Return IIf(useNull, DBNull.Value, 0)
                    End If
                Case "csng", "single"
                    If Not IsDBNull(Value) And IsNumeric(Value) Then
                        If Convert.ToSingle(Value) = Single.MinValue Then
                            Return IIf(useNull, DBNull.Value, 0.0)
                        Else
                            Return Convert.ToSingle(Value)
                        End If
                    Else
                        Return IIf(useNull, DBNull.Value, 0.0)
                    End If
                Case "cbool", "boolean", "bit"
                    Dim ret As Boolean = False
                    If Not IsDBNull(Value) Then
                        If TypeOf Value Is String Then
                            If Value = "1" Or Value = "-1" Then
                                ret = True
                            End If
                        Else
                            Try
                                ret = Convert.ToBoolean(Value)
                            Catch ex As Exception
                                If useNull Then
                                    Return DBNull.Value
                                Else
                                    ret = False
                                End If
                            End Try
                        End If
                    Else
                        If useNull Then
                            Return DBNull.Value
                        Else
                            ret = False
                        End If
                    End If
                    Return ret
                Case "cbyte", "byte"
                    Dim ret As Byte = 0
                    If Not IsDBNull(Value) Then
                        Return Convert.ToByte(Value)
                    Else
                        If useNull Then
                            Return DBNull.Value
                        End If
                    End If
                    Return ret
                Case "cdate", "date", "datetime"
                    Dim ret As Date = Date.MinValue
                    If Not IsDBNull(Value) AndAlso IsDate(Value) Then
                        ret = Convert.ToDateTime(Value)
                        If ret = Date.MinValue Then
                            If useNull Then
                                Return DBNull.Value
                            Else
                                Return New String("")
                            End If
                        End If
                    Else
                        If useNull Then
                            Return DBNull.Value
                        Else
                            Return New String("")
                        End If
                    End If
                    Return ret
                Case "guid"
                    Dim ret As System.Guid = System.Guid.Empty
                    If Not IsDBNull(Value) Then
                        ret = Value
                    Else
                        If useNull Then
                            Return DBNull.Value
                        End If
                    End If
                    Return ret
                Case "formatnumber"
                    If Not IsDBNull(Value) Then
                        Return FormatNumber(Value, 2, 0, 0, -1)
                    Else
                        Return FormatNumber(0, 2, 0, 0, -1)
                    End If
                Case "formatnumber3"
                    If Not IsDBNull(Value) Then
                        Return FormatNumber(Value, 3, 0, 0, -1)
                    Else
                        Return FormatNumber(0, 3, 0, 0, -1)
                    End If
                Case "formatnumber4"
                    If Not IsDBNull(Value) Then
                        Return FormatNumber(Value, 4, 0, 0, -1)
                    Else
                        Return FormatNumber(0, 4, 0, 0, -1)
                    End If
                Case "formatcurrency"
                    If Not IsDBNull(Value) Then
                        Return FormatCurrency(Value, 2, 0, 0, -1)
                    Else
                        Return FormatCurrency(0, 2, 0, 0, -1)
                    End If
                Case "formatcurrency4"
                    If Not IsDBNull(Value) Then
                        Return FormatCurrency(Value, 4, 0, 0, -1)
                    Else
                        Return FormatCurrency(0, 4, 0, 0, -1)
                    End If
                Case "formatnumber0"
                    If Not IsDBNull(Value) Then
                        Return FormatNumber(Value, -1, -1, 0, -1)
                    Else
                        Return FormatNumber(0, -1, -1, 0, -1)
                    End If

                Case "stringucase", "stringu", "ucase"
                    If IsDBNull(Value) OrElse Value = String.Empty Then
                        If useNull Then
                            Return DBNull.Value
                        Else
                            Return String.Empty
                        End If
                    Else
                        Return Convert.ToString(Value).ToUpper()
                    End If
                Case "stringlcase", "stringl", "lcase"
                    If IsDBNull(Value) OrElse Value = String.Empty Then
                        If useNull Then
                            Return DBNull.Value
                        Else
                            Return String.Empty
                        End If
                    Else
                        Return Convert.ToString(Value).ToLower
                    End If
                Case "stringrs", "stringreplacespecial"
                    If IsDBNull(Value) OrElse Value = String.Empty Then
                        If useNull Then
                            Return DBNull.Value
                        Else
                            Return String.Empty
                        End If
                    Else
                        Return ReplaceSpecialChars(Convert.ToString(Value))
                    End If
                Case "stringrsu", "stringreplacespecialucase"
                    If IsDBNull(Value) OrElse Value = String.Empty Then
                        If useNull Then
                            Return DBNull.Value
                        Else
                            Return String.Empty
                        End If
                    Else
                        Return ReplaceSpecialChars(Convert.ToString(Value)).ToUpper()
                    End If

                Case Else
                    Return New String("")
            End Select
        End Function

        Public Shared Function CheckQueryID(ByVal strIDNum As String, ByVal defaultIDNum As Object) As Integer
            Dim localIDNum As Integer
            If IsNumeric(strIDNum) Then
                localIDNum = Integer.Parse(strIDNum)
            Else
                If IsNumeric(defaultIDNum) Then
                    localIDNum = Integer.Parse(defaultIDNum)
                Else
                    localIDNum = 0
                End If
            End If
            Return localIDNum
        End Function

        Public Shared Function ReplaceSpecialChars(ByVal inputString As String) As String
            Dim returnString As New Text.StringBuilder("")
            Dim charArr As Char()
            Dim charVal As Int32, EndIndex As Integer

            If inputString.Length > 0 Then
                charArr = inputString.ToCharArray()
                EndIndex = charArr.GetLength(0)

                For i As Integer = 0 To EndIndex - 1
                    'charVal = Convert.ToInt32(charArr(i))
                    charVal = Asc(charArr(i))
                    ' ignore charVal < 32
                    If charVal >= 32 AndAlso charVal <= 126 Then
                        returnString.Append(charArr(i))
                    ElseIf charVal >= 127 Then
                        Select Case charVal
                            Case 131
                                returnString.Append("f")
                            Case 138
                                returnString.Append("S")
                            Case 140
                                returnString.Append("OE")
                            Case 142
                                returnString.Append("Z")
                            Case 146
                                returnString.Append("'")
                            Case 153
                                returnString.Append("(TM)")
                            Case 154
                                returnString.Append("s")
                            Case 156
                                returnString.Append("oe")
                            Case 158
                                returnString.Append("z")
                            Case 159
                                returnString.Append("Y")
                            Case 160
                                returnString.Append(" ")
                            Case 161
                                returnString.Append("!")
                            Case 169
                                returnString.Append("(C)")
                            Case 170
                                returnString.Append("a")
                            Case 174
                                returnString.Append("(R)")
                            Case 178
                                returnString.Append("2")
                            Case 179
                                returnString.Append("3")
                            Case 185
                                returnString.Append("1")
                            Case 188
                                returnString.Append("1/4")
                            Case 189
                                returnString.Append("1/2")
                            Case 190
                                returnString.Append("3/4")
                            Case 191
                                returnString.Append("?")
                            Case 192, 193, 194, 195, 196, 197
                                returnString.Append("A")
                            Case 198
                                returnString.Append("AE")
                            Case 199
                                returnString.Append("C")
                            Case 200, 201, 202, 203
                                returnString.Append("E")
                            Case 204, 205, 206, 207
                                returnString.Append("I")
                                'Case 208
                                '    returnString.append("ETH")
                            Case 209
                                returnString.Append("N")
                            Case 210, 211, 212, 213, 214
                                returnString.Append("O")
                            Case 215
                                returnString.Append("x")
                            Case 216
                                returnString.Append("O")
                            Case 217, 218, 219, 220
                                returnString.Append("U")
                            Case 221
                                returnString.Append("Y")
                            Case 224, 225, 226, 227, 228, 229
                                returnString.Append("a")
                            Case 230
                                returnString.Append("ae")
                            Case 231
                                returnString.Append("c")
                            Case 232, 233, 234, 235
                                returnString.Append("e")
                            Case 236, 237, 238, 239
                                returnString.Append("i")
                                'Case 240
                                '    returnString.append("eth")
                            Case 241
                                returnString.Append("n")
                            Case 242, 243, 244, 245, 246
                                returnString.Append("o")
                            Case 247
                                returnString.Append("/")
                            Case 248
                                returnString.Append("o")
                            Case 249, 250, 251, 252
                                returnString.Append("u")
                            Case 253
                                returnString.Append("y")
                            Case 255
                                returnString.Append("y")
                                'Case 65307
                                '    returnString.append(";")
                            Case Else
                                returnString.Append(" ")
                        End Select
                    End If
                Next
            End If
            Return returnString.ToString
        End Function

        Private Shared Function ReplaceSpecialCharsOLD(ByVal inputString As String) As String
            Dim returnString As String = String.Empty
            Dim charArr As Char()
            Dim charVal As Int32
            If inputString.Length > 0 Then
                charArr = inputString.ToCharArray()
                For Each c As Char In charArr

                    charVal = Convert.ToInt32(c)
                    ' ignore charVal < 32
                    If charVal >= 32 And charVal <= 126 Then
                        returnString += c
                    ElseIf charVal >= 127 Then
                        Select Case charVal
                            Case 131
                                returnString += "f"
                            Case 138
                                returnString += "S"
                            Case 140
                                returnString += "OE"
                            Case 142
                                returnString += "Z"
                            Case 146
                                returnString += "'"
                            Case 153
                                returnString += "(TM)"
                            Case 154
                                returnString += "s"
                            Case 156
                                returnString += "oe"
                            Case 158
                                returnString += "z"
                            Case 159
                                returnString += "Y"
                            Case 160
                                returnString += " "
                            Case 161
                                returnString += "!"
                            Case 169
                                returnString += "(C)"
                            Case 170
                                returnString += "a"
                            Case 174
                                returnString += "(R)"
                            Case 178
                                returnString += "2"
                            Case 179
                                returnString += "3"

                            Case 185
                                returnString += "1"
                            Case 188
                                returnString += "1/4"
                            Case 189
                                returnString += "1/2"
                            Case 190
                                returnString += "3/4"
                            Case 191
                                returnString += "?"
                            Case 192, 193, 194, 195, 196, 197
                                returnString += "A"
                            Case 198
                                returnString += "AE"
                            Case 199
                                returnString += "C"
                            Case 200, 201, 202, 203
                                returnString += "E"
                            Case 204, 205, 206, 207
                                returnString += "I"
                                'Case 208
                                '    returnString += "ETH"
                            Case 209
                                returnString += "N"
                            Case 210, 211, 212, 213, 214
                                returnString += "O"
                            Case 215
                                returnString += "x"
                            Case 216
                                returnString += "O"
                            Case 217, 218, 219, 220
                                returnString += "U"
                            Case 221
                                returnString += "Y"
                            Case 224, 225, 226, 227, 228, 229
                                returnString += "a"
                            Case 230
                                returnString += "ae"
                            Case 231
                                returnString += "c"
                            Case 232, 233, 234, 235
                                returnString += "e"
                            Case 236, 237, 238, 239
                                returnString += "i"
                                'Case 240
                                '    returnString += "eth"
                            Case 241
                                returnString += "n"
                            Case 242, 243, 244, 245, 246
                                returnString += "o"
                            Case 247
                                returnString += "/"
                            Case 248
                                returnString += "o"
                            Case 249, 250, 251, 252
                                returnString += "u"
                            Case 253
                                returnString += "y"
                            Case 255
                                returnString += "y"
                                'Case 65307
                                '    returnString += ";"
                            Case Else
                                returnString += " "
                        End Select
                    End If
                Next
            End If
            Return returnString
        End Function

        Public Shared Function SmartValuesAsString(ByRef value As Object, ByVal strType As String) As String
            Dim obj As Object
            obj = SmartValues(value, strType, True)
            If Not IsEmpty(obj) Then Return obj.ToString() Else Return String.Empty
        End Function

        Public Shared Function IsEmpty(ByVal field As Object) As Boolean
            If IsDBNull(field) Then
                Return True
            ElseIf TypeOf field Is Integer Then
                Return (CType(field, Integer) = Integer.MinValue)
            ElseIf TypeOf field Is Int16 Then
                Return (CType(field, Int16) = Int16.MinValue)
            ElseIf TypeOf field Is Long Then
                Return (CType(field, Long) = Long.MinValue)
            ElseIf TypeOf field Is Decimal Then
                Return (CType(field, Decimal) = Decimal.MinValue)
            ElseIf TypeOf field Is Date Then
                Return (CType(field, Date) = Date.MinValue)
            ElseIf TypeOf field Is Boolean Then
                Return (IsDBNull(field))
            ElseIf TypeOf field Is Byte Then
                Return (CType(field, Byte) = Byte.MinValue)
            ElseIf TypeOf field Is Char Then
                Return (CType(field, Char) = Char.MinValue)
            ElseIf TypeOf field Is Single Then
                Return (CType(field, Single) = Single.MinValue)
            ElseIf TypeOf field Is Double Then
                Return (CType(field, Double) = Double.MinValue)
            Else
                Return (field.ToString().Trim() = String.Empty)
            End If
        End Function


        Public Shared Function IsEmptyOrZero(ByVal field As Object, ByVal fieldType As String) As Boolean
            Return IsEmptyOrZero(SmartValues(field, fieldType, True))
        End Function

        Public Shared Function IsEmptyOrZero(ByVal field As Object) As Boolean
            If IsDBNull(field) Then
                Return True
            ElseIf TypeOf field Is Integer Then
                Return (CType(field, Integer) = Integer.MinValue Or CType(field, Integer) = 0)
            ElseIf TypeOf field Is Int16 Then
                Return (CType(field, Int16) = Int16.MinValue Or CType(field, Int16) = 0)
            ElseIf TypeOf field Is Long Then
                Return (CType(field, Long) = Long.MinValue Or CType(field, Long) = 0)
            ElseIf TypeOf field Is Decimal Then
                Return (CType(field, Decimal) = Decimal.MinValue Or CType(field, Decimal) = 0)
            ElseIf TypeOf field Is Date Then
                Return (CType(field, Date) = Date.MinValue)
            ElseIf TypeOf field Is Boolean Then
                Return (IsDBNull(field) Or field = False)
            ElseIf TypeOf field Is Byte Then
                Return (CType(field, Byte) = Byte.MinValue Or CType(field, Byte) = 0)
            ElseIf TypeOf field Is Char Then
                Return (CType(field, Char) = Char.MinValue Or CType(field, Char) = "0")
            ElseIf TypeOf field Is Single Then
                Return (CType(field, Single) = Single.MinValue Or CType(field, Single) = 0)
            ElseIf TypeOf field Is Double Then
                Return (CType(field, Double) = Double.MinValue Or CType(field, Double) = 0)
            Else
                Return (field.ToString().Trim() = String.Empty OrElse field.ToString().Trim() = "0" OrElse (IsNumeric(field.ToString()) AndAlso Convert.ToDecimal(field.ToString()) = 0))
            End If
        End Function

    End Class

End Namespace

