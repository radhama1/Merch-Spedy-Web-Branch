Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels

    Public Class ImportItemDetail
        Inherits FieldLockingData

        ' *********
        ' * ITEMS *
        ' *********

        Public Shared Function IsPack(ByVal batchID As Long) As Boolean
            Dim pack As Boolean = False
            Dim recCount As Integer = 0
            Dim sql As String = "select count(ID) as RecordCount from SPD_Import_Items where Batch_ID = @batchID and COALESCE(RTRIM(REPLACE(LEFT([PackItemIndicator],2), '-', '')), '') IN ('D','DP','SB')"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection(False)
                conn.Open()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@batchID", SqlDbType.BigInt).Value = batchID
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                If reader.Read() Then
                    recCount = DataHelper.SmartValues(reader.Item("RecordCount"), "integer", False)
                End If
                If recCount > 0 Then
                    pack = True
                End If
            Catch sqlex As SqlException
                Logger.LogError(sqlex)
                Throw sqlex
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                cmd = Nothing
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return pack
        End Function

        Public Function GetItemRecord(ByVal id As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord
            Dim objRecord As ImportItemRecord = New ImportItemRecord()
            Dim sql As String = "sp_SPD_Import_Item_GetRecord"
            Dim reader As SqlDataReader = Nothing
            Dim command As SqlCommand = Nothing
            Dim conn As SqlConnection = Nothing

            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = New SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("AppConnection").ConnectionString)
                command = New SqlCommand()
                command.Connection = conn
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Value = id
                command.Parameters.Add(objParam)
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure
                command.Connection.Open()
                reader = command.ExecuteReader()

                If reader.Read() Then
                    With reader
                        objRecord.ID = DataHelper.SmartValues(.Item("ID"), "long", True)
                        objRecord.Batch_ID = DataHelper.SmartValues(.Item("Batch_ID"), "long", True)
                        objRecord.DateSubmitted = DataHelper.SmartValues(.Item("DateSubmitted"), "date", True)
                        objRecord.Vendor = DataHelper.SmartValues(.Item("Vendor"), "string", True)
                        objRecord.Agent = DataHelper.SmartValues(.Item("Agent"), "string", True)
                        objRecord.AgentType = DataHelper.SmartValues(.Item("AgentType"), "string", True)
                        objRecord.Buyer = DataHelper.SmartValues(.Item("Buyer"), "string", True)
                        objRecord.Fax = DataHelper.SmartValues(.Item("Fax"), "string", True)
                        objRecord.EnteredBy = DataHelper.SmartValues(.Item("EnteredBy"), "string", True)
                        objRecord.SKUGroup = DataHelper.SmartValues(.Item("SKUGroup"), "string", True)
                        objRecord.Email = DataHelper.SmartValues(.Item("Email"), "string", True)
                        objRecord.EnteredDate = DataHelper.SmartValues(.Item("EnteredDate"), "date", True)
                        objRecord.Dept = DataHelper.SmartValues(.Item("Dept"), "string", True)
                        objRecord.Class = DataHelper.SmartValues(.Item("Class"), "string", True)
                        objRecord.SubClass = DataHelper.SmartValues(.Item("SubClass"), "string", True)
                        objRecord.PrimaryUPC = DataHelper.SmartValues(.Item("PrimaryUPC"), "string", True)
                        objRecord.MichaelsSKU = DataHelper.SmartValues(.Item("MichaelsSKU"), "string", True)
                        objRecord.GenerateMichaelsUPC = DataHelper.SmartValues(.Item("GenerateMichaelsUPC"), "string", True)
                        'PMO200141 GTIN14 Enhancements changes Start
                        objRecord.InnerGTIN = DataHelper.SmartValues(.Item("InnerGTIN"), "string", True)
                        objRecord.CaseGTIN = DataHelper.SmartValues(.Item("CaseGTIN"), "string", True)
                        objRecord.GenerateMichaelsGTIN = DataHelper.SmartValues(.Item("GenerateMichaelsGTIN"), "string", True)
                        'PMO200141 GTIN14 Enhancements End
                        'objRecord.AdditionalUPC1 = DataHelper.SmartValues(.Item("AdditionalUPC1"), "string", True)
                        'objRecord.AdditionalUPC2 = DataHelper.SmartValues(.Item("AdditionalUPC2"), "string", True)
                        'objRecord.AdditionalUPC3 = DataHelper.SmartValues(.Item("AdditionalUPC3"), "string", True)
                        'objRecord.AdditionalUPC4 = DataHelper.SmartValues(.Item("AdditionalUPC4"), "string", True)
                        'objRecord.AdditionalUPC5 = DataHelper.SmartValues(.Item("AdditionalUPC5"), "string", True)
                        'objRecord.AdditionalUPC6 = DataHelper.SmartValues(.Item("AdditionalUPC6"), "string", True)
                        'objRecord.AdditionalUPC7 = DataHelper.SmartValues(.Item("AdditionalUPC7"), "string", True)
                        'objRecord.AdditionalUPC8 = DataHelper.SmartValues(.Item("AdditionalUPC8"), "string", True)
                        objRecord.PackSKU = DataHelper.SmartValues(.Item("PackSKU"), "string", True)
                        objRecord.PlanogramName = DataHelper.SmartValues(.Item("PlanogramName"), "string", True)
                        objRecord.VendorNumber = DataHelper.SmartValues(.Item("VendorNumber"), "string", True)
                        objRecord.VendorRank = DataHelper.SmartValues(.Item("VendorRank"), "string", True)
                        objRecord.ItemTask = DataHelper.SmartValues(.Item("ItemTask"), "string", True)
                        objRecord.Description = DataHelper.SmartValues(.Item("Description"), "string", True)
                        objRecord.QuoteSheetStatus = DataHelper.SmartValues(.Item("QuoteSheetStatus"), "string", True)
                        objRecord.Season = DataHelper.SmartValues(.Item("Season"), "string", True)
                        'removed 2020-09-11
                        'objRecord.PaymentTerms = DataHelper.SmartValues(.Item("PaymentTerms"), "string", True)
                        'objRecord.Days = UCase(DataHelper.SmartValues(.Item("Days"), "string", True)) 'lp SPEDY order 12 02 2009
                        objRecord.VendorMinOrderAmount = DataHelper.SmartValues(.Item("VendorMinOrderAmount"), "string", True)
                        objRecord.VendorName = DataHelper.SmartValues(.Item("VendorName"), "string", True)
                        objRecord.VendorAddress1 = DataHelper.SmartValues(.Item("VendorAddress1"), "string", True)
                        objRecord.VendorAddress2 = DataHelper.SmartValues(.Item("VendorAddress2"), "string", True)
                        objRecord.VendorAddress3 = DataHelper.SmartValues(.Item("VendorAddress3"), "string", True)
                        objRecord.VendorAddress4 = DataHelper.SmartValues(.Item("VendorAddress4"), "string", True)
                        objRecord.VendorContactName = DataHelper.SmartValues(.Item("VendorContactName"), "string", True)
                        objRecord.VendorContactPhone = DataHelper.SmartValues(.Item("VendorContactPhone"), "string", True)
                        objRecord.VendorContactEmail = DataHelper.SmartValues(.Item("VendorContactEmail"), "string", True)
                        objRecord.VendorContactFax = DataHelper.SmartValues(.Item("VendorContactFax"), "string", True)
                        objRecord.ManufactureName = DataHelper.SmartValues(.Item("ManufactureName"), "string", True)
                        objRecord.ManufactureAddress1 = DataHelper.SmartValues(.Item("ManufactureAddress1"), "string", True)
                        objRecord.ManufactureAddress2 = DataHelper.SmartValues(.Item("ManufactureAddress2"), "string", True)
                        objRecord.ManufactureContact = DataHelper.SmartValues(.Item("ManufactureContact"), "string", True)
                        objRecord.ManufacturePhone = DataHelper.SmartValues(.Item("ManufacturePhone"), "string", True)
                        objRecord.ManufactureEmail = DataHelper.SmartValues(.Item("ManufactureEmail"), "string", True)
                        objRecord.ManufactureFax = DataHelper.SmartValues(.Item("ManufactureFax"), "string", True)
                        objRecord.AgentContact = DataHelper.SmartValues(.Item("AgentContact"), "string", True)
                        objRecord.AgentPhone = DataHelper.SmartValues(.Item("AgentPhone"), "string", True)
                        objRecord.AgentEmail = DataHelper.SmartValues(.Item("AgentEmail"), "string", True)
                        objRecord.AgentFax = DataHelper.SmartValues(.Item("AgentFax"), "string", True)
                        objRecord.VendorStyleNumber = DataHelper.SmartValues(.Item("VendorStyleNumber"), "string", True)
                        objRecord.HarmonizedCodeNumber = DataHelper.SmartValues(.Item("HarmonizedCodeNumber"), "string", True)
                        objRecord.DetailInvoiceCustomsDesc = DataHelper.SmartValues(.Item("DetailInvoiceCustomsDesc"), "string", True)
                        objRecord.ComponentMaterialBreakdown = DataHelper.SmartValues(.Item("ComponentMaterialBreakdown"), "string", True)
                        objRecord.ComponentConstructionMethod = DataHelper.SmartValues(.Item("ComponentConstructionMethod"), "string", True)
                        objRecord.IndividualItemPackaging = DataHelper.SmartValues(.Item("IndividualItemPackaging"), "string", True)
                        objRecord.EachInsideMasterCaseBox = DataHelper.SmartValues(.Item("EachInsideMasterCaseBox"), "string", True)
                        objRecord.EachInsideInnerPack = DataHelper.SmartValues(.Item("EachInsideInnerPack"), "string", True)
                        'objRecord.EachPieceNetWeightLbsPerOunce = DataHelper.SmartValues(.Item("EachPieceNetWeightLbsPerOunce"), "string", True)
                        objRecord.ReshippableInnerCartonLength = DataHelper.SmartValues(.Item("ReshippableInnerCartonLength"), "string", True)
                        objRecord.ReshippableInnerCartonWidth = DataHelper.SmartValues(.Item("ReshippableInnerCartonWidth"), "string", True)
                        objRecord.ReshippableInnerCartonHeight = DataHelper.SmartValues(.Item("ReshippableInnerCartonHeight"), "string", True)
                        objRecord.MasterCartonDimensionsLength = DataHelper.SmartValues(.Item("MasterCartonDimensionsLength"), "string", True)
                        objRecord.MasterCartonDimensionsWidth = DataHelper.SmartValues(.Item("MasterCartonDimensionsWidth"), "string", True)
                        objRecord.MasterCartonDimensionsHeight = DataHelper.SmartValues(.Item("MasterCartonDimensionsHeight"), "string", True)
                        objRecord.CubicFeetPerMasterCarton = DataHelper.SmartValues(.Item("CubicFeetPerMasterCarton"), "string", True)
                        objRecord.WeightMasterCarton = DataHelper.SmartValues(.Item("WeightMasterCarton"), "string", True)
                        objRecord.CubicFeetPerInnerCarton = DataHelper.SmartValues(.Item("CubicFeetPerInnerCarton"), "string", True)
                        objRecord.FOBShippingPoint = DataHelper.SmartValues(.Item("FOBShippingPoint"), "string", True)
                        objRecord.DutyPercent = DataHelper.SmartValues(.Item("DutyPercent"), "string", True)
                        objRecord.DutyAmount = DataHelper.SmartValues(.Item("DutyAmount"), "string", True)
                        objRecord.AdditionalDutyComment = DataHelper.SmartValues(.Item("AdditionalDutyComment"), "string", True)
                        objRecord.AdditionalDutyAmount = DataHelper.SmartValues(.Item("AdditionalDutyAmount"), "string", True)
                        objRecord.OceanFreightAmount = DataHelper.SmartValues(.Item("OceanFreightAmount"), "string", True)
                        objRecord.OceanFreightComputedAmount = DataHelper.SmartValues(.Item("OceanFreightComputedAmount"), "string", True)
                        objRecord.AgentCommissionPercent = DataHelper.SmartValues(.Item("AgentCommissionPercent"), "string", True)
                        objRecord.RecAgentCommissionPercent = DataHelper.SmartValues(.Item("RecAgentCommissionPercent"), "string", True)
                        objRecord.AgentCommissionAmount = DataHelper.SmartValues(.Item("AgentCommissionAmount"), "string", True)
                        objRecord.OtherImportCostsPercent = DataHelper.SmartValues(.Item("OtherImportCostsPercent"), "string", True)
                        objRecord.OtherImportCostsAmount = DataHelper.SmartValues(.Item("OtherImportCostsAmount"), "string", True)
                        objRecord.PackagingCostAmount = DataHelper.SmartValues(.Item("PackagingCostAmount"), "string", True)
                        objRecord.TotalImportBurden = DataHelper.SmartValues(.Item("TotalImportBurden"), "string", True)
                        objRecord.WarehouseLandedCost = DataHelper.SmartValues(.Item("WarehouseLandedCost"), "string", True)
                        objRecord.PurchaseOrderIssuedTo = DataHelper.SmartValues(.Item("PurchaseOrderIssuedTo"), "string", True)
                        objRecord.ShippingPoint = DataHelper.SmartValues(.Item("ShippingPoint"), "string", True)
                        objRecord.CountryOfOrigin = DataHelper.SmartValues(.Item("CountryOfOrigin"), "string", True)
                        objRecord.CountryOfOriginName = DataHelper.SmartValues(.Item("CountryOfOriginName"), "string", True)
                        objRecord.VendorComments = DataHelper.SmartValues(.Item("VendorComments"), "string", True)
                        objRecord.StockCategory = DataHelper.SmartValues(.Item("StockCategory"), "string", True)
                        objRecord.FreightTerms = DataHelper.SmartValues(.Item("FreightTerms"), "string", True)
                        objRecord.ItemType = DataHelper.SmartValues(.Item("ItemType"), "string", True)
                        objRecord.PackItemIndicator = DataHelper.SmartValues(.Item("PackItemIndicator"), "string", True)
                        objRecord.ItemTypeAttribute = DataHelper.SmartValues(.Item("ItemTypeAttribute"), "string", True)
                        objRecord.AllowStoreOrder = DataHelper.SmartValues(.Item("AllowStoreOrder"), "string", True)
                        objRecord.InventoryControl = DataHelper.SmartValues(.Item("InventoryControl"), "string", True)
                        objRecord.AutoReplenish = DataHelper.SmartValues(.Item("AutoReplenish"), "string", True)
                        objRecord.PrePriced = DataHelper.SmartValues(.Item("PrePriced"), "string", True)
                        objRecord.TaxUDA = DataHelper.SmartValues(.Item("TaxUDA"), "string", True)
                        objRecord.PrePricedUDA = DataHelper.SmartValues(.Item("PrePricedUDA"), "string", True)
                        objRecord.TaxValueUDA = DataHelper.SmartValues(.Item("TaxValueUDA"), "string", True)
                        objRecord.HybridType = DataHelper.SmartValues(.Item("HybridType"), "string", True)
                        objRecord.SourcingDC = DataHelper.SmartValues(.Item("SourcingDC"), "string", True)
                        objRecord.LeadTime = DataHelper.SmartValues(.Item("LeadTime"), "string", True)
                        objRecord.ConversionDate = DataHelper.SmartValues(.Item("ConversionDate"), "date", True)
                        objRecord.StoreSuppZoneGRP = DataHelper.SmartValues(.Item("StoreSuppZoneGRP"), "string", True)
                        objRecord.WhseSuppZoneGRP = DataHelper.SmartValues(.Item("WhseSuppZoneGRP"), "string", True)
                        objRecord.POGMaxQty = DataHelper.SmartValues(.Item("POGMaxQty"), "string", True)
                        objRecord.POGSetupPerStore = DataHelper.SmartValues(.Item("POGSetupPerStore"), "string", True)
                        objRecord.ProjSalesPerStorePerMonth = DataHelper.SmartValues(.Item("ProjSalesPerStorePerMonth"), "string", True)
                        objRecord.OutboundFreight = DataHelper.SmartValues(.Item("OutboundFreight"), "string", True)
                        objRecord.NinePercentWhseCharge = DataHelper.SmartValues(.Item("NinePercentWhseCharge"), "string", True)
                        objRecord.TotalStoreLandedCost = DataHelper.SmartValues(.Item("TotalStoreLandedCost"), "string", True)
                        objRecord.RDBase = DataHelper.SmartValues(.Item("RDBase"), "string", True)
                        objRecord.RDCentral = DataHelper.SmartValues(.Item("RDCentral"), "string", True)
                        objRecord.RDTest = DataHelper.SmartValues(.Item("RDTest"), "string", True)
                        objRecord.RDAlaska = DataHelper.SmartValues(.Item("RDAlaska"), "string", True)
                        objRecord.RDCanada = DataHelper.SmartValues(.Item("RDCanada"), "string", True)
                        objRecord.RD0Thru9 = DataHelper.SmartValues(.Item("RD0Thru9"), "string", True)
                        objRecord.RDCalifornia = DataHelper.SmartValues(.Item("RDCalifornia"), "string", True)
                        objRecord.RDVillageCraft = DataHelper.SmartValues(.Item("RDVillageCraft"), "string", True)
                        objRecord.Retail9 = DataHelper.SmartValues(.Item("Retail9"), "decimal", True)
                        objRecord.Retail10 = DataHelper.SmartValues(.Item("Retail10"), "decimal", True)
                        objRecord.Retail11 = DataHelper.SmartValues(.Item("Retail11"), "decimal", True)
                        objRecord.Retail12 = DataHelper.SmartValues(.Item("Retail12"), "decimal", True)
                        objRecord.Retail13 = DataHelper.SmartValues(.Item("Retail13"), "decimal", True)
                        objRecord.RDQuebec = DataHelper.SmartValues(.Item("RDQuebec"), "decimal", True)
                        objRecord.RDPuertoRico = DataHelper.SmartValues(.Item("RDPuertoRico"), "decimal", True)
                        objRecord.HazMatYes = DataHelper.SmartValues(.Item("HazMatYes"), "string", True)
                        objRecord.HazMatNo = DataHelper.SmartValues(.Item("HazMatNo"), "string", True)
                        objRecord.HazMatMFGCountry = DataHelper.SmartValues(.Item("HazMatMFGCountry"), "string", True)
                        objRecord.HazMatMFGName = DataHelper.SmartValues(.Item("HazMatMFGName"), "string", True)
                        objRecord.HazMatMFGFlammable = DataHelper.SmartValues(.Item("HazMatMFGFlammable"), "string", True)
                        objRecord.HazMatMFGCity = DataHelper.SmartValues(.Item("HazMatMFGCity"), "string", True)
                        objRecord.HazMatContainerType = DataHelper.SmartValues(.Item("HazMatContainerType"), "string", True)
                        objRecord.HazMatMFGState = DataHelper.SmartValues(.Item("HazMatMFGState"), "string", True)
                        objRecord.HazMatContainerSize = DataHelper.SmartValues(.Item("HazMatContainerSize"), "string", True)
                        objRecord.HazMatMFGPhone = DataHelper.SmartValues(.Item("HazMatMFGPhone"), "string", True)
                        objRecord.HazMatMSDSUOM = DataHelper.SmartValues(.Item("HazMatMSDSUOM"), "string", True)
                        objRecord.CoinBattery = DataHelper.SmartValues(.Item("CoinBattery"), "string", True)
                        objRecord.TSSA = DataHelper.SmartValues(.Item("TSSA"), "string", True)
                        objRecord.CSA = DataHelper.SmartValues(.Item("CSA"), "string", True)
                        objRecord.UL = DataHelper.SmartValues(.Item("UL"), "string", True)
                        objRecord.LicenceAgreement = DataHelper.SmartValues(.Item("LicenceAgreement"), "string", True)
                        objRecord.FumigationCertificate = DataHelper.SmartValues(.Item("FumigationCertificate"), "string", True)
                        objRecord.PhytoTemporaryShipment = DataHelper.SmartValues(.Item("PhytoTemporaryShipment"), "string", True)

                        objRecord.KILNDriedCertificate = DataHelper.SmartValues(.Item("KILNDriedCertificate"), "string", True)
                        objRecord.ChinaComInspecNumAndCCIBStickers = DataHelper.SmartValues(.Item("ChinaComInspecNumAndCCIBStickers"), "string", True)
                        objRecord.OriginalVisa = DataHelper.SmartValues(.Item("OriginalVisa"), "string", True)
                        objRecord.TextileDeclarationMidCode = DataHelper.SmartValues(.Item("TextileDeclarationMidCode"), "string", True)
                        objRecord.QuotaChargeStatement = DataHelper.SmartValues(.Item("QuotaChargeStatement"), "string", True)
                        objRecord.MSDS = DataHelper.SmartValues(.Item("MSDS"), "string", True)
                        objRecord.TSCA = DataHelper.SmartValues(.Item("TSCA"), "string", True)
                        objRecord.DropBallTestCert = DataHelper.SmartValues(.Item("DropBallTestCert"), "string", True)
                        objRecord.ManMedicalDeviceListing = DataHelper.SmartValues(.Item("ManMedicalDeviceListing"), "string", True)
                        objRecord.ManFDARegistration = DataHelper.SmartValues(.Item("ManFDARegistration"), "string", True)
                        objRecord.CopyRightIndemnification = DataHelper.SmartValues(.Item("CopyRightIndemnification"), "string", True)
                        objRecord.FishWildLifeCert = DataHelper.SmartValues(.Item("FishWildLifeCert"), "string", True)
                        objRecord.Proposition65LabelReq = DataHelper.SmartValues(.Item("Proposition65LabelReq"), "string", True)
                        objRecord.CCCR = DataHelper.SmartValues(.Item("CCCR"), "string", True)
                        objRecord.FormaldehydeCompliant = DataHelper.SmartValues(.Item("FormaldehydeCompliant"), "string", True)

                        objRecord.RMSSellable = DataHelper.SmartValues(.Item("RMS_Sellable"), "string", True)
                        objRecord.RMSOrderable = DataHelper.SmartValues(.Item("RMS_Orderable"), "string", True)
                        objRecord.RMSInventory = DataHelper.SmartValues(.Item("RMS_Inventory"), "string", True)

                        objRecord.ParentID = DataHelper.SmartValues(.Item("Parent_ID"), "long", False)

                        objRecord.RegularBatchItem = DataHelper.SmartValues(.Item("RegularBatchItem"), "boolean", False)

                        objRecord.DisplayerCost = DataHelper.SmartValues(.Item("Displayer_Cost"), "decimal", True)
                        objRecord.ProductCost = DataHelper.SmartValues(.Item("Product_Cost"), "decimal", True)
                        objRecord.Discountable = DataHelper.SmartValues(.Item("Discountable"), "string", True)
                        objRecord.StoreTotal = DataHelper.SmartValues(.Item("Store_Total"), "integer", True)
                        objRecord.POGStartDate = DataHelper.SmartValues(.Item("POG_Start_Date"), "date", True)
                        objRecord.POGCompDate = DataHelper.SmartValues(.Item("POG_Comp_Date"), "date", True)
                        objRecord.CalculateOptions = DataHelper.SmartValues(.Item("Calculate_Options"), "integer", False)
                        objRecord.LikeItemSKU = DataHelper.SmartValues(.Item("Like_Item_SKU"), "string", True)
                        objRecord.LikeItemDescription = DataHelper.SmartValues(.Item("Like_Item_Description"), "string", True)
                        objRecord.LikeItemRetail = DataHelper.SmartValues(.Item("Like_Item_Retail"), "decimal", True)
                        objRecord.AnnualRegularUnitForecast = DataHelper.SmartValues(.Item("Annual_Regular_Unit_Forecast"), "decimal", True)
                        'objRecord.UnitStoreMonth = DataHelper.SmartValues(.Item("Unit_Store_Month"), "decimal", True)
                        objRecord.LikeItemStoreCount = DataHelper.SmartValues(.Item("Like_Item_Store_Count"), "decimal", True)
                        objRecord.LikeItemRegularUnit = DataHelper.SmartValues(.Item("Like_Item_Regular_Unit"), "decimal", True)
                        objRecord.LikeItemUnitStoreMonth = DataHelper.SmartValues(.Item("Like_Item_Unit_Store_Month"), "decimal", True)
                        'objRecord.LIkeItemSales = DataHelper.SmartValues(.Item("Like_Item_Sales"), "decimal", True)
                        'objRecord.AdjustedYearlyDemandForecast = DataHelper.SmartValues(.Item("Adjusted_Yearly_Demand_Forecast"), "decimal", True)
                        ' objRecord.AdjustedUnitStoreMonth = DataHelper.SmartValues(.Item("Adjusted_Unit_Store_Month"), "decimal", True)
                        objRecord.AnnualRegRetailSales = DataHelper.SmartValues(.Item("Annual_Reg_Retail_Sales"), "decimal", True)
                        objRecord.Facings = DataHelper.SmartValues(.Item("Facings"), "decimal", True)
                        objRecord.MinPresPerFacing = DataHelper.SmartValues(.Item("Min_Pres_Per_Facing"), "decimal", True)
                        objRecord.InnerPack = DataHelper.SmartValues(.Item("Inner_Pack"), "decimal", True)
                        'lp Spedy Order 12 added
                        objRecord.POGMinQty = DataHelper.SmartValues(.Item("POG_Min_Qty"), "decimal", True)

                        objRecord.PrivateBrandLabel = DataHelper.SmartValues(.Item("Private_Brand_Label"), "string", True)
                        objRecord.QtyInPack = DataHelper.SmartValues(.Item("Qty_In_Pack"), "integer", True)

                        objRecord.ValidExistingSKU = DataHelper.SmartValues(.Item("Valid_Existing_SKU"), "boolean", True)
                        objRecord.ItemStatus = DataHelper.SmartValues(.Item("Item_Status"), "string", True)

                        objRecord.QuoteReferenceNumber = DataHelper.SmartValues(.Item("QuoteReferenceNumber"), "string", True)
                        objRecord.CustomsDescription = DataHelper.SmartValues(.Item("Customs_Description"), "string", True)

                        objRecord.StockingStrategyCode = DataHelper.SmartValues(.Item("Stocking_Strategy_Code"), "string", True)
                        objRecord.CanadaHarmonizedCodeNumber = DataHelper.SmartValues(.Item("CanadaHarmonizedCodeNumber"), "string", True)

                        objRecord.EachHeight = DataHelper.SmartValues(.Item("eachheight"), "decimal", True)
                        objRecord.EachWidth = DataHelper.SmartValues(.Item("EachWidth"), "decimal", True)
                        objRecord.EachLength = DataHelper.SmartValues(.Item("EachLength"), "decimal", True)
                        objRecord.EachWeight = DataHelper.SmartValues(.Item("EachWeight"), "decimal", True)
                        objRecord.CubicFeetEach = DataHelper.SmartValues(.Item("CubicFeetEach"), "decimal", True)

                        objRecord.ReshippableInnerCartonWeight = DataHelper.SmartValues(.Item("ReshippableInnerCartonWeight"), "decimal", True)


                        objRecord.SuppTariffPercent = DataHelper.SmartValues(.Item("SuppTariffPercent"), "string", True)
                        objRecord.SuppTariffAmount = DataHelper.SmartValues(.Item("SuppTariffAmount"), "string", True)

                        objRecord.MinimumOrderQuantity = DataHelper.SmartValues(.Item("MinimumOrderQuantity"), "integer", True)
                        objRecord.ProductIdentifiesAsCosmetic = DataHelper.SmartValues(.Item("ProductIdentifiesAsCosmetic"), "string", True)

                        'Dim iifd As New NovaLibra.Coral.Data.Michaels.ImportItemFileData()
                        NovaLibra.Coral.SystemFrameworks.Michaels.FriendDataHelper.SetImportItemUserData(objRecord,
                            DataHelper.SmartValues(.Item("DateCreated"), "date", True),
                            DataHelper.SmartValues(.Item("CreatedUserID"), "integer", True),
                            DataHelper.SmartValues(.Item("DateLastModified"), "date", True),
                            DataHelper.SmartValues(.Item("UpdateUserID"), "integer", True),
                            DataHelper.SmartValues(.Item("CreatedUser"), "string", True),
                            DataHelper.SmartValues(.Item("UpdateUser"), "string", True),
                            DataHelper.SmartValues(.Item("Image_File_ID"), "long", True),
                            DataHelper.SmartValues(.Item("MSDS_File_ID"), "long", True))
                        'iifd = Nothing

                        NovaLibra.Coral.SystemFrameworks.Michaels.FriendDataHelper.SetImportItemTaxWizard(objRecord,
                            DataHelper.SmartValues(.Item("Tax_Wizard"), "boolean", False))

                        objRecord.AdditionalUPCRecord = AdditionalUPCsData.GetItemAdditionalUPCs(0, objRecord.ID)

                    End With
                Else
                    objRecord.ID = 0
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                objRecord.ID = -1
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Close()
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then '
                    conn.Close()
                    conn.Dispose()
                    conn = Nothing
                End If
                If Not command Is Nothing Then
                    command.Dispose()
                End If
            End Try
            Return objRecord
        End Function

        ' ******************
        ' * ITEM LANGUAGES *
        ' ******************

        Public Shared Sub SaveEditedLanguage(ByVal importItemID As Integer, ByVal languagetypeID As Integer)
            Try
                Using conn As New SqlConnection(Utilities.ApplicationConnectionStrings.AppConnectionString)
                    conn.Open()

                    Using cmd As New SqlCommand("sp_SPD_Import_Item_Languages_Edited", conn)
                        cmd.CommandType = CommandType.StoredProcedure

                        cmd.Parameters.AddWithValue("@ItemID", importItemID)
                        cmd.Parameters.AddWithValue("@LanguageTypeID", languagetypeID)

                        cmd.ExecuteNonQuery()
                    End Using  'cmd
                End Using  'conn

            Catch ex As Exception
                Throw
            End Try
        End Sub

        Public Shared Sub SaveImportItemLanguage(ByVal importItemID As Integer, ByVal languageTypeID As Integer, ByVal pli As String, ByVal ti As String, ByVal descShort As String, ByVal descLong As String, ByVal userID As Integer)
            Try
                Using conn As New SqlConnection(Utilities.ApplicationConnectionStrings.AppConnectionString)
                    conn.Open()

                    Using cmd As New SqlCommand("sp_SPD_Import_Item_Languages_InsertUpdate", conn)
                        cmd.CommandType = CommandType.StoredProcedure

                        cmd.Parameters.AddWithValue("@ImportItemID", importItemID)
                        cmd.Parameters.AddWithValue("@LanguageTypeID", languageTypeID)
                        cmd.Parameters.AddWithValue("@PackageLanguageIndicator", pli)
                        cmd.Parameters.AddWithValue("@TranslationIndicator", ti)
                        cmd.Parameters.AddWithValue("@DescriptionShort", descShort)
                        cmd.Parameters.AddWithValue("@DescriptionLong", descLong)
                        cmd.Parameters.AddWithValue("@UserID", userID)

                        cmd.ExecuteNonQuery()
                    End Using  'cmd
                End Using  'conn

            Catch ex As Exception
                Throw
            End Try

        End Sub

        Public Shared Function GetImportItemLanguages(ByVal importItemID As Integer) As DataTable
            Dim dt As New DataTable

            Try
                Using conn As New SqlConnection(Utilities.ApplicationConnectionStrings.AppConnectionString)
                    conn.Open()

                    Using cmd As New SqlCommand("sp_SPD_Import_Item_Languages_GetByItemID", conn)
                        cmd.CommandType = CommandType.StoredProcedure
                        cmd.Parameters.AddWithValue("@ImportItemID", importItemID)
                        cmd.CommandTimeout = 1800

                        Using da As New SqlDataAdapter(cmd)
                            da.Fill(dt)
                        End Using   'da
                    End Using  'cmd
                End Using  'conn

            Catch ex As Exception
                Throw ex
            End Try

            Return dt
        End Function

        ' ************************************************************************************************
        ' *****            Currently only used for rollup, so not all fields needed.                 *****
        ' ************************************************************************************************
        Public Function GetItemList(ByVal batchID As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemList
            Dim itemList As New ImportItemList()
            Dim objRecord As ImportItemRecord
            Dim sql As String = "sp_SPD_Import_Item_GetRecord_ByBatchID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@Batch_ID", SqlDbType.BigInt)
                objParam.Value = batchID
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                Do While reader.Read()
                    With reader
                        objRecord = New ImportItemRecord()

                        objRecord.ID = DataHelper.SmartValues(.Item("ID"), "long", True)
                        objRecord.Batch_ID = DataHelper.SmartValues(.Item("Batch_ID"), "long", True)
                        objRecord.DateSubmitted = DataHelper.SmartValues(.Item("DateSubmitted"), "date", True)
                        objRecord.Vendor = DataHelper.SmartValues(.Item("Vendor"), "string", True)
                        objRecord.Agent = DataHelper.SmartValues(.Item("Agent"), "string", True)
                        objRecord.AgentType = DataHelper.SmartValues(.Item("AgentType"), "string", True)
                        objRecord.Buyer = DataHelper.SmartValues(.Item("Buyer"), "string", True)
                        objRecord.Fax = DataHelper.SmartValues(.Item("Fax"), "string", True)
                        objRecord.EnteredBy = DataHelper.SmartValues(.Item("EnteredBy"), "string", True)
                        objRecord.SKUGroup = DataHelper.SmartValues(.Item("SKUGroup"), "string", True)
                        objRecord.Email = DataHelper.SmartValues(.Item("Email"), "string", True)
                        objRecord.EnteredDate = DataHelper.SmartValues(.Item("EnteredDate"), "date", True)
                        objRecord.Dept = DataHelper.SmartValues(.Item("Dept"), "string", True)
                        objRecord.Class = DataHelper.SmartValues(.Item("Class"), "string", True)
                        objRecord.SubClass = DataHelper.SmartValues(.Item("SubClass"), "string", True)
                        objRecord.PrimaryUPC = DataHelper.SmartValues(.Item("PrimaryUPC"), "string", True)
                        objRecord.MichaelsSKU = DataHelper.SmartValues(.Item("MichaelsSKU"), "string", True)
                        objRecord.GenerateMichaelsUPC = DataHelper.SmartValues(.Item("GenerateMichaelsUPC"), "string", True)

                        objRecord.PackSKU = DataHelper.SmartValues(.Item("PackSKU"), "string", True)
                        objRecord.PlanogramName = DataHelper.SmartValues(.Item("PlanogramName"), "string", True)
                        objRecord.VendorNumber = DataHelper.SmartValues(.Item("VendorNumber"), "string", True)
                        objRecord.VendorRank = DataHelper.SmartValues(.Item("VendorRank"), "string", True)
                        objRecord.ItemTask = DataHelper.SmartValues(.Item("ItemTask"), "string", True)
                        objRecord.Description = DataHelper.SmartValues(.Item("Description"), "string", True)
                        objRecord.QuoteSheetStatus = DataHelper.SmartValues(.Item("QuoteSheetStatus"), "string", True)
                        objRecord.Season = DataHelper.SmartValues(.Item("Season"), "string", True)
                        'removed 2020-09-11
                        'objRecord.PaymentTerms = DataHelper.SmartValues(.Item("PaymentTerms"), "string", True)
                        'objRecord.Days = UCase(DataHelper.SmartValues(.Item("Days"), "string", True)) 'lp SPEDY order 12 02 2009
                        objRecord.VendorMinOrderAmount = DataHelper.SmartValues(.Item("VendorMinOrderAmount"), "string", True)
                        objRecord.VendorName = DataHelper.SmartValues(.Item("VendorName"), "string", True)
                        objRecord.VendorAddress1 = DataHelper.SmartValues(.Item("VendorAddress1"), "string", True)
                        objRecord.VendorAddress2 = DataHelper.SmartValues(.Item("VendorAddress2"), "string", True)
                        objRecord.VendorAddress3 = DataHelper.SmartValues(.Item("VendorAddress3"), "string", True)
                        objRecord.VendorAddress4 = DataHelper.SmartValues(.Item("VendorAddress4"), "string", True)
                        objRecord.VendorContactName = DataHelper.SmartValues(.Item("VendorContactName"), "string", True)
                        objRecord.VendorContactPhone = DataHelper.SmartValues(.Item("VendorContactPhone"), "string", True)
                        objRecord.VendorContactEmail = DataHelper.SmartValues(.Item("VendorContactEmail"), "string", True)
                        objRecord.VendorContactFax = DataHelper.SmartValues(.Item("VendorContactFax"), "string", True)
                        objRecord.ManufactureName = DataHelper.SmartValues(.Item("ManufactureName"), "string", True)
                        objRecord.ManufactureAddress1 = DataHelper.SmartValues(.Item("ManufactureAddress1"), "string", True)
                        objRecord.ManufactureAddress2 = DataHelper.SmartValues(.Item("ManufactureAddress2"), "string", True)
                        objRecord.ManufactureContact = DataHelper.SmartValues(.Item("ManufactureContact"), "string", True)
                        objRecord.ManufacturePhone = DataHelper.SmartValues(.Item("ManufacturePhone"), "string", True)
                        objRecord.ManufactureEmail = DataHelper.SmartValues(.Item("ManufactureEmail"), "string", True)
                        objRecord.ManufactureFax = DataHelper.SmartValues(.Item("ManufactureFax"), "string", True)
                        objRecord.AgentContact = DataHelper.SmartValues(.Item("AgentContact"), "string", True)
                        objRecord.AgentPhone = DataHelper.SmartValues(.Item("AgentPhone"), "string", True)
                        objRecord.AgentEmail = DataHelper.SmartValues(.Item("AgentEmail"), "string", True)
                        objRecord.AgentFax = DataHelper.SmartValues(.Item("AgentFax"), "string", True)
                        objRecord.VendorStyleNumber = DataHelper.SmartValues(.Item("VendorStyleNumber"), "string", True)
                        objRecord.HarmonizedCodeNumber = DataHelper.SmartValues(.Item("HarmonizedCodeNumber"), "string", True)
                        objRecord.DetailInvoiceCustomsDesc = DataHelper.SmartValues(.Item("DetailInvoiceCustomsDesc"), "string", True)
                        objRecord.ComponentMaterialBreakdown = DataHelper.SmartValues(.Item("ComponentMaterialBreakdown"), "string", True)
                        objRecord.ComponentConstructionMethod = DataHelper.SmartValues(.Item("ComponentConstructionMethod"), "string", True)
                        objRecord.IndividualItemPackaging = DataHelper.SmartValues(.Item("IndividualItemPackaging"), "string", True)
                        objRecord.EachInsideMasterCaseBox = DataHelper.SmartValues(.Item("EachInsideMasterCaseBox"), "string", True)
                        objRecord.EachInsideInnerPack = DataHelper.SmartValues(.Item("EachInsideInnerPack"), "string", True)
                        'objRecord.EachPieceNetWeightLbsPerOunce = DataHelper.SmartValues(.Item("EachPieceNetWeightLbsPerOunce"), "string", True)
                        objRecord.ReshippableInnerCartonLength = DataHelper.SmartValues(.Item("ReshippableInnerCartonLength"), "string", True)
                        objRecord.ReshippableInnerCartonWidth = DataHelper.SmartValues(.Item("ReshippableInnerCartonWidth"), "string", True)
                        objRecord.ReshippableInnerCartonHeight = DataHelper.SmartValues(.Item("ReshippableInnerCartonHeight"), "string", True)
                        objRecord.MasterCartonDimensionsLength = DataHelper.SmartValues(.Item("MasterCartonDimensionsLength"), "string", True)
                        objRecord.MasterCartonDimensionsWidth = DataHelper.SmartValues(.Item("MasterCartonDimensionsWidth"), "string", True)
                        objRecord.MasterCartonDimensionsHeight = DataHelper.SmartValues(.Item("MasterCartonDimensionsHeight"), "string", True)
                        objRecord.CubicFeetPerMasterCarton = DataHelper.SmartValues(.Item("CubicFeetPerMasterCarton"), "string", True)
                        objRecord.WeightMasterCarton = DataHelper.SmartValues(.Item("WeightMasterCarton"), "string", True)
                        objRecord.CubicFeetPerInnerCarton = DataHelper.SmartValues(.Item("CubicFeetPerInnerCarton"), "string", True)
                        objRecord.FOBShippingPoint = DataHelper.SmartValues(.Item("FOBShippingPoint"), "string", True)
                        objRecord.DutyPercent = DataHelper.SmartValues(.Item("DutyPercent"), "string", True)
                        objRecord.DutyAmount = DataHelper.SmartValues(.Item("DutyAmount"), "string", True)
                        objRecord.AdditionalDutyComment = DataHelper.SmartValues(.Item("AdditionalDutyComment"), "string", True)
                        objRecord.AdditionalDutyAmount = DataHelper.SmartValues(.Item("AdditionalDutyAmount"), "string", True)
                        objRecord.OceanFreightAmount = DataHelper.SmartValues(.Item("OceanFreightAmount"), "string", True)
                        objRecord.OceanFreightComputedAmount = DataHelper.SmartValues(.Item("OceanFreightComputedAmount"), "string", True)
                        objRecord.AgentCommissionPercent = DataHelper.SmartValues(.Item("AgentCommissionPercent"), "string", True)
                        objRecord.RecAgentCommissionPercent = DataHelper.SmartValues(.Item("RecAgentCommissionPercent"), "string", True)
                        objRecord.AgentCommissionAmount = DataHelper.SmartValues(.Item("AgentCommissionAmount"), "string", True)
                        objRecord.OtherImportCostsPercent = DataHelper.SmartValues(.Item("OtherImportCostsPercent"), "string", True)
                        objRecord.OtherImportCostsAmount = DataHelper.SmartValues(.Item("OtherImportCostsAmount"), "string", True)
                        objRecord.PackagingCostAmount = DataHelper.SmartValues(.Item("PackagingCostAmount"), "string", True)
                        objRecord.TotalImportBurden = DataHelper.SmartValues(.Item("TotalImportBurden"), "string", True)
                        objRecord.WarehouseLandedCost = DataHelper.SmartValues(.Item("WarehouseLandedCost"), "string", True)
                        objRecord.PurchaseOrderIssuedTo = DataHelper.SmartValues(.Item("PurchaseOrderIssuedTo"), "string", True)
                        objRecord.ShippingPoint = DataHelper.SmartValues(.Item("ShippingPoint"), "string", True)
                        objRecord.CountryOfOrigin = DataHelper.SmartValues(.Item("CountryOfOrigin"), "string", True)
                        objRecord.CountryOfOriginName = DataHelper.SmartValues(.Item("CountryOfOriginName"), "string", True)
                        objRecord.VendorComments = DataHelper.SmartValues(.Item("VendorComments"), "string", True)
                        objRecord.StockCategory = DataHelper.SmartValues(.Item("StockCategory"), "string", True)
                        objRecord.FreightTerms = DataHelper.SmartValues(.Item("FreightTerms"), "string", True)
                        objRecord.ItemType = DataHelper.SmartValues(.Item("ItemType"), "string", True)
                        objRecord.PackItemIndicator = DataHelper.SmartValues(.Item("PackItemIndicator"), "string", True)
                        objRecord.ItemTypeAttribute = DataHelper.SmartValues(.Item("ItemTypeAttribute"), "string", True)
                        objRecord.AllowStoreOrder = DataHelper.SmartValues(.Item("AllowStoreOrder"), "string", True)
                        objRecord.InventoryControl = DataHelper.SmartValues(.Item("InventoryControl"), "string", True)
                        objRecord.AutoReplenish = DataHelper.SmartValues(.Item("AutoReplenish"), "string", True)
                        objRecord.PrePriced = DataHelper.SmartValues(.Item("PrePriced"), "string", True)
                        objRecord.TaxUDA = DataHelper.SmartValues(.Item("TaxUDA"), "string", True)
                        objRecord.PrePricedUDA = DataHelper.SmartValues(.Item("PrePricedUDA"), "string", True)
                        objRecord.TaxValueUDA = DataHelper.SmartValues(.Item("TaxValueUDA"), "string", True)
                        objRecord.HybridType = DataHelper.SmartValues(.Item("HybridType"), "string", True)
                        objRecord.SourcingDC = DataHelper.SmartValues(.Item("SourcingDC"), "string", True)
                        objRecord.LeadTime = DataHelper.SmartValues(.Item("LeadTime"), "string", True)
                        objRecord.ConversionDate = DataHelper.SmartValues(.Item("ConversionDate"), "date", True)
                        objRecord.StoreSuppZoneGRP = DataHelper.SmartValues(.Item("StoreSuppZoneGRP"), "string", True)
                        objRecord.WhseSuppZoneGRP = DataHelper.SmartValues(.Item("WhseSuppZoneGRP"), "string", True)
                        objRecord.POGMaxQty = DataHelper.SmartValues(.Item("POGMaxQty"), "string", True)
                        objRecord.POGSetupPerStore = DataHelper.SmartValues(.Item("POGSetupPerStore"), "string", True)
                        objRecord.ProjSalesPerStorePerMonth = DataHelper.SmartValues(.Item("ProjSalesPerStorePerMonth"), "string", True)
                        objRecord.OutboundFreight = DataHelper.SmartValues(.Item("OutboundFreight"), "string", True)
                        objRecord.NinePercentWhseCharge = DataHelper.SmartValues(.Item("NinePercentWhseCharge"), "string", True)
                        objRecord.TotalStoreLandedCost = DataHelper.SmartValues(.Item("TotalStoreLandedCost"), "string", True)

                        objRecord.ParentID = DataHelper.SmartValues(.Item("Parent_ID"), "long", False)

                        objRecord.RegularBatchItem = DataHelper.SmartValues(.Item("RegularBatchItem"), "boolean", False)

                        objRecord.DisplayerCost = DataHelper.SmartValues(.Item("Displayer_Cost"), "decimal", True)
                        objRecord.ProductCost = DataHelper.SmartValues(.Item("Product_Cost"), "decimal", True)
                        objRecord.Discountable = DataHelper.SmartValues(.Item("Discountable"), "string", True)
                        objRecord.StoreTotal = DataHelper.SmartValues(.Item("Store_Total"), "integer", True)
                        objRecord.POGStartDate = DataHelper.SmartValues(.Item("POG_Start_Date"), "date", True)
                        objRecord.POGCompDate = DataHelper.SmartValues(.Item("POG_Comp_Date"), "date", True)
                        objRecord.CalculateOptions = DataHelper.SmartValues(.Item("Calculate_Options"), "integer", False)
                        objRecord.LikeItemSKU = DataHelper.SmartValues(.Item("Like_Item_SKU"), "string", True)
                        objRecord.LikeItemDescription = DataHelper.SmartValues(.Item("Like_Item_Description"), "string", True)
                        objRecord.LikeItemRetail = DataHelper.SmartValues(.Item("Like_Item_Retail"), "decimal", True)
                        objRecord.AnnualRegularUnitForecast = DataHelper.SmartValues(.Item("Annual_Regular_Unit_Forecast"), "decimal", True)
                        'objRecord.UnitStoreMonth = DataHelper.SmartValues(.Item("Unit_Store_Month"), "decimal", True)
                        objRecord.LikeItemStoreCount = DataHelper.SmartValues(.Item("Like_Item_Store_Count"), "decimal", True)
                        objRecord.LikeItemRegularUnit = DataHelper.SmartValues(.Item("Like_Item_Regular_Unit"), "decimal", True)
                        objRecord.LikeItemUnitStoreMonth = DataHelper.SmartValues(.Item("Like_Item_Unit_Store_Month"), "decimal", True)
                        'objRecord.LIkeItemSales = DataHelper.SmartValues(.Item("Like_Item_Sales"), "decimal", True)
                        'objRecord.AdjustedYearlyDemandForecast = DataHelper.SmartValues(.Item("Adjusted_Yearly_Demand_Forecast"), "decimal", True)
                        ' objRecord.AdjustedUnitStoreMonth = DataHelper.SmartValues(.Item("Adjusted_Unit_Store_Month"), "decimal", True)
                        objRecord.AnnualRegRetailSales = DataHelper.SmartValues(.Item("Annual_Reg_Retail_Sales"), "decimal", True)
                        objRecord.Facings = DataHelper.SmartValues(.Item("Facings"), "decimal", True)
                        objRecord.MinPresPerFacing = DataHelper.SmartValues(.Item("Min_Pres_Per_Facing"), "decimal", True)
                        objRecord.InnerPack = DataHelper.SmartValues(.Item("Inner_Pack"), "decimal", True)
                        'lp Spedy Order 12 added
                        objRecord.POGMinQty = DataHelper.SmartValues(.Item("POG_Min_Qty"), "decimal", True)

                        objRecord.PrivateBrandLabel = DataHelper.SmartValues(.Item("Private_Brand_Label"), "string", True)
                        objRecord.QtyInPack = DataHelper.SmartValues(.Item("Qty_In_Pack"), "integer", True)

                        objRecord.ValidExistingSKU = DataHelper.SmartValues(.Item("Valid_Existing_SKU"), "boolean", True)
                        objRecord.ItemStatus = DataHelper.SmartValues(.Item("Item_Status"), "string", True)

                        'JC Spedy Global Link - 2/7/11
                        objRecord.QuoteReferenceNumber = DataHelper.SmartValues(.Item("QuoteReferenceNumber"), "string", True)


                        objRecord.StockingStrategyCode = DataHelper.SmartValues(.Item("Stocking_Strategy_Code"), "string", True)
                        objRecord.CanadaHarmonizedCodeNumber = DataHelper.SmartValues(.Item("CanadaHarmonizedCodeNumber"), "string", True)

                        objRecord.EachHeight = DataHelper.SmartValues(.Item("eachheight"), "decimal", True)
                        objRecord.EachWidth = DataHelper.SmartValues(.Item("EachWidth"), "decimal", True)
                        objRecord.EachLength = DataHelper.SmartValues(.Item("EachLength"), "decimal", True)
                        objRecord.EachWeight = DataHelper.SmartValues(.Item("EachWeight"), "decimal", True)
                        objRecord.CubicFeetEach = DataHelper.SmartValues(.Item("CubicFeetEach"), "decimal", True)

                        objRecord.ReshippableInnerCartonWeight = DataHelper.SmartValues(.Item("ReshippableInnerCartonWeight"), "decimal", True)


                        objRecord.SuppTariffPercent = DataHelper.SmartValues(.Item("SuppTariffPercent"), "string", True)
                        objRecord.SuppTariffAmount = DataHelper.SmartValues(.Item("SuppTariffAmount"), "string", True)

                        objRecord.MinimumOrderQuantity = DataHelper.SmartValues(.Item("MinimumOrderQuantity"), "integer", False)
                        objRecord.ProductIdentifiesAsCosmetic = DataHelper.SmartValues(.Item("ProductIdentifiesAsCosmetic"), "string", True)

                        itemList.Add(objRecord)
                    End With
                Loop
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return itemList
        End Function

        Public Function GetItemRecordByQRN(ByVal qrn As String) As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord
            Dim objRecord As ImportItemRecord = New ImportItemRecord()
            Dim sql As String = "sp_SPD_Import_Item_GetRecord_ByQRN"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@QRN", SqlDbType.VarChar)
                objParam.Value = qrn
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        objRecord.ID = DataHelper.SmartValues(.Item("ID"), "long", True)
                        objRecord.Batch_ID = DataHelper.SmartValues(.Item("Batch_ID"), "long", True)
                        objRecord.DateSubmitted = DataHelper.SmartValues(.Item("DateSubmitted"), "date", True)
                        objRecord.Vendor = DataHelper.SmartValues(.Item("Vendor"), "string", True)
                        objRecord.Agent = DataHelper.SmartValues(.Item("Agent"), "string", True)
                        objRecord.AgentType = DataHelper.SmartValues(.Item("AgentType"), "string", True)
                        objRecord.Buyer = DataHelper.SmartValues(.Item("Buyer"), "string", True)
                        objRecord.Fax = DataHelper.SmartValues(.Item("Fax"), "string", True)
                        objRecord.EnteredBy = DataHelper.SmartValues(.Item("EnteredBy"), "string", True)
                        objRecord.SKUGroup = DataHelper.SmartValues(.Item("SKUGroup"), "string", True)
                        objRecord.Email = DataHelper.SmartValues(.Item("Email"), "string", True)
                        objRecord.EnteredDate = DataHelper.SmartValues(.Item("EnteredDate"), "date", True)
                        objRecord.Dept = DataHelper.SmartValues(.Item("Dept"), "string", True)
                        objRecord.Class = DataHelper.SmartValues(.Item("Class"), "string", True)
                        objRecord.SubClass = DataHelper.SmartValues(.Item("SubClass"), "string", True)
                        objRecord.PrimaryUPC = DataHelper.SmartValues(.Item("PrimaryUPC"), "string", True)
                        objRecord.MichaelsSKU = DataHelper.SmartValues(.Item("MichaelsSKU"), "string", True)
                        objRecord.GenerateMichaelsUPC = DataHelper.SmartValues(.Item("GenerateMichaelsUPC"), "string", True)
                        'objRecord.AdditionalUPC1 = DataHelper.SmartValues(.Item("AdditionalUPC1"), "string", True)
                        'objRecord.AdditionalUPC2 = DataHelper.SmartValues(.Item("AdditionalUPC2"), "string", True)
                        'objRecord.AdditionalUPC3 = DataHelper.SmartValues(.Item("AdditionalUPC3"), "string", True)
                        'objRecord.AdditionalUPC4 = DataHelper.SmartValues(.Item("AdditionalUPC4"), "string", True)
                        'objRecord.AdditionalUPC5 = DataHelper.SmartValues(.Item("AdditionalUPC5"), "string", True)
                        'objRecord.AdditionalUPC6 = DataHelper.SmartValues(.Item("AdditionalUPC6"), "string", True)
                        'objRecord.AdditionalUPC7 = DataHelper.SmartValues(.Item("AdditionalUPC7"), "string", True)
                        'objRecord.AdditionalUPC8 = DataHelper.SmartValues(.Item("AdditionalUPC8"), "string", True)
                        objRecord.PackSKU = DataHelper.SmartValues(.Item("PackSKU"), "string", True)
                        objRecord.PlanogramName = DataHelper.SmartValues(.Item("PlanogramName"), "string", True)
                        objRecord.VendorNumber = DataHelper.SmartValues(.Item("VendorNumber"), "string", True)
                        objRecord.VendorRank = DataHelper.SmartValues(.Item("VendorRank"), "string", True)
                        objRecord.ItemTask = DataHelper.SmartValues(.Item("ItemTask"), "string", True)
                        objRecord.Description = DataHelper.SmartValues(.Item("Description"), "string", True)
                        objRecord.QuoteSheetStatus = DataHelper.SmartValues(.Item("QuoteSheetStatus"), "string", True)
                        objRecord.Season = DataHelper.SmartValues(.Item("Season"), "string", True)
                        'removed 2020-09-11
                        'objRecord.PaymentTerms = DataHelper.SmartValues(.Item("PaymentTerms"), "string", True)
                        'objRecord.Days = UCase(DataHelper.SmartValues(.Item("Days"), "string", True)) 'lp SPEDY order 12 02 2009
                        objRecord.VendorMinOrderAmount = DataHelper.SmartValues(.Item("VendorMinOrderAmount"), "string", True)
                        objRecord.VendorName = DataHelper.SmartValues(.Item("VendorName"), "string", True)
                        objRecord.VendorAddress1 = DataHelper.SmartValues(.Item("VendorAddress1"), "string", True)
                        objRecord.VendorAddress2 = DataHelper.SmartValues(.Item("VendorAddress2"), "string", True)
                        objRecord.VendorAddress3 = DataHelper.SmartValues(.Item("VendorAddress3"), "string", True)
                        objRecord.VendorAddress4 = DataHelper.SmartValues(.Item("VendorAddress4"), "string", True)
                        objRecord.VendorContactName = DataHelper.SmartValues(.Item("VendorContactName"), "string", True)
                        objRecord.VendorContactPhone = DataHelper.SmartValues(.Item("VendorContactPhone"), "string", True)
                        objRecord.VendorContactEmail = DataHelper.SmartValues(.Item("VendorContactEmail"), "string", True)
                        objRecord.VendorContactFax = DataHelper.SmartValues(.Item("VendorContactFax"), "string", True)
                        objRecord.ManufactureName = DataHelper.SmartValues(.Item("ManufactureName"), "string", True)
                        objRecord.ManufactureAddress1 = DataHelper.SmartValues(.Item("ManufactureAddress1"), "string", True)
                        objRecord.ManufactureAddress2 = DataHelper.SmartValues(.Item("ManufactureAddress2"), "string", True)
                        objRecord.ManufactureContact = DataHelper.SmartValues(.Item("ManufactureContact"), "string", True)
                        objRecord.ManufacturePhone = DataHelper.SmartValues(.Item("ManufacturePhone"), "string", True)
                        objRecord.ManufactureEmail = DataHelper.SmartValues(.Item("ManufactureEmail"), "string", True)
                        objRecord.ManufactureFax = DataHelper.SmartValues(.Item("ManufactureFax"), "string", True)
                        objRecord.AgentContact = DataHelper.SmartValues(.Item("AgentContact"), "string", True)
                        objRecord.AgentPhone = DataHelper.SmartValues(.Item("AgentPhone"), "string", True)
                        objRecord.AgentEmail = DataHelper.SmartValues(.Item("AgentEmail"), "string", True)
                        objRecord.AgentFax = DataHelper.SmartValues(.Item("AgentFax"), "string", True)
                        objRecord.VendorStyleNumber = DataHelper.SmartValues(.Item("VendorStyleNumber"), "string", True)
                        objRecord.HarmonizedCodeNumber = DataHelper.SmartValues(.Item("HarmonizedCodeNumber"), "string", True)
                        objRecord.DetailInvoiceCustomsDesc = DataHelper.SmartValues(.Item("DetailInvoiceCustomsDesc"), "string", True)
                        objRecord.ComponentMaterialBreakdown = DataHelper.SmartValues(.Item("ComponentMaterialBreakdown"), "string", True)
                        objRecord.ComponentConstructionMethod = DataHelper.SmartValues(.Item("ComponentConstructionMethod"), "string", True)
                        objRecord.IndividualItemPackaging = DataHelper.SmartValues(.Item("IndividualItemPackaging"), "string", True)
                        objRecord.EachInsideMasterCaseBox = DataHelper.SmartValues(.Item("EachInsideMasterCaseBox"), "string", True)
                        objRecord.EachInsideInnerPack = DataHelper.SmartValues(.Item("EachInsideInnerPack"), "string", True)
                        'objRecord.EachPieceNetWeightLbsPerOunce = DataHelper.SmartValues(.Item("EachPieceNetWeightLbsPerOunce"), "string", True)
                        objRecord.ReshippableInnerCartonLength = DataHelper.SmartValues(.Item("ReshippableInnerCartonLength"), "string", True)
                        objRecord.ReshippableInnerCartonWidth = DataHelper.SmartValues(.Item("ReshippableInnerCartonWidth"), "string", True)
                        objRecord.ReshippableInnerCartonHeight = DataHelper.SmartValues(.Item("ReshippableInnerCartonHeight"), "string", True)
                        objRecord.MasterCartonDimensionsLength = DataHelper.SmartValues(.Item("MasterCartonDimensionsLength"), "string", True)
                        objRecord.MasterCartonDimensionsWidth = DataHelper.SmartValues(.Item("MasterCartonDimensionsWidth"), "string", True)
                        objRecord.MasterCartonDimensionsHeight = DataHelper.SmartValues(.Item("MasterCartonDimensionsHeight"), "string", True)
                        objRecord.CubicFeetPerMasterCarton = DataHelper.SmartValues(.Item("CubicFeetPerMasterCarton"), "string", True)
                        objRecord.WeightMasterCarton = DataHelper.SmartValues(.Item("WeightMasterCarton"), "string", True)
                        objRecord.CubicFeetPerInnerCarton = DataHelper.SmartValues(.Item("CubicFeetPerInnerCarton"), "string", True)
                        objRecord.FOBShippingPoint = DataHelper.SmartValues(.Item("FOBShippingPoint"), "string", True)
                        objRecord.DutyPercent = DataHelper.SmartValues(.Item("DutyPercent"), "string", True)
                        objRecord.DutyAmount = DataHelper.SmartValues(.Item("DutyAmount"), "string", True)
                        objRecord.AdditionalDutyComment = DataHelper.SmartValues(.Item("AdditionalDutyComment"), "string", True)
                        objRecord.AdditionalDutyAmount = DataHelper.SmartValues(.Item("AdditionalDutyAmount"), "string", True)
                        objRecord.OceanFreightAmount = DataHelper.SmartValues(.Item("OceanFreightAmount"), "string", True)
                        objRecord.OceanFreightComputedAmount = DataHelper.SmartValues(.Item("OceanFreightComputedAmount"), "string", True)
                        objRecord.AgentCommissionPercent = DataHelper.SmartValues(.Item("AgentCommissionPercent"), "string", True)
                        objRecord.RecAgentCommissionPercent = DataHelper.SmartValues(.Item("RecAgentCommissionPercent"), "string", True)
                        objRecord.AgentCommissionAmount = DataHelper.SmartValues(.Item("AgentCommissionAmount"), "string", True)
                        objRecord.OtherImportCostsPercent = DataHelper.SmartValues(.Item("OtherImportCostsPercent"), "string", True)
                        objRecord.OtherImportCostsAmount = DataHelper.SmartValues(.Item("OtherImportCostsAmount"), "string", True)
                        objRecord.PackagingCostAmount = DataHelper.SmartValues(.Item("PackagingCostAmount"), "string", True)
                        objRecord.TotalImportBurden = DataHelper.SmartValues(.Item("TotalImportBurden"), "string", True)
                        objRecord.WarehouseLandedCost = DataHelper.SmartValues(.Item("WarehouseLandedCost"), "string", True)
                        objRecord.PurchaseOrderIssuedTo = DataHelper.SmartValues(.Item("PurchaseOrderIssuedTo"), "string", True)
                        objRecord.ShippingPoint = DataHelper.SmartValues(.Item("ShippingPoint"), "string", True)
                        objRecord.CountryOfOrigin = DataHelper.SmartValues(.Item("CountryOfOrigin"), "string", True)
                        objRecord.CountryOfOriginName = DataHelper.SmartValues(.Item("CountryOfOriginName"), "string", True)
                        objRecord.VendorComments = DataHelper.SmartValues(.Item("VendorComments"), "string", True)
                        objRecord.StockCategory = DataHelper.SmartValues(.Item("StockCategory"), "string", True)
                        objRecord.FreightTerms = DataHelper.SmartValues(.Item("FreightTerms"), "string", True)
                        objRecord.ItemType = DataHelper.SmartValues(.Item("ItemType"), "string", True)
                        objRecord.PackItemIndicator = DataHelper.SmartValues(.Item("PackItemIndicator"), "string", True)
                        objRecord.ItemTypeAttribute = DataHelper.SmartValues(.Item("ItemTypeAttribute"), "string", True)
                        objRecord.AllowStoreOrder = DataHelper.SmartValues(.Item("AllowStoreOrder"), "string", True)
                        objRecord.InventoryControl = DataHelper.SmartValues(.Item("InventoryControl"), "string", True)
                        objRecord.AutoReplenish = DataHelper.SmartValues(.Item("AutoReplenish"), "string", True)
                        objRecord.PrePriced = DataHelper.SmartValues(.Item("PrePriced"), "string", True)
                        objRecord.TaxUDA = DataHelper.SmartValues(.Item("TaxUDA"), "string", True)
                        objRecord.PrePricedUDA = DataHelper.SmartValues(.Item("PrePricedUDA"), "string", True)
                        objRecord.TaxValueUDA = DataHelper.SmartValues(.Item("TaxValueUDA"), "string", True)
                        objRecord.HybridType = DataHelper.SmartValues(.Item("HybridType"), "string", True)
                        objRecord.SourcingDC = DataHelper.SmartValues(.Item("SourcingDC"), "string", True)
                        objRecord.LeadTime = DataHelper.SmartValues(.Item("LeadTime"), "string", True)
                        objRecord.ConversionDate = DataHelper.SmartValues(.Item("ConversionDate"), "date", True)
                        objRecord.StoreSuppZoneGRP = DataHelper.SmartValues(.Item("StoreSuppZoneGRP"), "string", True)
                        objRecord.WhseSuppZoneGRP = DataHelper.SmartValues(.Item("WhseSuppZoneGRP"), "string", True)
                        objRecord.POGMaxQty = DataHelper.SmartValues(.Item("POGMaxQty"), "string", True)
                        objRecord.POGSetupPerStore = DataHelper.SmartValues(.Item("POGSetupPerStore"), "string", True)
                        objRecord.ProjSalesPerStorePerMonth = DataHelper.SmartValues(.Item("ProjSalesPerStorePerMonth"), "string", True)
                        objRecord.OutboundFreight = DataHelper.SmartValues(.Item("OutboundFreight"), "string", True)
                        objRecord.NinePercentWhseCharge = DataHelper.SmartValues(.Item("NinePercentWhseCharge"), "string", True)
                        objRecord.TotalStoreLandedCost = DataHelper.SmartValues(.Item("TotalStoreLandedCost"), "string", True)
                        objRecord.RDBase = DataHelper.SmartValues(.Item("RDBase"), "string", True)
                        objRecord.RDCentral = DataHelper.SmartValues(.Item("RDCentral"), "string", True)
                        objRecord.RDTest = DataHelper.SmartValues(.Item("RDTest"), "string", True)
                        objRecord.RDAlaska = DataHelper.SmartValues(.Item("RDAlaska"), "string", True)
                        objRecord.RDCanada = DataHelper.SmartValues(.Item("RDCanada"), "string", True)
                        objRecord.RD0Thru9 = DataHelper.SmartValues(.Item("RD0Thru9"), "string", True)
                        objRecord.RDCalifornia = DataHelper.SmartValues(.Item("RDCalifornia"), "string", True)
                        objRecord.RDVillageCraft = DataHelper.SmartValues(.Item("RDVillageCraft"), "string", True)
                        'lp change order 14
                        objRecord.Retail9 = DataHelper.SmartValues(.Item("Retail9"), "decimal", True)
                        objRecord.Retail10 = DataHelper.SmartValues(.Item("Retail10"), "decimal", True)
                        objRecord.Retail11 = DataHelper.SmartValues(.Item("Retail11"), "decimal", True)
                        objRecord.Retail12 = DataHelper.SmartValues(.Item("Retail12"), "decimal", True)
                        objRecord.Retail13 = DataHelper.SmartValues(.Item("Retail13"), "decimal", True)
                        '-------------change order 14
                        objRecord.HazMatYes = DataHelper.SmartValues(.Item("HazMatYes"), "string", True)
                        objRecord.HazMatNo = DataHelper.SmartValues(.Item("HazMatNo"), "string", True)
                        objRecord.HazMatMFGCountry = DataHelper.SmartValues(.Item("HazMatMFGCountry"), "string", True)
                        objRecord.HazMatMFGName = DataHelper.SmartValues(.Item("HazMatMFGName"), "string", True)
                        objRecord.HazMatMFGFlammable = DataHelper.SmartValues(.Item("HazMatMFGFlammable"), "string", True)
                        objRecord.HazMatMFGCity = DataHelper.SmartValues(.Item("HazMatMFGCity"), "string", True)
                        objRecord.HazMatContainerType = DataHelper.SmartValues(.Item("HazMatContainerType"), "string", True)
                        objRecord.HazMatMFGState = DataHelper.SmartValues(.Item("HazMatMFGState"), "string", True)
                        objRecord.HazMatContainerSize = DataHelper.SmartValues(.Item("HazMatContainerSize"), "string", True)
                        objRecord.HazMatMFGPhone = DataHelper.SmartValues(.Item("HazMatMFGPhone"), "string", True)
                        objRecord.HazMatMSDSUOM = DataHelper.SmartValues(.Item("HazMatMSDSUOM"), "string", True)
                        objRecord.CoinBattery = DataHelper.SmartValues(.Item("CoinBattery"), "string", True)
                        objRecord.TSSA = DataHelper.SmartValues(.Item("TSSA"), "string", True)
                        objRecord.CSA = DataHelper.SmartValues(.Item("CSA"), "string", True)
                        objRecord.UL = DataHelper.SmartValues(.Item("UL"), "string", True)
                        objRecord.LicenceAgreement = DataHelper.SmartValues(.Item("LicenceAgreement"), "string", True)
                        objRecord.FumigationCertificate = DataHelper.SmartValues(.Item("FumigationCertificate"), "string", True)
                        objRecord.PhytoTemporaryShipment = DataHelper.SmartValues(.Item("PhytoTemporaryShipment"), "string", True)

                        objRecord.KILNDriedCertificate = DataHelper.SmartValues(.Item("KILNDriedCertificate"), "string", True)
                        objRecord.ChinaComInspecNumAndCCIBStickers = DataHelper.SmartValues(.Item("ChinaComInspecNumAndCCIBStickers"), "string", True)
                        objRecord.OriginalVisa = DataHelper.SmartValues(.Item("OriginalVisa"), "string", True)
                        objRecord.TextileDeclarationMidCode = DataHelper.SmartValues(.Item("TextileDeclarationMidCode"), "string", True)
                        objRecord.QuotaChargeStatement = DataHelper.SmartValues(.Item("QuotaChargeStatement"), "string", True)
                        objRecord.MSDS = DataHelper.SmartValues(.Item("MSDS"), "string", True)
                        objRecord.TSCA = DataHelper.SmartValues(.Item("TSCA"), "string", True)
                        objRecord.DropBallTestCert = DataHelper.SmartValues(.Item("DropBallTestCert"), "string", True)
                        objRecord.ManMedicalDeviceListing = DataHelper.SmartValues(.Item("ManMedicalDeviceListing"), "string", True)
                        objRecord.ManFDARegistration = DataHelper.SmartValues(.Item("ManFDARegistration"), "string", True)
                        objRecord.CopyRightIndemnification = DataHelper.SmartValues(.Item("CopyRightIndemnification"), "string", True)
                        objRecord.FishWildLifeCert = DataHelper.SmartValues(.Item("FishWildLifeCert"), "string", True)
                        objRecord.Proposition65LabelReq = DataHelper.SmartValues(.Item("Proposition65LabelReq"), "string", True)
                        objRecord.CCCR = DataHelper.SmartValues(.Item("CCCR"), "string", True)
                        objRecord.FormaldehydeCompliant = DataHelper.SmartValues(.Item("FormaldehydeCompliant"), "string", True)

                        objRecord.RMSSellable = DataHelper.SmartValues(.Item("RMS_Sellable"), "string", True)
                        objRecord.RMSOrderable = DataHelper.SmartValues(.Item("RMS_Orderable"), "string", True)
                        objRecord.RMSInventory = DataHelper.SmartValues(.Item("RMS_Inventory"), "string", True)

                        objRecord.ParentID = DataHelper.SmartValues(.Item("Parent_ID"), "long", False)

                        objRecord.RegularBatchItem = DataHelper.SmartValues(.Item("RegularBatchItem"), "boolean", False)

                        objRecord.DisplayerCost = DataHelper.SmartValues(.Item("Displayer_Cost"), "decimal", True)
                        objRecord.ProductCost = DataHelper.SmartValues(.Item("Product_Cost"), "decimal", True)
                        objRecord.Discountable = DataHelper.SmartValues(.Item("Discountable"), "string", True)
                        objRecord.StoreTotal = DataHelper.SmartValues(.Item("Store_Total"), "integer", True)
                        objRecord.POGStartDate = DataHelper.SmartValues(.Item("POG_Start_Date"), "date", True)
                        objRecord.POGCompDate = DataHelper.SmartValues(.Item("POG_Comp_Date"), "date", True)
                        objRecord.CalculateOptions = DataHelper.SmartValues(.Item("Calculate_Options"), "integer", False)
                        objRecord.LikeItemSKU = DataHelper.SmartValues(.Item("Like_Item_SKU"), "string", True)
                        objRecord.LikeItemDescription = DataHelper.SmartValues(.Item("Like_Item_Description"), "string", True)
                        objRecord.LikeItemRetail = DataHelper.SmartValues(.Item("Like_Item_Retail"), "decimal", True)
                        objRecord.AnnualRegularUnitForecast = DataHelper.SmartValues(.Item("Annual_Regular_Unit_Forecast"), "decimal", True)
                        'objRecord.UnitStoreMonth = DataHelper.SmartValues(.Item("Unit_Store_Month"), "decimal", True)
                        objRecord.LikeItemStoreCount = DataHelper.SmartValues(.Item("Like_Item_Store_Count"), "decimal", True)
                        objRecord.LikeItemRegularUnit = DataHelper.SmartValues(.Item("Like_Item_Regular_Unit"), "decimal", True)
                        objRecord.LikeItemUnitStoreMonth = DataHelper.SmartValues(.Item("Like_Item_Unit_Store_Month"), "decimal", True)
                        'objRecord.LIkeItemSales = DataHelper.SmartValues(.Item("Like_Item_Sales"), "decimal", True)
                        'objRecord.AdjustedYearlyDemandForecast = DataHelper.SmartValues(.Item("Adjusted_Yearly_Demand_Forecast"), "decimal", True)
                        ' objRecord.AdjustedUnitStoreMonth = DataHelper.SmartValues(.Item("Adjusted_Unit_Store_Month"), "decimal", True)
                        objRecord.AnnualRegRetailSales = DataHelper.SmartValues(.Item("Annual_Reg_Retail_Sales"), "decimal", True)
                        objRecord.Facings = DataHelper.SmartValues(.Item("Facings"), "decimal", True)
                        objRecord.MinPresPerFacing = DataHelper.SmartValues(.Item("Min_Pres_Per_Facing"), "decimal", True)
                        objRecord.InnerPack = DataHelper.SmartValues(.Item("Inner_Pack"), "decimal", True)
                        'lp Spedy Order 12 added
                        objRecord.POGMinQty = DataHelper.SmartValues(.Item("POG_Min_Qty"), "decimal", True)

                        objRecord.PrivateBrandLabel = DataHelper.SmartValues(.Item("Private_Brand_Label"), "string", True)
                        objRecord.QtyInPack = DataHelper.SmartValues(.Item("Qty_In_Pack"), "integer", True)

                        objRecord.ValidExistingSKU = DataHelper.SmartValues(.Item("Valid_Existing_SKU"), "boolean", True)
                        objRecord.ItemStatus = DataHelper.SmartValues(.Item("Item_Status"), "string", True)

                        'JC Spedy Global Link - 2/7/11
                        objRecord.QuoteReferenceNumber = DataHelper.SmartValues(.Item("QuoteReferenceNumber"), "string", True)

                        objRecord.StockingStrategyCode = DataHelper.SmartValues(.Item("Stocking_Strategy_Code"), "string", True)
                        objRecord.CanadaHarmonizedCodeNumber = DataHelper.SmartValues(.Item("CanadaHarmonizedCodeNumber"), "string", True)

                        objRecord.EachHeight = DataHelper.SmartValues(.Item("eachheight"), "decimal", True)
                        objRecord.EachWidth = DataHelper.SmartValues(.Item("EachWidth"), "decimal", True)
                        objRecord.EachLength = DataHelper.SmartValues(.Item("EachLength"), "decimal", True)
                        objRecord.EachWeight = DataHelper.SmartValues(.Item("EachWeight"), "decimal", True)
                        objRecord.CubicFeetEach = DataHelper.SmartValues(.Item("CubicFeetEach"), "decimal", True)

                        objRecord.ReshippableInnerCartonWeight = DataHelper.SmartValues(.Item("ReshippableInnerCartonWeight"), "decimal", True)

                        objRecord.SuppTariffPercent = DataHelper.SmartValues(.Item("SuppTariffPercent"), "string", True)
                        objRecord.SuppTariffAmount = DataHelper.SmartValues(.Item("SuppTariffAmount"), "string", True)

                        objRecord.MinimumOrderQuantity = DataHelper.SmartValues(.Item("MinimumOrderQuantity"), "integer", False)
                        objRecord.ProductIdentifiesAsCosmetic = DataHelper.SmartValues(.Item("ProductIdentifiesAsCosmetic"), "string", True)

                        'Dim iifd As New NovaLibra.Coral.Data.Michaels.ImportItemFileData()
                        NovaLibra.Coral.SystemFrameworks.Michaels.FriendDataHelper.SetImportItemUserData(objRecord,
                            DataHelper.SmartValues(.Item("DateCreated"), "date", True),
                            DataHelper.SmartValues(.Item("CreatedUserID"), "integer", True),
                            DataHelper.SmartValues(.Item("DateLastModified"), "date", True),
                            DataHelper.SmartValues(.Item("UpdateUserID"), "integer", True),
                            DataHelper.SmartValues(.Item("CreatedUser"), "string", True),
                            DataHelper.SmartValues(.Item("UpdateUser"), "string", True),
                            DataHelper.SmartValues(.Item("Image_File_ID"), "long", True),
                            DataHelper.SmartValues(.Item("MSDS_File_ID"), "long", True))
                        'iifd = Nothing

                        NovaLibra.Coral.SystemFrameworks.Michaels.FriendDataHelper.SetImportItemTaxWizard(objRecord,
                            DataHelper.SmartValues(.Item("Tax_Wizard"), "boolean", False))

                        objRecord.AdditionalUPCRecord = AdditionalUPCsData.GetItemAdditionalUPCs(0, objRecord.ID)

                    End With
                Else
                    objRecord.ID = 0
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                objRecord.ID = -1
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then '
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return objRecord
        End Function

        ' Apply Private Brand Label field to all items in batch
        Public Function ApplyPBLToAll(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord, ByVal userID As Integer) As Boolean

            Dim sql As String = "usp_SPD_Import_Item_ApplyPBLtoBatch"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Dim bUpdated As Boolean = False

            Try
                'If objRecord.ID <= 0 Then
                '    objRecord.AuditType = AuditRecordType.Insert
                'Else
                '    objRecord.AuditType = AuditRecordType.Update
                'End If
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@RetValue", SqlDbType.Int)
                objParam.Direction = ParameterDirection.ReturnValue
                cmd.Parameters.Add(objParam)

                cmd.Parameters.Add("@Batch_ID", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.Batch_ID, "long", True)
                cmd.Parameters.Add("@PrivateBrandLabel", SqlDbType.VarChar, 20).Value = DataHelper.DBSmartValues(objRecord.PrivateBrandLabel, "string", True)
                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = DataHelper.DBSmartValues(userID, "integer", True)
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
                bUpdated = (cmd.Parameters("@RetValue").Value = 1)

                ' save audit record
                'If objRecord.SaveAudit Then
                '    objRecord.AuditRecordID = recordID
                '    Me.SaveAuditRecord(objRecord, conn)
                'End If

            Catch ex As Exception
                Logger.LogError(ex)
                'Throw ex
            Finally
                If Not cmd Is Nothing Then
                    cmd.Dispose()
                    cmd = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return bUpdated
        End Function

        Public Function SaveItemRecord(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.ImportItemRecord, ByVal userID As Integer, ByVal SaveImage As Boolean, ByVal BatchAction As String, ByVal BatchNotes As String, Optional ByVal SkipInvalidatingPackChildren As Boolean = False, Optional ByVal isDirty As Boolean = True) As Long
            Dim sql As String = "sp_SPD_Import_Item_SaveRecord"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Dim recordID As Long = 0
            Try
                If objRecord.ID <= 0 Then
                    objRecord.AuditType = AuditRecordType.Insert
                Else
                    objRecord.AuditType = AuditRecordType.Update
                End If
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Direction = ParameterDirection.InputOutput
                objParam.Value = objRecord.ID
                cmd.Parameters.Add(objParam)
                cmd.Parameters.Add("@Batch_ID", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.Batch_ID, "long", True)
                cmd.Parameters.Add("@DateSubmitted", SqlDbType.DateTime).Value = DataHelper.DBSmartValues(objRecord.DateSubmitted, "date", True)
                cmd.Parameters.Add("@Vendor", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.Vendor, "string", True)
                cmd.Parameters.Add("@Agent", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.Agent, "string", True)
                cmd.Parameters.Add("@AgentType", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.AgentType, "string", True)
                cmd.Parameters.Add("@Buyer", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.Buyer, "string", True)
                cmd.Parameters.Add("@Fax", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.Fax, "string", True)
                cmd.Parameters.Add("@EnteredBy", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.EnteredBy, "string", True)
                cmd.Parameters.Add("@SKUGroup", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.SKUGroup, "string", True)
                cmd.Parameters.Add("@Email", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.Email, "string", True)
                cmd.Parameters.Add("@EnteredDate", SqlDbType.DateTime).Value = DataHelper.DBSmartValues(objRecord.EnteredDate, "date", True)
                cmd.Parameters.Add("@Dept", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.Dept, "string", True)
                cmd.Parameters.Add("@Class", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.Class, "string", True)
                cmd.Parameters.Add("@SubClass", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.SubClass, "string", True)
                cmd.Parameters.Add("@PrimaryUPC", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.PrimaryUPC, "string", True)
                cmd.Parameters.Add("@MichaelsSKU", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.MichaelsSKU, "string", True)
                cmd.Parameters.Add("@GenerateMichaelsUPC", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.GenerateMichaelsUPC, "string", True)
                'PMO200141 GTIN14 Enhancements changes start
                cmd.Parameters.Add("@InnerGTIN", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.InnerGTIN, "string", True)
                cmd.Parameters.Add("@CaseGTIN", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.CaseGTIN, "string", True)
                cmd.Parameters.Add("@GenerateMichaelsGTIN", SqlDbType.VarChar, 1).Value = DataHelper.DBSmartValues(objRecord.GenerateMichaelsGTIN, "string", True)
                'PMO200141 GTIN14 Enhancements changes end
                ' AdditionalUPC1 - AdditionalUPC8 (moved to additional UPCs below)
                cmd.Parameters.Add("@PackSKU", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.PackSKU, "string", True)
                cmd.Parameters.Add("@PlanogramName", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.PlanogramName, "string", True)
                cmd.Parameters.Add("@VendorNumber", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.VendorNumber, "string", True)
                cmd.Parameters.Add("@VendorRank", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.VendorRank, "string", True)
                cmd.Parameters.Add("@ItemTask", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ItemTask, "string", True)
                cmd.Parameters.Add("@Description", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.Description, "string", True)
                cmd.Parameters.Add("@VendorMinOrderAmount", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.VendorMinOrderAmount, "string", True)
                cmd.Parameters.Add("@VendorContactName", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.VendorContactName, "string", True)
                cmd.Parameters.Add("@VendorContactPhone", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.VendorContactPhone, "string", True)
                cmd.Parameters.Add("@VendorContactEmail", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.VendorContactEmail, "string", True)
                cmd.Parameters.Add("@VendorContactFax", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.VendorContactFax, "string", True)
                cmd.Parameters.Add("@ManufactureContact", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ManufactureContact, "string", True)
                cmd.Parameters.Add("@ManufacturePhone", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ManufacturePhone, "string", True)
                cmd.Parameters.Add("@ManufactureEmail", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ManufactureEmail, "string", True)
                cmd.Parameters.Add("@ManufactureFax", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ManufactureFax, "string", True)
                cmd.Parameters.Add("@AgentContact", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.AgentContact, "string", True)
                cmd.Parameters.Add("@AgentPhone", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.AgentPhone, "string", True)
                cmd.Parameters.Add("@AgentEmail", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.AgentEmail, "string", True)
                cmd.Parameters.Add("@AgentFax", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.AgentFax, "string", True)
                cmd.Parameters.Add("@VendorStyleNumber", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.VendorStyleNumber, "string", True)
                cmd.Parameters.Add("@HarmonizedCodeNumber", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.HarmonizedCodeNumber, "string", True)
                cmd.Parameters.Add("@DetailInvoiceCustomsDesc", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.DetailInvoiceCustomsDesc, "string", True)
                cmd.Parameters.Add("@ComponentMaterialBreakdown", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ComponentMaterialBreakdown, "string", True)
                cmd.Parameters.Add("@ComponentConstructionMethod", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ComponentConstructionMethod, "string", True)
                cmd.Parameters.Add("@IndividualItemPackaging", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.IndividualItemPackaging, "string", True)
                cmd.Parameters.Add("@EachInsideMasterCaseBox", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.EachInsideMasterCaseBox, "string", True)
                cmd.Parameters.Add("@EachInsideInnerPack", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.EachInsideInnerPack, "string", True)
                'cmd.Parameters.Add("@EachPieceNetWeightLbsPerOunce", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.EachPieceNetWeightLbsPerOunce, "string", True)
                cmd.Parameters.Add("@ReshippableInnerCartonLength", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ReshippableInnerCartonLength, "string", True)
                cmd.Parameters.Add("@ReshippableInnerCartonWidth", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ReshippableInnerCartonWidth, "string", True)
                cmd.Parameters.Add("@ReshippableInnerCartonHeight", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ReshippableInnerCartonHeight, "string", True)
                cmd.Parameters.Add("@MasterCartonDimensionsLength", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.MasterCartonDimensionsLength, "string", True)
                cmd.Parameters.Add("@MasterCartonDimensionsWidth", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.MasterCartonDimensionsWidth, "string", True)
                cmd.Parameters.Add("@MasterCartonDimensionsHeight", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.MasterCartonDimensionsHeight, "string", True)
                cmd.Parameters.Add("@CubicFeetPerMasterCarton", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.CubicFeetPerMasterCarton, "string", True)
                cmd.Parameters.Add("@WeightMasterCarton", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.WeightMasterCarton, "string", True)
                cmd.Parameters.Add("@CubicFeetPerInnerCarton", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.CubicFeetPerInnerCarton, "string", True)
                cmd.Parameters.Add("@FOBShippingPoint", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.FOBShippingPoint, "string", True)
                cmd.Parameters.Add("@DutyPercent", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.DutyPercent, "string", True)
                cmd.Parameters.Add("@DutyAmount", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.DutyAmount, "string", True)
                cmd.Parameters.Add("@AdditionalDutyComment", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.AdditionalDutyComment, "string", True)
                cmd.Parameters.Add("@AdditionalDutyAmount", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.AdditionalDutyAmount, "string", True)
                cmd.Parameters.Add("@OceanFreightAmount", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.OceanFreightAmount, "string", True)
                cmd.Parameters.Add("@OceanFreightComputedAmount", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.OceanFreightComputedAmount, "string", True)
                cmd.Parameters.Add("@AgentCommissionPercent", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.AgentCommissionPercent, "string", True)
                cmd.Parameters.Add("@AgentCommissionAmount", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.AgentCommissionAmount, "string", True)
                cmd.Parameters.Add("@OtherImportCostsPercent", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.OtherImportCostsPercent, "string", True)
                cmd.Parameters.Add("@OtherImportCostsAmount", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.OtherImportCostsAmount, "string", True)
                cmd.Parameters.Add("@PackagingCostAmount", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.PackagingCostAmount, "string", True)
                cmd.Parameters.Add("@TotalImportBurden", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.TotalImportBurden, "string", True)
                cmd.Parameters.Add("@WarehouseLandedCost", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.WarehouseLandedCost, "string", True)
                cmd.Parameters.Add("@PurchaseOrderIssuedTo", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.PurchaseOrderIssuedTo, "string", True)
                cmd.Parameters.Add("@ShippingPoint", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ShippingPoint, "string", True)
                cmd.Parameters.Add("@CountryOfOrigin", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.CountryOfOrigin, "string", True)
                cmd.Parameters.Add("@CountryOfOriginName", SqlDbType.VarChar, 50).Value = DataHelper.DBSmartValues(objRecord.CountryOfOriginName, "string", True)
                cmd.Parameters.Add("@VendorComments", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.VendorComments, "string", True)
                cmd.Parameters.Add("@StockCategory", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.StockCategory, "string", True)
                cmd.Parameters.Add("@FreightTerms", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.FreightTerms, "string", True)
                cmd.Parameters.Add("@ItemType", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ItemType, "string", True)
                cmd.Parameters.Add("@PackItemIndicator", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.PackItemIndicator, "string", True)
                cmd.Parameters.Add("@ItemTypeAttribute", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ItemTypeAttribute, "string", True)
                cmd.Parameters.Add("@AllowStoreOrder", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.AllowStoreOrder, "string", True)
                cmd.Parameters.Add("@InventoryControl", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.InventoryControl, "string", True)
                cmd.Parameters.Add("@Discountable", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.Discountable, "string", True)
                cmd.Parameters.Add("@AutoReplenish", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.AutoReplenish, "string", True)
                cmd.Parameters.Add("@PrePriced", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.PrePriced, "string", True)
                cmd.Parameters.Add("@TaxUDA", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.TaxUDA, "string", True)
                cmd.Parameters.Add("@PrePricedUDA", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.PrePricedUDA, "string", True)
                cmd.Parameters.Add("@TaxValueUDA", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.TaxValueUDA, "string", True)
                cmd.Parameters.Add("@HybridType", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.HybridType, "string", True)
                cmd.Parameters.Add("@SourcingDC", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.SourcingDC, "string", True)
                cmd.Parameters.Add("@LeadTime", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.LeadTime, "string", True)
                cmd.Parameters.Add("@ConversionDate", SqlDbType.DateTime).Value = DataHelper.DBSmartValues(objRecord.ConversionDate, "date", True)
                cmd.Parameters.Add("@StoreSuppZoneGRP", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.StoreSuppZoneGRP, "string", True)
                cmd.Parameters.Add("@WhseSuppZoneGRP", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.WhseSuppZoneGRP, "string", True)
                cmd.Parameters.Add("@POGMaxQty", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.POGMaxQty, "string", True)
                cmd.Parameters.Add("@POGSetupPerStore", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.POGSetupPerStore, "string", True)
                cmd.Parameters.Add("@ProjSalesPerStorePerMonth", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ProjSalesPerStorePerMonth, "string", True)
                cmd.Parameters.Add("@OutboundFreight", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.OutboundFreight, "string", True)
                cmd.Parameters.Add("@NinePercentWhseCharge", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.NinePercentWhseCharge, "string", True)
                cmd.Parameters.Add("@TotalStoreLandedCost", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.TotalStoreLandedCost, "string", True)
                cmd.Parameters.Add("@RDBase", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.RDBase, "string", True)
                cmd.Parameters.Add("@RDCentral", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.RDCentral, "string", True)
                cmd.Parameters.Add("@RDTest", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.RDTest, "string", True)
                cmd.Parameters.Add("@RDAlaska", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.RDAlaska, "string", True)
                cmd.Parameters.Add("@RDCanada", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.RDCanada, "string", True)
                cmd.Parameters.Add("@RD0Thru9", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.RD0Thru9, "string", True)
                cmd.Parameters.Add("@RDCalifornia", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.RDCalifornia, "string", True)
                cmd.Parameters.Add("@RDVillageCraft", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.RDVillageCraft, "string", True)
                cmd.Parameters.Add("@HazMatYes", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.HazMatYes, "string", True)
                cmd.Parameters.Add("@HazMatNo", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.HazMatNo, "string", True)
                cmd.Parameters.Add("@HazMatMFGCountry", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.HazMatMFGCountry, "string", True)
                cmd.Parameters.Add("@HazMatMFGName", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.HazMatMFGName, "string", True)
                cmd.Parameters.Add("@HazMatMFGFlammable", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.HazMatMFGFlammable, "string", True)
                cmd.Parameters.Add("@HazMatMFGCity", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.HazMatMFGCity, "string", True)
                cmd.Parameters.Add("@HazMatContainerType", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.HazMatContainerType, "string", True)
                cmd.Parameters.Add("@HazMatMFGState", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.HazMatMFGState, "string", True)
                cmd.Parameters.Add("@HazMatContainerSize", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.HazMatContainerSize, "string", True)
                cmd.Parameters.Add("@HazMatMFGPhone", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.HazMatMFGPhone, "string", True)
                cmd.Parameters.Add("@HazMatMSDSUOM", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.HazMatMSDSUOM, "string", True)
                cmd.Parameters.Add("@CoinBattery", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.CoinBattery, "string", True)
                cmd.Parameters.Add("@TSSA", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.TSSA, "string", True)
                cmd.Parameters.Add("@CSA", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.CSA, "string", True)
                cmd.Parameters.Add("@UL", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.UL, "string", True)
                cmd.Parameters.Add("@LicenceAgreement", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.LicenceAgreement, "string", True)
                cmd.Parameters.Add("@FumigationCertificate", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.FumigationCertificate, "string", True)
                cmd.Parameters.Add("@PhytoTemporaryShipment", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.PhytoTemporaryShipment, "string", True)
                cmd.Parameters.Add("@KILNDriedCertificate", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.KILNDriedCertificate, "string", True)
                cmd.Parameters.Add("@ChinaComInspecNumAndCCIBStickers", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ChinaComInspecNumAndCCIBStickers, "string", True)
                cmd.Parameters.Add("@OriginalVisa", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.OriginalVisa, "string", True)
                cmd.Parameters.Add("@TextileDeclarationMidCode", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.TextileDeclarationMidCode, "string", True)
                cmd.Parameters.Add("@QuotaChargeStatement", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.QuotaChargeStatement, "string", True)
                cmd.Parameters.Add("@MSDS", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.MSDS, "string", True)
                cmd.Parameters.Add("@TSCA", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.TSCA, "string", True)
                cmd.Parameters.Add("@DropBallTestCert", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.DropBallTestCert, "string", True)
                cmd.Parameters.Add("@ManMedicalDeviceListing", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ManMedicalDeviceListing, "string", True)
                cmd.Parameters.Add("@ManFDARegistration", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ManFDARegistration, "string", True)
                cmd.Parameters.Add("@CopyRightIndemnification", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.CopyRightIndemnification, "string", True)
                cmd.Parameters.Add("@FishWildLifeCert", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.FishWildLifeCert, "string", True)
                cmd.Parameters.Add("@Proposition65LabelReq", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.Proposition65LabelReq, "string", True)
                cmd.Parameters.Add("@CCCR", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.CCCR, "string", True)
                cmd.Parameters.Add("@FormaldehydeCompliant", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.FormaldehydeCompliant, "string", True)
                cmd.Parameters.Add("@QuoteSheetStatus", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.QuoteSheetStatus, "string", True)
                cmd.Parameters.Add("@Season", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.Season, "string", True)
                cmd.Parameters.Add("@VendorName", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.VendorName, "string", True)
                cmd.Parameters.Add("@VendorAddress1", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.VendorAddress1, "string", True)
                cmd.Parameters.Add("@VendorAddress2", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.VendorAddress2, "string", True)
                cmd.Parameters.Add("@VendorAddress3", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.VendorAddress3, "string", True)
                cmd.Parameters.Add("@VendorAddress4", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.VendorAddress4, "string", True)
                cmd.Parameters.Add("@ManufactureName", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ManufactureName, "string", True)
                cmd.Parameters.Add("@ManufactureAddress1", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ManufactureAddress1, "string", True)
                cmd.Parameters.Add("@ManufactureAddress2", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ManufactureAddress2, "string", True)

                'removed 2020-09-11
                'cmd.Parameters.Add("@PaymentTerms", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.PaymentTerms, "string", True)
                'cmd.Parameters.Add("@Days", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.Days, "string", True)
                cmd.Parameters.Add("@PaymentTerms", SqlDbType.VarChar).Value = ""
                cmd.Parameters.Add("@Days", SqlDbType.VarChar).Value = ""


                cmd.Parameters.Add("@RMS_Sellable", SqlDbType.VarChar, 1).Value = objRecord.RMSSellable
                cmd.Parameters.Add("@RMS_Orderable", SqlDbType.VarChar, 1).Value = objRecord.RMSOrderable
                cmd.Parameters.Add("@RMS_Inventory", SqlDbType.VarChar, 1).Value = objRecord.RMSInventory

                cmd.Parameters.Add("@Parent_ID", SqlDbType.BigInt).Value = objRecord.ParentID

                cmd.Parameters.Add("@RegularBatchItem", SqlDbType.Bit).Value = objRecord.RegularBatchItem

                cmd.Parameters.Add("@Batch_Action", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(BatchAction, "string", True)
                cmd.Parameters.Add("@Batch_Notes", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(BatchNotes, "string", True)

                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = DataHelper.DBSmartValues(userID, "integer", True)

                cmd.Parameters.Add("@Displayer_Cost", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.DisplayerCost, "decimal", True)
                cmd.Parameters.Add("@Product_Cost", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.ProductCost, "decimal", True)

                cmd.Parameters.Add("@Store_Total", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.StoreTotal, "integer", True)
                cmd.Parameters.Add("@POG_Start_Date", SqlDbType.DateTime).Value = DataHelper.DBSmartValues(objRecord.POGStartDate, "date", True)
                cmd.Parameters.Add("@POG_Comp_Date", SqlDbType.DateTime).Value = DataHelper.DBSmartValues(objRecord.POGCompDate, "date", True)
                cmd.Parameters.Add("@Calculate_Options", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.CalculateOptions, "integer", True)
                cmd.Parameters.Add("@Like_Item_SKU", SqlDbType.VarChar, 20).Value = DataHelper.DBSmartValues(objRecord.LikeItemSKU, "string", True)
                cmd.Parameters.Add("@Like_Item_Description", SqlDbType.VarChar, 255).Value = DataHelper.DBSmartValues(objRecord.LikeItemDescription, "string", True)
                cmd.Parameters.Add("@Like_Item_Retail", SqlDbType.Money).Value = DataHelper.DBSmartValues(objRecord.LikeItemRetail, "decimal", True)
                cmd.Parameters.Add("@Annual_Regular_Unit_Forecast", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.AnnualRegularUnitForecast, "decimal", True)
                'cmd.Parameters.Add("@Unit_Store_Month", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.UnitStoreMonth, "decimal", True)
                cmd.Parameters.Add("@Like_Item_Store_Count", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.LikeItemStoreCount, "decimal", True)
                cmd.Parameters.Add("@Like_Item_Regular_Unit", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.LikeItemRegularUnit, "decimal", True)
                cmd.Parameters.Add("@Like_Item_Unit_Store_Month", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.LikeItemUnitStoreMonth, "decimal", True)
                'cmd.Parameters.Add("@Like_Item_Sales", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.LikeItemSales, "decimal", True)
                'cmd.Parameters.Add("@Adjusted_Yearly_Demand_Forecast", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.AdjustedYearlyDemandForecast, "decimal", True)
                'cmd.Parameters.Add("@Adjusted_Unit_Store_Month", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.AdjustedUnitStoreMonth, "decimal", True)
                cmd.Parameters.Add("@Annual_Reg_Retail_Sales", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.AnnualRegRetailSales, "decimal", True)
                cmd.Parameters.Add("@Facings", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.Facings, "decimal", True)
                cmd.Parameters.Add("@Min_Pres_Per_Facing", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.MinPresPerFacing, "decimal", True)
                cmd.Parameters.Add("@Inner_Pack", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.InnerPack, "decimal", True)
                'lp Spedy Order 12
                cmd.Parameters.Add("@POG_Min_Qty", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.POGMinQty, "decimal", True)
                'lp Change Order 14
                cmd.Parameters.Add("@Retail9", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.Retail9, "decimal", True)
                cmd.Parameters.Add("@Retail10", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.Retail10, "decimal", True)
                cmd.Parameters.Add("@Retail11", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.Retail11, "decimal", True)
                cmd.Parameters.Add("@Retail12", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.Retail12, "decimal", True)
                cmd.Parameters.Add("@Retail13", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.Retail13, "decimal", True)
                cmd.Parameters.Add("@RDQuebec", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.RDQuebec, "decimal", True)
                cmd.Parameters.Add("@RDPuertoRico", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.RDPuertoRico, "decimal", True)
                'lp
                cmd.Parameters.Add("@Private_Brand_Label", SqlDbType.VarChar, 20).Value = DataHelper.DBSmartValues(objRecord.PrivateBrandLabel, "string", True)

                cmd.Parameters.Add("@Qty_In_Pack", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.QtyInPack, "integer", True)

                cmd.Parameters.Add("@Valid_Existing_SKU", SqlDbType.Bit).Value = DataHelper.DBSmartValues(objRecord.ValidExistingSKU, "boolean", True)
                cmd.Parameters.Add("@Item_Status", SqlDbType.VarChar, 10).Value = DataHelper.DBSmartValues(objRecord.ItemStatus, "string", True)

                cmd.Parameters.Add("@SkipInvalidatingPackChildren", SqlDbType.Bit).Value = DataHelper.DBSmartValues(SkipInvalidatingPackChildren, "boolean", True)

                'JC Spedy Global Link - 2/7/11
                cmd.Parameters.Add("@QuoteReferenceNumber", SqlDbType.VarChar, 20).Value = DataHelper.DBSmartValues(objRecord.QuoteReferenceNumber, "string", True)
                cmd.Parameters.Add("@CustomsDescription", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.CustomsDescription, "string", True)
                cmd.Parameters.Add("@IsDirty", SqlDbType.Bit).Value = isDirty

                'new stocking strat fields
                cmd.Parameters.Add("@Stocking_Strategy_Code", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.StockingStrategyCode, "string", True)
                cmd.Parameters.Add("@EachHeight", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.EachHeight, "decimal", True)
                cmd.Parameters.Add("@EachWidth", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.EachWidth, "decimal", True)
                cmd.Parameters.Add("@EachLength", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.EachLength, "decimal", True)
                cmd.Parameters.Add("@EachWeight", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.EachWeight, "decimal", True)
                cmd.Parameters.Add("@CubicFeetEach", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.CubicFeetEach, "decimal", True)
                cmd.Parameters.Add("@CanadaHarmonizedCodeNumber", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.CanadaHarmonizedCodeNumber, "string", True)

                cmd.Parameters.Add("@ReshippableInnerCartonWeight", SqlDbType.Decimal).Value = DataHelper.DBSmartValues(objRecord.ReshippableInnerCartonWeight, "decimal", True)

                cmd.Parameters.Add("@SuppTariffPercent", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.SuppTariffPercent, "string", True)
                cmd.Parameters.Add("@SuppTariffAmount", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.SuppTariffAmount, "string", True)

                cmd.Parameters.Add("@MinimumOrderQuantity", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.MinimumOrderQuantity, "integer", True)
                cmd.Parameters.Add("@ProductIdentifiesAsCosmetic", SqlDbType.VarChar).Value = DataHelper.DBSmartValues(objRecord.ProductIdentifiesAsCosmetic, "string", True)

                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
                recordID = cmd.Parameters("@ID").Value

                Debug.Assert(objRecord.ID <= 0 OrElse (objRecord.ID > 0 And objRecord.ID = recordID))
                ' must set the record ID so that the addiational upc values have the proper ID when saving.
                objRecord.ID = recordID

                ' save additional upcs
                If Not objRecord.AdditionalUPCRecord Is Nothing Then
                    AdditionalUPCsData.SaveItemAdditionalUPCs(objRecord.AdditionalUPCRecord, userID, conn)
                End If

                ' save audit record
                If objRecord.SaveAudit Then
                    objRecord.AuditRecordID = recordID
                    Me.SaveAuditRecord(objRecord, conn)
                End If

            Catch ex As Exception
                Logger.LogError(ex)
                objRecord.ID = -1
                recordID = 0
                'Throw ex
            Finally
                If Not cmd Is Nothing Then
                    cmd.Dispose()
                    cmd = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return recordID
        End Function

        Public Function DeleteItemRecord(ByVal id As Long, ByVal userID As Integer) As Boolean

            Dim sql As String = "sp_SPD_Import_Item_DeleteRecord"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Dim bSuccess As Boolean = True

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@ID", SqlDbType.BigInt)
                objParam.Value = id
                cmd.Parameters.Add(objParam)
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()

                Dim audit As New AuditRecord()
                audit.SetupAudit(MetadataTable.Import_Items, id, AuditRecordType.Delete, userID)
                Me.SaveAuditRecord(audit, conn)
                audit = Nothing

            Catch ex As Exception
                Logger.LogError(ex)

                bSuccess = False
                'Throw ex
            Finally
                If Not cmd Is Nothing Then
                    cmd.Dispose()
                    cmd = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If

            End Try
            Return bSuccess
        End Function

        Public Function GetChildItems(ByVal id As Long, ByVal includeParent As Boolean) As ArrayList
            Dim objList As ArrayList = New ArrayList()
            Dim sql As String = String.Empty
            Dim bNext As Boolean = True
            Dim iv As Int16
            Dim reg As Boolean
            If includeParent Then
                sql += "select ID, Is_Valid, RegularBatchItem from SPD_Import_Items where [ID] = @ID; "
            End If
            sql += "select ID, Is_Valid, RegularBatchItem from SPD_Import_Items where Parent_ID = @ID order by ID;"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection(False)
                conn.Open()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@ID", SqlDbType.BigInt).Value = id
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()

                If includeParent Then
                    If reader.Read() Then
                        iv = DataHelper.SmartValues(reader.Item("Is_Valid"), "smallint", True)
                        reg = DataHelper.SmartValues(reader.Item("RegularBatchItem"), "boolean", False)
                        objList.Add(New ImportItemChildRecord(DataHelper.SmartValues(reader.Item("ID"), "long", False), GetIsValidFlag(iv), reg))
                        bNext = reader.NextResult()
                    Else
                        bNext = False
                    End If
                End If

                If bNext Then
                    Do While reader.Read()
                        iv = DataHelper.SmartValues(reader.Item("Is_Valid"), "smallint", True)
                        reg = DataHelper.SmartValues(reader.Item("RegularBatchItem"), "boolean", False)
                        objList.Add(New ImportItemChildRecord(DataHelper.SmartValues(reader.Item("ID"), "long", False), GetIsValidFlag(iv), reg))
                    Loop
                End If

            Catch sqlex As SqlException
                Logger.LogError(sqlex)
                Throw sqlex
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                cmd = Nothing
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return objList
        End Function

        Public Function GetAddToBatchRecords(ByVal id As Long) As ArrayList
            Dim objList As ArrayList = New ArrayList()
            Dim sql As String = String.Empty
            sql = "sp_SPD_Import_Item_GetAddToBatchList"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection(False)
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@itemID", SqlDbType.BigInt).Value = id
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                Do While reader.Read()
                    objList.Add(New ImportItemAddToBatchRecord(DataHelper.SmartValues(reader.Item("ID"), "long", False), DataHelper.SmartValues(reader.Item("ItemCount"), "integer", False)))
                Loop

            Catch sqlex As SqlException
                Logger.LogError(sqlex)
                Throw sqlex
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                cmd = Nothing
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return objList
        End Function

        Public Function AddToBatch(ByVal id As Long, ByVal fromBatchID As Long, ByVal userID As Integer) As Boolean
            Dim sql As String = "sp_SPD_Import_Item_AddToBatch"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            'Dim objParam As System.Data.SqlClient.SqlParameter
            Dim bSuccess As Boolean = True
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@itemID", SqlDbType.BigInt).Value = DataHelper.SmartValues(id, "long", False)
                cmd.Parameters.Add("@fromBatchID", SqlDbType.BigInt).Value = DataHelper.SmartValues(fromBatchID, "long", False)
                cmd.Parameters.Add("@User_ID", SqlDbType.Int).Value = DataHelper.SmartValues(userID, "integer", False)
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()
            Catch ex As Exception
                Logger.LogError(ex)
                bSuccess = False
                'Throw ex
            Finally
                If Not cmd Is Nothing Then
                    cmd.Dispose()
                    cmd = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If

            End Try
            Return bSuccess
        End Function

        Private Function GetIsValidFlag(ByVal iv As Int16) As ItemValidFlag
            If iv = 1 Then
                Return ItemValidFlag.Valid
            ElseIf iv = 0 Then
                Return ItemValidFlag.NotValid
            Else
                Return ItemValidFlag.Unknown
            End If
        End Function

        'Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        '    If Not Me.disposed Then
        '        If disposing Then
        '            ' Insert code to free unmanaged resources.
        '        End If
        '        ' Insert code to free shared resources.
        '    End If
        '    MyBase.Dispose(disposing)
        'End Sub


        'Public Sub New()
        '    MyBase.New()
        'End Sub
    End Class

End Namespace


