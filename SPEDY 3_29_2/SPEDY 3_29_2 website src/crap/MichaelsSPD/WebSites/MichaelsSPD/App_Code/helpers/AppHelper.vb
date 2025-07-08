Imports System.Web
Imports System.Configuration

Imports Microsoft.VisualBasic

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities

Public Class AppHelper
    Private Const _keyUserID As String = "UserID"
    Private Const _keyFirstName As String = "First_Name"
    Private Const _keyLastName As String = "Last_name"

    Public Shared Function GetUserID() As Integer
        Return DataHelper.SmartValues(HttpContext.Current.Session(_keyUserID), "integer", False)
    End Function

    Public Shared Function GetUser() As String
        Return (HttpContext.Current.Session(_keyFirstName) & " " & HttpContext.Current.Session(_keyLastName))
    End Function

    Private Const _keyVendorID As String = "vendorId"

    Public Shared Function GetVendorID() As Integer
        Return DataHelper.SmartValues(HttpContext.Current.Session(_keyVendorID), "integer", False)
    End Function

    Private Const _KEY_IMPORT_ITEM_MAX_NEW_ITEM As String = "IMPORT_ITEM_MAX_NEW_ITEM"
    Private Const _KEY_DOMESTIC_ITEM_MAX_ROW As String = "DOMESTIC_ITEM_MAX_ROW"

    Public Shared Function GetImportItemMaxNewItem() As Integer
        Return DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings(_KEY_IMPORT_ITEM_MAX_NEW_ITEM), "integer", False)
    End Function

    Public Shared Function GetDomesticItemMaxRow() As Integer
        Return DataHelper.SmartValues(System.Configuration.ConfigurationManager.AppSettings(_KEY_DOMESTIC_ITEM_MAX_ROW), "integer", False)
    End Function

    ' CURRENT SPREADSHEET VERSIONS
    Private Const _KEY_SPREADSHEET_IMPORT As String = "SPREADSHEET_IMPORT"
    Private Const _KEY_SPREADSHEET_DOMESTIC As String = "SPREADSHEET_DOMESTIC"

    Public Shared Function GetCurrentImportSpreadsheetVersion() As String
        Return System.Configuration.ConfigurationManager.AppSettings(_KEY_SPREADSHEET_IMPORT).Trim()
    End Function

    Public Shared Function GetCurrentDomesticSpreadsheetVersion() As String
        Return System.Configuration.ConfigurationManager.AppSettings(_KEY_SPREADSHEET_DOMESTIC).Trim()
    End Function

    ' CURRENT SPREADSHEET PASSWORDS
    Private Const _KEY_SPREADSHEET_IMPORT_PASSWORD As String = "SPREADSHEET_IMPORT_PASSWORD"
    Private Const _KEY_SPREADSHEET_DOMESTIC_PASSWORD As String = "SPREADSHEET_DOMESTIC_PASSWORD"

    Public Shared Function GetCurrentImportSpreadsheetPassword() As String
        Return System.Configuration.ConfigurationManager.AppSettings(_KEY_SPREADSHEET_IMPORT_PASSWORD).Trim()
    End Function

    Public Shared Function GetCurrentDomesticSpreadsheetPassword() As String
        Return System.Configuration.ConfigurationManager.AppSettings(_KEY_SPREADSHEET_DOMESTIC_PASSWORD).Trim()
    End Function

    ' Validation_Rules
    ' DATABASE CONNECTION AND INFORMATION
    Private Const _KEY_DATABASENAME As String = "DatabaseName"
    Public Shared Function GetDatabaseName() As String
        Return System.Configuration.ConfigurationManager.AppSettings(_KEY_DATABASENAME).Trim()
    End Function
    Private Const _KEY_APPCONNECTION As String = "AppConnection"
    Public Shared Function GetDatabaseNameFromConnectionString() As String
        Dim databaseName As String = String.Empty
        Dim startString As String = "CATALOG="
        Dim connString As String = System.Configuration.ConfigurationManager.ConnectionStrings(_KEY_APPCONNECTION).ConnectionString.Trim()
        Dim connStringU As String = connString.ToUpper()
        Dim pos1 As Integer, pos2 As Integer
        pos1 = connStringU.IndexOf(startString)
        If pos1 >= 0 Then pos2 = connStringU.IndexOf(";", pos1)
        If pos1 >= 0 AndAlso pos2 > pos1 Then
            databaseName = connString.Substring((pos1 + startString.Length), (pos2 - (pos1 + startString.Length)))
        End If
        Return databaseName
    End Function

End Class
