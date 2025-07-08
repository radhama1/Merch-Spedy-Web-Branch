Imports System
Imports System.Text
Imports System.Web
Imports System.Web.UI
Imports System.Web.UI.WebControls

Imports Microsoft.VisualBasic


<ToolboxData("<{0}:NLValidationSummary runat=""server""></{0}:NLValidationSummary>")> _
Public Class NLValidationSummary
    Inherits System.Web.UI.WebControls.ValidationSummary

    Public Sub AddMessage(ByVal message As String)
        Me.Page.Validators.Add(New NLCustomValidator(message))
    End Sub

End Class

Public Class NLCustomValidator
    Implements IValidator

    Private _errorMessage As String = String.Empty

    Public Sub New(ByVal message As String)
        _errorMessage = message
    End Sub

    Public Property ErrorMessage() As String Implements System.Web.UI.IValidator.ErrorMessage
        Get
            Return _errorMessage
        End Get
        Set(ByVal value As String)
            _errorMessage = value
        End Set
    End Property

    Public Property IsValid() As Boolean Implements System.Web.UI.IValidator.IsValid
        Get
            Return False
        End Get
        Set(ByVal value As Boolean)

        End Set
    End Property

    Public Sub Validate() Implements System.Web.UI.IValidator.Validate

    End Sub
End Class


