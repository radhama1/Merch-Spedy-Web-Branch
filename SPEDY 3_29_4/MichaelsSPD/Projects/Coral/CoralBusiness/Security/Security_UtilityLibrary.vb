Imports System
Imports System.Data
Imports System.Data.SqlClient

Imports NovaLibra.Common
Imports NLData = NovaLibra.Coral.Data
Imports NLUtil = NovaLibra.Coral.Data.Utilities

Imports MSXML2
Imports Scripting

Namespace Security

    '==============================================================================
    ' CLASS: Security_UtilityLibrary
    ' By ken.wallace
    '==============================================================================
    '
    ' This object holds global data access and conversion functions for the 
    ' other security classes.  Modify with care. KW
    '
    '==============================================================================
    Public Class Security_UtilityLibrary

        Public Function FixXMLDateTime(ByVal p_xmlDateStrIn As String, ByVal boolApplyUTCOffset As Boolean) As String
            'XML passes us an ISO8601-formatted date value.
            'This fxn gets a VBScript-compatible Date from the ISO8601-formatted date value
            'by calling dateFromISO8601(sDate)
            Dim UTCOffset As Object, objShellOut As Object, strActiveTimeBiasRegKey As String
            strActiveTimeBiasRegKey = "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation\ActiveTimeBias"

            p_xmlDateStrIn = p_xmlDateStrIn

            If boolApplyUTCOffset Then
                objShellOut = CreateObject("WScript.Shell")
                UTCOffset = objShellOut.RegRead(strActiveTimeBiasRegKey)    ' <-- Delve into the server registry to find out what time offset to use
                UTCOffset = UTCOffset / 60                                    ' <-- The registry stores minutes, so divide by 60 to get offset hours
                'Response.Write "<p>UTCOffset = " & UTCOffset				' <-- Included for debugging

                Return dateFromISO8601(p_xmlDateStrIn, UTCOffset) ' <-- Add the UTC offset to the returned time to correct for time zone and/or Daylight Savings
            Else
                Return dateFromISO8601(p_xmlDateStrIn, 0)         ' <-- Use the time as-is, with no correction for time zone or Daylight Savings
            End If
        End Function

        Private Function dateFromISO8601(ByVal sDate As String, ByVal utcOffset As Object) As String
            'XML passes us an ISO8601-formatted date value.
            'This fxn gets a VBScript-compatible Date from the ISO8601-formatted date value.

            Dim arParts, iMonth, iYear, iDay, iHour, iMinute, iSecond, dtD, s
            s = Replace(Replace(Replace(sDate, "-", ":"), "T", ":"), "Z", "")
            arParts = Split(s, ":")

            'CCYY:MM:DD:hh:mm:ss
            '0    1  2  3  4  5

            If UBound(arParts) < 5 Then
                Return ""
            Else
                iYear = CInt(arParts(0))
                iMonth = CInt(arParts(1))
                iDay = CInt(arParts(2))
                iHour = CInt(arParts(3))
                iMinute = CInt(arParts(4))
                iSecond = CInt(arParts(5))

                dtD = CDate(DateValue(DateSerial(iYear, iMonth, iDay)) & " " & _
                   TimeValue(TimeSerial(iHour, iMinute, iSecond)))

                Return DateAdd("H", utcOffset, dtD)
            End If
        End Function

        Private Function dateToISO8601(ByVal dLocal As Object, ByVal utcOffset As Object) As String
            'XML uses an ISO8601-formatted date value.
            'This fxn gets an ISO8601-formatted date value from a VBScript-compatible date.
            Dim d
            ' convert local time into UTC
            d = DateAdd("H", -1 * utcOffset, dLocal)

            ' compose the date
            Return Year(d) & "-" & Right("0" & Month(d), 2) & "-" & Right("0" & Day(d), 2) & "T" & _
             Right("0" & Hour(d), 2) & ":" & Right("0" & Minute(d), 2) & ":" & Right("0" & Second(d), 2) & "Z"
        End Function

        Public Function loadXMLFromRS(ByVal p_strSQL As String, ByVal p_nodeName As String) As MSXML2.DOMDocument ' Returns an MSXML2.DOMDocument
            'Dim conn
            Dim SQLStr As String, xmlString As String = ""
            'Dim cmd, stream
            Dim xmldoc As MSXML2.FreeThreadedDOMDocument
            SQLStr = p_strSQL
            'Dim objReader As New NLData.DBReader(NLUtil.ApplicationHelper.GetAppSecurityConnection, SQLStr, CommandType.Text)
            Dim objDBCommand As New NLData.DBCommand(NLUtil.ApplicationHelper.GetAppSecurityConnection, SQLStr, CommandType.Text)

            'conn = Server.CreateObject("ADODB.Connection")
            'cmd = Server.CreateObject("ADODB.Command")
            'stream = Server.CreateObject("ADODB.Stream")
            xmldoc = CreateObject("MSXML2.FreeThreadedDOMDocument")

            'conn.Open(Application.Value("connStr"))
            'stream.Open()


            'cmd.CommandType = adCmdText
            'cmd.CommandText = SQLStr
            'cmd.ActiveConnection = conn


            'cmd.Properties("Output Stream").Value = stream
            'cmd.Execute, , adExecuteStream
            'stream.Position = 0
            'objReader.Open()
            'If objReader.Reader.Read Then
            '    xmlString = objReader.Reader.Item(0)
            'End If
            Dim xmlr As System.Xml.XmlReader
            objDBCommand.Connection.Open()
            xmlString = ""
            xmlr = objDBCommand.CommandObject.ExecuteXmlReader()
            xmlr.Read()
            Do While xmlr.ReadState <> Xml.ReadState.EndOfFile
                'System.Diagnostics.Debug.WriteLine()
                xmlString += xmlr.ReadOuterXml()
            Loop
            'xmldoc.LoadXML("<?xml version='1.0'?><Root>" & stream.ReadText & "</Root>")
            'xmldoc.loadXML("<" & p_nodeName & ">" & stream.ReadText & "</" & p_nodeName & ">")
            xmldoc.loadXML("<" & p_nodeName & ">" & xmlString & "</" & p_nodeName & ">")

            If xmldoc.parseError.errorCode <> 0 Then
                'Response.Write("Error loading XML: " & xmldoc.parseError.reason)
                Logger.LogError(New ApplicationException("Error loading XML: " & xmldoc.parseError.reason))
                xmldoc = Nothing

                ' Else
                'Response.Write "xmldoc.xml: " & xmldoc.xml
                '    Return xmldoc
            End If

            ' Disconnect the recordsets and cleanup  
            'cmd.ActiveConnection = Nothing
            'cmd = Nothing
            'conn = Nothing
            'stream = Nothing
            'xmldoc = Nothing
            'objReader.Dispose()
            objDBCommand.Dispose()
            Return xmldoc
        End Function

        Public Function LoadRSFromDB(ByVal p_strSQL As String) As NLData.DBReader
            'Dim rs, cmd
            'rs = Server.CreateObject("ADODB.Recordset")
            'cmd = Server.CreateObject("ADODB.Command")
            Dim objReader As New NLData.DBReader(NLUtil.ApplicationHelper.GetAppSecurityConnection, p_strSQL, CommandType.Text)


            'cmd.ActiveConnection = Application.Value("connStr")
            'cmd.CommandText = p_strSQL
            'cmd.CommandType = adCmdText
            'cmd.Prepared = True

            'rs.CursorLocation = adUseClient
            'rs.Open(cmd, , adOpenForwardOnly, adLockReadOnly)
            objReader.Open()

            'If Err() <> 0 Then
            '   Err.Raise(Err.Number, "ADOHelper: RunSQLReturnRS", Err.Description)
            'End If

            ' Disconnect the recordsets and cleanup  
            'rs.ActiveConnection = Nothing
            'cmd.ActiveConnection = Nothing
            'cmd = Nothing
            'objReader.Command = Nothing
            Return objReader
        End Function

        Public Sub RunSQL(ByVal p_strSQL As String)
            'Dim cmd
            'cmd = Server.CreateObject("ADODB.Command")
            Dim objCmd As New NLData.DBCommand(NLUtil.ApplicationHelper.GetAppSecurityConnection, p_strSQL, System.Data.CommandType.Text)

            'cmd.ActiveConnection = Application.Value("connStr")
            'cmd.ActiveConnection.BeginTrans()
            'cmd.CommandText = p_strSQL
            'cmd.CommandType = adCmdText

            ' Execute the query without returning a recordset
            ' Specifying adExecuteNoRecords reduces overhead and improves performance
            'cmd.Execute(True, , adExecuteNoRecords)
            objCmd.ExecuteNonQuery()
            'cmd.ActiveConnection.CommitTrans()

            'If Err() <> 0 Then
            '   cmd.ActiveConnection.RollBackTrans()
            '   Err.Raise(Err.Number, "ADOHelper: RunSQL", Err.Description)
            'End If

            ' Disconnect the recordsets and cleanup  
            'cmd.ActiveConnection = Nothing
            'cmd = Nothing
            objCmd.Dispose()
            objCmd = Nothing
        End Sub
    End Class

End Namespace
