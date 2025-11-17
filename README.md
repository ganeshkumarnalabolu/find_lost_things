Find Lost Things – A Simple Flutter Application
Introduction

This is a simple Flutter application where users can save details of items they lost or found, search through the list, and mark an item as resolved.
This project is created as part of the Mobile Application Development (MAD) assignment.

Features
1. Add Lost Item

Users can enter:

Title (required)

Description

Location

Contact number / email

2. List of Saved Items

All added items appear on the home screen in a scrollable list.

3. Search Function

A search bar helps users filter items by:

Title

Description

Location

4. Mark as Resolved

Each item has a details page where users can click “Mark as Resolved” to update the status.

5. Local Data Storage

The app uses SharedPreferences to store all data.
Items remain saved even after the app is closed and reopened.

Technologies Used

Flutter (Dart)

Android SDK / Emulator

SharedPreferences plugin

How to Run the App

Start an Android Emulator

Run the following in the terminal:

flutter run -d <emulator-id>

Screenshots

(Add your screenshots here)

Add Item screen

Home screen

Search screen

Details + Resolved screen

Conclusion

This project helped me learn:

Flutter UI basics

Forms and validation

Navigation

Using SharedPreferences for local storage

Managing app state with setState()