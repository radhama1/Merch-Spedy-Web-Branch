Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic

Partial Class vendorconnect_login
    Inherits System.Web.UI.Page

    Private _connectionString As String
    Private _isEnabled As Boolean = False
    Private _userExists As Boolean = False

    Protected msg As String = ""

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Try

            Dim environment As String = ConfigurationManager.AppSettings("Environment")

            Dim secChkURL As String = "http://192.168.12.56/check_sessionguid.asp"  'USE DEV setting as default
            Select Case environment
                Case "DEV"
                    secChkURL = "http://192.168.12.56/check_sessionguid.asp"
                Case "BETA"
                    secChkURL = "http://192.168.12.56/check_sessionguid.asp"
                Case "PROD"
                    secChkURL = "https://www.vendorconnect.com/check_sessionguid.asp"
                Case "VENDOR"
                    secChkURL = "https://www.vendorconnect.com/check_sessionguid.asp"
            End Select


            Dim company As String = ""

            Dim vendorId As String = Request.Form("vendorId")
            If vendorId = "TEST01" Then
                vendorId = "61153"
                company = "LI & FUNG / 4KIDS CO. MFG LT"
            End If

            Dim userId As String = Request.Form("userId")
            If userId = "" Then
                userId = Request.Form("email")        '	"undefined"
            End If

            If InStr(vendorId, ",") Then
                vendorId = Left(vendorId, InStr(vendorId, ",") - 1)
            End If

            If msg = "" Then
                If userId <> "" And IsNumeric(vendorId) Then

                    company = GetVendorName(vendorId)

                    GetUserInfo(userId, vendorId, company)

                    If Not _userExists Then
                        CreateUser(userId, vendorId, company)
                    End If

                    If _isEnabled Then
                        Response.Redirect("default.aspx", False)
                    Else
                        msg = "This account is invalid or no longer active.  Please contact Support if you believe you received this message in error."
                    End If

                End If
            End If

        Catch ex As Exception
            msg = "Error: " + ex.Message
        End Try

        lblMsg.Text = msg
    End Sub

    Private Function GetVendorName(ByVal vendorID As String) As String

        Dim vendorName As String = "undefined"

        Dim connection As System.Data.SqlClient.SqlConnection = New System.Data.SqlClient.SqlConnection
        Dim Command As System.Data.SqlClient.SqlCommand = New System.Data.SqlClient.SqlCommand
        Dim reader As System.Data.SqlClient.SqlDataReader

        Try
            connection.ConnectionString = ConfigurationManager.ConnectionStrings("AppConnection").ConnectionString
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure
            Command.CommandText = "usp_SPD_VC_GetVendorInfo"

            Command.Parameters.Add("@VendorId", System.Data.SqlDbType.Int).Value = vendorID
            Command.Connection.Open()
            reader = Command.ExecuteReader

            While reader.Read
                vendorName = reader("vendor_name").ToString
            End While

            reader.Close()
        Catch ex As Exception
            Throw
        Finally
            If Not reader Is Nothing Then reader.Close()
            If Not Command.Connection Is Nothing Then Command.Connection.Close()
        End Try

        If Len(vendorName) = 0 Then
            vendorName = "undefined"
        End If

        Return vendorName
    End Function

    Private Sub GetUserInfo(ByVal userId As String, ByVal vendorId As String, ByVal company As String)

        Dim connection As System.Data.SqlClient.SqlConnection = New System.Data.SqlClient.SqlConnection
        Dim Command As System.Data.SqlClient.SqlCommand = New System.Data.SqlClient.SqlCommand
        Dim reader As System.Data.SqlClient.SqlDataReader

        Try
            connection.ConnectionString = ConfigurationManager.ConnectionStrings("AppConnection").ConnectionString
            Command.Connection = connection
            Command.CommandType = CommandType.StoredProcedure
            Command.CommandText = "usp_SPD_VC_GetUserInfo"

            Command.Parameters.Add("@UserName", System.Data.SqlDbType.VarChar).Value = userId & "_" & vendorId
            Command.Connection.Open()
            reader = Command.ExecuteReader

            While reader.Read
                If Len(reader("ID")) > 0 Then
                    _userExists = True
                    _isEnabled = CType(reader("Enabled"), Boolean)
                    Session("UserID") = CType(reader("ID"), Long)
                    Session("Email_Address") = reader("Email_Address")
                    Session("UserName") = Left(reader("UserName"), InStrRev(reader("UserName"), "_") - 1)
                    Session("vendorId") = Right(reader("UserName"), Len(reader("UserName")) - InStrRev(reader("UserName"), "_"))
                    Session("Last_name") = reader("Last_name")
                    Session("First_Name") = reader("First_Name")
                    Session("Organization") = reader("Organization")
                    Session("FromVendorConnect") = True
                End If

            End While

            reader.Close()
        Catch ex As Exception
            Throw
        Finally
            If Not reader Is Nothing Then reader.Close()
            If Not Command.Connection Is Nothing Then Command.Connection.Close()
        End Try

    End Sub

    Private Sub CreateUser(ByVal userId As String, ByVal vendorId As String, ByVal company As String)
        Dim connection As System.Data.SqlClient.SqlConnection = New System.Data.SqlClient.SqlConnection
        Dim Command As System.Data.SqlClient.SqlCommand = New System.Data.SqlClient.SqlCommand
        Dim reader As System.Data.SqlClient.SqlDataReader

        Try
            Dim email As String = Request.Form("email")
            If (Len(email) > 0) Then

                connection = New System.Data.SqlClient.SqlConnection
                Command = New System.Data.SqlClient.SqlCommand

                connection.ConnectionString = ConfigurationManager.ConnectionStrings("AppConnection").ConnectionString
                Command.Connection = connection
                Command.CommandType = CommandType.StoredProcedure
                Command.CommandText = "usp_SPD_VC_CreateUser"

                Command.Parameters.Add("@Email", System.Data.SqlDbType.VarChar).Value = IIf(Len(email) > 0, email, "")
                Command.Parameters.Add("@UserName", System.Data.SqlDbType.VarChar).Value = userId & "_" & vendorId
                Command.Parameters.Add("@LastName", System.Data.SqlDbType.VarChar).Value = IIf(Len(Request.Form("lastname")) > 0, Request.Form("lastname"), "")
                Command.Parameters.Add("@FirstName", System.Data.SqlDbType.VarChar).Value = IIf(Len(Request.Form("firstname")) > 0, Request.Form("firstname"), "")
                Command.Parameters.Add("@Org", System.Data.SqlDbType.VarChar).Value = company
                Command.Parameters.Add("@OffLoc", System.Data.SqlDbType.VarChar).Value = IIf(Len(Request.Form("phone")) > 0, Request.Form("phone"), "")

                Command.Connection.Open()
                reader = Command.ExecuteReader

                While reader.Read
                    _isEnabled = True
                    _userExists = True
                    Session("UserID") = CType(reader("ID"), Long)
                    Session("Email_Address") = reader("Email_Address")
                    Session("UserName") = Left(reader("UserName"), InStr(reader("UserName"), "_"))
                    Session("vendorId") = Right(reader("UserName"), Len(reader("UserName")) - InStrRev(reader("UserName"), "_"))
                    Session("Last_name") = reader("Last_name")
                    Session("First_Name") = reader("First_Name")
                    Session("Organization") = reader("Organization")
                End While

                reader.Close()
            End If
        Catch ex As Exception
            Throw
        Finally
            If Not reader Is Nothing Then reader.Close()
            If Not Command.Connection Is Nothing Then Command.Connection.Close()
        End Try


    End Sub

End Class
