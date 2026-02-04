import Cocoa

final class MouseDistanceCalibrationViewController: NSViewController {
    private var titleLabel: NSTextField!
    private var instructionLabel: NSTextField!
    private var pixelLabel: NSTextField!
    private var statusLabel: NSTextField!
    private var resultLabel: NSTextField!
    private var retryButton: NSButton!
    private var closeButton: NSButton!
    private var updateTimer: Timer?
    private var hasCompleted = false

    override func loadView() {
        let mainView = NSView(frame: NSRect(x: 0, y: 0, width: 360, height: 240))
        mainView.wantsLayer = true
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        cleanup()
    }

    func prepareForDisplay() {
        if !isViewLoaded {
            _ = view
        }
        restartCalibration()
    }

    private func setupUI() {
        titleLabel = NSTextField(labelWithString: NSLocalizedString("settings.mouseDistanceCalibration.title", comment: ""))
        titleLabel.font = NSFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel.alignment = .center

        instructionLabel = NSTextField(wrappingLabelWithString: NSLocalizedString("settings.mouseDistanceCalibration.instruction", comment: ""))
        instructionLabel.font = NSFont.systemFont(ofSize: 12)
        instructionLabel.textColor = .secondaryLabelColor
        instructionLabel.alignment = .center

        pixelLabel = NSTextField(labelWithString: formatPixels(0))
        pixelLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 28, weight: .medium)
        pixelLabel.alignment = .center

        let pixelContainer = NSView()
        pixelContainer.wantsLayer = true
        pixelContainer.layer?.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.7).cgColor
        pixelContainer.layer?.cornerRadius = 10
        pixelContainer.layer?.borderWidth = 0.5
        pixelContainer.layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.18).cgColor
        pixelContainer.translatesAutoresizingMaskIntoConstraints = false

        pixelLabel.translatesAutoresizingMaskIntoConstraints = false
        pixelContainer.addSubview(pixelLabel)
        NSLayoutConstraint.activate([
            pixelLabel.centerXAnchor.constraint(equalTo: pixelContainer.centerXAnchor),
            pixelLabel.centerYAnchor.constraint(equalTo: pixelContainer.centerYAnchor)
        ])

        statusLabel = NSTextField(labelWithString: NSLocalizedString("settings.mouseDistanceCalibration.status.waiting", comment: ""))
        statusLabel.font = NSFont.systemFont(ofSize: 12)
        statusLabel.textColor = .secondaryLabelColor
        statusLabel.alignment = .center

        resultLabel = NSTextField(wrappingLabelWithString: "")
        resultLabel.font = NSFont.systemFont(ofSize: 12)
        resultLabel.textColor = .secondaryLabelColor
        resultLabel.alignment = .center
        resultLabel.isHidden = true

        retryButton = NSButton(title: NSLocalizedString("settings.mouseDistanceCalibration.retry", comment: ""), target: self, action: #selector(retryCalibration))
        retryButton.bezelStyle = .rounded
        retryButton.controlSize = .regular

        closeButton = NSButton(title: NSLocalizedString("settings.mouseDistanceCalibration.cancel", comment: ""), target: self, action: #selector(closeWindow))
        closeButton.bezelStyle = .rounded
        closeButton.controlSize = .regular

        let buttonRow = NSStackView(views: [retryButton, closeButton])
        buttonRow.orientation = .horizontal
        buttonRow.alignment = .centerY
        buttonRow.spacing = 8

        let contentStack = NSStackView(views: [
            titleLabel,
            instructionLabel,
            pixelContainer,
            statusLabel,
            resultLabel,
            buttonRow
        ])
        contentStack.orientation = .vertical
        contentStack.alignment = .centerX
        contentStack.spacing = 10
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -16),
            pixelContainer.widthAnchor.constraint(equalTo: contentStack.widthAnchor),
            pixelContainer.heightAnchor.constraint(equalToConstant: 64),
            instructionLabel.widthAnchor.constraint(equalTo: contentStack.widthAnchor),
            resultLabel.widthAnchor.constraint(equalTo: contentStack.widthAnchor)
        ])
    }

    private func restartCalibration() {
        StatsManager.shared.cancelMouseDistanceCalibration()
        hasCompleted = false
        resultLabel.isHidden = true
        resultLabel.stringValue = ""
        resultLabel.textColor = .secondaryLabelColor
        statusLabel.stringValue = NSLocalizedString("settings.mouseDistanceCalibration.status.waiting", comment: "")
        pixelLabel.stringValue = formatPixels(0)
        updateCloseButtonTitle()
        startTimer()

        let calibrationDistanceMeters = 0.10
        StatsManager.shared.beginMouseDistanceCalibration(knownMeters: calibrationDistanceMeters) { [weak self] result in
            self?.handleCompletion(result)
        }
    }

    private func handleCompletion(_ result: StatsManager.MouseDistanceCalibrationResult) {
        hasCompleted = true
        stopTimer()
        switch result {
        case .success(let pixels, let factor):
            pixelLabel.stringValue = formatPixels(pixels)
            statusLabel.stringValue = NSLocalizedString("settings.mouseDistanceCalibration.success.title", comment: "")
            let pixelText = formatPixels(pixels)
            let factorText = String(format: "%.3f×", factor)
            resultLabel.stringValue = String(
                format: NSLocalizedString("settings.mouseDistanceCalibration.success.message", comment: ""),
                pixelText,
                factorText
            )
            resultLabel.textColor = .secondaryLabelColor
            resultLabel.isHidden = false
        case .failure(let pixels):
            pixelLabel.stringValue = formatPixels(pixels)
            statusLabel.stringValue = NSLocalizedString("settings.mouseDistanceCalibration.failure.title", comment: "")
            resultLabel.stringValue = NSLocalizedString("settings.mouseDistanceCalibration.failure.message", comment: "")
            resultLabel.textColor = .systemRed
            resultLabel.isHidden = false
        }
        updateCloseButtonTitle()
    }

    private func startTimer() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.refreshLiveStatus()
        }
        if let timer = updateTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
        refreshLiveStatus()
    }

    private func stopTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    private func refreshLiveStatus() {
        guard !hasCompleted else { return }
        if StatsManager.shared.isMouseDistanceCalibrating {
            let pixels = StatsManager.shared.currentMouseDistanceCalibrationPixels()
            let pixelText = formatPixels(pixels)
            pixelLabel.stringValue = pixelText
            statusLabel.stringValue = String(
                format: NSLocalizedString("settings.mouseDistanceCalibration.status.moving", comment: ""),
                pixelText
            )
        } else if StatsManager.shared.isMouseDistanceCalibrationActive {
            pixelLabel.stringValue = formatPixels(0)
            statusLabel.stringValue = NSLocalizedString("settings.mouseDistanceCalibration.status.waiting", comment: "")
        } else {
            statusLabel.stringValue = ""
        }
    }

    private func cleanup() {
        stopTimer()
        StatsManager.shared.cancelMouseDistanceCalibration()
    }

    private func updateCloseButtonTitle() {
        let titleKey = hasCompleted ? "settings.mouseDistanceCalibration.close" : "settings.mouseDistanceCalibration.cancel"
        closeButton.title = NSLocalizedString(titleKey, comment: "")
    }

    private func formatPixels(_ pixels: Double) -> String {
        return String(format: "%.0f px", pixels)
    }

    @objc private func retryCalibration() {
        restartCalibration()
    }

    @objc private func closeWindow() {
        cleanup()
        view.window?.close()
    }
}
