Imports System
Imports System.ComponentModel
Imports System.Text
Imports System.Web
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports Microsoft.VisualBasic

Public Class NLChangeControl

    Private Shared _startupScripts As String = String.Empty

    Public Shared Sub Initialize(ByVal control As INLControl)
        Dim page As System.Web.UI.Page = CType(control, WebControl).Page
    End Sub

    Public Shared Sub RenderBeginChangeControl(ByVal writer As HtmlTextWriter, ByVal control As INLChangeControl)
        ' Set Change Control CSS class based on Original to Change value
        ' test to see if controls original value is different then the current value
        Dim strClass As String = String.Empty
        If control.ValueChanged Then
            strClass = " class=""nlcCCC"" "
        Else
            strClass = " class=""nlcCCC_hide"" "
        End If

        ' init
        Dim wc As WebControl = CType(control, WebControl)
        ' start container div
        writer.Write("<div id=""nlcCCC_" & wc.ID & """" & strClass & ">")
        writer.Write("<input type=""hidden"" id=""" & wc.ID & "_teaz"" value=""" & IIf(control.TreatEmptyAsZero, "1", "0") & """ />")
        writer.Write("<table border=""0"" cellpadding=""0"" cellspacing=""0""><tr><td>")

    End Sub

    Public Shared Function GetOnChangeAttribute(ByVal control As INLChangeControl) As String
        Dim wc As WebControl = CType(control, WebControl)
        Dim strAttribute As String = String.Empty
        ' FJL Feb 2010 - Change to only pass id of control as a parm.  Original value determined at run time so it can be called by client JS.
        strAttribute = String.Format("onChangeNLC('{0}');", wc.ID)

        'If wc.GetType() Is GetType(NLCheckBox) Then
        '    strAttribute = String.Format("onChangeNLC('{0}',{1});", wc.ID, IIf(Boolean.Parse(control.OriginalValue), "true", "false"))
        'ElseIf wc.GetType() Is GetType(NLDropDownList) Then
        '    strAttribute = String.Format("onChangeNLC('{0}','{1}');", wc.ID, control.OriginalValue.ToString())
        'Else
        '    strAttribute = String.Format("onChangeNLC('{0}','{1}');", wc.ID, control.OriginalValue.ToString().Replace("'", "\'"))
        'End If
        Return strAttribute

    End Function

    Public Shared Sub RenderEndChangeControl(ByVal writer As HtmlTextWriter, ByVal control As INLChangeControl)
        Dim strHideCSSClass As String = String.Empty
        If Not control.ValueChanged Then
            strHideCSSClass = " nlcHide"
        End If

        ' init
        Dim wc As WebControl = CType(control, WebControl)
        Dim restore As String = String.Empty
        Dim origVal As String = String.Empty

        If wc.GetType() Is GetType(NLCheckBox) Then
            If Not control.RenderReadOnly AndAlso control.RevertEnabled Then
                restore = String.Format("restoreNLCCB('{0}',{1});", wc.ID, IIf(Boolean.Parse(control.OriginalValue), "true", "false"))
            End If
            'origVal = IIf(Boolean.Parse(control.OriginalValue), "[checked]", "[unchecked]")
            origVal = IIf(Boolean.Parse(control.OriginalValue), "[x]", "[&nbsp;&nbsp;]")
        ElseIf wc.GetType() Is GetType(NLDropDownList) Then

            If Not control.RenderReadOnly AndAlso control.RevertEnabled Then
                restore = String.Format("restoreNLCDD('{0}','{1}');", wc.ID, control.OriginalValue.ToString())
            End If
            origVal = control.OriginalValue
            Dim ddl As NLDropDownList = CType(control, NLDropDownList)
            For i As Integer = 0 To ddl.Items.Count() - 1
                If ddl.Items(i).Value = control.OriginalValue Then
                    origVal = ddl.Items(i).Text
                    Exit For
                End If
            Next
        Else
            If Not control.RenderReadOnly AndAlso control.RevertEnabled Then
                'Have restoreNLCTB Get Orig Textbox value from _Orig hidden field rather than passing via a parameter
                'restore = String.Format("restoreNLCTB('{0}','{1}');", wc.ID, HttpContext.Current.Server.HtmlEncode(control.OriginalValue.ToString()).Replace("'", "\'"))
                restore = String.Format("restoreNLCTB('{0}');", wc.ID)
            End If
            origVal = control.OriginalValue.ToString()
        End If

        ' start change div
        writer.Write("<div id=""nlcCCOrigC_" & wc.ID & """  class=""nlcCCOrigC" & strHideCSSClass & """ >")
        ' create original value
        Dim ctrl As System.Web.UI.WebControls.HiddenField = New System.Web.UI.WebControls.HiddenField()
        ctrl.ID = wc.ID & "_ORIG"
        ctrl.Value = control.OriginalValue
        ctrl.RenderControl(writer)
        ' Create CCTracking field - xxx_CF  : Dx Initial state different. Sx Initial state is same.
        ctrl.ID = wc.ID & "_CF"
        ctrl.Value = IIf(control.ValueChanged, "Dx", "Sx")
        ctrl.RenderControl(writer)

        writer.Write("<span class=""nlcCCT"">")
        If wc.GetType() Is GetType(NLCheckBox) Then
            ' Don't HtmlEncode this so the &nbsp; turn into spaces
            writer.Write(origVal)
        Else
            writer.Write(wc.Page.Server.HtmlEncode(origVal))
        End If
        writer.Write("</span>")
        If origVal.Length = 0 Then
            writer.Write("<span >&nbsp;</span>")
        End If
        ' end change div
        writer.Write("</div>")

        writer.Write("</td><td valign=""bottom"">")

        ' create revert object if the control is not readonly
        If Not control.RenderReadOnly AndAlso control.RevertEnabled Then
            writer.Write("<div id=""nlcCCRevert_" & wc.ID & """ class=""nlcCCRevert" & strHideCSSClass & """ onclick=""" & restore & """></div>")
            'Else
            '    writer.Write("<div id=""nlcCCRevert_" & wc.ID & """ class=""nlcCCRevert nlcHide""></div>")
            'End If
        End If

        writer.Write("</td></tr></table>")

        ' end container div
        writer.Write("</div>")
    End Sub

    Public Shared Function IsEmptyOrZero(ByVal value As String) As Boolean
        If (value = "") Then
            Return True
        ElseIf IsNumeric(value) AndAlso Convert.ToDecimal(value) = 0 Then
            Return True
        Else
            Return False
        End If
    End Function

End Class
