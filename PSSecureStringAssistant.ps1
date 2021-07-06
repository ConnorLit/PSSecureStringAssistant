<#
	.SYNOPSIS 
		A tool to assist with creating encrypted secure string files.
		The files are then used to import those strings for credentials (as an example).
		This is critical for public script security, so those who read scripts cannot extract confidential data.

    .NOTES
		Created by LincolnOtter

	.LINK
		GitHub Repo: https://github.com/LincolnOtter/PSSecureStringAssistant

#>



function Show-FormSecureString {

	#region ======================================= Import Assemblies 
	[void][reflection.assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	Add-Type -AssemblyName PresentationCore, PresentationFramework
	#endregion 

	#region ======================================= Build Form Objects
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$FormSecureString = 						New-Object 'System.Windows.Forms.Form'
	$ButtonCopyScript = 			New-Object 'System.Windows.Forms.Button'
	$TextboxOutputScript = 			New-Object 'System.Windows.Forms.TextBox'
	$ButtonExportFile = 			New-Object 'System.Windows.Forms.Button'
	$TextBoxOutputName = 			New-Object 'System.Windows.Forms.TextBox'
	$TextboxOutputFolder = 			New-Object 'System.Windows.Forms.TextBox'
	$TextboxString = 				New-Object 'System.Windows.Forms.TextBox'
	$labelMachineName = 			New-Object 'System.Windows.Forms.Label'
	$labelUsername = 				New-Object 'System.Windows.Forms.Label'
	$labelNoteThatEncryptedSec = 	New-Object 'System.Windows.Forms.Label'
	$labelYouCanUseThisAssista = 	New-Object 'System.Windows.Forms.Label'
	$ButtonBrowse = 				New-Object 'System.Windows.Forms.Button'
	$ImageStringInvisible = 		New-Object 'System.Windows.Forms.PictureBox'
	$ImageStringVisible = 			New-Object 'System.Windows.Forms.PictureBox'
	$InitialFormWindowState = 		New-Object 'System.Windows.Forms.FormWindowState'

	# Initialise
	$TextBoxOutputName.Text = 		"$env:USERNAME"+"_"+"$env:COMPUTERNAME"+"_Secure.txt"
	#endregion 

	#region ======================================= Globals
	# Globals
	$global:HideString = $true;
	$global:StringDefault = " Enter String";
	$global:InitialDirectory = $PSScriptRoot
	#endregion 

	#region ======================================= Functions
	Function Write-Output()
	{
		param (
			[string[]]$MessageString
		)
		# Don't add line if empty
		If ($TextboxOutputScript.text -ne "")
		{
			$TextboxOutputScript.AppendText("`r`n")
		}
		# Add String
		$TextboxOutputScript.AppendText($MessageString)
		# Scroll Down
		$TextboxOutputScript.ScrollToCaret() 
	}
	function New-Alert()
	{
		param (
			[string[]]$AlertString
		)
		[System.Windows.MessageBox]::Show($AlertString, 'Alert', 'OK', 'Information')
	}
	
	function Update-StringVisible()
	{
		# Change to Password Text?
		if ($TextboxString.Text -ne $global:StringDefault)
		{
			$TextboxString.UseSystemPasswordChar = $global:HideString;
		}
		else
		{
			$TextboxString.UseSystemPasswordChar = $false;
		}
	}
	#endregion

	#region ======================================= Script Blocks
	$TextboxString_Enter = {
		if ($TextboxString.Text -eq $global:StringDefault) # String not entered yet
		{
			# Clear text ready for input
			$TextboxString.Text = ""
		};
		Update-StringVisible
	};
	$TextboxString_Leave = {
		if ($TextboxString.Text -eq "") # String not entered yet
		{
			# Clear text ready for input
			$TextboxString.Text = $global:StringDefault;
		};
		Update-StringVisible
	}
	$ImageStringInvisible_Click = {
		$global:HideString = $false;
		Update-StringVisible
		$ImageStringInvisible.Visible = $false;
		$ImageStringVisible.Visible = $true;
	}
	
	$ImageStringVisible_Click = {
		$global:HideString = $true;
		Update-StringVisible
		$ImageStringVisible.Visible = $false;
		$ImageStringInvisible.Visible = $true;
	}
	
	$ButtonCopyScript_Click = {
		Set-Clipboard -Value $TextboxOutputScript.Text
	}
	$buttonBrowse_Click={
		$OpenDialog = New-Object -TypeName System.Windows.Forms.FolderBrowserDialog
		# Initiat ebrowse path can be set by using initialDirectory
		$OpenDialog.SelectedPath = $global:InitialDirectory;
		$OpenDialog.ShowDialog() | Out-Null;
		# Gather Target CSV file
		$global:InitialDirectory = $OpenDialog.SelectedPath;
		$FilePath = $OpenDialog.SelectedPath;
		# Assigining the file choosen path to the text box
		$TextboxOutputFolder.Text = $FilePath;
	}
	$buttonExportFile_Click = {
		# Variables
		$Str_Pass = $TextboxString.Text
		$Out_Path = $TextboxOutputFolder.Text
		$Out_Filename = $TextBoxOutputName.Text
		# Check Password String
		if ($Str_Pass -eq $global:StringDefault)
		{
			New-Alert "Please insert a string to convert..."
			RETURN
		}
		if ($TextboxOutputFolder.Text -eq " Select output folder...") {
			New-Alert "Please select an output folder."
	        RETURN
	    }
	    if ($Str_Pass.Length -gt 0) {
	        $Str_Pass | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File "$Out_Path\$Out_Filename"
	        # Write Output to Copy
			$TextboxOutputScript.Clear()
	        Write-Output("`$SecureEncrypt = `"$Out_Path\$Out_Filename`"")
			Write-Output("`$CredPassword = Get-Content -Path `$SecureEncrypt | ConvertTo-SecureString")
			Write-Output("`$CredUser = `"Enter Username Here`"")
	        Write-Output('$Credentials = New-Object System.Management.Automation.PSCredential ($CredUser, $CredPassword)')
	    } else {
			New-Alert "Please enter a password into the password Textbox."
	    }
	}
	#endregion
	
	#region ======================================= Build Form
	$FormSecureString.SuspendLayout()
	# FormSecureString
	$FormSecureString.Controls.Add($ButtonCopyScript)
	$FormSecureString.Controls.Add($TextboxOutputScript)
	$FormSecureString.Controls.Add($ButtonExportFile)
	$FormSecureString.Controls.Add($TextBoxOutputName)
	$FormSecureString.Controls.Add($TextboxOutputFolder)
	$FormSecureString.Controls.Add($TextboxString)
	$FormSecureString.Controls.Add($labelMachineName)
	$FormSecureString.Controls.Add($labelUsername)
	$FormSecureString.Controls.Add($labelNoteThatEncryptedSec)
	$FormSecureString.Controls.Add($labelYouCanUseThisAssista)
	$FormSecureString.Controls.Add($ButtonBrowse)
	$FormSecureString.Controls.Add($ImageStringInvisible)
	$FormSecureString.Controls.Add($ImageStringVisible)
	$FormSecureString.AutoScaleDimensions 				= New-Object System.Drawing.SizeF(6, 13)
	$FormSecureString.AutoScaleMode 					= 'Font'
	$FormSecureString.BackColor 						= [System.Drawing.Color]::FromArgb(255, 41, 46, 51)
	$FormSecureString.ClientSize 						= New-Object System.Drawing.Size(591, 584)
	$FormSecureString.MaximizeBox 						= $False
	$FormSecureString.Name 								= 'FormSecureString'
	$FormSecureString.ShowIcon 							= $False
	$FormSecureString.SizeGripStyle 					= 'Hide'
	$FormSecureString.Text 								= 'PowerShell Secure String Assistant'

	# ButtonCopyScript
	$ButtonCopyScript.BackColor 						= [System.Drawing.Color]::FromArgb(255, 29, 33, 37)
	$ButtonCopyScript.Cursor 							= 'Hand'
	$ButtonCopyScript.FlatAppearance.BorderSize 		= 0
	$ButtonCopyScript.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(255, 57, 64, 71)
	$ButtonCopyScript.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(255, 47, 54, 61)
	$ButtonCopyScript.FlatStyle 						= 'Flat'
	$ButtonCopyScript.Font 								= [System.Drawing.Font]::new('Segoe UI Semibold', '9', [System.Drawing.FontStyle]'Bold')
	$ButtonCopyScript.ForeColor 						= [System.Drawing.Color]::FromArgb(255, 245, 245, 247)
	#region Binary Data
	$Formatter_binaryFomatter = New-Object System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
	$System_IO_MemoryStream = New-Object System.IO.MemoryStream (,[byte[]][System.Convert]::FromBase64String('
AAEAAAD/////AQAAAAAAAAAMAgAAAFFTeXN0ZW0uRHJhd2luZywgVmVyc2lvbj00LjAuMC4wLCBD
dWx0dXJlPW5ldXRyYWwsIFB1YmxpY0tleVRva2VuPWIwM2Y1ZjdmMTFkNTBhM2EFAQAAABVTeXN0
ZW0uRHJhd2luZy5CaXRtYXABAAAABERhdGEHAgIAAAAJAwAAAA8DAAAAcAMAAAKJUE5HDQoaCgAA
AA1JSERSAAAAFAAAABQIBgAAAI2JHQ0AAAGDaUNDUElDQyBwcm9maWxlAAAoz5WSO0gDQRRFT6IS
EcXCFCIWW6iVAVERS4liEBQkRvBXuLsxMZDdhN0EG0vBNmDhp/FX2Fhra2ErCIIfEDs7K0UbkfXN
RkgQIjgwzOHO3MvMewPBg6xpufV9YNkFJx6LanPzC1romRB1QBu9uunmp2bGE9QcH7cE1HoTUVn8
b7QkV1wTAprwiJl3CsLLwkNrhbziHeGwuaonhU+Fex25oPC90o0yvyhO+xxUmWEnER8VDgtr6So2
qthcdSzhQeGupGVLfnCuzEnF64qtbNH8uad6YfOKPTujdJmdxJhgimk0DIpkyFIgIqstiktc9qM1
/B2+f1pchrgymOIYI4eF7vtRPfhdWzc10F9Oao5Cw5PnvXVDaAu+Sp73eeh5X0dQ9wgXdsWfO4Dh
d9FLFa1rH1o34OyyohnbcL4J7Q953dF9SfU/mErB64m0aV4+wzU0LZbr9rPP8R0kpFaTV7C7Bz1p
yV6q8e7G6rr9ecavH9FvQsxylL+aV1MAAAAJcEhZcwAALiIAAC4iAari3ZIAAAAHdElNRQflBwMB
DQyXEgs+AAAAGXRFWHRDb21tZW50AENyZWF0ZWQgd2l0aCBHSU1QV4EOFwAAAVtJREFUOE/V1T1K
A1EUhuEgQUKwEAmCuAktRDeQJYilpRKJjZ0gsdLewspaRMFdaCkiWAgWWiuChfiHxveVMzpJZhJw
Kg88kOSe+3FD5p6Ukmq322WMY3KACVRiW3bRUMUyTnE5wDl2UIvtvcViHY94wT3u+njCB9ZQjojO
YqERTfuYwyxmMkxjA284QG5gE5/YjvejvsYVbrp4Sns96S3OsIih7zCLNz+BLmAFnvgdrxk8YfLa
vgfUI64nsIIjuGkVnnYsh0/FHgxtRFxu4DPmoyW3Yo97m/FR38CFaMmt2POPA7fgFTxEocAl+Eud
YB0XKBQ4BR/a5NmzoVCgX9PQFnZxjb8HJsWHBo/gGMUDLRaG4cX3pmzCoeCwyOIgcaB03pR0seAp
HU02OQC6x1eao86R5+j7vcvdxWINDlGHadaQTXMoO5yrsT27aPABd9xn/Q2kOSBiLpZKX4Wigj+a
vm47AAAAAElFTkSuQmCCCw=='))
	#endregion
	$ButtonCopyScript.Image 							= $Formatter_binaryFomatter.Deserialize($System_IO_MemoryStream)
	$Formatter_binaryFomatter 							= $null
	$System_IO_MemoryStream 							= $null
	$ButtonCopyScript.ImageAlign 						= 'MiddleRight'
	$ButtonCopyScript.Location 							= New-Object System.Drawing.Point(502, 409)
	$ButtonCopyScript.Name 								= 'ButtonCopyScript'
	$ButtonCopyScript.Size 								= New-Object System.Drawing.Size(77, 26)
	$ButtonCopyScript.TabIndex 							= 12
	$ButtonCopyScript.Text 								= 'Copy'
	$ButtonCopyScript.TextAlign 						= 'MiddleLeft'
	$ButtonCopyScript.UseVisualStyleBackColor 			= $False
	$ButtonCopyScript.add_Click($ButtonCopyScript_Click)

	# TextboxOutputScript
	$TextboxOutputScript.BackColor 						= [System.Drawing.Color]::FromArgb(255, 36, 41, 46)
	$TextboxOutputScript.BorderStyle 					= 'FixedSingle'
	$TextboxOutputScript.Font 							= [System.Drawing.Font]::new('Segoe UI Semibold', '10', [System.Drawing.FontStyle]'Bold')
	$TextboxOutputScript.ForeColor 						= [System.Drawing.Color]::FromArgb(255, 180, 180, 182)
	$TextboxOutputScript.Location 						= New-Object System.Drawing.Point(12, 440)
	$TextboxOutputScript.Multiline 						= $True
	$TextboxOutputScript.Name 							= 'TextboxOutputScript'
	$TextboxOutputScript.Size 							= New-Object System.Drawing.Size(567, 132)
	$TextboxOutputScript.TabIndex 						= 11
	$TextboxOutputScript.Text 							= ' Import script will be generated here...'
	#
	# ButtonExportFile
	#
	$ButtonExportFile.BackColor 						= [System.Drawing.Color]::FromArgb(255, 29, 33, 37)
	$ButtonExportFile.Cursor 							= 'Hand'
	$ButtonExportFile.FlatAppearance.BorderSize 		= 0
	$ButtonExportFile.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(255, 57, 64, 71)
	$ButtonExportFile.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(255, 47, 54, 61)
	$ButtonExportFile.FlatStyle 						= 'Flat'
	$ButtonExportFile.Font 								= [System.Drawing.Font]::new('Segoe UI Semibold', '9', [System.Drawing.FontStyle]'Bold')
	$ButtonExportFile.ForeColor 						= [System.Drawing.Color]::FromArgb(255, 245, 245, 247)
	$ButtonExportFile.ImageAlign 						= 'MiddleLeft'
	$ButtonExportFile.Location 							= New-Object System.Drawing.Point(43, 373)
	$ButtonExportFile.Name 								= 'ButtonExportFile'
	$ButtonExportFile.Size 								= New-Object System.Drawing.Size(142, 27)
	$ButtonExportFile.TabIndex 							= 10
	$ButtonExportFile.Text				 				= 'Export file'
	$ButtonExportFile.UseVisualStyleBackColor 			= $False
	$ButtonExportFile.add_Click($buttonExportFile_Click)
	#
	# TextBoxOutputName
	#
	$TextBoxOutputName.BackColor 						= [System.Drawing.Color]::FromArgb(255, 29, 33, 37)
	$TextBoxOutputName.BorderStyle 						= 'FixedSingle'
	$TextBoxOutputName.Font 							= [System.Drawing.Font]::new('Segoe UI Semibold', '10', [System.Drawing.FontStyle]'Bold')
	$TextBoxOutputName.ForeColor 						= [System.Drawing.Color]::FromArgb(255, 180, 180, 182)
	$TextBoxOutputName.Location 						= New-Object System.Drawing.Point(43, 338)
	$TextBoxOutputName.Name 							= 'TextBoxOutputName'
	$TextBoxOutputName.Size 							= New-Object System.Drawing.Size(396, 25)
	$TextBoxOutputName.TabIndex 						= 9
	#
	# TextboxOutputFolder
	#
	$TextboxOutputFolder.BackColor 						= [System.Drawing.Color]::FromArgb(255, 41, 46, 51)
	$TextboxOutputFolder.BorderStyle 					= 'FixedSingle'
	$TextboxOutputFolder.Font 							= [System.Drawing.Font]::new('Segoe UI Semibold', '10', [System.Drawing.FontStyle]'Bold')
	$TextboxOutputFolder.ForeColor 						= [System.Drawing.Color]::FromArgb(255, 180, 180, 182)
	$TextboxOutputFolder.Location 						= New-Object System.Drawing.Point(43, 306)
	$TextboxOutputFolder.Name 							= 'TextboxOutputFolder'
	$TextboxOutputFolder.Size 							= New-Object System.Drawing.Size(396, 25)
	$TextboxOutputFolder.TabIndex 						= 8
	$TextboxOutputFolder.Text 							= ' Select output folder...'
	#
	# TextboxString
	#
	$TextboxString.BackColor 							= [System.Drawing.Color]::FromArgb(255, 29, 33, 37)
	$TextboxString.BorderStyle 							= 'FixedSingle'
	$TextboxString.Font	 								= [System.Drawing.Font]::new('Segoe UI Semibold', '10', [System.Drawing.FontStyle]'Bold')
	$TextboxString.ForeColor 							= [System.Drawing.Color]::FromArgb(255, 180, 180, 182)
	$TextboxString.Location 							= New-Object System.Drawing.Point(43, 263)
	$TextboxString.Name 								= 'TextboxString'
	$TextboxString.Size 								= New-Object System.Drawing.Size(396, 25)
	$TextboxString.TabIndex 							= 5
	$TextboxString.Text 								= ' Enter String'
	$TextboxString.add_Enter($TextboxString_Enter)
	$TextboxString.add_Leave($TextboxString_Leave)
	#
	# labelMachineName
	#
	$labelMachineName.BackColor 						= [System.Drawing.Color]::FromArgb(255, 52, 59, 66)
	$labelMachineName.Font 								= [System.Drawing.Font]::new('Segoe UI Semibold', '11', [System.Drawing.FontStyle]'Bold')
	$labelMachineName.ForeColor 						= [System.Drawing.Color]::Khaki 
	$labelMachineName.Location 							= New-Object System.Drawing.Point(300, 12)
	$labelMachineName.Name 								= 'labelMachineName'
	$labelMachineName.Size 								= New-Object System.Drawing.Size(280, 43)
	$labelMachineName.TabIndex 							= 4
	$labelMachineName.Text 								= "Machine: $env:COMPUTERNAME"
	$labelMachineName.TextAlign 						= 'MiddleCenter'
	#
	# labelUsername
	#
	$labelUsername.BackColor 							= [System.Drawing.Color]::FromArgb(255, 52, 59, 66)
	$labelUsername.Font 								= [System.Drawing.Font]::new('Segoe UI Semibold', '11', [System.Drawing.FontStyle]'Bold')
	$labelUsername.ForeColor 							= [System.Drawing.Color]::Khaki 
	$labelUsername.Location 							= New-Object System.Drawing.Point(11, 12)
	$labelUsername.Name 								= 'labelUsername'
	$labelUsername.Size 								= New-Object System.Drawing.Size(280, 43)
	$labelUsername.TabIndex 							= 3
	$labelUsername.Text 								= "User: $env:USERNAME"
	$labelUsername.TextAlign 							= 'MiddleCenter'
	#
	# labelNoteThatEncryptedSec
	#
	$labelNoteThatEncryptedSec.Font 					= [System.Drawing.Font]::new('Segoe UI', '10', [System.Drawing.FontStyle]'Italic')
	$labelNoteThatEncryptedSec.ForeColor 				= [System.Drawing.Color]::FromArgb(255, 255, 172, 172)
	$labelNoteThatEncryptedSec.Location 				= New-Object System.Drawing.Point(12, 165)
	$labelNoteThatEncryptedSec.Name 					= 'labelNoteThatEncryptedSec'
	$labelNoteThatEncryptedSec.Size 					= New-Object System.Drawing.Size(567, 81)
	$labelNoteThatEncryptedSec.TabIndex 				= 2
	$labelNoteThatEncryptedSec.Text 					= 'Note that Encrypted Secure Strings can only be decrypted by the Creator Account and on the machine it was created with.
Therefore, be sure to run scripts with the same account, or else the decrypted Secure Strings will be incorrect.
(Creator and Machine information is displayed above).'
	#
	# labelYouCanUseThisAssista
	#
	$labelYouCanUseThisAssista.Font 					= [System.Drawing.Font]::new('Segoe UI Semibold', '10')
	$labelYouCanUseThisAssista.ForeColor 				= [System.Drawing.Color]::FromArgb(255, 245, 245, 247)
	$labelYouCanUseThisAssista.Location 				= New-Object System.Drawing.Point(12, 73)
	$labelYouCanUseThisAssista.Name 					= 'labelYouCanUseThisAssista'
	$labelYouCanUseThisAssista.Size 					= New-Object System.Drawing.Size(567, 81)
	$labelYouCanUseThisAssista.TabIndex 				= 1
	$labelYouCanUseThisAssista.Text 					= 'You can use this assistant tool to create Encrpyted Secure Strings used by PowerShell, and export them to text files for future import.

Enter a String below and export the Encrypted String file to the chosen directory.
The relevant code required to import the String will be generated for you.'
	#
	# ButtonBrowse
	#
	$ButtonBrowse.BackColor 							= [System.Drawing.Color]::FromArgb(255, 29, 33, 37)
	$ButtonBrowse.Cursor 								= 'Hand'
	$ButtonBrowse.FlatAppearance.BorderSize 			= 0
	$ButtonBrowse.FlatAppearance.MouseDownBackColor 	= [System.Drawing.Color]::FromArgb(255, 57, 64, 71)
	$ButtonBrowse.FlatAppearance.MouseOverBackColor 	= [System.Drawing.Color]::FromArgb(255, 47, 54, 61)
	$ButtonBrowse.FlatStyle 							= 'Flat'
	$ButtonBrowse.Font 									= [System.Drawing.Font]::new('Segoe UI Semibold', '9', [System.Drawing.FontStyle]'Bold')
	$ButtonBrowse.ForeColor 							= [System.Drawing.Color]::FromArgb(255, 245, 245, 247)
	$ButtonBrowse.ImageAlign 							= 'MiddleLeft'
	$ButtonBrowse.Location 								= New-Object System.Drawing.Point(450, 304)
	$ButtonBrowse.Name 									= 'ButtonBrowse'
	$ButtonBrowse.Size 									= New-Object System.Drawing.Size(116, 27)
	$ButtonBrowse.TabIndex 								= 0
	$ButtonBrowse.Text 									= '  Browse...'
	$ButtonBrowse.UseVisualStyleBackColor 				= $False
	$ButtonBrowse.add_Click($buttonBrowse_Click)
	#
	# ImageStringInvisible
	#
	$ImageStringInvisible.Cursor 						= 'Hand'
	#region Binary Data
	$Formatter_binaryFomatter 							= New-Object System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
	$System_IO_MemoryStream 							= New-Object System.IO.MemoryStream (,[byte[]][System.Convert]::FromBase64String('
AAEAAAD/////AQAAAAAAAAAMAgAAAFFTeXN0ZW0uRHJhd2luZywgVmVyc2lvbj00LjAuMC4wLCBD
dWx0dXJlPW5ldXRyYWwsIFB1YmxpY0tleVRva2VuPWIwM2Y1ZjdmMTFkNTBhM2EFAQAAABVTeXN0
ZW0uRHJhd2luZy5CaXRtYXABAAAABERhdGEHAgIAAAAJAwAAAA8DAAAAEgMAAAKJUE5HDQoaCgAA
AA1JSERSAAAAKAAAABgIBgAAAIiEv8AAAAGDaUNDUElDQyBwcm9maWxlAAAoz5WSO0gDQRRFT6IS
EcXCFCIWW6iVAVERS4liEBQkRvBXuLsxMZDdhN0EG0vBNmDhp/FX2Fhra2ErCIIfEDs7K0UbkfXN
RkgQIjgwzOHO3MvMewPBg6xpufV9YNkFJx6LanPzC1romRB1QBu9uunmp2bGE9QcH7cE1HoTUVn8
b7QkV1wTAprwiJl3CsLLwkNrhbziHeGwuaonhU+Fex25oPC90o0yvyhO+xxUmWEnER8VDgtr6So2
qthcdSzhQeGupGVLfnCuzEnF64qtbNH8uad6YfOKPTujdJmdxJhgimk0DIpkyFIgIqstiktc9qM1
/B2+f1pchrgymOIYI4eF7vtRPfhdWzc10F9Oao5Cw5PnvXVDaAu+Sp73eeh5X0dQ9wgXdsWfO4Dh
d9FLFa1rH1o34OyyohnbcL4J7Q953dF9SfU/mErB64m0aV4+wzU0LZbr9rPP8R0kpFaTV7C7Bz1p
yV6q8e7G6rr9ecavH9FvQsxylL+aV1MAAAAJcEhZcwAALiIAAC4iAari3ZIAAAAHdElNRQflBwMA
FjL+h7c4AAAAGXRFWHRDb21tZW50AENyZWF0ZWQgd2l0aCBHSU1QV4EOFwAAAP1JREFUWEftkzFK
A1EURSeFIYULsJCpJWsQrK3NIlKJOwmBIS5Ca2vBNYTUYpE6TCCQwuSc+AIy/CKBEAf5Fw7MvP/e
fRc+v8jKysrKarnq5bIHE1jAM9zF0dnl7shgFjP1LFawaTCFMTzAdcyfXHrHDne5s5mjsqluFFN8
whto9AQDuIUbuIJLuIBO4Lc1z+yx1xln9dBLz9Su39SHBvwrdgFTV9wWdle8fySrKLYBs/w8kr34
6cIQ3iE1dA7cbYZuxEqLhj48wit8QcrsFOjtDnf1Y/3xYriE+zAawQt8wAzm4ENbw3fgtzXP7LHX
GWf10KsM+6ysrH+sotgCLrL73qAjhe0AAAAASUVORK5CYIIL'))
	#endregion
	$ImageStringInvisible.Image 						= $Formatter_binaryFomatter.Deserialize($System_IO_MemoryStream)
	$Formatter_binaryFomatter 							= $null
	$System_IO_MemoryStream 							= $null
	$ImageStringInvisible.Location 						= New-Object System.Drawing.Point(452, 262)
	$ImageStringInvisible.Name 							= 'ImageStringInvisible'
	$ImageStringInvisible.Size	 						= New-Object System.Drawing.Size(40, 24)
	$ImageStringInvisible.SizeMode 						= 'AutoSize'
	$ImageStringInvisible.TabIndex 						= 6
	$ImageStringInvisible.TabStop 						= $False
	$ImageStringInvisible.add_Click($ImageStringInvisible_Click)
	#
	# ImageStringVisible
	#
	$ImageStringVisible.Cursor 							= 'Hand'
	#region Binary Data
	$Formatter_binaryFomatter 							= New-Object System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
	$System_IO_MemoryStream 							= New-Object System.IO.MemoryStream (,[byte[]][System.Convert]::FromBase64String('
AAEAAAD/////AQAAAAAAAAAMAgAAAFFTeXN0ZW0uRHJhd2luZywgVmVyc2lvbj00LjAuMC4wLCBD
dWx0dXJlPW5ldXRyYWwsIFB1YmxpY0tleVRva2VuPWIwM2Y1ZjdmMTFkNTBhM2EFAQAAABVTeXN0
ZW0uRHJhd2luZy5CaXRtYXABAAAABERhdGEHAgIAAAAJAwAAAA8DAAAAIwUAAAKJUE5HDQoaCgAA
AA1JSERSAAAAKAAAABgIBgAAAIiEv8AAAAGDaUNDUElDQyBwcm9maWxlAAAoz5WSO0gDQRRFT6IS
EcXCFCIWW6iVAVERS4liEBQkRvBXuLsxMZDdhN0EG0vBNmDhp/FX2Fhra2ErCIIfEDs7K0UbkfXN
RkgQIjgwzOHO3MvMewPBg6xpufV9YNkFJx6LanPzC1romRB1QBu9uunmp2bGE9QcH7cE1HoTUVn8
b7QkV1wTAprwiJl3CsLLwkNrhbziHeGwuaonhU+Fex25oPC90o0yvyhO+xxUmWEnER8VDgtr6So2
qthcdSzhQeGupGVLfnCuzEnF64qtbNH8uad6YfOKPTujdJmdxJhgimk0DIpkyFIgIqstiktc9qM1
/B2+f1pchrgymOIYI4eF7vtRPfhdWzc10F9Oao5Cw5PnvXVDaAu+Sp73eeh5X0dQ9wgXdsWfO4Dh
d9FLFa1rH1o34OyyohnbcL4J7Q953dF9SfU/mErB64m0aV4+wzU0LZbr9rPP8R0kpFaTV7C7Bz1p
yV6q8e7G6rr9ecavH9FvQsxylL+aV1MAAAAJcEhZcwAALiIAAC4iAari3ZIAAAAHdElNRQflBwMA
FSe4dwAQAAAAGXRFWHRDb21tZW50AENyZWF0ZWQgd2l0aCBHSU1QV4EOFwAAAw5JREFUWEfFl0FP
E1EUhceyNOoCdS2aqHFhjG6NKCDCwhBJ1A2JLvwRbo0bdS8EoyYSE3+BxMSV+g9AIwkbNaWWodjO
vCKIRv3ucFNeXy+0WNSTnKR975xz73szfTON2kE5qRxKXHo1delNV3Vjrlp9sEY3JmPMXRGNyv8N
KklyJnVZM3n4q0Xm8YyKV2O2F8U4zrEj19OqmzaKb5Fumqxr8/F8TuPbQ5KmvYS+s4vVk11adUJj
rpHuLdk9Wmbr+FIu72Slj+zwddLUCzi8UCp1qjUqLZb2MXYZvrQ8PqnxUGqptTUkaXKEFc5YgR6L
7MAFtWwININkxYa/RhbyHt1htWyONE3PEphYQR7nWHmXWpqCzIN4CkFGHbm/ExrtVosNVjGAeDk0
B/wZ/hrx9RE+CWPlJGP9Op2B7yzczPO5zMLrfDUw0SOCwNBAij9VSwYK37Z0QubuqCwD3meWLiBN
unNqWQM7coKJaiA0ibZ2GWhgyNL4RDOscqkjm2DqAlbRHs9M5UplLwMfA8EGdN/mvPOLlb6ydetE
80blUSEudpDx3dI10n2gt04pMmoLTE5prSiO4x14fxiaOopGtGqLGGv5sMd7/380OBVqNqL0Jgfy
fr60dIk5ClYL8XyH1pLFvbZ0PtH4lzgnGZbO4CfpLTNyQ55kYCkQmAx+JMOWxieaSyqXOt2WxuAS
D4tTalsDx0wfEyuBsIHsSHjM3LN0QubuqiyDeC1dwBV059VSDwIviiAwhJSD+rRaMuAbIFSeyWVY
kc+MDep0BvGIN8gKuSI9qMUG4XJWucAYMk/QAbU0BdouPHNBRkgntdWyOVjtMc6hWSPEZ4H7xL4U
HtD0o/0ceOvID2dWaqqlNfCqvosVPbECfaJ5DocWFkt71BrxebeMyZzl8YlmQmqpdeuQ+4vdbPbq
pXQ8y91Xe66BM5KtZdoDr/wdrPQGbLHRzehmJItX/tp5um2QJwKr7qUAb9quaDdg0RXFI17/qfLX
wY19lKIjvJDe4r/IOM08FtLMuIzxt3NENCr/A0TRb3yH12SDa7KPAAAAAElFTkSuQmCCCw=='))
	#endregion
	$ImageStringVisible.Image 							= $Formatter_binaryFomatter.Deserialize($System_IO_MemoryStream)
	$Formatter_binaryFomatter 							= $null
	$System_IO_MemoryStream 							= $null
	$ImageStringVisible.Location 						= New-Object System.Drawing.Point(452, 263)
	$ImageStringVisible.Name 							= 'ImageStringVisible'
	$ImageStringVisible.Size 							= New-Object System.Drawing.Size(40, 24)
	$ImageStringVisible.SizeMode 						= 'AutoSize'
	$ImageStringVisible.TabIndex 						= 7
	$ImageStringVisible.TabStop 						= $False
	$ImageStringVisible.Visible 						= $False
	$ImageStringVisible.add_Click($ImageStringVisible_Click)
	$FormSecureString.ResumeLayout()
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState 							= $FormSecureString.WindowState
	#Show the Form
	return $FormSecureString.ShowDialog()

} #End Function


# Show the Form
Show-FormSecureString | Out-Null
