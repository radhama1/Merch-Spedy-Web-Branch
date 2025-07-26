Imports System
Imports System.Data

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks.Michaels


Namespace Michaels

    Public Class MichaelsItemHelper

        Public Shared Function CalculateUnitsStoreTotal(ByVal likeItemRegularUnits As Decimal, ByVal storeTotal As Integer, ByVal yearlyForecast As Decimal) As Decimal
            Dim result As Decimal = Decimal.MinValue
            If likeItemRegularUnits <> Decimal.MinValue AndAlso likeItemRegularUnits >= 0 Then
                If storeTotal <> Integer.MinValue AndAlso storeTotal > 0 Then
                    If yearlyForecast <> Decimal.MinValue AndAlso yearlyForecast > 0 Then
                        result = ((yearlyForecast / storeTotal / 52) * 4)
                    Else
                        result = 0.0
                    End If
                Else
                    result = 0.0
                End If
            End If
            Return result
        End Function

        Public Shared Function CalculateYearlyForecast(ByVal likeItemRegularUnits As Decimal, ByVal likeItemSales As Decimal) As Decimal
            Dim result As Decimal = Decimal.MinValue
            If likeItemRegularUnits <> Decimal.MinValue AndAlso likeItemRegularUnits >= 0 Then
                If likeItemSales <> Decimal.MinValue AndAlso likeItemSales >= 0 Then
                    result = likeItemRegularUnits * likeItemSales
                Else
                    result = 0.0
                End If
            End If
            Return result
        End Function

        Public Shared Function CalculateTotalRetail(ByVal yearlyForecast As Decimal, ByVal USRetail As Decimal) As Decimal
            Dim result As Decimal = Decimal.MinValue
            If yearlyForecast <> Decimal.MinValue AndAlso yearlyForecast >= 0 Then
                If USRetail <> Decimal.MinValue Then
                    result = yearlyForecast * USRetail
                Else
                    result = 0.0
                End If
            End If
            Return result
        End Function

    End Class

End Namespace

