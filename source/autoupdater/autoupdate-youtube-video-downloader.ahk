#SingleInstance Force

IniRead,version,../settings.ini,Version,Version

;;; Unzip func

Unz(Source, Dest)
{
   psh := ComObjCreate("Shell.Application")
   psh.Namespace(Dest).CopyHere( psh.Namespace(Source).items, 4|16)
}

;;; Updater

oHttp := ComObjCreate("WinHttp.Winhttprequest.5.1")
Try
{ 
	oHttp.open("GET","https://raw.githubusercontent.com/azalty/youtube-video-downloader/master/latestversion.txt")
	oHttp.send()
	
	latestversion := % oHttp.responseText
	_latestversion := ""
	Loop, Parse, latestversion, `n, `r
	{
		_latestversion := A_LoopField
		break
	}
	if (version != _latestversion)
	{
		MsgBox, , AutoUpdater - YouTube video downloader, The latest version (%_latestversion%) will now be downloaded`nPlease, do not close this program or your computer
		
		Gui,1:Add,Progress,x10 y10 w380 h30 BackgroundBlack c00ff00 vProgress, 0
		Gui,1:Add,Text,vDownloadtext x10 w380, Creating folders...
		
		Gui,1:Show,, AutoUpdater - YouTube video downloader
		Gui,1:Submit,NoHide
		Gosub, DownloadLatestVersion
		return
		
		GuiClose:
			ExitApp
		
		DownloadLatestVersion:
			IfExist, %A_WorkingDir%\autoupdate
				FileRemoveDir, %A_WorkingDir%\autoupdate, 1
			Sleep, 500
			FileCreateDir, autoupdate
			
			Progress = 5
			GuiControl,1:,Progress,% Progress
			
			GuiControl,1:,Downloadtext, Creating folders... Done!
			
			Sleep, 500
			
			GuiControl,1:,Downloadtext, Downloading latest version... (might take time)
			
			URLDownloadToFile, https://github.com/azalty/youtube-video-downloader/releases/download/v%_latestversion%/youtube-video-downloader-%_latestversion%.zip, %A_WorkingDir%\autoupdate\youtube-video-downloader-%_latestversion%.zip

			Progress = 40
			GuiControl,1:,Progress,% Progress
			
			GuiControl,1:,Downloadtext, Downloading latest version... Done!
			
			Sleep, 500
			
			GuiControl,1:,Downloadtext, Extracting latest version...
			
			FileZip = %A_WorkingDir%\autoupdate\youtube-video-downloader-%_latestversion%.zip
			FileDir = %A_WorkingDir%\autoupdate
			Unz(FileZip, FileDir)
			
			Progress = 60
			GuiControl,1:,Progress,% Progress
			
			GuiControl,1:,Downloadtext, Extracting latest version... Done!
			
			
			Sleep, 500
			
			GuiControl,1:,Downloadtext, Removing the content we don't want...
			FileRemoveDir, %A_WorkingDir%\autoupdate\YouTube Video Downloader (%_latestversion%)\autoupdater, 1
			FileRemoveDir, %A_WorkingDir%\autoupdate\YouTube Video Downloader (%_latestversion%)\downloads, 1
			FileDelete, %FileZip%
			
			Progress = 65
			GuiControl,1:,Progress,% Progress
			
			GuiControl,1:,Downloadtext, Removing the content we don't want... Done!
			
			Sleep, 500
			
			GuiControl,1:,Downloadtext, Deleting the old version...
			
			Loop, Files, %A_WorkingDir%\..\*
			{
				FileDelete, %A_LoopFileLongPath%
			}
			Loop, Files, %A_WorkingDir%\..\*, D
			{
				If A_LoopFileName not In autoupdater,downloads
				{
					FileRemoveDir, %A_LoopFileLongPath%, 1
				}
			}
			
			Progress = 80
			GuiControl,1:,Progress,% Progress
			GuiControl,1:,Downloadtext, Deleting the old version... Done!
			
			Sleep, 500
			
			GuiControl,1:,Downloadtext, Replacing the new version...
			
			FileCopyDir, %A_WorkingDir%\autoupdate\YouTube Video Downloader (%_latestversion%), %A_WorkingDir%\.., 1
			
			Progress = 95
			GuiControl,1:,Progress,% Progress
			GuiControl,1:,Downloadtext, Replacing the new version... Done!
			
			Sleep, 500
			
			GuiControl,1:,Downloadtext, Deleting temporary files...
			
			FileRemoveDir, %A_WorkingDir%\autoupdate, 1
			
			Progress = 100
			GuiControl,1:,Progress,% Progress
			GuiControl,1:,Downloadtext, Deleting temporary files... Done!
			
			Sleep, 500
			Gui,1:Destroy
			MsgBox, , AutoUpdater - YouTube video downloader, The latest version (%_latestversion%) has been installed!
			ExitApp
	}
	else
	{
		MsgBox, , AutoUpdater - YouTube video downloader, Seems like you are already up to date!`nIf you believe this is an error, please report it on Github`n`nThe AutoUpdater will now close
		ExitApp
	}
}
Catch
{
	MsgBox, , AutoUpdater - YouTube video downloader, Oops... the AutoUpdater crashed...`nAre you connected to internet?`n`nThe AutoUpdater will now close
	ExitApp
}