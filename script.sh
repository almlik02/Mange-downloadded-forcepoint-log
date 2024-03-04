@echo off

REM Define source, destination, and 7-Zip executable path
SET sourceFolder="G:\zipfolder"
SET destinationFolder="G:\unzipfolder"
SET gzipExePath="C:\Program Files\7-Zip\7z.exe"
SET logFile="%destinationFolder%\processed_files.txt"

REM Ensure the destination folder exists
if not exist "%destinationFolder%" mkdir "%destinationFolder%"

REM Create log file if it doesn't exist
if not exist "%logFile%" type nul > "%logFile%"

REM Decompress all .gz files in the source folder to the destination folder
for %%i in ("%sourceFolder%\*.gz") do (
    REM Check if file is in the log file (already processed)
    findstr /i /c:"%%~ni" "%logFile%" >nul
    if errorlevel 1 (
        pushd "%destinationFolder%"
        echo Extracting %%i...
        %gzipExePath% e "%%i" -so > "%%~ni.csv" 2>"extract_error.log"
        if not errorlevel 1 (
            echo Successfully extracted: %%~ni
            del "%%i" /f /q
            echo %%~ni >> "%logFile%"
        ) else (
            echo Extraction failed for %%i. Check extract_error.log for details.
        )
        popd
    ) else (
        echo Skipping duplicate file: %%~ni
    )
)

REM Delete decompressed files older than 1 hour using PowerShell
forfiles /p "%destinationFolder%" /m * /c "cmd /c if @isdir==FALSE (powershell -command \"if ((Get-Item @path).LastWriteTime -lt (Get-Date).AddHours(-1)) {Remove-Item @path -Force}\")"
