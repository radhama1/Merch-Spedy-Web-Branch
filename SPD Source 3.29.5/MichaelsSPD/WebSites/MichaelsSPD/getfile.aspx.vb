Imports NovaLibra.Common.Utilities.DataHelper
Imports System.Data.SqlClient

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities

Partial Class getfile
    Inherits System.Web.UI.Page

    Private FileID As Long = 0
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Not Session("UserID") Is Nothing AndAlso IsNumeric(Session("UserID")) AndAlso Session("UserID") > 0 Then

            FileID = SmartValues(Request.QueryString("id"), "Long", True)

            If FileID > 0 Then
                WriteFile()
            End If

        End If

    End Sub

    Private Sub WriteFile()

        Dim reader As SqlDataReader = Nothing
        Dim sqlCon As SqlConnection = New SqlConnection(ConfigurationManager.ConnectionStrings("AppConnection").ConnectionString)
        Dim sqlCom As SqlCommand = Nothing
        Dim fileName As String = String.Empty
        
        Try

            sqlCon.Open()

            sqlCom = New SqlCommand("Select File_Name, File_Type, File_Data From SPD_Files Where ID = " & FileID, sqlCon)

            reader = sqlCom.ExecuteReader()
            reader.Read()

            Dim byteArray As Byte() = reader("File_Data")
            If Request("filename") <> String.Empty Then
                fileName = Request("filename")
            Else
                fileName = DataHelper.SmartValues(reader("File_Name"), "string", True)
            End If
            If Request("ad") <> String.Empty AndAlso Request("ad") = "1" Then
                Response.AddHeader("content-disposition", ("attachment;filename=" & fileName))
            End If

            Response.Clear()
            Response.ContentType = "Image/JPEG"
            Response.BinaryWrite(byteArray)

        Catch ex As Exception
        Finally
            If Not reader Is Nothing Then
                reader.Close()
                reader = Nothing
            End If

            If Not sqlCom Is Nothing Then
                sqlCom.Dispose()
                sqlCom = Nothing
            End If
            If Not sqlCon Is Nothing Then
                sqlCon.Close()
                sqlCon.Dispose()
                sqlCon = Nothing
            End If

        End Try


    End Sub

End Class
