# C:\MATCHMATRIX-PLATFORM\ops\mm_mail_config.ps1
$MM_MAIL = @{
  SmtpServer = "smtp.seznam.cz"
  Port       = 465
  UseSsl     = $true

  From       = "kub.petr@email.cz"
  To         = "kub.petr@email.cz"

  User       = "TVUJ_EMAIL@seznam.cz"
  Password   = "TVE_HESLO_NEBO_APP_HESLO"
}