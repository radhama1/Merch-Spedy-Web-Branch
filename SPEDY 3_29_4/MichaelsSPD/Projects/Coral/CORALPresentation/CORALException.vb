'*******************************************************************************
'Class: CORALException
'Created by: Scott Page
'Created Date: 3/10/2005
'Modifed Date:
'Desc: This class contains a custom application exception for custom exception handling
'********************************************************************************

Public Class CORALException

    Inherits ApplicationException

    Public Sub New()
        MyBase.New()
    End Sub

    Public Sub New(ByVal message As String)
        MyBase.New(message)
    End Sub

    Public Sub New(ByVal message As String, ByVal inner As Exception)
        MyBase.New(message, inner)
    End Sub
End Class
