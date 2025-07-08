Imports System
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports System.Collections.Specialized
Imports System.Data.SqlClient

Namespace Michaels
	Public Class POLocationData

		Public Shared Function GetLocationConstantByID(ByVal locationID As Integer) As String

			Dim locationConstant As String = String.Empty

			Dim sql As String = "PO_Location_Get_By_ID"
			Dim reader As DBReader = Nothing
			Dim conn As DBConnection = Nothing

			Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.Int).Value = locationID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        locationConstant = DataHelper.SmartValuesDBNull(.Item("Constant"), False)
                    End With
                End If

            Catch ex As Exception
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

            Return locationConstant
        End Function

        Public Shared Function GetLocationIDByConstant(ByVal constant As String) As Integer

            Dim poLocationID As Integer = 0
            Dim sql As String = "PO_Location_Get_By_Constant"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@Constant", SqlDbType.VarChar).Value = constant
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                Do While reader.Read()
                    With reader
                        poLocationID = DataHelper.SmartValuesDBNull(reader.Item("ID"))
                    End With
                Loop

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

            Return poLocationID
        End Function

        Public Shared Function GetLocationIDByName(ByVal locationName As String) As Integer
            Dim poLocationID As Integer = 0
            Dim sql As String = "PO_Location_Get_By_Name"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@Name", SqlDbType.VarChar).Value = locationName
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()

                Do While reader.Read()
                    With reader
                        poLocationID = DataHelper.SmartValuesDBNull(reader.Item("ID"))
                    End With
                Loop

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

            Return poLocationID
        End Function

        Public Shared Function GetLocationNameByID(ByVal locationID As Integer) As String
            Dim locationName As String = String.Empty

            Dim sql As String = "PO_Location_Get_By_ID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.Int).Value = locationID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        locationName = DataHelper.SmartValuesDBNull(.Item("Name"), False)
                    End With
                End If

            Catch ex As Exception
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

            Return locationName
        End Function

	End Class
End Namespace

