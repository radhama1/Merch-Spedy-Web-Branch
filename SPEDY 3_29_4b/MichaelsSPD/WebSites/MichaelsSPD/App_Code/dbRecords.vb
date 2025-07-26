Imports System
Imports System.Data
Imports System.Data.Sql
Imports System.Data.SqlClient
Imports System.IO
Imports Microsoft.VisualBasic

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.Data.Utilities

Public Class DBRecords

    'Public Shared Function RecordCount(ByVal itemHeaderID As Long, Optional ByVal strWhere As String = "") As Integer
    '    Dim connCoop As New SqlConnection(ConfigurationManager.ConnectionStrings("AppConnection").ConnectionString)
    '    Dim commCoop As SqlCommand = Nothing
    '    Dim reader As SqlDataReader
    '    Dim intRecordCount As Int32
    '    Try
    '        connCoop.Open()
    '        Dim strSQL As String = "sp_SPD_Grid_GetListCount"
    '        commCoop = New SqlCommand(strSQL, connCoop)
    '        commCoop.CommandType = CommandType.StoredProcedure
    '        commCoop.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = itemHeaderID
    '        commCoop.Parameters.Add("@whereContains", SqlDbType.NVarChar, 50).Value = strWhere
    '        reader = commCoop.ExecuteReader()

    '        If (reader.Read()) Then
    '            intRecordCount = DataHelper.SmartValues(reader.Item("RecordCount"), "Integer", False)
    '        End If
    '        reader.Close()




    '    Catch ex As ApplicationException

    '    Finally
    '        If Not connCoop.State = ConnectionState.Closed Then
    '            connCoop.Close()
    '        End If
    '        If Not commCoop Is Nothing Then
    '            commCoop.Dispose()
    '            commCoop = Nothing
    '        End If
    '        connCoop.Dispose()
    '        connCoop = Nothing

    '    End Try

    '    Return intRecordCount
    'End Function

    Public Shared Function LoadDefaultEnabledColumns(ByVal gridID As Integer) As String
        Dim XMLStr As String = ""
        Dim objReader As DBReader = Nothing
        Dim SQLStr As String
        Try
            If gridID < 0 Then gridID = 0
            SQLStr = "SELECT * FROM ColumnDisplayName WHERE Display = 1 AND Is_Custom = 0 and ISNULL(Workflow_ID, 1) = " & gridID.ToString() & " ORDER BY Column_Ordinal, [ID]"
            objReader = DataUtilities.GetDBReader(SQLStr)
            If objReader.HasRows Then
                Do While objReader.Read()
                    XMLStr += "<EnabledColumn ColumnID=""" & objReader("ID") & """ />"
                Loop
            End If
        Catch sqlex As SqlException
            Logger.LogError(sqlex)
        Catch ex As Exception
            Logger.LogError(ex)
        Finally
            If Not objReader Is Nothing Then
                objReader.Close()
                objReader.Dispose()
                objReader = Nothing
            End If
        End Try

        If XMLStr = "" Then
            XMLStr = "<DefaultEnabledColumns />"
        Else
            XMLStr = "<DefaultEnabledColumns>" & XMLStr & "</DefaultEnabledColumns>"
        End If

        Return XMLStr
    End Function

    Public Shared Function LoadUserEnabledColumns(ByVal userID As Long, ByVal gridID As Integer) As String
        Dim XMLStr As String = ""
        Dim objReader As DBReader = Nothing
        Dim SQLStr As String
        Try
            If gridID < 0 Then gridID = 0
            'SQLStr = "SELECT u.* FROM UserEnabledColumns u INNER JOIN ColumnDisplayName c ON u.ColumnDisplayName_ID = c.Column_Ordinal WHERE u.User_ID = '0" & userID & "' and ISNULL(c.Workflow_ID, 1) = " & gridID.ToString() & " ORDER BY u.ColumnDisplayName_ID, u.[ID]"
            SQLStr = "SELECT u.* FROM UserEnabledColumns u INNER JOIN ColumnDisplayName c ON u.ColumnDisplayName_ID = c.ID WHERE u.User_ID = '0" & userID & "' and ISNULL(c.Workflow_ID, 1) = " & gridID.ToString() & " ORDER BY u.ColumnDisplayName_ID, u.[ID]"

            objReader = DataUtilities.GetDBReader(SQLStr)
            If objReader.HasRows Then
                Do While objReader.Read()
                    XMLStr += "<EnabledColumn ColumnID=""" & objReader("ColumnDisplayName_ID") & """ />"
                Loop
            End If
        Catch sqlex As SqlException
            Logger.LogError(sqlex)
        Catch ex As Exception
            Logger.LogError(ex)
        Finally
            If Not objReader Is Nothing Then
                objReader.Close()
                objReader.Dispose()
                objReader = Nothing
            End If
        End Try

        If XMLStr = "" Then
            XMLStr = "<UserEnabledColumns />"
        Else
            XMLStr = "<UserEnabledColumns>" & XMLStr & "</UserEnabledColumns>"
        End If

        Return XMLStr
    End Function

    Public Shared Function LoadUserEnabledColumns(ByVal userEnabledColumns As String) As String
        Dim XMLStr As String = ""
        Dim arr As String() = userEnabledColumns.Split(",")
        If userEnabledColumns.Trim() <> "" Then
            For i As Integer = LBound(arr) To UBound(arr)
                XMLStr += "<EnabledColumn ColumnID=""" & arr(i).Trim() & """ />"
            Next
        End If

        If XMLStr = "" Then
            XMLStr = "<UserEnabledColumns />"
        Else
            XMLStr = "<UserEnabledColumns>" & XMLStr & "</UserEnabledColumns>"
        End If

        Return XMLStr
    End Function

End Class
