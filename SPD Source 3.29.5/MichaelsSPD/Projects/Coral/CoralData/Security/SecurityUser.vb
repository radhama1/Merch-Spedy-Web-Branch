Imports System
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks
Imports System.Data.SqlClient

Namespace Security

    Public Class Security
        Public Function GetSecurityUserByUserName(ByVal username As String) As NovaLibra.Coral.SystemFrameworks.Security.UserLogin
            Dim objUserLogin As NovaLibra.Coral.SystemFrameworks.Security.UserLogin = New NovaLibra.Coral.SystemFrameworks.Security.UserLogin()
            Dim sql As String = "sp_security_authenticate_user_by_username '" & username & "'"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppSecurityConnection()
                conn.Open()
                reader = New DBReader(conn)
                reader.Open(sql, CommandType.Text)
                If reader.Read() Then
                    With reader
                        objUserLogin.ID = .Item("ID")
                        objUserLogin.GUID = DataHelper.SmartValues(.Item("GUID"), "GUID", True)
                        objUserLogin.Username = DataHelper.SmartValues(.Item("UserName"), "String", True)
                        objUserLogin.Password = DataHelper.SmartValues(.Item("Password"), "String", True)
                        objUserLogin.FirstName = DataHelper.SmartValues(.Item("First_Name"), "String", True)
                        objUserLogin.LastName = DataHelper.SmartValues(.Item("Last_Name"), "String", True)
                        objUserLogin.EmailAddress = DataHelper.SmartValues(.Item("Email_Address"), "String", True)
                        objUserLogin.Organization = DataHelper.SmartValues(.Item("Organization"), "String", True)
                        objUserLogin.JobTitle = DataHelper.SmartValues(.Item("Job_Title"), "String", True)
                        objUserLogin.Enabled = DataHelper.SmartValues(.Item("Enabled"), "Boolean")
                    End With
                Else
                    objUserLogin.ID = 0
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                objUserLogin.ID = -1
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
            Return objUserLogin
        End Function

        Public Shared Function GetSecurityUserByID(ByVal ID As Integer) As NovaLibra.Coral.SystemFrameworks.Security.UserLogin

            Dim objUserLogin As New NovaLibra.Coral.SystemFrameworks.Security.UserLogin
            Dim sql As String = "sp_security_user_details"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@UserID", SqlDbType.BigInt)
                objParam.Value = ID
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        objUserLogin.ID = .Item("ID")
                        objUserLogin.GUID = DataHelper.SmartValues(.Item("GUID"), "GUID", True)
                        objUserLogin.Username = DataHelper.SmartValues(.Item("UserName"), "String", True)
                        objUserLogin.Password = DataHelper.SmartValues(.Item("Password"), "String", True)
                        objUserLogin.FirstName = DataHelper.SmartValues(.Item("First_Name"), "String", True)
                        objUserLogin.LastName = DataHelper.SmartValues(.Item("Last_Name"), "String", True)
                        objUserLogin.EmailAddress = DataHelper.SmartValues(.Item("Email_Address"), "String", True)
                        objUserLogin.Organization = DataHelper.SmartValues(.Item("Organization"), "String", True)
                        objUserLogin.JobTitle = DataHelper.SmartValues(.Item("Job_Title"), "String", True)
                        objUserLogin.Enabled = DataHelper.SmartValues(.Item("Enabled"), "Boolean")
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

            Return objUserLogin
        End Function

        Public Shared Function GetAllEnabled() As DataTable
            Dim users As New DataTable

            Dim sql As String = "sp_security_user_getAllEnabled"
            Dim command As DBCommand
            Dim adapter As SqlDataAdapter
            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.Connection.Open()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure

                adapter = New SqlDataAdapter(command.CommandObject)
                adapter.Fill(users)

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try

            Return users
        End Function

        Public Shared Function HasAccess(ByVal pScopeConst As String, ByVal pPrivilegeConst As String, ByVal pUserID As Integer, Optional ByVal pObjectID As Integer = -1) As Boolean

            Dim userCanAccess As Boolean = False

            Dim conn As SqlConnection
            Dim cmd As SqlCommand

            Try

                Dim sSQL As String = "sys_security_user_permission"

                conn = New SqlConnection(Utilities.ApplicationHelper.GetAppConnection().ConnectionString)
                cmd = New SqlCommand(sSQL, conn)
                cmd.CommandType = CommandType.StoredProcedure

                cmd.Parameters.Add("@Scope_Constant", SqlDbType.VarChar).Value = pScopeConst
                cmd.Parameters.Add("@Privilege_Constant", SqlDbType.VarChar).Value = pPrivilegeConst
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = pUserID
                cmd.Parameters.Add("@Object_ID", SqlDbType.BigInt).Value = pObjectID

                cmd.Connection.Open()
                userCanAccess = Convert.ToBoolean(cmd.ExecuteScalar())
                cmd.Connection.Close()

            Catch ex As Exception
                 Logger.LogError(ex)
                Throw ex
            Finally
                Try
                    If cmd IsNot Nothing Then cmd.Dispose()
                    If conn IsNot Nothing Then conn.Dispose()
                    cmd = Nothing
                    conn = Nothing
                Catch ex As Exception

                End Try
            End Try

            Return userCanAccess
        End Function


    End Class

End Namespace

