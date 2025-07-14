
Imports System
Imports System.Configuration
Imports System.Data.SqlClient

Imports System.ComponentModel
Imports CORALPresentation.CORALUtility

'*******************************************************************************
'Class: CORALData
'Created by: Scott Page
'Created Date: 3/10/2005
'Modifed Date:
'Desc: This class contains functions and methods needed to access the SQL database
'********************************************************************************
Public Class CORALData

    Public Shared Function GetConnection() As SqlConnection
        'Creates a connectoin with the specified connection string in web.config
        Dim connection As New SqlConnection

        connection.ConnectionString = System.Configuration.ConfigurationManager.ConnectionStrings("AppConnection").ConnectionString
        Return connection
    End Function

    Public Shared Function GetWebSiteAccessKey() As Guid
        'Converts the web site access key stored in the web.config into a GUID
        Dim myWebSiteAccessKey As New Guid(CStr(System.Configuration.ConfigurationManager.AppSettings("Website_Access_Key")))
        Return myWebSiteAccessKey
    End Function

    Public Shared Function GetWebSiteDetails() As DataSet
        'Gets a data set consisting of the web site path, URL, path, abstract, summary, etc. for all aliases given
        'a particular web site ID and web site access key
        Dim command As New SqlCommand
        Dim ds As New DataSet
        Dim da As New SqlDataAdapter

        command.Connection = GetConnection()
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_websites_anonuser_return_website_details"
        command.Parameters.Add(New SqlParameter("@myWebsiteID", SqlDbType.Int))
        command.Parameters("@myWebsiteID").Value = System.Configuration.ConfigurationManager.AppSettings("WebSiteID")
        command.Parameters.Add(New SqlParameter("@myWebsiteAccessKey", SqlDbType.UniqueIdentifier))
        command.Parameters("@myWebsiteAccessKey").Value = GetWebSiteAccessKey()
        Try
            da.SelectCommand = command
            da.Fill(ds)
            Return ds
        Catch ex As SqlException
            Throw ex
        Finally
            command.Connection.Close()
            command.Connection.Dispose()
            da.Dispose()
        End Try
    End Function

    Public Shared Function GetWebSiteSecurity(ByVal intPromotionStateID As Integer) As SqlDataReader
        'Gets the web site allowed roles, allowed groups, and allowed users from the database
        'in three separate comma delimited fields

        Dim command As New SqlCommand
        Dim dr As SqlDataReader
        Dim connection As New SqlConnection

        connection = GetConnection()

        command.Connection = connection
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_websites_anonuser_return_website_security"
        command.Parameters.Add(New SqlParameter("@myWebsiteID", SqlDbType.Int))
        command.Parameters("@myWebsiteID").Value = System.Configuration.ConfigurationManager.AppSettings("WebSiteID")
        command.Parameters.Add(New SqlParameter("@myWebsiteAccessKey", SqlDbType.UniqueIdentifier))
        command.Parameters("@myWebsiteAccessKey").Value = GetWebSiteAccessKey()
        command.Parameters.Add(New SqlParameter("@PromotionStateID", SqlDbType.Int))
        command.Parameters("@PromotionStateID").Value = intPromotionStateID
        Try
            connection.Open()
            dr = command.ExecuteReader(CommandBehavior.CloseConnection)
            Return dr
        Catch ex As SqlException
            connection.Close()
            connection.Dispose()
            dr.Close()
            Throw ex
        End Try
    End Function

    Public Shared Function CheckTopicSecurity(ByVal intUserID As Integer, ByVal intTopicID As Integer, _
    ByVal intPromotionStateID As Integer) As Byte
        'Executes a stored procedure that takes in the UserID, TopicID, and the web site information and determines
        'If the user has access to the topic information.  Returns True if the user is permitted access

        Dim command As New SqlCommand
        Dim intResult As Byte
        Dim connection As New SqlConnection

        connection = GetConnection()
        command.Connection = connection
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_websites_anonuser_check_topic_access"
        command.Parameters.Add(New SqlParameter("@myTopicID", SqlDbType.Int))
        command.Parameters("@myTopicID").Value = intTopicID
        command.Parameters.Add(New SqlParameter("@myUserID", SqlDbType.Int))
        command.Parameters("@myUserID").Value = intUserID
        command.Parameters.Add(New SqlParameter("@myWebsiteID", SqlDbType.Int))
        command.Parameters("@myWebsiteID").Value = System.Configuration.ConfigurationManager.AppSettings("WebSiteID")
        command.Parameters.Add(New SqlParameter("@myWebsiteAccessKey", SqlDbType.UniqueIdentifier))
        command.Parameters("@myWebsiteAccessKey").Value = GetWebSiteAccessKey()
        command.Parameters.Add(New SqlParameter("@PromotionStateID", SqlDbType.Int))
        command.Parameters("@PromotionStateID").Value = intPromotionStateID
        Try
            connection.Open()
            intResult = CByte(command.ExecuteScalar)
            Return intResult
        Catch ex As SqlException
            Throw ex
        Finally
            connection.Close()
            connection.Dispose()
        End Try
    End Function

    Public Shared Function GetUserLoginInfo(ByVal strLoginName As String) As SqlDataReader
        'Executes a stored procedure that takes in the login name and finds the corresponding user record
        'returns the entire user record along with the associated users security roles and security gruops, the latter two
        'in a comma delimited string

        Dim connection As New SqlConnection
        Dim command As New SqlCommand
        Dim dr As SqlDataReader

        connection = GetConnection()
        command.Connection = connection
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_security_login_user"
        command.Parameters.Add(New SqlParameter("@myLoginName", SqlDbType.VarChar, 200))
        command.Parameters("@myLoginName").Value = strLoginName
        Try
            connection.Open()
            dr = command.ExecuteReader(CommandBehavior.CloseConnection)
            Return dr
        Catch ex As SqlException
            connection.Close()
            connection.Dispose()
            dr.Close()
            Throw ex
        End Try
    End Function

    Public Shared Sub UpdateUserLoginStats(ByVal intUserID As Integer)
        'Increments the total number of logins field in the database for a specific user
        Dim connection As New SqlConnection
        Dim command As New SqlCommand

        connection = GetConnection()
        command.Connection = connection
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_update_shopping_customer_login"
        command.Parameters.Add(New SqlParameter("@myUserID", SqlDbType.Int))
        command.Parameters("@myUserID").Value = intUserID
        Try
            connection.Open()
            command.ExecuteNonQuery()
        Catch ex As SqlException
            Throw ex
        Finally
            connection.Close()
            connection.Dispose()
        End Try
    End Sub

    Public Shared Function GetElementFamilyList(ByVal intTopicID As Integer, ByVal intPromotionStateID As Integer) As String
        'Gets a listing of all related Parent Elements for a particular topic ID
        'string value is a comma delimited list of values (as returned by the stored procedure)

        Dim connection As New SqlConnection
        Dim command As New SqlCommand
        Dim strResult As String

        connection = GetConnection()
        command.Connection = connection
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_websites_anonuser_climbladder"
        command.Parameters.Add(New SqlParameter("@myArray", SqlDbType.VarChar, 5000))
        command.Parameters("@myArray").Value = intTopicID.ToString
        command.Parameters.Add(New SqlParameter("@myWebSiteID", SqlDbType.Int))
        command.Parameters("@myWebSiteID").Value = System.Configuration.ConfigurationManager.AppSettings("WebSiteID")
        command.Parameters.Add(New SqlParameter("@myWebsiteAccessKey", SqlDbType.UniqueIdentifier))
        command.Parameters("@myWebsiteAccessKey").Value = GetWebSiteAccessKey()
        command.Parameters.Add(New SqlParameter("@myPromotionStateID", SqlDbType.Int))
        command.Parameters("@myPromotionStateID").Value = intPromotionStateID
        Try
            connection.Open()
            strResult = CStr(FixNull(command.ExecuteScalar, GetType(String)))
            Return strResult
        Catch ex As SqlException
            Throw ex
        Finally
            connection.Close()
            connection.Dispose()
        End Try
    End Function

    Public Shared Function GetContentByParentElementID(ByVal intElementID As Integer, ByVal intPromotionStateID As Integer) As DataSet
        'Gets All child elements and data given a Parent Element ID.  Also returns a boolean indicating if the element
        'in the row has other children out there

        Dim connection As New SqlConnection
        Dim command As New SqlCommand
        Dim ds As New DataSet
        Dim da As New SqlDataAdapter

        connection = GetConnection()
        command.Connection = connection
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_websites_anonuser_content_by_parentElementID"
        command.Parameters.Add(New SqlParameter("@myWebSiteID", SqlDbType.Int))
        command.Parameters("@myWebSiteID").Value = System.Configuration.ConfigurationManager.AppSettings("WebSiteID")
        command.Parameters.Add(New SqlParameter("@myWebsiteAccessKey", SqlDbType.UniqueIdentifier))
        command.Parameters("@myWebsiteAccessKey").Value = GetWebSiteAccessKey()
        command.Parameters.Add(New SqlParameter("@myPromotionStateID", SqlDbType.Int))
        command.Parameters("@myPromotionStateID").Value = intPromotionStateID
        command.Parameters.Add(New SqlParameter("@parentElementID", SqlDbType.Int))
        command.Parameters("@parentElementID").Value = intElementID
        da.SelectCommand = command
        Try
            da.Fill(ds)
            Return ds
        Catch ex As SqlException
            Throw ex
        Finally
            da.Dispose()
        End Try
    End Function

    Public Shared Function GetContentByElementID(ByVal intElementID As Integer, ByVal intPromotionStateID As Integer) As DataSet
        'Gets a single record of content information based on the ElementID of the content and the promotion state

        Dim connection As New SqlConnection
        Dim command As New SqlCommand
        Dim ds As New DataSet
        Dim da As New SqlDataAdapter

        connection = GetConnection()
        command.Connection = connection
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_websites_anonuser_content_by_elementID"
        command.Parameters.Add(New SqlParameter("@elementID", SqlDbType.Int))
        command.Parameters("@elementID").Value = intElementID
        command.Parameters.Add(New SqlParameter("@myWebSiteID", SqlDbType.Int))
        command.Parameters("@myWebSiteID").Value = System.Configuration.ConfigurationManager.AppSettings("WebSiteID")
        command.Parameters.Add(New SqlParameter("@myWebsiteAccessKey", SqlDbType.UniqueIdentifier))
        command.Parameters("@myWebsiteAccessKey").Value = GetWebSiteAccessKey()
        command.Parameters.Add(New SqlParameter("@myPromotionStateID", SqlDbType.Int))
        command.Parameters("@myPromotionStateID").Value = intPromotionStateID
        Try
            da.SelectCommand = command
            da.Fill(ds)
            Return ds
        Catch ex As SqlException
            Throw ex
        Finally
            da.Dispose()
        End Try
    End Function

    Public Shared Function GetRepositoryContent(ByVal intTopicID As Integer, ByVal intLanguageID As Integer) As SqlDataReader
        'Gets content directly from the contnet repository based on the topic ID and the language
        'Used for anything where we get content that is NOT published to the web site through the admin tool
        Dim connection As New SqlConnection
        Dim command As New SqlCommand
        Dim dr As SqlDataReader

        connection = GetConnection()
        command.Connection = connection
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_repository_topic_content_by_topicID"
        command.Parameters.Add(New SqlParameter("@myID", SqlDbType.Int))
        command.Parameters("@myID").Value = intTopicID
        command.Parameters.Add(New SqlParameter("@myLangID", SqlDbType.Int))
        command.Parameters("@myLangID").Value = intLanguageID
        Try
            connection.Open()
            dr = command.ExecuteReader(CommandBehavior.CloseConnection)
            Return dr
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Shared Function GetElementIDByTemplate(ByVal strTemplate As String, ByVal intUserID As Integer, ByVal intGroupID As Integer) As SqlDataReader
        Dim connection As New SqlConnection
        Dim command As New SqlCommand
        Dim dr As SqlDataReader

        connection = GetConnection()
        command.Connection = connection
        command.CommandType = CommandType.StoredProcedure
        If intUserID > 0 Then
            command.CommandText = "sp_websites_get_element_ID_by_template_and_user_ID"
            command.Parameters.Add(New SqlParameter("@UserID", SqlDbType.Int))
            command.Parameters("@UserID").Value = intUserID
        Else
            command.CommandText = "sp_websites_get_element_id_by_template_and_group_ID"
            command.Parameters.Add(New SqlParameter("@GroupID", SqlDbType.Int))
            command.Parameters("@GroupID").Value = intGroupID
        End If
        command.Parameters.Add(New SqlParameter("@Scope", SqlDbType.VarChar, 50))
        command.Parameters("@Scope").Value = "WEB.ELEMENT"
        command.Parameters.Add(New SqlParameter("@PrivilegeAction", SqlDbType.VarChar, 100))
        command.Parameters("@PrivilegeAction").Value = "View"
        command.Parameters.Add(New SqlParameter("@TemplateConstant", SqlDbType.VarChar, 50))
        command.Parameters("@TemplateConstant").Value = strTemplate
        Try
            connection.Open()
            dr = command.ExecuteReader(CommandBehavior.CloseConnection)
            Return dr
        Catch ex As Exception
            Throw ex
        End Try
    End Function

    Public Shared Sub UpdateWebSiteClickStream(ByVal intElementID As Integer, ByVal intPromotionStateID As Integer, _
    ByVal intUserID As Integer)
        'Update the click stream data for the TopicID

        Dim connection As New SqlConnection
        Dim command As New SqlCommand

        connection = GetConnection()
        command.Connection = connection
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_websites_update_clickstream"
        command.Parameters.Add(New SqlParameter("@elementID", SqlDbType.Int))
        command.Parameters("@elementID").Value = intElementID
        command.Parameters.Add(New SqlParameter("@webSiteID", SqlDbType.Int))
        command.Parameters("@webSiteID").Value = System.Configuration.ConfigurationManager.AppSettings("WebSiteID")
        command.Parameters.Add(New SqlParameter("@PromotionStateID", SqlDbType.Int))
        command.Parameters("@PromotionStateID").Value = intPromotionStateID
        command.Parameters.Add(New SqlParameter("@userID", SqlDbType.Int))
        command.Parameters("@userID").Value = intUserID
        Try
            connection.Open()
            command.ExecuteNonQuery()
        Catch ex As SqlException
            Throw ex
        Finally
            connection.Close()
            connection.Dispose()
        End Try
    End Sub

    Public Shared Function SearchContent(ByVal strCriteria As String, ByVal intPromotionStateID As Integer, _
    ByVal dteStartDate As DateTime, ByVal dteEndDate As DateTime, ByVal intMaxRows As Integer, _
    ByVal intSortType As Integer, ByVal intStartRow As Integer, ByVal intIncludeHidden As Integer) As DataSet
        'Searches the web site elements for matching criteria and returns results in a dataset
        'supports paging and num rows returned
        'See stored procedure for dteails
        Dim connection As New SqlConnection
        Dim command As New SqlCommand
        Dim da As New SqlDataAdapter
        Dim ds As New DataSet

        connection = GetConnection()
        command.Connection = connection
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_websites_anonuser_search_content"
        command.Parameters.Add(New SqlParameter("@mySearchCriteria", SqlDbType.VarChar, 500))
        command.Parameters("@mySearchCriteria").Value = strCriteria
        command.Parameters.Add(New SqlParameter("@PromotionStateID", SqlDbType.Int))
        command.Parameters("@PromotionStateID").Value = intPromotionStateID
        If dteStartDate <> DateTime.MinValue Then
            command.Parameters.Add(New SqlParameter("@myStartDate", SqlDbType.DateTime))
            command.Parameters("@myStartDate").Value = dteStartDate
        End If
        If dteEndDate <> DateTime.MinValue Then
            command.Parameters.Add(New SqlParameter("@myEndDate", SqlDbType.DateTime))
            command.Parameters("@myEndDate").Value = dteEndDate
        End If
        command.Parameters.Add(New SqlParameter("@maxRows", SqlDbType.Int))
        command.Parameters("@maxRows").Value = intMaxRows
        command.Parameters.Add(New SqlParameter("@sortType", SqlDbType.Int))
        command.Parameters("@sortTYpe").Value = intSortType
        command.Parameters.Add(New SqlParameter("@startRow", SqlDbType.Int))
        command.Parameters("@startRow").Value = intStartRow
        command.Parameters.Add(New SqlParameter("@includeHidden", SqlDbType.Int))
        command.Parameters("@includeHidden").Value = intIncludeHidden
        Try
            da.SelectCommand = command
            da.Fill(ds)
            Return ds
        Catch ex As SqlException
            Throw ex
        Finally
            da.Dispose()
        End Try
    End Function

    Public Shared Function GetCountiesByState(ByVal strState As String) As DataSet
        'Gets a list of counties given a specific state and returns them in a dataset
        'that includes the county_id, the name, and the state abbreviation
        Dim command As New SqlCommand
        Dim da As New SqlDataAdapter
        Dim ds As New DataSet
        Dim connection As New SqlConnection

        connection = GetConnection()
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_get_counties_by_state"
        command.Connection = connection
        command.Parameters.Add(New SqlParameter("@State", SqlDbType.Char, 2))
        command.Parameters("@State").Value = strState
        Try
            da.SelectCommand = command
            da.Fill(ds)
            Return ds
        Catch ex As Exception
            Throw ex
        Finally
            da.Dispose()
        End Try
    End Function

    Public Shared Function AddUser(ByVal strUserName As String, ByVal strPassword As String, ByVal strFirst_Name As String, ByVal strMiddle_Initial As String, _
    ByVal strLast_Name As String, ByVal chrGender As Char, ByVal strEmail_Address As String, ByVal dteBirth_Date As DateTime, ByVal strAddress_1 As String, _
    ByVal strAddress_2 As String, ByVal strCity As String, ByVal strState As String, ByVal strZip As String, ByVal intCounty_ID As Integer, _
    ByVal strHome_Area_Code As String, ByVal strHome_Phone As String, ByVal strAlt_Area_Code As String, ByVal strAlt_Phone As String, _
    ByVal strParent_First_Name As String, ByVal strParent_Last_Name As String, ByVal strParent_Email_Address As String, ByVal strHigh_School As String, _
    ByVal strReferred_by As String, ByVal intBandwith_Preference As Byte, ByVal intAffiliateID As Integer, ByVal bolEmailOptIn As Boolean, ByVal strSSN As String, _
    ByVal strShortReferrer As String, ByVal strLongReferrer As String) As Integer
        'Adds a new user to the database with the appropriate values.  See stored procedure for database schema
        Dim command As New SqlCommand
        Dim connection As New SqlConnection

        connection = GetConnection()
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_shopping_register_user"
        command.Parameters.Add(New SqlParameter("@UserName", SqlDbType.VarChar, 50))
        command.Parameters("@UserName").Value = strUserName
        command.Parameters.Add(New SqlParameter("@Password", SqlDbType.VarChar, 50))
        command.Parameters("@Password").Value = strPassword
        command.Parameters.Add(New SqlParameter("@First_Name", SqlDbType.VarChar, 200))
        command.Parameters("@First_Name").Value = strFirst_Name
        command.Parameters.Add(New SqlParameter("@Middle_Initial", SqlDbType.Char, 1))
        command.Parameters("@Middle_Initial").Value = strMiddle_Initial
        command.Parameters.Add(New SqlParameter("@Last_Name", SqlDbType.VarChar, 200))
        command.Parameters("@Last_Name").Value = strLast_Name
        command.Parameters.Add(New SqlParameter("@Gender", SqlDbType.Char, 1))
        command.Parameters("@Gender").Value = chrGender
        command.Parameters.Add(New SqlParameter("@Email_Address", SqlDbType.VarChar, 200))
        command.Parameters("@Email_Address").Value = strEmail_Address
        command.Parameters.Add(New SqlParameter("@Birth_Date", SqlDbType.DateTime))
        command.Parameters("@Birth_Date").Value = dteBirth_Date
        command.Parameters.Add(New SqlParameter("@Address_1", SqlDbType.VarChar, 200))
        command.Parameters("@Address_1").Value = strAddress_1
        command.Parameters.Add(New SqlParameter("@Address_2", SqlDbType.VarChar, 200))
        command.Parameters("@Address_2").Value = strAddress_2
        command.Parameters.Add(New SqlParameter("@City", SqlDbType.VarChar, 200))
        command.Parameters("@City").Value = strCity
        command.Parameters.Add(New SqlParameter("@State", SqlDbType.Char, 2))
        command.Parameters("@State").Value = strState
        command.Parameters.Add(New SqlParameter("@Zip", SqlDbType.VarChar, 9))
        command.Parameters("@Zip").Value = strZip
        command.Parameters.Add(New SqlParameter("@County_ID", SqlDbType.Int))
        command.Parameters("@County_ID").Value = intCounty_ID
        command.Parameters.Add(New SqlParameter("@Home_Area_Code", SqlDbType.Char, 3))
        command.Parameters("@Home_Area_Code").Value = strHome_Area_Code
        command.Parameters.Add(New SqlParameter("@Home_Phone", SqlDbType.Char, 7))
        command.Parameters("@Home_Phone").Value = strHome_Phone
        command.Parameters.Add(New SqlParameter("@Alt_Area_Code", SqlDbType.Char, 3))
        command.Parameters("@Alt_Area_Code").Value = strAlt_Area_Code
        command.Parameters.Add(New SqlParameter("@Alt_Phone", SqlDbType.Char, 7))
        command.Parameters("@Alt_Phone").Value = strAlt_Phone
        command.Parameters.Add(New SqlParameter("@Parent_First_Name", SqlDbType.VarChar, 200))
        command.Parameters("@Parent_First_Name").Value = strParent_First_Name
        command.Parameters.Add(New SqlParameter("@Parent_Last_Name", SqlDbType.VarChar, 200))
        command.Parameters("@Parent_Last_Name").Value = strParent_Last_Name
        command.Parameters.Add(New SqlParameter("@Parent_Email_Address", SqlDbType.VarChar, 200))
        command.Parameters("@Parent_Email_Address").Value = strParent_Email_Address
        command.Parameters.Add(New SqlParameter("@High_School_Name", SqlDbType.VarChar, 200))
        command.Parameters("@High_School_Name").Value = strHigh_School
        command.Parameters.Add(New SqlParameter("@Referred_By", SqlDbType.VarChar, 200))
        command.Parameters("@Referred_By").Value = strReferred_by
        command.Parameters.Add(New SqlParameter("@Bandwith_Preference", SqlDbType.Bit))
        command.Parameters("@Bandwith_Preference").Value = intBandwith_Preference
        command.Parameters.Add(New SqlParameter("@NewUserID", SqlDbType.Int))
        command.Parameters.Add(New SqlParameter("@AffiliateID", SqlDbType.Int))
        command.Parameters("@AffiliateID").Value = intAffiliateID
        command.Parameters.Add(New SqlParameter("@EmailOptIn", SqlDbType.Bit))
        command.Parameters("@EmailOptIn").Value = bolEmailOptIn
        command.Parameters.Add(New SqlParameter("@SSN", SqlDbType.VarChar, 50))
        command.Parameters("@SSN").Value = strSSN
        command.Parameters.Add(New SqlParameter("@ShortReferrer", SqlDbType.VarChar, 2500))
        command.Parameters("@ShortReferrer").Value = strShortReferrer
        command.Parameters.Add(New SqlParameter("@LongReferrer", SqlDbType.VarChar, 2500))
        command.Parameters("@LongReferrer").Value = strLongReferrer
        command.Parameters("@NewUserID").Direction = ParameterDirection.Output
        Try
            connection.Open()
            command.Connection = connection
            command.ExecuteNonQuery()
            Return CInt(command.Parameters("@NewUserID").Value)
        Catch ex As Exception
            Throw ex
        Finally
            connection.Close()
            connection.Dispose()
        End Try
    End Function

    Public Shared Sub AddUserToGroup(ByVal intUserID As Integer, ByVal strGroup As String)
        'Takes the user id and the state and finds the appropriate group that matches the state,
        'adds the user as a member of that group.  Used when registering users.  It will properly
        'check to make sure the user is not already a member of the group before adding the user.
        Dim command As New SqlCommand
        Dim connection As New SqlConnection

        connection = GetConnection()
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_add_user_to_group"
        command.Parameters.Add(New SqlParameter("@GroupName", SqlDbType.VarChar, 100))
        command.Parameters("@GroupName").Value = strGroup
        command.Parameters.Add(New SqlParameter("@UserID", SqlDbType.Int))
        command.Parameters("@UserID").Value = intUserID
        Try
            connection.Open()
            command.Connection = connection
            command.ExecuteNonQuery()
        Catch ex As Exception
            Throw ex
        Finally
            connection.Close()
            connection.Dispose()
        End Try
    End Sub

    Public Shared Sub RemoveUserFromGroup(ByVal intUserID As Integer, ByVal strGroup As String)
        'Takes the user ID and group name, and if the user is a member of that group
        'removes the user from that group's membership
        Dim command As New SqlCommand
        Dim connection As New SqlConnection

        connection = GetConnection()
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_remove_user_from_group"
        command.Parameters.Add(New SqlParameter("@GroupName", SqlDbType.VarChar, 100))
        command.Parameters("@GroupName").Value = strGroup
        command.Parameters.Add(New SqlParameter("@UserID", SqlDbType.Int))
        command.Parameters("@UserID").Value = intUserID
        Try
            connection.Open()
            command.Connection = connection
            command.ExecuteNonQuery()
        Catch ex As Exception
            Throw ex
        Finally
            connection.Close()
            connection.Dispose()
        End Try
    End Sub

    Public Shared Function GetGroupID(ByVal strGroupName As String) As Integer
        Dim command As New SqlCommand
        Dim connection As New SqlConnection
        Dim intGroupID As Integer

        connection = GetConnection()
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_security_get_group_ID_by_Name"
        command.Parameters.Add(New SqlParameter("@GroupName", SqlDbType.VarChar, 200))
        command.Parameters("@GroupName").Value = strGroupName
        Try
            connection.Open()
            command.Connection = connection
            intGroupID = CInt(command.ExecuteScalar)
            Return intGroupID
        Catch ex As Exception
            Throw ex
        Finally
            connection.Close()
            connection.Dispose()
        End Try
    End Function

    Public Shared Function GetUserInfo(ByVal intUserID As Integer) As SqlDataReader
        'Deprecated method, uses the old security table structure instead of the new security structure
        Dim dr As SqlDataReader
        Dim connection As New SqlConnection
        Dim command As New SqlCommand

        connection = GetConnection()
        command.Connection = connection
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_get_user_info"
        command.Parameters.Add(New SqlParameter("@UserID", SqlDbType.Int))
        command.Parameters("@UserID").Value = intUserID
        Try
            connection.Open()
            dr = command.ExecuteReader(CommandBehavior.CloseConnection)
            Return dr
        Catch ex As Exception
            Throw ex
        Finally
            connection.Close()
            connection.Dispose()
        End Try
    End Function

    Public Shared Sub UpdateUser(ByVal intUserID As Integer, ByVal intShoppingCustomerID As Integer, ByVal strPassword As String, ByVal strFirst_Name As String, ByVal strMiddle_Initial As String, _
ByVal strLast_Name As String, ByVal chrGender As Char, ByVal strEmail_Address As String, ByVal dteBirth_Date As DateTime, ByVal strAddress_1 As String, _
ByVal strAddress_2 As String, ByVal strCity As String, ByVal strState As String, ByVal strZip As String, ByVal intCounty_ID As Integer, _
ByVal strHome_Area_Code As String, ByVal strHome_Phone As String, ByVal strAlt_Area_Code As String, ByVal strAlt_Phone As String, _
ByVal strParent_First_Name As String, ByVal strParent_Last_Name As String, ByVal strParent_Email_Address As String, ByVal strHigh_School As String, _
ByVal intBandwith_Preference As Byte, ByVal SSNNum As String, ByVal bolEmailOptIn As Boolean)
        'Adds a new user to the database with the appropriate values.  See stored procedure for database schema
        Dim command As New SqlCommand
        Dim connection As New SqlConnection

        connection = GetConnection()
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_update_user"
        command.Parameters.Add(New SqlParameter("@UserID", SqlDbType.Int))
        command.Parameters("@UserID").Value = intUserID
        command.Parameters.Add(New SqlParameter("@ShoppingCustomerID", SqlDbType.Int))
        command.Parameters("@ShoppingCustomerID").Value = intShoppingCustomerID
        command.Parameters.Add(New SqlParameter("@Password", SqlDbType.VarChar, 50))
        command.Parameters("@Password").Value = strPassword
        command.Parameters.Add(New SqlParameter("@First_Name", SqlDbType.VarChar, 200))
        command.Parameters("@First_Name").Value = strFirst_Name
        command.Parameters.Add(New SqlParameter("@Middle_Initial", SqlDbType.Char, 1))
        command.Parameters("@Middle_Initial").Value = strMiddle_Initial
        command.Parameters.Add(New SqlParameter("@Last_Name", SqlDbType.VarChar, 200))
        command.Parameters("@Last_Name").Value = strLast_Name
        command.Parameters.Add(New SqlParameter("@Gender", SqlDbType.Char, 1))
        command.Parameters("@Gender").Value = chrGender
        command.Parameters.Add(New SqlParameter("@Email_Address", SqlDbType.VarChar, 200))
        command.Parameters("@Email_Address").Value = strEmail_Address
        command.Parameters.Add(New SqlParameter("@Birth_Date", SqlDbType.DateTime))
        command.Parameters("@Birth_Date").Value = dteBirth_Date
        command.Parameters.Add(New SqlParameter("@Address_1", SqlDbType.VarChar, 200))
        command.Parameters("@Address_1").Value = strAddress_1
        command.Parameters.Add(New SqlParameter("@Address_2", SqlDbType.VarChar, 200))
        command.Parameters("@Address_2").Value = strAddress_2
        command.Parameters.Add(New SqlParameter("@City", SqlDbType.VarChar, 200))
        command.Parameters("@City").Value = strCity
        command.Parameters.Add(New SqlParameter("@State", SqlDbType.Char, 2))
        command.Parameters("@State").Value = strState
        command.Parameters.Add(New SqlParameter("@Zip", SqlDbType.VarChar, 9))
        command.Parameters("@Zip").Value = strZip
        command.Parameters.Add(New SqlParameter("@County_ID", SqlDbType.Int))
        command.Parameters("@County_ID").Value = intCounty_ID
        command.Parameters.Add(New SqlParameter("@Home_Area_Code", SqlDbType.Char, 3))
        command.Parameters("@Home_Area_Code").Value = strHome_Area_Code
        command.Parameters.Add(New SqlParameter("@Home_Phone", SqlDbType.Char, 7))
        command.Parameters("@Home_Phone").Value = strHome_Phone
        command.Parameters.Add(New SqlParameter("@Alt_Area_Code", SqlDbType.Char, 3))
        command.Parameters("@Alt_Area_Code").Value = strAlt_Area_Code
        command.Parameters.Add(New SqlParameter("@Alt_Phone", SqlDbType.Char, 7))
        command.Parameters("@Alt_Phone").Value = strAlt_Phone
        command.Parameters.Add(New SqlParameter("@Parent_First_Name", SqlDbType.VarChar, 200))
        command.Parameters("@Parent_First_Name").Value = strParent_First_Name
        command.Parameters.Add(New SqlParameter("@Parent_Last_Name", SqlDbType.VarChar, 200))
        command.Parameters("@Parent_Last_Name").Value = strParent_Last_Name
        command.Parameters.Add(New SqlParameter("@Parent_Email_Address", SqlDbType.VarChar, 200))
        command.Parameters("@Parent_Email_Address").Value = strParent_Email_Address
        command.Parameters.Add(New SqlParameter("@High_School_Name", SqlDbType.VarChar, 200))
        command.Parameters("@High_School_Name").Value = strHigh_School
        command.Parameters.Add(New SqlParameter("@Bandwith_Preference", SqlDbType.Bit))
        command.Parameters("@Bandwith_Preference").Value = intBandwith_Preference
        command.Parameters.Add(New SqlParameter("@EmailOptIn", SqlDbType.Bit))
        command.Parameters("@EmailOptIn").Value = bolEmailOptIn
        command.Parameters.Add(New SqlParameter("@SSN", SqlDbType.VarChar, 50))
        command.Parameters("@SSN").Value = SSNNum
        Try
            connection.Open()
            command.Connection = connection
            command.ExecuteNonQuery()
        Catch ex As Exception
            Throw ex
        Finally
            connection.Close()
            connection.Dispose()
        End Try
    End Sub

    Public Shared Function GetSecurityUserDetails(ByVal intUserID As Integer) As DataSet
        Dim command As New SqlCommand
        Dim ds As New DataSet
        Dim da As New SqlDataAdapter

        command.Connection = GetConnection()
        command.CommandType = CommandType.StoredProcedure
        command.CommandText = "sp_security_user_details"
        command.Parameters.Add(New SqlParameter("@UserID", SqlDbType.Int))
        command.Parameters("@UserID").Value = intUserID
        Try
            da.SelectCommand = command
            da.Fill(ds)
            Return ds
        Catch ex As Exception
            Throw ex
        Finally
            command.Connection.Close()
            da.Dispose()
        End Try
    End Function

End Class
