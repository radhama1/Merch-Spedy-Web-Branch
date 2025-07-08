<%@ Application Language="VB" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script runat="server">

    Sub Application_Start(ByVal sender As Object, ByVal e As EventArgs)
        ' Code that runs on application startup
        'SqlDependency.Start(ConfigurationManager.ConnectionStrings("AppConnection").ConnectionString)
        Try
            log4net.Config.XmlConfigurator.ConfigureAndWatch(New System.IO.FileInfo(ConfigurationManager.AppSettings("Log4NetConfigPath")))
        Catch ex As Exception
            'TODO?
        End Try
    End Sub
    
    Sub Application_End(ByVal sender As Object, ByVal e As EventArgs)
        ' Code that runs on application shutdown
        'SqlDependency.Stop(ConfigurationManager.ConnectionStrings("AppConnection").ConnectionString)
    End Sub
        
    Sub Application_Error(ByVal sender As Object, ByVal e As EventArgs)
        ' Code that runs when an unhandled error occurs
        Try
            'Log any error to the Event Log
            NovaLibra.Common.Logger.LogError(Server.GetLastError.GetBaseException)
        Catch ex As Exception
            'If logging also fails..  do nothing.
        End Try
    End Sub

    Sub Session_Start(ByVal sender As Object, ByVal e As EventArgs)
        ' Code that runs when a new session is started
    End Sub

    Sub Session_End(ByVal sender As Object, ByVal e As EventArgs)
        ' Code that runs when a session ends. 
        ' Note: The Session_End event is raised only when the sessionstate mode
        ' is set to InProc in the Web.config file. If session mode is set to StateServer 
        ' or SQLServer, the event is not raised.
    End Sub
       
</script>