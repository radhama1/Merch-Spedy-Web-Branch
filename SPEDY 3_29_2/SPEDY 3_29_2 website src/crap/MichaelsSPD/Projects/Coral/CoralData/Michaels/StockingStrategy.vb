Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels
    Public Class StockingStrategy

        Public Function GetStockingStrategies() As List(Of StockingStrategyRecord)
            Dim objSSRs As New List(Of StockingStrategyRecord)

            Dim objSSR As StockingStrategyRecord

            Dim sql As String = "usp_Get_Stocking_Strategy_All"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim bRead As Boolean = False
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                bRead = reader.Read()
                Do While bRead
                    objSSR = New StockingStrategyRecord
                    With reader
                        objSSR.StrategyCode = DataHelper.SmartValues(.Item("Strategy_Code"), "string", True)
                        objSSR.StrategyDesc = DataHelper.SmartValues(.Item("Strategy_Desc"), "string", True)
                        objSSR.StrategyType = DataHelper.SmartValues(.Item("Strategy_Type"), "string", True)
                        objSSR.Warehouse = DataHelper.SmartValues(.Item("Warehouse"), "long", True)
                        objSSR.StartDate = DataHelper.SmartValues(.Item("Start_Date"), "date", True)
                        objSSR.StartDate = DataHelper.SmartValues(.Item("End_Date"), "date", True)
                        objSSR.StrategyStatus = DataHelper.SmartValues(.Item("Strategy_Status"), "string", True)
                    End With
                    objSSRs.Add(objSSR)
                    bRead = reader.Read()
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
            Return objSSRs
        End Function

        Public Function GetStockingStrategiesByWarehouses(ByVal ItemTypeAttribute As String, ByVal Warehouses As String, ByVal WorkflowStageTypeID As Int32) As Dictionary(Of String, String)
            Dim objSSRs As New Dictionary(Of String, String)

            If Warehouses.Length = 0 Then
                Return objSSRs
            End If

            Dim sql As String = "usp_Get_Stocking_Strategy_By_Warehouses"
            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim bRead As Boolean = False
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                cmd.Parameters.Add("@ItemTypeAttribute", SqlDbType.VarChar, 20).Value = ItemTypeAttribute
                cmd.Parameters.Add("@Warehouses", SqlDbType.VarChar, 8000).Value = Warehouses.Replace(", ", ",").Replace(" ,", ",")
                cmd.Parameters.Add("@WorkflowStageTypeID", SqlDbType.Int, 8).Value = WorkflowStageTypeID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                bRead = reader.Read()
                Do While bRead

                    With reader
                        objSSRs.Add(DataHelper.SmartValues(.Item("Strategy_Code"), "string", True), DataHelper.SmartValues(.Item("Strategy_Desc"), "string", True))
                    End With

                    bRead = reader.Read()
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
            Return objSSRs
        End Function

        Public Function GetWarehousesForStockingStrategy(dtCurrent As DateTime) As Dictionary(Of Int64, Int64)
            Dim whs As New Dictionary(Of Int64, Int64)
            Dim dtCutover As DateTime

            Dim intDestWH As Int64
            Dim intWH As Int64

            Dim sql As String = "Select distinct Warehouse, sched.Destination_Warehouse, sched.Cutover_Date from Stocking_Strategy strat " &
                                "left outer join DC_Cutover_Schedule sched on right(strat.Warehouse,2) = sched.Cutover_Warehouse " &
                                "order by Warehouse"

            Dim reader As DBReader = Nothing
            Dim cmd As DBCommand
            Dim conn As DBConnection = Nothing
            Dim bRead As Boolean = False
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                cmd = reader.Command
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                bRead = reader.Read()
                Do While bRead
                    intWH = 0
                    With reader
                        intWH = DataHelper.SmartValues(.Item("Warehouse"), "bigint", True)
                        intDestWH = DataHelper.SmartValues(.Item("Destination_Warehouse"), "bigint", False)
                        dtCutover = DataHelper.SmartValues(.Item("Cutover_Date"), "datetime", True)
                    End With
                    If dtCutover > dtCurrent Then
                        intDestWH = 0
                    End If
                    If intWH > 0 Then
                        whs.Add(intWH, intDestWH)
                    End If
                    bRead = reader.Read()
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
            Return whs
        End Function

    End Class



End Namespace


