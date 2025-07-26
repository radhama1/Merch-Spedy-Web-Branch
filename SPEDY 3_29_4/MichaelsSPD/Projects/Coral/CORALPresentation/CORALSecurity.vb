Imports System.Data
Imports System.Data.SqlClient
Imports System.Web
Imports System.Text
Imports CORALPresentation.CORALUtility


'*******************************************************************************
'Class: CORALSecurity
'Created by: Scott Page
'Created Date: 3/10/2005
'Modifed Date:
'Desc: This class contains functions and methods to handle the security elements
'of the coral system such as verifying that the user has access to the web site,
'checking access to topic ID's, etc.
'********************************************************************************

Public Class CORALSecurity

    Public Sub InitializeSite()
        Dim dsWebSiteDetails As New DataSet
        Dim dt As New DataTable
        Dim row As DataRow
        Dim myRequest As HttpRequest
        Dim myResponse As HttpResponse
        Dim mySession As SessionState.HttpSessionState
        Dim myHost As String
        Dim myPath As String
        'Dim intTopicID As Integer

        myRequest = HttpContext.Current.Request 'Get an object for the current request object
        mySession = HttpContext.Current.Session 'Get an object for the current user session
        myResponse = HttpContext.Current.Response 'Get an object for the current user response
        myHost = myRequest.Url.Host 'Get the host name from the requesting URL
        myPath = myRequest.ServerVariables("PATH_INFO") 'Get the path information

        dsWebSiteDetails = CORALData.GetWebSiteDetails 'Get a list of web site details for this web site
        dt = dsWebSiteDetails.Tables(0)
        For Each row In dt.Rows 'Multiples rows will be returned as there are usually alias's for the site
            'Determine what site we need the details from by checking the requested host and path information
            If CStr(FixNull(row("Promotion_State_URL"), GetType(String))) = myHost Then 'Check to make sure the HOST name for the site matches the request
                If InStr(myPath.ToLower, CStr(FixNull(row("Promotion_State_Path"), GetType(String))).ToLower) > 0 Then 'make sure that the URL path matches what is set for the site
                    mySession("Promotion_State_URL") = myHost
                    mySession("Promotion_State_Path") = myPath
                    mySession("Allow_Anon_Access") = CBool(FixNull(row("Allow_Anon_Access"), GetType(Boolean)))
                    If CInt(FixNull(row("Promotion_State_ID"), GetType(Int16))) < 0 Then
                        mySession("Promotion_State_ID") = 0
                    Else
                        mySession("Promotion_State_ID") = CInt(FixNull(row("Promotion_State_ID"), GetType(Int16)))
                    End If
                    mySession("Website_Keywords") = HttpContext.Current.Server.HtmlEncode(CStr(FixNull(row("Website_Keywords"), GetType(String))))
                    mySession("Website_Abstract") = HttpContext.Current.Server.HtmlEncode(CStr(FixNull(row("Website_Abstract"), GetType(String))))
                    mySession("Website_Summary") = HttpContext.Current.Server.HtmlEncode(CStr(FixNull(row("Website_Summary"), GetType(String))))
                    Exit For
                End If
            End If
        Next

        'If anonymous access for the site is turned off and we don't have a logged in user at this point
        'Redirect the user to the login page
        ' TODO: change back if necessary (NDF)
        If CBool(mySession("Allow_Anon_Access")) = False Then ' And CInt(mySession("User_ID")) <= 0 Then
            mySession("redirURL") = myRequest.RawUrl
            myResponse.Redirect("./Login.aspx")
        End If

        'Stub for code of how to handle the user if the site is anonymous = off AND they are logged in
        'there are various deprecetaged security methods that need to be replaced, but we'll have to
        'put them on the back burner for the time being

    End Sub

    Public Sub InitializeSite(ByVal bolDeprecated As Boolean)
        'Note, this is the deprecated initialize site that fulfilled the same role as the security include file in the
        'united site.  The new security model no longer uses this method


        'Method run at the top of each page that does a variety of etup functions for each time a user views a page
        'inside a CORAL site.  The site will first get the proper site details by examining the Server name and path details
        'and store those values inside a session.  It then checks to see if anonymous access is enabled for the site.
        'If anonymous access is enabled the security simply allows the user to view the page.  If anonymous access is not
        'enabled it will then check to see if the user has logged in yet.  If not, the user is sent to the login page. 
        'If the user has logged in it checks to make sure the user has access to this web site.  If not, they are sent
        'to the login page.  If they are allowed access to the site it then performs a check to verify that the user
        'has proper access to the content on this page, and if so then they are allowed to view the page. If not, they are 
        'redirected to the default page.

        Dim dsWebSiteDetails As New DataSet
        Dim dt As New DataTable
        Dim row As DataRow
        Dim myRequest As HttpRequest
        Dim myResponse As HttpResponse
        Dim mySession As SessionState.HttpSessionState
        Dim myHost As String
        Dim myPath As String
        Dim intTopicID As Integer

        myRequest = HttpContext.Current.Request 'Get an object for the current request object
        mySession = HttpContext.Current.Session 'Get an object for the current user session
        myResponse = HttpContext.Current.Response 'Get an object for the current user response
        myHost = myRequest.Url.Host 'Get the host name from the requesting URL
        myPath = myRequest.ServerVariables("PATH_INFO") 'Get the path information

        dsWebSiteDetails = CORALData.GetWebSiteDetails 'Get a list of web site details for this web site
        dt = dsWebSiteDetails.Tables(0)
        For Each row In dt.Rows 'Multiples rows will be returned as there are usually alias's for the site
            'Determine what site we need the details from by checking the requested host and path information
            If CStr(FixNull(row("Promotion_State_URL"), GetType(String))) = myHost Then 'Check to make sure the HOST name for the site matches the request
                If InStr(myPath.ToLower, CStr(FixNull(row("Promotion_State_Path"), GetType(String))).ToLower) > 0 Then 'make sure that the URL path matches what is set for the site
                    mySession("Promotion_State_URL") = myHost
                    mySession("Promotion_State_Path") = myPath
                    mySession("Allow_Anon_Access") = CBool(FixNull(row("Allow_Anon_Access"), GetType(Boolean)))
                    If CInt(FixNull(row("Promotion_State_ID"), GetType(Int16))) < 0 Then
                        mySession("Promotion_State_ID") = 0
                    Else
                        mySession("Promotion_State_ID") = CInt(FixNull(row("Promotion_State_ID"), GetType(Int16)))
                    End If
                    mySession("Website_Keywords") = HttpContext.Current.Server.HtmlEncode(CStr(FixNull(row("Website_Keywords"), GetType(String))))
                    mySession("Website_Abstract") = HttpContext.Current.Server.HtmlEncode(CStr(FixNull(row("Website_Abstract"), GetType(String))))
                    mySession("Website_Summary") = HttpContext.Current.Server.HtmlEncode(CStr(FixNull(row("Website_Summary"), GetType(String))))
                    Exit For
                End If
            End If
        Next

        'If anonymous access for the site is turned off and we don't have a logged in user at this point
        'Redirect the user to the login page
        If CBool(mySession("Allow_Anon_Access")) = False Then ' And CInt(mySession("User_ID")) <= 0 Then
            mySession("redirURL") = myRequest.RawUrl
            myResponse.Redirect("./Login.aspx")
        End If

        If CBool(mySession("Allow_Anon_Access")) = False Then 'If the site has anonymous access turned off
            'If the current website is not setup to allow anonymous access

            'Check if the user has access to the current web site, if not send them back to the login page
            If 1 = 2 And CheckUserWebSiteSecurity(CInt(mySession("User_ID"))) = False Then
                mySession("redirURL") = myRequest.RawUrl
                myResponse.Redirect("./Login.aspx")
            Else
                'The user does have access, so make sure that the user also has access to the particular content for this page
                intTopicID = CInt(myRequest("tid")) 'Get the Topic ID from the query string passed in
                If CheckUserTopicSecurity(CInt(mySession("User_ID")), intTopicID, CInt(mySession("Promotion_State_ID"))) = False Then
                    'The user does not have proper access to the content on this page so send them back to default
                    myResponse.Redirect("./Default.aspx")
                End If
            End If
        End If
    End Sub

    Public Function CheckUserWebSiteSecurity(ByVal intUserID As Integer) As Boolean
        'Retrieves the allowable users, groups, and roles for the web site and checks
        'to see if the User's ID, User's Group, or User's security role IDs are in the returned lists
        'If any of them match the function returns True

        Dim dr As SqlDataReader
        Dim arUserGroups() As String
        Dim arUserRoles() As String
        Dim arWebSiteGroups() As String
        Dim arWebSiteRoles() As String
        Dim arWebSiteUsers() As String
        Dim mySession As SessionState.HttpSessionState

        mySession = HttpContext.Current.Session 'get the current user session

        'Get the user groups and roles from the session and split them into arrays
        arUserGroups = Split(CStr(mySession("Group_List")), ",")
        arUserRoles = Split(CStr(mySession("Security_Role_List")), ",")

        'execute the stored procedure and retrieve the data in a sql reader
        dr = CORALData.GetWebSiteSecurity(CInt(mySession("Promotion_State_ID")))
        If dr.Read = True Then ' If we have data
            'Split the comma delimited values from the database into arrays
            arWebSiteGroups = Split(CStr(FixNull(dr("allowedGroups"), GetType(String))), ",")
            arWebSiteRoles = Split(CStr(FixNull(dr("allowedRoles"), GetType(String))), ",")
            arWebSiteUsers = Split(CStr(FixNull(dr("allowedUsers"), GetType(String))), ",")

            Dim x As Integer 'counter

            If Array.BinarySearch(arWebSiteUsers, intUserID.ToString) >= 0 Then
                dr.Close()
                Return True 'the user's ID belongs to the set of allowed users, so return true and exit
            End If

            For x = 0 To arUserGroups.Length - 1
                If Array.BinarySearch(arWebSiteGroups, arUserGroups(x)) >= 0 Then
                    dr.Close()
                    Return True 'Our user belongs to a group that is set for this web site, so return true and exit
                End If
            Next

            For x = 0 To arUserRoles.Length - 1
                If Array.BinarySearch(arWebSiteRoles, arUserRoles(x)) >= 0 Then
                    dr.Close()
                    Return True 'Our user belongs to a role that is set for this web site, so return true and exit
                End If
            Next

            dr.Close()
            Return False 'The user does not have permission to the site so return false
        Else
            'Throw an expcetion here as we can't read from the database.
        End If
        dr.Close()
    End Function

    Public Function CheckUserTopicSecurity(ByVal intUserID As Integer, ByVal intTopicID As Integer, _
    ByVal intPromotionStateID As Integer) As Boolean
        'Checks to see if the userID being passed has access to the TopicID being passed.  Result from the database is 0 for
        'false and 1 for true. If we get a 1 back from the database we return True to indicate that the user has appropriate
        'access to this topic
        'Note: deprecated - not updated to work with the new security model
        Dim intResult As Byte

        intResult = CORALData.CheckTopicSecurity(intUserID, intTopicID, intPromotionStateID)
        If intResult = 1 Then
            Return True
        Else
            Return False
        End If
    End Function

    Public Function LoginUser(ByVal strLoginName As String, ByVal strPassword As String) As String
        'Processes a user login and sets up session information for the user if successful
        Dim dr As SqlDataReader
        Dim mySession As SessionState.HttpSessionState
        Dim strResult As String = String.Empty

        mySession = HttpContext.Current.Session 'Get the currrent user session
        Try
            dr = CORALData.GetUserLoginInfo(strLoginName) 'check the login name and return a data reader
            If dr.Read = True Then
                'check to see if we have a matching password
                'and make sure the account is enabled
                If CStr(FixNull(dr("Password"), GetType(String))).ToLower = strPassword.ToLower _
                And CBool(FixNull(dr("Enabled"), GetType(Boolean))) = True Then
                    'If we have a match the login is successful so setup the session values and return true
                    mySession("User_ID") = CStr(dr("ID"))
                    mySession("User_Name") = strLoginName
                    mySession("User_First_Name") = CStr(FixNull(dr("First_Name"), GetType(String)))
                    mySession("User_Last_Name") = CStr(FixNull(dr("Last_Name"), GetType(String)))
                    mySession("User_Organization") = CStr(FixNull(dr("Organization"), GetType(String)))
                    mySession("User_Email_Address") = CStr(FixNull(dr("Email_Address"), GetType(String)))
                    mySession("User_Date_Created") = CDate(FixNull(dr("Date_Created"), GetType(DateTime)))
                    mySession("User_Date_Last_Modified") = CDate(FixNull(dr("Date_Last_Modified"), GetType(DateTime)))
                    mySession("Group_List") = CStr(FixNull(dr("Group_List"), GetType(String)))
                    mySession("Login_Password") = CStr(FixNull(dr("Password"), GetType(String)))
                    '6-20-2005 For the time being we have commented out loading the user's language into the session
                    'as we do not yet have the site setup for hi band / low band, so by default in global.asax 
                    'all users are set to high band on first login, and will be for the entire site
                    'mySession("User_Language") = CInt(FixNull(dr("Language_ID"), GetType(Integer)))
                    dr.Close()

                    'Update the total number of logins for this user
                    CORALData.UpdateUserLoginStats(CInt(mySession("User_ID")))
                    strResult = "Successful"
                ElseIf CStr(FixNull(dr("Password"), GetType(String))) <> strPassword Then 'users password didn't match
                    strResult = "Bad Password"
                ElseIf CBool(FixNull(dr("Enabled"), GetType(Boolean))) = False Then
                    strResult = "Not Enabled"
                End If
            Else
                strResult = "User Not Found"
            End If
            dr.Close()
            Return strResult
        Catch ex As Exception
            Throw ex
        Finally
            If dr.IsClosed = False Then
                dr.Close()
            End If
        End Try
       
    End Function

    Public Function ForgotPassword(ByVal strUserName As String) As String
        'Gets the user login data for the user name that is passed and then fires
        'off an autoamtic E-mail to the user based on the content system that 
        'contains their password information, etc.
        Dim dr As SqlDataReader
        Dim strEmail As String

        dr = CORALData.GetUserLoginInfo(strUserName)
        If dr.Read = True Then
            strEmail = CStr(FixNull(dr("Email_Address"), GetType(String)))
            If Not strEmail = Nothing Then
                dr.Close()
                Return strEmail
            End If
        End If
        dr.Close()
        Return "0"
    End Function
End Class
