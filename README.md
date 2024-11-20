Flutter Kotlin SDK

This documentation provides integration steps and usage instructions for incorporating the Flutter Kotlin SDK 2.2.4 into your Flutter Android project. Follow these steps to initialize the SDK, record events, and manage attributes within your application.

## Integration Steps

### 1. Include SDK in Your Project

1. Place maven `{ url 'https://jitpack.io' }` in android project level `buid.gradle`.

```kotlin
 allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
    }
} 
```

2. Add `mergn_flutter_plugin_sdk:` in pubsec.yml

## Usage

### 1. Register API Key

Register your API Key:

```kotlin
MergnChannel.registerAPICall("API KEY");
```

### 2. Record Events

Use the `EventManager` to record events by providing an event name and properties:

```kotlin
String eventName = "Event Name";
// Map<String, String> eventProperties = {"propertyName": "PropertyValue"}; // Optional property setup
Map<String, String> eventProperties = Map(); // For empty properties
MergnChannel.sendEvent(eventName, eventProperties);
```

### 3. Record Attributes

Use the `AttributeManager` to record attributes by providing an attribute name and value:

```kotlin
String attributeName = "Email"; // eventName.text.toString()
String attributeValue = "fluttersdk@mergn.com";
MergnChannel.sendAttribute(attributeName, attributeValue);
```

### 4. Login

Record the login event when the user successfully logs in:

```
MergnChannel.login("fluttersdk@mergn.com");  // Add unique Identifier
```

**Unique Identity (mandatory)**: This value represents the customer's unique identity in your database, such as an ID or email.

### 5. Firebase Token Registration

Register the Firebase token to receive MERGN notifications:

```
MergnChannel.firebaseToken(fcmToken.toString());
```

This method should be called in any place where you would potentially land. Also, call this in `onNewToken()` and `onRefreshToken()` in your Firebase service.

### Important Case

There are three scenarios in the app where you need to send sign-in attributes and trigger the login event of the MERGN SDK:

1. When a new user creates a new account.
2. When existing users log into the app.
3. When the user is already logged in (important for capturing data of users who logged in previous versions of the app where the MERGN SDK was not integrated).
