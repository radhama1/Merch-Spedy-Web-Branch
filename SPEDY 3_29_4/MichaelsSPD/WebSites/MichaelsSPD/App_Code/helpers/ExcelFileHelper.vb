Imports System
Imports System.Data
Imports System.Drawing
Imports System.Diagnostics
Imports System.IO
Imports Microsoft.VisualBasic

Imports SpreadsheetGear
Imports SpreadsheetGear.Data
Imports SpreadsheetGear.shapes

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks
Imports NLObjects = NovaLibra.Coral.SystemFrameworks.Michaels

Public Class ExcelFileHelper

    Public Enum FileType
        Domestic = 1
        Import = 2
        ItemMaintenance = 3
        POFile = 4
        TMExemption = 5
        TMTranslation = 6
    End Enum

    Public Shared Function IsValidFileType(ByVal fileName As String) As Boolean
        If (fileName.Length > 5 AndAlso fileName.Trim().ToLower().EndsWith(".xls")) Or (fileName.Length > 6 AndAlso fileName.Trim().ToLower().EndsWith(".xlsx")) Or (fileName.Length > 6 AndAlso fileName.Trim().ToLower().EndsWith(".xlsm")) Then
            Return True
        Else
            Return False
        End If
    End Function

    Public Shared Function IsValidTabName(ByVal tabName As String) As Boolean
        Dim strRegex As String = "^(D(P)?-|R-|C-|D(P)?-PIAB-|D(P)?-PDQ-)*[0-9_]+$|^Child\s[0-9]+$|^Component\s[0-9]+$"    '"^(D(P)?-|R-|C-)*[0-9_]+$"
        Dim myRegexOptions As RegexOptions = RegexOptions.IgnoreCase
        Dim myRegex As New Regex(strRegex, myRegexOptions)
        Dim result As Boolean = False

        'Remove leading or trailing whitespace
        tabName = tabName.Trim()
        Try
            If InStr(tabName, WebConstants.IMPORT_ITEM_IMPORT_WORKSHEET) > 0 Then
                result = True
            Else
                For Each myMatch As Match In myRegex.Matches(tabName)
                    If myMatch.Success Then
                        result = True
                        Exit For
                    End If
                Next
            End If

        Catch ex As Exception
            'TODO
        End Try

        Return result

    End Function

    Public Shared Function IsValidComponent(ByRef wb As SpreadsheetGear.IWorkbook, Optional ByVal fType As FileType = FileType.Domestic) As Boolean

        Dim retValue As Boolean = True

        Try
            Select Case fType

                Case FileType.Domestic

                    If wb.Worksheets.Item(WebConstants.DOMESTIC_ITEM_IMPORT_WORKSHEET) Is Nothing Then
                        retValue = False
                    End If

                Case FileType.Import

                    'Modified 2/22/2011 to support new Quote Reference tabs
                    Dim found As Boolean = False
                    For itab As Integer = 0 To wb.Worksheets.Count - 1
                        If IsValidTabName(wb.Worksheets(itab).Name) Then
                            found = True
                            Exit For
                        End If
                    Next

                    If Not found Then retValue = False

                    'If wb.Worksheets.Item(WebConstants.IMPORT_ITEM_IMPORT_WORKSHEET) Is Nothing Then
                    '    retValue = False
                    'End If

                Case FileType.ItemMaintenance ' "fast" format

                    ' As of 7/1/2010
                    ' The format of the "fast" sheet is that the columns are in the correct order.
                    ' I'd break this off into its own function, but then there'd have to be an instance of the class.
                    If wb.Worksheets.Item(0).Cells(0, 0).Value.ToString.ToUpper <> "SKU" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 1).Value.ToString.ToUpper <> "VENDOR#" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 2).Value.ToString.ToUpper <> "DEPT" Then retValue = False


                    'If wb.Worksheets.Item(0).Cells(0, 4).Value.ToString.ToUpper <> "GTIN14-CASE" Then retValue = False
                    'If wb.Worksheets.Item(0).Cells(0, 5).Value.ToString.ToUpper <> "GTIN14-INNER" Then retValue = False

                    If wb.Worksheets.Item(0).Cells(0, 3).Value.ToString.ToUpper <> "VPN" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 4).Value.ToString.ToUpper <> "SKU DESC" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 5).Value.ToString.ToUpper <> "EACHES MASTER CASE" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 6).Value.ToString.ToUpper <> "EACHES INNER PACK" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 7).Value.ToString.ToUpper <> "ALLOW STORE ORDER" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 8).Value.ToString.ToUpper <> "INVENTORY CONTROL" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 9).Value.ToString.ToUpper <> "AUTO REPLENISH" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 10).Value.ToString.ToUpper <> "PREPRICED" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 11).Value.ToString.ToUpper <> "PREPRICED UDA" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 12).Value.ToString.ToUpper <> "COST" Then retValue = False

                    If wb.Worksheets.Item(0).Cells(0, 13).Value.ToString.ToUpper <> "EACH HEIGHT" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 14).Value.ToString.ToUpper <> "EACH WIDTH" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 15).Value.ToString.ToUpper <> "EACH LENGTH" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 16).Value.ToString.ToUpper <> "EACH WEIGHT" Then retValue = False

                    If wb.Worksheets.Item(0).Cells(0, 17).Value.ToString.ToUpper <> "INNER PACK HEIGHT" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 18).Value.ToString.ToUpper <> "INNER PACK WIDTH" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 19).Value.ToString.ToUpper <> "INNER PACK LENGTH" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 20).Value.ToString.ToUpper <> "INNER PACK WEIGHT" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 21).Value.ToString.ToUpper <> "MASTER CASE HEIGHT" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 22).Value.ToString.ToUpper <> "MASTER CASE WIDTH" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 23).Value.ToString.ToUpper <> "MASTER CASE LENGTH" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 24).Value.ToString.ToUpper <> "MASTER CASE WEIGHT" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 25).Value.ToString.ToUpper <> "COUNTRY OF ORIGIN" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 26).Value.ToString.ToUpper <> "TAX UDA" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 27).Value.ToString.ToUpper <> "TAX VALUE UDA" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 28).Value.ToString.ToUpper <> "DISCOUNTABLE" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 29).Value.ToString.ToUpper <> "IMPORT BURDEN" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 30).Value.ToString.ToUpper <> "SHIPPING POINT" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 31).Value.ToString.ToUpper <> "PLANOGRAM NAME" Then retValue = False

                    If wb.Worksheets.Item(0).Cells(0, 32).Value.ToString.ToUpper <> "PRIVATE BRAND LABEL" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 33).Value.ToString.ToUpper <> "PACKAGE LANGUAGE INDICATOR ENGLISH" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 34).Value.ToString.ToUpper <> "PACKAGE LANGUAGE INDICATOR FRENCH" Then retValue = False
                    'If wb.Worksheets.Item(0).Cells(0, 35).Value.ToString.ToUpper <> "PACKAGE LANGUAGE INDICATOR  SPANISH" Then retValue = False
                    'If wb.Worksheets.Item(0).Cells(0, 36).Value.ToString.ToUpper <> "TRANSLATION INDICATOR FRENCH" Then retValue = False
                    'If wb.Worksheets.Item(0).Cells(0, 37).Value.ToString.ToUpper <> "TRANSLATION INDICATOR SPANISH" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 35).Value.ToString.ToUpper <> "CUSTOMS DESCRIPTION" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 36).Value.ToString.ToUpper <> "ENGLISH SHORT DESCRIPTION" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 37).Value.ToString.ToUpper <> "ENGLISH LONG DESCRIPTION" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 38).Value.ToString.ToUpper <> "HARMONIZED CODE NUMBER" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 39).Value.ToString.ToUpper <> "CANADA HARMONIZED CODE NUMBER" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 40).Value.ToString.ToUpper <> "DETAIL INVOICE CUSTOMS DESCRIPTION" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 41).Value.ToString.ToUpper <> "COMPONENT MATERIAL BREAKDOWN BY %" Then retValue = False
                    'If wb.Worksheets.Item(0).Cells(0, 42).Value.ToString.ToUpper <> "SUPPLEMENTARY TARIFF PERCENT" Then retValue = False

                    If wb.Worksheets.Item(0).Cells(0, 42).Value.ToString.ToUpper <> "PHYTOSANITARY CERTIFICATE" Then retValue = False
                    If wb.Worksheets.Item(0).Cells(0, 43).Value.ToString.ToUpper <> "PHYTO TEMPORARY SHIPMENT" Then retValue = False


                    'if they included the UPC column then OK if it isn't there that is OK too, but if it is something else then No!
                    If Not wb.Worksheets.Item(0).Cells(0, 44).Value Is Nothing Then
                        If wb.Worksheets.Item(0).Cells(0, 44).Value.ToString.ToUpper.Trim <> "" And wb.Worksheets.Item(0).Cells(0, 44).Value.ToString.ToUpper <> "UPC" Then
                            retValue = False
                        End If
                    End If


                Case FileType.POFile

                    If wb.Worksheets.Item(WebConstants.PURCHASE_ORDER_IMPORT_ITEM_WORKSHEET) Is Nothing Then
                        retValue = False
                    Else
                        If wb.Worksheets.Item(WebConstants.PURCHASE_ORDER_IMPORT_ITEM_WORKSHEET).Cells(0, WebConstants.POFileColumn.SKU).Value.ToString.ToUpper <> "SKU" Then retValue = False
                        If wb.Worksheets.Item(WebConstants.PURCHASE_ORDER_IMPORT_ITEM_WORKSHEET).Cells(0, WebConstants.POFileColumn.LOC).Value.ToString.ToUpper <> "LOC" Then retValue = False
                        If wb.Worksheets.Item(WebConstants.PURCHASE_ORDER_IMPORT_ITEM_WORKSHEET).Cells(0, WebConstants.POFileColumn.QTY).Value.ToString.ToUpper <> "QTY" Then retValue = False
                        If wb.Worksheets.Item(WebConstants.PURCHASE_ORDER_IMPORT_ITEM_WORKSHEET).Cells(0, WebConstants.POFileColumn.COST).Value.ToString.ToUpper <> "COST" Then retValue = False
                        If wb.Worksheets.Item(WebConstants.PURCHASE_ORDER_IMPORT_ITEM_WORKSHEET).Cells(0, WebConstants.POFileColumn.IP).Value.ToString.ToUpper <> "IP" Then retValue = False
                        If wb.Worksheets.Item(WebConstants.PURCHASE_ORDER_IMPORT_ITEM_WORKSHEET).Cells(0, WebConstants.POFileColumn.MC).Value.ToString.ToUpper <> "MC" Then retValue = False
                    End If

            End Select

        Catch ex As Exception
            retValue = False
        End Try

        Return retValue

    End Function

    Public Shared Function GetExcelWorksheet(ByRef wb As SpreadsheetGear.IWorkbook, ByVal worksheetName As String) As SpreadsheetGear.IWorksheet
        Dim ws As SpreadsheetGear.IWorksheet = Nothing
        'For i As Integer = 0 To wb.Worksheets.Count - 1
        '    If wb.Worksheets.Item(i).Name = worksheetName Then
        '        ws = wb.Worksheets(i)
        '        Exit For
        '    End If
        'Next
        Try
            ws = wb.Worksheets.Item(worksheetName)
        Catch ex As Exception
            ws = Nothing
        End Try
        Return ws
    End Function

    Public Shared Function IsValidItemRow(ByRef worksheet As SpreadsheetGear.IWorksheet, ByVal row As Integer) As Boolean
        Dim checkrow As Integer = WebConstants.DOMESTIC_ITEM_START_ROW + CType(IIf(row <= 0, 1, row), Integer) - 1

        If row > AppHelper.GetDomesticItemMaxRow() Then Return False

        If ObjectToString(GetCell(worksheet, "B", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "C", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "D", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "E", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "F", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "G", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "H", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "I", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "J", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "K", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "L", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "M", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "N", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "O", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "P", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "Q", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "R", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "S", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "T", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "U", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "V", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "W", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "X", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "Y", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "Z", checkrow)).Trim() <> String.Empty Then Return True

        If ObjectToString(GetCell(worksheet, "AA", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AB", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AC", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AD", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AE", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AF", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AG", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AH", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AI", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AJ", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AK", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AL", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AM", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AN", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AO", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AP", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AQ", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AR", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AS", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AT", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AU", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AV", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AW", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AX", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AY", checkrow)).Trim() <> String.Empty Then Return True
        If ObjectToString(GetCell(worksheet, "AZ", checkrow)).Trim() <> String.Empty Then Return True

        If ObjectToString(GetCell(worksheet, "BA", checkrow)).Trim() <> String.Empty Then Return True

        Return False

    End Function

    Public Shared Function ObjectToString(ByRef obj As Object) As String
        If obj Is Nothing Then
            Return String.Empty
        Else
            Return obj.ToString()
        End If
    End Function

    Public Shared Function GetCellByMap(ByRef worksheet As SpreadsheetGear.IWorksheet, ByRef itemMapping As NLObjects.ItemMapping, ByVal columnName As String, Optional ByVal MultilineDelimiter As String = "", Optional ByVal rowOverride As Integer = 0) As Object
        Dim tlist As ArrayList = itemMapping.GetMappingColumns(columnName)
        Dim numColumns As Integer = tlist.Count
        If numColumns > 1 Then
            Dim retValue As New StringBuilder("")
            Dim counter As Integer = 0
            For Each x As NLObjects.ItemMappingColumn In tlist
                counter += 1
                If rowOverride > 0 Then
                    retValue.Append(CStr(GetCell(worksheet, x.ExcelColumn, rowOverride)))
                Else
                    retValue.Append(CStr(GetCell(worksheet, x.ExcelColumn, x.ExcelRow)))
                End If

                If counter < numColumns Then
                    retValue.Append(MultilineDelimiter)
                End If
            Next
            Return retValue.ToString()
        ElseIf numColumns = 1 Then
            Dim imc As NLObjects.ItemMappingColumn = tlist(0)
            If rowOverride > 0 Then
                Return GetCell(worksheet, imc.ExcelColumn, rowOverride)
            Else
                Return GetCell(worksheet, imc.ExcelColumn, imc.ExcelRow)
            End If
        Else
            Return Nothing
        End If
    End Function

    Public Shared Function GetCellDateByMap(ByRef worksheet As SpreadsheetGear.IWorksheet, ByRef itemMapping As NLObjects.ItemMapping, ByVal columnName As String, Optional ByVal MultilineDelimiter As String = "", Optional ByVal rowOverride As Integer = 0) As Object
        Dim tlist As ArrayList = itemMapping.GetMappingColumns(columnName)
        Dim numColumns As Integer = tlist.Count
        If numColumns > 1 Then
            Dim retValue As New StringBuilder("")
            Dim counter As Integer = 0
            For Each x As NLObjects.ItemMappingColumn In tlist
                counter += 1
                If rowOverride > 0 Then
                    retValue.Append(CStr(GetCellDate(worksheet, x.ExcelColumn, rowOverride)))
                Else
                    retValue.Append(CStr(GetCellDate(worksheet, x.ExcelColumn, x.ExcelRow)))
                End If

                If counter < numColumns Then
                    retValue.Append(MultilineDelimiter)
                End If
            Next
            Return retValue.ToString()
        ElseIf numColumns = 1 Then
            Dim imc As NLObjects.ItemMappingColumn = tlist(0)
            If rowOverride > 0 Then
                Return GetCellDate(worksheet, imc.ExcelColumn, rowOverride)
            Else
                Return GetCellDate(worksheet, imc.ExcelColumn, imc.ExcelRow)
            End If
        Else
            Return Nothing
        End If
    End Function

    Public Shared Function SetCellByMap(ByRef worksheet As SpreadsheetGear.IWorksheet, ByRef itemMapping As NLObjects.ItemMapping, ByVal columnName As String, ByVal value As Object, ByVal MultilineDelimiter As String) As Boolean
        Dim tlist As ArrayList = itemMapping.GetMappingColumns(columnName)
        Dim imc As NLObjects.ItemMappingColumn
        Dim arrValues As ArrayList = New ArrayList()
        ' load arrValues
        Dim str As String = value.ToString()
        Dim index As Integer = str.IndexOf(MultilineDelimiter)
        If index >= 0 Then
            Do While index >= 0
                arrValues.Add(str.Substring(0, index))
                str = str.Substring(index + MultilineDelimiter.Length)
                index = str.IndexOf(MultilineDelimiter)
            Loop
            arrValues.Add(str)
        Else
            arrValues.Add(str)
        End If
        ' end load arrValues
        Dim numColumns As Integer = tlist.Count
        If numColumns > 1 Then
            Dim bSetAll As Boolean = True, bSet As Boolean
            For i As Integer = 0 To numColumns - 1
                If i < arrValues.Count Then
                    imc = tlist(i)
                    bSet = SetCell(worksheet, imc.ExcelColumn, imc.ExcelRow, arrValues(i))
                    If Not bSet Then bSetAll = False
                End If
            Next
            Return bSetAll
        ElseIf numColumns = 1 Then
            imc = tlist(0)
            Return SetCell(worksheet, imc.ExcelColumn, imc.ExcelRow, value)
        Else
            Return False
        End If
    End Function

    ' returns cell value
    Public Shared Function GetCell(ByRef worksheet As SpreadsheetGear.IWorksheet, ByVal column As String, ByVal row As Integer) As Object
        Dim returnObj As Object = Nothing
        Try
            returnObj = worksheet.Cells(column & row.ToString()).Value
        Catch nrex As NullReferenceException
            returnObj = Nothing
        Catch ex As Exception
            returnObj = ""
        End Try

        Return returnObj
    End Function

    ' returns cell formatted text (good for dates, etc.)
    Public Shared Function GetCellText(ByRef worksheet As SpreadsheetGear.IWorksheet, ByVal column As String, ByVal row As Integer) As Object
        Dim returnObj As Object = Nothing
        Try
            returnObj = worksheet.Cells(column & row.ToString()).Text
        Catch nrex As NullReferenceException
            returnObj = Nothing
        Catch ex As Exception
            returnObj = ""
        End Try

        Return returnObj
    End Function

    ' returns cell formatted text (good for dates, etc.)
    Public Shared Function GetCellDate(ByRef worksheet As SpreadsheetGear.IWorksheet, ByVal column As String, ByVal row As Integer) As Object
        Dim returnObj As Object = Nothing
        Try
            If DataHelper.SmartValues(worksheet.Cells(column & row.ToString()).Value, "decimal", False) > 0 Then
                returnObj = worksheet.Workbook.NumberToDateTime(worksheet.Cells(column & row.ToString()).Value)
            End If
        Catch nrex As NullReferenceException
            returnObj = Nothing
        Catch ex As Exception
            returnObj = ""
        End Try

        Return returnObj
    End Function



    Public Shared Function GetImageByMap(ByRef worksheet As SpreadsheetGear.IWorksheet, ByRef itemMapping As NLObjects.ItemMapping, ByVal columnName As String) As SpreadsheetGear.Shapes.IShape

        Dim retPicture As SpreadsheetGear.Shapes.IShape = Nothing
        'Dim imc As NLObjects.ItemMappingColumn
        Dim tlist As ArrayList = itemMapping.GetMappingColumns(columnName)

        If tlist.Count >= 1 Then
            'imc = tlist(0)
            retPicture = GetImage(worksheet, tlist)
        End If

        Return retPicture

    End Function

    Public Shared Function SetImageByMap(ByRef worksheet As SpreadsheetGear.IWorksheet, ByRef itemMapping As NLObjects.ItemMapping, ByVal columnName As String, ByVal img As System.Drawing.Image) As Boolean
        Dim imc As NLObjects.ItemMappingColumn = itemMapping.GetMappingColumn(columnName)
        Dim r As IRange = worksheet.Range("Picture")
        Dim r2 As IRange = r.MergeArea
        Dim w As Double, h As Double, aspectRatio As Double
        w = r2.Width
        h = r2.Height
        aspectRatio = img.Width / img.Height
        If aspectRatio > w / h Then
            ' landscape
            h = w / aspectRatio
        Else
            ' portrait
            w = h * aspectRatio
        End If
        If Not imc Is Nothing Then
            'Return SetCell(worksheet, imc.ExcelColumn, imc.ExcelRow, img)
            worksheet.Shapes.AddPicture(imageToByteArray(img), _
                worksheet.WindowInfo.ColumnToPoints(r.Column), _
                worksheet.WindowInfo.RowToPoints(r.Row), _
                w, h)
        Else
            Return False
        End If
    End Function

    Public Shared Function GetImage(ByRef worksheet As SpreadsheetGear.IWorksheet, ByVal column As String, ByVal row As Integer) As SpreadsheetGear.Shapes.IShape

        Dim returnObj As SpreadsheetGear.Shapes.IShape = Nothing
        Dim tempImg As SpreadsheetGear.Shapes.IPictureFormat
        Dim img As SpreadsheetGear.Shapes.IShape
        Dim i As Integer

        Try
            For i = 0 To worksheet.Shapes.Count - 1

                img = worksheet.Shapes.Item(i)
                tempImg = img.PictureFormat

                If tempImg IsNot Nothing AndAlso (img.TopLeftCell.Row = row - 1 AndAlso img.TopLeftCell.Column = GetColIndexFromString(column) - 1) Then

                    If img.Name <> "Michaels Water Mark" Then

                        returnObj = img
                        'Exit For

                    End If

                End If

            Next

        Catch nrex As NullReferenceException
            returnObj = Nothing
        Catch ex As Exception
            returnObj = Nothing
        End Try

        Return returnObj

    End Function
    Public Shared Function GetImage(ByRef worksheet As SpreadsheetGear.IWorksheet, ByRef tlist As ArrayList) As SpreadsheetGear.Shapes.IShape

        Dim returnObj As SpreadsheetGear.Shapes.IShape = Nothing
        Dim tempImg As SpreadsheetGear.Shapes.IPictureFormat
        Dim img As SpreadsheetGear.Shapes.IShape
        Dim i As Integer

        Try

            For i = 0 To worksheet.Shapes.Count - 1

                img = worksheet.Shapes.Item(i)
                tempImg = img.PictureFormat

                If tempImg IsNot Nothing AndAlso (isValidCell(img.TopLeftCell.Row, img.TopLeftCell.Column, tlist)) Then

                    If img.Name <> "Michaels Water Mark" And img.Name <> "Picture 242" Then

                        returnObj = img
                        'Exit For

                    End If

                End If

            Next

        Catch nrex As NullReferenceException
            returnObj = Nothing
        Catch ex As Exception
            returnObj = Nothing
        End Try

        Return returnObj

    End Function
    Public Shared Function isValidCell(ByVal imgRow As Integer, ByVal imgColumn As Integer, ByRef tlist As ArrayList) As Boolean
        Dim imc As NLObjects.ItemMappingColumn
        Dim isValid As Boolean = False

        For i As Integer = 0 To tlist.Count - 1
            imc = CType(tlist(i), NLObjects.ItemMappingColumn)
            If imgRow = imc.ExcelRow - 1 AndAlso imgColumn = GetColIndexFromString(imc.ExcelColumn) - 1 Then
                isValid = True
                Exit For
            End If
        Next
        Return isValid
    End Function
    Public Shared Function imageToByteArray(ByVal imageIn As System.Drawing.Image) As Byte()

        Dim ms As New MemoryStream()
        imageIn.Save(ms, System.Drawing.Imaging.ImageFormat.Jpeg)
        Return ms.ToArray()

    End Function

    Public Shared Function SetCellByMap(ByRef worksheet As SpreadsheetGear.IWorksheet, ByRef itemMapping As NLObjects.ItemMapping, ByVal columnName As String, ByVal value As Object) As Boolean
        Try
            Dim imc As NLObjects.ItemMappingColumn = itemMapping.GetMappingColumn(columnName)
            If Not imc Is Nothing Then
                Return SetCell(worksheet, imc.ExcelColumn, imc.ExcelRow, value)
            Else
                'Debug.Assert(False)
                Return False
            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Shared Function SetCellByMap(ByRef worksheet As SpreadsheetGear.IWorksheet, ByRef itemMapping As NLObjects.ItemMapping, ByVal columnName As String, ByVal value As Object, ByVal rowNumber As Integer) As Boolean
        Dim imc As NLObjects.ItemMappingColumn
        imc = itemMapping.GetMappingColumn(columnName)
        If Not imc Is Nothing Then
            Return SetCell(worksheet, imc.ExcelColumn, rowNumber, value)
        Else
            Debug.Assert(False)
            Return False
        End If
    End Function

    Public Shared Function SetCellDateByMap(ByRef worksheet As SpreadsheetGear.IWorksheet, ByRef itemMapping As NLObjects.ItemMapping, ByVal columnName As String, ByVal value As Object) As Boolean
        Dim imc As NLObjects.ItemMappingColumn = itemMapping.GetMappingColumn(columnName)
        If Not imc Is Nothing Then
            Return SetCellDate(worksheet, imc.ExcelColumn, imc.ExcelRow, value)
        Else
            Debug.Assert(False)
            Return False
        End If
    End Function

    Public Shared Function SetCellDateByMap(ByRef worksheet As SpreadsheetGear.IWorksheet, ByRef itemMapping As NLObjects.ItemMapping, ByVal columnName As String, ByVal value As Object, ByVal rowNumber As Integer) As Boolean
        Dim imc As NLObjects.ItemMappingColumn
        imc = itemMapping.GetMappingColumn(columnName)
        If Not imc Is Nothing Then
            Return SetCellDate(worksheet, imc.ExcelColumn, rowNumber, value)
        Else
            Debug.Assert(False)
            Return False
        End If
    End Function

    Public Shared Function SetCell(ByRef worksheet As SpreadsheetGear.IWorksheet, ByVal column As String, ByVal row As Integer, ByVal value As Object) As Boolean
        Dim returnObj As Boolean = True
        Try
            worksheet.Cells(column & row.ToString()).Value = value
        Catch nrex As NullReferenceException
            returnObj = False
        Catch ex As Exception
            returnObj = False
        End Try
        Return returnObj
    End Function

    Public Shared Function SetCellDate(ByRef worksheet As SpreadsheetGear.IWorksheet, ByVal column As String, ByVal row As Integer, ByVal value As Object) As Boolean
        Dim returnObj As Boolean = True
        Try
            worksheet.Cells(column & row.ToString()).Value = value
        Catch nrex As NullReferenceException
            returnObj = False
        Catch ex As Exception
            returnObj = False
        End Try
        Return returnObj
    End Function

    Public Shared Function UnlockCellByMap(ByRef worksheet As SpreadsheetGear.IWorksheet, ByRef itemMapping As NLObjects.ItemMapping, ByVal columnName As String, ByVal password As String) As Boolean
        Dim imc As NLObjects.ItemMappingColumn = itemMapping.GetMappingColumn(columnName)
        If Not imc Is Nothing Then
            Return UnlockCell(worksheet, imc.ExcelColumn, imc.ExcelRow, password)
        Else
            Return False
        End If
    End Function

    Public Shared Function UnlockCell(ByRef worksheet As SpreadsheetGear.IWorksheet, ByVal column As String, ByVal row As Integer, ByVal password As String) As Boolean
        Dim ret As Boolean = True
        Try
            If password <> String.Empty Then worksheet.Unprotect(password)
            worksheet.Cells(column & row.ToString()).Locked = False
            If password <> String.Empty Then worksheet.Protect(password)
        Catch ex As Exception
            ret = False
        End Try
        Return ret
    End Function

    Public Shared Function GetColIndexFromString(ByVal column As String) As Integer
        Dim col As Integer = 0
        column = column.ToUpper().Trim()
        If Not IsValidColumnString(column) Then
            Throw New ArgumentOutOfRangeException()
        End If
        If column.Length = 1 Then
            col = Asc(column) - Asc("A") + 1
        ElseIf column.Length = 2 Then
            col = ((Asc(column.Substring(0, 1)) - Asc("A") + 1) * 26) + Asc(column.Substring(1, 1)) - Asc("A") + 1
        End If
        Return col
    End Function

    Public Shared Function IsValidColumnString(ByVal column As String) As Boolean
        If column.Length = 0 Or column.Length > 2 Then
            Return False
        Else
            For i As Integer = 0 To column.Length - 1
                If Asc(column.Substring(i, 1)) < Asc("A") Or Asc(column.Substring(i, 1)) > Asc("Z") Then
                    Return False
                End If
            Next
            Return True
        End If
    End Function

    Public Shared Function GetDateFromExcelCell(ByRef obj As Object) As Date
        Dim dt As Date = Date.MinValue
        Dim d As Integer ' Will contain the day as an Integer
        Dim m As Integer ' Will contain the month as an Integer
        Dim y As Integer ' Will contain the year as an Integer
        If Not obj Is Nothing AndAlso (TypeOf obj Is Integer OrElse DataHelper.SmartValues(obj, "integer", True) <> Integer.MinValue) Then
            ExcelSerialDateToDMY(CType(obj, Integer), d, m, y)
            dt = New Date(y, m, d)
        End If
        Return dt
    End Function

    Public Shared Sub ExcelSerialDateToDMY(ByRef nSerialDate As Integer, ByRef nDay As Integer, _
                              ByRef nMonth As Integer, ByRef nYear As Integer)

        ' This function is courtesy of The Code Project.
        ' http://www.codeproject.com/datetime/exceldmy.asp?df=100&forumid=4548&exp=0&select=590906

        ' nSerialDate is the serial date from Excel
        ' nDay, nMonth, and nYear are the "output parameters" where the method will store
        '    the Day, Month, and Year values as Integers that it extracts from nDate

        ' Excel/Lotus 123 have a bug with 29-02-1900. 1900 is not a
        ' leap year, but Excel/Lotus 123 think it is...
        If nSerialDate = 60 Then
            nDay = 29
            nMonth = 2
            nYear = 1900
            Return
        ElseIf nSerialDate < 60 Then
            ' Because of the 29-02-1900 bug, any serial date 
            ' under 60 is one off... Compensate.
            nSerialDate = nSerialDate + 1
        End If

        ' Modified Julian to DMY calculation with an addition of 2415019
        Dim l As Integer = nSerialDate + 68569 + 2415019
        Dim n As Integer = CInt(Fix((4 * l) / 146097))
        l = l - CInt(Fix((146097 * n + 3) / 4))
        Dim i As Integer = CInt(Fix((4000 * (l + 1)) / 1461001))
        l = l - CInt(Fix((1461 * i) / 4)) + 31
        Dim j As Integer = CInt(Fix((80 * l) / 2447))
        nDay = l - CInt(Fix((2447 * j) / 80))
        l = CInt(Fix(j / 11))
        nMonth = j + 2 - (12 * l)
        nYear = 100 * (n - 49) + i + l

    End Sub

    Public Shared Function Number2Letter(ByVal column As Double) As String
        Dim columnLetter As String = ""
        Dim n As Double = 0
        n = System.Convert.ToInt32((column / 26) - 0.500000000001)

        Dim Number As Integer = System.Convert.ToInt32((column - (n * 26)).ToString())
        If Number = 0 Then Number = 26

        Dim addition As String = ""
        If (n > 0) Then
            addition = Number2Letter(n)
        End If

        Select Case Number
            Case 1
                columnLetter = addition + "A"
            Case 2
                columnLetter = addition + "B"
            Case 3
                columnLetter = addition + "C"
            Case 4
                columnLetter = addition + "D"
            Case 5
                columnLetter = addition + "E"
            Case 6
                columnLetter = addition + "F"
            Case 7
                columnLetter = addition + "G"
            Case 8
                columnLetter = addition + "H"
            Case 9
                columnLetter = addition + "I"
            Case 10
                columnLetter = addition + "J"
            Case 11
                columnLetter = addition + "K"
            Case 12
                columnLetter = addition + "L"
            Case 13
                columnLetter = addition + "M"
            Case 14
                columnLetter = addition + "N"
            Case 15
                columnLetter = addition + "O"
            Case 16
                columnLetter = addition + "P"
            Case 17
                columnLetter = addition + "Q"
            Case 18
                columnLetter = addition + "R"
            Case 19
                columnLetter = addition + "S"
            Case 20
                columnLetter = addition + "T"
            Case 21
                columnLetter = addition + "U"
            Case 22
                columnLetter = addition + "V"
            Case 23
                columnLetter = addition + "W"
            Case 24
                columnLetter = addition + "X"
            Case 25
                columnLetter = addition + "Y"
            Case 26
                columnLetter = addition + "Z"
        End Select

        Return columnLetter
    End Function

End Class
