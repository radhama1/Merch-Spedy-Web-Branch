
Namespace Michaels

    Public Enum ItemFileType
        Image = 0
        MSDS = 1
    End Enum

    Public Class ItemFileTypeHelper
        Public Shared Function GetFileTypeString(ByVal fileType As ItemFileType) As String
            Select Case fileType
                Case ItemFileType.Image
                    Return "IMG"
                Case ItemFileType.MSDS
                    Return "MSDS"
                Case Else
                    Return String.Empty
            End Select
        End Function
    End Class

End Namespace