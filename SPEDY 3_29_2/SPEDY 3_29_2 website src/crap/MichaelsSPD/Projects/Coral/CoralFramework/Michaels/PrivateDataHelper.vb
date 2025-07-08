
Namespace Michaels

    Public Class FriendDataHelper
        'Private _dateCreated As Date = Date.MinValue
        'Private _createdUserID As Integer = Integer.MinValue
        'Private _dateLastModified As Date = Date.MinValue
        'Private _updateUserID As Integer = Integer.MinValue

        'Private _createdUser As String
        'Private _updateUser As String

        Public Shared Sub SetItemHeaderUserData(ByRef itemHeader As ItemHeaderRecord, _
            ByVal dateCreated As Date, _
            ByVal createdUserID As Integer, _
            ByVal dateLastModified As Date, _
            ByVal updateUserID As Integer, _
            ByVal createdUser As String, _
            ByVal updateUser As String)

            itemHeader.SetReadOnlyUserData(dateCreated, createdUserID, dateLastModified, updateUserID, createdUserID, updateUser)
        End Sub

        Public Shared Sub SetItemHeaderBatchData(ByRef itemHeader As ItemHeaderRecord, ByVal batchID As Long, ByVal batchVendorName As String, ByVal batchStageID As Long, ByVal batchStageName As String, ByVal batchStageType As Integer)
            itemHeader.SetReadOnlyBatchData(batchID, batchVendorName, batchStageID, batchStageName, batchStageType)
        End Sub

        Public Shared Sub SetItemHeaderItemCounts(ByRef itemHeader As ItemHeaderRecord, ByVal unknownCount As Integer, ByVal notValidCount As Integer, ByVal validCount As Integer)
            itemHeader.SetReadOnlyItemCounts(unknownCount, notValidCount, validCount)
        End Sub

        Public Shared Sub SetItemUserData(ByRef item As ItemRecord, _
            ByVal dateCreated As Date, _
            ByVal createdUserID As Integer, _
            ByVal dateLastModified As Date, _
            ByVal updateUserID As Integer, _
            ByVal createdUser As String, _
            ByVal updateUser As String, _
            ByVal imageID As Long, _
            ByVal msdsID As Long)

            item.SetReadOnlyData(dateCreated, createdUserID, dateLastModified, updateUserID, createdUserID, updateUser, imageID, msdsID)
        End Sub

        Public Shared Sub SetItemTaxWizard(ByRef item As ItemRecord, ByVal taxWizard As Boolean)
            item.SetTaxWizard(taxWizard)
        End Sub

        Public Shared Sub SetItemBatchData(ByRef item As ItemRecord, ByVal batchID As Long, ByVal batchStageID As Long, ByVal batchStageName As String, ByVal batchStageType As Integer)
            item.SetReadOnlyBatchData(batchID, batchStageID, batchStageName, batchStageType)
        End Sub

        Public Shared Sub SetImportItemUserData(ByRef item As ImportItemRecord, _
            ByVal dateCreated As Date, _
            ByVal createdUserID As Integer, _
            ByVal dateLastModified As Date, _
            ByVal updateUserID As Integer, _
            ByVal createdUser As String, _
            ByVal updateUser As String, _
            ByVal imageID As Long, _
            ByVal msdsID As Long)

            item.SetReadOnlyData(dateCreated, createdUserID, dateLastModified, updateUserID, createdUser, updateUser, imageID, msdsID)

        End Sub

        Public Shared Sub SetImportItemTaxWizard(ByRef item As ImportItemRecord, ByVal taxWizard As Boolean)
            item.SetTaxWizard(taxWizard)
        End Sub

        Public Shared Sub SetBatchData(ByRef batch As BatchRecord, _
            ByVal dateCreated As Date, _
            ByVal createdUserID As Integer, _
            ByVal dateLastModified As Date, _
            ByVal updateUserID As Integer, _
            ByVal createdUser As String, _
            ByVal updateUser As String, _
            ByVal workflowStageName As String, _
            ByVal workflowStageType As Integer)

            batch.SetReadOnlyData(dateCreated, createdUserID, dateLastModified, updateUserID, createdUser, updateUser, workflowStageName, workflowStageType)

        End Sub

        Public Shared Sub SetFileData(ByRef file As FileRecord, _
            ByVal dateCreated As Date, _
            ByVal createdUserID As Integer, _
            ByVal createdUserName As String)

            file.SetReadOnlyData(dateCreated, createdUserID, createdUserName)

        End Sub

    End Class

End Namespace
