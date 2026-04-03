//
//  APIEndpoint.swift
//  MeerkatAPI
//
//  Created by Leo Wehrfritz on 29.03.26.
//

import Foundation

extension URL {
    func appendingApiPath(_ endpoint: ApiEndpoint) -> URL {
        return self.appending(path: endpoint.toPath())
    }
}

public enum ApiEndpoint {
    
    // MARK: Auth Endpoints
    /// Create a new user account (POST)
    case register
    /// Authenticate and set session cookie (POST)
    case login
    /// Clear session cookie (POST)
    case logout
    /// Validate a password without registering (POST)
    case checkPasswordStrength
    /// Send a password reset email (POST)
    case requestPasswordReset
    /// Apply a password reset token (POST)
    case confirmPasswordReset
    
    // MARK: User Endpoints
    /// Get the current user (GET)
    case me
    /// Change password (POST)
    case changePassword
    /// Update UI language preference (PATCH)
    case language
    /// Update date format preference (PATCH)
    case dateFormat
    /// Get custom field names (GET/PATCH)
    case customFields
    
    // MARK: Contact Endpoints
    /// List contacts (GET/POST)
    case contacts
    /// Get a contact (GET/PUT/DELETE)
    case contact(id: Int)
    /// Archive a contact (POST)
    case archiveContact(id: Int)
    /// Unarchive a contact (POST)
    case unarchiveContact(id: Int)
    /// List all circles in use (GET)
    case circles
    /// Get five random contacts (GET)
    case random
    /// Get upcoming birthdays (GET)
    case birthdays
    /// Get a contact’s profile picture (GET/POST)
    case contactImage(id: Int)
    /// Proxy an external image URL for upload preview (GET)
    case proxyImage
    
    // MARK: Relationship Endpoints
    /// List outgoing relationships (GET/POST)
    case relationships(contactId: Int)
    /// List incoming relationships (GET)
    case incomingRelationships(contactId: Int)
    /// Update a relationship (PUT/DELETE)
    case updateRelationship(contactId: Int, relationshipId: Int)
    
    // MARK: Note Endpoints
    /// List notes for a contact (GET/POST)
    case contactNotes(contactId: Int)
    /// List unassigned notes (GET/POST)
    case unassignedNotes
    /// Get a note (GET/PUT/DELETE)
    case note(id: Int)
    
    // MARK: Activity Endpoints
    /// List all activities (GET/POST)
    case activities
    /// Get an activity (GET/PUT/DELETE)
    case activity(id: Int)
    /// List activities for a contact (GET)
    case contactActivities(contactId: Int)
    
    // MARK: Reminder Endpoints
    /// List all reminders (GET)
    case reminders
    /// List upcoming reminders (used by dashboard) (GET)
    case upcomingReminders
    /// Get a reminder (GET/PUT/DELETE)
    case reminder(id: Int)
    /// Mark a reminder complete (creates timeline entry) (POST)
    case completeReminder(id: Int)
    /// List reminders for a contact (POST/GET)
    case contactReminders(contactId: Int)
    /// List completion history for a contact (timeline entries) (GET)
    case completedReminders(contactId: Int)
    /// Delete a completion entry (DELETE)
    case reminderCompletions(id: Int)
    
    // MARK: Import Endpoints
    /// Upload a CSV file, returns parsed preview data
    case importUploadCSV
    /// Apply column mapping, returns contacts with duplicate detection
    case importPreviewCSV
    /// Execute the import with per-row decisions
    case importConfirmCSV
    /// Upload a VCF file, returns contacts with duplicate detection
    case importUploadVCF
    /// Execute the VCF import
    case importConfirmVCF
    
    // MARK: Export Endpoints
    /// Download all data as CSV
    case exportCSV
    /// Download all contacts as VCF (includes photos)
    case exportVCF
    
    // MARK: Graph Endpoints
    /// Get contact network graph data (GET)
    case graph
    
    // MARK: Token Endpoints
    /// List all API tokens for the current user (GET/POST)
    case apiTokens
    /// Revoke an API token (DELETE)
    case apiToken(id: Int)
    
    // MARK: Admin Endpoints
    /// List all users (GET)
    case users
    /// Get a user (GET/PATCH/DELETE)
    case user(id: Int)
    
    // MARK: Health
    /// Health check
    case health
    
    func toPath() -> String {
        let apiBasePath = "/api/v1"
        
        switch self {
        case .register:
            return apiBasePath + "/register"
        case .login:
            return apiBasePath + "/login"
        case .logout:
            return apiBasePath + "/logout"
        case .checkPasswordStrength:
            return apiBasePath + "/check-password-strength"
        case .requestPasswordReset:
            return apiBasePath + "/password-reset/request"
        case .confirmPasswordReset:
            return apiBasePath + "/password-reset/confirm"
        case .me:
            return apiBasePath + "/users/me"
        case .changePassword:
            return apiBasePath + "/users/change-password"
        case .language:
            return apiBasePath + "/users/language"
        case .dateFormat:
            return apiBasePath + "/users/date-format"
        case .customFields:
            return apiBasePath + "/users/custom-fields"
        case .contacts:
            return apiBasePath + "/contacts"
        case .contact(let id):
            return apiBasePath + "/contacts/\(id)"
        case .archiveContact(let id):
            return apiBasePath + "/contacts/\(id)/archive"
        case .unarchiveContact(let id):
            return apiBasePath + "/contacts/\(id)/unarchive"
        case .circles:
            return apiBasePath + "/contacts/circles"
        case .random:
            return apiBasePath + "/contacts/random"
        case .birthdays:
            return apiBasePath + "/contacts/birthdays"
        case .contactImage(let id):
            return apiBasePath + "/contacts/\(id)/profile_picture"
        case .proxyImage:
            return apiBasePath + "/proxy/image"
        case .relationships(let contactId):
            return apiBasePath + "/contacts/\(contactId)/relationships"
        case .incomingRelationships(let contactId):
            return apiBasePath + "/contacts/\(contactId)/incoming-relationships"
        case .updateRelationship(let contactId, let relationshipId):
            return apiBasePath + "/contacts/\(contactId)/relationships/\(relationshipId)"
        case .contactNotes(let contactId):
            return apiBasePath + "/contacts/\(contactId)/notes"
        case .unassignedNotes:
            return apiBasePath + "/notes"
        case .note(let id):
            return apiBasePath + "/notes/\(id)"
        case .activities:
            return apiBasePath + "/activities"
        case .activity(let id):
            return apiBasePath + "/activities/\(id)"
        case .contactActivities(let contactId):
            return apiBasePath + "/contacts/\(contactId)/activities"
        case .reminders:
            return apiBasePath + "/reminders"
        case .upcomingReminders:
            return apiBasePath + "/reminders/upcoming"
        case .reminder(let id):
            return apiBasePath + "/reminders/\(id)"
        case .completeReminder(let id):
            return apiBasePath + "/reminders/\(id)/complete"
        case .contactReminders(let contactId):
            return apiBasePath + "/contacts/\(contactId)/reminders"
        case .completedReminders(contactId: let contactId):
            return apiBasePath + "/contacts/\(contactId)/reminder-completions"
        case .reminderCompletions(let id):
            return apiBasePath + "/reminder-completions/\(id)"
        case .importUploadCSV:
            return apiBasePath + "/contacts/import/upload"
        case .importPreviewCSV:
            return apiBasePath + "/contacts/import/preview"
        case .importConfirmCSV:
            return apiBasePath + "/contacts/import/confirm"
        case .importUploadVCF:
            return apiBasePath + "/contacts/import/vcf/upload"
        case .importConfirmVCF:
            return apiBasePath + "/contacts/import/vcf/confirm"
        case .exportCSV:
            return apiBasePath + "/export"
        case .exportVCF:
            return apiBasePath + "/export/vcf"
        case .graph:
            return apiBasePath + "/graph"
        case .apiTokens:
            return apiBasePath + "/admin/api-tokens"
        case .apiToken(let id):
            return apiBasePath + "/admin/api-tokens/\(id)"
        case .users:
            return apiBasePath + "/admin/users"
        case .user(let id):
            return apiBasePath + "/admin/users/\(id)"
        case .health:
            return "/health"
        }
    }
}
