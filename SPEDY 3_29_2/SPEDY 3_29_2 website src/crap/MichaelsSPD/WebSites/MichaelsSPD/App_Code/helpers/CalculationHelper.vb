Imports System
Imports System.Text
Imports System.Web.UI.WebControls
Imports System.Xml
Imports System.Xml.XPath

Imports Microsoft.VisualBasic

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels

Public Class CalculationHelper

    Public Const CALC_IMPORT_OUTBOUND_FREIGHT_PERCENT As Decimal = 0.06
    Public Const CALC_IMPORT_NINE_WAREHOUSE_PERCENT As Decimal = 0.09

    Public Shared Sub CalcIMDomesticUploadChanges(ByRef record As Models.ItemMaintItemDetailFormRecord)

        ' each case
        record.EachCaseCube = CalcImportCubicFeetPerMasterCarton(record.EachCaseLength, record.EachCaseWidth, record.EachCaseHeight)

        ' inner case
        record.InnerCaseCube = CalcImportCubicFeetPerMasterCarton(record.InnerCaseLength, record.InnerCaseWidth, record.InnerCaseHeight)

        ' master case
        record.MasterCaseCube = CalcImportCubicFeetPerMasterCarton(record.MasterCaseLength, record.MasterCaseWidth, record.MasterCaseHeight)

        ' item cost
        If record.ItemCost >= 0 AndAlso record.DisplayerCost >= 0 Then
            record.FOBShippingPoint = record.ItemCost + record.DisplayerCost
        ElseIf record.ItemCost <> Decimal.MinValue Then
            record.FOBShippingPoint = record.ItemCost
        Else
            record.FOBShippingPoint = Decimal.MinValue
        End If

    End Sub

    ' Used By Item Maint Upload routine
    Public Shared Sub CalcIMUploadChanges(ByRef record As Models.ItemMaintItemDetailFormRecord) '
        Dim cube As Decimal = CalcImportCubicFeetPerMasterCarton(record.InnerCaseLength, record.InnerCaseWidth, record.InnerCaseHeight)
        If cube <> Decimal.MinValue Then record.InnerCaseCube = DataHelper.SmartValues(cube, "decimal", False)

        cube = CalcImportCubicFeetPerMasterCarton(record.MasterCaseLength, record.MasterCaseWidth, record.MasterCaseHeight)
        If cube <> Decimal.MinValue Then record.MasterCaseCube = DataHelper.SmartValues(cube, "decimal", False)

        cube = CalcImportCubicFeetPerMasterCarton(record.EachCaseLength, record.EachCaseWidth, record.EachCaseHeight)
        If cube <> Decimal.MinValue Then record.EachCaseCube = DataHelper.SmartValues(cube, "decimal", False)

        cube = CalcImportFOB(record.DisplayerCost, record.ItemCost)
        If cube <> Decimal.MinValue Then record.FOBShippingPoint = DataHelper.SmartValues(cube, "decimal", False)

        ' Calc routines expect Percents to be in xx.xx% format not 0.xxxx   
        ' NOTE if Fast Sheet starts allowing Percent fields to be entered then for Percent fields below need to be fixed

        Dim agent As String = IIf(record.VendorOrAgent = "A", "X", "")
        Dim dispcost As Decimal = record.DisplayerCost
        Dim prodcost As Decimal = record.ProductCost
        Dim fob As Decimal = record.FOBShippingPoint
        Dim dutyper As Decimal = record.DutyPercent
        If dutyper <> Decimal.MinValue Then dutyper = dutyper * 100

        Dim addduty As Decimal = record.AdditionalDutyAmount

        Dim supptariffper As Decimal = record.SuppTariffPercent
        If supptariffper <> Decimal.MinValue Then supptariffper = supptariffper * 100

        Dim eachesmc As Decimal = record.EachesMasterCase
        Dim mclength As Decimal = record.MasterCaseLength
        Dim mcwidth As Decimal = record.MasterCaseWidth
        Dim mcheight As Decimal = record.MasterCaseHeight
        Dim oceanfre As Decimal = record.OceanFreightAmount
        Dim oceanamt As Decimal = record.OceanFreightComputedAmount
        Dim agentcommper As Decimal = record.AgentCommissionPercent
        If agentcommper <> Decimal.MinValue Then agentcommper = agentcommper * 100

        Dim otherimportper As Decimal = record.OtherImportCostsPercent  'DataHelper.SmartValues(GetXMLValue(xmlin, "otherimportper"), "decimal", True)
        If otherimportper <> Decimal.MinValue Then otherimportper = otherimportper * 100

        Dim packcost As Decimal = record.PackagingCostAmount            'DataHelper.SmartValues(GetXMLValue(xmlin, "packcost"), "decimal", True)

        Dim cubicftpermc As Decimal = CalcImportCubicFeetPerMasterCarton(record.MasterCaseLength, record.MasterCaseWidth, record.MasterCaseHeight)

        Dim duty As Decimal = CalcImportDuty(fob, dutyper)

        Dim supptariff As Decimal = CalcSuppTariff(fob, supptariffper)

        Dim ocean As Decimal = CalcImportOceanFrieght(eachesmc, cubicftpermc, oceanfre)
        ocean = Decimal.Round(ocean, 6)

        Dim agentcomm As Decimal = CalcImportAgentComm(agent, fob, agentcommper)
        Dim otherimport As Decimal = CalcOtherImportCost(fob, otherimportper)

        Dim totalimport As Decimal = CalcImportTotalImport(agent, fob, duty, addduty, ocean, agentcomm, otherimport, packcost, supptariff)

        Dim totalcost As Decimal = CalcImportTotalCost(fob, totalimport)
        Dim outfreight As Decimal = CalcImportOutboundFreight(totalcost)
        Dim ninewhse As Decimal = CalcImportOutboundFreight(totalcost, outfreight)
        Dim totalstore As Decimal = CalcImportTotalStore(totalcost, outfreight, ninewhse)

        ' Save the calculated amounts
        If duty <> Decimal.MinValue Then record.DutyAmount = DataHelper.SmartValues(duty, "decimal", False)
        If supptariff <> Decimal.MinValue Then record.SuppTariffAmount = DataHelper.SmartValues(supptariff, "decimal", False)
        If ocean <> Decimal.MinValue Then record.OceanFreightComputedAmount = DataHelper.SmartValues(ocean, "decimal", False)
        If agentcomm <> Decimal.MinValue Then record.AgentCommissionAmount = DataHelper.SmartValues(agentcomm, "decimal", False)
        If otherimport <> Decimal.MinValue Then record.OtherImportCostsAmount = DataHelper.SmartValues(otherimport, "decimal", False)
        If totalimport <> Decimal.MinValue Then record.ImportBurden = DataHelper.SmartValues(totalimport, "decimal", False)
        If totalcost <> Decimal.MinValue Then record.WarehouseLandedCost = DataHelper.SmartValues(totalcost, "decimal", False)
        If outfreight <> Decimal.MinValue Then record.OutboundFreight = DataHelper.SmartValues(outfreight, "decimal", False)
        If ninewhse <> Decimal.MinValue Then record.NinePercentWhseCharge = DataHelper.SmartValues(ninewhse, "decimal", False)
        If totalstore <> Decimal.MinValue Then record.TotalStoreLandedCost = DataHelper.SmartValues(totalstore, "decimal", False)

    End Sub

    Public Shared Function CalculateItemCasePackCube(ByVal widthValue As String, ByVal heightValue As String, ByVal lengthValue As String, ByVal weightValue As String) As String

        If widthValue.Trim() = String.Empty Or heightValue.Trim = String.Empty Or lengthValue = String.Empty Then
            Return String.Empty
        End If
        Dim width As Decimal = DataHelper.SmartValues(widthValue, "decimal", False, 0, 4)
        Dim height As Decimal = DataHelper.SmartValues(heightValue, "decimal", False, 0, 4)
        Dim length As Decimal = DataHelper.SmartValues(lengthValue, "decimal", False, 0, 4)
        If width <= 0 Or height <= 0 Or length <= 0 Then
            Return DataHelper.SmartValues(0, "formatnumber4", False)
        End If
        Dim result As Decimal = (width * height * length / 1728)
        Return DataHelper.SmartValues(result, "formatnumber4", False)

    End Function

    Public Shared Function CalculateTotalCost(ByVal itemType As String, ByVal addUnitCost As Decimal, ByVal packItemIndicator As String, ByVal cost As Decimal) As Decimal
        ' FJL Nov 5 2010. Always calc total cost as that is what is sent to RMS
        Dim tcost As Decimal = Decimal.MinValue
        If cost > 0 Then        ' AndAlso packItemIndicator <> String.Empty 
            If packItemIndicator.Length > 0 AndAlso packItemIndicator <> "C" AndAlso itemType = "C" AndAlso addUnitCost >= 0 Then
                tcost = cost + addUnitCost
            Else
                tcost = cost
            End If
        End If
        Return tcost
    End Function

    Public Shared Function CalculateIMTotalCost(ByVal itemType As String, ByVal addUnitCost As Decimal, ByVal packItemIndicator As String, ByVal cost As Decimal) As Decimal
        Dim tcost As Decimal = Decimal.MinValue
        If cost > 0 Then
            If packItemIndicator <> "C" AndAlso packItemIndicator <> "" AndAlso addUnitCost >= 0 Then
                tcost = cost + addUnitCost
            Else
                tcost = cost
            End If
        End If
        Return tcost
    End Function

    ' ********************
    ' *** IMPORT CALCS ***
    ' ********************

    Public Shared Function CalculateOceanFrieght(ByVal eachesMasterCase As String, ByVal cubicFeetPerMasterCarton As String, ByVal oceanFrieght As String) As String
        Dim emc As Decimal = DataHelper.SmartValues(eachesMasterCase, "decimal", True)
        Dim cf As Decimal = DataHelper.SmartValues(cubicFeetPerMasterCarton, "decimal", True)
        Dim oceanf As Decimal = DataHelper.SmartValues(oceanFrieght, "decimal", True)
        If emc <> Decimal.MinValue AndAlso emc <> 0 AndAlso cf <> Decimal.MinValue AndAlso oceanf <> Decimal.MinValue Then
            'Dim result As Decimal = (cf / emc) * oceanf)
            Dim result As Decimal = oceanf * Math.Round(cf, 3) / emc

            Return DataHelper.SmartValues(result, "formatnumber4", False)
        Else
            Return String.Empty
        End If
    End Function

    Public Shared Function CalculateEstLandedCostAndStore(ByVal inputXML As String) As String
        Dim returnXML As String = String.Empty
        Dim xmlin As New XmlDocument, xmlout As New XmlDocument

        Try
            ' load xml
            ' --------
            xmlin.LoadXml(inputXML)
            xmlout.LoadXml(GetCalculateCostReturnXML())

            ' set values
            ' ----------
            ' input vars
            Dim agent As String = GetXMLValue(xmlin, "agent")
            Dim dispcost As Decimal = DataHelper.SmartValues(GetXMLValue(xmlin, "dispcost"), "decimal", True)
            Dim prodcost As Decimal = DataHelper.SmartValues(GetXMLValue(xmlin, "prodcost"), "decimal", True)
            Dim fob As Decimal = DataHelper.SmartValues(GetXMLValue(xmlin, "fob"), "decimal", True)
            Dim dutyper As Decimal = DataHelper.SmartValues(GetXMLValue(xmlin, "dutyper"), "decimal", True)
            Dim addduty As Decimal = DataHelper.SmartValues(GetXMLValue(xmlin, "addduty"), "decimal", True)
            Dim supptariffper As Decimal = DataHelper.SmartValues(GetXMLValue(xmlin, "supptariffper"), "decimal", True)
            Dim eachesmc As Decimal = DataHelper.SmartValues(GetXMLValue(xmlin, "eachesmc"), "decimal", True)
            Dim mclength As Decimal = DataHelper.SmartValues(GetXMLValue(xmlin, "mclength"), "decimal", True, Decimal.MinValue, 4)
            Dim mcwidth As Decimal = DataHelper.SmartValues(GetXMLValue(xmlin, "mcwidth"), "decimal", True, Decimal.MinValue, 4)
            Dim mcheight As Decimal = DataHelper.SmartValues(GetXMLValue(xmlin, "mcheight"), "decimal", True, Decimal.MinValue, 4)
            Dim oceanfre As Decimal = DataHelper.SmartValues(GetXMLValue(xmlin, "oceanfre"), "decimal", True)
            Dim oceanamt As Decimal = DataHelper.SmartValues(GetXMLValue(xmlin, "oceanamt"), "decimal", True)
            Dim agentcommper As Decimal = DataHelper.SmartValues(GetXMLValue(xmlin, "agentcommper"), "decimal", True)
            Dim otherimportper As Decimal = DataHelper.SmartValues(GetXMLValue(xmlin, "otherimportper"), "decimal", True)
            Dim packcost As Decimal = DataHelper.SmartValues(GetXMLValue(xmlin, "packcost"), "decimal", True)

            ' calculated vars
            fob = CalcImportFOB(dispcost, prodcost)

            Dim cubicftpermc As Decimal
            If GetXMLNodeAttribute(xmlin, "cubicftpermc", "calc").Trim() = "0" Then
                cubicftpermc = DataHelper.SmartValues(GetXMLValue(xmlin, "cubicftpermc"), "decimal", True, Decimal.MinValue, 4)
            Else
                cubicftpermc = CalcImportCubicFeetPerMasterCarton(mclength, mcwidth, mcheight)
            End If

            Dim duty As Decimal = CalcImportDuty(fob, dutyper)
            Dim supptariff As Decimal = CalcSuppTariff(fob, supptariffper)
            Dim ocean As Decimal = CalcImportOceanFrieght(eachesmc, cubicftpermc, oceanfre)
            ocean = Decimal.Round(ocean, 6)
            Dim agentcomm As Decimal = CalcImportAgentComm(agent, fob, agentcommper)
            Dim otherimport As Decimal = CalcOtherImportCost(fob, otherimportper)
            Dim totalimport As Decimal = CalcImportTotalImport(agent, fob, duty, addduty, ocean, agentcomm, otherimport, packcost, supptariff)
            Dim totalcost As Decimal = CalcImportTotalCost(fob, totalimport)
            Dim outfreight As Decimal = CalcImportOutboundFreight(totalcost)
            Dim ninewhse As Decimal = CalcImportOutboundFreight(totalcost, outfreight)
            Dim totalstore As Decimal = CalcImportTotalStore(totalcost, outfreight, ninewhse)

            ' store results
            ' ------------
            SetXMLValue(xmlout, "agent", agent)
            If dispcost <> Decimal.MinValue Then SetXMLValue(xmlout, "dispcost", DataHelper.SmartValues(dispcost, "formatnumber4", False))
            If prodcost <> Decimal.MinValue Then SetXMLValue(xmlout, "prodcost", DataHelper.SmartValues(prodcost, "formatnumber4", False))
            If fob <> Decimal.MinValue Then SetXMLValue(xmlout, "fob", DataHelper.SmartValues(fob, "formatnumber4", False))
            If dutyper <> Decimal.MinValue Then SetXMLValue(xmlout, "dutyper", DataHelper.SmartValues(dutyper, "formatnumber", False))
            If addduty <> Decimal.MinValue Then SetXMLValue(xmlout, "addduty", DataHelper.SmartValues(addduty, "formatnumber4", False))
            If supptariffper <> Decimal.MinValue Then SetXMLValue(xmlout, "supptariffper", DataHelper.SmartValues(supptariffper, "formatnumber", False))
            If eachesmc <> Decimal.MinValue Then SetXMLValue(xmlout, "eachesmc", DataHelper.SmartValues(eachesmc, "long", False))
            If mclength <> Decimal.MinValue Then SetXMLValue(xmlout, "mclength", DataHelper.SmartValues(mclength, "decimal", False, String.Empty, 4))
            If mcwidth <> Decimal.MinValue Then SetXMLValue(xmlout, "mcwidth", DataHelper.SmartValues(mcwidth, "decimal", False, String.Empty, 4))
            If mcheight <> Decimal.MinValue Then SetXMLValue(xmlout, "mcheight", DataHelper.SmartValues(mcheight, "decimal", False, String.Empty, 4))
            If cubicftpermc <> Decimal.MinValue Then SetXMLValue(xmlout, "cubicftpermc", DataHelper.SmartValues(cubicftpermc, "formatnumber4", False, String.Empty, 4))
            If oceanfre <> Decimal.MinValue Then SetXMLValue(xmlout, "oceanfre", DataHelper.SmartValues(oceanfre, "formatnumber4", False))
            If oceanamt <> Decimal.MinValue Then SetXMLValue(xmlout, "oceanamt", DataHelper.SmartValues(oceanamt, "formatnumber4", False))
            If agentcommper <> Decimal.MinValue Then SetXMLValue(xmlout, "agentcommper", DataHelper.SmartValues(agentcommper, "formatnumber", False))
            ' If otherimportper <> Decimal.MinValue Then SetXMLValue(xmlout, "otherimportper", DataHelper.SmartValues(otherimportper, "integer", False))
            If otherimportper <> Decimal.MinValue Then SetXMLValue(xmlout, "otherimportper", DataHelper.SmartValues(otherimportper, "formatnumber", False))
            If packcost <> Decimal.MinValue Then SetXMLValue(xmlout, "packcost", DataHelper.SmartValues(packcost, "formatnumber4", False))


            If duty <> Decimal.MinValue Then SetXMLValue(xmlout, "duty", DataHelper.SmartValues(duty, "formatnumber4", False))
            If supptariff <> Decimal.MinValue Then SetXMLValue(xmlout, "supptariff", DataHelper.SmartValues(supptariff, "formatnumber4", False))
            If ocean <> Decimal.MinValue Then SetXMLValue(xmlout, "ocean", DataHelper.SmartValues(ocean, "formatnumber4", False))
            If agentcomm <> Decimal.MinValue Then SetXMLValue(xmlout, "agentcomm", DataHelper.SmartValues(agentcomm, "formatnumber4", False))
            If otherimport <> Decimal.MinValue Then SetXMLValue(xmlout, "otherimport", DataHelper.SmartValues(otherimport, "formatnumber4", False))
            If totalimport <> Decimal.MinValue Then SetXMLValue(xmlout, "totalimport", DataHelper.SmartValues(totalimport, "formatnumber4", False))
            If totalcost <> Decimal.MinValue Then SetXMLValue(xmlout, "totalcost", DataHelper.SmartValues(totalcost, "formatnumber4", False))
            If outfreight <> Decimal.MinValue Then SetXMLValue(xmlout, "outfreight", DataHelper.SmartValues(outfreight, "formatnumber4", False))
            If ninewhse <> Decimal.MinValue Then SetXMLValue(xmlout, "ninewhse", DataHelper.SmartValues(ninewhse, "formatnumber4", False))
            If totalstore <> Decimal.MinValue Then SetXMLValue(xmlout, "totalstore", DataHelper.SmartValues(totalstore, "formatnumber4", False))

            ' set return value
            ' ----------------
            returnXML = xmlout.OuterXml
        Catch ex As Exception
            Return String.Empty
        Finally
            xmlin = Nothing
            xmlout = Nothing
        End Try

        Return returnXML
    End Function

    Public Shared Function CalcImportFOB(ByVal dispcost As Decimal, ByVal prodcost As Decimal) As Decimal
        Dim retValue As Decimal = Decimal.MinValue
        If prodcost <> Decimal.MinValue Then
            retValue = prodcost
            If dispcost <> Decimal.MinValue Then retValue += dispcost
        End If
        Return retValue
    End Function

    Public Shared Function CalcImportCubicFeetPerMasterCarton(ByVal mclength As Decimal, ByVal mcwidth As Decimal, ByVal mcheight As Decimal) As Decimal
        Dim retValue As Decimal
        If mcwidth <= 0 Or mcheight <= 0 Or mclength <= 0 Then
            retValue = 0.0000
        Else
            retValue = (mcwidth * mcheight * mclength / 1728)
            retValue = DataHelper.SmartValues(retValue, "formatnumber4", False)
        End If

        Return retValue
    End Function

    Public Shared Function CalcImportDuty(ByVal fob As Decimal, ByVal dutyper As Decimal) As Decimal
        Dim retValue As Decimal = Decimal.MinValue
        If fob <> Decimal.MinValue Then
            If dutyper <> Decimal.MinValue Then
                retValue = fob * (dutyper / 100)
            Else
                retValue = 0
            End If
        End If
        Return retValue
    End Function

    Public Shared Function CalcSuppTariff(ByVal fob As Decimal, ByVal supptariffper As Decimal) As Decimal
        Dim retValue As Decimal = Decimal.MinValue
        If fob <> Decimal.MinValue Then
            If supptariffper <> Decimal.MinValue Then
                retValue = fob * (supptariffper / 100)
            Else
                retValue = 0
            End If
        End If
        Return retValue
    End Function

    Public Shared Function CalcImportOceanFrieght(ByVal eachesmc As Decimal, ByVal cubicftpermc As Decimal, ByVal oceanfre As Decimal) As Decimal
        If eachesmc <> Decimal.MinValue AndAlso eachesmc <> 0 AndAlso cubicftpermc <> Decimal.MinValue AndAlso oceanfre <> Decimal.MinValue Then
            'Dim result As Decimal = ((cubicftpermc / eachesmc) * oceanfre)
            Dim result As Decimal = oceanfre * Math.Round(cubicftpermc, 3) / eachesmc
            Return result
        Else
            Return Decimal.MinValue
        End If
    End Function

    Public Shared Function CalcImportAgentComm(ByVal agent As String, ByVal fob As Decimal, ByVal agentcommper As Decimal) As Decimal
        Dim retValue As Decimal = Decimal.MinValue
        If agent <> String.Empty AndAlso agentcommper <> Decimal.MinValue Then
            If fob <> Decimal.MinValue Then
                retValue = fob * (agentcommper / 100)
            Else
                retValue = 0
            End If
        End If
        Return retValue
    End Function

    Public Shared Function CalcOtherImportCost(ByVal fob As Decimal, ByVal otherimportper As Decimal) As Decimal
        Dim retValue As Decimal = Decimal.MinValue
        If fob <> Decimal.MinValue Then
            If otherimportper <> Decimal.MinValue Then
                retValue = fob * (otherimportper / 100)
            Else
                retValue = 0
            End If
        End If
        Return retValue
    End Function

    Public Shared Function CalcImportTotalImport(ByVal agent As String, ByVal fob As Decimal, ByVal duty As Decimal, ByVal addduty As Decimal, ByVal ocean As Decimal, _
        ByVal agentcomm As Decimal, ByVal otherimport As Decimal, ByVal packcost As Decimal, ByVal supptariff As Decimal) As Decimal

        Dim retValue As Decimal = Decimal.MinValue
        If fob <> Decimal.MinValue Then
            If duty = Decimal.MinValue Then duty = 0
            If addduty = Decimal.MinValue Then addduty = 0
            If ocean = Decimal.MinValue Then ocean = 0
            If agentcomm = Decimal.MinValue Then agentcomm = 0
            If otherimport = Decimal.MinValue Then otherimport = 0
            If packcost = Decimal.MinValue Then packcost = 0
            If supptariff = Decimal.MinValue Then supptariff = 0
            If agent <> String.Empty Then
                retValue = (duty + addduty + ocean + agentcomm + otherimport + packcost + supptariff)
            Else
                retValue = (duty + addduty + ocean + otherimport + packcost + supptariff)
            End If

        End If
        Return retValue
    End Function

    Public Shared Function CalcImportTotalCost(ByVal fob As Decimal, ByVal totalimport As Decimal) As Decimal
        Dim retValue As Decimal = Decimal.MinValue
        If fob <> Decimal.MinValue Then
            If totalimport <> Decimal.MinValue Then
                retValue = (fob + totalimport)
            Else
                retValue = 0
            End If
        End If
        Return retValue
    End Function

    Public Shared Function CalcImportOutboundFreight(ByVal totalcost As Decimal) As Decimal
        Dim retValue As Decimal = Decimal.MinValue
        If totalcost <> Decimal.MinValue Then
            retValue = (totalcost * CALC_IMPORT_OUTBOUND_FREIGHT_PERCENT)
        End If
        Return retValue
    End Function

    Public Shared Function CalcImportOutboundFreight(ByVal totalcost As Decimal, ByVal outfreight As Decimal) As Decimal
        Dim retValue As Decimal = Decimal.MinValue
        If totalcost <> Decimal.MinValue Then
            retValue = ((totalcost + outfreight) * CALC_IMPORT_NINE_WAREHOUSE_PERCENT)
        End If
        Return retValue
    End Function

    Public Shared Function CalcImportTotalStore(ByVal totalcost As Decimal, ByVal outfreight As Decimal, ByVal ninewhse As Decimal) As Decimal
        Dim retValue As Decimal = Decimal.MinValue
        If totalcost <> Decimal.MinValue Then
            retValue = (totalcost + outfreight + ninewhse)
        End If
        Return retValue
    End Function


    ' ********************
    ' * HELPER FUNCTIONS *
    ' ********************

    Public Shared Function GetXMLValue(ByRef xmldoc As XmlDocument, ByVal node As String) As String
        Dim retValue As String = String.Empty
        If Not xmldoc.SelectSingleNode("//" & node) Is Nothing Then
            retValue = xmldoc.SelectSingleNode("//" & node).InnerText
            If retValue.Length >= 10 AndAlso retValue.Substring(0, 8) = "![CDATA[" AndAlso retValue.Substring(retValue.Length - 2, 2) = "]]" Then
                retValue = retValue.Substring(8) ' strip "![CDATA["
                retValue = retValue.Substring(0, retValue.Length - 2) ' strip "]]"
            End If
        End If
        Return retValue
    End Function

    Public Shared Sub SetXMLValue(ByRef xmldoc As XmlDocument, ByVal node As String, ByVal value As String)
        If Not xmldoc.SelectSingleNode("//" & node) Is Nothing Then
            xmldoc.SelectSingleNode("//" & node).InnerText = value
        End If
    End Sub

    Public Shared Function GetXMLNodeAttribute(ByRef xmldoc As XmlDocument, ByVal node As String, ByVal attribute As String) As String
        Dim retValue As String = String.Empty
        If Not xmldoc.SelectSingleNode("//" & node) Is Nothing Then
            retValue = xmldoc.SelectSingleNode("//" & node).Attributes(attribute).Value
        End If
        Return retValue
    End Function


    Public Shared Function GetCalculateCostReturnXML() As String
        Dim returnXML As String = "" & _
            "<?xml version=""1.0"" encoding=""utf-8"" ?>" & _
            "<calcresults>" & _
            "	<agent></agent>" & _
            "	<dispcost></dispcost>" & _
            "	<prodcost></prodcost>" & _
            "	<fob></fob>" & _
            "	<dutyper></dutyper>" & _
            "	<addduty></addduty>" & _
            "   <supptariffper></supptariffper>" & _
            "	<eachesmc></eachesmc>" & _
            "	<mclength></mclength>" & _
            "	<mcwidth></mcwidth>" & _
            "	<mcheight></mcheight>" & _
            "	<cubicftpermc></cubicftpermc>" & _
            "	<oceanfre></oceanfre>" & _
            "	<oceanamt></oceanamt>" & _
            "	<agentcommper></agentcommper>" & _
            "	<otherimportper></otherimportper>" & _
            "	<packcost></packcost>" & _
            "" & _
            "	<duty></duty>" & _
            "	<ocean></ocean>" & _
            "	<agentcomm></agentcomm>" & _
            "	<otherimport></otherimport>" & _
            "	<totalimport></totalimport>" & _
            "	<totalcost></totalcost>" & _
            "	<outfreight></outfreight>" & _
            "	<ninewhse></ninewhse>" & _
            "	<totalstore></totalstore>" & _
            "   <supptariff></supptariff>" & _
            "</calcresults>"
        Return returnXML
    End Function


    ' ********************
    ' *** SHARED CALCS ***
    ' ********************

    Public Shared Function CalculateConversionDate(ByVal leadTime As Integer) As String

        If leadTime = Integer.MinValue OrElse leadTime < 0 Then
            Return String.Empty
        End If
        Dim result As Date = DateAdd(DateInterval.Day, (leadTime + 14), Now())

        Return result.ToString("M/d/yyyy")

    End Function

End Class
