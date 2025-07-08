Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels

    Public Class ValidationData

        ' *******************
        ' * VALIDATION DATA *
        ' *******************

        Public Shared Function SetIsValid(ByVal recordID As Long, ByVal recordType As Integer, ByVal isValid As Boolean) As Boolean
            Dim sql As String = "sp_SPD_Set_IsValid_NoUpdate"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim ret As Boolean = False
            Dim i As Integer
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection(False)
                conn.Open()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@ID", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(recordID, "long", False)
                cmd.Parameters.Add("@recordType", SqlDbType.Int).Value = DataHelper.DBSmartValues(recordType, "integer", False)
                cmd.Parameters.Add("@isValid", SqlDbType.SmallInt).Value = DataHelper.DBSmartValues(isValid, "smallint", False)

                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                cmd.ExecuteNonQuery()

                ret = True
            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
                Throw ex
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
            Return ret
        End Function

        Public Function SetIsValid(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.SetValidationRecord, ByVal userID As Long) As Boolean
            Dim sql As String = "sp_SPD_Set_IsValid"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim ret As Boolean = False
            Dim i As Integer
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection(False)
                conn.Open()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@ID", SqlDbType.BigInt)
                cmd.Parameters.Add("@recordType", SqlDbType.Int).Value = DataHelper.DBSmartValues(objRecord.RecordType, "integer", False)
                cmd.Parameters.Add("@isValid", SqlDbType.SmallInt).Value = DataHelper.DBSmartValues(objRecord.IsValid, "smallint", False)
                cmd.Parameters.Add("@userID", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(userID, "long", False)
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                For i = 0 To objRecord.IDCount - 1
                    cmd.Parameters("@ID").Value = DataHelper.DBSmartValues(objRecord.Item(i), "long", False)
                    cmd.ExecuteNonQuery()
                Next
                ret = True
            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
                Throw ex
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
            Return ret
        End Function

        Public Function SetIsValidPerItem(ByVal objRecord As NovaLibra.Coral.SystemFrameworks.Michaels.SetValidationPerItemRecord, ByVal userID As Long) As Boolean
            Dim sql As String = "sp_SPD_Set_IsValid"
            Dim cmd As DBCommand = Nothing
            Dim conn As DBConnection = Nothing
            Dim ret As Boolean = False
            Dim i As Integer
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                cmd = New DBCommand(conn)
                cmd.Parameters.Add("@ID", SqlDbType.BigInt)
                cmd.Parameters.Add("@recordType", SqlDbType.Int)
                cmd.Parameters.Add("@isValid", SqlDbType.SmallInt)
                cmd.Parameters.Add("@userID", SqlDbType.BigInt).Value = DataHelper.DBSmartValues(userID, "long", False)
                cmd.CommandText = sql
                cmd.CommandType = CommandType.StoredProcedure
                For i = 0 To objRecord.Count - 1
                    cmd.Parameters("@ID").Value = DataHelper.DBSmartValues(objRecord.Item(i).ID, "long", False)
                    cmd.Parameters("@recordType").Value = DataHelper.DBSmartValues(objRecord.Item(i).RecordType, "smallint", False)
                    cmd.Parameters("@isValid").Value = DataHelper.DBSmartValues(objRecord.Item(i).IsValid, "integer", False)
                    cmd.ExecuteNonQuery()
                Next
                ret = True
            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
                Throw ex
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
            Return ret
        End Function

        ' ********************
        ' * BATCH VALIDATION *
        ' ********************

        Public Shared Function BatchValidationLookup(ByRef batchLookup As BatchValidationLookupRecord) As Boolean
            Dim ret As Boolean = True
            Dim sql As String = "usp_SPD_Validation_ValidateBatch"
            Dim conn As DBConnection = Nothing
            Dim reader As DBReader = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection(False)
                conn.Open()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@batchID", SqlDbType.BigInt)
                objParam.Value = batchLookup.BatchID
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        batchLookup.BatchErrors = DataHelper.SmartValues(.Item("BatchErrors"), "long", False)
                    End With
                Else
                    ret = False
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
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
            Return ret
        End Function

        Public Shared Function ItemMaintBatchValidationLookup(ByRef batchLookup As BatchValidationLookupRecord) As Boolean
            Dim ret As Boolean = True
            Dim sql As String = "usp_SPD_Validation_ValidateItemMaintBatch"
            Dim conn As DBConnection = Nothing
            Dim reader As DBReader = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@batchID", SqlDbType.BigInt)
                objParam.Value = batchLookup.BatchID
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        batchLookup.BatchErrors = DataHelper.SmartValues(.Item("BatchErrors"), "long", False)
                    End With
                Else
                    ret = False
                End If
                If reader.NextResult() Then
                    Do While reader.Read()
                        batchLookup.AddFutureCostSKU(DataHelper.SmartValues(reader.Item("ID"), "integer", False), _
                                                     DataHelper.SmartValues(reader.Item("SKU"), "string", True), _
                                                     DataHelper.SmartValues(reader.Item("FutureCostExists"), "boolean", True), _
                                                     DataHelper.SmartValues(reader.Item("FutureCostCancelled"), "boolean", True))
                    Loop
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
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
            Return ret
        End Function

        Public Shared Function BulkItemMaintBatchValidationLookup(ByRef batchLookup As BatchValidationLookupRecord) As Boolean
            Dim ret As Boolean = True
            Dim sql As String = "usp_SPD_Validation_ValidateBulkItemMaintBatch"
            Dim conn As DBConnection = Nothing
            Dim reader As DBReader = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@batchID", SqlDbType.BigInt)
                objParam.Value = batchLookup.BatchID
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        batchLookup.BatchErrors = DataHelper.SmartValues(.Item("BatchErrors"), "long", False)
                    End With
                Else
                    ret = False
                End If
                If reader.NextResult() Then
                    Do While reader.Read()
                        batchLookup.AddFutureCostSKU(DataHelper.SmartValues(reader.Item("ID"), "integer", False), _
                                                     DataHelper.SmartValues(reader.Item("SKU"), "string", True), _
                                                     DataHelper.SmartValues(reader.Item("FutureCostExists"), "boolean", True), _
                                                     DataHelper.SmartValues(reader.Item("FutureCostCancelled"), "boolean", True))
                    Loop
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
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
            Return ret
        End Function

        ' **************************
        ' * ITEM HEADER VALIDATION *
        ' **************************

        Public Function ItemHeaderValidationLookup(ByRef itemHeaderLookup As ItemHeaderValidationLookupRecord) As Boolean
            Dim ret As Boolean = True
            Dim sql As String = "select [Dept] as Dept from vwSPD_Fineline_Dept where [Dept] = @dept;" & _
                "select [ID] as vendor1 from [SPD_Vendor] where Vendor_Number = @vnum1 and rtrim(ltrim(Vendor_Type)) = @vtype1;" & _
                "select [ID] as vendor2 from [SPD_Vendor] where Vendor_Number = @vnum2 and rtrim(ltrim(Vendor_Type)) = @vtype2;"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            'Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@dept", SqlDbType.Float).Value = itemHeaderLookup.Dept
                reader.Command.Parameters.Add("@vnum1", SqlDbType.BigInt).Value = itemHeaderLookup.USVendorNum
                reader.Command.Parameters.Add("@vtype1", SqlDbType.VarChar, 100).Value = itemHeaderLookup.USVendorType
                reader.Command.Parameters.Add("@vnum2", SqlDbType.BigInt).Value = itemHeaderLookup.CanadianVendorNum
                reader.Command.Parameters.Add("@vtype2", SqlDbType.VarChar, 100).Value = itemHeaderLookup.CanadianVendorType
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                If reader.Read() Then
                    If DataHelper.SmartValues(reader.Item("Dept"), "integer", False) > 0 Then itemHeaderLookup.DeptValid = True Else itemHeaderLookup.DeptValid = False
                End If
                If reader.NextResult() And reader.Read() Then
                    If DataHelper.SmartValues(reader.Item("vendor1"), "long", False) > 0 Then itemHeaderLookup.USVendorNumValid = True Else itemHeaderLookup.USVendorNumValid = False
                End If
                If reader.NextResult() And reader.Read() Then
                    If DataHelper.SmartValues(reader.Item("vendor2"), "long", False) > 0 Then itemHeaderLookup.CanadianVendorNumValid = True Else itemHeaderLookup.CanadianVendorNumValid = False
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
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
            Return ret
        End Function

        ' *******************
        ' * ITEM VALIDATION *
        ' *******************

        Public Function ItemValidationLookup(ByRef itemLookup As ItemValidationLookupRecord) As Boolean
            Dim ret As Boolean = True
            Dim sql As String = "select [CLASS] as ClassNum from vwSPD_Fineline_Class where [DEPT] = @dept and [CLASS] = @classnum; " & _
                "select [SUBCLASS]as SubClassNum from vwSPD_Fineline_Subclass where [DEPT] = @dept and [CLASS] = @classnum and [SUBCLASS] = @subclassnum; " & _
                "select [COUNTRY_CODE] as CountryCode, [COUNTRY_NAME] as CountryName from [SPD_COUNTRY] where [COUNTRY_CODE] = @countryCode and UPPER([COUNTRY_NAME]) = UPPER(@country); " & _
                "select [Tax_UDA_ID] as TaxUDA, [Tax_UDA_Value_Number] as TaxValueUDA from [SPD_Tax_UDA_Value] where [Tax_UDA_ID] = @taxUDA and [Tax_UDA_Value_Number] = @taxValueUDA AND Enabled=1; " & _
                "Select top 1 case when ss.Strategy_Status = 'D' then 0 else 1 end as StockingStrategyStatusValid from Stocking_Strategy SS where ss.Strategy_Code = @StockingStrategyCode; " & _
                "Select top 1  " & _
                "case when @ItemTypeAttribute = 'S' and ss.Strategy_Type = 'S' then 1 when @ItemTypeAttribute <> 'S' and ss.Strategy_Type = 'B' then 1  " & _
                "else 0 end as StockingStrategyTypeValid " & _
                "from Stocking_Strategy SS  " & _
                "where ss.Strategy_Code = @StockingStrategyCode; " & _
                "Select case when @Inner_Case_Weight >= (@Each_Case_Weight * @Eaches_Inner_Pack) then 1 else 0 end as InnerWeightEachesCompareValid; " & _
                "Select case when @Master_Case_Weight >= (@Each_Case_Weight * @Eaches_Master_Case) then 1 else 0 end as MasterWeightEachesCompareValid; " & _
                "Select case when @Eaches_Inner_Pack = 0 then 0 else case when @Master_Case_Weight >= (@Inner_Case_Weight * @Eaches_Master_Case / @Eaches_Inner_Pack) then 1 else 0 end end as MasterWeightInnerEachesRatioValid; "

            sql += "exec usp_SPD_Validation_ValidateItem @itemID = " & itemLookup.ID & "; "
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            'Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@dept", SqlDbType.Float).Value = itemLookup.Dept
                reader.Command.Parameters.Add("@classnum", SqlDbType.Float).Value = itemLookup.ClassNum
                reader.Command.Parameters.Add("@subclassnum", SqlDbType.Float).Value = itemLookup.SubClassNum
                reader.Command.Parameters.Add("@countryCode", SqlDbType.VarChar, 2).Value = itemLookup.CountryOfOrigin
                reader.Command.Parameters.Add("@country", SqlDbType.VarChar, 50).Value = itemLookup.CountryOfOriginName
                reader.Command.Parameters.Add("@taxUDA", SqlDbType.Int).Value = DataHelper.SmartValues(itemLookup.TaxUDA, "integer", False)
                reader.Command.Parameters.Add("@taxValueUDA", SqlDbType.Int).Value = itemLookup.TaxValueUDA
                reader.Command.Parameters.Add("@ItemTypeAttribute", SqlDbType.VarChar, 100).Value = itemLookup.ItemTypeAttribute
                reader.Command.Parameters.Add("@StockingStrategyCode", SqlDbType.VarChar, 100).Value = itemLookup.StockingStrategyCode

                reader.Command.Parameters.Add("@Each_Case_Weight", SqlDbType.Decimal).Value = IIf(itemLookup.EachCaseWeight = System.Decimal.MinValue, vbNull, itemLookup.EachCaseWeight)
                reader.Command.Parameters.Add("@Inner_Case_Weight", SqlDbType.Decimal).Value = IIf(itemLookup.InnerCaseWeight = System.Decimal.MinValue, vbNull, itemLookup.InnerCaseWeight)
                reader.Command.Parameters.Add("@Master_Case_Weight", SqlDbType.Decimal).Value = IIf(itemLookup.MasterCaseWeight = System.Decimal.MinValue, vbNull, itemLookup.MasterCaseWeight)
                reader.Command.Parameters.Add("@Eaches_Inner_Pack", SqlDbType.Int).Value = IIf(itemLookup.EachesInnerPack = System.Int32.MinValue, vbNull, itemLookup.EachesInnerPack)
                reader.Command.Parameters.Add("@Eaches_Master_Case", SqlDbType.Int).Value = IIf(itemLookup.EachesMasterPack = System.Int32.MinValue, vbNull, itemLookup.EachesMasterPack)


                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                If reader.Read() Then
                    With reader
                        If DataHelper.SmartValues(.Item("ClassNum"), "long", False) > 0 Then itemLookup.ClassNumValid = True Else itemLookup.ClassNumValid = False
                    End With
                End If
                If reader.Reader.NextResult() AndAlso reader.Read() Then

                    With reader
                        If DataHelper.SmartValues(.Item("SubClassNum"), "long", False) > 0 Then itemLookup.SubClassNumValid = True Else itemLookup.SubClassNumValid = False
                    End With
                End If
                If reader.Reader.NextResult() AndAlso reader.Read() Then
                    With reader
                        If DataHelper.SmartValues(.Item("CountryName"), "string", False) <> String.Empty Then itemLookup.CountryOfOriginValid = True Else itemLookup.CountryOfOriginValid = False
                    End With
                End If
                If reader.Reader.NextResult() AndAlso reader.Read() Then
                    With reader
                        If DataHelper.SmartValues(.Item("taxValueUDA"), "integer", False) > 0 Then itemLookup.TaxValueUDAValid = True Else itemLookup.TaxValueUDAValid = False
                    End With
                Else
                    itemLookup.TaxValueUDAValid = False
                End If

                If reader.NextResult() AndAlso reader.Read() Then
                    itemLookup.StockingStrategyStatusValid = DataHelper.SmartValues(reader.Item("StockingStrategyStatusValid"), "boolean", False)
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    itemLookup.StockingStrategyTypeValid = DataHelper.SmartValues(reader.Item("StockingStrategyTypeValid"), "boolean", False)
                End If

                'pack weight
                If reader.NextResult() AndAlso reader.Read() Then
                    itemLookup.InnerWeightEachesCompareValid = DataHelper.SmartValues(reader.Item("InnerWeightEachesCompareValid"), "Decimal", False)
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    itemLookup.MasterWeightEachesCompareValid = DataHelper.SmartValues(reader.Item("MasterWeightEachesCompareValid"), "Decimal", False)
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    itemLookup.MasterWeightInnerEachesRatioValid = DataHelper.SmartValues(reader.Item("MasterWeightInnerEachesRatioValid"), "Decimal", False)
                End If

                ' item errors
                If reader.NextResult() AndAlso reader.Read() Then
                    itemLookup.ItemErrors = DataHelper.SmartValues(reader.Item("ItemErrors"), "integer", False)
                End If
                ' item UPC errors
                If reader.NextResult() Then
                    Do While reader.Read
                        itemLookup.AddUPCValidationError(reader.Item("Sequence"),
                                                         DataHelper.SmartValues(reader.Item("UPC"), "string", False),
                                                         DataHelper.SmartValues(reader.Item("UPCExists"), "boolean", False),
                                                         DataHelper.SmartValues(reader.Item("DupBatch"), "boolean", False),
                                                         DataHelper.SmartValues(reader.Item("DupWorkflow"), "boolean", False))
                    Loop
                End If

                'PMO200141 GTIN14 Enhancements changes
                'If reader.NextResult() Then
                '    Do While reader.Read
                '        itemLookup.AddInnerGTINValidationError(reader.Item("Sequence"),
                '                                         DataHelper.SmartValues(reader.Item("InnerGTIN"), "string", False),
                '                                         DataHelper.SmartValues(reader.Item("InnerGTINExists"), "boolean", False),
                '                                         DataHelper.SmartValues(reader.Item("InnerGTINDupBatch"), "boolean", False),
                '                                         DataHelper.SmartValues(reader.Item("InnerGTINDupWorkflow"), "boolean", False))
                '    Loop
                'End If

                'If reader.NextResult() Then
                '    Do While reader.Read
                '        itemLookup.AddCaseGTINValidationError(reader.Item("Sequence"),
                '                                         DataHelper.SmartValues(reader.Item("CaseGTIN"), "string", False),
                '                                         DataHelper.SmartValues(reader.Item("CaseGTINExists"), "boolean", False),
                '                                         DataHelper.SmartValues(reader.Item("CaseGTINDupBatch"), "boolean", False),
                '                                         DataHelper.SmartValues(reader.Item("CaseGTINDupWorkflow"), "boolean", False))
                '    Loop
                'End If

            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
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
            Return ret
        End Function

        Public Function ImportItemValidationLookup(ByRef itemLookup As ImportItemValidationLookupRecord) As Boolean
            Dim ret As Boolean = True
            Dim sql As String = "select [Dept] from vwSPD_Fineline_Dept where [Dept] = @dept;" & _
                "select [CLASS] as ClassNum from vwSPD_Fineline_Class where [DEPT] = @dept and [CLASS] = @classnum;" & _
                "select [SUBCLASS] as SubClassNum from vwSPD_Fineline_Subclass where [DEPT] = @dept and [CLASS] = @classnum and [SUBCLASS] = @subclassnum;" & _
                "select [COUNTRY_CODE] as CountryCode, [COUNTRY_NAME] as CountryName from [SPD_COUNTRY] where [COUNTRY_CODE] = @countryCode and UPPER([COUNTRY_NAME]) = UPPER(@country); " & _
                "select [Tax_UDA_ID] as TaxUDA, [Tax_UDA_Value_Number] as TaxValueUDA from [SPD_Tax_UDA_Value] where [Tax_UDA_ID] = @taxUDA and [Tax_UDA_Value_Number] = @taxValueUDA AND Enabled=1; " & _
                "Select top 1 case when ss.Strategy_Status = 'D' then 0 else 1 end as StockingStrategyStatusValid from Stocking_Strategy SS where ss.Strategy_Code = @StockingStrategyCode; " & _
                "Select top 1 " & _
                "case when @ItemTypeAttribute = 'S' and ss.Strategy_Type = 'S' then 1 when @ItemTypeAttribute <> 'S' and ss.Strategy_Type = 'B' then 1 " & _
                "else 0 end as StockingStrategyTypeValid " & _
                "from Stocking_Strategy SS " & _
                "where ss.Strategy_Code = @StockingStrategyCode; " & _
                "Select case when @Inner_Case_Weight >= (@Each_Case_Weight * @Eaches_Inner_Pack) then 1 else 0 end as InnerWeightEachesCompareValid; " & _
                "Select case when @Master_Case_Weight >= (@Each_Case_Weight * @Eaches_Master_Case) then 1 else 0 end as MasterWeightEachesCompareValid; " & _
                "Select case when @Eaches_Inner_Pack = 0 then 0 else case when @Master_Case_Weight >= (@Inner_Case_Weight * @Eaches_Master_Case / @Eaches_Inner_Pack) then 1 else 0 end end as MasterWeightInnerEachesRatioValid; "

            If itemLookup.ID <= 0 Then
                ' new record
                sql += "select 0 as DeptNotSameCount; "
                sql += "select 0 as VendorNumberNotSameCount; "
            Else 'lp fix is here in DeptNotSameCount
                'sql += "select count(*) as DeptNotSameCount from [SPD_Import_Items] where [Dept] != @deptString and ( [ID] = @ID or [Parent_ID] =  @parentID or  [ID] = @parentID); " ' @ID
                sql += "select count(*) as DeptNotSameCount from [SPD_Import_Items] where [Dept] != @deptString and ( [ID] != @ID and ( [Parent_ID] = @ID or [ID] = @parentID ) );"
                sql += "select count(*) as VendorNumberNotSameCount from [SPD_Import_Items] where isnull([VendorNumber], '') != @vendorNumberString and ( [ID] != @ID and ( [Parent_ID] = @ID or [ID] = @parentID ) ); "
            End If
            sql += "exec usp_SPD_Validation_ValidateImportItem @itemID = " & itemLookup.ID & "; "
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            'Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection(False)
                conn.Open()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@dept", SqlDbType.Float).Value = itemLookup.Dept
                reader.Command.Parameters.Add("@classnum", SqlDbType.Float).Value = itemLookup.ClassNum
                reader.Command.Parameters.Add("@subclassnum", SqlDbType.Float).Value = itemLookup.SubClassNum
                reader.Command.Parameters.Add("@countryCode", SqlDbType.VarChar, 2).Value = itemLookup.CountryOfOrigin
                reader.Command.Parameters.Add("@country", SqlDbType.VarChar, 50).Value = itemLookup.CountryOfOriginName
                reader.Command.Parameters.Add("@taxUDA", SqlDbType.Int).Value = DataHelper.SmartValues(itemLookup.TaxUDA, "integer", False)
                reader.Command.Parameters.Add("@taxValueUDA", SqlDbType.Int).Value = itemLookup.TaxValueUDA
                reader.Command.Parameters.Add("@ID", SqlDbType.BigInt).Value = itemLookup.ID
                reader.Command.Parameters.Add("@parentID", SqlDbType.BigInt).Value = itemLookup.ParentID
                reader.Command.Parameters.Add("@deptString", SqlDbType.VarChar, 100).Value = itemLookup.DeptString
                reader.Command.Parameters.Add("@vendorNumberString", SqlDbType.VarChar, 100).Value = itemLookup.VendorNumberString
                reader.Command.Parameters.Add("@ItemTypeAttribute", SqlDbType.VarChar, 100).Value = itemLookup.ItemTypeAttribute
                reader.Command.Parameters.Add("@StockingStrategyCode", SqlDbType.VarChar, 100).Value = itemLookup.StockingStrategyCode

                reader.Command.Parameters.Add("@Each_Case_Weight", SqlDbType.Decimal).Value = IIf(itemLookup.EachCaseWeight = System.Decimal.MinValue, vbNull, itemLookup.EachCaseWeight)
                reader.Command.Parameters.Add("@Inner_Case_Weight", SqlDbType.Decimal).Value = IIf(itemLookup.InnerCaseWeight = System.Decimal.MinValue, vbNull, itemLookup.InnerCaseWeight)
                reader.Command.Parameters.Add("@Master_Case_Weight", SqlDbType.Decimal).Value = IIf(itemLookup.MasterCaseWeight = System.Decimal.MinValue, vbNull, itemLookup.MasterCaseWeight)
                reader.Command.Parameters.Add("@Eaches_Inner_Pack", SqlDbType.Int).Value = IIf(itemLookup.EachesInnerPack = System.Int32.MinValue, vbNull, itemLookup.EachesInnerPack)
                reader.Command.Parameters.Add("@Eaches_Master_Case", SqlDbType.Int).Value = IIf(itemLookup.EachesMasterPack = System.Int32.MinValue, vbNull, itemLookup.EachesMasterPack)

                reader.Command.CommandTimeout = 1800
                reader.CommandText = sql
                reader.CommandType = CommandType.Text

                reader.Open()
                If reader.Read() Then
                    If DataHelper.SmartValues(reader.Item("Dept"), "integer", False) > 0 Then itemLookup.DeptValid = True Else itemLookup.DeptValid = False
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    If DataHelper.SmartValues(reader.Item("ClassNum"), "long", False) > 0 Then itemLookup.ClassNumValid = True Else itemLookup.ClassNumValid = False
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    If DataHelper.SmartValues(reader.Item("SubClassNum"), "long", False) > 0 Then itemLookup.SubClassNumValid = True Else itemLookup.SubClassNumValid = False
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    If DataHelper.SmartValues(reader.Item("CountryName"), "string", False) <> String.Empty Then itemLookup.CountryOfOriginValid = True Else itemLookup.CountryOfOriginValid = False
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    If DataHelper.SmartValues(reader.Item("taxValueUDA"), "integer", False) > 0 Then itemLookup.TaxValueUDAValid = True Else itemLookup.TaxValueUDAValid = False
                Else
                    itemLookup.TaxValueUDA = False
                End If

                If reader.NextResult() AndAlso reader.Read() Then
                    itemLookup.StockingStrategyStatusValid = DataHelper.SmartValues(reader.Item("StockingStrategyStatusValid"), "boolean", False)
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    itemLookup.StockingStrategyTypeValid = DataHelper.SmartValues(reader.Item("StockingStrategyTypeValid"), "boolean", False)
                End If

                'pack weight
                If reader.NextResult() AndAlso reader.Read() Then
                    itemLookup.InnerWeightEachesCompareValid = DataHelper.SmartValues(reader.Item("InnerWeightEachesCompareValid"), "Decimal", False)
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    itemLookup.MasterWeightEachesCompareValid = DataHelper.SmartValues(reader.Item("MasterWeightEachesCompareValid"), "Decimal", False)
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    itemLookup.MasterWeightInnerEachesRatioValid = DataHelper.SmartValues(reader.Item("MasterWeightInnerEachesRatioValid"), "Decimal", False)
                End If

                If reader.NextResult() AndAlso reader.Read() Then
                    If DataHelper.SmartValues(reader.Item("DeptNotSameCount"), "integer", False) <= 0 Then itemLookup.SameDeptValid = True Else itemLookup.SameDeptValid = False
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    If DataHelper.SmartValues(reader.Item("VendorNumberNotSameCount"), "integer", False) <= 0 Then
                        itemLookup.SameVendorValid = True
                    Else
                        'suppress this error for SB batches
                        If itemLookup.PackItemIndicator = "C" And itemLookup.BatchPackItemIndicator = "SB" Then
                            itemLookup.SameVendorValid = True
                        Else
                            itemLookup.SameVendorValid = False
                        End If
                    End If
                End If
                ' item errors
                If reader.NextResult() AndAlso reader.Read() Then
                    itemLookup.ItemErrors = DataHelper.SmartValues(reader.Item("ItemErrors"), "integer", False)
                End If
                ' item UPC errors
                If reader.NextResult() Then
                    Do While reader.Read
                        itemLookup.AddUPCValidationError(reader.Item("Sequence"),
                                                         DataHelper.SmartValues(reader.Item("UPC"), "string", False),
                                                         DataHelper.SmartValues(reader.Item("UPCExists"), "boolean", False),
                                                         DataHelper.SmartValues(reader.Item("DupBatch"), "boolean", False),
                                                         DataHelper.SmartValues(reader.Item("DupWorkflow"), "boolean", False))
                    Loop
                End If

                'PMO200141 GTIN14 Enhancements changes
                'If reader.NextResult() Then
                '    Do While reader.Read
                '        itemLookup.AddInnerGTINValidationError(reader.Item("Sequence"),
                '                                         DataHelper.SmartValues(reader.Item("InnerGTIN"), "string", False),
                '                                         DataHelper.SmartValues(reader.Item("InnerGTINExists"), "boolean", False),
                '                                         DataHelper.SmartValues(reader.Item("InnerGTINDupBatch"), "boolean", False),
                '                                         DataHelper.SmartValues(reader.Item("InnerGTINDupWorkflow"), "boolean", False))
                '    Loop
                'End If

                'If reader.NextResult() Then
                '    Do While reader.Read
                '        itemLookup.AddCaseGTINValidationError(reader.Item("Sequence"),
                '                                         DataHelper.SmartValues(reader.Item("CaseGTIN"), "string", False),
                '                                         DataHelper.SmartValues(reader.Item("CaseGTINExists"), "boolean", False),
                '                                         DataHelper.SmartValues(reader.Item("CaseGTINDupBatch"), "boolean", False),
                '                                         DataHelper.SmartValues(reader.Item("CaseGTINDupWorkflow"), "boolean", False))
                '    Loop
                'End If

            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
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
            Return ret
        End Function

        ' ******************************
        ' * ITEM MAINT ITEM VALIDATION *
        ' ******************************

        Public Shared Function ItemMaintItemValidationLookup(ByRef itemLookup As ItemMaintItemValidationLookupRecord) As Boolean
            Dim ret As Boolean = True
            Dim i As Integer
            Dim sql As String = "select [Dept] from vwSPD_Fineline_Dept where [Dept] = @dept;" & _
                "select [CLASS] as ClassNum from vwSPD_Fineline_Class where [DEPT] = @dept and [CLASS] = @classnum;" & _
                "select [SUBCLASS] as SubClassNum from vwSPD_Fineline_Subclass where [DEPT] = @dept and [CLASS] = @classnum and [SUBCLASS] = @subclassnum;" & _
                "select [COUNTRY_CODE] as CountryCode, [COUNTRY_NAME] as CountryName from [SPD_COUNTRY] where [COUNTRY_CODE] = @countryCode and UPPER([COUNTRY_NAME]) = UPPER(@country); " & _
                "select [Tax_UDA_ID] as TaxUDA, [Tax_UDA_Value_Number] as TaxValueUDA from [SPD_Tax_UDA_Value] where [Tax_UDA_ID] = @taxUDA and [Tax_UDA_Value_Number] = @taxValueUDA AND Enabled=1;" & _
                "Select top 1 case when ss.Strategy_Status = 'D' then 0 else 1 end as StockingStrategyStatusValid from Stocking_Strategy SS where ss.Strategy_Code = @StockingStrategyCode; " & _
                "Select top 1 " & _
                "case when @ItemTypeAttribute = 'S' and ss.Strategy_Type = 'S' then 1 when @ItemTypeAttribute <> 'S' and ss.Strategy_Type = 'B' then 1 " & _
                "else 0 end as StockingStrategyTypeValid " & _
                "from Stocking_Strategy SS " & _
                "where ss.Strategy_Code = @StockingStrategyCode; " & _
                "Select case when @Inner_Case_Weight >= (@Each_Case_Weight * @Eaches_Inner_Pack) then 1 else 0 end as InnerWeightEachesCompareValid; " & _
                "Select case when @Master_Case_Weight >= (@Each_Case_Weight * @Eaches_Master_Case) then 1 else 0 end as MasterWeightEachesCompareValid; " & _
                "Select case when @Eaches_Inner_Pack = 0 then 0 else case when @Master_Case_Weight >= (@Inner_Case_Weight * @Eaches_Master_Case / @Eaches_Inner_Pack) then 1 else 0 end end as MasterWeightInnerEachesRatioValid; "

            If itemLookup.ID <= 0 Then
                ' new record
                sql += "select 0 as DeptNotSameCount; "
                sql += "select 0 as VendorNumberNotSameCount; "
            Else
                sql += "select count(*) as DeptNotSameCount from [vwItemMaintItemDetail] where [DepartmentNum] != @deptString and ( [ID] != @ID and BatchID in (select BatchID from vwItemMaintItemDetail where [ID] = @ID));"
                sql += "select count(*) as VendorNumberNotSameCount from [vwItemMaintItemDetail] where isnull([VendorNumber], '') != @vendorNumberString and BatchID in (select BatchID from vwItemMaintItemDetail where [ID] = @ID); "
            End If
            sql += "exec usp_SPD_Validation_ValidateItemMaintItem @itemID = " & itemLookup.ID & "; "
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@dept", SqlDbType.Float).Value = itemLookup.Dept
                reader.Command.Parameters.Add("@classnum", SqlDbType.Float).Value = itemLookup.ClassNum
                reader.Command.Parameters.Add("@subclassnum", SqlDbType.Float).Value = itemLookup.SubClassNum
                reader.Command.Parameters.Add("@countryCode", SqlDbType.VarChar, 2).Value = itemLookup.CountryOfOrigin
                reader.Command.Parameters.Add("@country", SqlDbType.VarChar, 50).Value = itemLookup.CountryOfOriginName
                reader.Command.Parameters.Add("@taxUDA", SqlDbType.Int).Value = DataHelper.SmartValues(itemLookup.TaxUDA, "integer", False)
                reader.Command.Parameters.Add("@taxValueUDA", SqlDbType.Int).Value = itemLookup.TaxValueUDA
                reader.Command.Parameters.Add("@ID", SqlDbType.BigInt).Value = itemLookup.ID
                reader.Command.Parameters.Add("@deptString", SqlDbType.VarChar, 100).Value = itemLookup.DeptString
                reader.Command.Parameters.Add("@vendorNumberString", SqlDbType.VarChar, 100).Value = itemLookup.VendorNumberString
                reader.Command.Parameters.Add("@ItemTypeAttribute", SqlDbType.VarChar, 100).Value = itemLookup.ItemTypeAttribute
                reader.Command.Parameters.Add("@StockingStrategyCode", SqlDbType.VarChar, 100).Value = itemLookup.StockingStrategyCode
                reader.Command.Parameters.Add("@Each_Case_Weight", SqlDbType.Decimal).Value = IIf(itemLookup.EachCaseWeight = System.Decimal.MinValue, vbNull, itemLookup.EachCaseWeight)
                reader.Command.Parameters.Add("@Inner_Case_Weight", SqlDbType.Decimal).Value = IIf(itemLookup.InnerCaseWeight = System.Decimal.MinValue, vbNull, itemLookup.InnerCaseWeight)
                reader.Command.Parameters.Add("@Master_Case_Weight", SqlDbType.Decimal).Value = IIf(itemLookup.MasterCaseWeight = System.Decimal.MinValue, vbNull, itemLookup.MasterCaseWeight)
                reader.Command.Parameters.Add("@Eaches_Inner_Pack", SqlDbType.Int).Value = IIf(itemLookup.EachesInnerPack = System.Int32.MinValue, vbNull, itemLookup.EachesInnerPack)
                reader.Command.Parameters.Add("@Eaches_Master_Case", SqlDbType.Int).Value = IIf(itemLookup.EachesMasterPack = System.Int32.MinValue, vbNull, itemLookup.EachesMasterPack)
                For i = 0 To itemLookup.Countries.Count - 1
                    sql += String.Format("select [COUNTRY_CODE] as CountryCode, [COUNTRY_NAME] as CountryName from [SPD_COUNTRY] where [COUNTRY_CODE] = @countryCode{0} and UPPER([COUNTRY_NAME]) = UPPER(@country{0}); ", i)
                    reader.Command.Parameters.Add("@countryCode" & i.ToString(), SqlDbType.VarChar, 2).Value = itemLookup.Countries.Item(i).CountryCode
                    reader.Command.Parameters.Add("@country" & i.ToString(), SqlDbType.VarChar, 50).Value = itemLookup.Countries.Item(i).CountryName
                Next
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                If reader.Read() Then
                    If DataHelper.SmartValues(reader.Item("Dept"), "integer", False) > 0 Then itemLookup.DeptValid = True Else itemLookup.DeptValid = False
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    If DataHelper.SmartValues(reader.Item("ClassNum"), "long", False) > 0 Then itemLookup.ClassNumValid = True Else itemLookup.ClassNumValid = False
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    If DataHelper.SmartValues(reader.Item("SubClassNum"), "long", False) > 0 Then itemLookup.SubClassNumValid = True Else itemLookup.SubClassNumValid = False
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    If DataHelper.SmartValues(reader.Item("CountryName"), "string", False) <> String.Empty Then itemLookup.CountryOfOriginValid = True Else itemLookup.CountryOfOriginValid = False
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    If DataHelper.SmartValues(reader.Item("taxValueUDA"), "integer", False) > 0 Then itemLookup.TaxValueUDAValid = True Else itemLookup.TaxValueUDAValid = False
                Else
                    itemLookup.TaxValueUDAValid = False
                End If

                If reader.NextResult() AndAlso reader.Read() Then
                    itemLookup.StockingStrategyStatusValid = DataHelper.SmartValues(reader.Item("StockingStrategyStatusValid"), "boolean", False)
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    itemLookup.StockingStrategyTypeValid = DataHelper.SmartValues(reader.Item("StockingStrategyTypeValid"), "boolean", False)
                End If

                'pack weight
                If reader.NextResult() AndAlso reader.Read() Then
                    itemLookup.InnerWeightEachesCompareValid = DataHelper.SmartValues(reader.Item("InnerWeightEachesCompareValid"), "Decimal", False)
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    itemLookup.MasterWeightEachesCompareValid = DataHelper.SmartValues(reader.Item("MasterWeightEachesCompareValid"), "Decimal", False)
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    itemLookup.MasterWeightInnerEachesRatioValid = DataHelper.SmartValues(reader.Item("MasterWeightInnerEachesRatioValid"), "Decimal", False)
                End If

                If reader.NextResult() AndAlso reader.Read() Then
                    If DataHelper.SmartValues(reader.Item("DeptNotSameCount"), "integer", False) <= 0 Then itemLookup.SameDeptValid = True Else itemLookup.SameDeptValid = False
                End If
                If reader.NextResult() AndAlso reader.Read() Then
                    If DataHelper.SmartValues(reader.Item("VendorNumberNotSameCount"), "integer", False) <= 0 Then itemLookup.SameVendorValid = True Else itemLookup.SameVendorValid = False
                End If
                ' item errors
                If reader.NextResult() AndAlso reader.Read() Then
                    itemLookup.ItemErrors = DataHelper.SmartValues(reader.Item("ItemErrors"), "integer", False)
                End If
                If reader.NextResult() Then
                    Do While reader.Read()
                        itemLookup.AddMissingVendor(DataHelper.SmartValues(reader.Item("VendorNumber"), "integer", False))
                    Loop
                End If

                'If reader.NextResult() Then
                '    Do While reader.Read
                '        If DataHelper.SmartValues(reader.Item("InnerGTINExists"), "boolean", False) Then itemLookup.InnerGTINExists = True Else itemLookup.InnerGTINExists = False
                '        If DataHelper.SmartValues(reader.Item("InnerGTINDupBatch"), "boolean", False) Then itemLookup.InnerGTINDupBatch = True Else itemLookup.InnerGTINDupBatch = False
                '        If DataHelper.SmartValues(reader.Item("InnerGTINDupWorkflow"), "boolean", False) Then itemLookup.InnerGTINDupWorkflow = True Else itemLookup.InnerGTINDupWorkflow = False
                '    Loop
                'End If

                'If reader.NextResult() Then
                '    Do While reader.Read
                '        If DataHelper.SmartValues(reader.Item("CaseGTINExists"), "boolean", False) Then itemLookup.CaseGTINExists = True Else itemLookup.CaseGTINExists = False
                '        If DataHelper.SmartValues(reader.Item("CaseGTINDupBatch"), "boolean", False) Then itemLookup.CaseGTINDupBatch = True Else itemLookup.CaseGTINDupBatch = False
                '        If DataHelper.SmartValues(reader.Item("CaseGTINDupWorkflow"), "boolean", False) Then itemLookup.CaseGTINDupWorkflow = True Else itemLookup.CaseGTINDupWorkflow = False
                '    Loop
                'End If

                ' countries
                For i = 0 To itemLookup.Countries.Count - 1
                    If reader.NextResult() Then
                        If reader.Read() Then
                            If DataHelper.SmartValues(reader.Item("CountryName"), "string", False) = String.Empty Then itemLookup.Countries.Item(i).CountryCode = String.Empty
                        Else
                            itemLookup.Countries.Item(i).CountryCode = String.Empty
                        End If

                    Else
                        Debug.Assert(False)
                        Exit For
                    End If
                Next

            Catch ex As Exception
                Logger.LogError(ex)
                ret = False
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
            Return ret
        End Function

        ' ******************************
        ' * PO Validation*
        ' ******************************
        Public Shared Function LookupSeasonalAllocation(ByVal poAllocationEventID As Integer) As Boolean
            Dim isSeasonal As Boolean? = False

            Dim sql As String = "PO_Allocation_Event_Get_By_ID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.Int).Value = poAllocationEventID
                reader.CommandText = sql
                reader.Command.CommandTimeout = 600
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        isSeasonal = IIf(DataHelper.SmartValuesDBNull(.Item("WH_Type")).ToString = "S", True, False)
                    End With
                End If

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

            Return isSeasonal

        End Function

        Public Shared Function LookupAllocationIsDeleted(ByVal poAllocationEventID As Integer) As Boolean
            Dim isDeleted As Boolean? = False

            Dim sql As String = "PO_Allocation_Event_Get_By_ID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.Int).Value = poAllocationEventID
                reader.CommandText = sql
                reader.Command.CommandTimeout = 600
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        isDeleted = DataHelper.SmartValuesDBNull(.Item("Deleted"))
                    End With
                End If

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

            Return isDeleted
        End Function

        Public Shared Function LookupAllocationCode(ByVal poAllocationEventID As Integer) As String
            Dim code As String = ""

            Dim sql As String = "PO_Allocation_Event_Get_By_ID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.Int).Value = poAllocationEventID
                reader.CommandText = sql
                reader.Command.CommandTimeout = 600
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        code = DataHelper.SmartValuesDBNull(.Item("ALLOC_DESC"))
                    End With
                End If

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

            Return code
        End Function

        Public Shared Function LookupShipPointIsDeleted(ByVal shipPointOutLocID As String) As Boolean
            Dim isDeleted As Boolean? = False

            Dim sql As String = "PO_Ship_Point_Get_By_OUTLOC_ID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@OUTLOC_ID", SqlDbType.VarChar).Value = shipPointOutLocID
                reader.CommandText = sql
                reader.Command.CommandTimeout = 600
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        isDeleted = DataHelper.SmartValuesDBNull(.Item("Deleted"))
                    End With

                End If

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

            Return isDeleted
        End Function

        Public Shared Function LookupPaymentTermsIsDeleted(ByVal poPaymentTermID As Integer) As Boolean
            Dim isDeleted As Boolean? = False

            Dim sql As String = "PO_Payment_Terms_Get_By_ID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@ID", SqlDbType.Int).Value = poPaymentTermID
                reader.CommandText = sql
                reader.Command.CommandTimeout = 600
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                If reader.Read() Then
                    With reader
                        isDeleted = DataHelper.SmartValuesDBNull(.Item("Deleted"))
                    End With
                End If

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

            Return isDeleted
        End Function

        Public Shared Function LookupSKURMSData(ByVal vendorNumber As Long, ByVal sku As String) As DataTable
            Dim itemData As New DataTable

            Dim sql As String = "PO_Get_RMS_Item_Data"
            Dim command As DBCommand

            Dim adapter As SqlDataAdapter

            Try
                command = New DBCommand
                command.Connection = Utilities.ApplicationHelper.GetAppConnection()
                command.CommandText = sql
                command.CommandType = CommandType.StoredProcedure
                command.CommandTimeout = 600
                command.Parameters.Add("@Vendor_Number", SqlDbType.BigInt).Value = vendorNumber
                command.Parameters.Add("@Michaels_Sku", SqlDbType.VarChar).Value = sku

                adapter = New SqlDataAdapter(command.CommandObject)
                itemData = New DataTable
                adapter.Fill(itemData)

            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not command Is Nothing Then
                    command.Connection.Close()
                    command.Dispose()
                End If
            End Try

            Return itemData
        End Function

    End Class

End Namespace


