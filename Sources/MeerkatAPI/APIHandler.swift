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
            switch httpResponse.statusCode {
            case 200...299:
                return data
            case 401:
                Self.logger.error("Server returned 401:\n\(String(data: data, encoding: .utf8) ?? "", privacy: .public)")
                throw ApiError.unauthorized
            case 403:
                Self.logger.error("Server returned 403:\n\(String(data: data, encoding: .utf8) ?? "", privacy: .public)")
                throw ApiError.forbidden
            case 404:
                Self.logger.error("Server returned 404:\n\(String(data: data, encoding: .utf8) ?? "", privacy: .public)")
                throw ApiError.notFound
            default:
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

// TODO: Currently the answer schemes for different endpoints vary, but most of these could be handled with a couple of generics

// MARK: Auth
public extension ApiHandler {
    
    /**
     Create a new user account
     - Parameter username:      minimum 3 characters
     - Parameter mailAddress:
     - Parameter password:      minimum 8 characters, can be tested beforehand using `checkPasswordStrength(String)`
     - Parameter language:      InterfaceLanguage (currently either `en` or `de`)
     */
    func register(username: String, password: String, mailAddress: String, language: InterfaceLanguage) async throws {
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
    func login(username: String, password: String) async throws -> LoginResponse {
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
    func logout() async throws {
        _ = try await self.sendRequest(to: .logout, method: .POST)
    }
    
    /**
     Validate a password without registering
     - Parameter password: Password to check
     
     - Returns: PasswordStrengthResponse for the given password
     */
    func checkPasswordStrength(_ password: String) async throws -> PasswordStrengthResponse {
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
    func requestPasswordReset(mailAddress: String) async throws {
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
    func confirmPasswordReset(token: String, newPassword: String) async throws {
        let tokenPassDict = [
            "Token": token,
            "Password": newPassword
        ]
        
        _ = try await self.sendRequest(to: .confirmPasswordReset, method: .POST, body: self.jsonEncoder.encode(tokenPassDict))
    }
}


// MARK: User
public extension ApiHandler {
    
    /** Get the current user
     - Returns: The current user
     */
    func getMe() async throws -> User {
        return try await self.get(from: .me)
    }
    /**
     Change password
     - Parameter currentPassword: Current password of the user
     - Parameter newPassword: New password for the user
     */
    func changePassword(currentPassword: String, newPassword: String) async throws {
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
    func changeLanguage(_ newLanguage: InterfaceLanguage) async throws {
        let bodyDict = [
            "language": newLanguage.rawValue
        ]
        
        _ = try await self.sendRequest(to: .language, method: .PATCH, body: self.jsonEncoder.encode(bodyDict))
    }
    
    /**
     Update date format preference (WebUI only!)
     - Parameter newFormat: New date format to use
     */
    func changeDateFormat(_ newFormat: DateFormat) async throws {
        let bodyDict = [
            "date_format": newFormat.rawValue
        ]
        
        _ = try await self.sendRequest(to: .dateFormat, method: .PATCH, body: self.jsonEncoder.encode(bodyDict))
    }
    
    /**
     Get custom field names
     - Returns: CustomFields object containing all custom field names
     */
    func getCustomFields() async throws -> CustomFields {
        return try await self.get(from: .customFields)
    }
    
    /**
     Update custom field names
     - Parameter newFields: CustomFields object with the names of **all custom fields**, including those to be created
     
     - Returns: CustomFields object containing all custom field names
     */
    func updateCustomFields(_ newFields: CustomFields) async throws -> CustomFields {
        let data = try await self.sendRequest(to: .customFields, method: .PATCH, body: self.jsonEncoder.encode(newFields))
        
        return try self.jsonDecoder.decode(CustomFields.self, from: data)
    }
}


// MARK: Contacts
public extension ApiHandler {
    
    /**
     List contacts
     - Parameter fields: Fields to include with the response (defaults are sensible)
     - Parameter limit: Maximum number of contacts per page
     - Parameter page: Which page to load (starts at 1!)
     - Parameter sort: Which attribute to sort contacts by (defaults to `ID`)
     - Parameter order: Sort order, either `asc` or `desc`
     
     - Returns: List of contacts
     */
     func getContacts(fields: [Contact.CodingKeys] = Contact.defaultFields, limit: Int = 50, page: Int = 1, sort: Contact.CodingKeys = .id, order: String = "desc") async throws -> PaginatedResponse<Contact> {
        let fieldsQueryItem = URLQueryItem(name: "fields", value: fields.map{ $0.rawValue }.joined(separator: ","))
        return try await self.get(from: .contacts, parameters: [fieldsQueryItem, URLQueryItem(limit: limit), URLQueryItem(page: page)])
    }
    
    /**
     Create new contact
     - Parameter newContact: Contact object for the new contact
     
     - Returns: The newly created contact
     */
    func createContact(_ newContact: Contact) async throws -> Contact {
        let data = try await self.sendRequest(to: .contacts, method: .POST, body: self.jsonEncoder.encode(newContact))
        
        let response = try self.jsonDecoder.decode(WrappedObject<Contact>.self, from: data)
        return response.result
    }
    
    /**
     Get a contact
     - Returns: The contact with the given id
     */
    func getContact(id: Int) async throws -> Contact {
        return try await self.get(from: .contact(id: id))
    }
    
    /**
     Update an existing contact
     - Parameter contact: Contact object for the contact
     
     - Returns: The updated contact
     */
    func updateContact(_ contact: Contact) async throws -> Contact {
        let data = try await self.sendRequest(to: .contact(id: contact.id), method: .PUT, body: self.jsonEncoder.encode(contact))
        
        return try self.jsonDecoder.decode(Contact.self, from: data)
    }
    
    /**
     Delete an existing contact
     - Parameter contact: Contact to delete
     */
    func deleteContact(_ contact: Contact) async throws {
        _ = try await self.sendRequest(to: .contact(id: contact.id), method: .DELETE)
    }
    
    /**
     Archive a contact
     - Parameter contact: Contact to archive
     
     - Returns: The archived contact
     */
    func archiveContact(_ contact: Contact) async throws -> Contact {
        let data = try await self.sendRequest(to: .archiveContact(id: contact.id), method: .POST)
        
        return try self.jsonDecoder.decode(Contact.self, from: data)
    }
    /**
     Unarchive a contact
     - Parameter contact: Contact to unarchive
     
     - Returns: The unarchived contact
     */
    func unarchiveContact(_ contact: Contact) async throws -> Contact {
        let data = try await self.sendRequest(to: .unarchiveContact(id: contact.id), method: .POST)
        
        return try self.jsonDecoder.decode(Contact.self, from: data)
    }
    
    /**
     List all circles in use
     - Returns: A list of all currently used circles
     */
    func getCircles() async throws -> [String] {
        return try await self.get(from: .circles)
    }
    
    /**
     Get five random contacts
     - Returns: Up to five random contacts
     */
    func getRandomContacts() async throws -> [Contact] {
        // TODO: Check if this gets support for fields in the future
        let response: PaginatedResponse<Contact> = try await self.get(from: .contacts)
        return response.results
    }
    
    /**
     Get upcoming birthdays
     - Returns: List of upcoming birthdays
     */
    func getUpcomingBirthdays() async throws -> [Birthday] {
        let response: PaginatedResponse<Birthday> = try await self.get(from: .birthdays)
        return response.results
    }
    
    /** Get a contact’s profile picture
     - Parameter contact: The contact whose profile should be loaded
     */
    func getContactImage(_ contact: Contact) async throws -> Data {
        return try await self.getData(from: .contactImage(id: contact.id))
    }
    
    /**
     Upload an image for a contact
     - Parameter contact: The contact this image sohuld be assigned to
     - Parameter imageURL: URL to the image file
     
     - Returns: The updated contact
     */
    func uploadContactImage(contact: Contact, imageURL: URL) async throws -> Contact {
        let boundary = UUID().uuidString
        
        let body = try imageURL.toMultipartData(with: boundary)
        let data = try await self.sendRequest(to: .contactImage(id: contact.id), method: .POST, body: body, multipartBoundary: boundary)
        
        return try self.jsonDecoder.decode(Contact.self, from: data)
    }
}


// MARK: Relationship Endpoints
public extension ApiHandler {
    
    /**
     List outgoing relationships
     - Parameter contact: Contact whose relationships should be loaded
     
     - Returns: List of outgoing relationships for that contact
     */
    func getOutgoingRelationships(_ contact: Contact) async throws -> [Relationship] {
        let response: PaginatedResponse<Relationship> = try await self.get(from: .relationships(contactId: contact.id))
        return response.results
    }
    
    /**
     Create outgoing relationships
     - Parameter contact: Contact to which the relationship should be added
     - Parameter relationship: The new relationship
     
     - Returns: The newly created relationship
     */
    func createRelationship(contact: Contact, relationShip: Relationship) async throws -> Relationship {
        let data = try await self.sendRequest(to: .relationships(contactId: contact.id), method: .POST, body: self.jsonEncoder.encode(relationShip))
        
        let response = try self.jsonDecoder.decode(WrappedObject<Relationship>.self, from: data)
        return response.result
    }
    
    /**
     List incoming relationships
     - Parameter contact: Contact whose relationships should be loaded
     
     - Returns: List of incoming relationships for that contact
     */
    func getIncomingRelationships(_ contact: Contact) async throws -> [Relationship] {
        let response: PaginatedResponse<Relationship> = try await self.get(from: .incomingRelationships(contactId: contact.id))
        return response.results
    }
    
    /**
     Update a relationship
     - Parameter contact: Contact whose relationship should be updated
     - Parameter relationship: The relationship to be updated

     - Returns: The updated relationship
     */
    func updateRelationship(contact: Contact, relationship: Relationship) async throws -> Relationship {
        let data = try await self.sendRequest(to: .updateRelationship(contactId: contact.id, relationshipId: relationship.id), method: .PUT, body: self.jsonEncoder.encode(relationship))
        
        return try self.jsonDecoder.decode(Relationship.self, from: data)
    }
    
    /**
     Delete a relationship
     - Parameter contact: Contact whose relationship should be deleted
     - Parameter relationship: The relationship to be deleted
     */
    func deleteRelationship(contact: Contact, relationship: Relationship) async throws {
        _ = try await self.sendRequest(to: .updateRelationship(contactId: contact.id, relationshipId: relationship.id), method: .DELETE)
    }
}


// MARK: Note Endpoints
public extension ApiHandler {
    
    /**
     Get all notes for a contact
     - Parameter contact: Contact whose notes should be shown
     
     - Returns: List of notes for the given contact
     */
    func getContactNotes(_ contact: Contact) async throws -> [Note] {
        let data = try await self.sendRequest(to: .contactNotes(contactId: contact.id))
        
        let response = try self.jsonDecoder.decode(PaginatedResponse<Note>.self, from: data)
        return response.results
    }
    
    /**
     Create a note for a contact
     - Parameter contact: Contact to create a note for
     - Parameter note: Note to create
     
     - Returns: The newly created note
     */
    func createContactNote(contact: Contact, note: Note) async throws -> Note {
        let data = try await self.sendRequest(to: .contactNotes(contactId: contact.id), method: .POST, body: self.jsonEncoder.encode(note))
        
        let response = try self.jsonDecoder.decode(WrappedObject<Note>.self, from: data)
        return response.result
    }
    
    /**
     Get all unassigned notes
     - Parameter limit: Maximum number of contacts per page
     - Parameter page: Which page to load (starts at 1!)
     
     - Returns: List of unassigned notes
     */
    func getUnassignedNotes(limit: Int = 50, page: Int = 1) async throws -> PaginatedResponse<Note> {
        return try await self.get(from: .unassignedNotes, parameters: [URLQueryItem(limit: limit), URLQueryItem(page: page)])
    }
    
    /**
     Create an unassigned note
     - Parameter note: The note to create
     
     - Returns: The newly created note
     */
    func createUnassignedNote(_ note: Note) async throws -> Note {
        let data = try await self.sendRequest(to: .unassignedNotes, method: .POST, body: self.jsonEncoder.encode(note))
        
        let response = try self.jsonDecoder.decode(WrappedObject<Note>.self, from: data)
        return response.result
    }
    
    
    /**
     Get a note
     - Returns: Note with the given id
     */
    func getNote(_ id: Int) async throws -> Note {
        return try await self.get(from: .note(id: id))
    }
    
    /**
     Update a note
     - Parameter note: Note to update
     
     - Returns: The updated note
     */
    func updateNote(_ note: Note) async throws -> Note {
        let data = try await self.sendRequest(to: .note(id: note.id), method: .PUT, body: self.jsonEncoder.encode(note))
        
        let response = try self.jsonDecoder.decode(WrappedObject<Note>.self, from: data)
        return response.result
    }
    
    /**
     Delete a note
     - Parameter note: Note to delete
     */
    func deleteNote(_ note: Note) async throws {
        _ = try await self.sendRequest(to: .note(id: note.id), method: .DELETE)
    }
}


// MARK: Activity Endpoints
public extension ApiHandler {
    
    /**
     Get all activities
     - Parameter limit: Maximum number of contacts per page
     - Parameter page: Which page to load (starts at 1!)
     
     - Returns: List of activities
     */
    func getActivities(limit: Int = 50, page: Int = 1) async throws -> PaginatedResponse<Activity> {
        return try await self.get(from: .activities, parameters: [URLQueryItem(limit: limit), URLQueryItem(page: page)])
    }
    
    /**
     Create an activity
     - Parameter activity: The activity to create
     
     - Returns: The newly created note
     */
    func createActivity(_ note: Activity) async throws -> Activity {
        let data = try await self.sendRequest(to: .activities, method: .POST, body: self.jsonEncoder.encode(note))
        
        let response = try self.jsonDecoder.decode(WrappedObject<Activity>.self, from: data)
        return response.result
    }
    
    /**
     Get an activity
     - Returns: Activity with the given id
     */
    func getActivity(_ id: Int) async throws -> Activity {
        return try await self.get(from: .activity(id: id))
    }
    
    /**
     Update an activity
     - Parameter activity: Activity to update
     
     - Returns: The updated activity
     */
    func updateActivity(_ activity: Activity) async throws -> Activity {
        let data = try await self.sendRequest(to: .activity(id: activity.id), method: .PUT, body: self.jsonEncoder.encode(activity))
        
        let response = try self.jsonDecoder.decode(WrappedObject<Activity>.self, from: data)
        return response.result
    }
    
    /**
     Delete an activity
     - Parameter activity: Activity to delete
     */
    func deleteActivity(_ activity: Activity) async throws {
        _ = try await self.sendRequest(to: .activity(id: activity.id), method: .DELETE)
    }
    
    /**
     Get activities for a contact
     - Parameter contact: Contact whose activities to load
     
     - Returns: All activities for that contact
     */
    func getContactActivities(_ contact: Contact) async throws -> [Activity] {
        let data = try await self.sendRequest(to: .contactActivities(contactId: contact.id))
        
        let response = try self.jsonDecoder.decode(PaginatedResponse<Activity>.self, from: data)
        return response.results
    }
}


// MARK: Reminder Endpoints
public extension ApiHandler {
    
    /**
     Get all reminders
     - Returns: List of reminders
     */
    func getReminders() async throws -> [Reminder] {
        let data = try await self.sendRequest(to: .reminders)
        
        let response = try self.jsonDecoder.decode(PaginatedResponse<Reminder>.self, from: data)
        return response.results
    }
    
    /**
     Get all upcoming reminders
     - Returns: List of reminders
     */
    func getUpcomingReminders() async throws -> [Reminder] {
        let response: PaginatedResponse<Reminder> = try await self.get(from: .upcomingReminders)
        
        return response.results
    }
    
    /**
     Get a reminder
     - Returns: Reminder with the given id
     */
    func getReminder(_ id: Int) async throws -> Reminder {
        return try await self.get(from: .reminder(id: id))
    }
    
    /**
     Update a reminder
     - Parameter reminder: Reminder to update
     
     - Returns: The updated reminder
     */
    func updateReminder(_ reminder: Reminder) async throws -> Reminder {
        let data = try await self.sendRequest(to: .reminder(id: reminder.id), method: .PUT, body: self.jsonEncoder.encode(reminder))
        
        let response = try self.jsonDecoder.decode(WrappedObject<Reminder>.self, from: data)
        return response.result
    }
    
    /**
     Delete a reminder
     - Parameter reminder: Reminder to delete
     */
    func deleteReminder(_ reminder: Reminder) async throws {
        _ = try await self.sendRequest(to: .reminder(id: reminder.id), method: .DELETE)
    }
    
    /**
     Mark a reminder complete (creates timeline entry)
     - Parameter reminder: Reminder to mark completed
     */
    func completeReminder(_ reminder: Reminder) async throws {
        _ = try await self.sendRequest(to: .completeReminder(id: reminder.id), method: .POST)
    }
    
    /**
     Get reminders for a contact
     - Parameter contact: Contact to get reminders for
     
     - Returns: Reminders for that contact
     */
    func getContactReminders(_ contact: Contact) async throws -> [Reminder] {
        let data = try await self.sendRequest(to: .contactReminders(contactId: contact.id))
        
        let response = try self.jsonDecoder.decode(PaginatedResponse<Reminder>.self, from: data)
        return response.results
    }
    
    /**
     Create a reminder for a contact
     - Parameter contact: Contact to get create a reminder for
     - Parameter reminder: Reminder to create
     
     - Returns: Newly created reminder
     */
    func createContactReminder(contact: Contact, reminder: Reminder) async throws -> Reminder {
        let data = try await self.sendRequest(to: .contactReminders(contactId: contact.id), method: .POST, body: self.jsonEncoder.encode(reminder))
        
        return try self.jsonDecoder.decode(Reminder.self, from: data)
    }
    
    /**
     List completion history for a contact (timeline entries)
     - Parameter contact: Contact whose timeline to get
     
     - Returns: List of completed reminders for that contact
     */
    func getCompletedReminders(for contact: Contact) async throws -> [Reminder] {
        let data = try await self.sendRequest(to: .completedReminders(contactId: contact.id))
        
        let response = try self.jsonDecoder.decode(PaginatedResponse<Reminder>.self, from: data)
        return response.results
    }
    
    /** Delete a completion entry
     - Parameter reminder: Reminder to delete
     */
    func deleteCompletedReminder(_ reminder: Reminder) async throws {
        _ = try await self.sendRequest(to: .reminderCompletions(id: reminder.id))
    }
}

// MARK: Import
public extension ApiHandler {
    
    /**
    Upload a CSV file, returns parsed preview data
     - Parameter csvData: Data representation of the CSV file to upload
     
     - Returns: UploadPreviewResponse
     */
    func uploadCsvImport(_ csvData: Data) async throws -> ImportUploadResponse {
        let boundary = UUID().uuidString
        let body = try csvData.toMultipartData(boundary: boundary, fileName: "import.csv", mimeType: .delimitedText)
        
        let data = try await self.sendRequest(to: .importUploadCSV, method: .POST, body: body, multipartBoundary: boundary)
        
        return try self.jsonDecoder.decode(ImportUploadResponse.self, from: data)
    }
    
    /**
     Upload a CSV file, returns parsed preview data
     - Parameter csvURL: URL of the CSV file to upload
     
     - Returns: UploadPreviewResponse
     */
    func uploadCsvImport(_ csvURL: URL) async throws -> ImportUploadResponse {
        let boundary = UUID().uuidString
        let body = try csvURL.toMultipartData(with: boundary)
        
        let data = try await self.sendRequest(to: .importUploadCSV, method: .POST, body: body, multipartBoundary: boundary)
        
        return try self.jsonDecoder.decode(ImportUploadResponse.self, from: data)
    }
    
    /**
     Apply column mapping, returns contacts with duplicate detection (POST)
     - Parameter request: ImportPreviewRequest for the import
     
     - Returns: ImportPreviewResponse
     */
    func previewCsvUpload(_ request: ImportPreviewRequest) async throws -> ImportPreviewResponse {
        let data = try await self.sendRequest(to: .importPreviewCSV, method: .POST, body: self.jsonEncoder.encode(request))
        
        return try self.jsonDecoder.decode(ImportPreviewResponse.self, from: data)
    }
    
    /**
     Execute the import with per-row decisions (POST)
     - Parameter request: ImportConfirmRequest
     
     - Returns: ImportResult
     */
    func confirmCsvUpload(_ request: ImportConfirmRequest) async throws -> ImportResult {
        let data = try await self.sendRequest(to: .importConfirmCSV, method: .POST, body: self.jsonEncoder.encode(request))
        
        return try self.jsonDecoder.decode(ImportResult.self, from: data)
    }
    
    /**
     Upload a VCF file, returns contacts with duplicate detection (POST/Multipart form)
     - Parameter vcfData: Data representation of the VCF file to upload
     
     - Returns: UploadPreviewResponse
     */
    func uploadVcfImport(_ vcfData: Data) async throws -> ImportUploadResponse {
        let boundary = UUID().uuidString
        let body = try vcfData.toMultipartData(boundary: boundary, fileName: "import.vcf", mimeType: .delimitedText)
        
        let data = try await self.sendRequest(to: .importUploadVCF, method: .POST, body: body, multipartBoundary: boundary)
        
        return try self.jsonDecoder.decode(ImportUploadResponse.self, from: data)
    }
    
    /**
     Upload a VCF file, returns contacts with duplicate detection (POST/Multipart form)
     - Parameter vcfURL: Data representation of the VCF file to upload
     
     - Returns: UploadPreviewResponse
     */
    func uploadVcfImport(_ vcfURL: URL) async throws -> ImportUploadResponse {
        let boundary = UUID().uuidString
        let body = try vcfURL.toMultipartData(with: boundary)
        
        let data = try await self.sendRequest(to: .importUploadVCF, method: .POST, body: body, multipartBoundary: boundary)
        
        return try self.jsonDecoder.decode(ImportUploadResponse.self, from: data)
    }
    
    /**
     Execute the VCF import (POST)
     - Parameter request: ImportConfirmRequest
     
     - Returns: ImportResult
     */
    func confirmVcfUpload(_ request: ImportConfirmRequest) async throws -> ImportResult {
        let data = try await self.sendRequest(to: .importConfirmVCF, method: .POST, body: self.jsonEncoder.encode(request))
        
        return try self.jsonDecoder.decode(ImportResult.self, from: data)
    }
}

// MARK: Export
public extension ApiHandler {
    
    /**
     Download all data as CSV
     - Returns: Data of the CSV file
     */
    func exportCSV() async throws -> Data {
        let data = try await self.sendRequest(to: .exportCSV)
        return data
    }
    
    /**
     Download all contacts as VCF (includes photos)
     - Returns: Data of the VCF file
     */
    func exportVCF() async throws -> Data {
        let data = try await self.sendRequest(to: .exportVCF)
        return data
    }
}


// MARK: Graph
public extension ApiHandler {
    
    /** Get contact network graph data
     - Returns: Graph object containing all nodes and edges of the graph
     */
    func getNetworkGraph() async throws -> Graph {
        return try await self.get(from: .graph)
    }
}

// MARK: Tokens
public extension ApiHandler {
    /**
     List all API tokens for the current user (requires cookie auth!)
     - Returns: All API tokens for the current user
     */
    func getApiTokens() async throws -> PaginatedResponse<TokenResponse> {
        return try await self.get(from: .apiTokens)
    }
    
    /**
     Create an API token — returns the plaintext token once
     - Parameter name: Name for the API token
     
     - Returns: TokenResponse containing the token
     */
    func createApiToken(_ name: String) async throws -> TokenResponse {
        let bodyDict = [
            "Name": name
        ]
        
        let data = try await self.sendRequest(to: .apiTokens, method: .POST, body: self.jsonEncoder.encode(bodyDict))
        
        return try self.jsonDecoder.decode(TokenResponse.self, from: data)
    }
    
    /**
     Revoke an API token
     - Parameter id: ID of the API token to revoke
     */
    func revokeApiToken(_ id: Int) async throws {
        _ = try await self.sendRequest(to: .apiToken(id: id), method: .DELETE)
    }
}

// MARK: Admin
public extension ApiHandler {
    
    /**
     Get all users
     - Parameter limit: Maximum number of users per page
     - Parameter page: Which page to load (starts at 1!)
     
     - Returns: List of users
     */
    func getUsers(limit: Int = 50, page: Int = 1) async throws -> [User] {
        let data = try await self.sendRequest(to: .users, parameters: [URLQueryItem(limit: limit), URLQueryItem(page: page)])
        
        let response = try self.jsonDecoder.decode(PaginatedResponse<User>.self, from: data)
        return response.results
    }
    
    /**
     Get a user
     - Returns: User with the given id
     */
    func getUser(_ id: Int) async throws -> User {
        return try await self.get(from: .user(id: id))
    }
    
    /**
     Update a user
     - Parameter user: User to update
     
     - Returns: The updated user
     */
    func updateUser(_ user: User) async throws -> User {
        let data = try await self.sendRequest(to: .user(id: user.id), method: .PATCH, body: self.jsonEncoder.encode(user))
        
        return try self.jsonDecoder.decode(User.self, from: data)
    }
    
    /**
     Delete a user
     - Parameter user: User to delete
     */
    func deleteUser(_ user: User) async throws {
        _ = try await self.sendRequest(to: .user(id: user.id), method: .DELETE)
    }
}


// MARK: Health
public extension ApiHandler {
    /**
     Health check
     - Returns: Health status for the server
     */
    func checkHealth() async throws -> HealthStatus {
        let data = try await self.sendRequest(to: .health)
        
        return try self.jsonDecoder.decode(HealthStatus.self, from: data)
    }
}
