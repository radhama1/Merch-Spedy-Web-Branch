Imports System.Data.SqlClient

Namespace Utilities

    Public Class DBUtil

        Private strConn As String

        Public Sub New(ByVal ConnStr As String)
            strConn = ConnStr
        End Sub

        Public Function GetSqlConnection() As SqlConnection

            Dim conn As SqlConnection

            Try

                conn = New SqlConnection(strConn)

            Catch ex As Exception

                Throw ex

            End Try

            Return conn

        End Function

        Public Function GetDataSet(ByVal Sql As String, Optional ByVal srcTable As String = "") As DataSet

            Dim ds As DataSet
            Dim sqlconn As SqlConnection
            Dim sqlcmd As SqlCommand
            Dim sqlda As SqlDataAdapter

            Try

                'Get Connection
                sqlconn = Me.GetSqlConnection()

                'set cmd
                sqlcmd = New SqlCommand(Sql, sqlconn)
                sqlcmd.CommandTimeout = 1800

                'set the DA
                sqlda = New SqlDataAdapter(sqlcmd)

                'fill the DS
                ds = New DataSet
                If srcTable.Length > 0 Then
                    sqlda.Fill(ds, srcTable)
                Else
                    sqlda.Fill(ds)
                End If

            Catch ex As Exception

                Throw ex

            Finally

                Try
                    'close the connection
                    sqlda.Dispose()

                Catch ex As Exception
                End Try

            End Try

            Return ds

        End Function

        Public Function GetDataTable(ByVal Sql As String, Optional ByVal srcTable As String = "") As DataTable

            Dim dt As DataTable
            Dim sqlconn As SqlConnection
            Dim sqlcmd As SqlCommand
            Dim sqlda As SqlDataAdapter

            Try

                'Get Connection
                sqlconn = Me.GetSqlConnection()

                'set cmd
                sqlcmd = New SqlCommand(Sql, sqlconn)
                sqlcmd.CommandTimeout = 1800

                'set the DA
                sqlda = New SqlDataAdapter(sqlcmd)

                'fill the DT
                dt = New DataTable
                sqlda.Fill(dt)

            Catch ex As Exception

                Throw ex

            Finally

                Try
                    'close the connection
                    sqlda.Dispose()

                Catch ex As Exception
                End Try

            End Try

            Return dt

        End Function

        Public Function GetDataTable(ByVal sqlcmd As SqlCommand) As DataTable

            Dim dt As DataTable
            Dim sqlda As SqlDataAdapter

            Try

                'set the DA
                sqlda = New SqlDataAdapter(sqlcmd)

                'fill the DT
                dt = New DataTable
                sqlda.Fill(dt)

            Catch ex As Exception

                Throw ex

            Finally

                Try
                    'close the connection
                    sqlda.Dispose()

                Catch ex As Exception
                End Try

            End Try

            Return dt

        End Function

        Public Function GetScalarValue(ByVal Sql As String) As Object

            Dim sqlconn As SqlConnection
            Dim sqlcmd As SqlCommand

            Try

                'Get Connection
                sqlconn = Me.GetSqlConnection()

                'set cmd
                sqlcmd = New SqlCommand(Sql, sqlconn)
                sqlcmd.CommandTimeout = 1800

                sqlconn.Open()
                Return sqlcmd.ExecuteScalar()

            Catch ex As Exception

                Throw ex

            Finally

                Try
                    If sqlconn.State <> ConnectionState.Closed Then
                        sqlconn.Close()
                    End If
                Catch ex As Exception
                End Try

            End Try

        End Function

        Public Function GetScalarValue(ByVal Sql As String, ByVal conn As SqlConnection) As Object

            Dim cmd As SqlCommand

            Try

                'set cmd
                cmd = New SqlCommand(Sql, conn)
                cmd.CommandTimeout = 1800

                Return cmd.ExecuteScalar()

            Catch ex As Exception

                Throw ex

            End Try

        End Function

        Public Shared Function FormatString(ByVal strParam As String) As String

            Dim strTemp As String = strParam

            Try 'to format the string

                strTemp = strTemp.Replace("'", "''")

            Catch e As Exception

            End Try

            Return strTemp

        End Function

        Public Sub ExecuteSqlCommand(ByVal Sql As String)

            Dim conn As SqlConnection
            Dim cmd As SqlCommand

            Try 'to load the data

                'get conn
                conn = Me.GetSqlConnection()

                'set cmd
                cmd = New SqlCommand(Sql, conn)
                cmd.CommandTimeout = 3600

                'open the connection
                conn.Open()

                'execute the statement
                Call cmd.ExecuteNonQuery()

            Catch ex As Exception

                Throw ex

            Finally
                'close db
                If conn.State = ConnectionState.Open Then
                    conn.Close()
                End If

            End Try

        End Sub

        Public Sub ExecuteSqlCommand(ByVal Sql As String, ByVal conn As SqlConnection)

            Dim cmd As SqlCommand

            Try
                'set cmd
                cmd = New SqlCommand(Sql, conn)
                cmd.CommandTimeout = 3600

                'execute the statement
                Call cmd.ExecuteNonQuery()

            Catch ex As Exception

                Throw ex

            End Try

        End Sub

    End Class

End Namespace