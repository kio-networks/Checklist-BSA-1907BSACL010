@ECHO OFF
ECHO Y | powershell -command "Try {Send-MailMessage -SMTPServer %smtp_server% -From 'Sender <%mail_sender%>' -To 'Recipient <hp_sa@kionetworks.com>' -Subject 'Relay Test' -Body 'This is a Relay Test...' -ErrorAction Stop;} Catch {Exit 1}"
if %ERRORLEVEL% neq 0 (
echo "ERROR - Something went wrong sending the Email (Relay %smtp_server%)!!!"
exit 1
) ELSE (
echo "Email Sent Successfully (Relay %smtp_server%)!!!"
)
