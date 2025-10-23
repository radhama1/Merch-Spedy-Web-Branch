Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Configuration
Imports NovaLibra.Common

Public Class DBDataTable
    Implements IDisposable

    Private _objSelectDBCmd As DBCommand = Nothing
    Private _objDataTable As System.Data.DataTable = New System.Data.DataTable()
    Private _cmdSelectCreated As Boolean = False ' flag to determine if reader created cmd and thus should clean it up
    Private _opened As Boolean = False

    Protected disposed As Boolean = False

    Public Sub New()
        _objSelectDBCmd = New DBCommand
        _cmdSelectCreated = True
    End Sub

    Public Sub New(ByVal connString As String)
        _objSelectDBCmd = New DBCommand(connString)
        _cmdSelectCreated = True
    End Sub

    Public Sub New(ByRef connection As DBConnection)
        _objSelectDBCmd = New DBCommand(connection)
        _cmdSelectCreated = True
    End Sub

    Public Sub New(ByRef connection As DBConnection, ByVal commandText As String)
        _objSelectDBCmd = New DBCommand(connection)
        _cmdSelectCreated = True
        _objSelectDBCmd.CommandText = commandText
        _objSelectDBCmd.CommandType = CommandType.Text
    End Sub

    Public Sub New(ByRef connection As DBConnection, ByVal commandText As String, ByVal commandType As System.Data.CommandType)
        Me.New(connection, commandText)
        _objSelectDBCmd.CommandType = commandType
    End Sub

    Public Sub New(ByRef command As DBCommand)
        _objSelectDBCmd = command
        _cmdSelectCreated = False
    End Sub

    Public Property SelectCommand() As DBCommand
        Get
            Return _objSelectDBCmd
        End Get
        Set(ByVal value As DBCommand)
            If value Is Nothing Or _objSelectDBCmd IsNot value Then
                If Not _objSelectDBCmd Is Nothing And _cmdSelectCreated Then
                    _objSelectDBCmd.Dispose()
                    _objSelectDBCmd = Nothing
                End If
                _objSelectDBCmd = value
                _cmdSelectCreated = False
            End If
        End Set
    End Property

    Public Property SelectCommandType() As System.Data.CommandType
        Get
            Return _objSelectDBCmd.CommandType
        End Get
        Set(ByVal value As System.Data.CommandType)
            _objSelectDBCmd.CommandType = value
        End Set
    End Property

    Public Property SelectCommandText() As String
        Get
            Return _objSelectDBCmd.CommandText
        End Get
        Set(ByVal value As String)
            _objSelectDBCmd.CommandText = value
        End Set
    End Property

    Public ReadOnly Property DataTable() As System.Data.DataTable
        Get
            Return Me._objDataTable
        End Get
    End Property

    Public Function Open() As Boolean
        ' checks
        If _objSelectDBCmd Is Nothing Then
            Logger.LogError(New ApplicationException(DBErrorCode.DBERROR_NO_COMMAND))
            Return False
        ElseIf _objSelectDBCmd.Connection Is Nothing Then
            Logger.LogError(New ApplicationException(DBErrorCode.DBERROR_NO_CONNECTION_OBJECT))
            Return False
        ElseIf Trim(_objSelectDBCmd.CommandText) = "" Then
            Logger.LogError(New ApplicationException(DBErrorCode.DBERROR_NO_SQL_STATEMENT))
            Return False
        End If

        _opened = False
        Try
            ' check if the connection hasn't been opened, and open it if not open
            If Not _objSelectDBCmd.Connection.IsOpen Then
                _objSelectDBCmd.Connection.Open()
                _opened = True
            End If
            ' create DataTable
            Dim sda As New SqlDataAdapter(_objSelectDBCmd.CommandObject)
            sda.Fill(_objDataTable)
            ' if opened the connection, then close it
            If _opened Then
                _objSelectDBCmd.Connection.Close()
            End If
        Catch exsql As SqlException
            Logger.LogError(exsql)
            Throw exsql
            Return False
        Catch ex As Exception
            Logger.LogError(ex)
            Return False
        End Try
        Return True
    End Function

    Public Function Open(ByVal commandText As String) As Boolean
        Me._objSelectDBCmd.CommandText = commandText
        Return Me.Open()
    End Function

    Public Function Open(ByVal commandText As String, ByVal commandType As System.Data.CommandType) As Boolean
        Me._objSelectDBCmd.CommandText = commandText
        Me._objSelectDBCmd.CommandType = commandType
        Return Me.Open()
    End Function

    Public Sub Close()
        If _opened And Not _objSelectDBCmd Is Nothing Then
            If Not _objSelectDBCmd.Connection Is Nothing Then
                _objSelectDBCmd.Connection.Close()
            End If
            _opened = False
        End If
        If _cmdSelectCreated And Not _objSelectDBCmd Is Nothing Then
            Me.SelectCommand = Nothing
        End If
        If Not _objDataTable Is Nothing Then
            _objDataTable.Clear()
        End If
    End Sub

    Public ReadOnly Property HasRows() As Boolean
        Get
            Return (_objDataTable.Rows.Count > 0)
        End Get
    End Property

    Public ReadOnly Property Rows() As System.Data.DataRowCollection
        Get
            If Not _objDataTable Is Nothing Then
                Return _objDataTable.Rows
            Else
                Return Nothing
            End If
        End Get
    End Property

    Public ReadOnly Property Row(ByVal index As Integer) As System.Data.DataRow
        Get
            If Not _objDataTable Is Nothing AndAlso (index >= 0 And index < _objDataTable.Rows.Count) Then
                Return _objDataTable.Rows(index)
            Else
                Return Nothing
            End If
        End Get
    End Property

    Public ReadOnly Property Count() As Integer
        Get
            If Not _objDataTable Is Nothing Then
                Return _objDataTable.Rows.Count
            Else
                Return 0
            End If
        End Get
    End Property

    Default Public Property Item(ByVal rowIndex As Integer, ByVal columnIndex As Integer) As Object
        Get
            If Not _objDataTable Is Nothing Then
                Return _objDataTable.Rows(rowIndex).Item(columnIndex)
            Else
                Return Nothing
            End If
        End Get
        Set(ByVal value As Object)
            If Not _objDataTable Is Nothing Then
                _objDataTable.Rows(rowIndex).Item(columnIndex) = value
            End If
        End Set
    End Property

    Default Public Property Item(ByVal rowIndex As Integer, ByVal columnName As String) As Object
        Get
            If Not _objDataTable Is Nothing Then
                Return _objDataTable.Rows(rowIndex).Item(columnName)
            Else
                Return Nothing
            End If
        End Get
        Set(ByVal value As Object)
            If Not _objDataTable Is Nothing Then
                _objDataTable.Rows(rowIndex).Item(columnName) = value
            End If
        End Set
    End Property


    Protected Overridable Sub Dispose(ByVal disposing As Boolean)
        If Not Me.disposed Then
            If disposing Then
                ' Insert code to free unmanaged resources.
                If Not _objSelectDBCmd Is Nothing And _cmdSelectCreated Then
                    _objSelectDBCmd.Dispose()
                End If
                Close()
            End If
            ' Insert code to free shared resources.
            _objSelectDBCmd = Nothing
            _objDataTable.Dispose()
            _objDataTable = Nothing
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
