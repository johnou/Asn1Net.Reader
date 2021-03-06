@rem Add path to MSBuild Binaries
setlocal

@rem preparing environment

@IF EXIST "c:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\Tools\vsvars32.bat" SET devenv="c:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\Tools\vsvars32.bat"
@IF EXIST "c:\Program Files\Microsoft Visual Studio 10.0\Common7\Tools\vsvars32.bat" SET devenv="c:\Program Files\Microsoft Visual Studio 10.0\Common7\Tools\vsvars32.bat"
@IF EXIST "c:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\Tools\vsvars32.bat" SET devenv="c:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\Tools\vsvars32.bat"
@IF EXIST "c:\Program Files\Microsoft Visual Studio 11.0\Common7\Tools\vsvars32.bat" SET devenv="c:\Program Files\Microsoft Visual Studio 11.0\Common7\Tools\vsvars32.bat"
@IF EXIST "c:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\vsvars32.bat" SET devenv="C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\vsvars32.bat"
@IF EXIST "C:\Program Files\Microsoft Visual Studio 12.0\Common7\Tools\vsvars32.bat" SET devenv="C:\Program Files\Microsoft Visual Studio 12.0\Common7\Tools\vsvars32.bat"


set cur_dir=%CD%
call %devenv% || exit /b 1

set SLNPATH=src\Asn1Net.Reader\Asn1Net.Reader.sln

IF EXIST .nuget\nuget.exe goto restore

echo Downloading nuget.exe
md .nuget
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile '.nuget\nuget.exe'"

:restore
IF EXIST packages goto run
.nuget\NuGet.exe restore %SLNPATH%

:run
@rem cleanin sln
msbuild %SLNPATH% /p:Configuration=Release /target:Clean || exit /b 1
@rem build desktop version (.NET 4.0)
msbuild %SLNPATH% /p:Configuration=Release /target:Build || exit /b 1
@rem build PCL version
msbuild %SLNPATH% /p:Configuration=Release /p:Portability=Desktop /target:Build || exit /b 1

endlocal

setlocal

@rem set variables
set OUTDIR=build\Asn1Net.Reader
set SRCDIR=src\Asn1Net.Reader\Asn1Net.Reader\bin\

@rem prepare output directory
rmdir /S /Q %OUTDIR%
mkdir %OUTDIR%\pcl || exit /b 1
mkdir %OUTDIR%\desktop || exit /b 1

@rem copy files to output directory
copy %SRCDIR%\pcl\Release\Asn1Net.Reader.dll %OUTDIR%\pcl || exit /b 1
copy %SRCDIR%\pcl\Release\Asn1Net.Reader.XML %OUTDIR%\pcl || exit /b 1
copy %SRCDIR%\Release\Asn1Net.Reader.dll %OUTDIR%\desktop || exit /b 1
copy %SRCDIR%\Release\Asn1Net.Reader.XML %OUTDIR%\desktop || exit /b 1

@rem set license variables
set BUILDDIR=build

@rem copy licenses to output directory
copy %SRCDIR%\Release\LICENSE.txt %BUILDDIR% || exit /b 1
copy %SRCDIR%\Release\NOTICE.txt %BUILDDIR% || exit /b 1
copy LICENSE-3RD-PARTY %BUILDDIR%\3rd-party-license.txt || exit /b 1
copy README.md %BUILDDIR%\Readme.txt || exit /b 1

@rem copy make_nuget.bat and nuspec file
copy make_nuget.bat %BUILDDIR% || exit /b 1
copy Asn1Net.Reader.nuspec %BUILDDIR% || exit /b 1

endlocal

@echo BUILD SUCCEEDED !!!
@exit /b 0
