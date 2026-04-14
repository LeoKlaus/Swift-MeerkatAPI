# Swift Meerkat API

A Swift API wrapper for the API of [Meerkat](https://github.com/fbuchner/meerkat-crm), a self-hosted CRM for personal use.

> [!CAUTION]
> This integration is in early development and every update until 1.0.0 should be considered breaking!
> If you still want to use it with a project, consider pinning a specific commit.

## Basic usage

### Authentication

Meerkat uses cookie based authentication by default. Obtaining an API token requires authenticating with the users credentials, storing the session cookie and requesting a token with that cookie.
To do so, `ApiHandler` offers a number of static methods:

``` swift
// Login authenticate a user
_ = ApiHandler.login(serverURL: serverURL, username: username, password: password)

// Request token
let tokenResponse = try await ApiHandler.createApiToken(serverURL: serverURL, name: "Demo Token")

// Delete session cookie
try? await ApiHandler.logout(serverURL)

let handler = ApiHandler(serverURL: serverURL, token: tokenResponse.token!)
```


### Basic interaction

ApiHandler offers documented convenience methods for all available API endpoints at the time of writing.

For example loading contacts:
``` swift
let contactResponse = try await handler.getContacts()

print(contactResponse.results)
```


### Advanced interaction

For everything beyond that, you should refer to the [Meerkat API docs](https://fbuchner.github.io/meerkat-crm/api-reference.html).
