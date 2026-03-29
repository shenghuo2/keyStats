using System.Diagnostics;
using System.Reflection;
using System.Windows;

namespace KeyStats.Views;

public partial class SettingsWindow : Window
{
    private const string GitHubUrl = "https://github.com/debugtheworldbot/keyStats";

    public SettingsWindow()
    {
        InitializeComponent();
        VersionTextBlock.Text = GetVersionText();
    }

    private void OpenStats_Click(object sender, RoutedEventArgs e)
    {
        App.CurrentApp?.ShowStatsPanel();
    }

    private void ImportData_Click(object sender, RoutedEventArgs e)
    {
        App.CurrentApp?.ImportData();
    }

    private void ExportData_Click(object sender, RoutedEventArgs e)
    {
        App.CurrentApp?.ExportData();
    }

    private void NotificationSettings_Click(object sender, RoutedEventArgs e)
    {
        App.CurrentApp?.ShowNotificationSettings();
    }

    private void MouseCalibration_Click(object sender, RoutedEventArgs e)
    {
        App.CurrentApp?.ShowMouseCalibration();
    }

    private void OpenGitHub_Click(object sender, RoutedEventArgs e)
    {
        try
        {
            Process.Start(new ProcessStartInfo(GitHubUrl)
            {
                UseShellExecute = true
            });
        }
        catch
        {
            MessageBox.Show(this, "无法打开 GitHub 页面。", "KeyStats", MessageBoxButton.OK, MessageBoxImage.Information);
        }
    }

    private static string GetVersionText()
    {
        var assembly = Assembly.GetExecutingAssembly();
        var informationalVersion = assembly
            .GetCustomAttribute<AssemblyInformationalVersionAttribute>()?
            .InformationalVersion?
            .Trim();

        if (!string.IsNullOrWhiteSpace(informationalVersion))
        {
            return $"版本 {informationalVersion}";
        }

        var assemblyVersion = assembly.GetName().Version?.ToString();
        return $"版本 {assemblyVersion ?? "1.0.0"}";
    }
}
