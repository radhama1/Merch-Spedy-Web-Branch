Imports System
Imports System.Diagnostics
Imports System.Data
Imports System.Collections.generic
Imports Microsoft.VisualBasic

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks
Imports NovaLibra.Coral.SystemFrameworks.Michaels
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels


Partial Class IMPackChange

    Inherits MichaelsBasePage
    Implements System.Web.UI.ICallbackEventHandler

    Private _validFlag As ItemValidFlag = ItemValidFlag.Unknown
    Private _validWasUnknown As Boolean = False

    Private _refreshGrid As Boolean = False
    Private _closeForm As Boolean = False

    Private _callbackArg As String = ""

    ' FJL Jan 2010
    Private WorkflowStageID As Integer = 0

    Public Const CALLBACK_SEP As String = "{{|}}"

    ' Load up the Metadata for Save
    Private md As NovaLibra.Coral.SystemFrameworks.Metadata = MetadataHelper.GetMetadata()
    Private mdTable As NovaLibra.Coral.SystemFrameworks.MetadataTable
    Private mdColumn As NovaLibra.Coral.SystemFrameworks.MetadataColumn

    Private IMChanges As List(Of IMChangeRecord) = Nothing

    Public Property CloseForm() As Boolean
        Get
            Return _closeForm
        End Get
        Set(ByVal value As Boolean)
            _closeForm = value
        End Set
    End Property

    Public ReadOnly Property ItemID() As String
        Get
            Return recordID.Value
        End Get
    End Property

    Public Property RefreshGrid() As Boolean
        Get
            Return _refreshGrid
        End Get
        Set(ByVal value As Boolean)
            _refreshGrid = value
        End Set
    End Property

    Public ReadOnly Property RecordType() As Integer
        Get
            Return WebConstants.RECTYPE_DOMESTIC_ITEM
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        ' ========================================================================
        '  FJL PROTOTYPE ONLY for Item master Maint.  
        ' Request OBJECT parms passed in
        ' ItemID - From MaintItems table 
        ' SKU - SKU to edit
        ' BatchID - used to determine what batch stage we are at
        ' VendorNumber - What vendor to edit for this SKU
        ' Logic:
        '  PAGE LOAD
        '   Get Item record and use to set Current and Original Vailes
        '   Get Change Records for this SKU 
        '   for each FeildName returned
        '       Match Common on SKU (vendor = "") and BatchID: if Match then set current value. If SKU but not Batch then Lock field
        '       Match Vendor on SKU / Vendor / BatchID: If match set current value. if SKU / Vendor but not Batch then Lock field
        '       Match UPCs and COO on SKU / Vendor / counter. If match set current value. if SKU / Vendor but not Batch then Lock field

        ' ========================================================================

        If Not Page.IsCallback Then     ' NORMAL PAGE LOAD (not AJAX)
            ' check security
            'If Not SecurityCheck() Then
            'Response.Redirect("closeform.aspx?r=1")
            'End If

            'TODO: ADD THIS SECURITY
            'If Not UserManager.CanUserAddEdit() Then
            '    Response.Redirect("closeform.aspx")
            'End If

            Dim userID As Long = AppHelper.GetUserID()
            userID = 1473

            Dim vendorID As Integer = AppHelper.GetVendorID
            vendorID = 0

            If Not IsPostBack Then      ' INITAL PAGE LOAD
                ' TODO FIX THESE TO GET FROM REQUEST

                '' load record if update mode
                'If Request("hid") <> "" AndAlso IsNumeric(Request("hid")) Then
                '    hidBatchID.Value = Request("hid")
                'End If ' Request("hid")

                'If Request("r") = "1" Then
                '    RefreshGrid = True
                'End If
                ''LP 
                'If Request("close") = "1" Then
                '    CloseForm = True
                'End If
                Dim lvgs As ListValueGroups = FormHelper.LoadListValues("YESNO,ADDCHANGE,PACKITEMIND,HYBRIDTYPE,HYBRIDSOURCEDC,PREPRICEDUDA,TAXUDA,HAZCONTAINERTYPE,HAZMSDSUOM,RMS_PBL,STOCKCAT,FREIGHTTERMS,ITEMTYPE,INVCONTROL,ITEMTYPEATTRIB")
                'FormHelper.LoadListFromListValues(addChange, lvgs.GetListValueGroup("ADDCHANGE"), True)

                ' NEXT
                ' init controls

                ' NEXT
                ' setup header
                Page.Title = "Edit Item Master Record - Pack Component Change"
                lblHeading.Text = "Edit Item Master Pack Component"
                lblSubHeading.Text = "Using the fields below, edit this Item Maintenance Pack Component entry."

                LoadForm(userID, vendorID)
            End If ' is postback

        Else
        End If ' IsCallBack

        Dim cbReference As String
        cbReference = Page.ClientScript.GetCallbackEventReference(Me, "arg", _
            "ReceiveServerData", "context")
        Dim callbackScript As String = ""
        callbackScript &= "function CallServer(arg, context)" & _
            "{" & cbReference & "; }"
        Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), _
            "CallServer", callbackScript, True)

        CheckForStartupScripts()

    End Sub

    Private Sub LoadForm(ByVal userID As Integer, ByVal vendorID As Integer)
        'Dim IMCommon As NovaLibra.Coral.SystemFrameworks.Michaels.MaintItemMasterSKURecord = Nothing
        'Dim IMVendor As NovaLibra.Coral.SystemFrameworks.Michaels.MaintItemMasterVendorRecord = Nothing

        ' TODO. Get and Save this info to hidden fields
        Dim michaelsSKU As String, vendorNumber As Integer, batchID As Integer
        michaelsSKU = "10125351"
        batchID = 1000
        hidMichaelsSKU.Value = michaelsSKU
        hidBatchID.Value = batchID
        recordID.Value = 1


        vendorNumber = 2384
        hidVendorNumber.Value = vendorNumber

        'IMCommon = objMichaels.GetItemMasterCommon(michaelsSKU, userID, vendorID)
        'If (Not IMCommon Is Nothing) AndAlso IMCommon.MichaelsSKU > 0 Then

        'Else
        ' Response.Redirect("closeform.aspx")
        'End If ' Not itemHeader Is Nothing

        ' Get the Vendor portion of the Item Master Record
        'IMVendor = objMichaels.GetItemMasterVendor(michaelsSKU, vendorNumber, userID, vendorID)

        ' Get any changes associated with this Item / batch)
        'IMChanges = objMichaels.GetItemMasterChanges(michaelsSKU, batchID)
        Dim strTemp As String   ' used for special formats

        'SKU.Text = IMCommon.MichaelsSKU
        'DepartmentNum.Value = DataHelper.SmartValues(IMCommon.DepartmentNum, "string")
        'DepartmentName.Text = "Dept Name Goes here"

        'PrimaryUPC.Text = DataHelper.SmartValues(IMVendor.PrimaryUPC, "string")
        'VendorStyleNum.Text = DataHelper.SmartValues(IMVendor.VendorStyleNum, "string")
        'ItemDesc.Text = IMVendor.ItemDesc

        ' *****************************************
        ' CHANGEABLE FIELDS SET UP HERE
        ' *****************************************
        'If IMVendor.USCost <> Decimal.MinValue Then
        '    USCost.Text = CheckandSetControl(IMVendor.USCost, IMCommon.MichaelsSKU, vendorNumber, 0, USCost.ID, batchID, "formatnumber4")
        'End If

        'If IMVendor.CanadaCost <> Decimal.MinValue Then
        '    canadaCost.Text = CheckandSetControl(IMVendor.CanadaCost, IMCommon.MichaelsSKU, vendorNumber, 0, canadaCost.ID, batchID, "formatnumber4")
        'End If

        'If IMCommon.Base1Retail <> Decimal.MinValue Then
        '    Base1Retail.Text = CheckandSetControl(IMCommon.Base1Retail, IMCommon.MichaelsSKU, 0, 0, Base1Retail.ID, batchID, "formatnumber")
        'End If

        'If IMCommon.Base2Retail <> Decimal.MinValue Then
        '    Base2Retail.Text = CheckandSetControl(IMCommon.Base2Retail, IMCommon.MichaelsSKU, 0, 0, Base2Retail.ID, batchID, "formatnumber")
        'End If
        ''Base2Retail.Value = Base2Retail.Text

        'If IMCommon.TestRetail <> Decimal.MinValue Then
        '    testRetail.Text = CheckandSetControl(IMCommon.TestRetail, IMCommon.MichaelsSKU, 0, 0, testRetail.ID, batchID, "formatnumber")
        'End If
        ''testRetail.Value = testRetail.Text

        'If IMCommon.AlaskaRetail <> Decimal.MinValue Then
        '    alaskaRetail.Text = CheckandSetControl(IMCommon.AlaskaRetail, IMCommon.MichaelsSKU, 0, 0, alaskaRetail.ID, batchID, "formatnumber")
        'End If

        'If IMCommon.CanadaRetail <> Decimal.MinValue Then
        '    canadaRetail.Text = CheckandSetControl(IMCommon.CanadaRetail, IMCommon.MichaelsSKU, 0, 0, canadaRetail.ID, batchID, "formatnumber")
        'End If

        'If IMCommon.High2Retail <> Decimal.MinValue Then
        '    High2Retail.Text = CheckandSetControl(IMCommon.High2Retail, IMCommon.MichaelsSKU, 0, 0, High2Retail.ID, batchID, "formatnumber")
        'End If
        ''High2Retail.Value = High2Retail.Text

        'If IMCommon.High3Retail <> Decimal.MinValue Then
        '    High3Retail.Text = CheckandSetControl(IMCommon.High3Retail, IMCommon.MichaelsSKU, 0, 0, High3Retail.ID, batchID, "formatnumber")
        'End If
        ''High3Retail.Value = High3Retail.Text

        'If IMCommon.SmallMarketRetail <> Decimal.MinValue Then
        '    SmallMarketRetail.Text = CheckandSetControl(IMCommon.SmallMarketRetail, IMCommon.MichaelsSKU, 0, 0, SmallMarketRetail.ID, batchID, "formatnumber")
        'End If
        ''SmallMarketRetail.Value = SmallMarketRetail.Text

        'If IMCommon.High1Retail <> Decimal.MinValue Then
        '    High1Retail.Text = CheckandSetControl(IMCommon.High1Retail, IMCommon.MichaelsSKU, 0, 0, High1Retail.ID, batchID, "formatnumber")
        'End If
        ''High1Retail.Value = High1Retail.Text

        'If IMCommon.Base3Retail <> Decimal.MinValue Then
        '    Base3Retail.Text = CheckandSetControl(IMCommon.Base3Retail, IMCommon.MichaelsSKU, 0, 0, Base3Retail.ID, batchID, "formatnumber")
        'End If
        ''Base3Retail.Value = Base3Retail.Text

        'If IMCommon.Low1Retail <> Decimal.MinValue Then
        '    Low1Retail.Text = CheckandSetControl(IMCommon.Low1Retail, IMCommon.MichaelsSKU, 0, 0, Low1Retail.ID, batchID, "formatnumber")
        'End If
        ''Low1Retail.Value = Low1Retail.Text

        'If IMCommon.Low2Retail <> Decimal.MinValue Then
        '    Low2Retail.Text = CheckandSetControl(IMCommon.Low2Retail, IMCommon.MichaelsSKU, 0, 0, Low2Retail.ID, batchID, "formatnumber")
        'End If
        ''Low2Retail.Value = Low2Retail.Text

        'If IMCommon.ManhattanRetail <> Decimal.MinValue Then
        '    ManhattanRetail.Text = CheckandSetControl(IMCommon.ManhattanRetail, IMCommon.MichaelsSKU, 0, 0, ManhattanRetail.ID, batchID, "formatnumber")
        'End If
        ''ManhattanRetail.Value = ManhattanRetail.Text

        ' Now Get any additionalCOOS  from Change Records. 
        'Note that since change records can be deleted, the changerec counter can be different than the physical count.
        'Dim ChangeRec As MaintItemMasterChangesRecord
        'Dim i As Integer, maxCnt As Integer = controlCounter
        'Dim numChangeCOOs As Integer = objMichaels.GetCountForField(IMCommon.MichaelsSKU, vendorNumber, COOName, IMChanges)

        'For i = 1 To numChangeCOOs
        '    ChangeRec = objMichaels.GetNextCountForField(IMCommon.MichaelsSKU, vendorNumber, maxCnt, COOName, IMChanges)
        '    If ChangeRec.MichaelsSKU <> "" Then     ' match found. Add a form field
        '        Dim nlTextbox As NovaLibra.Controls.NLTextBox
        '        nlTextbox = AddChangeControlTB(COOName, ChangeRec.Counter.ToString, controlCounter, additionalCOOPlaceHolder.ID)
        '        ' use special case of CheckandSetControl since this has no ItemMaster Record
        '        nlTextbox.Text = CheckandSetControl(ChangeRec.NewValue, IMCommon.MichaelsSKU, vendorNumber, ChangeRec.Counter, COOName, nlTextbox.ID, batchID, , False)
        '        controlCounter += 1
        '        maxCnt = ChangeRec.Counter + 1
        '    Else
        '        Exit For
        '    End If
        'Next

        '' Create an empty Country of Origin Control
        'Dim COOString As String = String.Empty
        'COOString += "<input type=""text"" id=""" & COOName & maxCnt.ToString & """ name=""" & COOName & maxCnt.ToString & """ maxlength=""50"" value="""" /><sup>" & controlCounter.ToString & "</sup>"
        'additionalCOOs.Text = COOString
        'additionalCOOCount.Value = controlCounter.ToString
        'additionalCOOStart.Value = maxCnt   ' used by javascript to force autocompleter on
        'additionalCOOEnd.Value = maxCnt     ' this field hold the max count of addtional COOs that exist when the page is saved

        '' Create set of controls for any existing Additional UPCs
        'Dim addUPCRec As ItemMasterVendorUPCRecord
        'Dim UPCName As String = "UPC"
        'controlCounter = 1
        'For Each addUPCRec In IMVendor.GetAddUPCRecords
        '    Dim nlTextbox As NovaLibra.Controls.NLTextBox '= New NovaLibra.Controls.NLTextBox
        '    nlTextbox = AddChangeControlTB(UPCName, addUPCRec.Counter.ToString, controlCounter, additionalUPCPlaceholder.ID)
        '    nlTextbox.Text = CheckandSetControl(addUPCRec.UPC, IMCommon.MichaelsSKU, vendorNumber, addUPCRec.Counter, UPCName, nlTextbox.ID, batchID)
        '    nlTextbox.Attributes.Add("onchange", "additionalUPCChanged('" & (controlCounter.ToString) & "');")
        '    controlCounter += 1
        'Next

        '' Now Get any additional UPCs from Change Records
        ''Note that since change records can be deleted, the changerec counter can be different than the physical count.
        'maxCnt = controlCounter
        'Dim numChangeUPCs As Integer = objMichaels.GetCountForField(IMCommon.MichaelsSKU, vendorNumber, UPCName, IMChanges)

        'For i = 1 To numChangeUPCs
        '    ChangeRec = objMichaels.GetNextCountForField(IMCommon.MichaelsSKU, vendorNumber, maxCnt, UPCName, IMChanges)
        '    If ChangeRec.MichaelsSKU <> "" Then     ' match found. Add a form field
        '        Dim nlTextbox As NovaLibra.Controls.NLTextBox
        '        nlTextbox = AddChangeControlTB(UPCName, ChangeRec.Counter.ToString, controlCounter, additionalUPCPlaceholder.ID)
        '        ' use special case of CheckandSetControl since this has no ItemMaster Record
        '        nlTextbox.Text = CheckandSetControl(ChangeRec.NewValue, IMCommon.MichaelsSKU, vendorNumber, ChangeRec.Counter, UPCName, nlTextbox.ID, batchID, , False)
        '        nlTextbox.Attributes.Add("onchange", "additionalUPCChanged('" & (ChangeRec.Counter.ToString) & "');")
        '        controlCounter += 1
        '        maxCnt = ChangeRec.Counter + 1
        '    Else
        '        Exit For
        '    End If
        'Next

        '' Create an empty Add UPC Control
        'Dim UPCstring As String = String.Empty
        'UPCstring += "<input type=""text"" id=""" & UPCName & maxCnt.ToString & """ name=""" & UPCName & maxCnt.ToString & _
        '    """ onchange=""additionalUPCChanged(" & (maxCnt.ToString) & ");"" maxlength=""20"" value="""" /><sup>" & controlCounter.ToString & "</sup>"
        'additionalUPCs.Text = UPCstring     ' put the html into the placeholder
        'additionalUPCCount.Value = controlCounter.ToString
        'additionalUPCEnd.Value = maxCnt     ' used to determine next / last control generated



        'End If ' objRecord.ID > 0
        'IMVendor = Nothing
        'IMCommon = Nothing
        'End If ' id > 0

        'If hid.Value <> "" And ID > 0 Then
        '    validFlagDisplay.Text = ValidationHelper.GetValidationDisplayString(_validFlag, True)
        'End If

        ' Turn off Save for prototype
        ' If Session("edit") <> "Y" Then
        'btnUpdate.Visible = False
        'btnUpdate.Enabled = False
        btnUpdateClose.Visible = False
        btnUpdateClose.Enabled = False
        ' End If

        '  ImplementFieldLocking(itemFL)

        '' custom fields
        'Me.custFields.RecordType = Me.RecordType
        '' TODO FIX THIS >>>  Me.custFields.RecordID = DataHelper.SmartValues(recordID.Value, "long", False)
        'Me.custFields.DisplayTemplate = "<tr><td class=""formLabel"">##NAME##:</td><td class=""formField"">##VALUE##</td></tr>"
        'Me.custFields.Columns = 30
        'Me.custFields.LoadCustomFields(True)

        ' clean up 
        Dim itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking
        'itemFL = objMichaels.GetItemFieldLocking(AppHelper.GetUserID(), AppHelper.GetVendorID, WorkflowStageID)
        itemFL = Nothing

        'objMichaels = Nothing


    End Sub

    Private Function AddChangeControlTB(ByVal CtlName As String, ByVal index As String, ByVal ctlCtr As Integer, ByVal phID As String) As NovaLibra.Controls.NLTextBox
        Dim nlTextbox As NovaLibra.Controls.NLTextBox = New NovaLibra.Controls.NLTextBox
        Dim sup As New HtmlGenericControl("div")
        Dim ph As PlaceHolder
        ph = FindControl(phID)
        sup.InnerHtml = "<sup>" & ctlCtr.ToString & "</sup>"
        nlTextbox.ChangeControl = True
        nlTextbox.MaxLength = 50
        nlTextbox.ID = CtlName & index
        ph.Controls.Add(nlTextbox)
        ph.Controls.Add(sup)
        Dim div1 As New HtmlGenericControl("div")
        div1.Attributes.Add("style", "clear:both;")     'force next control to be below this one
        div1.InnerHtml = "<img src=""images/spacer.gif"" width=""1"" height=""2"" alt="""" />"
        ph.Controls.Add(div1)
        Return nlTextbox
    End Function

    ' Overloaded function. Called when both the Changes table Fieldname (changeField)and the form ControlID (ctlID) are the same
    Private Function CheckandSetControl(ByVal IMValue As Object, ByVal SKU As String, ByVal vendorNum As Integer, ByVal counter As Integer, _
        ByVal ctlID As String, ByVal batchID As Integer, Optional ByVal formatStr As String = "") As Object

        Return CheckandSetControl(IMValue, SKU, vendorNum, counter, ctlID, ctlID, batchID, formatStr)

    End Function

    Private Function CheckandSetControl(ByVal IMValue As Object, ByVal SKU As String, ByVal vendorNum As Integer, ByVal counter As Integer, _
        ByVal changeField As String, ByVal ctlID As String, ByVal batchID As Integer, _
            Optional ByVal formatStr As String = "", Optional ByVal Check As Boolean = True) As Object

        '    Dim ctlCC As NovaLibra.Controls.INLChangeControl  ' interface to a Nova Libra Change control 
        '    Dim retValue As String
        '    Dim objRecord As MaintItemMasterChangesRecord

        '    ' Find a matching Change Record
        '    'objRecord = objMichaels.FindIMChangeRecord(SKU, vendorNum, counter, changeField, IMChanges)
        '    ' Check is false that means its a new control only (Additional UPCs and COOs that only exist in the ChangeRec)
        '    If Check Then
        '        If objRecord.MichaelsSKU <> "" Then     ' match found. 
        '            '       retValue = objRecord.NewValue.ToString
        '        Else
        '            retValue = IMValue.ToString
        '        End If
        '    Else
        '        retValue = IMValue.ToString
        '    End If

        '    ' Set the properties of the Change control if found
        '    Try
        '        ctlCC = FindControl(ctlID)
        '    Catch
        '        ctlCC = Nothing
        '    End Try
        '    If Not ctlCC Is Nothing Then
        '        If Check Then
        '            If formatStr.Length > 0 Then
        '                ctlCC.OriginalValue = DataHelper.SmartValues(IMValue, formatStr)
        '            Else
        '                ctlCC.OriginalValue = IMValue       ' set the original value to the Item Master record
        '            End If
        '        Else
        '            ctlCC.OriginalValue = ""            ' set the original value as empty since it does not exist in Item Master Record
        '        End If
        '        If objRecord.MichaelsSKU <> "" AndAlso 1 = 1 Then ' objRecord.MaintenanceBatchID <> batchID Then    ' rec Found but does not belong to this batch. Set the control renderreadonly on
        '            ctlCC.RenderReadOnly = True
        '            Dim ctl As System.Web.UI.WebControls.WebControl
        '            Try
        '                ctl = FindControl(ctlID)
        '            Catch
        '                ctl = Nothing
        '            End Try
        '            If Not ctl Is Nothing Then
        '                ctl.ToolTip = "This field was changed in Batch: " '& objRecord.MaintenanceBatchID.ToString
        '            End If
        '        End If
        '    End If

        '    If formatStr.Length > 0 Then retValue = DataHelper.SmartValues(retValue, formatStr)
        '    Return retValue
    End Function

    Private Sub ImplementFieldLocking(ByRef itemFL As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking)
        For Each col As NovaLibra.Coral.SystemFrameworks.Michaels.MetadataColumn In itemFL.Columns
            LockField(col.ColumnName, col.Permission)
        Next
    End Sub

    Public Overrides Sub LockField(ByVal colName As String, ByVal permission As Char)
        Select Case UCase(permission)
            Case "N"            ' Hide Control
                Select Case colName

                    Case Else   ' dynamic control of fields 
                        Dim control As Control = Me.FindControl(colName)    ' First try the colName
                        If control Is Nothing Then
                            colName = Replace(colName, "_", "")             ' Then try w/o any _ in the name
                            control = Me.FindControl(colName)
                            If control Is Nothing Then
                                Return
                            End If
                        End If
                        ' First Hide any td FL assoc with control   ex controlNameFL
                        Dim htmlTD As HtmlTableCell = Me.FindControl(colName + "FL")
                        If Not (htmlTD Is Nothing) Then
                            ' htmlTD.InnerHtml = "&nbsp;"
                            htmlTD.Attributes.Add("style", "display:none")
                        End If
                        ' Hide any td Parent assoc with control OR the control if no parent. ex controlNameParent
                        htmlTD = Me.FindControl(colName + "Parent")
                        If Not (htmlTD Is Nothing) Then
                            htmlTD.Attributes.Add("style", "display:none")
                        Else
                            control.Visible = False
                        End If
                End Select

            Case "V"
                Select Case colName
                    Case Else   ' dynamic control of fields 
                        Dim control As Control = Me.FindControl(colName)    ' First try the colName
                        If control Is Nothing Then
                            colName = Replace(colName, "_", "")             ' Then try w/o any _ in the name
                            control = Me.FindControl(colName)
                            If control Is Nothing Then
                                Return
                            End If
                        End If
                        If Not (TypeOf control Is HiddenField) Then
                            Try
                                Dim NLControl As NovaLibra.Controls.INLChangeControl
                                NLControl = CType(control, NovaLibra.Controls.INLChangeControl)
                                NLControl.RenderReadOnly = True
                            Catch
                            End Try
                        End If
                End Select
            Case Else   ' Edit: Do nothing
        End Select

    End Sub

#Region "Scripts"
    Private Sub CheckForStartupScripts()
        Dim startupScriptKey As String = "__detail_form_"
        If Request("r") = "1" AndAlso Not Me.Page.ClientScript.IsStartupScriptRegistered(startupScriptKey) Then
            CreateStartupScripts(startupScriptKey)
        End If
    End Sub

    Private Sub CreateStartupScripts(ByVal startupScriptKey As String)

        Dim sb As New StringBuilder("")
        sb.Length = 0
        sb.Append("" & vbCrLf)
        sb.Append("<script language=""javascript"" type=""text/javascript"">" & vbCrLf)
        sb.Append("<!--" & vbCrLf)

        sb.Append("refreshItemGrid();" & vbCrLf)

        sb.Append("//-->" & vbCrLf)
        sb.Append("</script>" & vbCrLf)
        Me.ClientScript.RegisterStartupScript(Me.GetType(), startupScriptKey, sb.ToString())
    End Sub
#End Region

    Private Function FormatFormNumber(ByVal inputValue As Decimal) As String
        If inputValue <> Decimal.MinValue Then
            Return DataHelper.SmartValues(inputValue, "FormatNumber")
        Else
            Return String.Empty
        End If
    End Function

    Private Function FormatFormDate(ByVal inputValue As Date) As String
        If inputValue <> Date.MinValue Then
            Return inputValue.ToShortDateString()
        Else
            Return String.Empty
        End If
    End Function

#Region "Callbacks"

    Public Function GetCallbackResult() As String Implements System.Web.UI.ICallbackEventHandler.GetCallbackResult
        Dim str As String() = Split(_callbackArg, CALLBACK_SEP)
        If str.Length <= 0 Then
            Return ""
        End If
        Select Case str(0)
            Case "ECPC"
                ' each case pack cube
                If str.Length < 5 Then
                    Return "ECPC" & CALLBACK_SEP & "0"
                End If
                Return "ECPC" & CALLBACK_SEP & "1" & CALLBACK_SEP & CalculationHelper.CalculateItemCasePackCube(str(1), str(2), str(3), str(4))
            Case "ICPC"
                ' inner case pack cube
                If str.Length < 5 Then
                    Return "ICPC" & CALLBACK_SEP & "0"
                End If
                Return "ICPC" & CALLBACK_SEP & "1" & CALLBACK_SEP & CalculationHelper.CalculateItemCasePackCube(str(1), str(2), str(3), str(4))
            Case "MCPC"
                ' master case pack cube
                If str.Length < 5 Then
                    Return "MCPC" & CALLBACK_SEP & "0"
                End If
                Return "MCPC" & CALLBACK_SEP & "1" & CALLBACK_SEP & CalculationHelper.CalculateItemCasePackCube(str(1), str(2), str(3), str(4))
            Case "ConversionDate"
                ' conversion date
                If str.Length < 2 Then
                    Return "ConversionDate" & CALLBACK_SEP & "0"
                End If
                Dim leadTime As Integer = DataHelper.SmartValues(str(1), "integer", True)
                Return "ConversionDate" & CALLBACK_SEP & "1" & CALLBACK_SEP & CalculationHelper.CalculateConversionDate(leadTime)
            Case "Retail"
                ' retail values
                If str.Length < 5 Then
                    Return "Retail" & CALLBACK_SEP & "0"
                End If
                Dim prePriced As String = DataHelper.SmartValues(str(2), "string", False)
                Dim Base1Retail As Decimal = DataHelper.SmartValues(str(3).Replace(",", "").Replace("$", ""), "decimal", True)
                Dim alaskaRetail As Decimal = DataHelper.SmartValues(str(4).Replace(",", "").Replace("$", ""), "decimal", True)
                Dim resultBase As String = String.Empty
                Dim resultAlaska As String = String.Empty
                If Base1Retail <> Decimal.MinValue Then
                    resultBase = DataHelper.SmartValues(Base1Retail, "formatnumber", False, String.Empty, 2)
                    If prePriced = "Y" Then
                        resultAlaska = resultBase
                    Else
                        ' price point lookup
                        Dim objRecord As PricePointRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupAlaskRetailFromBaseRetail(Base1Retail)
                        If Not objRecord Is Nothing AndAlso objRecord.DiffRetail <> Decimal.MinValue Then
                            resultAlaska = DataHelper.SmartValues(objRecord.DiffRetail, "formatnumber", False, String.Empty, 2)
                        Else
                            If alaskaRetail <> Decimal.MinValue Then
                                resultAlaska = DataHelper.SmartValues(alaskaRetail, "formatnumber", False, String.Empty, 2)
                            End If
                        End If
                    End If
                End If
                Return "Retail" & CALLBACK_SEP & "1" & CALLBACK_SEP & str(1) & CALLBACK_SEP & resultBase & CALLBACK_SEP & resultAlaska
            Case "RetailAlaska"
                ' canada retail value
                If str.Length < 2 Then
                    Return "RetailAlaska" & CALLBACK_SEP & "0"
                End If
                Dim baseAlaska As Decimal = DataHelper.SmartValues(str(1).Replace(",", "").Replace("$", ""), "decimal", True)
                Dim resultAlaska As String = String.Empty
                If baseAlaska <> Decimal.MinValue Then
                    resultAlaska = DataHelper.SmartValues(baseAlaska, "formatnumber", False, String.Empty, 2)
                End If
                Return "RetailAlaska" & CALLBACK_SEP & "1" & CALLBACK_SEP & resultAlaska
            Case "RetailCanada"
                ' canada retail value
                If str.Length < 2 Then
                    Return "RetailCanada" & CALLBACK_SEP & "0"
                End If
                Dim baseCanada As Decimal = DataHelper.SmartValues(str(1).Replace(",", "").Replace("$", ""), "decimal", True)
                Dim resultCanada As String = String.Empty
                If baseCanada <> Decimal.MinValue Then
                    resultCanada = DataHelper.SmartValues(baseCanada, "formatnumber", False, String.Empty, 2)
                End If
                Return "RetailCanada" & CALLBACK_SEP & "1" & CALLBACK_SEP & resultCanada

                ' Following case NOT USED 
                'Case "PrimaryCountryOfOrigin"
                '    ' Country Of Origin value
                '    If str.Length < 2 Then
                '        Return "PrimaryCountryOfOrigin" & CALLBACK_SEP & "0"
                '    End If
                '    Dim country As String = str(1)
                '    Dim retString As String
                '    Dim objCountry As CountryRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupCountry(country)
                '    If Not objCountry Is Nothing AndAlso objCountry.CountryName <> String.Empty AndAlso objCountry.CountryCode <> String.Empty Then
                '        retString = "PrimaryCountryOfOrigin" & CALLBACK_SEP & "1" & CALLBACK_SEP & objCountry.CountryName & CALLBACK_SEP & objCountry.CountryCode
                '    Else
                '        retString = "PrimaryCountryOfOrigin" & CALLBACK_SEP & "1" & CALLBACK_SEP & "" & CALLBACK_SEP & ""
                '    End If
                '    objCountry = Nothing
                '    Return retString

            Case "DELETEIMAGE", "DELETEMSDS"
                ' TODO FIX THIS
                'If str.Length < 3 Then
                '    Return str(0) & CALLBACK_SEP & "0"
                'End If
                'Dim thisItemID As Long = DataHelper.SmartValues(str(1), "long", True)
                'Dim fileID As Long = DataHelper.SmartValues(str(2), "long", True)
                'If thisItemID = Long.MinValue Or thisItemID < 0 Or fileID = Long.MinValue Or fileID < 0 Then
                '    Return str(0) & CALLBACK_SEP & "0"
                'End If
                'Dim objFile As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemFile()
                'Dim bRet As Boolean = objFile.DeleteRecord(ItemType.ITEM_TYPE_DOMESTIC, thisItemID, fileID)
                'objFile = Nothing

                '' audit
                'Dim objFA As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFieldAuditing()
                'Dim audit As New Models.AuditRecord()
                'audit.SetupAudit(Models.MetadataTable.Items, thisItemID, Models.AuditRecordType.Update, CInt(Session("UserID")))
                'If str(0) = "DELETEMSDS" Then
                '    audit.AddAuditField("MSDS_File_ID", String.Empty)
                'Else
                '    audit.AddAuditField("Product_Image_File_ID", String.Empty)
                'End If
                'objFA.SaveAuditRecord(audit)
                'objFA = Nothing
                'audit = Nothing
                '' end audit
                'If bRet Then
                '    Return str(0) & CALLBACK_SEP & "1" & CALLBACK_SEP & thisItemID & CALLBACK_SEP & fileID
                'Else
                '    Return str(0) & CALLBACK_SEP & "0"
                'End If

                ' NOT NEEDED
                'Case "LikeItemSKU"
                '    ' retail values
                '    If str.Length < 2 Then
                '        Return "LikeItemSKU" & CALLBACK_SEP & "0"
                '    End If
                '    Dim item As String = DataHelper.SmartValues(str(1), "string", False)
                '    Dim resultItemDesc As String = String.Empty
                '    Dim resultBase1Retail As String = String.Empty
                '    If item <> String.Empty Then
                '        Dim objRecord As ItemMasterRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupItemMaster(item)
                '        If Not objRecord Is Nothing AndAlso (objRecord.ItemDescription <> String.Empty Or objRecord.Base1Retail <> Decimal.MinValue) Then
                '            resultItemDesc = objRecord.ItemDescription
                '            If objRecord.Base1Retail <> Decimal.MinValue Then
                '                resultBase1Retail = DataHelper.SmartValues(objRecord.Base1Retail, "formatnumber", True, String.Empty, 2)
                '            End If
                '        End If
                '        objRecord = Nothing
                '    End If
                '    Return "LikeItemSKU" & CALLBACK_SEP & "1" & CALLBACK_SEP & item & CALLBACK_SEP & resultItemDesc & CALLBACK_SEP & resultBase1Retail
        End Select

        ' Check for Dynamic parms (AdditionCOO)
        If Left(str(0), 13) = "additionalCOO" Then  'CountryOfOrigin
            ' additionalCOO
            ' 12345678901234567    
            ' Country Of Origin value
            If str.Length < 2 Then
                Return str(0) & CALLBACK_SEP & "0"
            End If
            Dim country As String = str(1)
            Dim retString As String
            Dim objCountry As CountryRecord = NovaLibra.Coral.BusinessFacade.Michaels.MichaelsBatch.LookupCountry(country)
            If Not objCountry Is Nothing AndAlso objCountry.CountryName <> String.Empty AndAlso objCountry.CountryCode <> String.Empty Then
                retString = str(0) & CALLBACK_SEP & "1" & CALLBACK_SEP & objCountry.CountryName & CALLBACK_SEP & objCountry.CountryCode
            Else
                retString = str(0) & CALLBACK_SEP & "1" & CALLBACK_SEP & "" & CALLBACK_SEP & ""
            End If
            objCountry = Nothing
            Return retString

        End If

        Return ""
    End Function

    Public Sub RaiseCallbackEvent(ByVal eventArgument As String) Implements System.Web.UI.ICallbackEventHandler.RaiseCallbackEvent
        _callbackArg = eventArgument
    End Sub

#End Region

    Public Function GetCurrentUser() As CurrentUser
        Dim objUser As CurrentUser
        If Not Session(WebConstants.SESSION_CURRENT_USER) Is Nothing Then
            objUser = CType(Session(WebConstants.SESSION_CURRENT_USER), CurrentUser)
        Else
            objUser = New CurrentUser()
        End If
        Return objUser
    End Function

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdate.Click
        Dim saveID As Long = SaveFormData()
        If saveID > 0 Then
            ' TODO FIX THIS Response.Redirect("MaintDetailform.aspx?r=1&hid=" & DataHelper.SmartValues(hid.Value, "long", False) & "&id=" & saveID)
        End If
    End Sub

    Protected Sub btnUpdateClose_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnUpdateClose.Click
        Dim saveID As Boolean = SaveFormData()
        If saveID > 0 Then
            'LP change here in order to refresh parent from grid             
            ' TODO FIX THIS Response.Redirect("detailform.aspx?r=1&close=1&hid=" & DataHelper.SmartValues(hid.Value, "long", False) & "&id=" & saveID)
            'Response.Redirect("closeform.aspx?r=1&hid=" & DataHelper.SmartValues(hid.Value, "long", False) & "&id=" & saveID)
        End If
    End Sub

    ' Check and Save: Check a control for a ChangeControl Flag  and Save accordingly.
    Private Function CheckandSave(ByVal ctlName As String, _
        ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.IMChangeRecord, _
        ByVal newValue As String, _
        Optional ByVal ChangeFlag As String = "") As Boolean

        Dim ctlCF As String, cFValue As String = ""
        Dim isOK As Boolean = False
        If ChangeFlag = "" Then         ' see if Change Control Flag exists
            ctlCF = ctlName + "_CF"
            If Request.Form(ctlCF) IsNot Nothing Then
                cFValue = UCase(Request.Form(ctlCF))
                isOK = True
            Else
                isOK = False
            End If
        Else
            cFValue = ChangeFlag        ' Use the flag passed in rather than checking here
            isOK = True
        End If

        If (isOK AndAlso (cFValue = "SC" Or cFValue = "DC" Or cFValue = "DR")) Then    ' Need to save the update
            'objRecord.NewValue = newValue
            mdColumn = mdTable.GetColumnByName(ctlName)     ' Find the fieldname to use for this save
            If mdColumn IsNot Nothing Then
                objRecord.FieldName = mdColumn.ColumnName
                'Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsMaintItemMasterDetail()
                'isOK = objMichaels.SaveChanges(objRecord, AppHelper.GetUserID(), cFValue)
            Else
                Throw New ArgumentException("Field " & ctlName & " not found in MetaData During Item Maint Save.")
                isOK = False    ' Need to save but could not find field name in metadatacolum. trouble
            End If
        End If

        Return isOK

    End Function

    Private Function SaveFormData() As Boolean
        Dim id As Long = 0
        Dim userID As Integer = Session("UserID")
        Dim changeFlag As String = "", ctlFlag As String
        Dim changeRec As NovaLibra.Coral.SystemFrameworks.Michaels.IMChangeRecord = _
            New NovaLibra.Coral.SystemFrameworks.Michaels.IMChangeRecord

        ' Set up ChangeRec for Item Master Common field changes
        'changeRec.MichaelsSKU = hidMichaelsSKU.Value
        'changeRec.VendorNumber = 0
        ''changeRec.Counter = 0
        ''changeRec.MaintenanceBatchID = hidBatchID.Value

        ''TODO - VALIDATION NEEDS TO BE DONE FIRST. ALSO NEED TO LOOK UP ANY ADDITIONAL COUNTRY CODES

        'mdTable = md.GetTableByName("SPD_Item_Master_Common")   ' Global variable
        '' Start Save

        '' Set up ChangeRec for Item Master Vendor field changes
        ''----------------------------------------------------------------------------------------------------
        'changeRec.VendorNumber = hidVendorNumber.Value
        'mdTable = md.GetTableByName("SPD_Item_Master_Vendor")   ' Global variable

        ''CheckandSave(USCost.ID, changeRec, DataHelper.SmartValues(USCost.Text.Replace("$", "").Replace(",", ""), "decimal", True))
        ''CheckandSave(canadaCost.ID, changeRec, DataHelper.SmartValues(canadaCost.Text.Replace("$", "").Replace(",", ""), "decimal", True))

        'changeRec = Nothing
        'LoadForm(AppHelper.GetUserID(), AppHelper.GetVendorID())

    End Function

End Class
