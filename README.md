# iOS Sample App
A sample app demonstrating OAuth 2.0 and other features using Core API.

## Getting Started
The purpose of this sample app is to perform three basic functions:
  * Complete the authorization process and receive tokens for communicating with Core
  * Call Core Public API resources using access token
  
### Requirements:

To successfully run this app, you need the following:
  * A Core [developer](https://api-developer.bqecore.com/webapp) account
  * An app on Developer Portal and the associated client_id, client_secret and redirect_uri
  * Core Sandbox/Production company
  
### What is supported?

  1. Authorization
  2. Authentication
  3. Activity - Retrieve, Create, Update and Delete
  
### Setting URL Schemes
In info tab of your target
![Image](Assets/URLSchemes.png "Image")
Replace timelogger by your application name

### Handle URL in AppDelegate
- On iOS implement `UIApplicationDelegate` method
```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey  : Any] = [:]) -> Bool {
    if let scheme = url.scheme, scheme == "timelogger"{
        CoreAccount.sharedInstance.handle(url: url)
    }
  return true
}
```
:warning: Any other application may try to open a URL with your url scheme. So you can check the source application, for instance for safari controller :
```
if (options[.sourceApplication] as? String == "com.apple.SafariViewService") {
```
