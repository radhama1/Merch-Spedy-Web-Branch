Imports System
Imports System.Data
Imports System.Data.SqlClient

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.Data.Utilities
Imports NovaLibra.Coral.BusinessFacade

Partial Class ztest
    Inherits System.Web.UI.Page


    Public Function GetHTML() As String
        Dim s As String = String.Empty
        Dim cname As String, dt As String, dname As String
        Dim cnt As Integer = 0
        Dim reader1 As DBReader, reader2 As DBReader
        Try
            reader1 = New DBReader(ApplicationHelper.GetAppConnection(), "select * from SPD_Items", CommandType.Text)
            reader1.Open()
            Dim schemaTable As DataTable = reader1.Reader.GetSchemaTable()
            Dim row As DataRow
            'Dim column As DataColumn

            For Each row In schemaTable.Rows
                'For Each column In schemaTable.Columns
                '    s += column.ColumnName & " = " & row(column).ToString() & vbCrLf
                'Next
                cname = row("ColumnName")
                dt = row("DataTypeName")
                Select Case dt.ToLower()
                    Case "varchar"
                        dt = "string"
                    Case "bigint"
                        dt = "long"
                    Case "money"
                        dt = "decimal"
                    Case "int"
                        dt = "integer"
                    Case "datetime"
                        dt = "date"
                    Case Else
                        dt = dt.ToLower()
                End Select
                If (cname <> "ID" And cname <> "Item_Header_ID" And cname <> "") Then
                    cnt += 1
                    reader2 = New DBReader(ApplicationHelper.GetAppConnection(), "select Column_Name, Display_Name from ColumnDisplayName where Column_Name = '" & cname & "'", CommandType.Text)
                    reader2.Open()
                    If reader2.Read() Then
                        dname = reader2("Display_Name")
                    Else
                        dname = cname
                    End If
                    reader2.Close()
                    reader2.Dispose()
                    reader2 = Nothing
                    s += "INSERT INTO [dbo].[ColumnDisplayName]([ID],[Column_Type],[Column_Name],[Column_Ordinal],[Column_Generic_Type],[Column_Format],[Fixed_Column],[Allow_Sort],[Allow_Filter],[Allow_UserDisable],[Allow_Admin],[Allow_AjaxEdit],[Is_Custom],[Default_UserDisplay],[Display],[Display_Name],[Display_Width],[Security_Privilege_Constant_Suffix])" & vbCrLf & _
                        "VALUES(" & cnt & ",'D','" & cname & "'," & cnt & ",'" & dt & "','" & dt & "',0,1,1,1,1,1,1,1,1,'" & dname & "',0,NULL)" & vbCrLf & _
                        vbCrLf
                End If
            Next

            reader1.Dispose()
            reader1 = Nothing
        Catch ex As Exception

        End Try

        Return s
    End Function
End Class
