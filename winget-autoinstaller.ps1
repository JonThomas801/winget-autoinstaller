if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget is not installed. Please install 'App Installer' from the Microsoft Store."
    exit 1
}

Add-Type -AssemblyName System.Windows.Forms

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Program Installer"
$form.Size = New-Object System.Drawing.Size(600, 500)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Create a label for instructions
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(20, 20)
$label.Size = New-Object System.Drawing.Size(360, 20)
$label.Text = "Select programs to install:"
$form.Controls.Add($label)

# Create a scrollable panel to hold the checked list box and headers
$panel = New-Object System.Windows.Forms.Panel
$panel.Location = New-Object System.Drawing.Point(20, 50)
$panel.Size = New-Object System.Drawing.Size(550, 350)
$panel.AutoScroll = $true
$form.Controls.Add($panel)

# Function to add a category header
function Add-CategoryHeader($panel, [string]$text, [ref]$yPos) {
    $header = New-Object System.Windows.Forms.Label
    $header.Text = $text
    $header.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $header.Location = New-Object System.Drawing.Point(0, $yPos.Value)
    $header.Size = New-Object System.Drawing.Size(360, 20)
    $panel.Controls.Add($header)
    $yPos.Value += 20
}

# Function to add items to the checked list box
function Add-CheckedListBoxItems($panel, [hashtable]$items, [ref]$yPos) {
    foreach ($friendlyName in $items.Keys) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $friendlyName
        $checkbox.Tag = $items[$friendlyName]
        $checkbox.Location = New-Object System.Drawing.Point(0, $yPos.Value)
        $checkbox.Size = New-Object System.Drawing.Size(500, 20)
        $panel.Controls.Add($checkbox)
        $yPos.Value += 20
    }
}

# Define the categories and their programs
$categories = @{
    "Text Editors" = @{
        "Atom" = "Github.Atom"
        "Brackets" = "Adobe.Brackets"
        "Gedit" = "Gnome.Gedit"
        "GNU Emacs" = "GNU.Emacs"
        "Neovim" = "Neovim.Neovim"
        "Notepad++" = "Notepad++.Notepad++"
        "Vim" = "Vim.vim"
        "Visual Studio Code" = "Microsoft.VisualStudioCode"
    }
    "Web Browsers" = @{
        "Arc" = "TheBrowserCompany.Arc"
        "Brave" = "Brave.Brave"
        "Google Chrome" = "Google.Chrome"
        "K-Meleon" = "kmeleonbrowser.K-Meleon"
        "LibreWolf" = "LibreWolf.LibreWolf"
        "Mozilla Firefox" = "Mozilla.Firefox"
        "Mozilla Thunderbird" = "Mozilla.Thunderbird"
        "Opera" = "Opera.Opera"
        "Opera GX" = "Opera.OperaGX"
        "Pale Moon" = "MoonchildProductions.PaleMoon"
        "Qutebrowser" = "Qutebrowser.Qutebrowser"
        "Thorium" = "Alex313031.Thorium"
        "TOR Browser" = "TorProject.TorBrowser"
        "Waterfox" = "Waterfox.Waterfox"
    }
    "Video Game Clients" = @{
        "Bethesda Launcher" = "Bethesda.Launcher"
        "EA Origin" = "ElectronicArts.Origin"
        "Epic Games Launcher" = "EpicGames.EpicGamesLauncher"
        "GOG Galaxy" = "GOG.Galaxy"
        "Itch.io" = "ItchIo.Itch"
        "Steam" = "Valve.Steam"
        "Ubisoft Connect" = "Ubisoft.Connect"
    }
    "Development Tools" = @{
        "7-Zip" = "7zip.7zip"
        "Angry IP Scanner" = "angryziber.AngryIPScanner"
        "Git" = "git.git"
        "GitHub Desktop" = "GitHub.GitHubDesktop"
        "GNU Privacy Guard (GPG)" = "GnuPG.GnuPG"
        "Neofetch" = "nepnep.neofetch-win"
        "PuTTY" = "PuTTY.PuTTY"
        "Python" = "Python.Python"
        "Raspberry Pi Imager" = "RaspberryPiFoundation.RaspberryPiImager"
        "Rustup" = "Rustlang.Rustup"
        "WinRAR" = "RARLab.WinRAR"
    }
    "Torrent Clients" = @{
        "Deluge" = "DelugeTeam.Deluge"
        "PicoTorrent" = "Picotorrent.Picotorrent"
        "qBittorrent" = "qBittorrent.qBittorrent"
        "Transmission" = "Transmission.Transmission"
        "Tribler" = "Tribler.Tribler"
    }
    "Media Players" = @{
        "Jellyfin Media Player" = "Jellyfin.JellyfinMediaPlayer"
        "Spotify" = "Spotify.Spotify"
        "Strawberry Music Player" = "StrawberryMusicPlayer.Strawberry"
        "VLC Media Player" = "VideoLAN.VLC"
        "Winamp" = "Winamp.Winamp"
        "YouTube Music" = "Ytmdesktop.Ytmdesktop"
    }
}

# Populate the panel with categories and items
$yPos = 0
foreach ($category in $categories.Keys) {
    Add-CategoryHeader -panel $panel -text $category -yPos ([ref]$yPos)
    Add-CheckedListBoxItems -panel $panel -items $categories[$category] -yPos ([ref]$yPos)
}

# Create an "Install" button
$buttonInstall = New-Object System.Windows.Forms.Button
$buttonInstall.Location = New-Object System.Drawing.Point(120, 420)
$buttonInstall.Size = New-Object System.Drawing.Size(160, 30)
$buttonInstall.Text = "Install Selected Programs"
$buttonInstall.Add_Click({
    $buttonInstall.Enabled = $false
    try {
        # Install selected programs
        foreach ($control in $panel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $program = $control.Tag
                Write-Host "Installing $program ..."
                winget install -e --id $program
                if ($LASTEXITCODE -ne 0) {
                    Write-Host "Failed to install $program."
                } else {
                    Write-Host "$program installed successfully."
                }
            }
        }
    } finally {
        $buttonInstall.Enabled = $true
    }
    $form.Close()
})
$form.Controls.Add($buttonInstall)

# Show the form
$form.Add_Shown({ $form.Activate() })
[void] $form.ShowDialog()
