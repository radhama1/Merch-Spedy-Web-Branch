
Namespace Michaels

    Public Enum ItemType
        Unknown = 0
        Domestic = 1
        Import = 2
    End Enum

    Public Class ItemTypeString

        Public Const ITEM_TYPE_IMPORT As String = "I"
        Public Const ITEM_TYPE_DOMESTIC As String = "D"

        Public Function GetTypeFromString(ByVal value As String) As ItemType
            If value = ITEM_TYPE_DOMESTIC Then
                Return ItemType.Domestic
            ElseIf value = ITEM_TYPE_IMPORT Then
                Return ItemType.Import
            Else
                Return ItemType.Unknown
            End If
        End Function

        Public Function GetStringFromType(ByVal value As ItemType) As String
            If value = ItemType.Domestic Then
                Return ITEM_TYPE_DOMESTIC
            ElseIf value = ItemType.Import Then
                Return ITEM_TYPE_IMPORT
            Else
                Return String.Empty
            End If
        End Function

    End Class

End Namespace