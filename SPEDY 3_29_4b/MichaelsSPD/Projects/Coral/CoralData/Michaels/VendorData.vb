Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels

    Public Class VendorData

        Public Function GetVendorRecord(ByVal vendorNumber As Long) As NovaLibra.Coral.SystemFrameworks.Michaels.VendorRecord
            Dim objRecord As VendorRecord = New VendorRecord()
            Dim sql As String = "select * from SPD_Vendor where Vendor_Number = @vendorNumber"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection(False)
                conn.Open()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@vendorNumber", SqlDbType.BigInt)
                objParam.Value = DataHelper.DBSmartValues(vendorNumber, "long", False)
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.Command.CommandTimeout = 600
                reader.CommandType = CommandType.Text
                reader.Open()
                If reader.Read() Then
                    With reader
                        objRecord.ID = .Item("ID")
                        objRecord.VendorNumber = DataHelper.SmartValues(.Item("Vendor_Number"), "long", False)
                        objRecord.VendorName = DataHelper.SmartValues(.Item("Vendor_Name"), "string", True)
                        objRecord.VendorType = DataHelper.SmartValues(.Item("Vendor_Type"), "string", True)
                        objRecord.PaymentTerms = DataHelper.SmartValues(.Item("PaymentTerms"), "string", True)
						objRecord.FreightTerms = DataHelper.SmartValues(.Item("FreightTerms"), "string", True)
						objRecord.EDIFlag = DataHelper.SmartValues(.Item("EDIFlag"), "boolean", False)
						objRecord.CurrencyCode = DataHelper.SmartValues(.Item("CurrencyCode"), "string", True)
                    End With
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
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return objRecord
        End Function

        Public Shared Function GetVendorType(ByVal vendorNumber As Long) As String
            Dim vendorOrAgent As String = ""

            Dim sql As String = "Select top 1 * From SPD_Item_Master_Vendor Where Vendor_Number = @VendorNumber"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing

            Try

                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@VendorNumber", SqlDbType.BigInt).Value = vendorNumber
                reader.CommandText = sql
                reader.Command.CommandTimeout = 600
                reader.CommandType = CommandType.Text
                reader.Open()
                While reader.Read()
                    With reader
                        vendorOrAgent = DataHelper.SmartValues(.Item("Vendor_Or_Agent"), "CStr", False)
                    End With
                End While

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

            Return vendorOrAgent
        End Function

    End Class

End Namespace
