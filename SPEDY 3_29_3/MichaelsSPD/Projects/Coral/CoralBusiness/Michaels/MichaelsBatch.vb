Imports System
Imports System.Data

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks.Michaels


Namespace Michaels

    Public Class MichaelsBatch

        Public Function GetRecord(ByVal id As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord

            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord = Nothing
            Try
                Dim objData As New NLData.Michaels.BatchData()
                objRecord = objData.GetBatchRecord(id)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                If objRecord Is Nothing Then
                    objRecord = New NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord()
                End If
                objRecord.ID = -1
            Finally
                'objData = Nothing
            End Try
            Return objRecord

        End Function

        Public Function SaveRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord, ByVal userID As Integer) As Long

            Dim recordID As Long
            Try
                Dim objData As New NLData.Michaels.BatchData()
                recordID = objData.SaveBatchRecord(objRecord, userID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                recordID = 0
            Finally
                'objData = Nothing
            End Try
            Return recordID

        End Function

        Public Function SaveRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.BatchRecord, ByVal userID As Integer, ByVal BatchAction As String, ByVal BatchNotes As String) As Long

            Dim recordID As Long
            Try
                Dim objData As New NLData.Michaels.BatchData()
                recordID = objData.SaveBatchRecord(objRecord, userID, BatchAction, BatchNotes)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                recordID = 0
            Finally
                'objData = Nothing
            End Try
            Return recordID

        End Function

        Public Function DeleteRecord(ByVal id As Long) As Boolean

            Dim bSuccess As Boolean
            Try
                Dim objData As New NLData.Michaels.BatchData()
                bSuccess = objData.DeleteBatchRecord(id)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                bSuccess = False
            Finally
                'objData = Nothing
            End Try
            Return bSuccess

        End Function


        ' ******************
        ' * WORKFLOW STAGE *
        ' ******************

        Public Function GetStageList(Optional ByVal workflowID As Integer = 0) As ArrayList
            Dim objRecord As ArrayList = Nothing
            Try
                Dim objData As New NLData.Michaels.BatchData()
                objRecord = objData.GetStageList(0, workflowID)
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                If objRecord Is Nothing Then
                    objRecord = New ArrayList()
                End If
            End Try
            Return objRecord
        End Function


        ' *****************
        ' * FINELINE DEPT *
        ' *****************

        Public Function GetDeptList() As ArrayList
            Dim objRecord As ArrayList = Nothing
            Try
                Dim objData As New NLData.Michaels.BatchData()
                objRecord = objData.GetDeptList()
                objData = Nothing
            Catch ex As Exception
                Logger.LogError(ex)
                If objRecord Is Nothing Then
                    objRecord = New ArrayList()
                End If
            End Try
            Return objRecord
        End Function


        ' ***********************
        ' * PRICE POINT LOOKUPS *
        ' ***********************

        Public Shared Function LookupAlaskRetailFromBaseRetail(ByVal baseRetail As Decimal) As NovaLibra.Coral.SystemFrameworks.Michaels.PricePointRecord

            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.PricePointRecord = Nothing
            Dim diffZoneID As Integer = 4
            Dim objData As New NLData.Michaels.BatchData()
            Try
                objRecord = objData.GetPricePointRecord(diffZoneID, baseRetail)
            Catch ex As Exception
                Logger.LogError(ex)
                objRecord = Nothing
            Finally
                objData = Nothing
            End Try
            Return objRecord

        End Function

        ' *******************
        ' * COUNTRY LOOKUPS *
        ' *******************

        Public Shared Function LookupCountry(ByVal country As String) As NovaLibra.Coral.SystemFrameworks.Michaels.CountryRecord

            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.CountryRecord = Nothing
            Dim objData As New NLData.Michaels.BatchData()
            Try
                objRecord = objData.GetCountryRecord(country)
            Catch ex As Exception
                Logger.LogError(ex)
                objRecord = Nothing
            Finally
                objData = Nothing
            End Try
            Return objRecord

        End Function

        Public Shared Function LookupCountries(ByVal countryPart As String) As ArrayList

            Dim objRecord As ArrayList = Nothing
            Dim objData As New NLData.Michaels.BatchData()
            Try
                objRecord = objData.GetCountries(countryPart)
            Catch ex As Exception
                Logger.LogError(ex)
                objRecord = Nothing
            Finally
                objData = Nothing
            End Try
            If objRecord Is Nothing Then
                objRecord = New ArrayList()
            End If
            Return objRecord

        End Function

        ' ***********************
        ' * ITEM MASTER LOOKUPS *
        ' ***********************

        Public Shared Function LookupItemMaster(ByVal itemSKU As String) As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMasterRecord

            Dim objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMasterRecord = Nothing
            Dim objData As New NLData.Michaels.BatchData()
            Try
                objRecord = objData.GetItemMasterRecord(itemSKU)
            Catch ex As Exception
                Logger.LogError(ex)
                objRecord = Nothing
            Finally
                objData = Nothing
            End Try
            Return objRecord

        End Function


    End Class

End Namespace

