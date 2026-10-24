<div align="center">

  <img src="assets/images/unifocus_logo_white.png" alt="UniFocus Logo" width="220" style="border-radius: 14px;" />

  # UniFocus

  <p>
    <b>The academic productivity workbench; a modern, open-source focus companion and multiplayer study arena built in Flutter.</b><br>
    Track cumulative GANO & AKTS, conquer Pomodoro sprints, manage course milestones, and study together in synchronized 2.5D virtual rooms.
  </p>

  <p align="center">
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square" alt="License" /></a>
    <a href="https://flutter.dev"><img src="https://img.shields.io/badge/written%20in-Flutter%20%7C%20Dart-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Written in Flutter" /></a>
    <img src="https://img.shields.io/badge/runs%20on-Android%20%C2%B7%20iOS%20%C2%B7%20Web%20%C2%B7%20Desktop-4CAF50?style=flat-square" alt="Supported Platforms" />
    <img src="https://img.shields.io/badge/security-Dual--Token%20Auth-00897B?style=flat-square" alt="Dual-Token Auth" />
  </p>

  <p align="center">
    <a href="https://firebase.google.com"><img src="https://img.shields.io/badge/realtime%20sync-Google%20Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black" alt="Firebase Sync" /></a>
    <a href="https://livekit.io"><img src="https://img.shields.io/badge/voice-LiveKit%20WebRTC-000000?style=flat-square&logo=webrtc&logoColor=white" alt="LiveKit Voice" /></a>
    <img src="https://img.shields.io/badge/audio-Synchronized%20Lo--fi-e91e63?style=flat-square" alt="Synchronized Audio" />
    <img src="https://img.shields.io/badge/languages-EN%20%C2%B7%20TR%20%C2%B7%20AR%20(RTL)-673AB7?style=flat-square" alt="Languages" />
  </p>

  <p align="center">
    <a href="#architecture--technology-stack">Architecture</a> •
    <a href="#academic-baseline--course-model">Academic Baseline & GANO</a> •
    <a href="#study-together--25d-active-study-arena">2.5D Study Arena</a> •
    <a href="#xp--gamification-system">Gamification & XP</a> •
    <a href="#security--dual-token-authentication">Security</a>
  </p>

</div>

### For University Students: You get it all settled!
Personalized degree, habit tracking, GANO calculation, and semester course selection. Above all that, the app analyzes the courses and semesters you take based on your needs.

### For School Students
Choose your academic year, select the classes you take and select your school. Play minigames and enjoy your learning studies.

### For y'all: Let's be more Social
#### The app provides a synchronized studying environment of a 2.5D physical study office where you can invite your friends to study together, play minigames, and have fun!

---

## Architecture & Technology Stack

- **Framework**: Dart
- **Backend Source of Truth**: Google Firebase
  - **Firebase Authentication**: Dual-Token architecture with short-lived memory access tokens, secure refresh tokens, sliding inactivity limits, and silent renewal on 401 Unauthorized.
  - **Cloud Firestore**: Realtime collections for `users/{uid}`, `users/{uid}/semesters/{semId}/courses/{courseId}`, `users/{uid}/tasks/{taskId}`, `users/{uid}/xpTransactions/{txId}`, and `rooms/{roomId}` with subcollection `rooms/{roomId}/members/{uid}`.
  - **Firebase Storage**: User avatars and academic document attachments.
- **Real-Time Voice**: LiveKit WebRTC with backend token generation and real microphone audio activity detection.
- **Audio Synchronization**: Synchronized ambient audio using server timestamp offsets and bundled royalty-free audio tracks.
- **Localization**: Native English (`en`), Turkish (`tr`), and Arabic (`ar`) with true bidirectional RTL support.

---

## Academic Baseline Model (For University Students)

### Academic Baseline vs Entered Courses
UniFocus avoids forcing students to enter four years of historical courses manually. Onboarding captures the student's existing baseline:
- `previousGpa`: The cumulative GPA achieved prior to using UniFocus (nullable).
- `previousCompletedAKTS`: Total credits completed prior to using UniFocus.

If a student is in their Preparatory Year (`PREP`) or is a Freshman who has not yet completed graded courses, `previousGpa` is set to `null`. The user interface displays **`GPA NOT SET`** rather than misleading `0.00`.

When graded courses are entered into UniFocus, cumulative GANO is calculated precisely by weighting the previous baseline with newly completed courses:

$$\text{Cumulative GANO} = \frac{(\text{previousGpa} \times \text{previousCompletedAKTS}) + \sum (\text{course.gradePoints} \times \text{course.akts})}{\text{previousCompletedAKTS} + \sum \text{gradedCourse.akts}}$$

If `previousGpa` is unset and no graded courses exist, the application displays **`GPA NOT SET`** with no fabricated changes.

### Multi-Program Support (Double & Minor)
UniFocus provides full first-class support for students with secondary programs:
- Single Major (`NONE`)
- Double Major (`CAP`)
- Minor Program (`MINOR`)

Every course explicitly specifies its academic program ownership (`programType: MAIN | CAP | MINOR`), allowing students to add courses belonging to either their primary department or secondary degree. Academic screens feature quick program filter chips (*All Programs*, *Main Program*, *ÇAP*, *Yandal*).

---

## Study Together & 2.5D Active Study Arena

### Real Multiplayer Architecture
- Real rooms are identified by 9-digit codes formatted as `XXX-XXX-XXX`.
- Room state is stored under `rooms/{roomId}` with participants in `rooms/{roomId}/members/{uid}`.
- If a user has never joined or hosted an arena, the UI renders the clean empty state: **`NO ACTIVE ROOMS`** with options to **`CREATE NEW ARENA`** or **`JOIN ARENA`**.

### 2.5D Physical Workstation Allocation
- The 2.5D Isometric Room features 6 predefined physical workstations.
- Workstation assignment is deterministic: `[0, 3, 1, 4, 2, 5]` to ensure peers sit separated before filling adjacent desks.
- **Unused Desks Hidden**: During `ACTIVE` focus mode, unused desks are completely hidden. If 2 students study together, only 2 desks are rendered.
- **Personal Break**: When a single participant takes a personal break, only their avatar stands up, walks to the door, and exits the room. Their desk becomes visibly unoccupied while other peers remain focused.
- **Group Break & Voting**: When a peer requests a group break, a room-wide vote banner is presented to all members. When the vote condition passes, the entire room transitions to the Break Lounge.
- **Host Disconnect Policy**: When the host leaves a room with remaining peers, host authority is deterministically transferred to the next longest-standing member, preventing the room from becoming orphaned.

### LiveKit Voice & Speaking Detection
- In the Break Lounge, real WebRTC voice is powered by LiveKit.
- The speaking indicator is driven directly by LiveKit audio level callbacks (`ActiveSpeakersChangedEvent`), displaying glowing speech rings and waveforms based on real participant microphone audio.
- Microphones are automatically muted upon room entry and cleanly disconnected when exiting the lounge.

### Synchronized Lo-fi Audio
- Music uses bundled, royalty-free audio tracks (`assets/audio/`) to guarantee immediate playback across all platforms without external network or CORS failures.
- Playback synchronization is timestamp-based (`musicState.startedAt` and `currentPositionSeconds`), avoiding writing to Firestore every second while allowing late joiners to seek to the shared playback position.

---

## XP & Gamification System

### XP Philosophy
The UniFocus XP system is designed to reward genuine academic consistency, focused study sprints, task completion, and collaborative peer learning. XP is awarded exclusively for verifiable, completed academic activities.

### XP Sources
The following table documents every XP source and its exact reward value implemented in `GamificationService`:

| Activity | XP Awarded |
|---|---:|
| Normal task completed | +10 XP |
| High-priority task completed | +15 XP |
| 25–30 minute completed focus session | +25 XP |
| 50–60 minute completed focus session | +50 XP |
| 90+ minute completed focus session | +75 XP |
| Daily focus goal completed (4 sessions) | +30 XP bonus |
| Completed Study Together session | +25 XP |
| Completed multiplayer session bonus | +25 XP |
| Completed social mini-game | +5 XP |
| Daily streak continuation | +5 XP |
| 7-day streak milestone | +50 XP bonus |
| 30-day streak milestone | +200 XP bonus |

### Activities that DO NOT Award XP
To prevent game-playing and maintain gamification integrity, the following activities **never award XP**:
- Opening or viewing a screen
- Joining or leaving a Study Together room
- Starting and immediately cancelling a focus session
- Navigating back and forth between tabs
- Reconnecting to Firestore or LiveKit
- Refreshing the web browser or restarting the mobile application

### Level Formula
Player levels follow a progressive quadratic XP requirement curve. Level thresholds are documented below:

| Level | Lifetime XP Required | Incremental XP to Next Level |
|:---:|:---:|:---:|
| **Level 1** | 0 XP | 100 XP |
| **Level 2** | 100 XP | 150 XP |
| **Level 3** | 250 XP | 200 XP |
| **Level 4** | 450 XP | 250 XP |
| **Level 5** | 700 XP | 300 XP |
| **Level 6** | 1000 XP | 350 XP |
| **Level 7** | 1350 XP | 400 XP |
| **Level 8** | 1750 XP | 450 XP |
| **Level 9** | 2200 XP | 500 XP |
| **Level 10** | 2700 XP | 550 XP |

For levels beyond Level 10, the XP required scales consistently at:

$$\text{XP}(\text{Level } N) = 2700 + (N - 10) \times 550$$

### Streak System
- **Starting a Streak**: Completing at least one verified focus sprint (minimum 25 minutes) or completing an academic task starts a 1-day streak.
- **Continuation**: Completing an activity on consecutive calendar days increments the streak count and awards +5 XP per day.
- **Missed Day**: If a full calendar day passes without any completed focus session or task, the streak resets to 0.
- **Milestone Bonuses**: Reaching a 7-day streak awards a **+50 XP** milestone bonus. Reaching a 30-day streak awards a **+200 XP** milestone bonus.

### Anti-Abuse Rules & Idempotency
- **Idempotency Keys**: Every XP award is stamped with a unique `idempotencyKey` (e.g. `task_{taskId}`, `session_{sessionId}`).
- **Transaction Audit Trail**: Each transaction is stored in Cloud Firestore under `users/{uid}/xpTransactions/{transactionId}`. If a transaction with that key already exists, additional XP is strictly rejected.
- **Server-Side Trust**: Client-side widgets cannot arbitrarily modify the total XP integer; all mutations occur via `GamificationService` transaction sets.

### Comprehensive Example Calculation
Suppose a student completes the following activities in one day:
1. Completes 2 normal academic tasks: $2 \times (+10\text{ XP}) = +20\text{ XP}$
2. Completes a 50-minute Pomodoro focus session: $+50\text{ XP}$
3. Hits their 4-session daily focus goal: $+30\text{ XP bonus}$
4. Completes a multiplayer Study Together session: $+25\text{ XP}$

$$\text{Total XP Earned} = 20 + 50 + 30 + 25 = 125\text{ XP}$$

A brand-new user starting at **0 XP (Level 1)** earns 125 XP, advancing to **Level 2** (requiring 100 XP) with 25 XP toward Level 3 (requiring 250 XP total).

### New User Default State
For every freshly registered account:
- $\text{XP} = 0$
- $\text{Level} = 1$
- $\text{Streak} = 0$
- $\text{Total Focus Minutes} = 0$
- $\text{Courses} = 0$
- $\text{Tasks} = 0$
- $\text{Rooms} = 0$

---

## Security & Dual-Token Authentication

UniFocus implements a strict Dual-Token authentication architecture adhering to professional web security standards:
- **In-Memory Access Token**: Short-lived (15–60 min) token held strictly in memory.
- **Secure Refresh Token**: Long-lived token stored securely in `SharedPreferences`.
- **Sliding Inactivity Expiration**: A 7-day sliding inactivity limit logs out dormant sessions.
- **Silent Renewal**: Network requests that encounter `401 Unauthorized` automatically attempt background silent renewal using the refresh token before redirecting to the login screen.
- **Token Rotation**: Every refresh event generates a fresh rotated token to invalidate stale tokens.
