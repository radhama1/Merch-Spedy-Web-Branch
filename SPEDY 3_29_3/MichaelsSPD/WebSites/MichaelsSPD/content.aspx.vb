Imports CORALPresentation

Public Class content
    Inherits Page

    ' Public Content As DisplayContent
    'Public LeftNav As LeftNav
    'Public PortalContent As PortalContent
    Public bolClose As Boolean
    Public bolFooter As Boolean

    Private Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        Dim intTopicID As Integer
        Dim myCORALSecurity As New CORALSecurity

        myCORALSecurity.InitializeSite()

        intTopicID = CInt(Request("tid"))

        If Not Request("close") Is Nothing Then
            If CBool(Request("close")) = True Then
                bolClose = True
            End If
        End If

        If Not Request("footer") Is Nothing Then
            If CBool(Request("footer")) = True Then
                bolFooter = True
            End If
        End If

        Content.TopicID = intTopicID
        Content.UserID = CInt(Session("User_ID"))

        LeftNav.TopicID = intTopicID

        PortalContent.RootID = intTopicID

    End Sub

End Class
