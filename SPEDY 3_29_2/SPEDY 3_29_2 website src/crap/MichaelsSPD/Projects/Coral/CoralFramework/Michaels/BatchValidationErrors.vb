
Namespace Michaels

    Public Enum BatchValidationErrors
        None = 0
        DDPMultipleParents = 1
        DDPNoComponents = 2
        DDPMissingParent = 4
        DDPMissingTypes = 8
        DDPComponentsNotActive = 16
        DDPPackCost1NotEqual = 32
        DDPPackCost2NotEqual = 64
        DDPSameSKUGroup = 128 ' DP ONLY
        DPComponentsSameItemTypeAttribute = 256
        DPComponentsSameStockCategory = 512
        'DPComponentsSameHybridInfo = 1024
        DPComponentsSameStockingStrategyCode = 1024 ' reusing 1024
        DPSamePrimaryVendor = 2048
        DPComponentsSameHierarchy = 4096
        NoItems = 8192 ' IM
        NoChanges = 16384 ' IM
        DDPComponentQtyZero = 32768 ' IM
        DuplicateSKU = 65536
        SKUGroupRules = 131072 'D ONLY 
        DDPMasterCaseWeightNotEqual = 262144
    End Enum

End Namespace

