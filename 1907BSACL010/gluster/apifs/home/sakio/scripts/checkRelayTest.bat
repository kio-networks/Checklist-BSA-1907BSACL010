@ECHO OFF
powershell -command " & {Send-MailMessage -SMTPServer 172.16.50.27 -From 'Sender <sis_renapo@kionetworks.com>' -To 'Recipient <scastro@kionetworks.com>' -Subject 'Relay Test' -Body 'This is a Relay Test...'}"
if %ERRORLEVEL% neq 0 (
echo "ERROR - Something went wrong sending the Email (Relay 172.16.50.27)!!!"
exit 1
) ELSE (
echo "Email Sent Successfully (Relay 172.16.50.27)!!!"
exit 0
)
