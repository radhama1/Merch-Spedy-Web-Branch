Imports System
Imports System.ComponentModel
Imports System.IO
Imports System.Text
Imports System.Web
Imports System.Web.UI
Imports System.Web.UI.WebControls

Imports Microsoft.VisualBasic

Imports NovaLibra.Coral.SystemFrameworks

<ToolboxData("<{0}:NLCustomFields runat=""server""></{0}:NLCustomFields>")> _
Public Class NLCustomFields
    Inherits System.Web.UI.WebControls.WebControl

    Public Const CUSTOM_FIELD_NAME As String = "##NAME##"
    Public Const CUSTOM_FIELD_VALUE As String = "##VALUE##"
    Public Const CUSTOM_FIELD_COLUMNS As Integer = 30

    Private _customFields As CustomFields = Nothing

    Public ReadOnly Property FieldCount() As Integer
        Get
            Return _customFields.FieldCount
        End Get
    End Property

    <Bindable(True), DefaultValue(0)> _
    Public Property RecordType() As Integer
        Get
            Dim o As Object = Me.ViewState.Item("RecordType")
            If Not o Is Nothing Then
                Return CType(o, Integer)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            Me.ViewState.Item("RecordType") = value
        End Set
    End Property

    <Bindable(True), DefaultValue(0)> _
    Public Property RecordID() As Long
        Get
            Dim o As Object = Me.ViewState.Item("RecordID")
            If Not o Is Nothing Then
                Return CType(o, Long)
            Else
                Return False
            End If
        End Get
        Set(ByVal value As Long)
            Me.ViewState.Item("RecordID") = value
        End Set
    End Property

    <Bindable(True), DefaultValue("")> _
    Public Property DisplayTemplate() As String
        Get
            Dim o As Object = Me.ViewState.Item("DisplayTemplate")
            If Not o Is Nothing Then
                Return CType(o, String)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As String)
            Me.ViewState.Item("DisplayTemplate") = value
        End Set
    End Property

    <Bindable(True), DefaultValue(30)> _
    Public Property Columns() As Integer
        Get
            Dim o As Object = Me.ViewState.Item("Columns")
            Dim cols As Integer
            If Not o Is Nothing Then
                cols = CType(o, Integer)
            Else
                cols = CUSTOM_FIELD_COLUMNS
            End If
            If cols < -0 Then cols = CUSTOM_FIELD_COLUMNS
            Return cols
        End Get
        Set(ByVal value As Integer)
            Me.ViewState.Item("Columns") = value
        End Set
    End Property

    <Bindable(True), DefaultValue(False)> _
    Public Property RenderReadOnly() As Boolean
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

    Protected Overrides Sub AddAttributesToRender(ByVal writer As System.Web.UI.HtmlTextWriter)
        If Not RenderReadOnly Then
            MyBase.AddAttributesToRender(writer)
        End If
    End Sub

    Protected Overrides Sub OnLoad(ByVal e As System.EventArgs)
        MyBase.OnLoad(e)
        If Me.Page.IsPostBack Then
            Me.LoadCustomFields(True)
            Me.LoadValuesFromResponse()
        End If
    End Sub

    Protected Overrides Sub Render(ByVal writer As HtmlTextWriter)
        ' if DisplayTemplate is populated with a string, then render with the following rules:
        ' - replace CUSTOM_FIELD_NAME with the field name
        ' - replace CUSTOM_FIELD_VALUE with the control
        ' if DisplayTemplate is blank, then render with the following rules:
        ' - display label for control, then control
        ' - separate fields with a <br /> tag

        Dim sb As New StringBuilder("")
        Dim fieldName As String
        Dim fieldString As String
        Dim fieldString2 As String
        Dim stringValue As String
        'Dim wc As System.Web.UI.WebControls.WebControl
        Dim tb As System.Web.UI.WebControls.TextBox
        Dim cb As System.Web.UI.WebControls.CheckBox
        Dim value As CustomFieldValue
        Dim count As Integer = 0

        If Not _customFields Is Nothing Then
            For Each field As CustomField In _customFields.Fields
                value = _customFields.GetValue(Me.RecordID, field.ID)
                fieldString2 = String.Empty
                Select Case field.FieldType
                    Case CustomFieldType.TypeBoolean
                        cb = New System.Web.UI.WebControls.CheckBox
                        cb.ID = Me.BuildControlID(field.ID, Me.RecordID)
                        If Not value Is Nothing Then
                            stringValue = value.GetFieldValueFormatted()
                        Else
                            stringValue = ""
                        End If
                        If stringValue = "1" Then
                            cb.Checked = True
                        Else
                            cb.Checked = False
                        End If
                        fieldString = RenderCustomControl(cb, stringValue)
                    Case Else
                        tb = New System.Web.UI.WebControls.TextBox
                        tb.ID = Me.BuildControlID(field.ID, Me.RecordID)
                        If Not value Is Nothing Then
                            stringValue = value.GetFieldValueFormatted()
                        Else
                            stringValue = ""
                        End If
                        Select Case field.FieldType
                            Case CustomFieldType.TypeDate
                                If field.FieldLimit > 0 AndAlso field.FieldLimit >= 10 Then
                                    tb.MaxLength = field.FieldLimit
                                    tb.Columns = field.FieldLimit
                                Else
                                    tb.MaxLength = 10
                                    tb.Columns = 10
                                End If
                            Case CustomFieldType.TypeDateTime
                                If field.FieldLimit > 0 AndAlso field.FieldLimit >= 18 Then
                                    tb.MaxLength = field.FieldLimit
                                    tb.Columns = field.FieldLimit
                                Else
                                    tb.MaxLength = 20
                                    tb.Columns = 20
                                End If
                            Case CustomFieldType.TypeDecimal, CustomFieldType.TypeInteger, CustomFieldType.TypeLong, CustomFieldType.TypeMoney
                                If field.FieldLimit > 0 Then
                                    tb.MaxLength = field.FieldLimit
                                    tb.Columns = field.FieldLimit
                                Else
                                    tb.MaxLength = 20
                                    tb.Columns = 20
                                End If
                            Case CustomFieldType.TypePercent
                                If field.FieldLimit > 0 Then
                                    tb.MaxLength = field.FieldLimit
                                    tb.Columns = field.FieldLimit
                                Else
                                    tb.MaxLength = 10
                                    tb.Columns = 10
                                End If
                                fieldString2 = "%"
                            Case CustomFieldType.TypeText
                                tb.Rows = 5
                                tb.TextMode = TextBoxMode.MultiLine
                                tb.Columns = Me.Columns
                                If field.FieldLimit > 0 Then
                                    tb.MaxLength = field.FieldLimit
                                End If
                            Case CustomFieldType.TypeTime
                                If field.FieldLimit > 0 AndAlso field.FieldLimit >= 10 Then
                                    tb.MaxLength = field.FieldLimit
                                    tb.Columns = field.FieldLimit
                                Else
                                    tb.MaxLength = 10
                                    tb.Columns = 10
                                End If
                            Case Else
                                If field.FieldLimit > 0 Then
                                    tb.MaxLength = field.FieldLimit
                                End If
                                tb.Columns = Me.Columns
                        End Select
                        tb.Text = stringValue
                        fieldString = RenderCustomControl(tb, stringValue) & fieldString2
                End Select
                fieldName = Me.Page.Server.HtmlEncode(NLControlHelper.RemoveDangerousText(field.FieldName))
                If Me.DisplayTemplate <> "" Then
                    stringValue = Me.DisplayTemplate
                    sb.Append(stringValue.Replace(CUSTOM_FIELD_NAME, fieldName).Replace(CUSTOM_FIELD_VALUE, fieldString))
                Else
                    stringValue = "<label for=""" & Me.BuildControlID(field.ID, Me.RecordID) & """>" & fieldName & "</label> &nbsp; "
                    sb.Append(stringValue)
                    sb.Append(fieldString)
                    If count > 0 Then
                        sb.Append("<br />")
                    End If
                End If
                count += 1
            Next
        End If
        writer.Write(sb.ToString())
    End Sub

    Protected Function RenderCustomControl(ByRef control As System.Web.UI.WebControls.WebControl, ByVal stringValue As String) As String
        Dim sw As New StringWriter()
        Dim controlwriter As New HtmlTextWriter(sw)

        If Me.RenderReadOnly Then
            ' render read only version
            Dim span As System.Web.UI.WebControls.WebControl = New System.Web.UI.WebControls.WebControl(System.Web.UI.HtmlTextWriterTag.Span)
            span.CssClass = "renderReadOnly"
            span.RenderBeginTag(controlwriter)
            controlwriter.Write("&nbsp; " & Me.Page.Server.HtmlEncode(NLControlHelper.RemoveDangerousText(stringValue)))
            span.RenderEndTag(controlwriter)
            Dim ctrl As System.Web.UI.WebControls.HiddenField = New System.Web.UI.WebControls.HiddenField()
            ctrl.ID = control.ID
            ctrl.Value = stringValue
            ctrl.RenderControl(controlwriter)
        Else
            control.RenderControl(controlwriter)
        End If
        Return sw.ToString()
    End Function

    Public Sub LoadCustomFields(Optional ByVal loadValues As Boolean = False)
        Dim recordIDString As String
        If loadValues Then
            recordIDString = Me.RecordID.ToString
        Else
            recordIDString = ""
        End If
        _customFields = NovaLibra.Coral.BusinessFacade.SystemCustomFields.GetCustomFields(Me.RecordType, recordIDString)
    End Sub

    Public Function SaveCustomFields(ByVal recordID As Long) As Boolean
        If Not _customFields Is Nothing Then
            _customFields.SetRecordIDForAllValues(recordID)
            Return Me.SaveCustomFields()
        Else
            Return False
        End If
    End Function

    Public Function SaveCustomFields() As Boolean
        Dim success As Boolean = False
        If Not _customFields Is Nothing Then
            success = NovaLibra.Coral.BusinessFacade.SystemCustomFields.SaveCustomFieldValues(_customFields)
        End If
        Return success
    End Function

    Protected Sub LoadValuesFromResponse()
        Dim field As CustomField
        Dim value As CustomFieldValue
        Dim controlID As String
        Dim controlValue As String
        Dim Request As System.Web.HttpRequest = Me.Context.Request
        Dim Response As System.Web.HttpResponse = Me.Context.Response
        If Not _customFields Is Nothing Then
            For Each field In _customFields.Fields
                If _customFields.ContainsValue(Me.RecordID, field.ID) Then
                    value = _customFields.GetValue(Me.RecordID, field.ID)
                Else
                    value = _customFields.AddValue(New CustomFieldValue(Me.RecordID, field))
                End If
                If Not value Is Nothing Then
                    controlID = BuildControlID(field.ID, Me.RecordID)
                    If Not Request.Form(controlID) Is Nothing Then
                        controlValue = Request.Form(controlID)
                    Else
                        controlValue = String.Empty
                    End If
                    controlValue = Request.Form(controlID)
                    value.SetFieldValue(controlValue)
                End If
            Next
        End If
    End Sub

    Protected Function BuildControlID(ByVal fieldID As Integer, ByVal recordID As Long) As String
        Return "CF_" + fieldID.ToString + "_" + recordID.ToString
    End Function



End Class


