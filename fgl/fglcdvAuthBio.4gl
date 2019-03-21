#
#       (c) Copyright Four Js 2019.
#
#                                 Apache License
#                           Version 2.0, January 2004
#
#       https://www.apache.org/licenses/LICENSE-2.0

#+ Genero BDL wrapper around the Cordova Fingerprint plugin.
#+

IMPORT util

#+ The AuthOptionsT type is used to pass options to the authenticate call.
#+
PUBLIC TYPE AuthOptionsT RECORD
  clientId STRING, --used on Android/IOS
  clientSecret STRING, --only used on Android
  disableBackup BOOLEAN, --prevent asking for Password dialog if biometric auth failed
  localizedFallbackTitle STRING --alternative title for the "Input Password"
END RECORD

PUBLIC CONSTANT AUTH_TYPE_NONE="none"
PUBLIC CONSTANT AUTH_TYPE_FINGER="finger"
PUBLIC CONSTANT AUTH_TYPE_FACE="face"


PRIVATE CONSTANT FIPRI="Fingerprint"
PRIVATE CONSTANT CDV="cordova"
PRIVATE CONSTANT _CALL="call"
DEFINE m_error STRING

#+ Retrieves the biometric authentication type avaiable on the device
#+
#+ @return either AUTH_TYPE_NONE,AUTH_TYPE_FINGER or AUTH_TYPE_FACE
PUBLIC FUNCTION availableType() RETURNS STRING
   DEFINE result STRING
   TRY
      CALL ui.Interface.frontCall(CDV,_CALL,[FIPRI,"isAvailable"],[result])
   END TRY
   IF NOT result.equals(AUTH_TYPE_NONE) AND 
      NOT result.equals(AUTH_TYPE_FINGER) AND
      NOT result.equals(AUTH_TYPE_FACE) THEN
     LET result=AUTH_TYPE_NONE
   END IF
   RETURN result
END FUNCTION

#+ Retrieves if biometric authentication is possible
#+
#+ @return TRUE in case a biometric authentication method is possible
#+ otherwise FALSE
PUBLIC FUNCTION isAvaible() RETURNS BOOLEAN
   DEFINE authType STRING
   LET authType=availableType()
   RETURN IIF(NOT authType.equals(AUTH_TYPE_NONE),TRUE,FALSE)
END FUNCTION

#+ Checks if the user passed the authentication check
#+
#+ In case the auhentication failed, the error can be retrieved with getLastError()
#+
#+ @return TRUE in case the user was able to authenticate , otherwise FALSE
PUBLIC FUNCTION authenticate(options AuthOptionsT) RETURNS BOOLEAN
  DEFINE result STRING
  TRY
    CALL ui.Interface.frontCall(CDV,"call",[FIPRI,"authenticate",options],[result])
    RETURN TRUE
  CATCH
    CALL err_frontcall()
    RETURN FALSE
  END TRY
END FUNCTION

#+ Returns the last Error message of the previous operation 
#+
#+ @return the error message
FUNCTION getLastError() RETURNS STRING
  RETURN m_error
END FUNCTION

#+ extract the plugin error message
PRIVATE FUNCTION err_frontcall()
  DEFINE msg STRING
  DEFINE idx,endidx INT

  LET msg=err_get(status)
  IF status=-6333 THEN --cut off the leading bla
    LET msg=msg.subString(msg.getIndexOf("Reason:",1)+7,msg.getLength())
  END IF
  IF (idx:=msg.getIndexOf("NSLocalizedDescription = ",1))<>0 THEN
    --extract from the silly iOS format
    LET idx=idx+26
    LET endidx=msg.getIndexOf("\n",idx)
    IF endidx<>0 THEN
      LET msg=msg.subString(idx,endidx-3)
    END IF
  END IF
  LET m_error=msg
  DISPLAY "ERROR:",m_error
END FUNCTION
