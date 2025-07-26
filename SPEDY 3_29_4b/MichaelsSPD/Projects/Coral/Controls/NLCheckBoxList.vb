Imports System
Imports System.ComponentModel
Imports System.Text
Imports System.Web
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports Microsoft.VisualBasic

<ToolboxData("<{0}:NLCheckBoxList runat=""server""></{0}:NLCheckBoxList>")> _
Public Class NLCheckBoxList
    Inherits System.Web.UI.WebControls.CheckBoxList
    Implements INLChangeControl

#Region "INLChangeControl"
    <Bindable(True), DefaultValue(False)> _
        Public Property RenderReadOnly() As Boolean Implements INLChangeControl.RenderReadOnly
        Get
            Dim o As Object = Me.ViewState.Item("RenderReadOnly")
            If Not o Is Nothing Then
                Return CType(o, Boolean)
            Else
                Return False
            End If
        End Get
        Set(ByVal value As Boolean)
            Me.ViewState.Item("RenderReadOnly") = value
        End Set
    End Property

    <Bindable(True), DefaultValue("renderReadOnly")> _
    Public Property RenderReadOnlyCssClass() As String Implements INLChangeControl.RenderReadOnlyCssClass
        Get
            Dim o As Object = Me.ViewState.Item("RenderReadOnlyCssClass")
            If Not o Is Nothing Then
                Return CType(o, String)
            Else
                Return "renderReadOnly"
            End If
        End Get
        Set(ByVal value As String)
            Me.ViewState.Item("RenderReadOnlyCssClass") = value
        End Set
    End Property

    <Bindable(True), DefaultValue(False)> _
    Public Property ChangeControl() As Boolean Implements INLChangeControl.ChangeControl
        Get
            Dim o As Object = Me.ViewState.Item("ChangeControl")
            If Not o Is Nothing Then
                Return CType(o, Boolean)
            Else
                Return False
            End If
        End Get
        Set(ByVal value As Boolean)
            Me.ViewState.Item("ChangeControl") = value
        End Set
    End Property

    <Bindable(True), DefaultValue("")> _
    Property OriginalValue() As String Implements INLChangeControl.OriginalValue
        Get
            Dim o As Object = Me.ViewState.Item("OriginalValue")
            If Not o Is Nothing Then
                Return CType(o, String)
            Else
                Return ""
            End If
        End Get
        Set(ByVal value As String)
            Me.ViewState.Item("OriginalValue") = value
        End Set
    End Property

    <Bindable(True), DefaultValue(True)> _
    Public Property RevertEnabled() As Boolean Implements INLChangeControl.RevertEnabled
        Get
            Dim o As Object = Me.ViewState.Item("RevertEnabled")
            If Not o Is Nothing Then
                Return CType(o, Boolean)
            Else
                Return True
            End If
        End Get
        Set(ByVal value As Boolean)
            Me.ViewState.Item("RevertEnabled") = value
        End Set
    End Property

    Public ReadOnly Property ValueChanged() As Boolean Implements INLChangeControl.ValueChanged
        Get
            If Me.TreatEmptyAsZero Then
                If NLChangeControl.IsEmptyOrZero(OriginalValue.ToString()) AndAlso NLChangeControl.IsEmptyOrZero(SelectedValue) Then
                    Return False
                Else
                    Return OriginalValue.ToString() <> SelectedValue
                End If
            Else
                Return OriginalValue.ToString() <> SelectedValue
            End If
        End Get
    End Property

    Public Sub SetOriginalValue(ByVal value As Object, Optional ByVal setValue As Boolean = True) Implements INLChangeControl.SetOriginalValue
        OriginalValue = value
        If setValue Then SelectedValue = value.ToString()
    End Sub

    <Bindable(True), DefaultValue(False)> _
    Public Property TreatEmptyAsZero() As Boolean Implements INLChangeControl.TreatEmptyAsZero
        Get
            Dim o As Object = Me.ViewState.Item("TEAZ")
            If Not o Is Nothing Then
                Return CType(o, Boolean)
            Else
                Return False
            End If
        End Get
        Set(ByVal value As Boolean)
            Me.ViewState.Item("TEAZ") = value
        End Set
    End Property
#End Region

    Public Sub SetOriginalValue(ByVal value As Integer, Optional ByVal setValue As Boolean = True)
        Dim val As String = String.Empty
        If value >= 0 AndAlso value < Me.Items.Count Then
            val = Me.Items(value).Value
            Me.OriginalValue = val
            If setValue Then SelectedIndex = value
        End If
    End Sub

    Protected Overrides Sub OnPreRender(ByVal e As System.EventArgs)
        MyBase.OnPreRender(e)
        NLChangeControl.Initialize(Me)
    End Sub

    Protected Overrides Sub AddAttributesToRender(ByVal writer As System.Web.UI.HtmlTextWriter)
        'If Not RenderReadOnly Then
        MyBase.AddAttributesToRender(writer)
        'End If
    End Sub

    Protected Overrides Sub Render(ByVal writer As HtmlTextWriter)
        If Me.ChangeControl Then NLChangeControl.RenderBeginChangeControl(writer, Me)
        If RenderReadOnly Then
            ' render read only version
            Dim span As System.Web.UI.WebControls.WebControl = New System.Web.UI.WebControls.WebControl(System.Web.UI.HtmlTextWriterTag.Span)
            span.CssClass = RenderReadOnlyCssClass
            span.ToolTip = Me.ToolTip
            span.RenderBeginTag(writer)
            'writer.Write("&nbsp; " & Me.Page.Server.HtmlEncode(NLControlHelper.RemoveDangerousText(Me.Checked.ToString())))
            Dim chkStr As New StringBuilder("")
            For Each j As ListItem In Me.Items
                chkStr.Append(IIf(Boolean.Parse(j.Selected), "[x] - " & j.Text & " <br/>", "[&nbsp;&nbsp;] - " & j.Text & " <br/>"))
            Next
            writer.Write(chkStr.ToString)
            span.RenderEndTag(writer)
            Me.CssClass = "hideElement"
            MyBase.Render(writer)
        Else
            If Me.ChangeControl And Not RenderReadOnly Then    ' add the onchange event handler to the control if its not RenderReadOnly
                'If Me.ChangeControl Then    ' add the onchange event handler to the control
                Dim onChangeAttr As String = NLChangeControl.GetOnChangeAttribute(Me)
                Dim curOnClick As String = Me.Attributes.Item("onclick")
                Me.Attributes.Add("onclick", onChangeAttr + " " + curOnClick)
            End If
            MyBase.Render(writer)
        End If
        If Me.ChangeControl Then NLChangeControl.RenderEndChangeControl(writer, Me)
    End Sub

    Private Sub NLCheckBoxList_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        SetOriginalValue(False)
    End Sub

End Class
