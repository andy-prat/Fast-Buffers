:: This script pack FastBuffers library for any platform in Windows.
::
:: This script needs the next environment variables to be run.
:: - SVN_BIN_DIR: Directory with the subversion binaries.
:: - LIBREOFFICE_BIN_DIR: Directory with the LibreOffice binaries.
:: - NSIS_BIN_DIR: Directory with the NSIS installer libraries.
:: - EPROSIMADIR: URL to the directory with common sources of eProsima.
:: - ANT_BIN_DIR: Directory with the ant binaries.
:: - DOXYGEN_BIN_DIR: Directory with the doxygen binaries. (Also pdflatex and graphviz)
:: Also this script needs the eProsima.documentation.changeVersion macro installed in the system.

setlocal EnableDelayedExpansion
setlocal EnableExpansion
@echo off

:: Initialize the returned value to 0 (all succesfully)
set errorstatus=0

if "%EPROSIMADIR%"=="" (
    echo "EPROSIMADIR environment variable has to be set"
    set errorstatus=-1
    goto :exit
)

:: Go to root directory
cd "..\.."

:: Update and compile CDR library.
cd "..\CDR"
:: Update CDR library.
svn update
set errorstatus=%ERRORLEVEL%
if not %errorstatus%==0 goto :exit
:: Compile CDR library.
cd "utils\scripts"
call build_cdr.bat
set errorstatus=%ERRORLEVEL%
if not %errorstatus%==0 goto :exit
cd "..\..\..\FastBuffers"

:: Get the current vesion of FastBuffers
call %EPROSIMADIR%\scripts\common_pack_functions.bat :getVersionFromCPP

:: Update and compile FastBuffers application.
:: Update FastBuffers application.
svn update
set errorstatus=%ERRORLEVEL%
if not %errorstatus%==0 goto :exit
:: Compile FastBuffers for target.
call ant jar
set errorstatus=%ERRORLEVEL%
if not %errorstatus%==0 goto :exit

:: Create PDFS from documentation.
cd "doc"
:: Installation manual
soffice.exe --headless "macro:///eProsima.documentation.changeVersion(%CD%\Installation Manual.odt,%VERSION%)"
set errorstatus=%ERRORLEVEL%
if not %errorstatus%==0 goto :exit
:: User manual
soffice.exe --headless "macro:///eProsima.documentation.changeVersion(%CD%\User Manual.odt,%VERSION%)"
set errorstatus=%ERRORLEVEL%
if not %errorstatus%==0 goto :exit
cd ".."

:: Create README
soffice.exe --headless "macro:///eProsima.documentation.changeVersionToHTML(%CD%\README.odt,%VERSION%)"
set errorstatus=%ERRORLEVEL%
if not %errorstatus%==0 goto :exit

:: Create doxygen information.
:: Generate the examples
:: CDR example
call scripts\efastbuffers_local.bat -replace -ser cdr -o utils\doxygen\examples\cdr utils\doxygen\examples\cdr\FooCdr.idl
set errorstatus=%ERRORLEVEL%
if not %errorstatus%==0 goto :exit
:: Fast CDR example
call scripts\efastbuffers_local.bat -replace -ser fastcdr -o utils\doxygen\examples\fastcdr utils\doxygen\examples\fastcdr\FooFastCdr.idl
set errorstatus=%ERRORLEVEL%
if not %errorstatus%==0 goto :exit
:: Export version
set VERSION_DOX=%VERSION%
mkdir output
mkdir output\doxygen
doxygen utils\doxygen\doxyfile
set errorstatus=%ERRORLEVEL%
if not %errorstatus%==0 goto :exit
cd output\doxygen\latex
call make.bat
set errorstatus=%ERRORLEVEL%
if not %errorstatus%==0 goto :exit
cd ..\..\..

:: Create installers.
cd "utils\installers\windows"
:: Win32 installer.
makensis.exe /DVERSION="%VERSION%" Setup_Win32.nsi
set errorstatus=%ERRORLEVEL%
if not %errorstatus%==0 goto :exit
:: Win64 installer.
makensis.exe /DVERSION="%VERSION%" Setup_Win64.nsi
set errorstatus=%ERRORLEVEL%
if not %errorstatus%==0 goto :exit
cd "..\..\.."

rmdir /S /Q output

goto :exit

:: Function exit ::
:exit
if %errorstatus%==0 (echo "PACKAGING SUCCESSFULLY") else (echo "PACKAGING FAILED")
exit /b %errorstatus%
goto :EOF
