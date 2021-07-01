# Load Assemblies
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

# ==================== Form Variables
# Fonts
$FontForm = "Segoe UI"
# Colours
$ColourForm = "#24292E"
$ColourClearInput = "#b2b2b2" 
$ColourConsole = "200,220,230"
$ColourDefaultText = "250,250,252"
$ColourAltText = "215,215,218"
$ColourInteractBG = "#1D2125"
# Buttons
$ButtonWidth_Normal = 155
$ButtonHeight_Normal = 30
# Sizes
$WidthInfoBox = 650
$WidthForm = 710
$Hei_Form = 920

# Form Creation
$Form_Window = New-Object system.Windows.Forms.Form
    $Form_Window.ClientSize = "$WidthForm,$Hei_Form"
    $Form_Window.Text = "PowerShell Secure String Assistant"
    $Form_Window.BackColor = $ColourForm
    #$Form_Window.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    $Form_Window.ShowIcon = $False
    $Form_Window.StartPosition = "manual"
    $Form_Window.Location = "0,0"
    $Form_Window.MaximizeBox = $False

# Output Console Textbox
$TextBox_Output = New-Object System.Windows.Forms.RichTextBox 
    $TextBox_Output.Text = ""
    $TextBox_Output.Multiline = $True
    $TextBox_Output.AcceptsTab = $False
    $TextBox_Output.ReadOnly = $True
    $TextBox_Output.WordWrap = $True
    $TextBox_Output.BackColor = $ColourConsole
    $TextBox_Output.ForeColor = $ColourDefaultText
    $TextBox_Output.Font = "Consolas,12"
    $TextBox_Output.Location = New-Object System.Drawing.Point(10,684)
    $TextBox_Output.Width = 690
    $TextBox_Output.Height = 200
    $TextBox_Output.ScrollBars = "Vertical"
    $TextBox_Output.BorderStyle = [System.Windows.Forms.BorderStyle]::None
        $Form_Window.Controls.Add($TextBox_Output)

# Button - Output Textbox Clear
$Button_CopyOutput = New-Object system.Windows.Forms.Button
    $Button_CopyOutput.BackColor = "#dce6f0"
    $Button_CopyOutput.text = "COPY SCRIPT"
    $Button_CopyOutput.width = 118
    $Button_CopyOutput.height = 24
    $Button_CopyOutput.location = New-Object System.Drawing.Point(582,890)
    $Button_CopyOutput.Font = "$FontForm,10"
        $Button_CopyOutput.Add_Click({ Copy-Output })
        $Form_Window.Controls.Add($Button_CopyOutput)

# Textbox - Info
$Label_Info = New-Object System.Windows.Forms.Label
$Label_Info.Text = "Use this tool to create encrypted Secure Strings used by PowerShell.`
Enter a string below and define an output directory.`
Click `"Generate File`" to create an encrypted Secure String file.`r`n`
Encrypted Secure String files can only be decrypted by the creator account on the machine it was created on, so be sure to run scripts with the same account or else decrypted Secure Strings will be incorrect.`
(Creator and machine information is referenced at the top of this Window)."
$Label_Info.Multiline = $True
$Label_Info.ReadOnly = $True
$Label_Info.WordWrap = $True
$Label_Info.SelectionStart = 0
$Label_Info.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$Label_Info.BackColor = $ColourForm
$Label_Info.ForeColor = $ColourDefaultText
$Label_Info.Font = "$FontForm,10"
$Label_Info.Location = New-Object System.Drawing.Point(20,80)
$Label_Info.Width = $WidthInfoBox
$Label_Info.Height = 160
$Label_Info.Enabled = $true
    $Form_Window.Controls.Add($Label_Info)

# Label - Current Running as...
$Label_RunningAs = New-Object system.Windows.Forms.Label
    $Label_RunningAs.Text = "User: $env:USERNAME        |        Machine: $env:COMPUTERNAME"
    $Label_RunningAs.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $Label_RunningAs.AutoSize = $false
    $Label_RunningAs.Width = 670
    $Label_RunningAs.Height = 40
    $Label_RunningAs.Location = New-Object System.Drawing.Point(20,20)
    $Label_RunningAs.Font = "$FontForm,12"
    $Label_RunningAs.ForeColor = $ColourDefaultText
    $Label_RunningAs.BackColor = "#2F363D"
        $Form_Window.Controls.Add($Label_RunningAs)

# InputBox - Password
$TextBox_Password = New-Object system.Windows.Forms.MaskedTextBox
$TextBox_Password.Multiline = $false
$TextBox_Password.Text = " Enter String"
$TextBox_Password.UseSystemPasswordChar = $false
$TextBox_Password.BorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$TextBox_Password.BorderColor = $ColourInteractBG
$TextBox_Password.TextAlign = VerticalAlignment.Top;
$TextBox_Password.AutoSize = $False
$TextBox_Password.Width = 400
$TextBox_Password.Height = 25
$TextBox_Password.location = New-Object System.Drawing.Point(40,250)
$TextBox_Password.Font = "$FontForm,11"
$TextBox_Password.ForeColor = $ColourClearInput
$TextBox_Password.BackColor = $ColourInteractBG
$TextBox_Password.Add_TextChanged({ Update-PWMask })
$TextBox_Password.Add_Enter({ 
    if ($TextBox_Password.Text -match " Enter String") {
        $TextBox_Password.Text = ""
        $TextBox_Password.ForeColor = $ColourDefaultText
    }
})
$TextBox_Password.Add_Leave({ 
    if ($TextBox_Password.Text -eq "") {
        $TextBox_Password.Text = " Enter String"
        $TextBox_Password.UseSystemPasswordChar = $false
        $TextBox_Password.ForeColor = $ColourAltText
    }
})
    $Form_Window.Controls.Add($TextBox_Password)

# Checkbox - Hide PW
$CheckBox_HidePW = New-Object system.Windows.Forms.CheckBox
$CheckBox_HidePW.Text = "Show/Hide"
$CheckBox_HidePW.AutoSize = $true
$CheckBox_HidePW.Checked = $true
$CheckBox_HidePW.location = New-Object System.Drawing.Point(500,250)
$CheckBox_HidePW.ForeColor = $ColourAltText
$CheckBox_HidePW.Font = "$FontForm,11"
    $CheckBox_HidePW.Add_CheckedChanged({ Update-PWMask })
    $Form_Window.Controls.Add($CheckBox_HidePW)

# TextBox - Folder Path
$TextBox_OutputFolder = New-Object System.Windows.Forms.Label
$TextBox_OutputFolder.ReadOnly = $True
$TextBox_OutputFolder.Width = 510
$TextBox_OutputFolder.Height = 26
$TextBox_OutputFolder.AutoSize = $False
$TextBox_OutputFolder.BorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$TextBox_OutputFolder.BackColor = $ColourForm
$TextBox_OutputFolder.ForeColor = $ColourAltText
$TextBox_OutputFolder.Text = " Select output folder..."
$TextBox_OutputFolder.Font = "$FontForm,11"
$TextBox_OutputFolder.Location = New-Object System.Drawing.Point( 40,440 )
    $Form_Window.Controls.Add($TextBox_OutputFolder)

# Button - Browse Output Path
$Button_BrowseFolder = New-Object system.Windows.Forms.Button
$Button_BrowseFolder.BackColor = $ColourInteractBG
$Button_BrowseFolder.ForeColor = $ColourDefaultText
$Button_BrowseFolder.text = "BROWSE..."
$Button_BrowseFolder.width = ($ButtonWidth_Normal*0.7)
$Button_BrowseFolder.height = $ButtonHeight_Normal
$Button_BrowseFolder.location = New-Object System.Drawing.Point( 558,468 )
$Button_BrowseFolder.Font = "$FontForm,11"
    $Button_BrowseFolder.Add_Click({ Browse-Folder })
    $Form_Window.Controls.Add($Button_BrowseFolder)

# TextBox - File Name
$TextBox_FileName = New-Object System.Windows.Forms.TextBox
$TextBox_FileName.BackColor = $ColourInteractBG
$TextBox_FileName.ForeColor = $ColourDefaultText
$TextBox_FileName.Text = "$env:USERNAME"+"_SecureEncrypt.txt"
$TextBox_FileName.Width = 200
$TextBox_FileName.Font = "$FontForm,10"
$TextBox_FileName.Location = New-Object System.Drawing.Point( 40,480 )
    $Form_Window.Controls.Add($TextBox_FileName)

# Button - Generate Password File
$Button_Generate = New-Object system.Windows.Forms.Button
$Button_Generate.BackColor = $ColourInteractBG
$Button_Generate.ForeColor = $ColourDefaultText
$Button_Generate.text = "Export file"
$Button_Generate.width = ($ButtonWidth_Normal)
$Button_Generate.height = ($ButtonHeight_Normal)
$Button_Generate.location = New-Object System.Drawing.Point( 40,540 )
$Button_Generate.Font = "$FontForm,12"
    $Button_Generate.Add_Click({ Generate-PasswordFile })
    $Form_Window.Controls.Add($Button_Generate)

# Label - Script Generator Instructions
$Label_Instructions = New-Object system.Windows.Forms.Label
$Label_Instructions.Text = "(Copy this into your PowerShell script to import the Password)"
$Label_Instructions.TextAlign = "MiddleCenter"
$Label_Instructions.ForeColor = $ColourAltText
$Label_Instructions.AutoSize = $False
$Label_Instructions.Width = $WidthForm
$Label_Instructions.Height = 25
$Label_Instructions.Location = New-Object System.Drawing.Point(0,656)
$Label_Instructions.Font = "$FontForm,11"
$Label_Instructions.ForeColor = "0,0,0"
    $Form_Window.Controls.Add($Label_Instructions)

# ========================================
#  FUNCTIONS
# ========================================
Function Generate-PasswordFile {
    if ($TextBox_OutputFolder.Text -eq "Select Folder") {
        Write-Host "Please select an output folder."
        RETURN
    }
    $Str_Pass = $TextBox_Password.Text
    $Out_Path = $TextBox_OutputFolder.Text
    $Out_Filename = $TextBox_FileName.Text
    if ($Str_Pass.Length -gt 0) {
        $Str_Pass | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File "$Out_Path\$Out_Filename"
        # Write Output to Copy
        $TextBox_Output.Clear()
        Write-Output("`$FilePath = `"$Out_Path\$Out_Filename`"")
        Write-Output("`$Cred_Password = Get-Content -Path `$FilePath | ConvertTo-SecureString")
        Write-Output('$Credentials = New-Object System.Management.Automation.PSCredential ("Username", $Cred_Password)')
    } else {
        Write-Host Please enter a password into the password Textbox.
    }
}
Function Copy-Output {
    $Str = $TextBox_Output.Text
    if ($Str.Length -gt 0){
        Set-Clipboard -Value $TextBox_Output.Text
    } else {
        Write-Host "Click on `"Generate File`" to create the integration script." 
    }
}
Function Update-PWMask {
    if ($TextBox_Password.Text -ne "Enter Password") {
        $TextBox_Password.UseSystemPasswordChar = $CheckBox_HidePW.Checked
    }
} 
function Browse-Folder() {
    $OpenDialog = New-Object -TypeName System.Windows.Forms.FolderBrowserDialog
    #Initiat browse path can be set by using initialDirectory
    $initialDirectory = $PSScriptRoot
    $OpenDialog.SelectedPath = $initialDirectory
    $OpenDialog.ShowDialog() | Out-Null   
    # Gather Target CSV file
    $filePath = $OpenDialog.SelectedPath
    # Assigining the file choosen path to the text box
    $TextBox_OutputFolder.Text = $filePath 
}

Function Update-Checkbox($TargetObject) {
    If ($TargetObject.Checked -eq $True) {
        $TargetObject.ForeColor = "255,0,0"
    } Else {
        $TargetObject.ForeColor = $ColourUnchecked
    }
}
Function InputBox_DynamicInput($TargetObject,$ResetString) {
    if ($TargetObject.Text -eq "") {
        $TargetObject.Text = $ResetString
        $TargetObject.ForeColor = $ColourClearInput
    }
}
Function ClearOutput {
    $TextBox_Output.Clear() 
}
Function Write-Output($MessageString) {
    $TextBox_Output.ForeColor = "0,0,0" # Set Colour
    # Don't add line if empty
    If ($TextBox_Output.text -ne "") {
        $TextBox_Output.AppendText("`r`n")
        $TextBox_Output.ForeColor = "0,0,0" # Set Colour
    }
    $TextBox_Output.AppendText($MessageString) # Add String
    $TextBox_Output.ScrollToCaret() # Scroll Down
}
Function Write-Output-Green($MessageString) {
    $TextBox_Output.ForeColor = "0,255,130" # Set Colour
    # Don't add line if empty
    If ($TextBox_Output.text -ne "") {
        $TextBox_Output.AppendText("`r`n")
        $TextBox_Output.ForeColor = "0,255,130" # Set Colour
    }
    $TextBox_Output.AppendText("> "+$MessageString) # Add String
    $TextBox_Output.ScrollToCaret() # Scroll Down
}
Function Write-Output-Red($MessageString) {
    $TextBox_Output.SelectionColor = "255,80,80" # Set Colour
    # Don't add line if empty
    If ($TextBox_Output.text -ne "") {
        $TextBox_Output.AppendText("`r`n")
        $TextBox_Output.SelectionColor = "255,80,80" # Set Colour
    }
    $TextBox_Output.AppendText("> "+$MessageString) # Add String
    $TextBox_Output.ScrollToCaret() # Scroll Down
}

function OpenChangeLog() {
    Start-Process "https://gnsplc.sharepoint.com/:b:/s/IT3rdLine/ESkshxXGMFVOtk7Y3tEiF78B3Vkw_GxdIVb2DWC7wmwjCQ?e=1TCPID"
}

# Close Form
function closeForm(){$Form.close()}



# =================== RUN FORM
[void]$Form_Window.ShowDialog()