# Software Requirements Specification for TransposeX

## 1. Purpose

### 1.1 Definitions

- **Sheet Music Transposition**: The process of shifting a piece of music from one key to another while maintaining its structure.
- **Optical Music Recognition (OMR)**: A technology that scans and converts printed or handwritten sheet music into a digital format.
- **Functional Requirements**: Features the app must have to meet user needs, such as transposing music and uploading files.
- **Non-functional Requirements**: Constraints on how the app performs, including speed, usability, and security.
- **MusicXML**: A file format that allows digital representation of sheet music for easy editing and sharing.
- **Key Signature**: The set of sharps or flats that defines the tonal center of a piece of music.

### 1.2 Background

Musicians frequently need to transpose sheet music to accommodate different instruments, vocal ranges, or performance needs. However, manual transposition is difficult to learn, time-consuming, and error-prone, often requiring musicians to rewrite entire scores by hand.

Existing apps like MuseScore and Flat.io allow digital transposition, but they require users to manually input every note, making it impractical for quick adjustments. Our **Sheet Music Key Converter App** aims to fill this gap by allowing users to upload an image or PDF of sheet music and automatically transpose it to any key.

By leveraging **Optical Music Recognition (OMR)** and **music processing algorithms**, the app will provide a seamless solution for music students, accompanists, and hobbyists, making transposition faster, easier, and more accessible to everyone.

---

## 2. Overall Description

### 2.1 User Characteristics

- **Musical Background**: Mostly beginner to intermediate musicians but can include experienced players.

#### **Primary Users:**
- 🎵 **Students** who need to transpose music for practice or performance.
- 🎹 **Hobbyists** who want to play music in a different key.
- 🎤 **Singers** who need to adjust music to match their vocal range.
- 📝 **Anyone** who struggles with manually transposing sheet music and wants an easier way.

### 2.2 User Stories
**As a user,** 
- I want to upload an image or PDF of my sheet music so that I can easily transpose it.
- I want to select a new key for transposition so I can adjust the music to my needs.
- I want to see a preview of the transposed sheet music before downloading it.
- I want the app to detect and show the original key so I can confirm the starting point.
- I want the app to warn me if the uploaded sheet music is unreadable or unclear.
- I want to zoom in and out on my sheet music for better readability.
- I want to save my transposed sheet music in multiple formats (PDF, XML, and JPEG).
- I want a simple and easy-to-use interface, so I don’t get confused while using the app.
- I want the app to function properly on my phone or tablet so I can use it anywhere.
- I want the app to be fast and responsive, so I don’t have to wait too long for my music to be transposed.
- I want a help section that explains how to use the app.
- I want the app to be stable and not crash while I’m using it.
- I want the app to be accessible so that people with disabilities can use it too.

### 2.3 App Workflow
<img width="851" alt="Screenshot 2025-02-18 at 1 12 59 PM" src="https://github.com/user-attachments/assets/a7ab5b47-19a7-4495-8443-7d2723b56236" />

### 2.4 Hi-Fi Wireframes
You can access the Hi-Fi wireframes [here](https://cs5520-spring25-seattle.github.io/finalproject-transposex/TransposeX.pdf).
---

## 3. Requirements

### 3.1 Functional Requirements (What the App Must Do)

*(Items marked with an asterisk (*) are not required for MVP.)*

- The app must allow users to upload images (**PNG, JPEG**) and files (**PDFs**) of sheet music.
- The app must use **Optical Music Recognition (OMR)** to detect the original key, musical notes, and symbols from uploaded images.
- Users must be able to **select a new key** for transposition (e.g., from C major to G major).
- The app must **transpose all musical elements**, including melody, chords, and key signatures.
- The app must allow users to **preview the transposed sheet music** before saving or downloading.
- The app must support exporting transposed sheet music in **PDF, MusicXML, and JPEG formats**.
- Users must be able to **zoom in/out** and adjust the display for better readability.
- The app must provide **real-time feedback or warnings** if the upload is unclear, incomplete, or unreadable.
- The app must allow users to save transposed sheet music in different formats (**PDF, XML, JPEG**).

### 3.2 Non-Functional Requirements

- The app must transpose sheet music within **10-15 seconds** for standard-length pieces (**2-3 pages**).
- The **Optical Music Recognition (OMR)** must achieve at least **90% accuracy** in detecting notes and symbols.
- The app must have an **intuitive and user-friendly interface**.
- The app shall allow users to begin scanning and transposing sheet music within **3 seconds** of opening the app.
- The app interface shall follow **standard mobile UI guidelines** (e.g., **Material Design for Android, Human Interface Guidelines for iOS**).
- The app must be compatible with **iOS and Android** (including tablets).
- The app must provide **error-handling mechanisms**, such as guiding users when uploads fail.
- The app must be optimized for **mobile and tablet use**, ensuring that sheet music remains readable on smaller screens. *
- The app must have **voiceover support** on all buttons and texts, ensuring usability for users with disabilities. *
- The app should operate reliably **without frequent crashes or downtime**. *
- The app must successfully open and function **98% of the time** without crashing. *
- Any **downtime or failures** must not exceed **2 minutes per day** on average. *

---

## 📌 Notes  

- Features marked with an asterisk (*) are **not required for MVP** but may be considered for future updates.
- This document outlines the key functionalities, user expectations, and performance standards for **TransposeX**.
