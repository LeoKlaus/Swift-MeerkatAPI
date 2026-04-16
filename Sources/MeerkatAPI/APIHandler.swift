//
//  APIHandler.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 29.03.26.
//

import Foundation
import OSLog

public final class ApiHandler: Sendable {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ApiHandler.self)
    )
    
    public let serverURL: URL
    private let token: String
    
    let session: URLSession
    
    let jsonDecoder: JSONDecoder
    let jsonEncoder: JSONEncoder
    
    public init(serverURL: URL, token: String) {
        self.serverURL = serverURL
        self.token = token
        
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.httpShouldSetCookies = false
        
        self.session = URLSession(configuration: sessionConfiguration)
        
        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.dateDecodingStrategy = .iso8601
        
        self.jsonEncoder = JSONEncoder()
        self.jsonEncoder.dateEncodingStrategy = .iso8601
    }
    
    public func sendRequest(to endpoint: ApiEndpoint, method: HTTPMethod = .GET, body: Data? = nil, multipartBoundary: String? = nil, parameters: [URLQueryItem] = []) async throws -> Data {
        
        var request = URLRequest(url: self.serverURL.appendingApiPath(endpoint).appending(queryItems: parameters))
        
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
        
        if let multipartBoundary {
            request.addValue("multipart/form-data; boundary=\(multipartBoundary)", forHTTPHeaderField: "Content-Type")
        } else {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if parameters.isEmpty {
            Self.logger.debug("Sending \(method.rawValue, privacy: .public) request to \(endpoint.toPath(), privacy: .public)")
        } else {
            Self.logger.debug("Sending \(method.rawValue, privacy: .public) request to \(endpoint.toPath(), privacy: .public) with parameters:\n \(parameters.map{"\($0.name)=\($0.value ?? "")"}.joined(separator: ",\n"), privacy: .public)")
        }
        
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
    
    
    // MARK: - Convenience Methods
    
    // TODO: Currently the answer schemes for different endpoints vary (not all are paginated), but most of these could be handled with a couple of generics
    
    // MARK: Auth
    /**
     Create a new user account
     - Parameter username:      minimum 1 characters
     - Parameter mailAddress:   Email address of the user
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
        _ = try await self.sendRequest(to: .register, method: .POST, body: try JSONEncoder().encode(credentials))
    }
    
    /**
     Create a new user account
     - Parameter serverURL:     URL of the server
     - Parameter username:      minimum 1 characters
     - Parameter mailAddress:   Email address of the user
     - Parameter password:      minimum 8 characters, can be tested beforehand using `checkPasswordStrength(String)`
     - Parameter language:      InterfaceLanguage (currently either `en` or `de`)
     */
    public static func register(serverURL: URL, username: String, password: String, mailAddress: String, language: InterfaceLanguage) async throws {
        let credentials = [
            "Username": username,
            "Email": mailAddress,
            "Password": password,
            "Language": language.rawValue
        ]
        
        // Just returns a success message and a 201
        _ = try await Self.sendRequest(serverURL: serverURL, endpoint: .register, method: .POST, body: try JSONEncoder().encode(credentials))
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
     - Parameter serverURL: URL of the server
     */
    public static func logout(_ serverURL: URL) async throws {
        _ = try await Self.sendRequest(serverURL: serverURL, endpoint: .logout, method: .POST)
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
     Validate a password without registering
     - Parameter serverURL: URL of the server
     - Parameter password: Password to check
     
     - Returns: PasswordStrengthResponse for the given password
     */
    public static func checkPasswordStrength(serverURL: URL, password: String) async throws -> PasswordStrengthResponse {
        let passwordDict = [
            "Password": password
        ]
        
        let data = try await Self.sendRequest(serverURL: serverURL, endpoint: .checkPasswordStrength, method: .POST, body: JSONEncoder().encode(passwordDict))
        
        return try JSONDecoder().decode(PasswordStrengthResponse.self, from: data)
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
     Send a password reset email
     - Parameter serverURL:     URL of the server
     - Parameter mailAddress: Mail address of the user whos password should be reset
     */
    public static func requestPasswordReset(serverURL: URL, mailAddress: String) async throws {
        let mailDict = [
            "Email": mailAddress
        ]
        
        _ = try await Self.sendRequest(serverURL: serverURL, endpoint: .requestPasswordReset, method: .POST, body: JSONEncoder().encode(mailDict))
    }
    
    /**
     Apply a password reset token
     - Parameter serverURL: URL of the server
     - Parameter token: Token from the password reset mail
     - Parameter newPassword: New password for the user
     */
    public static func confirmPasswordReset(serverURL: URL, token: String, newPassword: String) async throws {
        let tokenPassDict = [
            "Token": token,
            "Password": newPassword
        ]
        
        _ = try await Self.sendRequest(serverURL: serverURL, endpoint: .confirmPasswordReset, method: .POST, body: JSONEncoder().encode(tokenPassDict))
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
    
    
    // MARK: User
    /** Get the current user
     - Returns: The current user
     */
    public func getMe() async throws -> User {
        let data = try await self.sendRequest(to: .me)
        return try self.jsonDecoder.decode(User.self, from: data)
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
        let data = try await self.sendRequest(to: .customFields)
        return try self.jsonDecoder.decode(CustomFields.self, from: data)
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
    
    
    // MARK: Contacts
    /**
     List contacts
     - Parameter fields: Fields to include with the response (defaults are sensible)
     - Parameter limit: Maximum number of contacts per page
     - Parameter page: Which page to load (starts at 1!)
     - Parameter sort: Which attribute to sort contacts by (defaults to `ID`)
     - Parameter order: Sort order, either `asc` or `desc`
     
     - Returns: List of contacts
     */
    public func getContacts(fields: Set<Contact.CodingKeys> = Contact.defaultFields, limit: Int = 50, page: Int = 1, search: String? = nil, sort: Contact.CodingKeys = .id, order: SortOrder = .reverse, includeArchived: Bool = false, circleFilter: String? = nil) async throws -> PaginatedResponse<Contact> {
        var parameters: [URLQueryItem] = [
            URLQueryItem(limit: limit),
            URLQueryItem(page: page)
        ]
        
        parameters.append(
            URLQueryItem(
                name: "fields",
                value: fields.map{ $0.rawValue
                }.joined(separator: ","))
        )
        
        if includeArchived {
            parameters.append(
                URLQueryItem(
                    name: "include_archived",
                    value: "true"
                )
            )
        }
        parameters.append(
            URLQueryItem(
                name: "sort",
                value: sort.rawValue
            )
        )
        
        parameters.append(
            URLQueryItem(
                name: "order",
                value: order == .forward ? "asc" : "desc"
            )
        )
        
        
        
        if let search {
            parameters.append(
                URLQueryItem(
                    name: "search",
                    value: search
                )
            )
        }
        
        if let circleFilter {
            parameters.append(
                URLQueryItem(
                    name: "circle",
                    value: circleFilter
                )
            )
        }
        
        let data = try await self.sendRequest(
            to: .contacts,
            parameters: parameters
        )
        return try self.jsonDecoder.decode(PaginatedResponse<Contact>.self, from: data)
    }
    
    /**
     Create new contact
     - Parameter newContact: Contact object for the new contact
     
     - Returns: The newly created contact
     */
    public func createContact(_ newContact: Contact) async throws -> Contact {
        let data = try await self.sendRequest(to: .contacts, method: .POST, body: self.jsonEncoder.encode(newContact))
        
        let response = try self.jsonDecoder.decode(WrappedObject<Contact>.self, from: data)
        return response.result
    }
    
    /**
     Get a contact
     - Returns: The contact with the given id
     */
    public func getContact(id: Int) async throws -> Contact {
        let data = try await self.sendRequest(to: .contact(id: id))
        return try self.jsonDecoder.decode(Contact.self, from: data)
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
        let data = try await self.sendRequest(to: .circles)
        
        return try self.jsonDecoder.decode([String]?.self, from: data) ?? []
    }
    
    /**
     Get five random contacts
     - Returns: Up to five random contacts
     */
    public func getRandomContacts() async throws -> [Contact] {
        // TODO: Check if this gets support for fields in the future
        let data = try await self.sendRequest(to: .randomContacts)
        
        return try self.jsonDecoder.decode(PaginatedResponse<Contact>.self, from: data).results
    }
    
    /**
     Get upcoming birthdays
     - Returns: List of upcoming birthdays
     */
    public func getUpcomingBirthdays() async throws -> [Birthday] {
        let data = try await self.sendRequest(to: .birthdays)
        
        return try self.jsonDecoder.decode(PaginatedResponse<Birthday>.self, from: data).results
    }
    
    /** Get a contact’s profile picture
     - Parameter contact: The contact whose profile should be loaded
     */
    public func getContactImage(_ contact: Contact) async throws -> Data {
        return try await self.sendRequest(to: .contactImage(id: contact.id))
    }
    
    /**
     Upload an image for a contact
     - Parameter contact: The contact this image sohuld be assigned to
     - Parameter imageURL: URL to the image file
     
     - Returns: The updated contact
     */
    public func uploadContactImage(contact: Contact, imageURL: URL) async throws -> Contact {
        let boundary = UUID().uuidString
        
        let body = try imageURL.toMultipartData(with: boundary)
        let data = try await self.sendRequest(to: .contactImage(id: contact.id), method: .POST, body: body, multipartBoundary: boundary)
        
        return try self.jsonDecoder.decode(Contact.self, from: data)
    }
    
    
    // MARK: Relationship Endpoints
    /**
     List outgoing relationships
     - Parameter contact: Contact whose relationships should be loaded
     
     - Returns: List of outgoing relationships for that contact
     */
    public func getOutgoingRelationships(_ contact: Contact) async throws -> [Relationship] {
        let data = try await self.sendRequest(to: .relationships(contactId: contact.id))
        
        return try self.jsonDecoder.decode(PaginatedResponse<Relationship>.self, from: data).results
    }
    
    /**
     Create outgoing relationships
     - Parameter contact: Contact to which the relationship should be added
     - Parameter relationship: The new relationship
     
     - Returns: The newly created relationship
     */
    public func createRelationship(contact: Contact, relationShip: Relationship) async throws -> Relationship {
        let data = try await self.sendRequest(to: .relationships(contactId: contact.id), method: .POST, body: self.jsonEncoder.encode(relationShip))
        
        return try self.jsonDecoder.decode(WrappedObject<Relationship>.self, from: data).result
    }
    
    /**
     List incoming relationships
     - Parameter contact: Contact whose relationships should be loaded
     
     - Returns: List of incoming relationships for that contact
     */
    public func getIncomingRelationships(_ contact: Contact) async throws -> [Relationship] {
        let data = try await self.sendRequest(to: .incomingRelationships(contactId: contact.id))
        
        return try self.jsonDecoder.decode(PaginatedResponse<Relationship>.self, from: data).results
    }
    
    /**
     Update a relationship
     - Parameter contact: Contact whose relationship should be updated
     - Parameter relationship: The relationship to be updated
     
     - Returns: The updated relationship
     */
    public func updateRelationship(contact: Contact, relationship: Relationship) async throws -> Relationship {
        let data = try await self.sendRequest(to: .updateRelationship(contactId: contact.id, relationshipId: relationship.id), method: .PUT, body: self.jsonEncoder.encode(relationship))
        
        return try self.jsonDecoder.decode(Relationship.self, from: data)
    }
    
    /**
     Delete a relationship
     - Parameter contact: Contact whose relationship should be deleted
     - Parameter relationship: The relationship to be deleted
     */
    public func deleteRelationship(contact: Contact, relationship: Relationship) async throws {
        _ = try await self.sendRequest(to: .updateRelationship(contactId: contact.id, relationshipId: relationship.id), method: .DELETE)
    }
    
    
    // MARK: Note Endpoints
    /**
     Get all notes for a contact
     - Parameter contact: Contact whose notes should be shown
     
     - Returns: List of notes for the given contact
     */
    public func getContactNotes(_ contact: Contact) async throws -> [Note] {
        let data = try await self.sendRequest(to: .contactNotes(contactId: contact.id))
        
        return try self.jsonDecoder.decode(PaginatedResponse<Note>.self, from: data).results
    }
    
    /**
     Create a note for a contact
     - Parameter contactId: ID of the contact to create a note for
     - Parameter note: Note to create
     
     - Returns: The newly created note
     */
    public func createContactNote(contactId: Int, note: Note) async throws -> Note {
        let data = try await self.sendRequest(to: .contactNotes(contactId: contactId), method: .POST, body: self.jsonEncoder.encode(note))
        
        let response = try self.jsonDecoder.decode(WrappedObject<Note>.self, from: data)
        return response.result
    }
    
    /**
     Get all unassigned notes
     - Parameter limit: Maximum number of contacts per page
     - Parameter page: Which page to load (starts at 1!)
     
     - Returns: List of unassigned notes
     */
    public func getUnassignedNotes(limit: Int = 50, page: Int = 1) async throws -> PaginatedResponse<Note> {
        let data = try await self.sendRequest(to: .unassignedNotes, parameters: [URLQueryItem(limit: limit), URLQueryItem(page: page)])
        
        return try self.jsonDecoder.decode(PaginatedResponse<Note>.self, from: data)
    }
    
    /**
     Create an unassigned note
     - Parameter note: The note to create
     
     - Returns: The newly created note
     */
    public func createUnassignedNote(_ note: Note) async throws -> Note {
        let data = try await self.sendRequest(to: .unassignedNotes, method: .POST, body: self.jsonEncoder.encode(note))
        
        return try self.jsonDecoder.decode(WrappedObject<Note>.self, from: data).result
    }
    
    
    /**
     Get a note
     - Returns: Note with the given id
     */
    public func getNote(_ id: Int) async throws -> Note {
        let data = try await self.sendRequest(to: .note(id: id))
        
        return try self.jsonDecoder.decode(Note.self, from: data)
    }
    
    /**
     Update a note
     - Parameter note: Note to update
     
     - Returns: The updated note
     */
    public func updateNote(_ note: Note) async throws -> Note {
        let data = try await self.sendRequest(to: .note(id: note.id), method: .PUT, body: self.jsonEncoder.encode(note))
        
        let response = try self.jsonDecoder.decode(WrappedObject<Note>.self, from: data)
        return response.result
    }
    
    /**
     Delete a note
     - Parameter note: Note to delete
     */
    public func deleteNote(_ note: Note) async throws {
        _ = try await self.sendRequest(to: .note(id: note.id), method: .DELETE)
    }
    
    
    // MARK: Activity Endpoints
    /**
     Get all activities
     - Parameter limit: Maximum number of contacts per page
     - Parameter page: Which page to load (starts at 1!)
     
     - Returns: List of activities
     */
    public func getActivities(limit: Int = 50, page: Int = 1) async throws -> PaginatedResponse<Activity> {
        let data = try await self.sendRequest(to: .activities, parameters: [URLQueryItem(limit: limit), URLQueryItem(page: page)])
        
        return try self.jsonDecoder.decode(PaginatedResponse<Activity>.self, from: data)
    }
    
    /**
     Create an activity
     - Parameter activity: The activity to create
     
     - Returns: The newly created note
     */
    public func createActivity(_ activity: Activity) async throws -> Activity {
        let data = try await self.sendRequest(to: .activities, method: .POST, body: self.jsonEncoder.encode(activity))
        
        let response = try self.jsonDecoder.decode(WrappedObject<Activity>.self, from: data)
        return response.result
    }
    
    /**
     Get an activity
     - Returns: Activity with the given id
     */
    public func getActivity(_ id: Int) async throws -> Activity {
        let data = try await self.sendRequest(to: .activity(id: id))
        
        return try self.jsonDecoder.decode(Activity.self, from: data)
    }
    
    /**
     Update an activity
     - Parameter activity: Activity to update
     
     - Returns: The updated activity
     */
    public func updateActivity(_ activity: Activity) async throws -> Activity {
        let data = try await self.sendRequest(to: .activity(id: activity.id), method: .PUT, body: self.jsonEncoder.encode(activity))
        
        let response = try self.jsonDecoder.decode(WrappedObject<Activity>.self, from: data)
        return response.result
    }
    
    /**
     Delete an activity
     - Parameter activity: Activity to delete
     */
    public func deleteActivity(_ activity: Activity) async throws {
        _ = try await self.sendRequest(to: .activity(id: activity.id), method: .DELETE)
    }
    
    /**
     Get activities for a contact
     - Parameter contact: Contact whose activities to load
     
     - Returns: All activities for that contact
     */
    public func getContactActivities(_ contact: Contact) async throws -> [Activity] {
        let data = try await self.sendRequest(to: .contactActivities(contactId: contact.id))
        
        return try self.jsonDecoder.decode(PaginatedResponse<Activity>.self, from: data).results
    }
    
    
    // MARK: Reminder Endpoints
    /**
     Get all reminders
     - Returns: List of reminders
     */
    public func getReminders() async throws -> [Reminder] {
        let data = try await self.sendRequest(to: .reminders)
        
        let response = try self.jsonDecoder.decode(PaginatedResponse<Reminder>.self, from: data)
        return response.results
    }
    
    /**
     Get all upcoming reminders
     - Returns: List of reminders
     */
    public func getUpcomingReminders() async throws -> [Reminder] {
        let data = try await self.sendRequest(to: .upcomingReminders)
        
        return try self.jsonDecoder.decode(PaginatedResponse<Reminder>.self, from: data).results
    }
    
    /**
     Get a reminder
     - Returns: Reminder with the given id
     */
    public func getReminder(_ id: Int) async throws -> Reminder {
        let data = try await self.sendRequest(to: .reminder(id: id))
        
        return try self.jsonDecoder.decode(Reminder.self, from: data)
    }
    
    /**
     Update a reminder
     - Parameter reminder: Reminder to update
     
     - Returns: The updated reminder
     */
    public func updateReminder(_ reminder: Reminder) async throws -> Reminder {
        let data = try await self.sendRequest(to: .reminder(id: reminder.id), method: .PUT, body: self.jsonEncoder.encode(reminder))
        
        let response = try self.jsonDecoder.decode(WrappedObject<Reminder>.self, from: data)
        return response.result
    }
    
    /**
     Delete a reminder
     - Parameter reminder: Reminder to delete
     */
    public func deleteReminder(_ reminder: Reminder) async throws {
        _ = try await self.sendRequest(to: .reminder(id: reminder.id), method: .DELETE)
    }
    
    /**
     Mark a reminder complete (creates timeline entry)
     - Parameter reminder: Reminder to mark completed
     - Parameter skip: Whether to skip the reminder
     */
    public func completeReminder(_ reminder: Reminder, skip: Bool = false) async throws {
        _ = try await self.sendRequest(to: .completeReminder(id: reminder.id), method: .POST, parameters: skip ? [URLQueryItem(name: "skip", value: "true")] : [])
    }
    
    /**
     Get reminders for a contact
     - Parameter contact: Contact to get reminders for
     
     - Returns: Reminders for that contact
     */
    public func getContactReminders(_ contact: Contact) async throws -> [Reminder] {
        let data = try await self.sendRequest(to: .contactReminders(contactId: contact.id))
        
        return try self.jsonDecoder.decode(PaginatedResponse<Reminder>.self, from: data).results
    }
    
    /**
     Create a reminder for a contact
     - Parameter contactId: ID of the contact to get create a reminder for
     - Parameter reminder: Reminder to create
     
     - Returns: Newly created reminder
     */
    public func createContactReminder(contactId: Int, reminder: Reminder) async throws -> Reminder {
        let data = try await self.sendRequest(to: .contactReminders(contactId: contactId), method: .POST, body: self.jsonEncoder.encode(reminder))
        
        return try self.jsonDecoder.decode(WrappedObject<Reminder>.self, from: data).result
    }
    
    /**
     List completion history for a contact (timeline entries)
     - Parameter contact: Contact whose timeline to get
     
     - Returns: List of completed reminders for that contact
     */
    public func getCompletedReminders(for contact: Contact) async throws -> [ReminderCompletion] {
        let data = try await self.sendRequest(to: .completedReminders(contactId: contact.id))
        
        return try self.jsonDecoder.decode(PaginatedResponse<ReminderCompletion>.self, from: data).results
    }
    
    /** Delete a completion entry
     - Parameter reminder: Reminder to delete
     */
    public func deleteCompletedReminder(_ reminder: Reminder) async throws {
        _ = try await self.sendRequest(to: .reminderCompletions(id: reminder.id))
    }
    
    
    // MARK: Import
    /**
     Upload a CSV file, returns parsed preview data
     - Parameter csvData: Data representation of the CSV file to upload
     
     - Returns: UploadPreviewResponse
     */
    public func uploadCsvImport(_ csvData: Data) async throws -> ImportUploadResponse {
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
    public func uploadCsvImport(_ csvURL: URL) async throws -> ImportUploadResponse {
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
    public func previewCsvUpload(_ request: ImportPreviewRequest) async throws -> ImportPreviewResponse {
        let data = try await self.sendRequest(to: .importPreviewCSV, method: .POST, body: self.jsonEncoder.encode(request))
        
        return try self.jsonDecoder.decode(ImportPreviewResponse.self, from: data)
    }
    
    /**
     Execute the import with per-row decisions (POST)
     - Parameter request: ImportConfirmRequest
     
     - Returns: ImportResult
     */
    public func confirmCsvUpload(_ request: ImportConfirmRequest) async throws -> ImportResult {
        let data = try await self.sendRequest(to: .importConfirmCSV, method: .POST, body: self.jsonEncoder.encode(request))
        
        return try self.jsonDecoder.decode(ImportResult.self, from: data)
    }
    
    /**
     Upload a VCF file, returns contacts with duplicate detection (POST/Multipart form)
     - Parameter vcfData: Data representation of the VCF file to upload
     
     - Returns: UploadPreviewResponse
     */
    public func uploadVcfImport(_ vcfData: Data) async throws -> ImportUploadResponse {
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
    public func uploadVcfImport(_ vcfURL: URL) async throws -> ImportUploadResponse {
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
    public func confirmVcfUpload(_ request: ImportConfirmRequest) async throws -> ImportResult {
        let data = try await self.sendRequest(to: .importConfirmVCF, method: .POST, body: self.jsonEncoder.encode(request))
        
        return try self.jsonDecoder.decode(ImportResult.self, from: data)
    }
    
    
    // MARK: Export
    /**
     Download all data as CSV
     - Returns: Data of the CSV file
     */
    public func exportCSV() async throws -> Data {
        let data = try await self.sendRequest(to: .exportCSV)
        return data
    }
    
    /**
     Download all contacts as VCF (includes photos)
     - Returns: Data of the VCF file
     */
    public func exportVCF() async throws -> Data {
        let data = try await self.sendRequest(to: .exportVCF)
        return data
    }
    
    
    // MARK: Graph
    
    /** Get contact network graph data
     - Returns: Graph object containing all nodes and edges of the graph
     */
    public func getNetworkGraph() async throws -> Graph {
        let data = try await self.sendRequest(to: .graph)
        
        return try self.jsonDecoder.decode(Graph.self, from: data)
    }
    
    
    // MARK: Tokens (Static)
    private static func sendRequest(serverURL: URL, endpoint: ApiEndpoint, method: HTTPMethod = .GET, body: Data? = nil) async throws -> Data {
        
        var request = URLRequest(url: serverURL.appendingApiPath(endpoint))
        
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Self.logger.debug("Sending \(method.rawValue, privacy: .public) request to \(endpoint.toPath(), privacy: .public)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
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
    
    /**
     Login and store auth cookie for this session of the app.
     Some operations, like managing tokens require a session cookie.
     - Parameter serverURL: URL of the server
     - Parameter username: Username or email of the user
     - Parameter password: Password
     
     - Returns: LoginResponse, if login was successful
     */
    public static func login(serverURL: URL, username: String, password: String) async throws -> LoginResponse {
        let credentials = [
            "identifier": username,
            "password": password
        ]
        
        let data = try await Self.sendRequest(serverURL: serverURL, endpoint: .login, method: .POST, body: JSONEncoder().encode(credentials))
        return try JSONDecoder().decode(LoginResponse.self, from: data)
    }
    
    /**
     List all API tokens for the current user.
     Requires session cookie, call `.login()` first!
     - Returns: All API tokens for the current user
     */
    public static func getApiTokens(_ serverURL: URL) async throws -> PaginatedResponse<TokenResponse> {
        let data = try await Self.sendRequest(serverURL: serverURL, endpoint: .apiTokens)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(PaginatedResponse<TokenResponse>.self, from: data)
    }
    
    /**
     Create an API token — returns the plaintext token once
     Requires session cookie, call `.login()` first!
     - Parameter serverURL: URL of the server
     - Parameter name: Name for the API token
     
     - Returns: TokenResponse containing the token
     */
    public static func createApiToken(serverURL: URL, name: String) async throws -> TokenResponse {
        let bodyDict = [
            "Name": name
        ]
        
        let data = try await Self.sendRequest(serverURL: serverURL, endpoint: .apiTokens, method: .POST, body: JSONEncoder().encode(bodyDict))
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(TokenResponse.self, from: data)
    }
    
    /**
     Revoke an API token
     Requires session cookie, call `.login()` first!
     - Parameter serverURL: URL of the server
     - Parameter id: ID of the API token to revoke
     */
    public static func revokeApiToken(serverURL: URL, id: Int) async throws {
        _ = try await Self.sendRequest(serverURL: serverURL, endpoint: .apiToken(id: id), method: .DELETE)
    }
    
    
    // MARK: Admin
    /**
     Get all users
     - Parameter limit: Maximum number of users per page
     - Parameter page: Which page to load (starts at 1!)
     
     - Returns: List of users
     */
    public func getUsers(limit: Int = 50, page: Int = 1) async throws -> [User] {
        let data = try await self.sendRequest(to: .users, parameters: [URLQueryItem(limit: limit), URLQueryItem(page: page)])
        
        let response = try self.jsonDecoder.decode(PaginatedResponse<User>.self, from: data)
        return response.results
    }
    
    /**
     Get a user
     - Returns: User with the given id
     */
    public func getUser(_ id: Int) async throws -> User {
        let data = try await self.sendRequest(to: .user(id: id))
        
        return try self.jsonDecoder.decode(User.self, from: data)
    }
    
    /**
     Update a user
     - Parameter user: User to update
     
     - Returns: The updated user
     */
    public func updateUser(_ user: User) async throws -> User {
        let data = try await self.sendRequest(to: .user(id: user.id), method: .PATCH, body: self.jsonEncoder.encode(user))
        
        return try self.jsonDecoder.decode(User.self, from: data)
    }
    
    /**
     Delete a user
     - Parameter user: User to delete
     */
    public func deleteUser(_ user: User) async throws {
        _ = try await self.sendRequest(to: .user(id: user.id), method: .DELETE)
    }
    
    
    // MARK: Health
    /**
     Health check
     - Returns: Health status for the server
     */
    public func checkHealth() async throws -> HealthStatus {
        let data = try await self.sendRequest(to: .health)
        
        return try self.jsonDecoder.decode(HealthStatus.self, from: data)
    }
    
    /**
     Health check
     - Parameter serverURL: URL of the server
     - Returns: Health status for the server
     */
    public static func checkHealth(_ serverURL: URL) async throws -> HealthStatus {
        let data = try await self.sendRequest(serverURL: serverURL, endpoint: .health)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(HealthStatus.self, from: data)
    }
}
