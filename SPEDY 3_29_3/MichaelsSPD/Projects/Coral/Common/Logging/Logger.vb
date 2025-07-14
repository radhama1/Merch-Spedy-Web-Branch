Imports System
Imports System.Data
Imports System.Data.SqlClient

Public Class Logger
    'Setup Logging
    Private Shared ReadOnly log As log4net.ILog = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType)

    Public Shared Sub LogError(ByVal ex As Exception)
        log.Error("ERROR: ", ex)
    End Sub

    Public Shared Sub LogActivity(ByVal activity As ActivityLog)
        log.Info("ACTIVITY: " & activity.Activity & " TYPE: " & activity.ActivityType)
    End Sub

    Public Shared Sub LogInfo(ByVal message As String)
        log.Info("INFO: " & message)
    End Sub

End Class
