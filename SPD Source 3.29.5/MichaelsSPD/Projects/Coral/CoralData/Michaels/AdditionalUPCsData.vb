
Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels

    Public Class AdditionalUPCsData
        ' FJL May 2010  -- Moved to separate class to handle both Domestic and Import items

        ' ******************
        ' * ADDITIONAL UPC *
        ' ******************
        Public Shared Function GetItemAdditionalUPCs(ByVal itemHeaderID As Long, ByVal itemID As Long) As ItemAdditionalUPCRecord

            Dim objRecord As New ItemAdditionalUPCRecord(itemHeaderID, itemID)

            Dim sql As String = "sp_SPD_Item_Additional_UPC_GetList"
            Dim reader As SqlDataReader = Nothing
            Dim cmd As SqlCommand = Nothing
            Dim conn As SqlConnection = Nothing
            Dim additionalUPC As String = String.Empty
            Try

                conn = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("AppConnection").ConnectionString)
                cmd = New SqlCommand()
                cmd.Connection = conn
                cmd.Parameters.Add("@itemHeaderID", SqlDbType.BigInt).Value = itemHeaderID
                cmd.Parameters.Add("@itemID", SqlDbType.BigInt).Value = itemID
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.CommandTimeout = 600
                cmd.Connection.Open()
                reader = cmd.ExecuteReader()

                Do While reader.Read()
                    With reader
                        additionalUPC = DataHelper.SmartValues(.Item("Additional_UPC"), "string", True)
                    End With
                    objRecord.AddAdditionalUPC(additionalUPC)
                Loop

                reader.Close()
            Catch sqlex As SqlException
                Logger.LogError(sqlex)
                Throw sqlex
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Close()
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Close()
                    conn.Dispose()
                    conn = Nothing
                Else
                    conn = Nothing
                End If
                If Not cmd Is Nothing Then
                    cmd.Dispose()
                    cmd = Nothing
                End If
            End Try
            Return objRecord
        End Function

        Public Shared Function SaveItemAdditionalUPCs(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemAdditionalUPCRecord, ByVal userID As Integer) As Boolean
            Return SaveItemAdditionalUPCs(objRecord, userID, Nothing)
        End Function

        Public Shared Function SaveItemAdditionalUPCs(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemAdditionalUPCRecord, ByVal userID As Integer, ByRef dbconn As DBConnection) As Boolean
            Dim sql As String = "sp_SPD_Item_Additional_UPC_SaveRecord"
            Dim cmd As DBCommand = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Dim connCreated As Boolean = False
            Dim conn As DBConnection = Nothing
            'Dim recordID As Long = 0
            Dim bSuccess As Boolean = True
            Try
                If Not dbconn Is Nothing Then
                    conn = dbconn
                Else
                    conn = Utilities.ApplicationHelper.GetAppConnection()
                    conn.Open()
                    connCreated = True
                End If

                cmd = New DBCommand(conn)
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Direction = ParameterDirection.InputOutput

                For i As Integer = 0 To objRecord.AdditionalUPCs.Count - 1
                    cmd.Parameters.Clear()
                    objParam.Value = 0
                    cmd.Parameters.Add(objParam)
                    cmd.Parameters.Add("@Item_Header_ID", SqlDbType.BigInt).Value = objRecord.ItemHeaderID
                    cmd.Parameters.Add("@Item_ID", SqlDbType.BigInt).Value = objRecord.ItemID
                    cmd.Parameters.Add("@Sequence", SqlDbType.Int).Value = (i + 1)
                    cmd.Parameters.Add("@Additional_UPC", SqlDbType.VarChar, 20).Value = objRecord.AdditionalUPCs.Item(i)
                    cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = userID
                    cmd.ExecuteNonQuery()
                    'recordID = cmd.Parameters("@ID").Value
                Next

                DeleteItemAdditionalUPCFromSequence(objRecord.ItemHeaderID, objRecord.ItemID, objRecord.AdditionalUPCs.Count + 1, conn)

            Catch ex As Exception
                Logger.LogError(ex)
                bSuccess = False
                Throw ex
            Finally
                If Not cmd Is Nothing Then
                    cmd.Dispose()
                    cmd = Nothing
                End If
                If Not conn Is Nothing AndAlso connCreated Then
                    conn.Dispose()
                    conn = Nothing
                Else
                    conn = Nothing
                End If
            End Try
            Return bSuccess
        End Function

        Public Shared Function DeleteItemAdditionalUPCFromSequence(ByVal itemHeaderID As Long, ByVal itemID As Long, ByVal startingSequence As Integer) As Boolean
            Return DeleteItemAdditionalUPCFromSequence(itemHeaderID, itemID, startingSequence, Nothing)
        End Function

        Public Shared Function DeleteItemAdditionalUPCFromSequence(ByVal itemHeaderID As Long, ByVal itemID As Long, ByVal startingSequence As Integer, ByRef dbconn As DBConnection) As Boolean
            Dim sql As String = "sp_SPD_Item_Additional_UPC_DeleteFromSequence"
            Dim cmd As DBCommand = Nothing
            Dim connCreated As Boolean = False
            Dim conn As DBConnection = Nothing
            Dim bSuccess As Boolean = True
            Try
                If Not dbconn Is Nothing Then
                    conn = dbconn
                Else
                    conn = Utilities.ApplicationHelper.GetAppConnection()
                    conn.Open()
                    connCreated = True
                End If

                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@Item_Header_ID", SqlDbType.BigInt).Value = itemHeaderID
                cmd.Parameters.Add("@Item_ID", SqlDbType.BigInt).Value = itemID
                cmd.Parameters.Add("@Starting_Sequence", SqlDbType.Int).Value = startingSequence
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
                If Not conn Is Nothing AndAlso connCreated Then
                    conn.Dispose()
                    conn = Nothing
                Else
                    conn = Nothing
                End If
            End Try
            Return bSuccess
        End Function

    End Class

End Namespace

