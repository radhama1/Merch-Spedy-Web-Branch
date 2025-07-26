Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels

    Public Class FieldAuditingData

        Public Function SaveAuditRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecord, ByRef conn As DBConnection) As Boolean
            'Dim sql As String = "sp_SPD_Audit_SaveRecord"
            Dim cmd As DBCommand = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            'Dim conn As DBConnection = Nothing
            Dim recordID As Long = 0
            Dim ret As Boolean = False
            Try
                cmd = New DBCommand(conn)
                cmd.CommandType = CommandType.StoredProcedure

                ' [SPD_Audit]
                cmd.CommandText = "sp_SPD_Audit_SaveRecord"
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Direction = ParameterDirection.InputOutput
                objParam.Value = 0
                cmd.Parameters.Add(objParam)
                cmd.Parameters.Add("@Table_ID", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.AuditTableID, "integer", False)
                cmd.Parameters.Add("@Record_ID", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(objRecord.AuditRecordID, "long", False)
                cmd.Parameters.Add("@Audit_Type_ID", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.AuditType, "integer", False)
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.UserID, "integer", False)
                cmd.ExecuteNonQuery()
                recordID = cmd.Parameters("@ID").Value

                ' [SPD_Audit_Field]
                If Not objRecord.AuditFields Is Nothing Then
                    cmd.CommandText = "sp_SPD_Audit_Field_SaveRecord"
                    cmd.Parameters.Clear()
                    cmd.Parameters.Add("@Audit_ID", SqlDbType.BigInt).Value = recordID
                    cmd.Parameters.Add("@Table_ID", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.AuditTableID, "integer", False)
                    cmd.Parameters.Add("@Field_Name", SqlDbType.VarChar, 200)
                    cmd.Parameters.Add("@Field_Value", SqlDbType.VarChar, -1)
                    For Each fld As NovaLibra.Coral.SystemFrameworks.Michaels.AuditField In objRecord.AuditFields
                        cmd.Parameters("@Field_Name").Value = fld.FieldName
                        cmd.Parameters("@Field_Value").Value = fld.FieldValue
                        cmd.ExecuteNonQuery()
                    Next
                End If

            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
                Throw ex
            Finally
                If Not cmd Is Nothing Then
                    cmd.Connection = Nothing
                    cmd.Dispose()
                    cmd = Nothing
                End If
            End Try
            Return ret

        End Function

        Public Function SaveAuditRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecord) As Boolean
            Dim conn As DBConnection = Nothing
            Dim ret As Boolean = False
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                ret = SaveAuditRecord(objRecord, conn)
            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
                Throw ex
            Finally
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return ret

        End Function

        Public Function SaveExcelAuditLog(ByRef AuditRec As ExcelAuditLog) As Integer
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim recordID As Long = 0
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.CommandText = "usp_SPD_Excel_SaveAuditRec"
                Dim RecID As New SqlParameter("@ID", SqlDbType.BigInt)
                RecID.Direction = ParameterDirection.ReturnValue
                cmd.Parameters.Add(RecID)

                cmd.Parameters.Add("@Batch_ID", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(AuditRec.BatchID, "long", False)
                cmd.Parameters.Add("@SKU", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(AuditRec.MichaelsSKU, "string", False)
                cmd.Parameters.Add("@VendorNumber", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(AuditRec.VendorNumber, "long", False)
                cmd.Parameters.Add("@Direction", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(AuditRec.Direction, "string", False)
                cmd.Parameters.Add("@Message", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(AuditRec.Message, "string", False)
                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = DataHelper.DBSmartValues(AuditRec.CreatedUserID, "long", False)
                cmd.Parameters.Add("@XLFileName", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(AuditRec.XLFileName, "string", False)
                cmd.ExecuteNonQuery()
                conn.Close()

                'now get the number of rows returned.  Need to do this after connection is closed (don't ask me why)
                Try
                    recordID = CType(RecID.Value, Integer)
                Catch
                    recordID = -2
                End Try

            Catch ex As Exception
                Logger.LogError(ex)
                recordID = -1
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
            Return recordID
        End Function

    End Class

End Namespace

