using System.Windows;

namespace KeyStats.Views;

public partial class SettingsWindow : Window
{
    public SettingsWindow()
    {
        InitializeComponent();
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
}
