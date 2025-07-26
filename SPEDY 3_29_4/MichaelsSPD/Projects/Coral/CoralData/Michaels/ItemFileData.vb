Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels

    Public Class ItemFileData

        Public Function GetFileID(ByVal itemtype As String, ByVal itemID As Long, ByVal fileType As ItemFileType) As Long

            Dim sql As String = "select [File_ID] from [SPD_Items_Files] where Item_Type = @Item_Type and Item_ID = @Item_ID and File_Type = @File_Type"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim bRead As Boolean
            Dim File_ID As Long = Long.MinValue

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@Item_Type", SqlDbType.VarChar, 1).Value = itemtype
                cmd.Parameters.Add("@Item_ID", SqlDbType.BigInt).Value = itemID
                cmd.Parameters.Add("@File_Type", SqlDbType.VarChar, 10).Value = ItemFileTypeHelper.GetFileTypeString(fileType)
                reader.CommandText = sql

                reader.Open()
                bRead = reader.Read()
                If bRead Then
                    File_ID = DataHelper.SmartValues(reader.Item("File_ID"), "long", False)
                End If

            Catch sqlex As SqlException
                Logger.LogError(sqlex)
                Throw sqlex
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                cmd = Nothing
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return File_ID

        End Function

        Public Function AddRecord(ByVal itemType As String, ByVal itemID As Long, ByVal fileID As Long, ByVal fileType As ItemFileType, ByVal userID As Integer, Optional ByVal isDirty As Boolean = True) As Long
            Dim sql As String = "sp_SPD_Items_Files_SaveRecord"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Dim recordID As Long = 0
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Direction = ParameterDirection.InputOutput
                objParam.Value = 0
                cmd.Parameters.Add(objParam)
                cmd.Parameters.Add("@Item_Type", SqlDbType.VarChar, 1).Value = itemType
                cmd.Parameters.Add("@Item_ID", SqlDbType.BigInt).Value = itemID
                cmd.Parameters.Add("@File_ID", SqlDbType.BigInt).Value = fileID
                cmd.Parameters.Add("@File_Type", SqlDbType.VarChar, 10).Value = ItemFileTypeHelper.GetFileTypeString(fileType)
                cmd.Parameters.Add("@userID", SqlDbType.Int).Value = userID
                cmd.Parameters.Add("@IsDirty", SqlDbType.Bit).Value = isDirty

                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
                recordID = cmd.Parameters("@ID").Value
            Catch ex As Exception
                Logger.LogError(ex)
                recordID = 0
                'Throw ex
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

        Public Function DeleteRecord(ByVal itemType As String, ByVal itemID As Long, ByVal fileID As Long) As Boolean
            Dim sql As String = "sp_SPD_Items_Files_DeleteRecord"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim retValue As Boolean = False
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@Item_Type", SqlDbType.VarChar, 1).Value = itemType
                cmd.Parameters.Add("@Item_ID", SqlDbType.BigInt).Value = itemID
                cmd.Parameters.Add("@File_ID", SqlDbType.BigInt).Value = fileID

                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
                retValue = True
            Catch ex As Exception
                Logger.LogError(ex)
                retValue = False
                'Throw ex
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
            Return retValue
        End Function

        Public Function DeleteRecord(ByVal fileID As Long) As Boolean
            Dim sql As String = "sp_SPD_Items_Files_DeleteRecord_By_File_ID"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim retValue As Boolean = False
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@File_ID", SqlDbType.BigInt).Value = fileID

                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
                retValue = True
            Catch ex As Exception
                Logger.LogError(ex)
                retValue = False
                'Throw ex
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
            Return retValue
        End Function

    End Class

End Namespace


