@ECHO OFF
ECHO Y | powershell -command "Try {Send-MailMessage -SMTPServer 172.16.50.27 -From 'Sender bsm_renapo@kionetworks.com' -To 'Recipient <scastro@kionetworks.com>' -Subject 'Relay Test' -Body 'This is a Relay Test...' -ErrorAction Stop;} Catch {Exit 1}"
if %ERRORLEVEL% neq 0 (
echo "ERROR - Something went wrong sending the Email (172.16.50.27)!!!"
exit 1
) ELSE (
echo "Email Sent Successfully (Relay 172.16.50.27)!!!"
)
