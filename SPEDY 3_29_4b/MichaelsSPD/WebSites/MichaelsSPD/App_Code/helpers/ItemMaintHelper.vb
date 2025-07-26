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

Public Class ItemMaintHelper

    Public Shared Function CalculateDPBatchParent(ByVal batchID As Long, ByVal costChanged As Boolean, ByVal masterWeightChanged As Boolean) As Boolean
        Dim ret As Boolean = False
        Dim validPack As Boolean = True
        Dim userID As Long = DataHelper.SmartValues(HttpContext.Current.Session("UserID"), "long")
        Dim objData As New Data.BatchData()
        Dim batchDetail As Models.BatchRecord = objData.GetBatchRecord(batchID)
        objData = Nothing

        Dim itemList As Models.ItemMaintItemDetailRecordList = Nothing
        Dim itemRec As Models.ItemMaintItemDetailFormRecord = Nothing
        Dim packRec As Models.ItemMaintItemDetailFormRecord = Nothing
        Dim changes As Models.IMTableChanges
        Dim rowChanges As Models.IMRowChanges
        Dim saveRowChanges As Models.IMRowChanges
        Dim i As Integer
        Dim total As Decimal = 0
        Dim totalWeight As Decimal = 0
        Dim qtyInPack As Integer
        Dim itemCost As Decimal
        Dim masterWeight As Decimal

        If batchDetail IsNot Nothing AndAlso batchDetail.IsPack() Then
            ' get the list
            Dim strXML As String = GetDefaultSortAndFilterXML()
            Dim firstRow As Integer = 1
            Dim pageSize As Integer = Data.MaintItemMasterData.GetItemListCount(batchDetail.ID, strXML, userID) + 1
            itemList = Data.MaintItemMasterData.GetItemList(batchDetail.ID, 0, 0, strXML, userID)
            changes = Data.MaintItemMasterData.GetIMChangeRecordsByBatchID(batchDetail.ID)
            'go through the list and calculate cost and find the pack record
            For i = 0 To itemList.ListRecords.Count - 1
                itemRec = itemList.ListRecords.Item(i)
                rowChanges = changes.GetRow(itemRec.ID, True)
                If itemRec.IsPackParent() Then
                    If packRec IsNot Nothing Then
                        ret = False
                        validPack = False
                        Exit For
                    Else
                        packRec = itemRec
                    End If
                Else

                    ' add to total cost
                    qtyInPack = FormHelper.GetValueWithChanges(itemRec.QtyInPack, rowChanges, "QtyInPack", "integer")
                    If itemRec.VendorType = Models.ItemType.Import Then
                        itemCost = FormHelper.GetValueWithChanges(itemRec.ProductCost, rowChanges, "ProductCost", "decimal")
                    Else
                        itemCost = FormHelper.GetValueWithChanges(itemRec.ItemCost, rowChanges, "ItemCost", "decimal")
                    End If

                    If qtyInPack >= 0 AndAlso itemCost >= 0 Then
                        total += (qtyInPack * itemCost)
                    End If

                    ' add to total weight
                    masterWeight = FormHelper.GetValueWithChanges(itemRec.MasterCaseWeight, rowChanges, "MasterCaseWeight", "decimal")
                    If masterWeight >= 0 Then
                        totalWeight += masterWeight
                    End If

                End If
            Next
            ' if valid pack then calculate parent rec
            If validPack AndAlso packRec IsNot Nothing Then
                itemRec = packRec
                rowChanges = changes.GetRow(itemRec.ID, True)
                saveRowChanges = New Models.IMRowChanges(itemRec.ID)


                If costChanged Then
                    ' set the new item cost
                    If itemRec.VendorType = Models.ItemType.Import Then
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.ProductCost, "ProductCost", "decimal", total))
                    Else
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.ItemCost, "ItemCost", "decimal", total))
                    End If

                    ' calc
                    If itemRec.VendorType = Models.ItemType.Import Then

                        ' set values
                        ' ----------
                        ' input vars
                        Dim agent As String = FormHelper.GetValueWithChanges(itemRec.VendorOrAgent, rowChanges, "VendorOrAgent", "string")
                        If agent.Length > 0 AndAlso (agent = "A" Or agent.StartsWith("A")) Then
                            agent = "A"
                        Else
                            agent = String.Empty
                        End If
                        Dim dispcost As Decimal = FormHelper.GetValueWithChanges(itemRec.DisplayerCost, rowChanges, "DisplayerCost", "decimal")
                        'Dim prodcost As Decimal = FormHelper.GetValueWithChanges(itemRec.ProductCost, rowChanges, "ProductCost", "decimal")
                        Dim prodcost As Decimal = total
                        Dim fob As Decimal = FormHelper.GetValueWithChanges(itemRec.FOBShippingPoint, rowChanges, "FOBShippingPoint", "decimal")
                        Dim dutyper As Decimal = FormHelper.GetValueWithChanges(itemRec.DutyPercent, rowChanges, "DutyPercent", "decimal")
                        If dutyper <> Decimal.MinValue Then dutyper = dutyper * 100
                        Dim addduty As Decimal = FormHelper.GetValueWithChanges(itemRec.AdditionalDutyAmount, rowChanges, "AdditionalDutyAmount", "decimal")

                        Dim supptariffper As Decimal = FormHelper.GetValueWithChanges(itemRec.SuppTariffPercent, rowChanges, "SuppTariffPercent", "decimal")
                        If supptariffper <> Decimal.MinValue Then supptariffper = supptariffper * 100

                        Dim eachesmc As Decimal = FormHelper.GetValueWithChanges(itemRec.EachesMasterCase, rowChanges, "EachesMasterCase", "decimal")
                        Dim mclength As Decimal = FormHelper.GetValueWithChanges(itemRec.MasterCaseLength, rowChanges, "MasterCaseLength", "decimal")
                        Dim mcwidth As Decimal = FormHelper.GetValueWithChanges(itemRec.MasterCaseWidth, rowChanges, "MasterCaseWidth", "decimal")
                        Dim mcheight As Decimal = FormHelper.GetValueWithChanges(itemRec.MasterCaseHeight, rowChanges, "MasterCaseHeight", "decimal")
                        Dim oceanfre As Decimal = FormHelper.GetValueWithChanges(itemRec.OceanFreightAmount, rowChanges, "OceanFreightAmount", "decimal")
                        Dim oceanamt As Decimal = FormHelper.GetValueWithChanges(itemRec.OceanFreightComputedAmount, rowChanges, "OceanFreightComputedAmount", "decimal")
                        Dim agentcommper As Decimal = FormHelper.GetValueWithChanges(itemRec.AgentCommissionPercent, rowChanges, "AgentCommissionPercent", "decimal")
                        If agentcommper <> Decimal.MinValue Then agentcommper = agentcommper * 100
                        Dim otherimportper As Decimal = FormHelper.GetValueWithChanges(itemRec.OtherImportCostsPercent, rowChanges, "OtherImportCostsPercent", "decimal")
                        If otherimportper <> Decimal.MinValue Then otherimportper = otherimportper * 100
                        Dim packcost As Decimal = Decimal.MinValue
                        ' calculated vars
                        fob = CalculationHelper.CalcImportFOB(dispcost, prodcost)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.FOBShippingPoint, "FOBShippingPoint", "decimal", fob))

                        Dim cubicftpermc As Decimal = CalculationHelper.CalcImportCubicFeetPerMasterCarton(mclength, mcwidth, mcheight)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.MasterCaseCube, "MasterCaseCube", "decimal", cubicftpermc))

                        Dim duty As Decimal = CalculationHelper.CalcImportDuty(fob, dutyper)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.DutyAmount, "DutyAmount", "decimal", duty))

                        Dim supptariff As Decimal = CalculationHelper.CalcSuppTariff(fob, supptariffper)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.SuppTariffAmount, "SuppTariffAmount", "decimal", supptariff))

                        Dim ocean As Decimal = CalculationHelper.CalcImportOceanFrieght(eachesmc, cubicftpermc, oceanfre)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.OceanFreightComputedAmount, "OceanFreightComputedAmount", "decimal", ocean))

                        Dim agentcomm As Decimal = CalculationHelper.CalcImportAgentComm(agent, fob, agentcommper)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.AgentCommissionAmount, "AgentCommissionAmount", "decimal", agentcomm))

                        Dim otherimport As Decimal = CalculationHelper.CalcOtherImportCost(fob, otherimportper)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.OtherImportCostsAmount, "OtherImportCostsAmount", "decimal", otherimport))

                        Dim totalimport As Decimal = CalculationHelper.CalcImportTotalImport(agent, fob, duty, addduty, ocean, agentcomm, otherimport, packcost, supptariff)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.ImportBurden, "ImportBurden", "decimal", totalimport))

                        Dim totalcost As Decimal = CalculationHelper.CalcImportTotalCost(fob, totalimport)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.WarehouseLandedCost, "WarehouseLandedCost", "decimal", totalcost))

                        Dim outfreight As Decimal = CalculationHelper.CalcImportOutboundFreight(totalcost)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.OutboundFreight, "OutboundFreight", "decimal", outfreight))

                        Dim ninewhse As Decimal = CalculationHelper.CalcImportOutboundFreight(totalcost, outfreight)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.NinePercentWhseCharge, "NinePercentWhseCharge", "decimal", ninewhse))

                        Dim totalstore As Decimal = CalculationHelper.CalcImportTotalStore(totalcost, outfreight, ninewhse)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.TotalStoreLandedCost, "TotalStoreLandedCost", "decimal", totalstore))

                    ElseIf itemRec.VendorType = Models.ItemType.Domestic Then
                        Dim it As String = String.Empty
                        Dim auc As Decimal = Decimal.MinValue
                        Dim pii As String = String.Empty
                        Dim icost As Decimal = Decimal.MinValue
                        Dim ticost As Decimal = Decimal.MinValue
                        Dim cresult As String = String.Empty

                        it = FormHelper.GetValueWithChanges(itemRec.ItemType, rowChanges, "ItemType", "string")
                        auc = FormHelper.GetValueWithChanges(itemRec.DisplayerCost, rowChanges, "DisplayerCost", "decimal")
                        pii = FormHelper.GetValueWithChanges(itemRec.PackItemIndicator, rowChanges, "PackItemIndicator", "string")
                        icost = total

                        ticost = CalculationHelper.CalculateIMTotalCost(it, auc, pii, icost)
                        saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.FOBShippingPoint, "FOBShippingPoint", "decimal", ticost))
                    End If
                End If


                'NAK - Per Michaels Decision on 1/17/2012, remove the weight rollup calculation for the pack item altogether
                'If masterWeightChanged Then
                '   saveRowChanges.Add(FormHelper.CreateChangeRecord(itemRec.MasterCaseWeight, "MasterCaseWeight", "decimal", totalWeight))
                'End If


                ' save the changes
                Data.MaintItemMasterData.SaveItemMaintChanges(saveRowChanges, userID)

                ' set return value
                ret = True
            End If
            ' clean up
            itemRec = Nothing
            itemList = Nothing
            changes = Nothing
        End If
        batchDetail = Nothing

        Return ret
    End Function


    Protected Shared Function GetDefaultSortAndFilterXML() As String

        Dim XMLStr As String = "<Root>"
        ' sort
        XMLStr += "<Sort><Parameter SortID=""1"" intColOrdinal=""0"" intDirection=""0"" /></Sort>"
        ' filter
        XMLStr += "<Filter/>"
        ' close
        XMLStr = "<?xml version=""1.0"" encoding=""utf-8"" ?>" & XMLStr & "</Root>"
        ' return 
        Return XMLStr

    End Function

End Class
