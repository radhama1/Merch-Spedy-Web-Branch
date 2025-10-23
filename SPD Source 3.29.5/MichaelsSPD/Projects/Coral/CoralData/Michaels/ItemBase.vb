Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels

    Public Class ItemBase
        Implements IDisposable

        Dim conn As DBConnection = Nothing
        ' protected member
        Protected disposed As Boolean = False

        Public ReadOnly Property Connection() As DBConnection
            Get
                Return conn
            End Get
        End Property


        Public Sub New()
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            End Try
        End Sub

        Protected Overrides Sub Finalize()
            Dispose(True)
            MyBase.Finalize()
        End Sub

        Protected Overridable Sub Dispose(ByVal disposing As Boolean)
            If Not Me.disposed Then
                If disposing Then
                    ' Insert code to free unmanaged resources.
                    If Not conn Is Nothing Then
                        conn.Dispose()
                    End If
                End If
                ' Insert code to free shared resources.
                conn = Nothing
            End If
            Me.disposed = True
        End Sub


        Public Sub Dispose() Implements IDisposable.Dispose
            Dispose(True)
            GC.SuppressFinalize(Me)
        End Sub

    End Class

End Namespace

