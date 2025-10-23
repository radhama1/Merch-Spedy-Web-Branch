Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels

    Public Class FreightTermsData

		Public Shared Function GetIDByName(ByVal name As String) As Integer
			Dim id As New Integer

			Dim sql As String = "PO_Freight_Terms_Get_By_Name"
			Dim reader As DBReader = Nothing
			Dim conn As DBConnection = Nothing

			Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
				reader = New DBReader(conn)
				reader.Command.Parameters.Add("@Name", SqlDbType.VarChar).Value = name
				reader.CommandText = sql
				reader.CommandType = CommandType.StoredProcedure
				reader.Open()
				If reader.Read() Then
					With reader
						id = .Item("ID")
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

			Return id

		End Function

	End Class

End Namespace