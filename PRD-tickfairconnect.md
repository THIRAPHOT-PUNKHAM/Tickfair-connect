# Product Requirements Document (PRD)

**Project:** TickFair Connect  
**Platform:** Flutter mobile application  
**Date:** February 27, 2026  
**Author:** Thiraphot Punkham (Product Manager / Flutter Developer)

---

## Executive Summary
TickFair Connect delivers a lightweight, cross‑platform mobile app that solves the common problem of unfair ticket distribution for small events. By implementing a first‑come‑first‑served queue coupled with a single‑ticket policy, the system ensures transparency, fairness, and simplicity. The MVP targets university‑age users who frequently miss out on tickets due to simultaneous heavy access and lack of visible queue order. Development will leverage Flutter for the frontend and Firebase for backend services to accelerate time‑to‑market.

### Vision & Goals
- **Vision:** Become the go‑to mobile solution for fair ticketing at campus and community events.  
- **Primary goal:** Enable any user to join a managed queue and reserve one ticket reliably.  
- **Secondary goals:** Maintain sub‑5‑second queue update latency, achieve 80%+ registration conversion, and keep the system within feasibility limits for an academic MVP.

---

## Target Audience
- **Primary user:** 22‑year‑old university student in Thailand with intermediate tech skills.  
- **Context:** Attending concerts, sales, or academic events where tickets are limited.  
- **Problems:** Frequent ticket acquisition failure during peak demand, no visibility into queue position, ability of some users to abuse the system by retrying repeatedly.

### Personas
| Persona | Description | Key Needs |
|---------|-------------|-----------|
| "Prim" | Female undergraduate, social, tech‑savvy | Fair access to event tickets, real‑time queue status, simple workflow |

---

## Functional Requirements
Functionality is broken into modules that correspond to core user actions.

### Authentication & Profile
- **FR‑A1:** Support user registration via email/password.  
- **FR‑A2:** Authenticate existing users with secure login.  
- **FR‑A3:** Allow profile viewing/updating (name, email).  
- **FR‑A4:** Maintain session tokens with automatic refresh.

### Event Listing & Discovery
- **FR‑E1:** Display a scrollable list of available events with name, date, venue, capacity, and remaining tickets.  
- **FR‑E2:** Enable basic search/filter by date or category.  
- **FR‑E3:** Provide event detail screens with full description and a "Join Queue" action.

### Queue Management
- **FR‑Q1:** Allow a logged‑in user to join a queue for a selected event.  
- **FR‑Q2:** Capture server‑side timestamp upon entry.  
- **FR‑Q3:** Calculate and store queue position based on timestamp.  
- **FR‑Q4:** Prevent duplicate queue entries for the same event.  
- **FR‑Q5:** Offer queue cancellation and timeout (30‑minute inactivity).

### Real‑Time Updates & Notifications
- **FR‑R1:** Continuously update the user’s queue position with <5‑second latency.  
- **FR‑R2:** Display estimated wait time and total queue size.  
- **FR‑R3:** Notify the user (in‑app push) when their turn is within a configurable threshold (e.g., 5 positions).

### Ticket Reservation & Confirmation
- **FR‑T1:** Enable reservation with a single tap when queue position = 1.  
- **FR‑T2:** Enforce one ticket per user, per event.  
- **FR‑T3:** Generate a ticket record containing event data and a unique ID (or QR code).  
- **FR‑T4:** Present a confirmation screen and allow download or save of ticket information.

---

## Non-Functional Requirements
These requirements govern system qualities beyond specific features.

### Performance
- **NFR‑P1:** App launch and screen transitions must occur within 2 seconds.  
- **NFR‑P2:** Queue update latency <5 seconds.  
- **NFR‑P3:** Backend APIs should respond within 1 second under nominal load.

### Security
- **NFR‑S1:** All communication must use TLS 1.2+ encryption.  
- **NFR‑S2:** Passwords hashed using a strong algorithm (bcrypt/Argon2 via Firebase Auth).  
- **NFR‑S3:** Implement role‑based security rules in the database so users can only access their own queue/reservation data.  
- **NFR‑S4:** Rate‑limit queue join operations to mitigate abuse.

### Usability & UI/UX
- **NFR‑U1:** UI must support Thai and English localizations.  
- **NFR‑U2:** Design follows Material guidelines with responsive layouts for phones/tablets.  
- **NFR‑U3:** Provide clear loading indicators and error messages.  
- **NFR‑U4:** Accessibility support for screen readers (WCAG Level A).

---

## Tech Stack
| Layer | Technology / Service |
|-------|----------------------|
| Frontend | Flutter (Dart) for iOS & Android |
| Authentication | Firebase Authentication (email/password) |
| Realtime Database | Firebase Realtime Database or Firestore |
| Backend Logic | Firebase Cloud Functions (Node.js) |
| Notifications | Firebase Cloud Messaging (FCM) |
| Storage (tickets) | Firebase Cloud Storage |
| Analytics & Crash Reporting | Firebase Analytics, Crashlytics |

**Rationale:** The student submission referenced simplicity and realtime requirements; Firebase is a natural backend choice for rapid prototyping in an academic context. Flutter ensures cross‑platform support with a single codebase.

---

## User Flow
Outlined below are the critical journeys.

### Registration & Access
1. Launch app → Welcome screen.  
2. Choose "Register" → Fill email/password, accept terms → Submit → Success message → Login screen.
3. Login with credentials → Redirect to Event List.

### Event Discovery to Queue Entry
1. Event List scrolls with cards.  
2. Tap card → Event Detail view.  
3. Press "Join Queue" → Confirmation modal with initial queue position.  
4. Redirect to Queue Status page.

### Queue Tracking & Reservation
1. Queue Status page shows current position, estimated time.  
2. Realtime updates occur while user waits.  
3. When position = 1, "Reserve Ticket" button appears.  
4. Tap button → Reservation processed → Confirmation screen with ticket ID/QR code.

### Alternative Flows
- Cancel queue from Queue Status.  
- Event sold out or cancelled triggers alert and returns user to Event List.
- Inactivity timeout removes user automatically and notifies them.

---

## Milestones
A high‑level roadmap organized into development sprints.

| Milestone | Description | Target Date |
|-----------|-------------|-------------|
| **M1 – Setup & Auth** | Flutter project scaffold, Firebase integration, registration/login flows | Mar 15, 2026 |
| **M2 – Event Listing** | Build event list screen, detail view, backend event data | Mar 31, 2026 |
| **M3 – Queue Core** | Queue join logic, position calculation, realtime updates | Apr 14, 2026 |
| **M4 – Reservation & Confirmation** | Reservation endpoint, confirmation UI, ticket generation | Apr 28, 2026 |
| **M5 – Polish & Testing** | UX refinements, performance tuning, end‑to‑end testing, bug fixes | May 12, 2026 |
| **M6 – MVP Release** | Deploy to beta testers, collect feedback, prepare final report | May 26, 2026 |

---

*This PRD follows the requirements set forth by the academic evaluation and reflects the simplified MVP strategy recommended in the feedback. Development teams should use this document as the authoritative guide during implementation.*
