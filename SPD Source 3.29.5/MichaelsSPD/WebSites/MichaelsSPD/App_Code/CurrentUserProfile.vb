Imports Microsoft.VisualBasic
Imports System.Web.Profile


Public Class CurrentUserProfile
    Inherits ProfileBase

    Public Property ID() As Long
        Get
            Return CType(Me("ID"), Long)
        End Get
        Set(ByVal value As Long)
            Me("ID") = value
        End Set
    End Property
End Class
