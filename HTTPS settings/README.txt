Tutorial followed for the HTTPS implementation:
https://zuziko.com/tutorials/how-to-enable-https-ssl-on-wamp-server/

-put the certificate and private.key in the D:\Wamp64\bin\apache\apache2.4.46\conf\key folder.
(if key folder does not exist create one).
-replace current httpd-ssl in C:\Wamp64\bin\apache\apache2.4.46\conf\extra with this one
and check that the variables as ${SERVER_ROOT} and others correspond to your computer's paths
as well with httpd in the /conf directory (the one i send before had my file paths :/).

If it does not run, right-click the wamp icon,
go to Tools/Check httpd.conf syntax and tell me the errors to troubleshoot
