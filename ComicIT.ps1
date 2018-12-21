#========================================================================
#
# Tool Name	: CommicIT
# Author 	: Jérôme Bezet-Torres
# Date 		: 29/09/2018
# Website	: http://JM2K69.github.io/
# Twitter	: https://twitter.com/JM2K69
#
#========================================================================

##Initialize######
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       			| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MaterialDesignThemes.Wpf.dll') 			| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MaterialDesignColors.dll')       			| out-null
[String]$ScriptDirectory = split-path $myinvocation.mycommand.path

function LoadXml ($global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow
$XamlMainWindow=LoadXml("$ScriptDirectory\main.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)


$XamlMainWindow.SelectNodes("//*[@Name]") | %{
    try {Set-Variable -Name "$("WPF_"+$_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop}
    catch{throw}
    }
 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable *WPF*
}
  #Get-FormVariables



#########################################################################
#                       Functions       								#
#########################################################################
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$WPF_Web_source.SelectedIndex = 0
$Site =  $WPF_Web_source.SelectionBoxItem
$Global:Lang = 'EN'
$Global:Random = 'Yes'
$WPF_EN.IsChecked =$True

If ($site -eq "monkeyuser")
{
    $Global:Lang = 'EN'
    $WPF_EN.IsChecked = $true
}

function Find-CommitStripImage {
    [CmdletBinding()]
    Param
    (
              
        [Parameter(Mandatory = $true)]
        [ValidateSet("EN","FR")]$lang,
        [Parameter(Mandatory = $true)]
        [ValidateSet("Yes","No")]$Random
    )

    begin {
        switch ($lang) {
            'FR' {       
                 $URLCommitStrip = "http://www.commitstrip.com/fr/feed/?"
                }
            'EN' {
                $URLCommitStrip = "http://www.commitstrip.com/en/feed/?"
            }
            Default {}
        }
        
    }
    process{
        switch ($Random)
        {
            'No' {        
                    $resquest =Invoke-RestMethod $URLCommitStrip
                    $Image = $(Invoke-WebRequest -uri $resquest[0].link).Images.src | where {$_ -like "https://www.commitstrip.com**"}
                    [String]$Title = $resquest[0].title
                    
                 }
            'Yes'{
                    $resquest =Invoke-RestMethod $URLCommitStrip
                    $NB = $resquest.Count
                    $PostNb=get-random -Minimum 0 -Maximum $NB
                    $Image = $(Invoke-WebRequest -uri $resquest[$PostNb].link).Images.src | where {$_ -like "https://www.commitstrip.com**"}
                    [String]$Title =  $resquest[$PostNb].title
                    [String]$Date = $resquest[$PostNb].pubDate

                 }
            Default {}
        }

    }
    end {
    $myObject = [PSCustomObject]@{
    Image     = $Image
    Title     = $Title
    Date      = $Date
        }
        return $myObject
    }
    
}
function Find-Monkeyuser {
    [CmdletBinding()]
    Param
    (
              
        [Parameter(Mandatory = $true)]
        [ValidateSet("Yes","No")]$Random


    )

    begin {
             
                 $URL = "https://www.monkeyuser.com/feed"
               
        
          }
    process{
        switch ($Random)
        {
            'No' {        
                    $resquest =Invoke-RestMethod $URL
                    $Image = $(Invoke-WebRequest -uri $resquest[0].link).Images.src | where {$_ -like "https://***"}
                    [String]$Title = $resquest[0].title
                 }
            'Yes'{
                    $resquest =Invoke-RestMethod $URL
                    $NB = $resquest.Count
                    $PostNb=get-random -Minimum 0 -Maximum $NB
                    $Image = $(Invoke-WebRequest -uri $resquest[$PostNb].link).Images.src | where {$_ -like "https://***"}
                    $Title =  $resquest[$PostNb].title
                    [String]$Date = $resquest[$PostNb].pubDate
                 }
            Default {}
        }

    }
    end {
        $myObject = [PSCustomObject]@{
            Image     = $Image
            Title     = $Title
            Date      = $Date
                }
                return $myObject
    }
    
}
$WPF_EN.add_Click({

    if ($WPF_EN.IsChecked -eq $true) 
    {
        $Global:Lang = 'EN'
       
    }
    if ($WPF_EN.IsChecked -eq $False) 
    {
        $Global:Lang = 'FR'
    }


})

$WPF_Last.add_Click({

    if ($WPF_Last.IsChecked -eq $true) 
    {
        $Global:Random = 'Yes'
      
    }
    if ($WPF_Last.IsChecked -eq $False) 
    {
        $Global:Random = 'No'
    }

})

$WPF_Web.add_Click({

    $Site =  $WPF_Web_source.SelectionBoxItem

        if ($Site -eq "CommitStrip")
        {
            $result = Find-CommitStripImage -lang $Global:Lang -Random $Global:Random
            $File = $result.Image
            $Title = $result.Title
            if ($result.date -eq $Null)
            {
                $PubDate = ""
            }
            if ($result.date -ne $Null)
            {
                $PubDate = "Publish on" +" "+ $Result.Date
            }
           
            $Size = ' Width="500" Height="550" '
            $Sizez = ' Width="525" Height="560" '
        }

        if ( $Site -eq "monkeyuser")
        {
          $result = Find-Monkeyuser -Random $Global:Random
          $File = $result.Image
          $Title = $result.Title
          $Size = ' Width="600" Height="550" '
          if ($result.date -eq $Null)
          {
              $PubDate = ""
          }
          if ($result.date -ne $Null)
          {
              $PubDate = "Publish on" +" "+ $Result.Date
          }

        }


    [XML]$xaml=@"
<Controls:MetroWindow 
xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
xmlns:Controls="http://metro.mahapps.com/winfx/xaml/controls"
xmlns:materialDesign="http://materialdesigninxaml.net/winfx/xaml/themes"
Title="CommicIT result"
WindowStartupLocation="CenterScreen" 
Width="Auto" 
ResizeMode="NoResize"
Height="Auto" 
SizeToContent="WidthAndHeight" 			
WindowStyle="None"
BorderThickness="0"	
GlowBrush="{DynamicResource AccentColorBrush}"
TextElement.Foreground="{DynamicResource MaterialDesignBody}"
TextElement.FontWeight="Regular"
TextElement.FontSize="13"
TextOptions.TextFormattingMode="Ideal"
TextOptions.TextRenderingMode="Auto"
Background="{DynamicResource MaterialDesignPaper}"
FontFamily="{DynamicResource MaterialDesignFont}">

<Window.Resources>
        <ResourceDictionary>
            <ResourceDictionary.MergedDictionaries>
                <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Controls.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Fonts.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Colors.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Accents/Steel.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Accents/BaseLight.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignThemes.Wpf;component/Themes/MaterialDesignTheme.Dark.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignThemes.Wpf;component/Themes/MaterialDesignTheme.Defaults.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignColors;component/Themes/Recommended/Primary/MaterialDesignColor.Purple.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignColors;component/Themes/Recommended/Accent/MaterialDesignColor.blue.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignThemes.Wpf;component/Themes/MaterialDesignTheme.RadioButton.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignThemes.Wpf;component/Themes/MaterialDesignTheme.Button.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignThemes.Wpf;component/Themes/MaterialDesignTheme.Card.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignThemes.Wpf;component/Themes/MaterialDesignTheme.CheckBox.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignThemes.Wpf;component/Themes/MaterialDesignTheme.Flipper.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignThemes.Wpf;component/Themes/MaterialDesignTheme.PopupBox.xaml"/>
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignThemes.Wpf;component/Themes/MaterialDesignTheme.TextBox.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignThemes.Wpf;component/Themes/MaterialDesignTheme.Button.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignThemes.Wpf;component/Themes/MaterialDesignTheme.Menu.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MaterialDesignThemes.Wpf;component/Themes/MaterialDesignTheme.ToolTip.xaml" />
            </ResourceDictionary.MergedDictionaries>
        </ResourceDictionary>
    </Window.Resources>

<Grid Margin="0,0,41,0">
<StackPanel Orientation="Vertical" HorizontalAlignment="Center" Margin="10,0,-39,10" >
 <StackPanel Orientation="Vertical">
    <TextBlock Style="{DynamicResource MaterialDesignTitleTextBlock}" HorizontalAlignment="Center" Text="$Title"></TextBlock>
    <TextBlock Style="{DynamicResource MaterialDesignTitleTextBlock}" FontSize="11" HorizontalAlignment="Center" Text="$PubDate"></TextBlock>
 </StackPanel>
<materialDesign:ColorZone Mode="PrimaryLight" $SizeZ CornerRadius="12" materialDesign:ShadowAssist.ShadowDepth="Depth3" Margin="112,5,139,0">
<StackPanel Orientation="Horizontal" >
<Image Source="$File" Margin="10 10 10 0 "  $Size HorizontalAlignment="Center">
  <Image.Effect>
      <DropShadowEffect Color="#FF8B7C7C"/>
  </Image.Effect>
</Image>

</StackPanel>
</materialDesign:ColorZone>
<Button Name="Close" Style="{StaticResource MaterialDesignFloatingActionAccentButton}" materialDesign:ShadowAssist.ShadowDepth="Depth3" Margin="0 15 0 0 ">
<materialDesign:PackIcon Kind="ExitToApp" Width="32" Height="32"/>
</Button>
</StackPanel>

</Grid>

</Controls:MetroWindow>
"@
$image_Window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))

    $Close = $image_Window.findname("Close") 
    $Close.add_Click({
    $image_Window.Close() | Out-Null

})


    $image_Window.ShowDialog() | Out-Null


})

$Form.ShowDialog() | Out-Null

