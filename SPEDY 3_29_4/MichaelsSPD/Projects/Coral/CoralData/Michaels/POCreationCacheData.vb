Imports System
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports System.Collections.Specialized
Imports System.Data.SqlClient

Namespace Michaels

    Public Class POCreationCacheData

        Public Shared Sub UpdateRecord(ByRef objRec As POCreationCacheRecord, Optional ByVal HydrateRecord As Hydrate = POCreationData.Hydrate.None)
            Try
                _UpdateRecord(objRec)

                If HydrateRecord = Hydrate.All Then
                    objRec = GetRecord(objRec.ActiveUserID, objRec.ID)
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            End Try

        End Sub

        Private Shared Sub _UpdateRecord(ByVal objRecord As POCreationCacheRecord)

            Dim sql As String = "PO_Creation_Cache_Update"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@Active_User_ID", SqlDbType.Int).Value = objRecord.ActiveUserID
                cmd.Parameters.Add("@ID", SqlDbType.BigInt).Value = objRecord.ID
                cmd.Parameters.Add("@Workflow_Department_ID", SqlDbType.Int).Value = objRecord.WorkflowDepartmentID
                cmd.Parameters.Add("@PO_Department_ID", SqlDbType.Int).Value = objRecord.PODepartmentID
                cmd.Parameters.Add("@PO_Class", SqlDbType.Int).Value = objRecord.POClass
                cmd.Parameters.Add("@PO_Subclass", SqlDbType.Int).Value = objRecord.POSubclass
                cmd.Parameters.Add("@Is_Detail_Valid", SqlDbType.Bit).Value = objRecord.IsDetailValid

                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not cmd Is Nothing Then
                    cmd.Dispose()
                    cmd = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

        End Sub

        Public Shared Sub UpdateAllocPlannerFlags(ByVal POCreationID As Long?, ByVal UserID As Integer)

            Dim sql As String = "PO_Creation_Cache_Update_Alloc_Planner_Flags"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = POCreationID
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = UserID
                cmd.CommandTimeout = 1800
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not cmd Is Nothing Then
                    cmd.Dispose()
                    cmd = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

        End Sub

        Public Shared Sub UpdateIsDateWarning(ByVal POCreationID As Long?, ByVal UserID As Integer, ByVal IsDateWarning As Boolean?)

            Dim sql As String = "PO_Creation_Cache_Update_Is_Date_Warning"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = POCreationID
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = UserID
                cmd.Parameters.Add("@Is_Date_Warning", SqlDbType.Bit).Value = IsDateWarning

                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not cmd Is Nothing Then
                    cmd.Dispose()
                    cmd = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

        End Sub

        Public Shared Sub UpdatePODepartmentID(ByVal POCreationID As Long?, ByVal UserID As Integer)

            Dim sql As String = "PO_Creation_Cache_Update_PO_Department_ID"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = POCreationID
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = UserID

                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not cmd Is Nothing Then
                    cmd.Dispose()
                    cmd = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

        End Sub

        Public Shared Sub UpdateWorkflowDepartmentID(ByVal POCreationID As Long?, ByVal UserID As Integer, ByVal WorkflowDepartmentID As Integer?)

            Dim sql As String = "PO_Creation_Cache_Update_Workflow_Department_ID"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = POCreationID
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = UserID
                cmd.Parameters.Add("@Workflow_Department_ID", SqlDbType.Int).Value = WorkflowDepartmentID

                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not cmd Is Nothing Then
                    cmd.Dispose()
                    cmd = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

        End Sub

        Public Shared Function GetRecord(ByVal ActiveUserID As Integer, ByVal POCreationID As Long) As POCreationCacheRecord

            Dim objRecord As New POCreationCacheRecord()
            Dim sql As String = "PO_Creation_Cache_Get_By_ID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@Active_User_ID", SqlDbType.Int).Value = ActiveUserID
                reader.Command.Parameters.Add("@ID", SqlDbType.BigInt).Value = POCreationID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then

                    With reader

                        objRecord.ActiveUserID = DataHelper.SmartValuesDBNull(.Item("Active_User_ID"))
                        objRecord.ID = DataHelper.SmartValuesDBNull(.Item("ID"))
                        objRecord.WorkflowDepartmentID = DataHelper.SmartValuesDBNull(.Item("Workflow_Department_ID"))
                        objRecord.PODepartmentID = DataHelper.SmartValuesDBNull(.Item("PO_Department_ID"))
                        objRecord.POClass = DataHelper.SmartValuesDBNull(.Item("PO_Class"))
                        objRecord.POSubclass = DataHelper.SmartValuesDBNull(.Item("PO_Subclass"))
                        objRecord.IsDetailValid = DataHelper.SmartValuesDBNull(.Item("Is_Detail_Valid"))

                    End With

                End If

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

            Return objRecord

        End Function

        Public Enum Hydrate As Short
            None = 0
            All = 1
        End Enum

        Public Shared Function GetPODepartmentName(ByVal ActiveUserID As Integer, ByVal POCreationID As Integer) As String

            Dim returnValue As String = ""

            Dim sql As String = "PO_Creation_Cache_Get_PO_Department_Name"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@PO_Creation_ID", SqlDbType.BigInt).Value = POCreationID
                reader.Command.Parameters.Add("@Active_User_ID", SqlDbType.Int).Value = ActiveUserID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then

                    With reader

                        returnValue = DataHelper.SmartValuesDBNull(.Item("Department_Name"))

                    End With

                End If

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

            Return returnValue

        End Function

    End Class
End Namespace