-- Date captured: 11 Feb 2004 07:09:09:287

-- Script for restoring std sql logins...
EXEC sp_addlogin 'redmill_cms_adminuser', '%%logon!' ,'master', 'us_english', 0x8F68E229BEE6D14383445ABAEB703644, 'skip_encryption' 
EXEC sp_addlogin 'redmill_cms_webuser',  '%%logon!' ,'master', 'us_english', 0x14AAEED08B25564DB1C099CD0EF43AEC, 'skip_encryption' 
EXEC sp_password NULL, '%%logon!', 'redmill_cms_adminuser'
EXEC sp_password NULL, '%%logon!', 'redmill_cms_webuser'

-- Scripts for adding roles
exec sp_addrole N'webaccess_admintool'
exec sp_addrole N'webaccess_standard'

-- Scripts for adding users
exec sp_grantdbaccess N'redmill_cms_webuser',N'redmill_cms_webuser'
exec sp_grantdbaccess N'redmill_cms_adminuser',N'redmill_cms_adminuser'

-- Scripts for adding role members
exec sp_addrolemember N'webaccess_standard',N'redmill_cms_webuser'
exec sp_addrolemember N'webaccess_admintool',N'redmill_cms_adminuser'
