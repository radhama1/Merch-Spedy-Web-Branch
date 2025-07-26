Imports System
Imports System.DateTime

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NLData = NovaLibra.Coral.Data

Imports MSXML2
Imports Scripting

Namespace Security

    '==============================================================================
    ' CLASS: Security_Group
    ' Generated using CodeSmith on Thursday, September 08, 2005
    ' By ken.wallace
    '==============================================================================
    '
    ' This object represents properties and methods for interacting with 
    ' table DriversEdDirect_Dev.dbo.Security_Group.  
    '
    '==============================================================================
    Public Class Security_Group
        'Private, class member variable
        Private m_ID As Integer
        Private m_Group_Name As String
        Private m_Group_Summary As String
        Private m_Is_Role As Boolean
        Private m_System_Role As Boolean
        Private m_SortOrder As String
        Private m_Start_Date As Date
        Private m_End_Date As Date
        Private m_Date_Last_Modified As Date
        Private m_Date_Created As Date
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

        ' Group_Name
        Public Property Group_Name() As String
            Get
                Return m_Group_Name
            End Get
            Set(ByVal value As String)
                m_Group_Name = value
            End Set
        End Property

        ' Group_Summary
        Public Property Group_Summary() As String
            Get
                Return m_Group_Summary
            End Get
            Set(ByVal value As String)
                m_Group_Summary = value
            End Set
        End Property

        ' Is_Role
        Public Property Is_Role() As Boolean
            Get
                Return m_Is_Role
            End Get
            Set(ByVal value As Boolean)
                m_Is_Role = value
            End Set
        End Property

        ' System_Role
        Public Property System_Role() As Boolean
            Get
                Return m_System_Role
            End Get
            Set(ByVal value As Boolean)
                m_System_Role = value
            End Set
        End Property

        ' SortOrder 
        Public Property SortOrder() As String
            Get
                Return m_SortOrder
            End Get
            Set(ByVal value As String)
                m_SortOrder = value
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

        ' Date_Last_Modified
        Public Property Date_Last_Modified() As Date
            Get
                Return m_Date_Last_Modified
            End Get
            Set(ByVal value As Date)
                m_Date_Last_Modified = value
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

        'Loads this object's values by loading a record based on the given ID
        Public Function Load(ByVal p_ID)
            Dim SQLStr1 As String
            Dim SQLStr2 As String
            Dim rs As System.Data.SqlClient.SqlDataReader
            Dim objReader As NLData.DBReader
            Dim iCount As Integer = 0
            Dim retID As Integer = 0

            SQLStr1 = "SELECT * FROM Security_Group WHERE ID = '0" & p_ID & "'"
            SQLStr2 = "SELECT * FROM Security_Group WHERE ID = '0" & p_ID & "'"
            objReader = utils.LoadRSFromDB(SQLStr1 & vbCrLf & SQLStr2)
            rs = objReader.reader

            If rs.Read() Then
                iCount = rs(0)
            End If
            Select Case iCount
                Case 1
                    If rs.NextResult() And rs.Read() Then
                        m_ID = DataHelper.SmartValues(rs("ID"), "CInt")
                        m_Group_Name = DataHelper.SmartValues(rs("Group_Name"), "CStr")
                        m_Group_Summary = DataHelper.SmartValues(rs("Group_Summary"), "CStr")
                        m_Is_Role = DataHelper.SmartValues(rs("Is_Role"), "CBool")
                        m_System_Role = DataHelper.SmartValues(rs("System_Role"), "CBool")
                        m_SortOrder = DataHelper.SmartValues(rs("SortOrder"), "CStr")
                        m_Start_Date = DataHelper.SmartValues(rs("Start_Date"), "CDate")
                        m_End_Date = DataHelper.SmartValues(rs("End_Date"), "CDate")
                        m_Date_Last_Modified = DataHelper.SmartValues(rs("Date_Last_Modified"), "CDate")
                        m_Date_Created = DataHelper.SmartValues(rs("Date_Created"), "CDate")
                        retID = m_ID
                    Else
                        Err.Raise(2, "Security_Group", "Error loading class cls_Security_Group [Load]: Item was not found.")
                    End If
                Case -1, 0
                    Err.Raise(2, "Security_Group", "Error loading class cls_Security_Group [Load]: Item was not found.")
                Case Else
                    Err.Raise(3, "Security_Group", "Error loading class cls_Security_Group [Load]: Item was not unique.")
            End Select

            rs.Close()
            rs = Nothing
            objReader.Dispose()
            objReader = Nothing

            Return retID
        End Function

        'Loads this object's values by loading a record based on the given ID and the current security context
        Public Sub LoadFromCurrentContext(ByRef p_CurrentContextXMLObject As Object, ByVal p_ID As Integer)
            Dim tempxmldoc As Object, tempxmlattribute As Object 'MSXML2.FreeThreadedDOMDocument
            tempxmldoc = CreateObject("MSXML2.FreeThreadedDOMDocument")
            'tempxmlattribute = CreateObject("MSXML2.FreeThreadedDOMDocument")

            tempxmldoc.async = False
            tempxmldoc.validateOnParse = False
            tempxmldoc.preserveWhiteSpace = True
            tempxmldoc.resolveExternals = False
            tempxmldoc.load(p_CurrentContextXMLObject)

            If tempxmldoc.selectNodes("//Security_Group[@ID = '" & CStr(p_ID) & "']").length > 0 Then

                For Each tempxmlattribute In tempxmldoc.selectSingleNode("//Security_Group[@ID = '" & CStr(p_ID) & "']").attributes
                    'Response.Write tempxmlattribute.nodeName & ": " & tempxmlattribute.nodeValue & "<br>"
                    If tempxmlattribute.nodeName = "ID" Then m_ID = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CInt")
                    If tempxmlattribute.nodeName = "Group_Name" Then m_Group_Name = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CStr")
                    If tempxmlattribute.nodeName = "Group_Summary" Then m_Group_Summary = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CStr")
                    If tempxmlattribute.nodeName = "Is_Role" Then m_Is_Role = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CBool")
                    If tempxmlattribute.nodeName = "System_Role" Then m_System_Role = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CBool")
                    If tempxmlattribute.nodeName = "SortOrder" Then m_SortOrder = DataHelper.SmartValues(tempxmlattribute.nodeValue, "CStr")
                    If tempxmlattribute.nodeName = "Start_Date" Then m_Start_Date = DataHelper.SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
                    If tempxmlattribute.nodeName = "End_Date" Then m_End_Date = DataHelper.SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
                    If tempxmlattribute.nodeName = "Date_Last_Modified" Then m_Date_Last_Modified = DataHelper.SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
                    If tempxmlattribute.nodeName = "Date_Created" Then m_Date_Created = DataHelper.SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
                Next

            End If

            tempxmldoc = Nothing
            tempxmlattribute = Nothing
        End Sub

        Public Function Save()
            Dim SQLStr As String
            SQLStr = "sp_Security_Group_InsertUpdate "
            SQLStr = SQLStr & " @ID = " & m_ID & ", "
            SQLStr = SQLStr & " @Group_Name = " & m_Group_Name & ", "
            SQLStr = SQLStr & " @Group_Summary = " & m_Group_Summary & ", "
            SQLStr = SQLStr & " @Is_Role = " & m_Is_Role & ", "
            SQLStr = SQLStr & " @System_Role = " & m_System_Role & ", "
            SQLStr = SQLStr & " @SortOrder = " & m_SortOrder & ", "
            SQLStr = SQLStr & " @Start_Date = " & m_Start_Date & ", "
            SQLStr = SQLStr & " @End_Date = " & m_End_Date & ", "
            SQLStr = SQLStr & " @Date_Last_Modified = " & m_Date_Last_Modified & ", "
            SQLStr = SQLStr & " @Date_Created = " & m_Date_Created & ", "
            SQLStr = SQLStr & " " & m_ID & " OUTPUT "
            utils.LoadRSFromDB(SQLStr)
            Return m_ID
        End Function

        Public Sub Delete()
            Dim SQLStr As String
            SQLStr = "DELETE FROM Security_Group WHERE [ID] = '0" & CLng(m_ID) & "'"
            utils.RunSQL(SQLStr)
        End Sub

        Protected Overrides Sub Finalize()
            utils = Nothing
            MyBase.Finalize()
        End Sub
    End Class

End Namespace
