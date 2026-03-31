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
    
    public let serverURL: URL
    
    let session: URLSession
    let jsonDecoder: JSONDecoder
    let jsonEncoder: JSONEncoder
    
    nonisolated public init(serverURL: URL) {
        self.serverURL = serverURL
        
        self.session = URLSession.shared
        
        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.dateDecodingStrategy = .iso8601
        
        self.jsonEncoder = JSONEncoder()
        self.jsonEncoder.dateEncodingStrategy = .iso8601
    }
    
    open func sendRequest(to endpoint: ApiEndpoint, method: HTTPMethod = .GET, body: Data? = nil, multipartBoundary: String? = nil, parameters: [URLQueryItem] = []) async throws -> Data {
        
        var request = URLRequest(url: self.serverURL.appendingApiPath(endpoint).appending(queryItems: parameters))
        
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let multipartBoundary {
            request.addValue("multipart/form-data; boundary=\(multipartBoundary)", forHTTPHeaderField: "Content-Type")
        } else {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
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

// MARK: Auth
extension ApiHandler {
    
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
        _ = try await self.sendRequest(to: .register, method: .POST, body: try self.jsonEncoder.encode(credentials))
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
        
        let data = try await self.sendRequest(to: .login, method: .POST, body: self.jsonEncoder.encode(credentials))
        
        return try self.jsonDecoder.decode(LoginResponse.self, from: data)
    }
    
    /**
     Clear current session cookie
     */
    public func logout() async throws {
        _ = try await self.sendRequest(to: .logout, method: .POST)
    }
    
    /**
     Validate a password without registering
     - Parameter password: Password to check
     
     - Returns: PasswordStrengthResponse for the given password
     */
    public func checkPasswordStrength(_ password: String) async throws -> PasswordStrengthResponse {
        let passwordDict = [
            "Password": password
        ]
        
        let data = try await self.sendRequest(to: .checkPasswordStrength, method: .POST, body: self.jsonEncoder.encode(passwordDict))
        
        return try self.jsonDecoder.decode(PasswordStrengthResponse.self, from: data)
    }
    
    /**
     Send a password reset email
     - Parameter mailAddress: Mail address of the user whos password should be reset
     */
    public func requestPasswordReset(mailAddress: String) async throws {
        let mailDict = [
            "Email": mailAddress
        ]
        
        _ = try await self.sendRequest(to: .requestPasswordReset, method: .POST, body: self.jsonEncoder.encode(mailDict))
    }
    
    /**
     Apply a password reset token
     - Parameter token: Token from the password reset mail
     - Parameter newPassword: New password for the user
     */
    public func confirmPasswordReset(token: String, newPassword: String) async throws {
        let tokenPassDict = [
            "Token": token,
            "Password": newPassword
        ]
        
        _ = try await self.sendRequest(to: .confirmPasswordReset, method: .POST, body: self.jsonEncoder.encode(tokenPassDict))
    }
}


// MARK: User
extension ApiHandler {
    
    /** Get the current user
     - Returns: The current user
     */
    public func getMe() async throws -> User {
        return try await self.get(from: .me)
    }
    /**
     Change password
     - Parameter currentPassword: Current password of the user
     - Parameter newPassword: New password for the user
     */
    public func changePassword(currentPassword: String, newPassword: String) async throws {
        let passDict = [
            "current_password": currentPassword,
            "new_password": newPassword
        ]
        
        _ = try await self.sendRequest(to: .changePassword, method: .POST, body: self.jsonEncoder.encode(passDict))
    }
    
    /**
     Update UI language preference (WebUI only!)
     - Parameter newLanguage: New language to use
     */
    public func changeLanguage(_ newLanguage: InterfaceLanguage) async throws {
        let bodyDict = [
            "language": newLanguage.rawValue
        ]
        
        _ = try await self.sendRequest(to: .language, method: .PATCH, body: self.jsonEncoder.encode(bodyDict))
    }
    
    /**
     Update date format preference (WebUI only!)
     - Parameter newFormat: New date format to use
     */
    public func changeDateFormat(_ newFormat: DateFormat) async throws {
        let bodyDict = [
            "date_format": newFormat.rawValue
        ]
        
        _ = try await self.sendRequest(to: .dateFormat, method: .PATCH, body: self.jsonEncoder.encode(bodyDict))
    }
    
    /**
     Get custom field names
     - Returns: CustomFields object containing all custom field names
     */
    public func getCustomFields() async throws -> CustomFields {
        return try await self.get(from: .customFields)
    }
    
    /**
     Update custom field names
     - Parameter newFields: CustomFields object with the names of **all custom fields**, including those to be created
     
     - Returns: CustomFields object containing all custom field names
     */
    public func updateCustomFields(_ newFields: CustomFields) async throws -> CustomFields {
        let data = try await self.sendRequest(to: .customFields, method: .PATCH, body: self.jsonEncoder.encode(newFields))
        
        return try self.jsonDecoder.decode(CustomFields.self, from: data)
    }
}


// MARK: Contacts
extension ApiHandler {
    /**
     List contacts
     - Parameter fields: Fields to include with the response (defaults are sensible)
     - Parameter limit: Maximum number of contacts per page
     - Parameter page: Which page to load (starts at 1!)
     - Parameter sort: Which attribute to sort contacts by (defaults to `ID`)
     - Parameter order: Sort order, either `asc` or `desc`
     
     - Returns: List of contacts
     */
    public func getContacts(fields: [Contact.CodingKeys] = Contact.defaultFields, limit: Int = 50, page: Int = 1, sort: Contact.CodingKeys = .id, order: String = "desc") async throws -> [Contact] {
        let fieldsQueryItem = URLQueryItem(name: "fields", value: fields.map{ $0.rawValue }.joined(separator: ","))
        let response: PaginatedResponse<Contact> = try await self.get(from: .contacts, parameters: [fieldsQueryItem])
        return response.results
    }
    
    /**
     Create new contact
     - Parameter newContact: Contact object for the new contact
     
     - Returns: The newly created contact
     */
    public func createContact(_ newContact: Contact) async throws -> Contact {
        let data = try await self.sendRequest(to: .contacts, method: .POST, body: self.jsonEncoder.encode(newContact))
        
        return try self.jsonDecoder.decode(Contact.self, from: data)
    }
    
    /**
     Get a contact
     
     - Returns: The contact with the given id
     */
    public func getContact(id: Int) async throws -> Contact {
        return try await self.get(from: .contact(id: id))
    }
    
    /**
     Update an existing contact
     - Parameter contact: Contact object for the contact
     
     - Returns: The updated contact
     */
    public func updateContact(_ contact: Contact) async throws -> Contact {
        let data = try await self.sendRequest(to: .contact(id: contact.id), method: .PUT, body: self.jsonEncoder.encode(contact))
        
        return try self.jsonDecoder.decode(Contact.self, from: data)
    }
    
    /**
     Delete an existing contact
     - Parameter contact: Contact to delete
     */
    public func deleteContact(_ contact: Contact) async throws {
        _ = try await self.sendRequest(to: .contact(id: contact.id), method: .DELETE)
    }
    
    /**
     Archive a contact
     - Parameter contact: Contact to archive
     
     - Returns: The archived contact
     */
    public func archiveContact(_ contact: Contact) async throws -> Contact {
        let data = try await self.sendRequest(to: .archiveContact(id: contact.id), method: .POST)
        
        return try self.jsonDecoder.decode(Contact.self, from: data)
    }
    /**
     Unarchive a contact
     - Parameter contact: Contact to unarchive
     
     - Returns: The unarchived contact
     */
    public func unarchiveContact(_ contact: Contact) async throws -> Contact {
        let data = try await self.sendRequest(to: .unarchiveContact(id: contact.id), method: .POST)
        
        return try self.jsonDecoder.decode(Contact.self, from: data)
    }
    /**
     List all circles in use
     
     - Returns: A list of all currently used circles
     */
    public func getCircles() async throws -> [String] {
        return try await self.get(from: .circles)
    }
    
    /**
     Get five random contacts
     
     - Returns: Up to five random contacts
     */
    public func getRandomContacts() async throws -> [Contact] {
        // TODO: Check if this gets support for fields in the future
        let response: PaginatedResponse<Contact> = try await self.get(from: .contacts)
        return response.results
    }
    
    /// Get upcoming birthdays
    public func getUpcomingBirthdays() async throws -> [Birthday] {
        let response: PaginatedResponse<Birthday> = try await self.get(from: .birthdays)
        return response.results
    }
    
    /** Get a contact’s profile picture
     - Parameter contact: The contact whose profile should be loaded
     */
    public func getContactImage(contact: Contact) async throws -> Data {
        return try await self.getData(from: .contactImage(id: contact.id))
    }
    
    /**
     Upload an image for a contact
     - Parameter contact: The contact this image sohuld be assigned to
     - Parameter imageData: Binary data for the image
     
     - Returns: The updated contact
     */
    public func uploadContactImage(contact: Contact, imageURL: URL) async throws -> Contact {
        let boundary = UUID().uuidString
        
        let body = try imageURL.toMultipartData(with: boundary)
        let data = try await self.sendRequest(to: .contactImage(id: contact.id), method: .POST, body: body, multipartBoundary: boundary)
        
        return try self.jsonDecoder.decode(Contact.self, from: data)
    }
}


// MARK: Relationship Endpoints
extension ApiHandler {
    /// List outgoing relationships (GET/POST)
    //case relationships(contactId: Int)
    /// List incoming relationships (GET)
    //case incomingRelationships(contactId: Int)
    /// Update a relationship (PUT/DELETE)
    //case updateRelationship(contactId: Int, relationshipId: Int)
}


// MARK: Note Endpoints
extension ApiHandler {
    /// List notes for a contact (GET/POST)
    //case contactNotes(contactId: Int)
    /// List unassigned notes (GET/POST)
    //case unassignedNotes
    /// Get a note (GET/PUT/DELETE)
    //case note(id: Int)
}


// MARK: Activity Endpoints
extension ApiHandler {
    /// List all activities (GET/POST)
    //case activities
    /// Get an activity (GET/PUT/DELETE)
    //case activity(id: Int)
    /// List activities for a contact (GET)
    //case contactActivities(contactId: Int)
}


// MARK: Reminder Endpoints
extension ApiHandler {
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
}


// MARK: Graph
extension ApiHandler {
    /// Get contact network graph data (GET)
    //case graph
}


// MARK: Admin
extension ApiHandler {
    /// List all users (GET)
    //case users
    /// Get a user (GET/PATCH/DELETE)
    //case user(id: Int)
}


// MARK: Health
extension ApiHandler {
    /**
     Health check
     - Returns: Health status for the server
     */
    public func checkHealth() async throws -> HealthStatus {
        let data = try await self.sendRequest(to: .health)
        
        return try self.jsonDecoder.decode(HealthStatus.self, from: data)
    }
}
