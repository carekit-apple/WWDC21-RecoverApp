# Recover

Recover is a sample study app built using Apple's ResearchKit and CareKit frameworks. Be sure to watch the accompanying WWDC videos.
- [Build a research and care app, part 1: Setup onboarding](https://developer.apple.com/wwdc21/10068)
- [Build a research and care app, part 2: Schedule tasks](https://developer.apple.com/wwdc21/10069)
- [Build a research and care app, part 3: Visualize progress](https://developer.apple.com/wwdc21/10282)

# Minimum Requirements

- iOS 13.0
- Xcode 12.0

# Setup

1. Download the repository and the required submodules:

    ```bash
    git clone --recurse-submodule https://github.com/carekit-apple/WWDC21-RecoverApp.git
    ```

2. Choose the target named `Recover` and run the app.

# Files

- `AppDelegate.swift`: Contains logic that sets up the CareKit store.

- `Surveys.swift`: Defines ResearchKit tasks such as surveys and onboarding.

- `CareFeedViewController.swift`: Contains logic that fetches and displays tasks from the CareKit store.

- `InsightsViewController.swift` Contains logic that sets up the 3D model and charts for visualizing progress.

# 3D Model

By default, the "Insights" tab in the app displays a 3D model of a toy robot. To view the toy robot, download [this](https://developer.apple.com/augmented-reality/quick-look/models/vintagerobot2k/toy_robot_vintage.usdz) file and drag it into your project in Xcode. Alternatively, you can provide custom built models or use 3rd party solutions. In order to display the knee model shown in the demo, you can install the SDK provided by - [BioDigital](https://developer.biodigital.com/docs/ios-sdk/apple-research-kit).
