IMPORT FGL fgldialog
IMPORT FGL fglcdvAuthBio
DEFINE options fglcdvAuthBio.AuthOptionsT
MAIN
  DEFINE result STRING
  LET options.clientId="Genero wants your Finger"
  LET options.clientSecret="Genero"
  LET options.disableBackup=FALSE --set to TRUE would not ask for the passcode
  LET options.localizedFallbackTitle="Hey: Password please!" --title for the password dialog
  MENU "Cordova Fingerprint / Face Id Demo"
    COMMAND "Check Available"
      LET result=fglcdvAuthBio.availableType()
      IF NOT result.equals(fglcdvAuthBio.AUTH_TYPE_NONE) THEN
        CALL fgl_winmessage("Fingerprint or Face Id is available with:",result,"info")
      ELSE
        CALL fgl_winmessage("Attention","No biometric Authentication available","exclamation")
      END IF
    ON ACTION verify_with_password ATTRIBUTE(TEXT="Authenticate (w. Password)",COMMENT="In case of failure ask password")
      LET options.disableBackup=NULL --set to TRUE would not ask for the passcode
                                     --set to FALSE would allow alternative password question
      CALL authenticate()
    ON ACTION verify ATTRIBUTE(TEXT="Authenticate (FaceID only)",COMMENT="In case of failure return error")
      LET options.disableBackup=TRUE --doesn't ask for passcode, instead informs the programmer that passcode has been asked for
      CALL authenticate()
    COMMAND "Exit"
      EXIT MENU
  END MENU
END MAIN

FUNCTION authenticate()
  DEFINE err STRING
  IF fglcdvAuthBio.authenticate(options.*) THEN
    MESSAGE "Success"
    CALL fgl_winmessage("Success","Biometric authentication was successful","info")
  ELSE
    LET err=fglcdvAuthBio.getLastError()
    ERROR err
    CALL fgl_winmessage("Authentication failed with error:",err,"exclamation")
  END IF
END FUNCTION
