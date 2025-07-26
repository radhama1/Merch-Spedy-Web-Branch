Imports System
Imports System.Web
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports System.Collections.Specialized
Imports System.Data.SqlClient

Namespace Michaels


    Public Class ColumDisplayNameData
        Public Shared Function GeColumnDisplayNameByWorkflowID(ByVal workflowID As Integer) As List(Of ColumnDisplayName)
            Dim columnDisplayNames As New List(Of ColumnDisplayName)

            Dim sql As String = "ColumnDisplayName_Get_By_WorkflowID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@WorkflowID", SqlDbType.Int).Value = workflowID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                While reader.Read()
                    With reader
                        Dim cdn As New ColumnDisplayName
                        cdn.ID = DataHelper.SmartValues(.Item("ID"), "CInt", True)
                        cdn.ColumnType = DataHelper.SmartValues(.Item("Column_Type"), "CStr", False)
                        cdn.ColumnName = DataHelper.SmartValues(.Item("Column_Name"), "CStr", False)
                        cdn.ColumnOrdinal = DataHelper.SmartValues(.Item("Column_Ordinal"), "CStr", False)
                        cdn.ColumnGenericType = DataHelper.SmartValues(.Item("Column_Generic_Type"), "CStr", False)
                        cdn.ColumnFormat = DataHelper.SmartValues(.Item("Column_Format"), "CStr", False)
                        cdn.ColumnFormatString = DataHelper.SmartValues(.Item("Column_Format_String"), "CStr", False)
                        cdn.FixedColumn = DataHelper.SmartValues(.Item("Fixed_Column"), "Boolean", False)
                        cdn.AllowSort = DataHelper.SmartValues(.Item("Allow_Sort"), "Boolean", False)
                        cdn.AllowFilter = DataHelper.SmartValues(.Item("Allow_Filter"), "Boolean", False)
                        cdn.AllowUserDisable = DataHelper.SmartValues(.Item("Allow_UserDisable"), "Boolean", False)
                        cdn.AllowAdmin = DataHelper.SmartValues(.Item("Allow_Admin"), "Boolean", False)
                        cdn.AllowAjaxEdit = DataHelper.SmartValues(.Item("Allow_AjaxEdit"), "Boolean", False)
                        cdn.IsCustom = DataHelper.SmartValues(.Item("Is_Custom"), "Boolean", False)
                        cdn.DefaultUserDisplay = DataHelper.SmartValues(.Item("Default_UserDisplay"), "Boolean", False)
                        cdn.Display = DataHelper.SmartValues(.Item("Display"), "Boolean", False)
                        cdn.DisplayName = DataHelper.SmartValues(.Item("Display_Name"), "CStr", False)
                        cdn.DisplayWidth = DataHelper.SmartValues(.Item("Display_Width"), "CInt", False)
                        cdn.MaxLength = DataHelper.SmartValues(.Item("Max_Length"), "CInt", False)
                        cdn.SecurityPrivelegeConstantSuffix = DataHelper.SmartValues(.Item("Security_Privilege_Constant_Suffix"), "CStr", False)
                        cdn.DateCreated = DataHelper.SmartValues(.Item("Date_Created"), "CDate", False)
                        cdn.DateLastModified = DataHelper.SmartValues(.Item("Date_Last_Modified"), "CDate", False)
                        cdn.WorkflowID = DataHelper.SmartValues(.Item("Workflow_ID"), "CInt", False)

                        columnDisplayNames.Add(cdn)
                    End With
                End While

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return columnDisplayNames
        End Function
    End Class
End Namespace