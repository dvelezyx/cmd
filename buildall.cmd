@echo off

REM DON'T CHANGE ANYTHING AFTER HERE...

REM call SETCVSPATH.cmd

set MODE=%1
set CONFIG=%2
set BUILDMODE=%3
set CVSPATH=%4
set MYSOLUTION=%5
set ACTIONS=INIT BUILD
set LOGPATH=%CVSPATH%\log
set LOGFILE=%LOGPATH%\BuildLog.htm

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

set SOLUTIONS=%CVSPATH%\vc\Coseu\%L2DBI% %CVSPATH%\vc\Coseu\%BATCHLIB% %CVSPATH%\vc\Suppl\%SUPPL32% %CVSPATH%\vc\Coseu\%COSEU% 
REM set SOLUTIONS=%SOLUTIONS% %CVSPATH%\vc\L2001\LOGAABR\%LOGAPGM%
REM set SOLUTIONS=%SOLUTIONS% %CVSPATH%\vc\L2001\EXITS\%L2USERX%
set SOLUTIONS=%SOLUTIONS% %CVSPATH%\vc\L2001\Forsrvr\%FORSRV%
REM set SOLUTIONS=%SOLUTIONS% %CVSPATH%\vc\L2001\PROZSRV\%PROZSRV%
REM set SOLUTIONS=%SOLUTIONS% %CVSPATH%\vc\HRMS\%ETAT%

ECHO MODE:       %MODE%
ECHO CONFIG:     %CONFIG%
ECHO BUILDMODE:  %BUILDMODE%
ECHO CVSPATH:    %CVSPATH%
ECHO LOGFILE:    %LOGFILE%
ECHO MYSOLUTION: %MYSOLUTION%
PAUSE

REM CREAR LOGPATH
MKDIR %LOGPATH%
REM BORRAR BUILDLOG
DEL %LOGFILE%

IF NOT "COMPILE%MYSOLUTION%"=="COMPILE" set SOLUTIONS=%MYSOLUTION%

IF "%MODE%MACROS"=="INITMACROS" (

 FOR %%S IN (%SOLUTIONS%) DO (

  PUSHD %%~dpS

  @echo Processing... %%~nxS in %%~dpS
  REM START "" /D "%%~dpS" /WAIT 
  %DEVENV% %%~nxS /command %RUNMACRO%
  REM START "" /D "%%~dpS" /WAIT %DEVENV% %%~nxS /command %RUNMACRO%
  REM START /WAIT v:\CVS\HEAD\Mod_\Lvl0\src\win32\vc\Coseu\batchlib.sln /command %RUNMACRO%
  POPD
 
 ) 


:CHECK_STARTED
"%windir%\system32\timeout.exe" /T 4 /NOBREAK
%tasklist% | find /C "%procName%"
if %ERRORLEVEL%==1 GOTO:CHECK_STARTED

:CHECK_FINISHED
"%windir%\system32\timeout.exe" /T 8 /NOBREAK
%tasklist% | find /C "%procName%"
if %ERRORLEVEL%==0 GOTO:CHECK_FINISHED

)

REM PAUSE

FOR %%S IN (%SOLUTIONS%) DO (

 PUSHD %%~dpS

 @echo Processing... %%~nxS in %%~dpS

 IF "%MODE%ALL"=="TESTALL" (
  @echo %%~nxS
 ) ELSE (
  IF "%MODE%ALL"=="CLEANALL" (
   %DEVENV% %%~nxS /clean %CONFIG%
  ) ELSE (
   IF "%%~nxS"=="%SUPPL32%" (
    %DEVENV% %%~nxS /%BUILDMODE% %CONFIG% /project logasyslog.vcproj /out %LOGFILE%
    %DEVENV% %%~nxS /%BUILDMODE% %CONFIG% /project logaxml.vcproj /out %LOGFILE%
   ) ELSE (
    IF "%%~nxS"=="%COSEU%" (
     %DEVENV% %%~nxS /%BUILDMODE% %CONFIG% /project l2dbi001.vcproj /out %LOGFILE%
     %DEVENV% %%~nxS /%BUILDMODE% %CONFIG% /project l2ddc001.vcproj /out %LOGFILE%
     %DEVENV% %%~nxS /%BUILDMODE% %CONFIG% /project l2run001.vcproj /out %LOGFILE%
     %DEVENV% %%~nxS /%BUILDMODE% %CONFIG% /project coseulib.vcproj /out %LOGFILE%
    ) ELSE (
     IF "%%~nxS"=="%LOGAPGM%" (
      %DEVENV% %%~nxS /%BUILDMODE% %CONFIG% /project logadll.vcproj /out %LOGFILE%
     ) ELSE (
      IF "%%~nxS"=="%FORSRV%" (
       FOR %%P IN (repes*.vcproj%) DO (
        @echo Solution: %%S
        @echo Project:  %%P
        %DEVENV% %%~nxS /%BUILDMODE% %CONFIG% /project %%P /out %LOGFILE%
       )
      ) ELSE (
       IF "%%~nxS"=="%PROZSRV%" (
        %DEVENV% %%~nxS /%BUILDMODE% %CONFIG% /project repva.vcproj /out %LOGFILE%
       ) ELSE (
        IF "%%~nxS"=="%ETAT%" (
	     %DEVENV% %%~nxS /%BUILDMODE% %CONFIG% /project etat.vcproj /out %LOGFILE%
	    ) ELSE (
	     %DEVENV% %%~nxS /%BUILDMODE% %CONFIG% /out %LOGFILE%
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
