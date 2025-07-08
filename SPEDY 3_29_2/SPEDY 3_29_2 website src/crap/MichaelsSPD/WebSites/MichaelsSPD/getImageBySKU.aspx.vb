Imports System.Data.SqlClient

Partial Class getImageBySKU
    Inherits System.Web.UI.Page

    Private _SKU As String = ""
    Public Property SKU() As Long
        Get
            Return _SKU
        End Get
        Set(ByVal value As Long)
            _SKU = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If IsNumeric(Request.QueryString("SKU")) Then

            SKU = Trim(Request.QueryString("SKU"))

            If Len(SKU) = 8 Then
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

        Dim sqlCon As SqlConnection = New SqlConnection(ConfigurationManager.ConnectionStrings("ProdHackConnection").ConnectionString)

        Dim sqlCom As SqlCommand = Nothing

        Try

            sqlCon.Open()

            sqlCom = New SqlCommand("Select top 1 File_Type, File_Data From SPD_Files f, SPD_Item_Master_Vendor v Where v.Michaels_SKU = '" & Replace(SKU, "'", "''") & "' and v.Image_ID = f.ID order by v.Primary_Indicator desc", sqlCon)

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
