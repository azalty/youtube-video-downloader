#SingleInstance Force

;;; Config Part

IniRead,version,settings.ini,Version,Version

;; Audio

isaudio = 1

if isaudio
{
	IniRead,aThumbnail,settings.ini,Audio,AddThumbnail
	IniRead,aQuality,settings.ini,General,AudioQuality
	IniRead,aForceFrequency,settings.ini,General,ForceFrequency
	
	_aThumbnail := ""
	_aQuality := ""
	_aForceFrequency := ""
	
	if %aThumbnail%
		_aThumbnail := " --embed-thumbnail"
	if %aQuality%
		_aQuality := " --audio-quality 0"
	if %aForceFrequency%
		_aForceFrequency := " --postprocessor-args ""-ar 44100"""
}

;; Video

isvideo = 0



;; General

IniRead,Playlist,settings.ini,General,DownloadPlaylist
IniRead,Thumbnail,settings.ini,General,SaveThumbnail
IniRead,Updates,settings.ini,Updates,CheckUpdates
IniRead,Filenames,settings.ini,General,RestrictFilenames

_Playlist := " --no-playlist"
_Thumbnail := ""
_Filenames := ""

if %Playlist%
	_Playlist := " --yes-playlist"
if %Thumbnail%
	_Thumbnail := " --write-thumbnail"
if %Filenames%
	_Filenames := " --restrict-filenames"



;;; Update checker

if Updates
{
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
			Gui,1:Add,Text,x10, Your version of YouTube video downloader is outdated.`n`nCurrent version: %version%`nLatest version: %_latestversion%`n`nPlease install the latest version to get the best experience`nElse you can disable CheckUpdates in settings.ini
			Gui,1:Add,Button,x10 w200 h40 gAutoUpdate, Use the AutoUpdater
			Gui,1:Add,Button,x10 w200 h40 gManualDL, Manual Download
			Gui,1:Add,Button,x10 w200 h40 gDontUpdate, Don't update
			
			Gui,1:Show,, YouTube video downloader
			return
			
			GuiClose:
				ExitApp
			
			AutoUpdate:
				SetWorkingDir, %A_ScriptDir%\autoupdater
				Run, autoupdate-youtube-video-downloader.exe
				ExitApp
			
			ManualDL:
				Run, https://github.com/azalty/youtube-video-downloader/releases/latest
				ExitApp
			
			DontUpdate:
				Gui,1:Destroy
				Gosub, Next
		}
	}
	Catch
	{
		MsgBox, , YouTube video downloader, Impossible to retrieve the last version`nAre you connected to internet?`n`nDisable CheckUpdates in settings.ini if you don't want to check for updates anymore
	}
}

;;; First install part

Next:

IfNotExist, %A_ScriptDir%\youtube-dl\ffmpeg.exe
{
	MsgBox, , YouTube video downloader, Seems like you are starting this script for the first time.`nLet us setup the best options for you...
	if %A_Is64bitOS%
	{
		FileMove, %A_ScriptDir%\youtube-dl\64bits\ffmpeg.exe, %A_ScriptDir%\youtube-dl\
		FileRemoveDir, %A_ScriptDir%\youtube-dl\64bits\, 1
		FileRemoveDir, %A_ScriptDir%\youtube-dl\32bits\, 1
		MsgBox, , YouTube video downloader, 64bits detected!`nEverything is ready! Thanks for using azalty/youtube-video-downloader
	}
	else
	{
		FileMove, %A_ScriptDir%\youtube-dl\32bits\ffmpeg.exe, %A_ScriptDir%\youtube-dl\
		FileRemoveDir, %A_ScriptDir%\youtube-dl\64bits\,1
		FileRemoveDir, %A_ScriptDir%\youtube-dl\32bits\, 1
		MsgBox, , YouTube video downloader, 32bits detected!`nEverything is ready! Thanks for using azalty/youtube-video-downloader
	}
}

;;; Script Part

InputBox, videolink, YouTube audio downloader, Enter the link of the video you want to download the audio from`nEx:`nhttps://www.youtube.com/watch?v=xxxxxxxxxxx`nhttps://youtu.be/xxxxxxxxxxx, , 400, 180
if ErrorLevel
    ExitApp
else
{
	Run "%A_ScriptDir%\youtube-dl\youtube-dl.exe" -x --audio-format mp3 -o "%A_ScriptDir%/downloads/`%(title)s.`%(ext)s" %videolink%%_aThumbnail%%_aQuality%%_aForceFrequency%%_Playlist%%_Thumbnail%%_Filenames%
	ExitApp
}