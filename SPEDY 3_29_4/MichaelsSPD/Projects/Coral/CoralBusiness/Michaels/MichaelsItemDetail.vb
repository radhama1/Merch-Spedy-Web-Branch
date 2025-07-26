Imports System
Imports System.Data

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks.Michaels
'lp
Imports System.IO
Imports System.Runtime.Serialization.Formatters.Binary
Imports System.Runtime.Serialization
'lp


Namespace Michaels

    Public Class MichaelsItemDetail
        Inherits MichaelsFieldAuditing

        ' ****************
        ' * ITEM HEADERS *
        ' ****************

        Public Function GetItemHeaderRecord(ByVal id As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord
            'Dim objData As NLData.Michaels.ItemDetail = New NLData.Michaels.ItemDetail()
            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord = Nothing
            Try
                Dim objData As New NLData.Michaels.ItemDetail()
                objRecord = objData.GetItemHeaderRecord(id)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                If objRecord Is Nothing Then
                    objRecord = New NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord()
                End If
                objRecord.ID = -1
                Throw ex
            Finally
                'objData = Nothing
            End Try
            Return objRecord
        End Function

        Public Function SaveItemHeaderRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord, ByVal userID As Integer, ByVal calculateParentTotals As Boolean) As Long
            Dim objData As New NLData.Michaels.ItemDetail()
            Dim id As Long
            id = objData.SaveItemHeaderRecord(objRecord, userID, String.Empty, String.Empty, String.Empty, calculateParentTotals)
            objData = Nothing
            Return id
        End Function

        Public Function SaveItemHeaderRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord, ByVal userID As Integer) As Long
            Dim objData As New NLData.Michaels.ItemDetail()
            Dim id As Long
            id = objData.SaveItemHeaderRecord(objRecord, userID, String.Empty, String.Empty, String.Empty, False)
            objData = Nothing
            Return id
        End Function

        Public Function SaveItemHeaderRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemHeaderRecord, ByVal userID As Integer, ByVal batchAction As String, ByVal batchNotes As String, ByVal sessionUserName As String) As Long
            'Dim objData As NLData.Michaels.ItemDetail = New NLData.Michaels.ItemDetail()
            Dim recordID As Long
            Try
                Dim objData As New NLData.Michaels.ItemDetail()
                recordID = objData.SaveItemHeaderRecord(objRecord, userID, batchAction, batchNotes, sessionUserName, False)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                recordID = 0
            Finally
                'objData = Nothing
            End Try
            Return recordID
        End Function

        Public Function DeleteItemHeaderRecord(ByVal id As Long, ByVal userID As Integer) As Boolean
            'Dim objData As NLData.Michaels.ItemDetail = New NLData.Michaels.ItemDetail()
            Dim bSuccess As Boolean
            Try
                Dim objData As New NLData.Michaels.ItemDetail()
                bSuccess = objData.DeleteItemHeaderRecord(id, userID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                bSuccess = False
            Finally
                'objData = Nothing
            End Try
            Return bSuccess
        End Function

        Public Function DisableStockingStratBasedOnStockCat(ByVal StockCategory As String, ByVal CanadaStockCategory As String) As Boolean
            Dim bDisableStockingStratBasedOnStockCat As Boolean

            If StockCategory = "D" And CanadaStockCategory = "D" Then
                bDisableStockingStratBasedOnStockCat = True
            ElseIf StockCategory = "W" And CanadaStockCategory = "W" Then
                bDisableStockingStratBasedOnStockCat = False
            ElseIf StockCategory = "D" And CanadaStockCategory = "" Then
                bDisableStockingStratBasedOnStockCat = True
            ElseIf StockCategory = "W" And CanadaStockCategory = "" Then
                bDisableStockingStratBasedOnStockCat = False
            ElseIf StockCategory = "" And CanadaStockCategory = "" Then
                bDisableStockingStratBasedOnStockCat = False
            ElseIf StockCategory = "" And CanadaStockCategory = "D" Then
                bDisableStockingStratBasedOnStockCat = True
            ElseIf StockCategory = "" And CanadaStockCategory = "W" Then
                bDisableStockingStratBasedOnStockCat = False
            End If

            Return bDisableStockingStratBasedOnStockCat

        End Function

        ' *********
        ' * ITEMS *
        ' *********

        Public Function GetRecord(ByVal id As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecord
            'Dim objData As NLData.Michaels.ItemDetail = New NLData.Michaels.ItemDetail()
            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecord = Nothing
            Try
                Dim objData As New NLData.Michaels.ItemDetail()
                objRecord = objData.GetItemRecord(id)

                'Get Multilingual information
                Dim languageDT As DataTable = NovaLibra.Coral.Data.Michaels.ItemDetail.GetItemLanguages(objRecord.ID)
                If languageDT.Rows.Count > 0 Then
                    'For Each language row, set the front end controls
                    For Each language As DataRow In languageDT.Rows
                        Dim ltypeID As Integer = DataHelper.SmartValues(language("Language_Type_ID"), "CInt", False)
                        Dim pli As String = DataHelper.SmartValues(language("Package_Language_Indicator"), "CStr", False)
                        Dim ti As String = DataHelper.SmartValues(language("Translation_Indicator"), "CStr", False)
                        Dim descShort As String = DataHelper.SmartValues(language("Description_Short"), "CStr", False)
                        Dim descLong As String = DataHelper.SmartValues(language("Description_Long"), "CStr", False)
                        Dim exemptEndDate As String = DataHelper.SmartValues(language("Exempt_End_Date"), "CStr", False)
                        Select Case ltypeID
                            Case 1
                                'Set Item Values
                                objRecord.PLIEnglish = pli
                                objRecord.TIEnglish = ti
                                objRecord.EnglishShortDescription = descShort
                                objRecord.EnglishLongDescription = descLong
                            Case 2
                                'Set Item Values
                                objRecord.PLIFrench = pli
                                objRecord.TIFrench = ti
                                objRecord.FrenchShortDescription = descShort
                                objRecord.FrenchLongDescription = descLong
                                objRecord.ExemptEndDateFrench = exemptEndDate
                            Case 3
                                'Set Item Values
                                objRecord.PLISpanish = pli
                                objRecord.TISpanish = ti
                                objRecord.SpanishShortDescription = descShort
                                objRecord.SpanishLongDescription = descLong
                        End Select
                    Next
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                If objRecord Is Nothing Then
                    objRecord = New NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecord()
                End If
                objRecord.ID = -1
            Finally
                'objData = Nothing
            End Try
            Return objRecord
        End Function


        Public Function ApplyPBLToAll(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecord, ByVal userID As Integer) As Boolean
            Dim result As Boolean
            Try
                Dim objData As New NLData.Michaels.ItemDetail()
                result = objData.ApplyPBLToAll(objRecord, userID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                result = False
            Finally
                'objData = Nothing
            End Try
            Return result

        End Function

        Public Sub ClearStockingStrategy(ByVal ItemHeaderID As Int64, ByVal userID As Integer)

            Try
                Dim objData As New NLData.Michaels.ItemDetail()
                objData.ClearStockingStrategy(ItemHeaderID, userID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
            Finally
                'objData = Nothing
            End Try

        End Sub

        Public Function SaveRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemRecord, ByVal userID As Integer, Optional ByVal isDirty As Boolean = True) As Long
            'Dim objData As NLData.Michaels.ItemDetail = New NLData.Michaels.ItemDetail()
            Dim recordID As Long
            Try
                Dim objData As New NLData.Michaels.ItemDetail()
                recordID = objData.SaveItemRecord(objRecord, userID, isDirty)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                recordID = 0
            Finally
                'objData = Nothing
            End Try
            Return recordID
        End Function

        Public Function DeleteRecord(ByVal id As Long, ByVal userID As Integer) As Boolean
            'Dim objData As NLData.Michaels.ItemDetail = New NLData.Michaels.ItemDetail()
            Dim bSuccess As Boolean
            Try
                Dim objData As New NLData.Michaels.ItemDetail()
                bSuccess = objData.DeleteItemRecord(id, userID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                bSuccess = False
            Finally
                'objData = Nothing
            End Try
            Return bSuccess
        End Function

        Public Function GetItemValidationUnknownCount(ByVal itemHeaderID As Long) As Integer
            Dim recCount As Integer
            Try
                Dim objData As New NLData.Michaels.ItemDetail()
                recCount = objData.GetItemValidationUnknownCount(itemHeaderID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                recCount = 0
            End Try
            Return recCount
        End Function

        Public Function GetListCount(ByVal itemHeaderID As Long, ByVal xmlSortCriteria As String, ByVal userID As Long) As Integer
            Dim listCount As Integer
            Try
                Dim objData As New NLData.Michaels.ItemDetail()
                listCount = objData.GetItemListCount(itemHeaderID, xmlSortCriteria, userID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                listCount = 0
            End Try
            Return listCount
        End Function

        Public Function GetList(ByVal itemHeaderID As Long, ByVal startRow As Integer, ByVal pageSize As Integer, ByVal xmlSortCriteria As String, ByVal userID As Long) As ItemList
            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemList = Nothing
            Try
                Dim objData As New NLData.Michaels.ItemDetail()
                objRecord = objData.GetItemList(itemHeaderID, startRow, pageSize, xmlSortCriteria, userID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                If objRecord Is Nothing Then
                    objRecord = New NovaLibra.Coral.SystemFrameworks.Michaels.ItemList()
                End If
                objRecord.TotalRecords = 0
            End Try
            Return objRecord
        End Function


        ' ******************
        ' * ADDITIONAL UPC *
        ' ******************

        Public Function GetItemAdditionalUPCs(ByVal itemHeaderID As Long, ByVal itemID As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.ItemAdditionalUPCRecord
            'Dim objData As NLData.Michaels.ItemDetail = New NLData.Michaels.ItemDetail()
            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemAdditionalUPCRecord = Nothing
            Try
                'Dim objData As New NLData.Michaels.ItemDetail()
                objRecord = NLData.Michaels.AdditionalUPCsData.GetItemAdditionalUPCs(itemHeaderID, itemID)
                ' objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                If objRecord Is Nothing Then
                    objRecord = New NovaLibra.Coral.SystemFrameworks.Michaels.ItemAdditionalUPCRecord()
                End If
                Throw ex
            Finally
                'objData = Nothing
            End Try
            Return objRecord
        End Function

        Public Function SaveItemAdditionalUPCs(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemAdditionalUPCRecord, ByVal userID As Integer) As Boolean
            'Dim objData As NLData.Michaels.ItemDetail = New NLData.Michaels.ItemDetail()
            Dim bSuccess As Boolean
            Try
                'Dim objData As New NLData.Michaels.ItemDetail()
                'bSuccess = objData.SaveItemAdditionalUPCs(objRecord, userID)
                bSuccess = NLData.Michaels.AdditionalUPCsData.SaveItemAdditionalUPCs(objRecord, userID)
                'objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                bSuccess = False
            Finally
                'objData = Nothing
            End Try
            Return bSuccess
        End Function

        Public Function DeleteItemAdditionalUPCFromSequence(ByVal itemHeaderID As Long, ByVal itemID As Long, ByVal startingSequence As Integer) As Boolean
            'Dim objData As NLData.Michaels.ItemDetail = New NLData.Michaels.ItemDetail()
            Dim bSuccess As Boolean
            Try
                'Dim objData As New NLData.Michaels.ItemDetail()
                'bSuccess = objData.DeleteItemAdditionalUPCFromSequence(itemHeaderID, itemID, startingSequence)
                bSuccess = NLData.Michaels.AdditionalUPCsData.DeleteItemAdditionalUPCFromSequence(itemHeaderID, itemID, startingSequence)
                'objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                bSuccess = False
            Finally
                'objData = Nothing
            End Try
            Return bSuccess
        End Function


        ' *****************
        ' * TAX QUESTIONS *
        ' *****************

        Public Function GetTaxWizardData(ByVal itemType As TaxWizardData.TaxWizardItemType, ByVal itemID As Long, ByVal userID As Long) As TaxWizardData
            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.TaxWizardData = Nothing
            Try
                Dim objData As New NLData.Michaels.ItemDetail()
                objRecord = objData.GetTaxWizardDataRecord(itemType, itemID, userID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                If objRecord Is Nothing Then
                    objRecord = New NovaLibra.Coral.SystemFrameworks.Michaels.TaxWizardData
                End If
            End Try
            Return objRecord
        End Function

        Public Function SaveTaxWizardData(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.TaxWizardData, ByVal userID As Long) As Boolean
            Dim ret As Boolean = False
            Try
                Dim objData As New NLData.Michaels.ItemDetail()
                ret = objData.SaveTaxWizardDataRecord(objRecord, userID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
            End Try
            Return ret
        End Function

        Public Function GetTaxUDANumber(ByVal taxUDAID As Long) As Integer
            Dim taxUDANumber As Integer = 0
            Try
                Dim objData As New NLData.Michaels.ItemDetail()
                taxUDANumber = objData.GetTaxUDANumber(taxUDAID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
            End Try
            Return taxUDANumber
        End Function

        Public Function GetTaxQuestions(ByVal taxUDAID As Integer) As TaxQuestions
            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.TaxQuestions = Nothing
            Try
                Dim objData As New NLData.Michaels.ItemDetail()
                objRecord = objData.GetTaxQuestions(taxUDAID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                If objRecord Is Nothing Then
                    objRecord = New NovaLibra.Coral.SystemFrameworks.Michaels.TaxQuestions()
                End If
            End Try
            Return objRecord
        End Function

        ' *****************
        ' * FIELD LOCKING *
        ' *****************

        Public Function GetHeaderFieldLocking(ByVal userID As Long, ByVal vendorID As String, ByVal workflowStageID As Integer) As FieldLocking
            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking = Nothing
            Try
                ' Dim objData As New NLData.Michaels.ImportItemDetail()
                Dim objData As New NLData.Michaels.ItemDetail
                objRecord = objData.GetFieldLocking(userID, MetadataTable.Item_Headers, vendorID, workflowStageID, False)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            End Try
            Return objRecord
        End Function

        Public Function GetItemFieldLocking(ByVal userID As Long, ByVal vendorID As String, ByVal workFlowStageID As Integer) As FieldLocking
            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking = Nothing
            Try
                Dim objData As New NLData.Michaels.ItemDetail
                objRecord = objData.GetFieldLocking(userID, MetadataTable.Items, vendorID, workFlowStageID, True)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            End Try
            Return objRecord
        End Function


        ' ******************
        ' * FIELD AUDITING *
        ' ******************

        Public Function SaveAuditRecordForItemHeader(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.AuditRecord, ByVal itemHeaderID As Long) As Boolean
            Dim ret As Boolean = False
            Try
                Dim objData As New NLData.Michaels.ItemDetail()
                ret = objData.SaveAuditRecordForItemHeader(objRecord, itemHeaderID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
                Throw ex
            End Try
            Return ret
        End Function

    End Class

End Namespace

