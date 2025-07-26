
Imports System.Data
Imports System.Data.SqlClient
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports NovaLibra.Common.Utilities
Imports System.Collections.Generic
Imports WebConstants


Partial Class TestVendorLogin
    Inherits System.Web.UI.Page

    Public ReadOnly Property VersionNo() As String
        Get
            Return WebConstants.APP_VERSION
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub


    Protected Sub btnlogin_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnlogin.Click
        Dim vendorNum As String
        vendorNum = vendorID.Text.Trim

        If vendorNum.Length = 0 OrElse Not IsNumeric(vendorNum) Then
            lblMessage.Text = "Invalid Vendor Number"
            Exit Sub
        End If

        If AuthCode.Text <> "!H0wdyd00dy$" Then
            lblMessage.Text = "Invalid Authentication Code"
            AuthCode.Text = ""
            Exit Sub
        End If

        Dim connection As SqlConnection = New SqlConnection
        Dim Command As SqlCommand = New SqlCommand
        Dim param As SqlParameter
        Dim connectString As String
        Dim reader As SqlDataReader
        Dim ok As Boolean = False
        Dim username As String
        connectString = ConfigurationManager.ConnectionStrings.Item("AppConnection").ConnectionString

        connection.ConnectionString = connectString

        Try
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure
            Command.CommandText = "usp_SPD_UTIL_TestVendorLogin"
            param = Nothing
            param = Command.CreateParameter()
            param.Direction = ParameterDirection.Input
            param.ParameterName = "vendorID"
            param.DbType = DbType.String
            param.Value = vendorNum
            Command.Parameters.Add(param)

            Command.Connection.Open()
            reader = Command.ExecuteReader
            If reader.HasRows Then
                reader.Read()
                Session("UserID") = DataHelper.SmartValues(reader.Item("ID"), "long", False)
                Session("Email_Address") = reader.Item("Email_Address")
                username = reader.Item("UserName")

                Session("UserName") = Left(username, InStrRev(username, "_") - 1)
                Session("vendorId") = Right(username, Len(username) - InStrRev(username, "_"))
                Session("Last_name") = reader.Item("Last_name")
                Session("First_Name") = reader.Item("First_Name")
                Session("Organization") = reader.Item("Organization")
                ok = True
            Else
                lblMessage.Text = "Vendor Record not Found"
            End If
            reader.Close()
            Command.Connection.Close()
        Catch ex As Exception
            lblMessage.Text = "SQL Error occurred. " & ex.Message
            If Command.Connection.State = ConnectionState.Open Then Command.Connection.Close()
        Finally
            Command.Dispose()
            connection.Dispose()
            Command = Nothing
            connection = Nothing
            reader = Nothing
        End Try

        If ok Then
            Response.Redirect("default.aspx")
        End If

    End Sub
End Class
