# EduHub App Flowchart

## App Architecture Overview

```mermaid
graph TB
    subgraph "Mobile App (Flutter)"
        A[Welcome Screen] --> B[Authentication Check]
        B --> C{User Logged In?}
        C -->|No| D[Login/Signup Flow]
        C -->|Yes| E[Home Page]
        D --> E
    end
    
    subgraph "Authentication Services"
        F[Firebase Auth]
        G[Supabase Auth]
        H[PostgreSQL User DB]
    end
    
    subgraph "Core Features"
        I[Home Tab]
        J[Course Tab]
        K[Class Tab]
        L[Assignment Tab]
        M[Profile Tab]
    end
    
    subgraph "Backend Services (Node.js)"
        N[Auth API]
        O[User API]
        P[Time Tracker API]
        Q[Assignment API]
    end
    
    subgraph "Databases"
        R[Firebase Firestore]
        S[PostgreSQL]
        T[Supabase Storage]
    end
    
    E --> I
    E --> J
    E --> K
    E --> L
    E --> M
    
    D --> F
    D --> G
    F --> H
    G --> H
    
    I --> N
    J --> O
    K --> P
    L --> Q
    M --> N
    
    N --> R
    N --> S
    O --> S
    P --> S
    Q --> S
    
    K --> T
    L --> T
```

## Detailed User Flow

```mermaid
flowchart TD
    Start([App Start]) --> Welcome[Welcome Screen<br/>3 seconds]
    Welcome --> AuthCheck{Check Authentication}
    
    AuthCheck -->|Not Authenticated| Login[Login Page]
    AuthCheck -->|Authenticated| Home[Home Page]
    
    Login --> Signup[Signup Option]
    Login --> FirebaseAuth[Firebase Authentication]
    Signup --> FirebaseAuth
    FirebaseAuth --> UserCreation[Create User in PostgreSQL]
    UserCreation --> Home
    
    Home --> TabSelection{Select Tab}
    
    TabSelection -->|Home| HomeTab[Home Tab]
    TabSelection -->|Courses| CourseTab[Course Tab]
    TabSelection -->|Classes| ClassTab[Class Tab]
    TabSelection -->|Assignments| AssignmentTab[Assignment Tab]
    TabSelection -->|Profile| ProfileTab[Profile Tab]
    
    %% Home Tab Flow
    HomeTab --> UserRole{User Role}
    UserRole -->|Student| StudentHome[Student Home View]
    UserRole -->|Teacher| TeacherHome[Teacher Home View]
    UserRole -->|Guest| GuestHome[Guest Home View]
    
    %% Course Tab Flow
    CourseTab --> CourseList[Course List]
    CourseList --> CourseDetail[Course Details]
    CourseDetail --> Enroll{Enroll in Course}
    Enroll -->|Yes| CourseEnrolled[Course Enrollment]
    Enroll -->|No| CourseList
    
    %% Class Tab Flow
    ClassTab --> ClassRole{User Role}
    ClassRole -->|Student| StudentClass[Student Classes]
    ClassRole -->|Teacher| TeacherClass[Teacher Classes]
    
    StudentClass --> ClassDetail[Class Details]
    TeacherClass --> CreateClass[Create Class]
    CreateClass --> ClassDetail
    
    ClassDetail --> ClassFeatures{Class Features}
    ClassFeatures --> Chat[Class Chat]
    ClassFeatures --> Materials[Class Materials]
    ClassFeatures --> Members[Class Members]
    
    %% Assignment Tab Flow
    AssignmentTab --> AssignmentRole{User Role}
    AssignmentRole -->|Student| StudentAssignment[Student Assignments]
    AssignmentRole -->|Teacher| TeacherAssignment[Teacher Assignments]
    
    StudentAssignment --> AssignmentList[Available Assignments]
    AssignmentList --> StartAssignment[Start Assignment]
    StartAssignment --> QuestionFlow[Question Flow]
    QuestionFlow --> AssignmentComplete[Assignment Complete]
    AssignmentComplete --> PersonalityTest[Personality Test]
    PersonalityTest --> Results[Personality Results]
    
    TeacherAssignment --> CreateAssignment[Create Assignment]
    CreateAssignment --> AddQuestions[Add Questions]
    AddQuestions --> PublishAssignment[Publish Assignment]
    
    %% Profile Tab Flow
    ProfileTab --> ProfileOptions{Profile Options}
    ProfileOptions --> EditProfile[Edit Profile]
    ProfileOptions --> Settings[Settings]
    ProfileOptions --> Logout[Logout]
    ProfileOptions --> CustomerService[Customer Service]
    
    Logout --> AuthCheck
```

## Database Schema Flow

```mermaid
erDiagram
    edu_user {
        int id PK
        string firebase_uid UK
        string first_name
        string last_name
        string email UK
        string password
        string role
    }
    
    assignments {
        int id PK
        string title
        string language
        timestamp created_at
        timestamp updated_at
    }
    
    questions {
        int id PK
        int assignment_id FK
        text question_text
        string type
        string image_url
        text correct_answer
    }
    
    time_tracker {
        int id PK
        int user_id FK
        timestamp start_time
        timestamp end_time
    }
    
    personality_result {
        int personality_result_id PK
        string code
        text main_description_en
        text main_description_km
        text description_en
        text description_km
        timestamp created_at
        timestamp updated_at
    }
    
    relationship {
        int id PK
        int personality_result_id FK
        text header_description_en
        text header_description_km
        text description_en
        text description_km
        timestamp created_at
        timestamp updated_at
    }
    
    edu_user ||--o{ time_tracker : tracks
    assignments ||--o{ questions : contains
    personality_result ||--o{ relationship : has
```

## Data Flow Architecture

```mermaid
graph LR
    subgraph "Frontend (Flutter)"
        A[UI Components] --> B[State Management]
        B --> C[Service Layer]
    end
    
    subgraph "Service Layer"
        C --> D[API Service]
        C --> E[Firebase Service]
        C --> F[Time Tracker Service]
        C --> G[Assignment Service]
    end
    
    subgraph "Backend (Node.js)"
        D --> H[Express Routes]
        H --> I[Middleware]
        I --> J[Controllers]
        J --> K[Database Layer]
    end
    
    subgraph "Data Sources"
        E --> L[Firebase Auth]
        E --> M[Firestore]
        F --> N[PostgreSQL]
        G --> N
        K --> N
        K --> O[Supabase Storage]
    end
    
    subgraph "External Services"
        P[Push Notifications]
        Q[Deep Links]
        R[Image Storage]
    end
    
    A --> P
    A --> Q
    G --> R
```

## Key Features Flow

```mermaid
graph TB
    subgraph "Authentication Flow"
        A1[Email/Password Login] --> A2[Firebase Auth]
        A3[Google Sign-in] --> A2
        A4[Signup] --> A5[Create User in PostgreSQL]
        A2 --> A6[JWT Token]
        A5 --> A6
        A6 --> A7[Store in SharedPreferences]
    end
    
    subgraph "Time Tracking Flow"
        B1[App Open] --> B2[Start Time Tracking]
        B2 --> B3[Record Start Time]
        B4[App Close/Background] --> B5[End Time Tracking]
        B5 --> B6[Calculate Duration]
        B6 --> B7[Store in PostgreSQL]
    end
    
    subgraph "Assignment Flow"
        C1[Select Assignment] --> C2[Load Questions]
        C2 --> C3[Display Questions]
        C3 --> C4[Record Answers]
        C4 --> C5[Calculate Score]
        C5 --> C6[Personality Analysis]
        C6 --> C7[Show Results]
    end
    
    subgraph "Class Communication Flow"
        D1[Send Message] --> D2[Upload to Supabase Storage]
        D2 --> D3[Store Metadata in Firestore]
        D3 --> D4[Send Push Notification]
        D4 --> D5[Update Chat UI]
    end
```

## Technology Stack Integration

```mermaid
graph TB
    subgraph "Frontend Technologies"
        A[Flutter/Dart]
        B[Firebase SDK]
        C[Supabase Flutter]
        D[State Management]
    end
    
    subgraph "Backend Technologies"
        E[Node.js/Express]
        F[PostgreSQL]
        G[JWT Authentication]
        H[RESTful APIs]
    end
    
    subgraph "Database & Storage"
        I[Firebase Firestore]
        J[Firebase Authentication]
        K[Supabase Storage]
        L[PostgreSQL Database]
    end
    
    subgraph "Additional Services"
        M[Push Notifications]
        N[Deep Linking]
        O[Image Processing]
        P[Time Tracking]
    end
    
    A --> B
    A --> C
    A --> D
    
    B --> I
    B --> J
    C --> K
    D --> E
    
    E --> F
    E --> G
    E --> H
    
    H --> L
    
    A --> M
    A --> N
    A --> O
    A --> P
```

This flowchart illustrates the complete EduHub app architecture including:

1. **User Authentication Flow** - From welcome screen to authenticated home page
2. **Role-Based Navigation** - Different flows for students, teachers, and guests
3. **Feature Navigation** - Core tabs and their sub-features
4. **Database Architecture** - PostgreSQL schema with relationships
5. **Data Flow** - How data moves between frontend, backend, and databases
6. **Technology Integration** - How different services work together

The app uses a hybrid approach with Firebase for authentication and some real-time features, PostgreSQL for structured data, and Supabase for file storage and additional backend services.
