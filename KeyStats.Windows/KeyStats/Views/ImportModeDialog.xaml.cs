using System.Windows;
using System.Windows.Input;
using KeyStats.Services;

namespace KeyStats.Views
{
    public partial class ImportModeDialog : Window
    {
        public StatsManager.ImportMode? SelectedMode { get; private set; }

        public ImportModeDialog()
        {
            InitializeComponent();

            // Allow dragging the window
            MouseLeftButtonDown += (s, e) =>
            {
                if (e.LeftButton == MouseButtonState.Pressed)
                    DragMove();
            };

            // ESC to close
            KeyDown += (s, e) =>
            {
                if (e.Key == Key.Escape)
                {
                    SelectedMode = null;
                    Close();
                }
            };
        }

        public static StatsManager.ImportMode? Show(Window? owner = null)
        {
            var dialog = new ImportModeDialog();

            if (owner != null)
            {
                dialog.Owner = owner;
                dialog.WindowStartupLocation = WindowStartupLocation.CenterOwner;
            }

            dialog.ShowDialog();
            return dialog.SelectedMode;
        }

        private void OverwriteButton_Click(object sender, RoutedEventArgs e)
        {
            SelectedMode = StatsManager.ImportMode.Overwrite;
            Close();
        }

        private void MergeButton_Click(object sender, RoutedEventArgs e)
        {
            SelectedMode = StatsManager.ImportMode.Merge;
            Close();
        }

        private void CancelButton_Click(object sender, RoutedEventArgs e)
        {
            SelectedMode = null;
            Close();
        }
    }
}
