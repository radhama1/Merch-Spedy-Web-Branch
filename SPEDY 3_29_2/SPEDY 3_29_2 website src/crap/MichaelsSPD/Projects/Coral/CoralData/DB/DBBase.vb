Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Configuration
Imports NovaLibra.Common

Public MustInherit Class DBBase
    Implements IDisposable

    Private _objDBConn As DBConnection = Nothing

    Protected _connCreated As Boolean = False ' flag to determine if created conn and thus should clean it up

    Protected disposed As Boolean = False

    Public Sub New()
        _objDBConn = New DBConnection()
        _connCreated = True
    End Sub

    Public Sub New(ByVal connString As String)
        _objDBConn = New DBConnection(connString)
        _connCreated = True
    End Sub

    Public Sub New(ByRef connection As DBConnection)
        _objDBConn = connection
        _connCreated = False
    End Sub

    Public Property Connection() As DBConnection
        Get
            Return _objDBConn
        End Get
        Set(ByVal value As DBConnection)
            If value Is Nothing Or _objDBConn IsNot value Then
                If Not _objDBConn Is Nothing And _connCreated Then
                    _objDBConn.Dispose()
                    _objDBConn = Nothing
                End If
                _objDBConn = value
                _connCreated = False
                SetConnection()
            End If
        End Set
    End Property

    Public Property ConnectionString() As String
        Get
            If Not _objDBConn Is Nothing Then
                Return _objDBConn.ConnectionString
            Else
                Return ""
            End If
        End Get
        Set(ByVal value As String)
            If _objDBConn Is Nothing Then
                _objDBConn = New DBConnection(value)
                _connCreated = True
                SetConnection()
            Else
                _objDBConn.ConnectionString = value
            End If
        End Set
    End Property

    ' called when a new connection object is set
    Protected MustOverride Sub SetConnection()


    Protected Overridable Sub Dispose(ByVal disposing As Boolean)
        If Not Me.disposed Then
            If disposing Then
                ' Insert code to free unmanaged resources.
                If Not _objDBConn Is Nothing And _connCreated Then
                    _objDBConn.Dispose()
                End If
            End If
            ' Insert code to free shared resources.
            _objDBConn = Nothing
        End If
        Me.disposed = True
    End Sub

    Public Sub Dispose() Implements IDisposable.Dispose
        If Not _objDBConn Is Nothing Then
            _objDBConn.Close()
        End If
        Dispose(True)
        GC.SuppressFinalize(Me)
    End Sub

    Protected Overrides Sub Finalize()
        Dispose(False)
        MyBase.Finalize()
    End Sub

End Class
