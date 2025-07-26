Imports System.Web
Imports System.Web.UI
Imports System.Web.UI.WebControls

Imports Microsoft.VisualBasic

Public Interface INLChangeControl
    Inherits INLControl

    Property ChangeControl() As Boolean
    Property OriginalValue() As String
    ReadOnly Property ValueChanged() As Boolean
    Sub SetOriginalValue(ByVal value As Object, Optional ByVal setValue As Boolean = True)

    ' FJL 
    Property RevertEnabled() As Boolean

    Property TreatEmptyAsZero() As Boolean

End Interface
