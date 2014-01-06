@rem
@rem Author:: Seth Chisamore (<schisamo@opscode.com>)
@rem Copyright:: Copyright (c) 2011 Opscode, Inc.
@rem License:: Apache License, Version 2.0
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem     http://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.
@rem

@set "KITCHENPLAN_BRANCH_NAME=master"
@set "KITCHENPLAN_ARCHIVE_URL=https://github.disney.com/stwagner/kitchenplan/archive/%KITCHENPLAN_BRANCH_NAME%.zip"
@set "GIT_ARCHIVE_URL=https://msysgit.googlecode.com/files/Git-1.8.5.2-preview20131230.exe"
@set "CHEF_MSI_BASE_URL=https://www.opscode.com/chef/download"
@set KITCHENPLAN_DIRECTORY=C:\kitchenplan

@rem Use delayed environment expansion so that ERRORLEVEL can be evaluated with the
@rem !ERRORLEVEL! syntax which evaluates at execution of the line of script, not when
@rem the line is read. See help for the /E switch from cmd.exe /? .
@setlocal ENABLEDELAYEDEXPANSION

@set BOOTSTRAP_DIRECTORY=C:\chef\
@echo Checking for existing directory "%BOOTSTRAP_DIRECTORY%"...
@if NOT EXIST %BOOTSTRAP_DIRECTORY% (
    @echo Existing directory not found, creating.
    @mkdir %BOOTSTRAP_DIRECTORY%
) else (
    @echo Existing directory found, skipping creation.
)

> C:\chef\wget.vbs (
echo.url = WScript.Arguments.Named^("url"^)
echo.path = WScript.Arguments.Named^("path"^)
echo.proxy = null
echo.Set objXMLHTTP = CreateObject^("MSXML2.ServerXMLHTTP"^)
echo.Set wshShell = CreateObject^( "WScript.Shell" ^)
echo.Set objUserVariables = wshShell.Environment^("USER"^)
echo.
echo.On Error Resume Next
echo.
echo.If NOT ^(objUserVariables^("HTTP_PROXY"^) = ""^) Then
echo.proxy = objUserVariables^("HTTP_PROXY"^)
echo.
echo.ElseIf NOT ^(WScript.Arguments.Named^("proxy"^) = ""^) Then
echo.proxy = WScript.Arguments.Named^("proxy"^)
echo.End If
echo.
echo.If NOT isNull^(proxy^) Then
echo.Set objXMLHTTP = CreateObject^("MSXML2.ServerXMLHTTP.6.0"^)
echo.objXMLHTTP.setProxy 2, proxy
echo.End If
echo.
echo.On Error Goto 0
echo.
echo.objXMLHTTP.open "GET", url, false
echo.objXMLHTTP.send^(^)
echo.If objXMLHTTP.Status = 200 Then
echo.Set objADOStream = CreateObject^("ADODB.Stream"^)
echo.objADOStream.Open
echo.objADOStream.Type = 1
echo.objADOStream.Write objXMLHTTP.ResponseBody
echo.objADOStream.Position = 0
echo.Set objFSO = Createobject^("Scripting.FileSystemObject"^)
echo.If objFSO.Fileexists^(path^) Then objFSO.DeleteFile path
echo.Set objFSO = Nothing
echo.objADOStream.SaveToFile path
echo.objADOStream.Close
echo.Set objADOStream = Nothing
echo.End if
echo.Set objXMLHTTP = Nothing
)

@rem Determine the version and the architecture

@FOR /F "usebackq tokens=1-8 delims=.[] " %%A IN (`ver`) DO (
@set WinMajor=%%D
@set WinMinor=%%E
@set WinBuild=%%F
)

@echo Detected Windows Version %WinMajor%.%WinMinor% Build %WinBuild%

@set LATEST_OS_VERSION_MAJOR=6
@set LATEST_OS_VERSION_MINOR=3

@if /i %WinMajor% GTR %LATEST_OS_VERSION_MAJOR% goto VersionUnknown
@if /i %WinMajor% EQU %LATEST_OS_VERSION_MAJOR%  (
  @if /i %WinMinor% GTR %LATEST_OS_VERSION_MINOR% goto VersionUnknown
)

goto Version%WinMajor%.%WinMinor%

:VersionUnknown
@rem If this is an unknown version of windows set the default
@set MACHINE_OS=2008r2
@echo Warning: Unknown version of Windows, assuming default of Windows %MACHINE_OS%
goto architecture_select

:Version6.0
@set MACHINE_OS=2008
goto architecture_select

:Version5.2
@set MACHINE_OS=2003r2
goto architecture_select

:Version6.1
@set MACHINE_OS=2008r2
goto architecture_select

:Version6.2
@set MACHINE_OS=2012
goto architecture_select

@rem Currently Windows Server 2012 R2 is treated as equivalent to Windows Server 2012
:Version6.3
goto Version6.2

:architecture_select
goto Architecture%PROCESSOR_ARCHITEW6432%

:Architecture
goto Architecture%PROCESSOR_ARCHITECTURE%

@rem If this is an unknown architecture set the default
@set MACHINE_ARCH=i686
goto install

:Architecturex86
@set MACHINE_ARCH=i686
goto install

:Architectureamd64
@set MACHINE_ARCH=x86_64
goto install

:install
@rem Install Chef using chef-client MSI installer

@set "REMOTE_SOURCE_MSI_URL=%CHEF_MSI_BASE_URL%?p=windows&pv=%MACHINE_OS%&m=%MACHINE_ARCH%"
@set "LOCAL_DESTINATION_MSI_PATH=%TEMP%\chef-client-latest.msi"
@set "CHEF_CLIENT_MSI_LOG_PATH=%TEMP%\chef-client-msi%RANDOM%.log"
@set "FALLBACK_QUERY_STRING=&DownloadContext=PowerShell"

@rem Clear any pre-existing downloads
@echo Checking for existing downloaded package at "%LOCAL_DESTINATION_MSI_PATH%"
@if EXIST "%LOCAL_DESTINATION_MSI_PATH%" (
    @echo Found existing downloaded package, deleting.
    @del /f /q "%LOCAL_DESTINATION_MSI_PATH%"
    @if ERRORLEVEL 1 (
	echo Warning: Failed to delete pre-existing package with status code !ERRORLEVEL! > "&2"
    )
) else (
    echo No existing downloaded packages to delete.
)

@rem If there is somehow a name collision, remove pre-existing log
@if EXIST "%CHEF_CLIENT_MSI_LOG_PATH%" del /f /q "%CHEF_CLIENT_MSI_LOG_PATH%"

@echo Attempting to download client package using cscript...
cscript /nologo C:\chef\wget.vbs /url:"%REMOTE_SOURCE_MSI_URL%" /path:"%LOCAL_DESTINATION_MSI_PATH%"

@rem Work around issues found in Windows Server 2012 around job objects not respecting WSMAN memory quotas
@rem that cause the MSI download process to exceed the quota even when it is increased by administrators.
@rem Retry the download using a more memory-efficient mechanism that only works if PowerShell is available.
@set DOWNLOAD_ERROR_STATUS=!ERRORLEVEL!
@if ERRORLEVEL 1 (
    @echo Failed cscript download with status code !DOWNLOAD_ERROR_STATUS! > "&2"
    @if !DOWNLOAD_ERROR_STATUS!==0 set DOWNLOAD_ERROR_STATUS=2
) else (
    @rem Sometimes the error level is not set even when the download failed,
    @rem so check for the file to be sure it is there -- if it is not, we will retry
    @if NOT EXIST "%LOCAL_DESTINATION_MSI_PATH%" (
	echo Failed download: download completed, but downloaded file not found > "&2"
	set DOWNLOAD_ERROR_STATUS=2
    ) else (
	echo Download via cscript succeeded.
    )
)

@if NOT %DOWNLOAD_ERROR_STATUS%==0 (
    @echo Warning: Failed to download "%REMOTE_SOURCE_MSI_URL%" to "%LOCAL_DESTINATION_MSI_PATH%"

)

@echo Installing downloaded client package...

msiexec /qn /log "%CHEF_CLIENT_MSI_LOG_PATH%" /i "%LOCAL_DESTINATION_MSI_PATH%"

@if ERRORLEVEL 1 (
    echo Chef-client package failed to install with status code !ERRORLEVEL!. > "&2"
    echo See installation log for additional detail: %CHEF_CLIENT_MSI_LOG_PATH%. > "&2"
) else (
    @echo Chef Installation completed successfully
    del /f /q "%CHEF_CLIENT_MSI_LOG_PATH%"
)

@endlocal


@set "LOCAL_GIT_ARCHIVE=%TEMP%\git-installer.exe"
@echo Attempting to download git-scm archive
cscript /nologo C:\chef\wget.vbs /url:"%GIT_ARCHIVE_URL%" /path:"%LOCAL_GIT_ARCHIVE%"
@echo Installing git-scm
cmd /c %LOCAL_GIT_ARCHIVE% /verysilent /dir="%PROGRAMFILES%\git" /components="ext,ext\cheetah,assoc,assoc_sh"
@echo Adding git-scm binary path to path in this shell.
@set "PATH=%PATH%:%PROGRAMFILES%\git\bin"

@echo Checking for existing kitchenplan directory "%KITCHENPLAN_DIRECTORY%"...
@if NOT EXIST %KITCHENPLAN_DIRECTORY% (
    @echo Existing directory not found, creating.
    @mkdir %KITCHENPLAN_DIRECTORY%
) else (
    @echo Existing directory found, skipping creation.
)

> %KITCHENPLAN_DIRECTORY%\unzip.vbs (
echo.inFile = WScript.Arguments.Named^("inFile"^)
echo.outFolder = WScript.Arguments.Named^("outFolder"^)
echo.Set objShell = CreateObject^( "Shell.Application" ^)
echo.Set objSource = objShell.NameSpace^(inFile^).Items^(^)
echo.Set objTarget = objShell.NameSpace^(outFolder^)
echo.intOptions = 256
echo.objTarget.CopyHere objSource, intOptions
)

@set "LOCAL_KITCHENPLAN_ARCHIVE=%TEMP%\kitchenplan.zip"
@echo Attempting to download kitchenplan archive
cscript /nologo C:\chef\wget.vbs /url:"%KITCHENPLAN_ARCHIVE_URL%" /path:"%LOCAL_KITCHENPLAN_ARCHIVE%"
@echo Decompressing kitchenplan archive into %KITCHENPLAN_DIRECTORY%
cscript /nologo %KITCHENPLAN_DIRECTORY%\unzip.vbs /inFile:"%LOCAL_KITCHENPLAN_ARCHIVE%" /outFolder:"%KITCHENPLAN_DIRECTORY%"

robocopy /move /e /log:%TEMP%\copy_kitchenplan.log %KITCHENPLAN_DIRECTORY%\kitchenplan-%KITCHENPLAN_BRANCH_NAME% %KITCHENPLAN_DIRECTORY%\
cd %KITCHENPLAN_DIRECTORY%

@echo Executing kitchenplan for user %USERNAME%, good luck!

C:\opscode\chef\embedded\bin\ruby kitchenplan
