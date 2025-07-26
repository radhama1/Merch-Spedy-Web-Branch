Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Configuration
Imports NovaLibra.Common

Public Class DBConnection
    Implements IDisposable

    ' private members
    Private _objConn As SqlConnection = Nothing
    Private _isOpen As Boolean = False
    ' protected member
    Protected disposed As Boolean = False

    ' constructors
    Public Sub New()
        _objConn = New SqlConnection()
    End Sub

    Public Sub New(ByVal connString As String)
        _objConn = New SqlConnection(connString)
    End Sub

    Public Sub New(ByRef connection As SqlConnection)
        _objConn = connection
    End Sub

    Public Property ConnectionString() As String
        Get
            If Not _objConn Is Nothing Then
                Return _objConn.ConnectionString
            Else
                Return ""
            End If
        End Get
        Set(ByVal value As String)
            If _objConn.ConnectionString <> value Then
                If Me.IsOpen Then
                    Me.Close()
                    _objConn.ConnectionString = value
                    Me.Open()
                Else
                    _objConn.ConnectionString = value
                End If
            End If
        End Set
    End Property

    Public Property ConnectionObject() As System.Data.SqlClient.SqlConnection
        Get
            Return _objConn
        End Get
        Set(ByVal value As System.Data.SqlClient.SqlConnection)
            _objConn = value
        End Set
    End Property

    Public ReadOnly Property IsOpen() As Boolean
        Get
            'Return (Not _objConn Is Nothing AndAlso _objConn.State <> ConnectionState.Closed)
            Return (Not _objConn Is Nothing AndAlso _isOpen = True)
        End Get
    End Property

    Public Function Open() As Boolean
        Dim bRet As Boolean = True
        Try
            _objConn.Open()
            _isOpen = True
        Catch sqlex As SqlException
            Logger.LogError(sqlex)
            Throw sqlex
            _isOpen = False
            bRet = False
        Catch ex As Exception
            Logger.LogError(ex)
            _isOpen = False
            bRet = False
        End Try
        Return bRet
    End Function

    Public Function Open(ByVal connString As String) As Boolean
        If Me.IsOpen Then Me.Close()
        ConnectionString = connString
        Return Me.Open()
    End Function

    Public Sub Close()
        If Not _objConn Is Nothing Then
            Try
                If Not _objConn.State = ConnectionState.Closed OrElse _isOpen = True Then
                    _objConn.Close()
                    _isOpen = False
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                _isOpen = False
            End Try
        End If
    End Sub

    Protected Overridable Sub Dispose(ByVal disposing As Boolean)
        If Not Me.disposed Then
            If disposing Then
                ' Insert code to free unmanaged resources.
                If Not _objConn Is Nothing Then
                    Me.Close()
                    _objConn.Dispose()
                End If
            End If
            ' Insert code to free shared resources.
            _objConn = Nothing
        End If
        Me.disposed = True
    End Sub

    Public Sub Dispose() Implements IDisposable.Dispose
        Dispose(True)
        GC.SuppressFinalize(Me)
    End Sub

    Protected Overrides Sub Finalize()
        Dispose(False)
        MyBase.Finalize()
    End Sub

End Class
