🔐 LAPS Password Retrieval

A macOS application designed to securely retrieve and manage LAPS (Local Administrator Password Solution) credentials in enterprise environments.

📌 Overview

This tool provides a streamlined and secure interface for IT administrators to retrieve LAPS passwords without manually querying directory services or running scripts.

The application integrates with Jamf Pro and stores configuration securely in the macOS Keychain, ensuring credentials are never exposed in plain text.

✨ Features
🔍 Retrieve LAPS passwords securely
🔐 Store configuration in macOS Keychain
🖥️ Native macOS UI (Swift / SwiftUI)
⚡ Fast and responsive interface
🧩 Designed for enterprise environments
📋 Simple workflow for IT administrators
🏗️ Tech Stack
Swift
SwiftUI / AppKit
macOS Keychain Services
Jamf Pro API
🚀 Deployment
1. Install the App
Download the app
Move it to:
/Applications

⚠️ The app must be installed in /Applications before running the setup script.

🔑 Keychain Configuration

The application requires configuration to be stored in the macOS Keychain.

A helper script is included to securely store all required API details.

✅ Recommended: Jamf Pro Policy Deployment

This is the recommended method for production rollout.

📌 Why use this method
No secrets stored in script files
Centralized deployment
Easy credential rotation
Secure enterprise rollout
🧾 Script Location
scripts/setup_keychain_config.sh
⚙️ Jamf Pro Script Parameters
Parameter	Description
4	Jamf Pro URL
5	OAuth Client ID
6	OAuth Client Secret
7	Teams Webhook URL

Parameters 1–3 can remain empty.

🛠️ Jamf Policy Steps
Upload the script to Jamf Pro
Create a new policy
Add the script to the policy
Populate parameters 4–7
Scope the policy to target devices
Ensure the app is installed in /Applications
Run the policy
📥 Example Parameter Values
Parameter 4: https://your-jamf-url.example.com
Parameter 5: your-client-id
Parameter 6: your-client-secret
Parameter 7: https://your-teams-webhook-url
⚠️ Manual Setup (Not Recommended for Production)

This method is intended only for testing or small-scale usage.

⚠️ Security Warning

Do NOT commit scripts with real credentials to GitHub.

🛠️ Steps
Install the app into:
/Applications
Edit the script:

Replace:

JAMF_URL="${4:-}"
CLIENT_ID="${5:-}"
CLIENT_SECRET="${6:-}"
TEAMS_URL="${7:-}"

With:

JAMF_URL="https://your-jamf-url.example.com"
CLIENT_ID="your-client-id"
CLIENT_SECRET="your-client-secret"
TEAMS_URL="your-teams-webhook-url"
Run the script:
chmod +x scripts/setup_keychain_config.sh
sudo ./scripts/setup_keychain_config.sh
🚫 Why this is not recommended
Secrets stored in plain script
Risk of accidental exposure
Difficult to manage at scale
Not suitable for enterprise rollout
🔄 How It Works
The script stores a JSON configuration in the macOS Keychain
The app reads the configuration securely at runtime
Access is restricted to the installed application
The script recreates the Keychain entry on each run
📝 Logging

The script writes logs to:

/Library/Logs/JamfLAPSUI_KeychainSetup.log
🛡️ Security Considerations
Credentials are stored using macOS Keychain encryption
Access is limited to the app bundle
No secrets are stored in the repository
Recommended to use Jamf policy-based deployment
📄 License

MIT License

Copyright (c) 2026 Deepak Gandhi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND...

👤 Author

Deepak Gandhi
GitHub: https://github.com/DeepakGandhi24

🙌 Acknowledgements
Microsoft LAPS
Jamf Pro API
Apple Developer Documentation