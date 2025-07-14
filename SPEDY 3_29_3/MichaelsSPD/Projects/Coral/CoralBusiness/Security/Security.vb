Imports System
Imports System.Data

Imports NovaLibra.Common

Imports MSXML2
Imports Scripting

Namespace Security

    '==============================================================================
    ' CLASS: cls_Security
    ' Created Friday, September 08, 2005
    ' By ken.wallace
    '==============================================================================
    '
    ' This object represents properties and methods for interacting with 
    ' the Security super class
    '
    '==============================================================================
    Public Class Security
        Implements IDisposable

        'Private, class member variables	
        Private m_CurrentUserID As Integer  'The Current User's ID
        Private m_CurrentUserGUID As Guid  'The Current User's Globally Unique Identifier
        Private m_CurrentScopeConstant As String  'The string constant of the current scope (where applicable).
        Private m_CurrentPrivilegedObjectID As Integer  'The ID of the current object (where applicable).
        Private m_xml As String  'String representation of the Security XML object
        Private m_objSecurityXML As MSXML2.FreeThreadedDOMDocument 'The Security XML object
        Private m_Groups As Scripting.Dictionary
        Private utils As Security_UtilityLibrary

        Protected disposed As Boolean = False

        Public Sub New()
            m_objSecurityXML = CreateObject("MSXML2.FreeThreadedDOMDocument")
            m_Groups = CreateObject("Scripting.Dictionary")
            utils = New Security_UtilityLibrary()
        End Sub


        ' CurrentUserID 
        Public Property CurrentUserID() As Integer
            Get
                Return m_CurrentUserID
            End Get
            Set(ByVal value As Integer)
                m_CurrentUserID = value
            End Set
        End Property

        ' CurrentUserGUID 
        Public Property CurrentUserGUID() As Guid
            Get
                Return m_CurrentUserGUID
            End Get
            Set(ByVal value As Guid)
                m_CurrentUserGUID = value
                m_CurrentUserID = resolveUserIDFromGUID()
            End Set
        End Property

        ' CurrentScopeConstant
        Public Property CurrentScopeConstant() As String
            Get
                Return m_CurrentScopeConstant
            End Get
            Set(ByVal value As String)
                m_CurrentScopeConstant = value
            End Set
        End Property

        ' CurrentPrivilegedObjectID
        Public Property CurrentPrivilegedObjectID() As Integer
            Get
                Return m_CurrentPrivilegedObjectID
            End Get
            Set(ByVal value As Integer)
                m_CurrentPrivilegedObjectID = value
            End Set
        End Property

        ' XMLObject
        Public ReadOnly Property XMLObject() As Object
            Get
                Return m_objSecurityXML
            End Get
        End Property

        ' XMLSource
        Public Property XMLSource() As String
            Get
                Return m_xml
            End Get
            Set(ByVal value As String)
                m_xml = value
            End Set
        End Property

        'Get the Groups Collection
        Public ReadOnly Property Groups() As Object
            Get
                Return m_Groups
            End Get
        End Property

        Public Sub Initialize(ByVal p_CurrentUserID As Integer, ByVal p_CurrentScopeConstant As String, ByVal p_CurrentPrivilegedObjectID As Integer)
            m_CurrentUserID = p_CurrentUserID
            m_CurrentScopeConstant = p_CurrentScopeConstant
            m_CurrentPrivilegedObjectID = p_CurrentPrivilegedObjectID
            Load()
        End Sub

        Public Function isRequestedScopeAllowed(ByVal Requested_Scope_Constant As String)
            Dim retValue As Boolean = False

            If m_objSecurityXML.selectNodes("//Security_Scope[@Constant = '" & Requested_Scope_Constant & "']").length > 0 Then
                retValue = True
            End If

            If Not retValue Then retValue = isSystemAdministrator()
            Return retValue
        End Function

        Public Function isRequestedPrivilegeAllowed(ByVal Requested_Scope_Constant As String, ByVal Requested_Privilege_Constant As String)
            Dim retValue As Boolean = False

            If m_objSecurityXML.selectNodes("//Security_Privilege[@Constant = '" & Requested_Privilege_Constant & "']/Security_Scope[@Constant = '" & Requested_Scope_Constant & "']").length > 0 Then
                retValue = True
            End If

            If Not retValue Then retValue = isSystemAdministrator()
            Return retValue
        End Function

        Public Function isRequestedPrivilegeAllowedWithinCurrentContext(ByVal Requested_Privilege_Constant As String)
            Return isRequestedPrivilegeAllowed(m_CurrentScopeConstant, Requested_Privilege_Constant)
        End Function

        Public Function isRequestedAccessToObjectAllowed(ByVal Requested_Scope_Constant As String, ByVal Requested_Privilege_Constant As String, ByVal Requested_Object_ID As String)
            Dim retValue As Boolean = False

            If m_objSecurityXML.selectNodes("//Security_Privileged_Objects/Security_Privileged_Object[@Secured_Object_ID = '" & Requested_Object_ID & "']/Security_Privilege[@Constant = '" & Requested_Privilege_Constant & "']/Security_Scope[@Constant = '" & Requested_Scope_Constant & "']").length > 0 Then
                retValue = True
            End If

            If Not retValue Then retValue = isSystemAdministrator()
            Return retValue
        End Function

        Public Function isRequestedAccessToObjectAllowedWithinCurrentContext(ByVal Requested_Privilege_Constant As String, ByVal Requested_Object_ID As String)
            Return isRequestedAccessToObjectAllowed(m_CurrentScopeConstant, Requested_Privilege_Constant, Requested_Object_ID)
        End Function

        Public Function isSystemAdministrator()
            Dim retValue As Boolean = False

            If m_objSecurityXML.selectNodes("//Security_Group[@System_Role = '1']").length > 0 Then
                retValue = True
            End If

            Return retValue
        End Function

        Public Sub Load()
            LoadCurrentContextFromDB()
            m_CurrentUserGUID = resolveUserGUIDFromID()
            LoadAllGroups()
            m_xml = m_objSecurityXML.xml
        End Sub

        Public Sub Clear()
            m_objSecurityXML = Nothing
            m_Groups.RemoveAll()
            CurrentUserID = ""
            CurrentUserGUID = Guid.Empty
            CurrentScopeConstant = ""
            CurrentPrivilegedObjectID = ""
            XMLSource = ""
        End Sub

        Public Sub saveXMLToFile(ByVal p_FilePath As String)
            m_objSecurityXML.save(p_FilePath)
        End Sub

        Private Function resolveUserGUIDFromID() As Guid
            Dim retGUID = Guid.Empty
            If Trim(m_CurrentUserID) <> "" And IsNumeric(m_CurrentUserID) Then
                If m_CurrentUserID > 0 Then
                    Dim tmpSecurityUser As New Security_User
                    tmpSecurityUser.Load(m_CurrentUserID)
                    retGUID = tmpSecurityUser.GUID
                    tmpSecurityUser = Nothing
                End If
            End If
            Return retGUID
        End Function

        Private Function resolveUserIDFromGUID() As Long
            Dim retLong As Long = 0
            If m_CurrentUserGUID.ToString().Trim().Length > 0 Then
                Dim tmpSecurityUser As New Security_User
                retLong = tmpSecurityUser.LoadFromGUID(m_CurrentUserGUID)
                tmpSecurityUser = Nothing
            End If
            Return retLong
        End Function

        Private Sub LoadCurrentContextFromDB()
            Dim SQLStr As String

            m_objSecurityXML.async = False
            m_objSecurityXML.validateOnParse = False
            m_objSecurityXML.preserveWhiteSpace = True
            m_objSecurityXML.resolveExternals = False
            m_objSecurityXML.loadXML("<?xml version='1.0'?><Root></Root>")

            If Trim(m_CurrentUserID) <> "" And IsNumeric(m_CurrentUserID) Then
                If m_CurrentUserID > 0 Then
                    SQLStr = "SELECT Security_User.* FROM Security_User WHERE Security_User.[ID] = '0" & m_CurrentUserID & "' FOR XML AUTO"
                    m_objSecurityXML.selectSingleNode("//Root").appendChild(utils.loadXMLFromRS(SQLStr, "Security_User").selectSingleNode("//Security_User[@ID=" & m_CurrentUserID & "]"))

                    SQLStr = "sp_security_generate_securitycontextxmldoc_securitygroups_by_UserID '0" & m_CurrentUserID & "', 1"
                    m_objSecurityXML.selectSingleNode("//Security_User").appendChild(utils.loadXMLFromRS(SQLStr, "Security_Groups").selectSingleNode("*"))

                    SQLStr = "sp_security_generate_securitycontextxmldoc_by_UserID '0" & m_CurrentUserID & "'"
                    m_objSecurityXML.selectSingleNode("//Security_User").appendChild(utils.loadXMLFromRS(SQLStr, "Security_Privileges").selectSingleNode("*"))

                    SQLStr = "sp_security_generate_securitycontextxmldoc_privilegedobjects_by_UserID '0" & m_CurrentUserID & "'"
                    m_objSecurityXML.selectSingleNode("//Security_User").appendChild(utils.loadXMLFromRS(SQLStr, "Security_Privileged_Objects").selectSingleNode("*"))
                End If
            End If

        End Sub

        Private Sub LoadAllGroups()
            Dim tmpnode As Object, tmpxmlattribute As Object 'MSXML2.FreeThreadedDOMDocument
            Dim tmpSecurityGroup As Security_Group

            tmpnode = CreateObject("MSXML2.FreeThreadedDOMDocument")
            tmpxmlattribute = CreateObject("MSXML2.FreeThreadedDOMDocument")

            If m_objSecurityXML.selectNodes("//Security_Groups").length > 0 Then
                For Each tmpnode In m_objSecurityXML.selectNodes("//Security_Groups/*")
                    tmpSecurityGroup = New Security_Group
                    tmpSecurityGroup.LoadFromCurrentContext(m_objSecurityXML, tmpnode.getAttribute("ID"))
                    m_Groups.Add(tmpnode.getAttribute("ID"), tmpSecurityGroup)
                    tmpSecurityGroup = Nothing
                Next
            End If

            tmpnode = Nothing
            tmpxmlattribute = Nothing

        End Sub

        Protected Overridable Sub Dispose(ByVal disposing As Boolean)
            If Not Me.disposed Then
                If disposing Then
                    ' Insert code to free unmanaged resources.
                    m_objSecurityXML = Nothing
                    m_Groups = Nothing

                End If
                ' Insert code to free shared resources.
                utils = Nothing
            End If
            Me.disposed = True
        End Sub

        Public Sub Dispose() Implements IDisposable.Dispose
            Dispose(True)
            GC.SuppressFinalize(Me)
        End Sub

        Protected Overrides Sub Finalize()
            Dispose(False)
            MyBase.Finalize()
        End Sub

    End Class

End Namespace
