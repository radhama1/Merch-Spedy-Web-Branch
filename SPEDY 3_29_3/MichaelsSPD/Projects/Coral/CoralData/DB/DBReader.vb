Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Configuration
Imports NovaLibra.Common

Public Class DBReader
    Implements IDisposable

    Private _objDBCmd As DBCommand = Nothing
    Private _objReader As System.Data.SqlClient.SqlDataReader = Nothing
    Private _cmdCreated As Boolean = False ' flag to determine if reader created cmd and thus should clean it up
    Private _opened As Boolean = False

    Protected disposed As Boolean = False

    Public Sub New()
        _objDBCmd = New DBCommand
        _cmdCreated = True
    End Sub

    Public Sub New(ByVal connString As String)
        _objDBCmd = New DBCommand(connString)
        _cmdCreated = True
    End Sub

    Public Sub New(ByRef connection As DBConnection)
        _objDBCmd = New DBCommand(connection)
        _cmdCreated = True
    End Sub

    Public Sub New(ByRef connection As DBConnection, ByVal cmdText As String)
        _objDBCmd = New DBCommand(connection)
        _cmdCreated = True
        _objDBCmd.CommandText = cmdText
    End Sub

    Public Sub New(ByRef connection As DBConnection, ByVal commandText As String, ByVal commandType As System.Data.CommandType)
        Me.New(connection, commandText)
        _objDBCmd.CommandType = commandType
    End Sub

    Public Sub New(ByRef command As DBCommand)
        _objDBCmd = command
        _cmdCreated = False
    End Sub

    Public Property Command() As DBCommand
        Get
            Return _objDBCmd
        End Get
        Set(ByVal value As DBCommand)
            If value Is Nothing Or _objDBCmd IsNot value Then
                If Not _objDBCmd Is Nothing And _cmdCreated Then
                    _objDBCmd.Dispose()
                    _objDBCmd = Nothing
                End If
                _objDBCmd = value
                _cmdCreated = False
            End If
        End Set
    End Property

    Public Property CommandType() As System.Data.CommandType
        Get
            Return _objDBCmd.CommandType
        End Get
        Set(ByVal value As System.Data.CommandType)
            _objDBCmd.CommandType = value
        End Set
    End Property

    Public Property CommandText() As String
        Get
            Return _objDBCmd.CommandText
        End Get
        Set(ByVal value As String)
            _objDBCmd.CommandText = value
        End Set
    End Property

    Public ReadOnly Property Reader() As System.Data.SqlClient.SqlDataReader
        Get
            Return _objReader
        End Get
    End Property

    Default Public ReadOnly Property Item(ByVal i As Integer) As Object
        Get
            Return Me.Reader.Item(i)
        End Get
    End Property

    Default Public ReadOnly Property Item(ByVal name As String) As Object
        Get
            Return Me.Reader.Item(name)
        End Get
    End Property

    Public Sub Open() 'As System.Data.SqlClient.SqlDataReader
        ' checks
        If _objDBCmd Is Nothing Then
            Logger.LogError(New ApplicationException(DBErrorCode.DBERROR_NO_COMMAND))
            'Return Nothing
        ElseIf _objDBCmd.Connection Is Nothing Then
            Logger.LogError(New ApplicationException(DBErrorCode.DBERROR_NO_CONNECTION_OBJECT))
            'Return Nothing
        ElseIf Trim(_objDBCmd.CommandText) = "" Then
            Logger.LogError(New ApplicationException(DBErrorCode.DBERROR_NO_SQL_STATEMENT))
            'Return Nothing
        End If

        _opened = False
        Try
            ' check if the connection hasn't been opened, and open it if not open
            If Not _objDBCmd.Connection.IsOpen Then
                _objDBCmd.Connection.Open()
                _opened = True
            End If
            ' create reader
            _objReader = _objDBCmd.CommandObject.ExecuteReader(CommandBehavior.CloseConnection)
            ' if opened the connection, then close it
            'If _opened Then
            '_objDBCmd.Connection.Close()
            'End If
        Catch exsql As SqlException
            Logger.LogError(exsql)
            Throw exsql
            'Return Nothing
        Catch ex As Exception
            Logger.LogError(ex)
            Throw ex
            'Return Nothing
        End Try
        'If clearCommand Then
        'Me.Command = Nothing
        'End If
        'Return _objReader
    End Sub

    Public Sub Open(ByVal commandText As String) 'As System.Data.SqlClient.SqlDataReader
        Me.CommandText = commandText
        'Return Me.Open()
    End Sub

    Public Sub Open(ByVal commandText As String, ByVal commandType As System.Data.CommandType) 'As System.Data.SqlClient.SqlDataReader
        Me.CommandText = commandText
        Me.CommandType = commandType
        'Return Me.Open()
    End Sub

    Public Sub Close()
        If _opened And Not _objDBCmd Is Nothing Then
            If Not _objDBCmd.Connection Is Nothing Then
                _objDBCmd.Connection.Close()
            End If
            _opened = False
        End If
        If _cmdCreated And Not _objDBCmd Is Nothing Then
            Me.Command = Nothing
        End If
        If Not _objReader Is Nothing Then
            If Not _objReader.IsClosed Then
                _objReader.Close()
            End If
        End If
    End Sub

    Public ReadOnly Property HasRows() As Boolean
        Get
            Return Me.Reader.HasRows
        End Get
    End Property

    Public Function Read() As Boolean
        Return Me.Reader.Read()
    End Function

    Public Function NextResult() As Boolean
        Return Me.Reader.NextResult()
    End Function


    Protected Overridable Sub Dispose(ByVal disposing As Boolean)
        If Not Me.disposed Then
            If disposing Then
                ' Insert code to free unmanaged resources.
                If Not _objDBCmd Is Nothing And _cmdCreated Then
                    _objDBCmd.Dispose()
                End If
                Close()
            End If
            ' Insert code to free shared resources.
            _objDBCmd = Nothing
            _objReader = Nothing
        End If
        Me.disposed = True
    End Sub

    Public Sub Dispose() Implements IDisposable.Dispose
        If Not _objDBCmd Is Nothing Then
            If Not _objDBCmd.Connection Is Nothing Then
                _objDBCmd.Connection.Close()
            End If
        End If
        Dispose(True)
        GC.SuppressFinalize(Me)
    End Sub

    Protected Overrides Sub Finalize()
        Dispose(False)
        MyBase.Finalize()
    End Sub

End Class
