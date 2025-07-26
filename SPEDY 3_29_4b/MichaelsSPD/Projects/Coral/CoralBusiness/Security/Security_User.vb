Imports System

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NLData = NovaLibra.Coral.Data
Imports NLUtil = NovaLibra.Coral.Data.Utilities

Namespace Security

    '==============================================================================
    ' CLASS: Security_User
    ' Generated using CodeSmith on Friday, October 14, 2005
    ' By ken.wallace
    '==============================================================================
    '
    ' This object represents properties and methods for interacting with 
    ' table DriversEdDirect_Dev.dbo.Security_User.  
    '
    '==============================================================================
    Public Class Security_User
        'Private, class member variable
        Private m_ID As Integer
        Private m_GUID As Guid
        Private m_Email_Address As String
        Private m_UserName As String
        Private m_Password As String
        Private m_Enabled As Boolean
        Private m_Last_Name As String
        Private m_First_Name As String
        Private m_Middle_Name As String
        Private m_Title As String
        Private m_Suffix As String
        Private m_Organization As String
        Private m_Department As String
        Private m_Job_Title As String
        Private m_Office_Location As String
        Private m_Gender As String
        Private m_Language_ID As Integer
        Private m_Comments As String
        Private m_Start_Date As Date
        Private m_End_Date As Date
        Private m_Date_Created As Date
        Private m_Date_Last_Modified As Date
        Private utils As Security_UtilityLibrary

        Public Sub New()
            utils = New Security_UtilityLibrary
        End Sub

        ' ID
        Public Property ID() As Integer
            Get
                Return m_ID
            End Get
            Set(ByVal value As Integer)
                m_ID = value
            End Set
        End Property

        ' GUID
        Public Property GUID() As Guid
            Get
                Return m_GUID
            End Get
            Set(ByVal value As Guid)
                m_GUID = value
            End Set
        End Property

        ' Email_Address
        Public Property Email_Address() As String
            Get
                Return m_Email_Address
            End Get
            Set(ByVal value As String)
                m_Email_Address = value
            End Set
        End Property

        ' UserName
        Public Property UserName() As String
            Get
                Return m_UserName
            End Get
            Set(ByVal value As String)
                m_UserName = value
            End Set
        End Property

        ' Password
        Public Property Password() As String
            Get
                Return m_Password
            End Get
            Set(ByVal value As String)
                m_Password = value
            End Set
        End Property

        ' Enabled
        Public Property Enabled() As Boolean
            Get
                Return m_Enabled
            End Get
            Set(ByVal value As Boolean)
                m_Enabled = value
            End Set
        End Property

        ' Last_Name
        Public Property Last_Name() As String
            Get
                Return m_Last_Name
            End Get
            Set(ByVal value As String)
                m_Last_Name = value
            End Set
        End Property

        ' First_Name
        Public Property First_Name() As String
            Get
                Return m_First_Name
            End Get
            Set(ByVal value As String)
                m_First_Name = value
            End Set
        End Property

        ' Middle_Name
        Public Property Middle_Name() As String
            Get
                Return m_Middle_Name
            End Get
            Set(ByVal value As String)
                m_Middle_Name = value
            End Set
        End Property

        ' Title
        Public Property Title() As String
            Get
                Return m_Title
            End Get
            Set(ByVal value As String)
                m_Title = value
            End Set
        End Property

        ' Suffix
        Public Property Suffix() As String
            Get
                Return m_Suffix
            End Get
            Set(ByVal value As String)
                m_Suffix = value
            End Set
        End Property

        ' Organization 
        Public Property Organization() As String
            Get
                Return m_Organization
            End Get
            Set(ByVal value As String)
                m_Organization = value
            End Set
        End Property

        ' Department
        Public Property Department() As String
            Get
                Return m_Department
            End Get
            Set(ByVal value As String)
                m_Department = value
            End Set
        End Property

        ' Job_Title
        Public Property Job_Title() As String
            Get
                Return m_Job_Title
            End Get
            Set(ByVal value As String)
                m_Job_Title = value
            End Set
        End Property

        ' Office_Location
        Public Property Office_Location() As String
            Get
                Return m_Office_Location
            End Get
            Set(ByVal value As String)
                m_Office_Location = value
            End Set
        End Property

        ' Gender
        Public Property Gender() As String
            Get
                Return m_Gender
            End Get
            Set(ByVal value As String)
                m_Gender = value
            End Set
        End Property

        ' Language_ID
        Public Property Language_ID() As Integer
            Get
                Return m_Language_ID
            End Get
            Set(ByVal value As Integer)
                m_Language_ID = value
            End Set
        End Property

        ' Comments
        Public Property Comments() As String
            Get
                Return m_Comments
            End Get
            Set(ByVal value As String)
                m_Comments = value
            End Set
        End Property

        ' Start_Date
        Public Property Start_Date() As Date
            Get
                Return m_Start_Date
            End Get
            Set(ByVal value As Date)
                m_Start_Date = value
            End Set
        End Property

        ' End_Date
        Public Property End_Date() As Date
            Get
                Return m_End_Date
            End Get
            Set(ByVal value As Date)
                m_End_Date = value
            End Set
        End Property

        ' Date_Created
        Public Property Date_Created() As Date
            Get
                Return m_Date_Created
            End Get
            Set(ByVal value As Date)
                m_Date_Created = value
            End Set
        End Property

        ' Date_Last_Modified
        Public Property Date_Last_Modified() As Date
            Get
                Return m_Date_Last_Modified
            End Get
            Set(ByVal value As Date)
                m_Date_Last_Modified = value
            End Set
        End Property


        'Loads this object's values by loading a record based on the given ID
        Public Function Load(ByVal p_ID As Long)
            Dim SQLStr1 As String
            Dim SQLStr2 As String
            Dim rs As System.Data.SqlClient.SqlDataReader
            Dim objReader As NLData.DBReader
            Dim iCount As Integer = 0
            Dim retID As Integer = 0

            SQLStr1 = "SELECT count(*) FROM Security_User WHERE ID = '0" & p_ID & "' "
            SQLStr2 = "SELECT * FROM Security_User WHERE ID = '0" & p_ID & "'"
            objReader = utils.LoadRSFromDB(SQLStr1 & vbCrLf & SQLStr2)
            rs = objReader.Reader

            If rs.Read() Then
                iCount = rs(0)
            End If
            Select Case iCount
                Case 1
                    If rs.NextResult() AndAlso rs.Read() Then
                        m_ID = DataHelper.SmartValues(rs("ID"), "CInt")
                        m_GUID = DataHelper.SmartValues(rs("GUID"), "GUID")
                        m_Email_Address = DataHelper.SmartValues(rs("Email_Address"), "CStr")
                        m_UserName = DataHelper.SmartValues(rs("UserName"), "CStr")
                        m_Password = DataHelper.SmartValues(rs("Password"), "CStr")
                        m_Enabled = DataHelper.SmartValues(rs("Enabled"), "Boolean")
                        m_Last_Name = DataHelper.SmartValues(rs("Last_Name"), "CStr")
                        m_First_Name = DataHelper.SmartValues(rs("First_Name"), "CStr")
                        m_Middle_Name = DataHelper.SmartValues(rs("Middle_Name"), "CStr")
                        m_Title = DataHelper.SmartValues(rs("Title"), "CStr")
                        m_Suffix = DataHelper.SmartValues(rs("Suffix"), "CStr")
                        m_Organization = DataHelper.SmartValues(rs("Organization"), "CStr")
                        m_Department = DataHelper.SmartValues(rs("Department"), "CStr")
                        m_Job_Title = DataHelper.SmartValues(rs("Job_Title"), "CStr")
                        m_Office_Location = DataHelper.SmartValues(rs("Office_Location"), "CStr")
                        m_Gender = DataHelper.SmartValues(rs("Gender"), "CStr")
                        m_Language_ID = DataHelper.SmartValues(rs("Language_ID"), "CInt")
                        m_Comments = DataHelper.SmartValues(rs("Comments"), "CStr")
                        m_Start_Date = DataHelper.SmartValues(rs("Start_Date"), "CDate")
                        m_End_Date = DataHelper.SmartValues(rs("End_Date"), "CDate")
                        m_Date_Created = DataHelper.SmartValues(rs("Date_Created"), "CDate")
                        m_Date_Last_Modified = DataHelper.SmartValues(rs("Date_Last_Modified"), "CDate")
                        retID = m_ID
                    Else
                        Err.Raise(1002, "Security_User", "Error loading class Security_User [Load]: Item was not found.")
                    End If
                Case -1, 0
                    Err.Raise(1002, "Security_User", "Error loading class Security_User [Load]: Item was not found.")
                Case Else
                    Err.Raise(1003, "Security_User", "Error loading class Security_User [Load]: Item was not unique.")
            End Select
            rs = Nothing
            objReader.Dispose()
            objReader = Nothing
            Return retID
        End Function

        'Loads this object's values by loading a record based on the given GUID
        Public Function LoadFromGUID(ByVal p_GUID) As Integer
            Dim SQLStr1
            Dim SQLStr2
            Dim rs As System.Data.SqlClient.SqlDataReader
            Dim objReader As NLData.DBReader
            Dim iCount As Integer = 0
            Dim retID As Integer

            SQLStr1 = "SELECT COUNT(*) FROM Security_User WHERE GUID = '" & p_GUID.ToString() & "'"
            SQLStr2 = "SELECT * FROM Security_User WHERE GUID = '" & p_GUID.ToString() & "'"
            objReader = utils.LoadRSFromDB(SQLStr1 & vbCrLf & SQLStr2)
            rs = objReader.Reader

            If rs.Read() Then
                iCount = rs(0)
            End If
            Select Case iCount
                Case 1
                    If rs.NextResult() And rs.Read() Then
                        m_ID = DataHelper.SmartValues(rs("ID"), "CInt")
                        m_GUID = DataHelper.SmartValues(rs("GUID"), "CStr")
                        m_Email_Address = DataHelper.SmartValues(rs("Email_Address"), "CStr")
                        m_UserName = DataHelper.SmartValues(rs("UserName"), "CStr")
                        m_Password = DataHelper.SmartValues(rs("Password"), "CStr")
                        m_Enabled = DataHelper.SmartValues(rs("Enabled"), "CBool")
                        m_Last_Name = DataHelper.SmartValues(rs("Last_Name"), "CStr")
                        m_First_Name = DataHelper.SmartValues(rs("First_Name"), "CStr")
                        m_Middle_Name = DataHelper.SmartValues(rs("Middle_Name"), "CStr")
                        m_Title = DataHelper.SmartValues(rs("Title"), "CStr")
                        m_Suffix = DataHelper.SmartValues(rs("Suffix"), "CStr")
                        m_Organization = DataHelper.SmartValues(rs("Organization"), "CStr")
                        m_Department = DataHelper.SmartValues(rs("Department"), "CStr")
                        m_Job_Title = DataHelper.SmartValues(rs("Job_Title"), "CStr")
                        m_Office_Location = DataHelper.SmartValues(rs("Office_Location"), "CStr")
                        m_Gender = DataHelper.SmartValues(rs("Gender"), "CStr")
                        m_Language_ID = DataHelper.SmartValues(rs("Language_ID"), "CInt")
                        m_Comments = DataHelper.SmartValues(rs("Comments"), "CStr")
                        m_Start_Date = DataHelper.SmartValues(rs("Start_Date"), "CDate")
                        m_End_Date = DataHelper.SmartValues(rs("End_Date"), "CDate")
                        m_Date_Created = DataHelper.SmartValues(rs("Date_Created"), "CDate")
                        m_Date_Last_Modified = DataHelper.SmartValues(rs("Date_Last_Modified"), "CDate")
                        retID = m_ID
                    End If
                Case -1, 0
                    'err.raise 2, "cls_Security_User", "Error loading class cls_Security_User [LoadFromGUID]: Item was not found."
                Case Else
                    'err.raise 3, "cls_Security_User", "Error loading class cls_Security_User [LoadFromGUID]: Item was not unique."			
            End Select
            rs.Close()
            rs = Nothing
            objReader.Dispose()
            objReader = Nothing
            Return retID
        End Function

        'Loads this object's values by loading a record based on the given ID and the current security context
        Public Sub LoadFromCurrentContext(ByRef p_CurrentContextXMLObject, ByVal p_ID)
            Dim tempxmldoc As MSXML2.FreeThreadedDOMDocument, tempxmlattribute As MSXML2.FreeThreadedDOMDocument
            tempxmldoc = CreateObject("MSXML2.FreeThreadedDOMDocument")
            tempxmlattribute = CreateObject("MSXML2.FreeThreadedDOMDocument")

            tempxmldoc.async = False
            tempxmldoc.validateOnParse = False
            tempxmldoc.preserveWhiteSpace = True
            tempxmldoc.resolveExternals = False
            tempxmldoc.load(p_CurrentContextXMLObject)

            If tempxmldoc.selectNodes("//Security_User[@ID = '" & CStr(p_ID) & "']").length > 0 Then
                For Each tempxmlattribute In tempxmldoc.selectSingleNode("//Security_User[@ID = '" & CStr(p_ID) & "']").attributes
                    'Response.Write tempxmlattribute.nodeName & ": " & tempxmlattribute.nodeValue & "<br>"
                    If tempxmlattribute.nodeName = "ID" Then m_ID = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CInt")
                    If tempxmlattribute.nodeName = "GUID" Then m_GUID = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CStr")
                    If tempxmlattribute.nodeName = "Email_Address" Then m_Email_Address = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CStr")
                    If tempxmlattribute.nodeName = "UserName" Then m_UserName = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CStr")
                    If tempxmlattribute.nodeName = "Password" Then m_Password = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CStr")
                    If tempxmlattribute.nodeName = "Enabled" Then m_Enabled = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CBool")
                    If tempxmlattribute.nodeName = "Last_Name" Then m_Last_Name = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CStr")
                    If tempxmlattribute.nodeName = "First_Name" Then m_First_Name = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CStr")
                    If tempxmlattribute.nodeName = "Middle_Name" Then m_Middle_Name = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CStr")
                    If tempxmlattribute.nodeName = "Title" Then m_Title = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CStr")
                    If tempxmlattribute.nodeName = "Suffix" Then m_Suffix = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CStr")
                    If tempxmlattribute.nodeName = "Organization" Then m_Organization = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CStr")
                    If tempxmlattribute.nodeName = "Department" Then m_Department = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CStr")
                    If tempxmlattribute.nodeName = "Job_Title" Then m_Job_Title = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CStr")
                    If tempxmlattribute.nodeName = "Office_Location" Then m_Office_Location = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CStr")
                    If tempxmlattribute.nodeName = "Gender" Then m_Gender = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CStr")
                    If tempxmlattribute.nodeName = "Language_ID" Then m_Language_ID = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CInt")
                    If tempxmlattribute.nodeName = "Comments" Then m_Comments = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CStr")
                    If tempxmlattribute.nodeName = "Start_Date" Then m_Start_Date = DataHelper.SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
                    If tempxmlattribute.nodeName = "End_Date" Then m_End_Date = DataHelper.SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
                    If tempxmlattribute.nodeName = "Date_Created" Then m_Date_Created = DataHelper.SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
                    If tempxmlattribute.nodeName = "Date_Last_Modified" Then m_Date_Last_Modified = DataHelper.SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
                Next
            End If

            tempxmldoc = Nothing
            tempxmlattribute = Nothing
        End Sub

        Public Function Save()
            Dim SQLStr As String

            SQLStr = "sp_Security_User_InsertUpdate "
            SQLStr = SQLStr & " @ID = " & m_ID & ", "
            SQLStr = SQLStr & " @Email_Address = " & m_Email_Address & ", "
            SQLStr = SQLStr & " @UserName = " & m_UserName & ", "
            SQLStr = SQLStr & " @Password = " & m_Password & ", "
            SQLStr = SQLStr & " @Enabled = " & m_Enabled & ", "
            SQLStr = SQLStr & " @Last_Name = " & m_Last_Name & ", "
            SQLStr = SQLStr & " @First_Name = " & m_First_Name & ", "
            SQLStr = SQLStr & " @Middle_Name = " & m_Middle_Name & ", "
            SQLStr = SQLStr & " @Title = " & m_Title & ", "
            SQLStr = SQLStr & " @Suffix = " & m_Suffix & ", "
            SQLStr = SQLStr & " @Organization = " & m_Organization & ", "
            SQLStr = SQLStr & " @Department = " & m_Department & ", "
            SQLStr = SQLStr & " @Job_Title = " & m_Job_Title & ", "
            SQLStr = SQLStr & " @Office_Location = " & m_Office_Location & ", "
            SQLStr = SQLStr & " @Gender = " & m_Gender & ", "
            SQLStr = SQLStr & " @Language_ID = " & m_Language_ID & ", "
            SQLStr = SQLStr & " @Comments = " & m_Comments & ", "
            SQLStr = SQLStr & " @Start_Date = " & m_Start_Date & ", "
            SQLStr = SQLStr & " @End_Date = " & m_End_Date & ", "
            SQLStr = SQLStr & " @Date_Created = " & m_Date_Created & ", "
            SQLStr = SQLStr & " @Date_Last_Modified = " & m_Date_Last_Modified & ", "
            SQLStr = SQLStr & " " & m_ID & " OUTPUT "

            utils.LoadRSFromDB(SQLStr)
            Return m_ID
        End Function

        Public Sub Delete()
            Dim SQLStr As String
            SQLStr = "DELETE FROM Security_User WHERE [ID] = '0" & CLng(m_ID) & "'"
            utils.RunSQL(SQLStr)
        End Sub

        Protected Overrides Sub Finalize()
            utils = Nothing
            MyBase.Finalize()
        End Sub
    End Class

End Namespace
