Imports System
Imports System.Data

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks.Michaels


Namespace Michaels

    Public Class MichaelsValidation

        ' *******************
        ' * VALIDATION DATA *
        ' *******************

        Public Shared Function SetIsValidFlags(ByRef valErrors As ArrayList, ByVal userID As Long) As Boolean
            Dim ret As Boolean = False
            Dim objRecord As SetValidationPerItemRecord = New SetValidationPerItemRecord()
            Dim vr As ValidationRecord
            Dim ivf As ItemValidFlag
            For i As Integer = 0 To valErrors.Count - 1
                If TypeOf valErrors.Item(i) Is ValidationRecord Then
                    vr = CType(valErrors.Item(i), ValidationRecord)
                    If vr.IsValid Then
                        ivf = ItemValidFlag.Valid
                    Else
                        ivf = ItemValidFlag.NotValid
                    End If
                    objRecord.Add(vr.RecordID, vr.RecordType, ivf)
                End If
            Next
            Try
                Dim objData As New NLData.Michaels.ValidationData()
                ret = objData.SetIsValidPerItem(objRecord, userID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
            End Try
            Return ret
        End Function

        Public Shared Function SetIsValidFlags(ByRef valError As ValidationRecord, ByVal userID As Long) As Boolean
            Dim ret As Boolean = False
            Dim objRecord As SetValidationRecord = New SetValidationRecord(valError.RecordID, valError.RecordType)
            If valError.IsValid Then
                objRecord.IsValid = ItemValidFlag.Valid
            Else
                objRecord.IsValid = ItemValidFlag.NotValid
            End If
            Try
                Dim objData As New NLData.Michaels.ValidationData()
                ret = objData.SetIsValid(objRecord, userID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
            End Try
            Return ret
        End Function

        Public Shared Function SetIsValidFlags(ByRef objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.SetValidationRecord, ByVal userID As Long) As Boolean
            Dim ret As Boolean = False
            Try
                Dim objData As New NLData.Michaels.ValidationData()
                ret = objData.SetIsValid(objRecord, userID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
            End Try
            Return ret
        End Function

        ' ********************
        ' * BATCH VALIDATION *
        ' ********************

        Public Shared Function BatchValidationLookup(ByRef batchLookup As BatchValidationLookupRecord) As Boolean
            Return NLData.Michaels.ValidationData.BatchValidationLookup(batchLookup)
        End Function

        Public Shared Function ItemMaintBatchValidationLookup(ByRef batchLookup As BatchValidationLookupRecord) As Boolean
            Return NLData.Michaels.ValidationData.ItemMaintBatchValidationLookup(batchLookup)
        End Function

        ' **************************
        ' * ITEM HEADER VALIDATION *
        ' **************************

        Public Shared Function ItemHeaderValidationLookup(ByRef itemHeaderLookup As ItemHeaderValidationLookupRecord) As Boolean
            Dim objData As New NLData.Michaels.ValidationData()
            Dim bRet As Boolean = objData.ItemHeaderValidationLookup(itemHeaderLookup)
            objData = Nothing
            Return bRet
        End Function

        ' *******************
        ' * ITEM VALIDATION *
        ' *******************

        Public Shared Function ItemValidationLookup(ByRef itemLookup As ItemValidationLookupRecord) As Boolean
            Dim objData As New NLData.Michaels.ValidationData()
            Dim bRet As Boolean = objData.ItemValidationLookup(itemLookup)
            objData = Nothing
            Return bRet
        End Function

        Public Shared Function ImportItemValidationLookup(ByRef itemLookup As ImportItemValidationLookupRecord) As Boolean
            Dim objData As New NLData.Michaels.ValidationData()
            Dim bRet As Boolean = objData.ImportItemValidationLookup(itemLookup)
            objData = Nothing
            Return bRet
        End Function

    End Class

End Namespace

