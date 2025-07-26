Imports System.Data.SqlClient
Imports System.Diagnostics
Imports System.Web
Imports System.Web.Caching
Imports Microsoft.VisualBasic
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks

Public Class MetadataHelper
    Private Const CACHE_METADATA As String = "METADATA"

    Public Shared Function GetMetadata() As NovaLibra.Coral.SystemFrameworks.Metadata
        Dim md As NovaLibra.Coral.SystemFrameworks.Metadata = Nothing
        Dim obj As Object = HttpContext.Current.Cache.Get(CACHE_METADATA)
        If obj Is Nothing Then
            md = NovaLibra.Coral.Data.MetadataData.GetMetadata()
            'HttpContext.Current.Cache.Insert(CACHE_METADATA, md, Nothing, System.Web.Caching.Cache.NoAbsoluteExpiration, New TimeSpan(12, 0, 0))

            Dim SqlDep As SqlCacheDependency = Nothing
            Try
                SqlDep = New SqlCacheDependency(AppHelper.GetDatabaseName(), "SPD_Metadata_Column")
            Catch exDBDis As DatabaseNotEnabledForNotificationException
                Try
                    SqlCacheDependencyAdmin.EnableNotifications("AppConnection")
                Catch exPerm As UnauthorizedAccessException
                    Debug.Assert(False, "Caching failed miserably.")
                End Try
            Catch exTabDis As TableNotEnabledForNotificationException
                Try
                    SqlCacheDependencyAdmin.EnableTableForNotifications("AppConnection", "SPD_Metadata_Column")
                Catch exc As SqlException
                    Debug.Assert(False, "Caching failed miserably.")
                End Try
            Finally
                HttpContext.Current.Cache.Insert(CACHE_METADATA, md, SqlDep)
            End Try

        Else
            md = CType(obj, NovaLibra.Coral.SystemFrameworks.Metadata)
        End If
        Return md
    End Function

End Class
