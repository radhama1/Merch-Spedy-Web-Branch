Imports Microsoft.VisualBasic

Public Class WebConstants

    ' App Constants
    Public Const APP_NAME As String = "Michaels Web Application"

    ' ----------- APP_VERSION ------------------------------------------------------------------------
    ' ---------------------------------------------- APP_VERSION -------------------------------------
    ' ------------------------------------------------------------------------------------------------
    ' * PLEASE UPDATE THIS BEFORE PUSHING ANY TYPE OF BUILD (DEVELOPMENT, TEST, PRODUCTION).  THANKS !
    ' Recent Changes
    ' Essaki, sometime in June2021 3.24.5 - added GTIN
    ' KH in March 2022 3.24.6 - finalized GTIN functionality
    ' KH in June 2022 3.24.7 - added SeasonCode field for POs
    ' KH in Aug 2022 3.25.0 - improved support for non IE browsers, reskin
    ' KH in Oct 2022 3.26.0 - fixes for non IE browsers
    ' KH in Sept 2023 3.27.0 - import burden calculation removed, CoinBattery field added.
    ' KH in Sept 2023 3.27.1 - import burden calculations restored, CoinBattery field added.
    ' KH and MWM in DEC 2023 3.27.2 - Dimensions should be 4 decimal places.
    ' MWM APR 29th 2024 - changing to PHYTO first with out LCR
    ' MWM SEPT 2024 Removing GTIN functionality, remove TSSA, add Reese's Law, add Product ID's as Cosmetic, add UPC to fast sheet, disable old forms
    ' KH 2025-04-09 3.29.1 - rewrote login page to use recordsets instead of readers in order to work with TLS 1.2 and encrypted traffic
    ' KH 2025-05-21 3.29.2 - added support for SB as new pack type along with existing D, DP
    ' KH 2025-07-14 3.29.3 - fix for component english descriptions
    ' KH 2025-07-22 3.29.4 - fix for SB components with varying vendors
    ' KH 2025-10-15 3.29.5 - fix for new SB items with mix of import/domestic components and varying vendors


    Public Const APP_VERSION As String = "Version 3.29.5"
    ' ------------------------------------------------------------------------------------------------
    ' ------------------------------------------------------------------------------ APP_VERSION -----
    ' ------------------------------------- APP_VERSION ----------------------------------------------

    Public Const APP_PATH_REPLACE As String = "{{APP-PATH}}"

    ' Session Constants
    Public Const SESSION_CURRENT_USER As String = ""

    ' Security Constants
    Public Const APP_ADMIN_SCOPE As String = "ADMIN"
    Public Const APP_ADMIN_PRIVILEGE As String = "ADMINACCESS"

    ' Application level Session variables
    Public Const cAPPMESSAGE As String = "SPDAppMessage"
    Public Const cUSERID As String = "UserID"
    Public Const cVENDORID As String = "vendorId"
    Public Const cFIRSTNAME As String = "First_Name"
    Public Const cLASTNAME As String = "Last_Name"
    Public Const cEMAIL As String = "Email_Address"
    Public Const cORG As String = "Organization"
    Public Const cUSERROLE As String = "UserRole"
    Public Const cUSERDEPT As String = "UserDept"

    Public Const cADMINDBCQA As String = "_isAdminDBCQA"
    Public Const cTAXMGR As String = "_isTaxMgr"
    Public Const cIMPORTMGR As String = "_isImportMgr"
    Public Const cVENDORRELATION As String = "_isVendorRelation"
    Public Const cBATCHPERPAGE As String = "_BatchesPerPage"


    Public Const cBATCHID As String = "_BatchID"
    Public Const cIMITEMID As String = "_IMItemID"
    Public Const cHEADERID As String = "_HeaderID"

    ' Page Redirects and currentTab constants
    ' Session variables
    Public Const CURRENTTAB As String = "_CurrentTab"
    Public Const TABSVISBLE As String = "_TabsVisible"

    ' Make sure these Bit map 1 2 4 8 16 32 etc
    Public Const NEWITEM As Integer = 1
    Public Const ITEMMAINT As Integer = 2
    Public Const PONEW As Integer = 4
    Public Const POMAINT As Integer = 8
    Public Const TRILINGUALMAINT As Integer = 16
    Public Const BULKITEMMAINT As Integer = 32

    Public Const NEWITEM_PAGE As String = "NewItem.aspx"
    Public Const ITEMMAINT_PAGE As String = "ItemMaint.aspx"
    Public Const PONEW_PAGE As String = "POCreation.aspx"
    Public Const POMAINT_PAGE As String = "POMaint.aspx"
    Public Const TRILINGUALMAINT_PAGE As String = "TrilingualMaint.aspx"
    Public Const BULKITEMMAINT_PAGE As String = "BulkItemMaint.aspx"

    ' Default Grid Size
    Public Const BATCH_PAGE_SIZE As Integer = 10

    'Security Group Constants
    'Public Const SYSTEM_ADMINISTRATORS As Integer = 1   'System Administrators
    'Public Const NOVA_LIBRA As Integer = 2              'Nova Libra
    'Public Const SECURITY_MANAGERS As Integer = 3       'Security Managers
    'Public Const CONTENT_MANAGERS As Integer = 4        'Content Managers
    'Public Const WEBSITE_MANAGERS As Integer = 5        'Website Managers
    'Public Const VENDOR_CAA As Integer = 33             'Vendor/CAA
    'Public Const CAA_CMA As Integer = 34                'CAA/CMA
    'Public Const IMPORT_MGR As Integer = 35             'Import Mgr.
    'Public Const BUYER As Integer = 36                  'Buyer
    'Public Const PRICING_MGR As Integer = 37            'Pricing Mgr.
    'Public Const GM_DM As Integer = 38                  'GM/DM
    'Public Const MERCH_ANALYST As Integer = 39          'Merch. Analyst
    'Public Const SCA As Integer = 40                    'SCA
    'Public Const TAX_MGR As Integer = 41                'Tax Mgr.
    'Public Const DBC_QA As Integer = 42                 'DBC/QA

    'Additional COO Names   - Change Rec Only Fields
    Public Const cADDCOONAME As String = "AddCountryOfOriginName"
    Public Const cADDCOO As String = "AddCountryOfOrigin"
    Public Const cNEWPRIMARY As String = "CountryOfOriginName"
    Public Const cNEWPRIMARYCODE As String = "CountryOfOrigin"
    Public Const cADDACOUNTRY As String = "lnkAddACountry"
    Public Const cEMPTYCOUNTRY As String = "rowEmptyCountry"

    ' Cost Change Field
    Public Const cFUTURECOSTSTATUS As String = "FutureCostStatus"

    ' Domestic Item
    Public Const DOMESTIC_ITEM_IMPORT_WORKSHEET As String = "Add Change"
    Public Const DOMESTIC_ITEM_START_ROW As Integer = 23

    ' Import Item
    Public Const IMPORT_ITEM_DETAIL_WORKSHEET As String = "Detail Sheet"
    Public Const IMPORT_ITEM_ADDL_PICTURE_WORKSHEET As String = "Additional Picture Sheet"
    Public Const IMPORT_ITEM_SECURITY_WORKSHEET As String = "00-Securtiy"
    Public Const IMPORT_ITEM_IMPORT_WORKSHEET As String = "Import Quote Sheet"
    Public Const IMPORT_ITEM_CHILD_WORKSHEET As String = "Child #"
    Public Const IMPORT_ITEM_REGULAR_WORKSHEET As String = "R-#"

    'Purchase Order Item
    Public Const PURCHASE_ORDER_IMPORT_ITEM_WORKSHEET As String = "Sheet1"

    ' New Item Approval Tab
    Public Const NEW_ITEM_TAB_WORKSHEET As String = "New Item"
    Public Const NEW_ITEM_TAB_START_ROW As Integer = 18

    ' Like Item Approval Tab
    Public Const LIKE_ITEM_TAB_WORKSHEET As String = "Like Item"
    Public Const LIKE_ITEM_TAB_START_ROW As Integer = 18

    ' Import Constants
    Public Const IMPORT_RMS_DEFAULT_VALUE As String = "Y"
    Public Const IMPORT_ERROR_UNKNOWN As String = "An unknown error has occurred while uploading this spreadsheet.<br />Please contact the system administrator and verify that you are using the latest version of the spreadsheet."
    Public Const IMPORT_ERROR_INVALID_VERSION As String = "This version of the spreadsheet is not currently supported by SPEDY.<br />Please contact the system administrator or get the latest version of the spreadsheet."
    Public Const IMPORT_ERR0R_INVALID_SKU_VENDOR As String = "There is an invalid SKU ({0}) in the upload.<br />Please fix the issue with the spreadsheet and try the upload again."

    Public Const IMPORT_ERROR_INVALID_VENDOR_NUMBER As String = "No Vendor Number was specified.  Please specify a vendor number in the spreadsheet and try the upload again."
    Public Const IMPORT_ERROR_INVALID_SKU_BATCH As String = "SKU ({0}) is already in batch ({1}).<br />If changes need to be made to the SKU, they will need to be done in Item Maintenance."
    Public Const IMPORT_ERROR_INVALID_SKU_PACK_PARENT As String = "SKU ({0}) is a pack sku and cannot be added to a New Item batch.<br />If changes need to be made to the SKU, they will need to be done in Item Maintenance."
    Public Const IMPORT_ERROR_INVALID_QUOTE_SHEET_STATUS As String = "There is an invalid Quote Sheet Status ({0}) in the upload.<br/>Please fix the issue with the spreadsheet and try the upload again."
    Public Const IMPORT_ERROR_INVALID_QRN_BATCH As String = "Quote Reference Number ({0}) is already in batch ({1}).<br />Please fix the issue with the spreadsheet and try the upload again."
    Public Const IMPORT_ERROR_INVALID_TASK_TYPE As String = "There is an invalid Task Type ({0}) in the upload.<br/>Please fix the issue with the spreadsheet and try the upload again."
    Public Const IMPORT_ERROR_INVALID_ITEMTASK_EDIT_SKU As String = "The spreadsheet has Item Task set to 'EDIT' for an item without a SKU Number. <br/>Please fix the issue with the spreadsheet and try the upload again."
    Public Const IMPORT_ERROR_INVALID_ITEMTASK_NEW_SKU As String = "The spreadhseet has Item Task set to 'NEW ITEM' for an item with a SKU. <br/>If changes need to be made to the SKU, they will need to be done in Item Maintenance."
    Public Const IMPORT_ERROR_INVALID_VENDOR_PACK As String = "The spreadhseet has multiple vendors ({0}, {1}). <br/>Please fix the issue with the spreadsheet and try the upload again."
    Public Const IMPORT_ERROR_INVALID_ITEMTASK_SKU As String = "The spreadsheet has Item Task set to 'EDIT' for an item without a SKU Number. <br/>Please fix the issue with the spreadsheet and try the upload again."

    ' Multiline Delimiter
    Public Const MULTILINE_DELIM As String = "<MULTILINEDELIMITER>"

    ' Custom Fields
    Public Const RECTYPE_NEW_ITEM_BATCH As Integer = 1
    Public Const RECTYPE_DOMESTIC_ITEM_HEADER As Integer = 2
    Public Const RECTYPE_DOMESTIC_ITEM As Integer = 3
    Public Const RECTYPE_IMPORT_ITEM As Integer = 4
    Public Const RECTYPE_ITEM_MAINTENANCE_BATCH As Integer = 5
    Public Const RECTYPE_ITEM_MAINTENANCE As Integer = 6

    ' List Value Constants
    Public Const LIST_VALUE_DEFAULT_PRIVATE_BRAND_LABEL As String = "12"

    'constants below represent ITEM Condition_ID values in SPD_WORKFLOW_Condition table
    Public Const IMPORTITEM As Integer = 1
    Public Const SEASONALATTRIBUTE As Integer = 2
    Public Const DEPARTMENTS As Integer = 3
    Public Const PRICINGCHECK As Integer = 4
    Public Const PACKITEMDISPLAYER As Integer = 5
    Public Const DOMESTICITEM As Integer = 6
    Public Const PACKITEMDISPLAYPACK As Integer = 7 'Display Pack
    Public Const STOCKCATEGORYWAREHOUSE As Integer = 8
    Public Const STOCKCATEGORYDIRECT As Integer = 9
    Public Const ITEMTYPEREGULARITEM As Integer = 10
    Public Const ITEMTYPETYPECOMPLEXPACK As Integer = 11
    Public Const ITEMTYPESIMPLEPACK As Integer = 12
    Public Const BASICATTRIBUTE As Integer = 13
    Public Const FIXTUREATTRIBUTE As Integer = 14
    Public Const GIVEAWAYATTRIBUTE As Integer = 15
    Public Const SUPPLIERSATTRIBUTE As Integer = 16
    Public Const TESTATRRIBUTE As Integer = 17
    Public Const QUICKCODEATTRIBUTE As Integer = 18
    Public Const MODIFIEDFIELDS As Integer = 19
    Public Const HEAVYPACK As Integer = 20
    Public Const PACKITEMD_PDQ As Integer = 21
    Public Const PACKITEMD_PIAB As Integer = 22
    Public Const PACKITEMDP_PDQ As Integer = 23
    Public Const PACKITEMDP_PIAB As Integer = 24
    Public Const PACKITEMDP_NEITHER As Integer = 25
    Public Const NONSEASONALATTRIBUTE As Integer = 26
    Public Const COMPONENTCHANGES As Integer = 27
    Public Const SOURCINGBATCH As Integer = 51
    Public Const WORKFLOWCONTAINSREJECT As Integer = 52
    Public Const BATCHUPDATEDINSPEDY As Integer = 53
    Public Const NOTSOURCINGBATCH As Integer = 54
    Public Const WORKFLOWHASNOREJECT As Integer = 55
    Public Const BATCHNOTUPDATEDINSPEDY As Integer = 56
    Public Const PLISNOTALLYES As Integer = 61
    Public Const PLISEDITED As Integer = 62
    Public Const CREATEDBYIMPORTMGR As Integer = 63
    Public Const SPEDYMODIFIEDFIELDS As Integer = 64
    Public Const NONQUICKCODEATTRIBUTE As Integer = 66
    Public Const ALLSEASONALATTRIBUTE As Integer = 67
    '---------------------------------------
    'constants below represent PO Condition_ID values in SPD_WORKFLOW_Condition table
    Public Const INITIATORROLES As Integer = 30
    Public Const AMOUNTGRT As Integer = 31
    Public Const AMOUNTLT As Integer = 32
    Public Const BATCHDIRECT As Integer = 33
    Public Const BATCHWAREHOUSE As Integer = 34
    Public Const BASICORDER As Integer = 35
    Public Const SEASONALORDER As Integer = 36
    Public Const CONTAINSWAREHOUSEITEM As Integer = 37
    Public Const ALLDIRECTITEMS As Integer = 38
    Public Const PAYMENTTERMSMATCH As Integer = 39
    Public Const PAYMENTTERMSLOC As Integer = 40
    Public Const PAYMENTTERMSNOTLOC As Integer = 44
    Public Const SHIPWINDOWDAYS As Integer = 41
    Public Const VENDORTYPEIMPORT As Integer = 42
    Public Const VENDORTYPEDOMESTIC As Integer = 43
    Public Const PACKMISMATCH As Integer = 45
    Public Const POSPECIALTEST As Integer = 46
    Public Const ISALLOCDIRTY As Integer = 47
    Public Const ISPLANNERDISRTY As Integer = 48
    Public Const ISDATEWARNING As Integer = 49
    Public Const POTYPEAST As Integer = 50
    Public Const POTYPEMAN As Integer = 57
    Public Const RSETEVENT As Integer = 58
    Public Const NONRSETEVENT As Integer = 59
    Public Const POCANCELLED As Integer = 60

    Public Const APPROVE As String = "Approve"
    Public Const DISAPPROVE As String = "Disapprove"

    Public Const BATCHTYPEDOMESTIC As Integer = 1
    Public Const BATCHTYPEIMPORT As Integer = 2

    Public Const POSPECIAL_CUSTOMERORDER As Integer = 1
    Public Const POSPECIAL_TEST As Integer = 2

    'PO Location Zone IDs
    Public Const PO_LOCATION_US_ZONE As Integer = 1000
    Public Const PO_LOCATION_CA_ZONE As Integer = 1001
    Public Const PO_LOCATION_AK_ZONE As Integer = 1002

    ' Required Entry Const for Drop Downs
    Public Const cREQPICK As String = "* Please Select *"

    ' String pipe
    Public Const cPIPE As String = "|"

    Public Enum WorkflowType
        NewItem = 1
        ItemMaint = 2
        NewPO = 3
        POMaint = 4
        TrilingualMaint = 5
        EXTMaint = 6
        BulkItemMaint = 7
    End Enum

    Public Enum SecurityGroups
        SysAdmins = 1
        NovaLibra = 2
        SecurityManagers = 3
        ContentManagers = 4
        WebsiteManagers = 5
        VendorCAA = 33
        CAACMA = 34
        ImportMgr = 35
        Buyer = 36
        PricingMgr = 37
        GMDM = 38
        MerchAnalyst = 39
        SCA = 40
        TaxMgr = 41
        DBCQA = 42
        NewStoreGroup = 48
        VendorRelation = 58
    End Enum

    Public Enum POFileColumn
        SKU = 0
        LOC = 1
        QTY = 2
        COST = 3
        IP = 4
        MC = 5
    End Enum

End Class
