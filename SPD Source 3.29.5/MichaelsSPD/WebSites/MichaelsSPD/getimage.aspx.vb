Imports NovaLibra.Common.Utilities.DataHelper
Imports System.Data.SqlClient

Partial Class getimage
    Inherits System.Web.UI.Page

    Private _fileID As Long = 0
    Public Property FileID() As Long
        Get
            Return _fileID
        End Get
        Set(ByVal value As Long)
            _fileID = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Not Session("UserID") Is Nothing AndAlso IsNumeric(Session("UserID")) AndAlso Session("UserID") > 0 Then

            FileID = SmartValues(Request.QueryString("id"), "Long", True)

            If FileID > 0 Then
                WriteFile()
            Else
                Response.Redirect("/images/spacer.gif")
            End If

        Else
            Response.Redirect("/images/spacer.gif")
        End If

    End Sub

    Private Sub WriteFile()

        Dim reader As SqlDataReader = Nothing

        Dim sqlCon As SqlConnection = New SqlConnection(ConfigurationManager.ConnectionStrings("AppConnection").ConnectionString)

        Dim sqlCom As SqlCommand = Nothing

        Try

            sqlCon.Open()

            sqlCom = New SqlCommand("Select File_Type, File_Data From SPD_Files Where ID = " & FileID, sqlCon)

            reader = sqlCom.ExecuteReader()
            reader.Read()

            Dim byteArray As Byte() = reader("File_Data")

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
