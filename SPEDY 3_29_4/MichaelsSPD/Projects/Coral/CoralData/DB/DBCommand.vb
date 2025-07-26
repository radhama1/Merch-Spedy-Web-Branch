Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Configuration
Imports NovaLibra.Common

Public Class DBCommand
    Inherits DBBase

    Private _objCmd As SqlCommand = Nothing
    Private _opened As Boolean = False

    Public Sub New()
        MyBase.New()
        _objCmd = New SqlCommand()
        SetConnection()
    End Sub

    Public Sub New(ByVal connString As String)
        MyBase.New(connString)
        _objCmd = New SqlCommand()
        SetConnection()
    End Sub

    Public Sub New(ByVal connString As String, ByVal commandText As String, ByVal commandType As System.Data.CommandType)
        MyBase.New(connString)
        _objCmd = New SqlCommand(commandText)
        _objCmd.CommandType = commandType
        SetConnection()
    End Sub

    Public Sub New(ByRef connection As DBConnection)
        MyBase.New(connection)
        _objCmd = New SqlCommand()
        SetConnection()
    End Sub

    Public Sub New(ByVal connection As DBConnection, ByVal commandText As String, ByVal commandType As System.Data.CommandType)
        MyBase.New(connection)
        _objCmd = New SqlCommand(commandText)
        _objCmd.CommandType = commandType
        SetConnection()
    End Sub

    Public Property CommandType() As System.Data.CommandType
        Get
            Return _objCmd.CommandType
        End Get
        Set(ByVal value As System.Data.CommandType)
            _objCmd.CommandType = value
        End Set
    End Property

    Public Property CommandText() As String
        Get
            Return _objCmd.CommandText
        End Get
        Set(ByVal value As String)
            _objCmd.CommandText = value
        End Set
    End Property

    Public Property CommandTimeout() As Integer
        Get
            Return _objCmd.CommandTimeout
        End Get
        Set(ByVal value As Integer)
            _objCmd.CommandTimeout = value
        End Set
    End Property

    Public ReadOnly Property Parameters() As System.Data.SqlClient.SqlParameterCollection
        Get
            If Not Me.disposed Then
                Return _objCmd.Parameters
            Else
                Return Nothing
            End If
        End Get
    End Property

    Public ReadOnly Property CommandObject() As System.Data.SqlClient.SqlCommand
        Get
            Return _objCmd
        End Get
    End Property

    Public Function ExecuteNonQuery() As Integer
        Dim retValue As Integer
        Try
            If Not Connection.IsOpen Then
                Connection.Open()
                _opened = True
            End If
            retValue = _objCmd.ExecuteNonQuery()
        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            Throw sqlex
        Catch ex As Exception
            Logger.LogError(ex)
            Throw ex
        End Try
        Return retValue
    End Function

    Public Function ExecuteReader() As System.Data.SqlClient.SqlDataReader
        Dim reader As System.Data.SqlClient.SqlDataReader = Nothing
        Try
            If Not Connection.IsOpen Then
                Connection.Open()
                _opened = True
            End If
            reader = _objCmd.ExecuteReader()
            If _opened Then
                Connection.Close()
                _opened = False
            End If
        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            Throw sqlex
        Catch ex As Exception
            Logger.LogError(ex)
        End Try
        Return reader
    End Function

    Public Function ExecuteReader(ByVal behavior As System.Data.CommandBehavior) As System.Data.SqlClient.SqlDataReader
        Dim reader As System.Data.SqlClient.SqlDataReader = Nothing
        Try
            If Not Connection.IsOpen Then
                Connection.Open()
                _opened = True
            End If
            reader = _objCmd.ExecuteReader(behavior)
            If _opened Then
                Connection.Close()
                _opened = False
            End If
        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            Throw sqlex
        Catch ex As Exception
            Logger.LogError(ex)
        End Try
        Return reader
    End Function

    Protected Overrides Sub SetConnection()
        If Not Connection Is Nothing And Not _objCmd Is Nothing Then
            _objCmd.Connection = Connection.ConnectionObject
        End If
    End Sub


    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        If Not Me.disposed Then
            If disposing Then
                ' Insert code to free unmanaged resources.
                If _connCreated Then
                    Connection.Dispose()
                    Connection = Nothing
                End If
                _objCmd.Dispose()
            End If
            ' Insert code to free shared resources.
            _objCmd = Nothing
        End If
        MyBase.Dispose(disposing)
    End Sub


    Protected Overrides Sub Finalize()
        MyBase.Finalize()
    End Sub

End Class
