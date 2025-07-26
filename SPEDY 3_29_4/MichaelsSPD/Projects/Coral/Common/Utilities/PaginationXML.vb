Imports System.Text

Namespace Utilities

    Public Class PaginationXML

        Private strSortXML As StringBuilder
        Private curSortID As Integer

        Private strFilterXML As StringBuilder
        Private curFilterID As Integer

        Public Sub New()

            strSortXML = New StringBuilder
            curSortID = 0

            strFilterXML = New StringBuilder
            curFilterID = 0

        End Sub

        Public Sub AddSortCriteria(ByVal pColOrdinal As Integer, ByVal pSortType As SortDirection)

            curSortID += 1
            strSortXML.Append("<Parameter SortID=""" & curSortID & """ intColOrdinal=""" & pColOrdinal & """ intDirection=""" & pSortType & """ />")

        End Sub

        Public Function GetSortInnerXMLStr() As String

            Dim retValue As String = ""

            If Not strSortXML Is Nothing Then
                retValue = strSortXML.ToString()
            End If

            Return retValue

        End Function

        Public Sub SetSortInnerXMLStr(ByVal pXMLStr As String)

            If Not strSortXML Is Nothing Then
                strSortXML = New StringBuilder
                strSortXML.Append(pXMLStr)
            End If

        End Sub

        Public Sub AddFilterCriteria(ByVal pColOrdinal As Integer, ByVal pCriteria As String)

            curFilterID += 1
            strFilterXML.Append("<Parameter FilterID=""" & curFilterID & """ intColOrdinal=""" & pColOrdinal & """>" & pCriteria & "</Parameter>")

        End Sub

        Public Function GetFilterInnerXMLStr() As String

            Dim retValue As String = ""

            If Not strFilterXML Is Nothing Then
                retValue = strFilterXML.ToString()
            End If

            Return retValue

        End Function

        Public Sub SetFilterInnerXMLStr(ByVal pXMLStr As String)

            If Not strFilterXML Is Nothing Then
                strFilterXML = New StringBuilder
                strFilterXML.Append(pXMLStr)
            End If

        End Sub


        Public Function GetPaginationXML() As String

            Dim strXML As New StringBuilder

            strXML.Append("<?xml version=""1.0"" encoding=""ISO-8859-1""?>")
            strXML.Append("<Root>")

            'Add Filter(s)
            strXML.Append("<Filter>")
            strXML.Append(GetFilterInnerXMLStr())
            strXML.Append("</Filter>")

            'Add Sorting
            strXML.Append("<Sort>")
            strXML.Append(GetSortInnerXMLStr())
            strXML.Append("</Sort>")

            strXML.Append("</Root>")

            Return strXML.ToString()

        End Function

        Public Shared Function GetSortDirectionString(ByVal pDirection As SortDirection) As String

            Dim returnValue As String = ""

            Select Case pDirection
                Case SortDirection.Asc
                    returnValue = "ASC"
                Case SortDirection.Desc
                    returnValue = "DESC"
            End Select

            Return returnValue

        End Function
        Public Enum SortDirection As Short
            Asc = 0
            Desc = 1
        End Enum

    End Class

End Namespace