//
//  APIHandler.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 29.03.26.
//

import Foundation
import OSLog

nonisolated open class ApiHandler {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ApiHandler.self)
    )
    
    let session: URLSession
    let serverURL: URL
    let jsonDecoder: JSONDecoder
    
    nonisolated public init(serverURL: URL) {
        self.serverURL = serverURL
        
        self.session = URLSession.shared
        
        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.dateDecodingStrategy = .iso8601
    }
    
    private func sendRequest(to endpoint: ApiEndpoint, method: HTTPMethod = .GET, body: Data? = nil, parameters: [URLQueryItem] = []) async throws -> Data {
        var request = URLRequest(url: self.serverURL.appendingApiPath(endpoint).appending(queryItems: parameters))
        
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        Self.logger.debug("Sending \(method.rawValue, privacy: .public) request to \(endpoint.toPath(), privacy: .public)")
        
        let (data, response) = try await self.session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if 200...299 ~= httpResponse.statusCode {
                return data
            } else if 403 == httpResponse.statusCode {
                Self.logger.error("Server returned 403:\n\(String(data: data, encoding: .utf8) ?? "", privacy: .public)")
                throw ApiError.forbidden
            } else if 404 == httpResponse.statusCode {
                Self.logger.error("Server returned 404:\n\(String(data: data, encoding: .utf8) ?? "", privacy: .public)")
                throw ApiError.notFound
            } else {
                Self.logger.error("Server returned unexpected status code \(httpResponse.statusCode, privacy: .public) and response:\n\(String(data: data, encoding: .utf8) ?? "", privacy: .public)\nQueried endpoint: \(endpoint.toPath(), privacy: .public)")
                throw ApiError.unexpectedHTTPStatus(data, httpResponse.statusCode)
            }
        }
        
        Self.logger.error("Server returned unexpected response:\n\(String(data: data, encoding: .utf8) ?? "", privacy: .public)")
        throw ApiError.invalidResponse(data, response)
    }
    
    open func get<T: Decodable>(from endpoint: ApiEndpoint, parameters: [URLQueryItem] = []) async throws -> T {
        let data = try await self.sendRequest(to: endpoint, parameters: parameters)
        return try self.jsonDecoder.decode(T.self, from: data)
    }
    
    open func getData(from endpoint: ApiEndpoint) async throws -> Data {
        return try await self.sendRequest(to: endpoint)
    }
}

// MARK: - Convenience Methods
extension ApiHandler {
    
    // MARK: Auth
    
    /**
     Create a new user account
     
     - Parameter username:      minimum 3 characters
     - Parameter mailAddress:
     - Parameter password:      minimum 8 characters, can be tested beforehand using `checkPasswordStrength(String)`
     - Parameter language:      InterfaceLanguage (currently either `en` or `de`)
     */
    public func register(username: String, password: String, mailAddress: String, language: InterfaceLanguage) async throws {
        let credentials = [
            "Username": username,
            "Email": mailAddress,
            "Password": password,
            "Language": language.rawValue
        ]
        
        // Just returns a success message and a 201
        let _ = try await self.sendRequest(to: .register, method: .POST, body: try JSONEncoder().encode(credentials))
    }
    
    /**
     Authenticate and set session cookie
     - Parameter username
     - Parameter password
     
     - Returns: LoginResponse, if authentication was successful
     */
    public func login(username: String, password: String) async throws -> LoginResponse {
        let credentials = [
            "identifier": username,
            "password": password
        ]
        
        let encoder = JSONEncoder()
        
        let data = try await self.sendRequest(to: .login, method: .POST, body: encoder.encode(credentials))
        
        return try JSONDecoder().decode(LoginResponse.self, from: data)
    }
    
    /**
     Clear current session cookie
     */
    public func logout() async throws {
        let _ = try await self.sendRequest(to: .logout, method: .POST)
    }
    
    /**
     Validate a password without registering
     - Parameter password: Password to check
     
     - Returns: PasswordStrengthResponse for the given password
     */
    public func checkPasswordStrength(password: String) async throws -> PasswordStrengthResponse {
        let passwordDict = [
            "Password": password
        ]
        
        let encoder = JSONEncoder()
        
        let data = try await self.sendRequest(to: .checkPasswordStrength, method: .POST, body: encoder.encode(passwordDict))
        
        return try JSONDecoder().decode(PasswordStrengthResponse.self, from: data)
    }
    
    /**
     Send a password reset email
     - Parameter mailAddress: Mail address of the user whos password should be reset
    */
    func requestPasswordReset(mailAddress: String) async throws {
        let mailDict = [
            "Email": mailAddress
        ]
        
        let encoder = JSONEncoder()
        
        let _ = try await self.sendRequest(to: .requestPasswordReset, method: .POST, body: encoder.encode(mailDict))
    }
    
    /**
     Apply a password reset token
     - Parameter token: Token from the password reset mail
     - Parameter newPassword: New password for the user
     */
    func requestPasswordReset(token: String, newPassword: String) async throws {
        let tokenPassDict = [
            "Token": token,
            "Password": newPassword
        ]
        
        let encoder = JSONEncoder()
        
        let _ = try await self.sendRequest(to: .confirmPasswordReset, method: .POST, body: encoder.encode(tokenPassDict))
    }
    
    // MARK: User
    /// Get the current user
    public func getMe() async throws -> User {
        return try await self.get(from: .me)
    }
    /// Change password (POST)
    //case changePassword
    /// Update UI language preference (PATCH)
    //case language
    /// Update date format preference (PATCH)
    //case dateFormat
    /// Get custom field names (GET/PATCH)
    //case customFields
    
    // MARK: Contacts
    /// List contacts (GET/POST)
    public func getContacts(fields: [Contact.CodingKeys] = Contact.defaultFields) async throws -> [Contact] {
        let fieldsQueryItem = URLQueryItem(name: "fields", value: fields.map{ $0.rawValue }.joined(separator: ","))
        let response: PaginatedResponse<Contact> = try await self.get(from: .contacts, parameters: [fieldsQueryItem])
        return response.results
    }
    
    /// Get a contact (GET/PUT/DELETE)
    public func getContact(id: Int) async throws -> Contact {
        return try await self.get(from: .contact(id: id))
    }
    /// Archive a contact (POST)
    //case archiveContact(id: Int)
    /// Unarchive a contact (POST)
    //case unarchiveContact(id: Int)
    /// List all circles in use (GET)
    //case circles
    /// Get five random contacts (GET)
    //case random
    /// Get upcoming birthdays (GET)
    //case birthdays
    /// Get a contact’s profile picture (GET/POST)
    public func getContactImage(contactId: Int) async throws -> Data {
        return try await self.getData(from: .contactImage(id: contactId))
    }
    /// Proxy an external image URL for upload preview (GET)
    //case proxyImage
    
    // MARK: Relationship Endpoints
    /// List outgoing relationships (GET/POST)
    //case relationships(contactId: Int)
    /// List incoming relationships (GET)
    //case incomingRelationships(contactId: Int)
    /// Update a relationship (PUT/DELETE)
    //case updateRelationship(contactId: Int, relationshipId: Int)
    
    // MARK: Note Endpoints
    /// List notes for a contact (GET/POST)
    //case contactNotes(contactId: Int)
    /// List unassigned notes (GET/POST)
    //case unassignedNotes
    /// Get a note (GET/PUT/DELETE)
    //case note(id: Int)
    
    // MARK: Activity Endpoints
    /// List all activities (GET/POST)
    //case activities
    /// Get an activity (GET/PUT/DELETE)
    //case activity(id: Int)
    /// List activities for a contact (GET)
    //case contactActivities(contactId: Int)
    
    // MARK: Reminder Endpoints
    /// List all reminders (GET)
    //case reminders
    /// List upcoming reminders (used by dashboard) (GET)
    //case upcomingReminders
    /// Get a reminder (GET/PUT/DELETE)
    //case reminder(id: Int)
    /// Mark a reminder complete (creates timeline entry) (POST)
    //case completeReminder(id: Int)
    /// List reminders for a contact (POST/GET)
    //case contactReminders(contactId: Int)
    /// List completion history for a contact (timeline entries) (GET)
    //case completedReminders(contactId: Int)
    /// Delete a completion entry (DELETE)
    //case reminderCompletions(id: Int)
    
    // MARK: Graph
    /// Get contact network graph data (GET)
    //case graph
    
    // MARK: Admin
    /// List all users (GET)
    //case users
    /// Get a user (GET/PATCH/DELETE)
    //case user(id: Int)
    
    // MARK: Health
    /// Health check
    //case health
}
