Imports System
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports System.Collections.Specialized
Imports System.Data.SqlClient

Namespace Michaels

    Public Class POMaintenanceCacheData

        Public Shared Function GetRecord(ByVal ActiveUserID As Integer, ByVal POMaintenanceID As Long) As POMaintenanceCacheRecord

            Dim objRecord As New POMaintenanceCacheRecord()
            Dim sql As String = "PO_Maintenance_Cache_Get_By_ID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.BigInt).Value = POMaintenanceID
                reader.Command.Parameters.Add("@User_ID", SqlDbType.Int).Value = ActiveUserID
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
                        objRecord.POLocationID = DataHelper.SmartValuesDBNull(.Item("PO_Location_ID"))
                        objRecord.ExternalReferenceID = DataHelper.SmartValuesDBNull(.Item("External_Reference_ID"))
                        objRecord.WrittenDate = DataHelper.SmartValuesDBNull(.Item("Written_Date"))
                        objRecord.NotBefore = DataHelper.SmartValuesDBNull(.Item("Not_Before"))
                        objRecord.NotAfter = DataHelper.SmartValuesDBNull(.Item("Not_After"))
                        objRecord.EstimatedInStockDate = DataHelper.SmartValuesDBNull(.Item("Estimated_In_Stock_Date"))

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

        Public Shared Function GetPODepartmentName(ByVal ActiveUserID As Integer, ByVal POMaintenanceID As Integer) As String

            Dim returnValue As String = ""

            Dim sql As String = "PO_Maintenance_Cache_Get_PO_Department_Name"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@Active_User_ID", SqlDbType.Int).Value = ActiveUserID
                reader.Command.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = POMaintenanceID
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

        Public Shared Function GetWorkflowDepartmentName(ByVal WorkflowDepartmentNumber As Integer?) As String

            Dim returnValue As String = ""

            Dim sql As String = "PO_Get_Work_Flow_Dept_By_ID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@Department_Number", SqlDbType.Int).Value = WorkflowDepartmentNumber
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

        Public Enum Hydrate As Short
            None = 0
            All = 1
        End Enum

        Public Shared Sub UpdateRecord(ByRef objRec As POMaintenanceCacheRecord, Optional ByVal HydrateRecord As Hydrate = POMaintenanceData.Hydrate.None)
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

        Private Shared Sub _UpdateRecord(ByVal objRecord As POMaintenanceCacheRecord)

            Dim sql As String = "PO_Maintenance_Cache_Update_All"
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
                cmd.Parameters.Add("@PO_Location_ID", SqlDbType.Int).Value = objRecord.POLocationID
                cmd.Parameters.Add("@External_Reference_ID", SqlDbType.VarChar).Value = objRecord.ExternalReferenceID
                cmd.Parameters.Add("@Written_Date", SqlDbType.DateTime).Value = objRecord.WrittenDate
                cmd.Parameters.Add("@Not_Before", SqlDbType.DateTime).Value = objRecord.NotBefore
                cmd.Parameters.Add("@Not_After", SqlDbType.DateTime).Value = objRecord.NotAfter
                cmd.Parameters.Add("@Estimated_In_Stock_Date", SqlDbType.DateTime).Value = objRecord.EstimatedInStockDate

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

        Public Shared Sub UpdateAllocPlannerFlags(ByVal POMaintenanceID As Integer, ByVal UserID As Integer)

            Dim sql As String = "PO_Maintenance_Cache_Update_Alloc_Planner_Flags"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = POMaintenanceID
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

        Public Shared Sub UpdateIsDateWarning(ByVal POMaintenanceID As Integer, ByVal UserID As Integer, ByVal IsDateWarning As Boolean?)

            Dim sql As String = "PO_Maintenance_Cache_Update_Is_Date_Warning"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = POMaintenanceID
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

        Public Shared Sub UpdatePODepartmentID(ByVal POMaintenanceID As Integer, ByVal UserID As Integer)

            Dim sql As String = "PO_Maintenance_Cache_Update_PO_Department_ID"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = POMaintenanceID
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

        Public Shared Sub UpdateWorkflowDepartmentID(ByVal POMaintenanceID As Integer, ByVal UserID As Integer, ByVal WorkflowDepartmentID As Integer?)

            Dim sql As String = "PO_Maintenance_Cache_Update_Workflow_Department_ID"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)

                cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = POMaintenanceID
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

        Public Shared Sub UpdateSKUCacheCancelledQtyBySKU(ByVal poMaintenanceID As Integer, ByVal sku As String, ByVal User_ID As Integer)

            Dim sql As String = "PO_Maintenance_SKU_Store_CACHE_Update_Cancelled_Qty_By_SKU"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = poMaintenanceID
                cmd.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = sku
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = User_ID
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

        Public Shared Sub UpdateSKUCacheRestoreCancelledQtyBySKU(ByVal poMaintenanceID As Integer, ByVal sku As String, ByVal User_ID As Integer)

            Dim sql As String = "PO_Maintenance_SKU_Store_CACHE_Restore_Cancelled_Qty_By_SKU"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@PO_Maintenance_ID", SqlDbType.BigInt).Value = poMaintenanceID
                cmd.Parameters.Add("@Michaels_SKU", SqlDbType.VarChar).Value = sku
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = User_ID
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

    End Class
End Namespace