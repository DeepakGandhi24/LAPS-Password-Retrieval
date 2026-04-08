import SwiftUI
import Foundation
import AppKit
import Security
import Combine

struct ContentView: View {
    @StateObject private var viewModel = LAPSViewModel()

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroCard
                    statusBanner
                    inputSection
                    resultSection
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            viewModel.loadConfigFromKeychain()
            viewModel.refreshAuditLogPreview()
        }
    }

    private var sidebar: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)

                            ZStack {
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(.white)

                                Image("GenesysIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 12, height: 12)
                                    .background(
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 16, height: 16)
                                    )
                                    .offset(x: 10, y: 10)
                            }
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("JamfLAPSUI")
                                .font(.headline)
                            Text("Secure retrieval")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Label("Secure configuration loaded", systemImage: "key.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }

            Section("Actions") {
                actionButton(
                    title: "Retrieve Password",
                    systemImage: "key.horizontal.fill",
                    tint: .blue
                ) {
                    Task { await viewModel.retrievePassword() }
                }
                .disabled(viewModel.isWorking)

                actionButton(
                    title: "Copy Password",
                    systemImage: "doc.on.doc.fill",
                    tint: .green
                ) {
                    viewModel.copyPassword()
                }
                .disabled(viewModel.password.isEmpty)

                actionButton(
                    title: "Clear Results",
                    systemImage: "arrow.counterclockwise",
                    tint: .orange
                ) {
                    viewModel.clearResults()
                }
                .disabled(viewModel.isWorking)
            }
            Section("Preferences") {
                Toggle(isOn: $viewModel.maskPassword) {
                    Label("Mask Password", systemImage: "eye.slash.fill")
                }
            }

        }
        .navigationTitle("LAPS Password Retrieval")
        .listStyle(.sidebar)
    }

    private func actionButton(title: String, systemImage: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)
        }
        .buttonStyle(.borderedProminent)
        .tint(tint)
    }
    private func brandedIcon(size: CGFloat) -> some View {
        Image("GenesysIcon")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
    private var heroCard: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.95), Color.cyan.opacity(0.9), Color.indigo.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 10)

            Circle()
                .fill(.white.opacity(0.10))
                .frame(width: 220, height: 220)
                .offset(x: 80, y: 70)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Jamf LAPS Password Retrieval")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)

                        Text("Securely retrieve LAPS passwords from Jamf Pro using configuration loaded from Keychain.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.white.opacity(0.14))
                            .frame(width: 68, height: 68)

                        ZStack {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundStyle(.white)

                            Image("GenesysIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                .background(
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 18, height: 18)
                                )
                                .offset(x: 14, y: 14)
                                .shadow(radius: 1)
                        }
                    }
                }

                HStack(spacing: 10) {
                    statusPill(
                        title: viewModel.isWorking ? "Working" : "Ready",
                        systemImage: viewModel.isWorking ? "hourglass" : "checkmark.circle.fill",
                        background: .white.opacity(0.16)
                    )

                    statusPill(
                        title: viewModel.isError ? "Error" : "Secure Mode",
                        systemImage: viewModel.isError ? "exclamationmark.triangle.fill" : "shield.lefthalf.filled",
                        background: .white.opacity(0.16)
                    )
                }
            }
            .padding(24)
        }
        .frame(minHeight: 190)
    }

    private func statusPill(title: String, systemImage: String, background: Color) -> some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(background, in: Capsule())
    }

    private var inputSection: some View {
        cardContainer(title: "Request Details", subtitle: "Enter the target details and business justification.") {
            VStack(alignment: .leading, spacing: 14) {
                TextField("LAPS Account", text: $viewModel.lapsAccount)
                    .textFieldStyle(.roundedBorder)

                TextField("Serial Number", text: $viewModel.serialNumber)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: viewModel.serialNumber) { _, newValue in
                        viewModel.serialNumber = newValue
                            .uppercased()
                            .replacingOccurrences(of: " ", with: "")
                    }

                TextField("Business Justification", text: $viewModel.reason, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
            }
        }
    }

    private var resultSection: some View {
        cardContainer(title: "Results", subtitle: "Retrieved details from Jamf and Teams audit status.") {
            VStack(alignment: .leading, spacing: 12) {
                ResultRow(title: "Target Serial", value: viewModel.serialNumber)
                ResultRow(title: "Jamf Computer ID", value: viewModel.computerID)
                ResultRow(title: "Management ID", value: viewModel.managementID)
                ResultRow(title: "LAPS Account", value: viewModel.foundUser)
                ResultRow(title: "Password", value: viewModel.displayPassword)
                ResultRow(title: "Teams Status", value: viewModel.teamsStatus)
            }
        }
    }

    private var statusBanner: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: viewModel.isError ? "exclamationmark.triangle.fill" : "info.circle.fill")
                .foregroundStyle(viewModel.isError ? .red : .blue)

            Text(viewModel.statusMessage)
                .foregroundStyle(viewModel.isError ? .red : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(viewModel.isError ? Color.red.opacity(0.08) : Color.blue.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(viewModel.isError ? Color.red.opacity(0.18) : Color.blue.opacity(0.14), lineWidth: 1)
        )
    }
    private func cardContainer<Content: View>(title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.semibold))
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            content()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}

struct ResultRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(title)
                .fontWeight(.semibold)
                .frame(width: 170, alignment: .leading)

            Text(value.isEmpty ? "-" : value)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.primary.opacity(0.05))
                )
        }
    }
}

struct AppConfig: Codable {
    let jamfURL: String
    let clientID: String
    let clientSecret: String
    let teamsURL: String
}

@MainActor
final class LAPSViewModel: ObservableObject {
    @Published var jamfURL = ""
    @Published var clientID = ""
    @Published var clientSecret = ""
    @Published var teamsURL = ""

    @Published var lapsAccount = ""
    @Published var serialNumber = ""
    @Published var reason = ""

    @Published var computerID = ""
    @Published var managementID = ""
    @Published var foundUser = ""
    @Published var password = ""
    @Published var teamsStatus = ""
    @Published var statusMessage = "Ready"
    @Published var isError = false
    @Published var isWorking = false
    @Published var maskPassword = true
    @Published var auditLogPreview = ""

    let auditLogPath = NSHomeDirectory() + "/Library/Logs/JamfLAPSUI_Audit.log"

    var displayPassword: String {
        guard !password.isEmpty else { return "" }
        return maskPassword ? String(repeating: "•", count: max(password.count, 8)) : password
    }

    func loadConfigFromKeychain() {
        do {
            let json = try KeychainHelper.load(service: "JamfLAPSUI", account: "config")
            let data = Data(json.utf8)
            let config = try JSONDecoder().decode(AppConfig.self, from: data)

            jamfURL = config.jamfURL.trimmingCharacters(in: .whitespacesAndNewlines)
            clientID = config.clientID
            clientSecret = config.clientSecret
            teamsURL = config.teamsURL

            statusMessage = "Configuration loaded from Keychain."
            isError = false
        } catch let error as NSError {
            if error.code == -25300 {
                statusMessage = "Configuration not found in Keychain. Please run the Jamf Keychain setup policy."
            } else {
                statusMessage = "Failed to load configuration from Keychain: \(error.localizedDescription)"
            }
            isError = true
        }
    }

    func clearInputs() {
        lapsAccount = ""
        serialNumber = ""
        reason = ""
    }

    func clearResults() {
        lapsAccount = ""
        serialNumber = ""
        reason = ""

        computerID = ""
        managementID = ""
        foundUser = ""
        password = ""
        teamsStatus = ""
        statusMessage = "Ready"
        isError = false
    }

    func copyPassword() {
        guard !password.isEmpty else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(password, forType: .string)
        statusMessage = "Password copied to clipboard."
        isError = false
    }

    func retrievePassword() async {
        guard validateInputs() else { return }

        isWorking = true
        isError = false
        statusMessage = "Requesting OAuth token..."

        do {
            let service = JamfService(baseURL: jamfURL, clientID: clientID, clientSecret: clientSecret)
            let token = try await service.fetchToken()

            log("START | runnerUser=\(NSUserName()) | runnerMac=\(Host.current().localizedName ?? "Unknown")")
            log("INPUT | targetSerial=\(serialNumber) | lapsUser=\(lapsAccount) | reason=\(reason)")

            statusMessage = "Looking up computer record..."
            let computerID = try await service.fetchComputerID(serial: serialNumber, token: token)
            self.computerID = String(computerID)

            statusMessage = "Loading inventory details..."
            let managementID = try await service.fetchManagementID(computerID: computerID, token: token)
            self.managementID = managementID

            statusMessage = "Retrieving LAPS password..."
            let pwd = try await service.fetchLAPSPassword(managementID: managementID, account: lapsAccount, token: token)
            self.password = pwd
            self.foundUser = lapsAccount

            log("SUCCESS | password retrieved | serial=\(serialNumber) | computerID=\(computerID) | managementID=\(managementID)")

            if !teamsURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                statusMessage = "Posting Teams audit event..."
                let teamsService = TeamsService(webhookURL: teamsURL)
                let teamsResponse = try await teamsService.postAdaptiveCard(
                    timestamp: Self.timestamp(),
                    runnerUser: NSUserName(),
                    runnerMac: Host.current().localizedName ?? "Unknown",
                    targetSerial: serialNumber,
                    lapsAccount: lapsAccount,
                    reason: reason,
                    jamfID: String(computerID),
                    managementID: managementID
                )
                teamsStatus = teamsResponse
                log("TEAMS | \(teamsResponse)")
            } else {
                teamsStatus = "Skipped"
            }

            statusMessage = "Password retrieved successfully."
            isError = false
            log("END | completed")
            refreshAuditLogPreview()
        } catch {
            statusMessage = error.localizedDescription
            isError = true
            log("ERROR | \(error.localizedDescription)")
            refreshAuditLogPreview()
        }

        isWorking = false
    }

    func sendTeamsTest() async {
        guard !teamsURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            statusMessage = "Teams webhook URL is empty."
            isError = true
            return
        }

        isWorking = true
        defer { isWorking = false }

        do {
            let teamsService = TeamsService(webhookURL: teamsURL)
            let result = try await teamsService.postAdaptiveCard(
                timestamp: Self.timestamp(),
                runnerUser: NSUserName(),
                runnerMac: Host.current().localizedName ?? "Unknown",
                targetSerial: serialNumber.isEmpty ? "TEST-SERIAL" : serialNumber,
                lapsAccount: lapsAccount.isEmpty ? "test_account" : lapsAccount,
                reason: reason.isEmpty ? "Webhook connectivity test" : reason,
                jamfID: computerID.isEmpty ? "N/A" : computerID,
                managementID: managementID.isEmpty ? "N/A" : managementID
            )
            teamsStatus = result
            statusMessage = "Teams test sent successfully."
            isError = false
        } catch {
            statusMessage = "Teams test failed: \(error.localizedDescription)"
            isError = true
        }
    }

    private func validateInputs() -> Bool {
        if jamfURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            clientID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            clientSecret.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            statusMessage = "Configuration is missing. Please run the Jamf Keychain setup policy first."
            isError = true
            return false
        }
        
        if let url = URL(string: jamfURL) {
            print("Valid URL:", url)
        } else {
            statusMessage = "Jamf URL is malformed."
            isError = true
            return false
        }
        if lapsAccount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            serialNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            statusMessage = "LAPS account, serial number, and business justification are required."
            isError = true
            return false
        }

        return true
    }

    private func log(_ message: String) {
        let line = "\(Self.timestamp()) | \(message)\n"
        let path = auditLogPath
        let data = Data(line.utf8)

        let directory = (path as NSString).deletingLastPathComponent
        try? FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)

        if !FileManager.default.fileExists(atPath: path) {
            FileManager.default.createFile(atPath: path, contents: nil)
        }

        if let handle = FileHandle(forWritingAtPath: path) {
            do {
                try handle.seekToEnd()
                try handle.write(contentsOf: data)
                try handle.close()
            } catch {
                statusMessage = "Audit log write failed: \(error.localizedDescription)"
                isError = true
            }
        }
    }

    func refreshAuditLogPreview() {
        auditLogPreview = (try? String(contentsOfFile: auditLogPath, encoding: .utf8)) ?? "No audit log found yet."
    }

    static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
}

struct OAuthTokenResponse: Codable {
    let access_token: String
}

struct LegacyComputerResponse: Codable {
    let computer: LegacyComputer
}

struct LegacyComputer: Codable {
    let general: LegacyGeneral
}

struct LegacyGeneral: Codable {
    let id: Int
}

struct InventoryResponse: Codable {
    let general: InventoryGeneral
}

struct InventoryGeneral: Codable {
    let managementId: String
}

struct LAPSPasswordResponse: Codable {
    let password: String
}

enum JamfLAPSError: LocalizedError {
    case invalidURL
    case httpError(Int, String)
    case missingData(String)
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration."
        case let .httpError(code, body):
            return "Request failed with HTTP \(code). Response: \(body)"
        case let .missingData(message):
            return message
        case .encodingFailed:
            return "Failed to encode one of the request values."
        }
    }
}

struct JamfService {
    let baseURL: String
    let clientID: String
    let clientSecret: String

    func fetchToken() async throws -> String {
        print("DEBUG URL:", normalizedBaseURL + "/api/oauth/token")
        guard let url = URL(string: normalizedBaseURL + "/api/oauth/token") else {
            throw JamfLAPSError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = [
            "grant_type=client_credentials",
            "client_id=\(percentEncode(clientID))",
            "client_secret=\(percentEncode(clientSecret))"
        ].joined(separator: "&")
        request.httpBody = body.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)

        let decoded = try JSONDecoder().decode(OAuthTokenResponse.self, from: data)
        return decoded.access_token
    }

    func fetchComputerID(serial: String, token: String) async throws -> Int {
        guard let url = URL(string: normalizedBaseURL + "/JSSResource/computers/serialnumber/\(percentEncodePath(serial))") else {
            throw JamfLAPSError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)

        let decoded = try JSONDecoder().decode(LegacyComputerResponse.self, from: data)
        return decoded.computer.general.id
    }

    func fetchManagementID(computerID: Int, token: String) async throws -> String {
        guard let url = URL(string: normalizedBaseURL + "/api/v1/computers-inventory/\(computerID)?section=GENERAL") else {
            throw JamfLAPSError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)

        let decoded = try JSONDecoder().decode(InventoryResponse.self, from: data)
        return decoded.general.managementId
    }

    func fetchLAPSPassword(managementID: String, account: String, token: String) async throws -> String {
        guard let encodedAccount = account.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw JamfLAPSError.encodingFailed
        }
        guard let url = URL(string: normalizedBaseURL + "/api/v2/local-admin-password/\(managementID)/account/\(encodedAccount)/password") else {
            throw JamfLAPSError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)

        let decoded = try JSONDecoder().decode(LAPSPasswordResponse.self, from: data)
        guard !decoded.password.isEmpty else {
            throw JamfLAPSError.missingData("Password was not returned by Jamf.")
        }
        return decoded.password
    }

    private var normalizedBaseURL: String {
        let trimmed = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.hasSuffix("/") ? String(trimmed.dropLast()) : trimmed
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw JamfLAPSError.missingData("No HTTP response received.")
        }
        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "<non-text response>"
            throw JamfLAPSError.httpError(http.statusCode, body)
        }
    }

    private func percentEncode(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
    }

    private func percentEncodePath(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? value
    }
}

struct TeamsService {
    let webhookURL: String

    func postAdaptiveCard(
        timestamp: String,
        runnerUser: String,
        runnerMac: String,
        targetSerial: String,
        lapsAccount: String,
        reason: String,
        jamfID: String,
        managementID: String
    ) async throws -> String {
        guard let url = URL(string: webhookURL) else {
            throw JamfLAPSError.invalidURL
        }

        let payload = AdaptiveCardPayload(
            type: "AdaptiveCard",
            schema: "http://adaptivecards.io/schemas/adaptive-card.json",
            version: "1.4",
            body: [
                .textBlock(TextBlock(type: "TextBlock", size: "Medium", weight: "Bolder", text: "JAMF LAPS Password Viewed", wrap: nil, spacing: nil)),
                .textBlock(TextBlock(type: "TextBlock", size: nil, weight: nil, text: "This event was generated by the Jamf Self Service LAPS viewer app.", wrap: true, spacing: "Small")),
                .factSet(FactSet(type: "FactSet", facts: [
                    Fact(title: "Time:", value: timestamp),
                    Fact(title: "Runner user:", value: runnerUser),
                    Fact(title: "Runner machine:", value: runnerMac),
                    Fact(title: "Target serial:", value: targetSerial),
                    Fact(title: "LAPS account:", value: lapsAccount),
                    Fact(title: "Reason:", value: reason),
                    Fact(title: "Jamf Computer ID:", value: jamfID),
                    Fact(title: "Management ID:", value: managementID)
                ]))
            ]
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw JamfLAPSError.missingData("No HTTP response received from Teams.")
        }

        let responseText = String(data: data, encoding: .utf8) ?? "<empty>"
        guard (200...299).contains(http.statusCode) else {
            throw JamfLAPSError.httpError(http.statusCode, responseText)
        }

        return "HTTP \(http.statusCode): \(responseText)"
    }
}

struct AdaptiveCardPayload: Codable {
    let type: String
    let schema: String
    let version: String
    let body: [AdaptiveCardBody]

    enum CodingKeys: String, CodingKey {
        case type
        case schema = "$schema"
        case version
        case body
    }
}

enum AdaptiveCardBody: Codable {
    case textBlock(TextBlock)
    case factSet(FactSet)

    func encode(to encoder: Encoder) throws {
        switch self {
        case let .textBlock(block):
            try block.encode(to: encoder)
        case let .factSet(set):
            try set.encode(to: encoder)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let block = try? container.decode(TextBlock.self) {
            self = .textBlock(block)
            return
        }
        if let set = try? container.decode(FactSet.self) {
            self = .factSet(set)
            return
        }
        throw DecodingError.typeMismatch(
            AdaptiveCardBody.self,
            .init(codingPath: decoder.codingPath, debugDescription: "Unknown body type")
        )
    }
}

struct TextBlock: Codable {
    let type: String
    let size: String?
    let weight: String?
    let text: String
    let wrap: Bool?
    let spacing: String?
}

struct FactSet: Codable {
    let type: String
    let facts: [Fact]
}

struct Fact: Codable {
    let title: String
    let value: String
}

enum KeychainHelper {
    static func save(service: String, account: String, value: String) throws {
        let data = Data(value.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)

        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }

    static func load(service: String, account: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }

        guard let data = item as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw JamfLAPSError.missingData("Could not decode Keychain value.")
        }

        return value
    }
}
