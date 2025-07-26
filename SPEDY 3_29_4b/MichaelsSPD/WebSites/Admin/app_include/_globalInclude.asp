<% 
'==============================================================================
' Security & Authentication Includes
'==============================================================================
%>
<!--#include file="./security_check.asp"-->
<!--#include file="./security_classes.asp"-->

<%
'==============================================================================
' Business Object (BO) Library
'==============================================================================
%>
<!--#include file="./bo_classes.asp"-->

<%
'==============================================================================
' Data Access Layer (DAL)
' These classes are the baseclasses for the business object classes, and 
' facilitate all database-level loading, saving, and deleting operations.  
'
' NOTE: Data Validation should be done at the BO level, not at the DAL level.
'==============================================================================
%>
<!--#include file="./dal_classes.asp"-->

<%
'==============================================================================
' Utility Includes
'==============================================================================
%>
<!--#include file="./checkQueryID.asp"-->
<!--#include file="./findNeedleInHayStack.asp"-->
<!--#include file="./formatDate.asp"-->
<!--#include file="./formatFileSize.asp"-->
<!--#include file="./padMe.asp"-->
<!--#include file="./returnDataWithGetRows.asp"-->
<!--#include file="./returnRandomFile.asp"-->
<!--#include file="./smartValues.asp"-->
<!--#include file="./StripHTML.asp"-->
<!--#include file="./StripTextSizes.asp"-->
<!--#include file="./trimSummary.asp"-->
<!--#include file="./trimWords.asp"-->
<!--#include file="./dal_cls_UtilityLibrary.asp"-->
<!--#include file="./InitRelativeFolder.asp"-->
