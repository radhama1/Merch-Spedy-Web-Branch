Imports System
Imports System.Data

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks.Michaels


Namespace Michaels

    Public Class MichaelsImportItemDetail
        Inherits MichaelsFieldAuditing

        ' *********
        ' * ITEMS *
        ' *********

        Public Function GetRecord(ByVal id As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord

            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord = Nothing
            Try
                Dim objData As New NLData.Michaels.ImportItemDetail()
                objRecord = objData.GetItemRecord(id)

                'GET Language Information for the Item
                If objRecord.ID > 0 Then
                    'Get language settings from SPD_Import_Item_Languages
                    Dim languageDT As DataTable = Data.Michaels.ImportItemDetail.GetImportItemLanguages(objRecord.ID)
                    If languageDT.Rows.Count > 0 Then
                        'For Each language row, set the front end controls
                        For Each language As DataRow In languageDT.Rows
                            Dim languageTypeID As Integer = DataHelper.SmartValues(language("Language_Type_ID"), "CInt", False)
                            Dim pli As String = DataHelper.SmartValues(language("Package_Language_Indicator"), "CStr", False)
                            Dim ti As String = DataHelper.SmartValues(language("Translation_Indicator"), "CStr", False)
                            Dim descShort As String = DataHelper.SmartValues(language("Description_Short"), "CStr", False)
                            Dim descLong As String = DataHelper.SmartValues(language("Description_Long"), "CStr", False)
                            Dim exemptEndDate As String = DataHelper.SmartValues(language("Exempt_End_Date"), "CStr", False)
                            Select Case languageTypeID
                                Case 1
                                    objRecord.PLIEnglish = pli
                                    objRecord.TIEnglish = ti
                                    objRecord.EnglishShortDescription = descShort
                                    objRecord.EnglishLongDescription = descLong
                                Case 2
                                    objRecord.PLIFrench = pli
                                    objRecord.TIFrench = ti
                                    objRecord.FrenchShortDescription = descShort
                                    objRecord.FrenchLongDescription = descLong
                                    objRecord.ExemptEndDateFrench = exemptEndDate
                                Case 3
                                    objRecord.PLISpanish = pli
                                    objRecord.TISpanish = "N" 'TI Spanish not implemented.  Always set to No.
                                    objRecord.SpanishShortDescription = descShort
                                    objRecord.SpanishLongDescription = descLong
                            End Select
                        Next
                    Else
                        'Default English - Translation Indicator to YES for New items (only needed when item exists, but no TI Record yet in DB)
                        objRecord.TIEnglish = "Y"
                    End If
                End If

                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                If objRecord Is Nothing Then
                    objRecord = New NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord()
                End If
                objRecord.ID = -1
            Finally
                'objData = Nothing
            End Try
            Return objRecord

        End Function

        Public Function SaveRecord(ByVal isDirty As Boolean, ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord, ByVal userID As Integer) As Long

            Dim recordID As Long
            Try
                Dim objData As New NLData.Michaels.ImportItemDetail()
                recordID = objData.SaveItemRecord(objRecord, userID, False, "", "", False, isDirty)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                recordID = 0
            Finally
                'objData = Nothing
            End Try
            Return recordID

        End Function
        Public Function SaveRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord, ByVal userID As Integer, ByVal SaveImage As Boolean) As Long

            Dim recordID As Long
            Try
                Dim objData As New NLData.Michaels.ImportItemDetail()
                recordID = objData.SaveItemRecord(objRecord, userID, SaveImage, "", "")
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                recordID = 0
            Finally
                'objData = Nothing
            End Try
            Return recordID

        End Function

        Public Function SaveRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord, ByVal userID As Integer, ByVal SaveImage As Boolean, ByVal BatchAction As String, ByVal BatchNotes As String, Optional ByVal isDirty As Boolean = True) As Long

            Dim recordID As Long
            Try
                Dim objData As New NLData.Michaels.ImportItemDetail()
                recordID = objData.SaveItemRecord(objRecord, userID, False, BatchAction, BatchNotes, False, isDirty)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                recordID = 0
            Finally
                'objData = Nothing
            End Try
            Return recordID

        End Function

        Public Function ApplyPBLToAll(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord, ByVal userID As Integer) As Boolean
            Dim result As Boolean
            Try
                Dim objData As New NLData.Michaels.ImportItemDetail()
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

        Public Function DeleteRecord(ByVal id As Long, ByVal userID As Integer) As Boolean

            Dim bSuccess As Boolean
            Try
                Dim objData As New NLData.Michaels.ImportItemDetail()
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

        Public Function DuplicateRecord(ByVal id As Long, ByVal userID As Long) As Long
            Dim newid As Long = 0
            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord = Nothing
            objRecord = GetRecord(id)
            If Not objRecord Is Nothing Then
                If objRecord.ParentID = 0 Then
                    objRecord.ParentID = objRecord.ID
                    objRecord.ID = 0
                    'Set isDirty to TRUE
                    newid = SaveRecord(True, objRecord, userID)
                Else
                    newid = -1
                End If
            End If
            Return newid
        End Function

        Public Function DuplicateRecord(ByRef objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord, ByVal userID As Long) As Long
            Dim newid As Long = 0
            If Not objRecord Is Nothing Then
                If objRecord.ParentID = 0 Then
                    objRecord.ParentID = objRecord.ID
                End If
                objRecord.ID = 0
                'Set isDirty to TRUE
                newid = SaveRecord(True, objRecord, userID)
            End If
            Return newid
        End Function

        Public Function GetChildItems(ByVal id As Long, ByVal includeParent As Boolean) As ArrayList
            Dim objList As ArrayList
            Dim objData As New NLData.Michaels.ImportItemDetail()
            objList = objData.GetChildItems(id, includeParent)
            objData = Nothing
            Return objList
        End Function

        Public Function GetAddToBatchRecords(ByVal id As Long) As ArrayList
            Dim objList As ArrayList
            Dim objData As New NLData.Michaels.ImportItemDetail()
            objList = objData.GetAddToBatchRecords(id)
            objData = Nothing
            Return objList
        End Function

        Public Function AddToBatch(ByVal id As Long, ByVal fromBatchID As Long, ByVal userID As Integer) As Boolean
            Dim bSuccess As Boolean
            Dim objData As New NLData.Michaels.ImportItemDetail()
            bSuccess = objData.AddToBatch(id, fromBatchID, userID)
            objData = Nothing
            Return bSuccess
        End Function


        ' *****************
        ' * FIELD LOCKING *
        ' *****************

        Public Function GetFieldLocking(ByVal userID As Long, ByVal vendorID As Integer, ByVal workFlowStageID As Integer) As FieldLocking
            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.FieldLocking = Nothing
            Try
                Dim objData As New NLData.Michaels.ImportItemDetail()
                objRecord = objData.GetFieldLocking(userID, MetadataTable.Import_Items, vendorID, workFlowStageID, False)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            End Try
            Return objRecord
        End Function

    End Class

End Namespace

