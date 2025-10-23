Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Diagnostics
Imports System.IO
Imports System.Reflection
Imports System.Text
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Collections.Generic

Imports Microsoft.VisualBasic

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels
Imports Data = NovaLibra.Coral.Data.Michaels


Public Class FormHelper

    Public Const DEFAULT_BLANK_VALUE As String = ""
    Public Const DEFAULT_TEXT_CONTINUE As String = "..."

    Public Shared Function LoadListValues(ByVal listValueGroupNames As String) As ListValueGroups
        Dim lvgs As ListValueGroups = SystemListValues.GetListValueGroups(listValueGroupNames)
        Return lvgs
    End Function

    Public Shared Sub LoadListFromListValues(ByRef listControl As DropDownList, ByRef lvgs As ListValueGroups, ByVal listValueGroupName As String, ByVal blankFirstItem As Boolean, ByVal firstItemText As String, ByVal initialValue As String, ByVal displayTextLimit As Integer)
        LoadListFromListValues(listControl, lvgs.GetListValueGroup(listValueGroupName), blankFirstItem, firstItemText, initialValue, displayTextLimit)
    End Sub

    Public Shared Sub LoadListFromListValues(ByRef listControl As DropDownList, ByRef lvgs As ListValueGroups, ByVal listValueGroupName As String, ByVal blankFirstItem As Boolean, ByVal firstItemText As String, ByVal initialValue As String)
        LoadListFromListValues(listControl, lvgs.GetListValueGroup(listValueGroupName), blankFirstItem, firstItemText, initialValue)
    End Sub

    Public Shared Sub LoadListFromListValues(ByRef listControl As DropDownList, ByRef lvgs As ListValueGroups, ByVal listValueGroupName As String, ByVal blankFirstItem As Boolean, ByVal firstItemText As String)
        LoadListFromListValues(listControl, lvgs.GetListValueGroup(listValueGroupName), blankFirstItem, firstItemText)
    End Sub

    Public Shared Sub LoadListFromListValues(ByRef listControl As DropDownList, ByRef lvgs As ListValueGroups, ByVal listValueGroupName As String, ByVal blankFirstItem As Boolean)
        LoadListFromListValues(listControl, lvgs.GetListValueGroup(listValueGroupName), blankFirstItem)
    End Sub

    Public Shared Sub LoadListFromListValues(ByRef listControl As DropDownList, ByRef lvgs As ListValueGroups, ByVal listValueGroupName As String)
        LoadListFromListValues(listControl, lvgs.GetListValueGroup(listValueGroupName))
    End Sub

    Public Shared Sub LoadListFromListValues(ByRef listControl As DropDownList, ByRef lvg As ListValueGroup)
        LoadListFromListValues(listControl, lvg, False, "", "", 0)
    End Sub

    Public Shared Sub LoadListFromListValues(ByRef listControl As DropDownList, ByRef lvg As ListValueGroup, ByVal blankFirstItem As Boolean)
        LoadListFromListValues(listControl, lvg, blankFirstItem, "", "", 0)
    End Sub

    Public Shared Sub LoadListFromListValues(ByRef listControl As DropDownList, ByRef lvg As ListValueGroup, ByVal blankFirstItem As Boolean, ByVal firstItemText As String)
        LoadListFromListValues(listControl, lvg, blankFirstItem, firstItemText, "", 0)
    End Sub

    Public Shared Sub LoadListFromListValues(ByRef listControl As DropDownList, ByRef lvg As ListValueGroup, ByVal blankFirstItem As Boolean, ByVal firstItemText As String, ByVal initialValue As String)
        LoadListFromListValues(listControl, lvg, blankFirstItem, firstItemText, initialValue, 0)
    End Sub

    Public Shared Sub LoadListFromListValues(ByRef listControl As DropDownList, ByRef lvg As ListValueGroup, ByVal blankFirstItem As Boolean, ByVal firstItemText As String, ByVal initialValue As String, ByVal displayTextLimit As Integer)
        Dim lv As ListValue
        Dim dt As String
        listControl.Items.Clear()
        For i As Integer = 0 To lvg.ListValueCount - 1
            lv = lvg.ListValues.Item(i)
            dt = GetListValueDisplayText(lv.Value, lv.DisplayText, displayTextLimit)
            listControl.Items.Add(New ListItem(dt, lv.Value))
        Next
        If blankFirstItem Then
            listControl.Items.Insert(0, New ListItem(CType(IIf(firstItemText <> "", firstItemText, DEFAULT_BLANK_VALUE), String), ""))
        End If
        If initialValue <> "" Then
            listControl.SelectedValue = initialValue
        End If
    End Sub

    Public Shared Function GetListValueDisplayText(ByVal value As String, ByVal displayText As String, ByVal displayTextLimit As Integer) As String
        Dim dt As String
        If displayText.Trim() = "" Then
            dt = value
        Else
            dt = (value & " - " & displayText)
        End If
        If displayTextLimit > 0 Then
            If dt.Length > displayTextLimit Then
                dt = dt.Substring(0, displayTextLimit) & DEFAULT_TEXT_CONTINUE
            End If
        End If
        Return dt
    End Function

    Public Shared Function GetAlphaChars(ByVal inputString As String) As String
        Return GetAlphaChars(inputString, String.Empty)
    End Function

    Public Shared Function GetAlphaChars(ByVal inputString As String, ByVal otherValidCharacters As String) As String
        Dim returnString As String = String.Empty
        Dim charArr As Char()
        If inputString.Length > 0 Then
            charArr = inputString.ToCharArray()
            For Each c As Char In charArr
                If ValidationHelper.IsAlpha(c) Then
                    ' valid char
                    returnString += c
                Else
                    ' check for other valid characters
                    If otherValidCharacters.Length > 0 AndAlso otherValidCharacters.IndexOf(c) >= 0 Then
                        returnString += c
                    End If
                End If
            Next
        End If
        Return returnString
    End Function


    Public Shared Function RenderControl(ByRef ctrl As Control) As String
        Dim sb As New StringBuilder()
        Dim tw As New StringWriter(sb)
        Dim hw As New HtmlTextWriter(tw)
        ctrl.RenderControl(hw)
        Dim retString As String = sb.ToString()
        hw = Nothing : tw = Nothing : sb = Nothing
        Return retString
    End Function

    ' *** WORKING WITH OBJECTS USING REFLECTION ***

    Public Shared Function HasProperty(ByRef obj As Object, ByVal propertyName As String) As Boolean
        Dim t As Type = obj.GetType()
        Dim propInfo As PropertyInfo = t.GetProperty(propertyName)
        If propInfo Is Nothing Then
            Return False
        Else
            Return True
        End If
    End Function

    Public Shared Function GetObjectValue(ByRef obj As Object, ByRef column As MetadataColumn) As Object
        Return GetObjectValue(obj, column, False)
    End Function

    Public Shared Function GetObjectValue(ByRef obj As Object, ByRef column As MetadataColumn, ByVal convertType As Boolean) As Object
        Dim value As Object = Nothing
        If Not column Is Nothing Then
            If convertType AndAlso column.GenericType <> column.Format Then
                value = DataHelper.SmartValues(GetObjectValue(obj, column.ColumnName.Replace("_", "")), column.Format, True)
            Else
                value = GetObjectValue(obj, column.ColumnName.Replace("_", ""))
            End If
        End If
        Return value
    End Function

    Public Shared Function GetObjectValue(ByRef obj As Object, ByVal propertyName As String) As Object
        Dim value As Object = Nothing
        If propertyName <> String.Empty Then
            ' get the class type
            Dim t As Type = obj.GetType()
            ' get the property info 
            Dim propInfo As PropertyInfo = t.GetProperty(propertyName)
            ' get the value
            If propInfo IsNot Nothing Then
                value = propInfo.GetValue(obj, Nothing)
            End If
        End If
        ' return the value
        Return value
    End Function


    Public Shared Function FindIMChangeRecord(ByRef IMChanges As List(Of Models.IMChangeRecord), ByVal ID As Integer, ByVal FieldName As String, _
            Optional ByVal CountryOfOrigin As String = "", Optional ByVal UPC As String = "", Optional ByVal EffectiveDate As String = "", _
            Optional ByVal counter As Integer = 0) As Models.IMChangeRecord

        For Each item As Models.IMChangeRecord In IMChanges
            If item.ItemID = ID _
                AndAlso item.FieldName.ToUpper = FieldName.ToUpper _
                AndAlso item.CountryOfOrigin.ToUpper = CountryOfOrigin.ToUpper _
                AndAlso item.UPC = UPC _
                AndAlso item.EffectiveDate = EffectiveDate _
                AndAlso item.Counter = counter Then
                Return item
            End If
        Next
        Dim objRecord As Models.IMChangeRecord = New Models.IMChangeRecord
        objRecord.ItemID = -1
        Return objRecord
    End Function



    Public Shared Function SetObjectValue(ByRef obj As Object, ByVal propertyName As String, ByVal value As Object) As Boolean
        Dim success As Boolean = False
        If propertyName <> String.Empty Then
            ' get the class type
            Dim t As Type = obj.GetType()
            ' get the propinfo ainfo
            Dim propInfo As PropertyInfo = t.GetProperty(propertyName)
            ' set the value
            If propInfo IsNot Nothing Then
                propInfo.SetValue(obj, value, Nothing)
                success = True
            End If
        End If
        Return success
    End Function

    Public Shared Sub FlattenItemMaintRecord(ByRef record As Models.ItemMaintItemDetailRecord, ByRef rowChanges As Models.IMRowChanges, ByRef table As NovaLibra.Coral.SystemFrameworks.MetadataTable)
        Dim cellChange As Models.IMCellChangeRecord
        Dim column As NovaLibra.Coral.SystemFrameworks.MetadataColumn
        If rowChanges IsNot Nothing Then
            If rowChanges.RowRecords.Count > 0 Then
                For i As Integer = 0 To rowChanges.RowRecords.Count - 1 Step 1
                    cellChange = rowChanges.RowRecords.Item(i)
                    If cellChange.Counter = 0 Then
                        column = table.GetColumnByName(cellChange.FieldName)
                        If column IsNot Nothing Then
                            If FormHelper.HasProperty(record, column.ColumnName) Then
                                FormHelper.SetObjectValue(record, column.ColumnName.Replace("_", ""), DataHelper.SmartValues(cellChange.FieldValue, column.GenericType, True))
                            End If
                        End If
                    End If

                Next
            End If
        End If
    End Sub

    Public Shared Function GetValueWithChanges(ByVal originalValue As Object, ByRef rowChanges As Models.IMRowChanges, ByVal columnName As String, ByVal dataType As String) As Object
        Return GetValueWithChanges(originalValue, rowChanges, columnName, dataType, 0)
    End Function

    Public Shared Function GetValueWithChanges(ByVal originalValue As Object, ByRef rowChanges As Models.IMRowChanges, ByVal columnName As String, ByVal dataType As String, ByVal counter As Integer) As Object
        Dim returnValue As Object = originalValue
        Dim cellChange As Models.IMCellChangeRecord = rowChanges.GetCellChange(columnName, counter)
        If cellChange IsNot Nothing Then
            returnValue = DataHelper.SmartValues(cellChange.FieldValue, dataType, True)
        End If
        Return returnValue
    End Function

    Public Shared Function CreateChangeRecord(ByVal originalValue As Object, _
                                              ByVal columnName As String, _
                                              ByVal dataType As String, _
                                              ByVal newValue As Object) As Models.IMCellChangeRecord

        Return CreateChangeRecord(originalValue, columnName, dataType, newValue, 0)

    End Function

    Public Shared Function CreateChangeRecord(ByVal originalValue As Object, _
                                                  ByVal columnName As String, _
                                                  ByVal dataType As String, _
                                                  ByVal newValue As Object, _
                                                  ByVal counter As Integer) As Models.IMCellChangeRecord

        Dim table As MetadataTable = MetadataHelper.GetMetadata().GetTableByID(Models.MetadataTable.vwItemMaintItemDetail)
        Return CreateChangeRecord(originalValue, columnName, dataType, newValue, counter, table)

    End Function

    Public Shared Function CreateChangeRecord(ByVal originalValue As Object, _
                                                  ByVal columnName As String, _
                                                  ByVal dataType As String, _
                                                  ByVal newValue As Object, _
                                                  ByVal counter As Integer, _
                                                  ByRef table As MetadataTable) As Models.IMCellChangeRecord

        Dim cellChange As New Models.IMCellChangeRecord(columnName)
        'cellChange.FieldValue = DataHelper.SmartValuesAsString(newValue, dataType)
        Dim oValue As Object = originalValue
        Dim nValue As Object = newValue
        Dim nValueStr As String
        Dim column As MetadataColumn = Nothing
        If table IsNot Nothing Then
            column = table.GetColumnByName(columnName)
            If table.DoesColumnTreatEmptyAsZero(columnName) Then
                ' for calculated fields, if both values <blank> OR 0, then haschanged = false else test as usual
                If DataHelper.IsEmptyOrZero(originalValue, dataType) AndAlso DataHelper.IsEmptyOrZero(newValue, dataType) Then
                    cellChange.DontSendToRMS = True
                End If
            End If
        End If

        ' compare and save value / has changed
        ' based on formatted values if decimal / formatnumber
        If column IsNot Nothing _
            AndAlso column.GenericType.ToLower.Contains("decimal") _
            AndAlso column.ColumnFormat.ToLower.Contains("formatnumber") Then

            ' compare base on column format
            oValue = DataHelper.SmartValuesAsString(originalValue, column.GenericType)
            nValue = DataHelper.SmartValuesAsString(newValue, column.GenericType)
            nValueStr = DataHelper.SmartValuesAsString(nValue, column.ColumnFormat)
            cellChange.FieldValue = nValueStr
            cellChange.HasChanged = IIf(DataHelper.SmartValuesAsString(oValue, column.ColumnFormat) = nValueStr, False, True)
        Else

            ' compare types as normal
            cellChange.FieldValue = DataHelper.SmartValuesAsString(newValue, dataType)
            cellChange.HasChanged = IIf(DataHelper.SmartValues(originalValue, dataType, True) = DataHelper.SmartValues(newValue, dataType, True), False, True)

        End If
        
        cellChange.Counter = counter
        Return cellChange

    End Function

    Public Shared Sub CheckAndAddChangeRecord(ByRef saveRowChanges As Models.IMRowChanges, _
                                              ByRef currentRowChanges As Models.IMRowChanges, _
                                              ByVal originalValue As Object, _
                                              ByVal columnName As String, _
                                              ByVal dataType As String, _
                                              ByVal newValue As Object)

        Dim changeRecExists As Boolean = False
        If currentRowChanges IsNot Nothing Then
            changeRecExists = IIf(currentRowChanges.GetCellChange(columnName) IsNot Nothing, True, False)
        End If

        Dim hasChanged As Boolean = IIf(DataHelper.SmartValues(originalValue, dataType) = DataHelper.SmartValues(newValue, dataType), False, True)

        If changeRecExists Or hasChanged Then
            saveRowChanges.Add(New Models.IMCellChangeRecord(columnName, DataHelper.SmartValuesAsString(newValue, dataType), hasChanged))
        End If

    End Sub

    ' Used by IMDomestic, IMImport, IMCostChange forms when no Original value available
    ' LOGIC
    '   IF newValue = ItemDetail and Current Change Rec exists (in IMChanges)   THEN SaveChange as a revert
    '   IF newValue = ChangeRec THEN do nothing
    '   IF newValue <> ItemDetail and (No Change Rec OR newValue <> ChangeRec)  THEN SaveChange
    Public Shared Function CheckandSave(ByVal newValue As String, _
                                  ByVal origValue As String, _
                                  ByRef changeRec As Models.IMChangeRecord, _
                                  ByVal ChangeExists As Boolean) As Boolean

        Dim result As Boolean = True
        If newValue = origValue AndAlso ChangeExists Then
            changeRec.HasChanged = False
            result = Data.MaintItemMasterData.SaveItemMaintChanges(changeRec.ItemID, changeRec.FieldName, changeRec.FieldValue, _
                        changeRec.HasChanged, changeRec.ChangedByID, changeRec.CountryOfOrigin, changeRec.UPC, changeRec.EffectiveDate, changeRec.Counter)
        End If

        If newValue <> origValue AndAlso (Not ChangeExists OrElse newValue <> changeRec.FieldValue) Then
            changeRec.FieldValue = newValue
            changeRec.HasChanged = True
            result = Data.MaintItemMasterData.SaveItemMaintChanges(changeRec.ItemID, changeRec.FieldName, changeRec.FieldValue, _
                        changeRec.HasChanged, changeRec.ChangedByID, changeRec.CountryOfOrigin, changeRec.UPC, changeRec.EffectiveDate, changeRec.Counter)
        End If
        Return result

    End Function


    ' LOGIC
    '   IF newValue = ItemDetail and Current Change Rec exists (in IMChanges)   THEN SaveChange as a revert
    '   IF newValue = ChangeRec THEN do nothing
    '   IF newValue <> ItemDetail and (No Change Rec OR newValue <> ChangeRec)  THEN SaveChange
    ' Save Change in ItemDetail afterwards for Validation
    Public Shared Function CheckandSave(ByVal ctlName As String, _
                                  ByRef changeRec As Models.IMChangeRecord, _
                                  ByRef itemDetail As Models.ItemMaintItemDetailFormRecord, _
                                  ByVal newValue As String, _
                                  ByRef mdColumn As NovaLibra.Coral.SystemFrameworks.MetadataColumn, _
                                  ByRef IMChanges As List(Of Models.IMChangeRecord), _
                                  ByVal UserID As Long, _
                                  Optional ByVal baseType As String = "") As Boolean

        ' Rturns TRUE if ANY Change Record updated (reverted or updated or Inserted)
        '       FALSE if No change record saved

        Dim result As Boolean = False, DontSendToRMS As Boolean

        Dim SaveChange As Boolean = False
        Dim exChangeRec As Models.IMChangeRecord

        If baseType = "" Then baseType = mdColumn.GenericType

        Dim originalValue As String, changeValue As String, IMOrig As String

        'If mdColumn.TreatEmptyAsZero AndAlso newValue.Length = 0 Then
        '    changeValue = DataHelper.SmartValuesAsString("0", mdColumn.ColumnFormat)
        'Else
        changeValue = DataHelper.SmartValuesAsString(newValue, mdColumn.ColumnFormat)  ' Changed value
        'End If

        originalValue = FormHelper.GetObjectValue(itemDetail, mdColumn.ColumnName)

        'If mdColumn.TreatEmptyAsZero AndAlso originalValue.Length = 0 Then
        '    originalValue = DataHelper.SmartValuesAsString("0", mdColumn.ColumnFormat)
        'Else
        originalValue = DataHelper.SmartValuesAsString(originalValue, mdColumn.GenericType) ' Original Value
        IMOrig = originalValue

        originalValue = DataHelper.SmartValuesAsString(originalValue, mdColumn.ColumnFormat)    ' formatted the same way as the change record
        'End If

        Dim SameOrig As Boolean = (changeValue = originalValue)

        ' Find a matching Existing Change Record
        exChangeRec = FormHelper.FindIMChangeRecord(IMChanges, changeRec.ItemID, mdColumn.ColumnName, changeRec.CountryOfOrigin, changeRec.UPC, changeRec.EffectiveDate, changeRec.Counter)

        If SameOrig AndAlso exChangeRec.ItemID > 0 Then   ' REVERT
            changeRec.HasChanged = False
            SaveChange = True
        ElseIf Not SameOrig Then    ' Original and newValue are different
            Dim SameChange As Boolean = False
            If exChangeRec.ItemID > 0 Then  ' Change record exists.  Does it match newValue?
                SameChange = (DataHelper.SmartValues(newValue, baseType, True) = DataHelper.SmartValues(exChangeRec.FieldValue, baseType, True))
                ' SameChange = (DataHelper.SmartValues(newValue, mdColumn.ColumnFormat, True) = DataHelper.SmartValues(exChangeRec.FieldValue, mdColumn.ColumnFormat, True))
            End If
            If Not SameChange Then
                changeRec.HasChanged = True
                SaveChange = True
            End If
        End If

        If SaveChange Then
            changeRec.FieldName = mdColumn.ColumnName
            changeRec.FieldValue = DataHelper.SmartValuesAsString(newValue, baseType)
            If mdColumn.TreatEmptyAsZero AndAlso DataHelper.IsEmptyOrZero(newValue, baseType) AndAlso DataHelper.IsEmptyOrZero(IMOrig, baseType) Then
                DontSendToRMS = True
            Else
                DontSendToRMS = False
            End If

            result = Data.MaintItemMasterData.SaveItemMaintChanges(changeRec.ItemID, changeRec.FieldName, changeRec.FieldValue, changeRec.HasChanged, UserID, _
                   changeRec.CountryOfOrigin, changeRec.UPC, changeRec.EffectiveDate, changeRec.Counter, DontSendToRMS)

            ' Now update itemDetail with the newValue for Validation to use if needed
            If result = True Then
                Dim saveValue As Object
                saveValue = DataHelper.SmartValues(newValue, baseType, True)
                FormHelper.SetObjectValue(itemDetail, changeRec.FieldName, saveValue)
            End If
        End If

        Return result
    End Function

    Public Shared Function GetCountForField(ByVal ID As Integer, ByVal FieldName As String, ByRef IMChanges As List(Of Models.IMChangeRecord)) As Integer

        Dim count As Integer = 0
        For Each item As Models.IMChangeRecord In IMChanges
            If item.ItemID = ID AndAlso item.FieldName.ToUpper = FieldName.ToUpper Then
                count += 1
            End If
        Next
        Return count

    End Function

    ' return a change record that has a counter = or greater than the specfied counter
    Public Shared Function GetNextCountForField(ByVal ItemID As Integer, ByVal counter As Integer, ByVal FieldName As String, _
        ByRef IMChanges As List(Of Models.IMChangeRecord)) As Models.IMChangeRecord

        For Each item As Models.IMChangeRecord In IMChanges
            If item.ItemID = ItemID AndAlso item.Counter >= counter AndAlso item.FieldName.ToUpper = FieldName.ToUpper Then
                Return item
            End If
        Next
        Dim objRecord As Models.IMChangeRecord = New Models.IMChangeRecord
        objRecord.ItemID = -1
        Return objRecord

    End Function

    ' vendors

    Public Shared Function LookupDomesticVendor(ByVal vendorNum As Integer) As String
        Dim retValue As String = String.Empty

        Dim vendor As NovaLibra.Coral.SystemFrameworks.Michaels.VendorRecord = Nothing
        Dim vnum As Integer = vendorNum
        If vnum > 0 Then
            Dim objMichaelsVendor As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsVendor()
            vendor = objMichaelsVendor.GetVendorRecord(vnum)
            If Not vendor Is Nothing AndAlso vendor.ID > 0 Then
                If ValidationHelper.IsValidDomesticVendor(vendor) Then
                    retValue = vendor.VendorName
                End If
            End If
            vendor = Nothing
            objMichaelsVendor = Nothing
        End If

        Return retValue
    End Function

    Public Shared Function LookupImportVendor(ByVal vendorNum As Integer) As String
        Dim retValue As String = String.Empty

        Dim vendor As NovaLibra.Coral.SystemFrameworks.Michaels.VendorRecord = Nothing
        Dim vnum As Integer = vendorNum
        If vnum > 0 Then
            Dim objMichaelsVendor As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsVendor()
            vendor = objMichaelsVendor.GetVendorRecord(vnum)
            If Not vendor Is Nothing AndAlso vendor.ID > 0 Then
                If ValidationHelper.IsValidImportVendor(vendor) Then
                    retValue = vendor.VendorName
                End If
            End If
            vendor = Nothing
            objMichaelsVendor = Nothing
        End If

        Return retValue
    End Function

    Public Shared Sub SetupControlsFromMetadata(ByRef page As System.Web.UI.Page, ByVal table As NovaLibra.Coral.SystemFrameworks.MetadataTable)
        Dim col As NovaLibra.Coral.SystemFrameworks.MetadataColumn
        Dim ctrl As System.Web.UI.Control
        Dim nlctrl As NovaLibra.Controls.INLChangeControl
        If table IsNot Nothing Then
            For Each de As DictionaryEntry In table.GetColums()
                col = de.Value
                If col.TreatEmptyAsZero Then
                    ctrl = page.FindControl(col.ColumnName & "Edit")
                    If ctrl Is Nothing Then ctrl = page.FindControl(col.ColumnName)
                    If ctrl IsNot Nothing AndAlso TypeOf ctrl Is NovaLibra.Controls.INLChangeControl Then
                        nlctrl = CType(ctrl, NovaLibra.Controls.INLChangeControl)
                        nlctrl.TreatEmptyAsZero = True
                    End If
                End If
            Next
        End If
    End Sub

End Class
