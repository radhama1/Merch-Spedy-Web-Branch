Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels

    Public Class FileData

        Public Shared Function GetFileRecord(ByVal id As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.FileRecord
            Dim objRecord As FileRecord = New FileRecord()
            Dim sql As String = "sp_SPD_File_GetRecord"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Value = id
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        objRecord.ID = DataHelper.SmartValues(.Item("ID"), "long", True)

                        objRecord.File_Name = DataHelper.SmartValues(.Item("File_Name"), "string", True)
                        objRecord.File_Type = DataHelper.SmartValues(.Item("File_Type"), "string", True)
                        objRecord.File_Data = .Item("File_Data")
                        objRecord.File_Size = DataHelper.SmartValues(.Item("File_Size"), "long", True)
                        objRecord.Image_Width_Pixels = DataHelper.SmartValues(.Item("Image_Width_Pixels"), "integer", True)
                        objRecord.Image_Height_Pixels = DataHelper.SmartValues(.Item("Image_Height_Pixels"), "integer", True)
                        If Not IsDBNull(.Item("Image_Thumbnail")) Then objRecord.Image_Thumbnail = .Item("Image_Thumbnail")

                        NovaLibra.Coral.SystemFrameworks.Michaels.FriendDataHelper.SetFileData(objRecord, _
                            DataHelper.SmartValues(.Item("Date_Created"), "date", True), _
                            DataHelper.SmartValues(.Item("Created_User_ID"), "integer", True), _
                            DataHelper.SmartValues(.Item("Created_User_Name"), "string", True))

                    End With
                Else
                    objRecord.ID = 0
                End If

                reader.Close()
            Catch ex As Exception
                Logger.LogError(ex)
                objRecord.ID = -1
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

        Public Shared Function SaveFileRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.FileRecord, ByVal userID As Integer) As Long
            Dim sql As String = "sp_SPD_File_SaveRecord"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Dim recordID As Long = 0
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Direction = ParameterDirection.InputOutput
                objParam.Value = objRecord.ID
                cmd.Parameters.Add(objParam)
                cmd.Parameters.Add("@File_Name", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.File_Name, "string", True)
                cmd.Parameters.Add("@File_Type", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.File_Type, "string", True)
                cmd.Parameters.Add("@File_Data", SqlDbType.Image).Value = objRecord.File_Data
                cmd.Parameters.Add("@File_Size", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(objRecord.File_Size, "long", True)
                cmd.Parameters.Add("@Image_Width_Pixels", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.Image_Width_Pixels, "integer", True)
                cmd.Parameters.Add("@Image_Height_Pixels", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.Image_Height_Pixels, "integer", True)
                cmd.Parameters.Add("@Image_Thumbnail", SqlDbType.Image).Value = objRecord.Image_Thumbnail

                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = DataHelper.DBSmartValues(userID, "integer", True)

                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
                recordID = cmd.Parameters("@ID").Value
            Catch ex As Exception
                Logger.LogError(ex)
                objRecord.ID = -1
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

        Public Shared Function DeleteFileRecord(ByVal id As Long) As Boolean
            Dim sql As String = "sp_SPD_File_DeleteRecord"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Dim bSuccess As Boolean = True
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Value = id
                cmd.Parameters.Add(objParam)
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
            Catch ex As Exception
                Logger.LogError(ex)

                bSuccess = False
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
            Return bSuccess
        End Function

    End Class

End Namespace


