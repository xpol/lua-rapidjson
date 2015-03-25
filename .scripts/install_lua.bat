@echo off
Setlocal EnableDelayedExpansion

:: Most of the following CMD scripting magic was taken from
:: https://github.com/siffiejoe/prg-lr4win
:: Thanks to siffiejoe

cd %APPVEYOR_BUILD_FOLDER%

:: hack to make sure that we can bail out from within nested
:: subroutines without killing the console window
:: Note: This hack prevents me from setting environment variables here to be visible in the calling script.
:: That's why we resort to calling a temp file.
:: I hate batch files.
if "%~1" EQU "_GO_" (shift /1 & goto :main)
cmd /c ^""%~f0" _GO_ %*^"
if exist %APPVEYOR_BUILD_FOLDER%\.scripts\setpaths.bat (
	endlocal
	call %APPVEYOR_BUILD_FOLDER%\.scripts\setpaths.bat
	del %APPVEYOR_BUILD_FOLDER%\.scripts\setpaths.bat
)
exit /B

:: start of the script
:main

:: first create some necessary directories:
mkdir downloads 2>NUL

:: Download and compile Lua (or LuaJIT)
if "%LUA%"=="luajit" (
	set lj_dest_folder=c:\lj%LJ_SHORTV%

	if !LJ_SHORTV!==2.1 (
		rem set lj_source_folder=c:\luajit-%LJ_VER%
		set lj_source_folder=%APPVEYOR_BUILD_FOLDER%\downloads\luajit-%LJ_VER%
		if not exist !lj_source_folder! (
			git clone http://luajit.org/git/luajit-2.0.git !lj_source_folder!
			if errorlevel 1 (
				git clone git://repo.or.cz/luajit-2.0.git !lj_source_folder! || call :die
			)
		)
		cd !lj_source_folder!\src
		git checkout v2.1 || call :die
	) else (
		call :download http://luajit.org/download/LuaJIT-%LJ_VER%.zip
		call :extract_zip downloads\LuaJIT-%LJ_VER%.zip downloads\luajit-%LJ_VER%
		set lj_source_folder=%APPVEYOR_BUILD_FOLDER%\downloads\luajit-%LJ_VER%
		cd !lj_source_folder!\src
	)
	call msvcbuild.bat

	if not exist !lj_dest_folder! (
		mkdir !lj_dest_folder!
		mkdir !lj_dest_folder!\bin
		mkdir !lj_dest_folder!\include
		mkdir !lj_dest_folder!\lib
	)

	move !lj_source_folder!\src\luajit.exe !lj_dest_folder!\bin
	move !lj_source_folder!\src\lua51.dll !lj_dest_folder!\bin
	move !lj_source_folder!\src\lua51.lib !lj_dest_folder!\lib
	for %%a in (lauxlib.h lua.h lua.hpp luaconf.h lualib.h luajit.h) do ( copy "!lj_source_folder!\src\%%a" "!lj_dest_folder!\include" )

	set LUA_DIR=!lj_dest_folder!
) else (
	call :download_lua %LUA_VER%
	call :download https://github.com/Tieske/luawinmake/archive/master.zip
	call :extract_zip downloads/master.zip downloads\lua-%LUA_VER%
	if not exist downloads\lua-%LUA_VER%\etc mkdir downloads\lua-%LUA_VER%\etc
	move downloads\luawinmake-master\etc\winmake.bat %APPVEYOR_BUILD_FOLDER%\downloads\lua-%LUA_VER%\etc\winmake.bat
	cd downloads\lua-%LUA_VER%
	call etc\winmake
	call etc\winmake install c:\lua%LUA_VER%
	set LUA_DIR=c:\lua%LUA_VER%
)

:: defines LUA_DIR so Cmake can find this Lua install
set PATH=!PATH!;!LUA_DIR!\bin
call !LUA! -v

:: Downloads and installs LuaRocks
cd %APPVEYOR_BUILD_FOLDER%
if !LUAROCKS_VER!==HEAD (
	git clone https://github.com/keplerproject/luarocks.git downloads\luarocks-%LUAROCKS_VER%-win32
) else (
	call :download %LUAROCKS_URL%/luarocks-%LUAROCKS_VER%-win32.zip
	call :extract_zip downloads\luarocks-%LUAROCKS_VER%-win32.zip downloads\luarocks-%LUAROCKS_VER%-win32
)
cd downloads\luarocks-%LUAROCKS_VER%-win32
call install.bat /LUA %LUA_DIR% /Q /LV %LUA_SHORTV% || call :die
set PATH=%PATH%;%ProgramFiles(x86)%\LuaRocks\%LUAROCKS_SHORTV%\;%ProgramFiles(x86)%\LuaRocks\systree\bin
rem set LUA_PATH=%ProgramFiles(x86)%\LuaRocks\%LUAROCKS_SHORTV%\lua\?.lua;%ProgramFiles(x86)%\LuaRocks\%LUAROCKS_SHORTV%\lua\?\init.lua;%ProgramFiles(x86)%\LuaRocks\systree\share\lua\%LUA_SHORTV%\?.lua;%ProgramFiles(x86)%\LuaRocks\systree\share\lua\%LUA_SHORTV%\?\init.lua
rem set LUA_CPATH=%ProgramFiles(x86)%\LuaRocks\systree\lib\lua\%LUA_SHORTV%\?.dll
call luarocks --version || call :die

:: Hack. Create a script that will set all the variables we want to set in the environment.
ECHO set PATH=%PATH%>> "%APPVEYOR_BUILD_FOLDER%\.scripts\setpaths.bat"
ECHO set LUA_DIR=%LUA_DIR%>> "%APPVEYOR_BUILD_FOLDER%\.scripts\setpaths.bat"
call luarocks path>> "%APPVEYOR_BUILD_FOLDER%\.scripts\setpaths.bat"

endlocal

goto :eof


:: helper functions:

:: strip the last extension from a file name
:strip_ext
setlocal
for /F "delims=" %%G in ("%~1") do set _result=%%~nG
endlocal & set _result=%_result%
goto :eof

:: get the filename part of an internet URL (using forward slashes)
:url_basename
setlocal
set _var=%1
:url_basename_loop
set _result=%_var:*/=%
if %_result% NEQ %_var% (
  set _var=%_result%
  goto :url_basename_loop
)
endlocal & set _result=%_result%
goto :eof


:: download a file from the internet using wget
:download
setlocal
set _url=%1
call :url_basename %_url%
set _dest_file=%_result%
if NOT exist downloads\%_dest_file% (
	echo Downloading %_url% ...
	if NOT [%APPVEYOR%]==[] (
		appveyor DownloadFile %_url% -FileName downloads\%_dest_file%
	) else (
		"%WGET%" --no-check-certificate -nc -P downloads %_url% -O downloads\%_dest_file% || call :die
	)
)
endlocal & set _result=downloads\%_dest_file%
goto :eof


:: extract a tarball
:extract_tarball
setlocal
set _tarball=%1
set _dir=%2
call :strip_ext %_tarball%
echo Extracting %_tarball% ...
"%SEVENZIP%" x -aoa -odownloads %_tarball% || call :die
"%SEVENZIP%" x -aoa -o%_dir% downloads\%_result% || call :die
endlocal
goto :eof

:: extract a zip
:extract_zip
setlocal
set _zipfile=%1
set _dir=%2
call :strip_ext %_zipfile%
echo Extracting %_zipfile% ...
"%SEVENZIP%" x -aoa -odownloads %_zipfile% || call :die
endlocal
goto :eof

:: download a Lua tarball and extract it
:download_lua
setlocal
set _ver=%1
call :download %LUAURL%/lua-%_ver%.tar.gz
call :extract_tarball %_result% %APPVEYOR_BUILD_FOLDER%\downloads
set _dir=downloads\lua-%_ver%
endlocal & set _result=0
goto :eof



:: for bailing out when an error occurred
:die
echo Something went wrong ... Sorry!
exit 1
goto :eof
