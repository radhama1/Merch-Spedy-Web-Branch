Imports System
Imports System.Exception
Imports System.Runtime.Serialization
Imports System.Xml.Serialization

Imports Microsoft.VisualBasic

<System.Serializable()> _
Public Class SPEDYUploadException
    Inherits System.ApplicationException

    Public Sub New()
        MyBase.New()
    End Sub

    Public Sub New(ByVal message As String)
        MyBase.New(message)
    End Sub

    Public Sub New(ByVal message As String, ByRef innerException As Exception)
        MyBase.New(message, innerException)
    End Sub

    Public Sub New(ByRef info As System.Runtime.Serialization.SerializationInfo, ByRef context As System.Runtime.Serialization.StreamingContext)
        MyBase.New(info, context)
    End Sub
End Class
