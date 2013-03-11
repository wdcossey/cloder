What is it?
-----------
"IL-2 Sturmovik: Cliffs of Dover" Loader for Windows® 8.

	CloDer translates to:
		[Cl]iffs
		  [o]f
		   [D]over
		  loD[er] (without the "a", because it just worked at the time :P).

What does it do?
----------------
It ensures you can play "IL-2 Sturmovik: Cliffs of Dover" in Windows® 8, duh. ;-]

The hook library ("CloDer.dll") patches "Launcher.exe" (in memory) to fix an issue (with "WriteProcessMemory") when running under Windows® 8.
Just to clarify the issue is NOT with Windows® 8 but rather with "maddox.dll" (a bug within the ".NET Reactor" protection scheme).

How do I use it?
----------------
Place the files ("CloDer.exe" and "CloDer.dll") in your CloD directory ("...\steamapps\common\il-2 sturmovik cliffs of dover"), run "CloDer.exe", off you go.

	Additional Info: 
		* If you do NOT want to put the files in your game folder, you can run "CloDer.exe" from anywhere, it will simply ask you for "Launcher.exe" when run.

		* If you want to get smart, make a shortcut to "CloDer.exe" with a parameter pointing to "Launcher.exe".
			See "CloDer Parameters:" below.

Before you play!
----------------
Ensure that you have installed the accompanying software/run-times (these are a must have!):

	* Visual C++ 2010 Run-time Components
		Installation can be found in "...\il-2 sturmovik cliffs of dover\redist\VCRedist\", run "vcredist_x86.exe".
		Updated installation (Service Pack 1):	http://www.microsoft.com/en-us/download/details.aspx?id=8328
	* DirectX
		DirectX installation can be found in "...\il-2 sturmovik cliffs of dover\redist\DirectX\", run "DXSETUP.exe".
		Updated installation (Web Installer):	http://www.microsoft.com/en-us/download/details.aspx?id=35

CloDer Parameters:
------------------
Parameters are very basic, any additional parameters specified will be passed onto CloD ("Launcher.exe").

	* Example(s):
		- Run the game:
			"C:\Downloads\CloDer.exe"
			OR
			"C:\Downloads\CloDer.exe" "C:\Program Files (x86)\Steam\steamapps\common\il-2 sturmovik cliffs of dover\Launcher.exe"

		- Start a server:
			"C:\Downloads\CloDer.exe" -server
			OR
			"C:\Downloads\CloDer.exe" "C:\Program Files (x86)\Steam\steamapps\common\il-2 sturmovik cliffs of dover\Launcher.exe" -server

		- Run the game with a Mod[ification] (using "kegetys.dll"):
			"C:\Downloads\CloDer.exe" -mod=nomipmaps -mod=nossao
			OR
			"C:\Downloads\CloDer.exe" "C:\Program Files (x86)\Steam\steamapps\common\il-2 sturmovik cliffs of dover\Launcher.exe" -mod=nomipmaps -mod=nossao

	* Note(s):
		As of version 0.0.0.2 parameters will take preference over local files (therefore you can specify a different 
			"Launcher.exe" even if one already exists in the same directory as CloDer).
		The first executable found in the "CloDer.exe" parameters is considered to be "Launcher.exe".
		Any path(s) counting a white-space must be wrapped in quotes.

A few words of warning:
-----------------------
I do not play "IL-2 Sturmovik: Cliffs of Dover", this patch was made to address an issue my friend had with the game (under Windows® 8), I have not tested any  
aspects of actual game play.

"CloDer.dll" should be automatically unloaded from "Launcher.exe" after the game launches (but this is not guaranteed).
Be weary when playing online as this game is VAC ("Valve Anti-Cheat") enabled, if this fix is detected as an exploit (which it is not) you will get banned.

It is possible that your Anti-Virus might go postal and kill "CloDer.exe" and/or "CloDer.dll", you can ignore this (perhaps add "CloDer.exe" and "CloDer.dll" to the white-list).
If you are still unsure, you are more than welcome to not run the application and enjoy life without your game.

If you want to rename "CloDer.exe", ensure that the accompanying .dll ("CloDer.dll") has the same naming convention.
For example if you rename "CloDer.exe" to "my_odd_file_name.exe" then you must rename "CloDer.dll" to "my_odd_file_name.dll".

Technical References:
---------------------
http://msdn.microsoft.com/en-us/library/windows/desktop/ms684320.aspx
http://msdn.microsoft.com/en-us/library/windows/desktop/ms684880.aspx
http://msdn.microsoft.com/en-us/library/windows/desktop/ms681674.aspx
http://msdn.microsoft.com/en-us/library/windows/desktop/aa366898.aspx | http://msdn.microsoft.com/en-us/library/windows/desktop/aa366899.aspx

Version History:
----------------
	* 0.0.0.2:
		Additional parameters specified to "CloDer.exe" will be passed onto "Launcher.exe".
		Minor enhancements to "CloDer.exe" & "CloDer.dll".
		I have left "CloDer.exe" & "CloDer.dll" unpacked (previously I used UPX), this should tone down (+-50%) the false positives from "heuristically challenged" 
			anti-virus products.

	* 0.0.0.1:
		Initial release.

File Hashes:
------------
	* 0.0.0.2:
		- CloDer.exe:
			SHA1 - 8e93a724d211437f3e6b70117c6034e8f59e30d9
			MD5  - bb615002fc3998124dab3faa7eff32ce
		- CloDer.dll:
			SHA1 - c4acd75b8e3da5216680ef5ebff836fee116c735
			MD5  - eecfad7dfe828fc66cde88feda26ba4f

Credits:
--------
Written by: sYk0.
Written for: TonyD.