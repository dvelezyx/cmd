@echo off

REM DON'T CHANGE ANYTHING AFTER HERE...

REM call SETCVSPATH.cmd

set MODE=%1
set CONFIG=%2
set BUILDMODE=%3
set CVSPATH=%4
set MYSOLUTION=%5

set tasklist=%windir%\System32\tasklist.exe
set procName=vsmsvr.exe
set DEVENV="%VS71COMNTOOLS%\..\IDE\devenv"
set RUNMACRO=Macros.ReleaseMacros.VersionResourceUpdater.UpdateVersionResource_new_from_template_autoclose

set L2DBI=l2dbi001_noDepend.sln
set BATCHLIB=batchlib.sln
set SUPPL32=_Suppl32.sln
set COSEU=COSEU.sln
set LOGAPGM=logapgm.sln
set L2USERX=l2userx.sln
set FORSRV=_forsrvr.sln
set PROZSRV=_prozsrv.sln
set ETAT=ETAT.sln

set SOLUTIONS=%CVSPATH%\vc\Coseu\%L2DBI% %CVSPATH%\vc\Coseu\%BATCHLIB% %CVSPATH%\vc\Suppl\%SUPPL32% 
set SOLUTIONS=%SOLUTIONS% %CVSPATH%\vc\Coseu\%COSEU% 
REM set SOLUTIONS=%SOLUTIONS% %CVSPATH%\vc\L2001\LOGAABR\%LOGAPGM%
REM set SOLUTIONS=%SOLUTIONS% %CVSPATH%\vc\L2001\EXITS\%L2USERX%
set SOLUTIONS=%SOLUTIONS% %CVSPATH%\vc\L2001\Forsrvr\%FORSRV%
REM set SOLUTIONS=%SOLUTIONS% %CVSPATH%\vc\L2001\PROZSRV\%PROZSRV%
REM set SOLUTIONS=%SOLUTIONS% %CVSPATH%\vc\HRMS\%ETAT%

ECHO MODE:       %MODE%
ECHO CONFIG:     %CONFIG%
ECHO BUILDMODE:  %BUILDMODE%
ECHO CVSPATH:    %CVSPATH%
ECHO MYSOLUTION: %MYSOLUTION%

IF "%MODE%MACROS"=="INITMACROS" (
 ECHO "INITMACROS..."
)
 
PAUSE

IF NOT "COMPILE%MYSOLUTION%"=="COMPILE" set SOLUTIONS=%MYSOLUTION%

FOR %%S IN (%SOLUTIONS%) DO (

 PUSHD %%~dpS

 @echo Processing... %%~nxS in %%~dpS

 IF "%MODE%MACROS"=="INITMACROS" (
  %DEVENV% %%~nxS /command "%RUNMACRO%"
  PAUSE
  REM :CHECK_STARTED
  REM "%windir%\system32\timeout.exe" /T 4 /NOBREAK
  REM %tasklist% | find /C "%procName%"
  REM if %ERRORLEVEL%==1 GOTO:CHECK_STARTED
  REM
  REM :CHECK_FINISHED
  REM "%windir%\system32\timeout.exe" /T 8 /NOBREAK
  REM %tasklist% | find /C "%procName%"
  REM if %ERRORLEVEL%==0 GOTO:CHECK_FINISHED
 )

 IF "%MODE%ALL"=="TESTALL" (
  @echo %%~nxS
 ) ELSE (
  IF "%MODE%ALL"=="CLEANALL" (
   %DEVENV% %%~nxS /clean %CONFIG%
  ) ELSE (
   IF "%%~nxS"=="%SUPPL32%" (
    %DEVENV% %%~nxS /%BUILDMODE% %CONFIG% /project logasyslog.vcproj
    %DEVENV% %%~nxS /%BUILDMODE% %CONFIG% /project logaxml.vcproj
   ) ELSE (
    IF "%%~nxS"=="%COSEU%" (
     %DEVENV% %%~nxS /%BUILDMODE% %CONFIG% /project coseulib.vcproj
    ) ELSE (
     IF "%%~nxS"=="%LOGAPGM%" (
      %DEVENV% %%~nxS /%BUILDMODE% %CONFIG% /project logadll.vcproj
     ) ELSE (
      IF "%%~nxS"=="%FORSRV%" (
       FOR %%P IN (repes*.vcproj%) DO (
        @echo Solution: %%S
        @echo Project:  %%P
        %DEVENV% %%~nxS /%BUILDMODE% %CONFIG% /project %%P
       )
      ) ELSE (
       IF "%%~nxS"=="%PROZSRV%" (
        %DEVENV% %%~nxS /%BUILDMODE% %CONFIG% /project repva.vcproj
       ) ELSE (
        IF "%%~nxS"=="%ETAT%" (
	     %DEVENV% %%~nxS /%BUILDMODE% %CONFIG% /project etat.vcproj
	    ) ELSE (
	     %DEVENV% %%~nxS /%BUILDMODE% %CONFIG%
	    )
       )
      )
     )
    )
   )
  )
 )

 POPD
)
