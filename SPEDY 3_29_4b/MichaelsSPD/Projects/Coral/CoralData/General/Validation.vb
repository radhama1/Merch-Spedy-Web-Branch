Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks

Public Class Validation

    Public Shared Function GetValidationDocument(ByVal validationDocType As ValidationDocumentType) As NovaLibra.Coral.SystemFrameworks.ValidationDocument
        Dim doc As NovaLibra.Coral.SystemFrameworks.ValidationDocument = New NovaLibra.Coral.SystemFrameworks.ValidationDocument
        Dim rule As ValidationRule = Nothing
        Dim conditionSet As ValidationConditionSet = Nothing
        Dim condition As ValidationCondition = Nothing
        Dim itemType As Integer
        Dim ruleID As Integer
        Dim setID As Integer
        Dim conID As Integer
        Dim sql As String = "usp_Validation_GetDocumentDetail"
        Dim reader As DBReader = Nothing
        Dim conn As DBConnection = Nothing
        Dim cmd As DBCommand
        Try
            conn = Utilities.ApplicationHelper.GetAppConnection()
            reader = New DBReader(conn)
            cmd = reader.Command
            cmd.Parameters.Add("@Validation_Document_ID", SqlDbType.Int).Value = validationDocType
            reader.CommandText = sql
            reader.CommandType = CommandType.StoredProcedure
            reader.Open()

            ' ValidationDocument
            If reader.Read() Then
                With reader
                    doc.ID = DataHelper.SmartValues(.Item("ID"), "integer", True)
                    doc.DocumentType = validationDocType
                    doc.WorkflowID = DataHelper.SmartValues(.Item("Workflow_ID"), "integer", True)
                    doc.MetadataTableID = DataHelper.SmartValues(.Item("Metadata_Table_ID"), "integer", True)
                    doc.Document = DataHelper.SmartValues(.Item("Validation_Document"), "string", True)
                End With
            End If

            ' ValidationRule
            If reader.NextResult() Then
                Do While reader.Read()
                    With reader
                        rule = New ValidationRule()
                        rule.ID = DataHelper.SmartValues(.Item("ID"), "integer", True)
                        rule.ValidationRule = DataHelper.SmartValues(.Item("Validation_Rule"), "string", True)
                        rule.MetadataColumnID = DataHelper.SmartValues(.Item("Metadata_Column_ID"), "integer", True)
                        doc.AddRule(rule)
                    End With
                Loop
            End If

            ' ValidationConditionSet, ValidationCondition
            If reader.NextResult() Then
                Do While reader.Read()
                    With reader
                        ruleID = DataHelper.SmartValues(.Item("Validation_Rule_ID"), "integer", True)
                        setID = DataHelper.SmartValues(.Item("Validation_Condition_Set_ID"), "integer", True)
                        conID = DataHelper.SmartValues(.Item("Validation_Condition_ID"), "integer", True)
                        If rule Is Nothing OrElse rule.ID <> ruleID Then
                            rule = doc.GetRule(ruleID)
                            If rule Is Nothing Then Continue Do
                        End If
                        If conditionSet Is Nothing OrElse conditionSet.ID <> setID Then
                            conditionSet = New ValidationConditionSet()
                            conditionSet.ID = setID
                            itemType = DataHelper.SmartValues(.Item("Validation_Rule_Type_ID"), "integer", False)
                            If ValidationRuleType.IsDefined(GetType(ValidationRuleType), itemType) Then
                                conditionSet.RuleType = CType(itemType, ValidationRuleType)
                            Else
                                conditionSet.RuleType = ValidationRuleType.TypeCustom
                            End If
                            conditionSet.ErrorText = DataHelper.SmartValues(.Item("Error_Text"), "string")
                            conditionSet.ErrorSeverity = DataHelper.SmartValues(.Item("Validation_Rule_Severity_ID"), "integer", False)
                            rule.AddConditionSet(conditionSet)
                        End If
                        condition = New ValidationCondition()
                        condition.ID = conID
                        itemType = DataHelper.SmartValues(.Item("Validation_Condition_Type_ID"), "integer", False)
                        If ValidationConditionType.IsDefined(GetType(ValidationConditionType), itemType) Then
                            condition.ConditionType = CType(itemType, ValidationConditionType)
                        Else
                            condition.ConditionType = ValidationConditionType.Unknown
                        End If
                        condition.Field1 = DataHelper.SmartValues(.Item("Field1"), "integer", True)
                        condition.Field2 = DataHelper.SmartValues(.Item("Field2"), "integer", True)
                        condition.Field3 = DataHelper.SmartValues(.Item("Field3"), "integer", True)
                        condition.Value1 = DataHelper.SmartValues(.Item("Value1"), "string", True)
                        condition.Value2 = DataHelper.SmartValues(.Item("Value2"), "string", True)
                        condition.Value3 = DataHelper.SmartValues(.Item("Value3"), "string", True)
                        condition.ConditionOperator = DataHelper.SmartValues(.Item("Operator"), "string", True)
                        condition.Conjunction = DataHelper.SmartValues(.Item("Conjunction"), "string", True)
                        conditionSet.AddCondition(condition)
                    End With
                Loop
                rule = Nothing : conditionSet = Nothing : condition = Nothing
            End If

            ' Stages (for the ValidationConditionSet)
            If reader.NextResult() Then
                Do While reader.Read()
                    With reader
                        ruleID = DataHelper.SmartValues(.Item("Validation_Rule_ID"), "integer", True)
                        setID = DataHelper.SmartValues(.Item("Validation_Condition_Set_ID"), "integer", True)
                        If rule Is Nothing OrElse rule.ID <> ruleID Then
                            rule = doc.GetRule(ruleID)
                            If rule Is Nothing Then Continue Do
                        End If
                        If conditionSet Is Nothing OrElse conditionSet.ID <> setID Then
                            conditionSet = rule.GetConditionSet(setID)
                            If conditionSet Is Nothing Then Continue Do
                        End If
                        conditionSet.AddStage(DataHelper.SmartValues(.Item("SPD_Workflow_Stage_ID"), "integer", True))
                    End With
                Loop
                rule = Nothing : conditionSet = Nothing : condition = Nothing
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
        Return doc
    End Function

End Class
