
Namespace Michaels

    Public Enum ItemValidationErrors
        None = 0
        ComponentsSameItemTypeAttribute = 1 ' DP
        ComponentsSameStockCategory = 2 ' DP
        'ComponentsSameHybridType = 4 ' DP
        ComponentsSameStockingStrategyCode = 4 ' DP  'reusing 4
        'ComponentsSameHybridSourcingDC = 8 ' DP
        ComponentsSameHierarchyD = 16 ' DP
        ComponentsSameHierarchyC = 32 ' DP
        ComponentsSameHierarchySC = 64 ' DP
        ComponentsSameVendor = 128 ' DP
        DisplayerWarehouseSeasonalW = 256 ' D
        DisplayerWarehouseSeasonalS = 512 'D
        ComponentsMustBeActive = 1024 ' D/DP
        ComponentsSameSkuGroup = 2048 ' D/DP
        ComponentsQtyInPack = 4096 ' D/DP
        DDPActive = 8192 ' D/DP
        MultipleDDP = 16384 ' D/DP
        DuplicateSKU = 32768
        DDPComponentVendors = 65536 ' D/DP Component has to have same vendors as the parent
        DuplicateComponent = 131072 ' D/DP Component already on a different Display Pack
        ComponentsSamePLI = 262144 ' D/DP Component has to have the same PLI as parent
        ComponentsSameTI = 524288 ' D/DP Component has to have the same TI as parent
    End Enum

End Namespace