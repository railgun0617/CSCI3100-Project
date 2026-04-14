# CUHK Venue & Equipment Booking SaaS

A multi‑tenant SaaS application for CUHK student societies and departments to manage bookings of venues and equipment. Built with Ruby on Rails 8.1, Tailwind CSS, and SQLite.

## Table of Contents

- [Features](#features)
- [Technology Stack](#technology-stack)
- [Setup Instructions](#setup-instructions)
- [Running the Application](#running-the-application)
- [Testing](#testing)
- [Deployment](#deployment)
- [Advanced Features](#advanced-features)
- [Feature Ownership](#feature-ownership)
- [Team](#team)

## Features

### Core Features
- **Multi‑tenant architecture** – Each department (tenant) manages its own venues and equipment independently.
- **User authentication** – Devise with roles: `student` and `staff` (plus an `Admin` tenant for super‑admin access).
- **Resource/Departments management** – CRUD operations for venues and equipment (staff only), departments(admin only).
- **Booking system** – Students can book venues/equipment for 1‑4 hour slots, up to 7 days in advance.
- **Conflict detection** – Prevents double‑booking of venues and ensures sufficient equipment quantity.
- **Approval workflow** – Staff approve or reject pending bookings; students see real‑time status.
- **Email confirmation** – Users must confirm their email address when changing their password before sign in via a link (using Brevo SMTP). Also, users can receive email notification for booking requests (pending, approve and reject).
- **Cancel & delete bookings** – Students can cancel their own bookings; staff can delete any booking.

### Advanced Features (N‑1 = 3+)
1. **Google Maps API** – Interactive map picker for venue/equipment location when creating/editing resources; displays location on show pages.
2. **ActionCable (Real‑time)** – Staff dashboard updates instantly when a booking is approved/rejected; students see status changes without page reload.
3. **SendGrid (Email notifications)** – Booking confirmation, approval/rejection, and reminder emails are sent via Brevo (SendGrid alternative).
4. **Fuzzy search** – Ransack‑powered search on all listing pages (Resources, Venues, Equipment) that matches name, description, location, and department.

## Technology Stack

| Component       | Technology                                      |
|----------------|-------------------------------------------------|
| Framework      | Ruby on Rails 8.1                               |
| Database       | SQLite                                          |
| Frontend       | Tailwind CSS, Stimulus (Hotwire), ERB           |
| Authentication | Devise (confirmable, rememberable)              |
| Real‑time      | ActionCable                                     |
| Email          | Brevo SMTP (SendGrid compatible)                |
| Search         | Ransack (fuzzy matching with `LIKE`)            |
| Maps           | Google Maps JavaScript API                      |
| Testing        | RSpec (unit), Cucumber (BDD), SimpleCov         |
| CI/CD          | GitHub Actions                                  |
| Deployment     | Google Cloud                                    |

## Setup Instructions

### Prerequisites
- Ruby 3.2+
- Node.js (for Tailwind CSS)

### Clone the repository
```bash
git clone https://github.com/railgun0617/CSCI3100-Project.git
cd CSCI3100-Project
```

### Install dependencies
```bash
bundle install
```

### Configure the database
```bash
rails db:create db:migrate db:seed
```

The seed file creates:
- Default tenants: `Admin`, `Main Campus`, `NA College`
- A staff user for the `Admin` tenant: `admin@cuhk.edu.hk` / `password123`
- Sample venues and equipment.

### Start the local server (Run locally)
```bash
bin/dev   # starts Rails server + Tailwind CSS watcher
```
If Tailwind CSS haven't installed:
```bash
rails tailwindcss:install
```
and then
```bash
rails tailwindcss:watch
```
In another terminal to start server using: 
```bash
rails server
```

The app will be available at `http://localhost:3000`.

## Running the Application

### User roles
- **Student** – Can browse resources, make bookings, view own bookings, cancel bookings.
- **Staff** – Can manage resources (create, edit, delete) within their department, approve/reject bookings, create other staff accounts (if admin).
- **Admin** (tenant “Admin”) – Has full access to all departments and can reassign resources to any tenant.

### Default login credentials
| Role          | Email                          | Password     |
|---------------|--------------------------------|--------------|
| Admin (staff) | `admin@cuhk.edu.hk`            | `password123`|
| Staff         | Create via admin dashboard     |              |
| Student       | Register via sign‑up page      |              |

### Key paths
| Page                      | URL                           |
|---------------------------|-------------------------------|
| Home                      | `/`                           |
| All Resources (public)    | `/resources`                  |
| Venues                    | `/venues`                     |
| Equipment                 | `/equipment`                  |
| My Bookings               | `/bookings`                   |
| Staff Dashboard           | `/staff/dashboard`            |
| Manage Resources (staff)  | `/manage_resources`           |
| Manage Departments (staff)| `/admin/tenants`              |
| Create Staff (staff)      | `/admin/users/new`            |
| Sign in                   | `/users/sign_in`              |
| Sign up                   | `/users/sign_up`              |

## Testing

### Run RSpec (unit tests)
```bash
bundle exec rspec
```

### Run Cucumber (BDD acceptance tests)
```bash
bundle exec cucumber
```

### Coverage report
SimpleCov generates a coverage report after running tests.

The project requires **>80% line coverage** – both rspec and cucumber tests currently met.

## Advanced Features

### Google Maps Integration
- When creating/editing a venue or equipment, an interactive map allows staff to pick the location.
- The selected latitude/longitude is saved and displayed on the resource’s show page.

### Real‑time Updates (ActionCable)
- Staff dashboard subscribes to a `BookingsChannel`.
- When a staff approves/rejects a booking, all connected staff dashboards update instantly.
- Students’ My Bookings page also updates live.

### Email Notifications (SendGrid via Brevo)
- On booking creation: student receives a confirmation email.
- On approval/rejection: student receives an email with the updated status.
- Daily background job (Sidekiq) sends reminders for next‑day bookings.

### Fuzzy Search
- Ransack search on `Venues & Equipment`, `Venues`, `Equipment`, `Manage Resources` and `Manage Departments` pages.
- Searches across name, description, location, and department name.
- Case‑insensitive using `LIKE` (SQLite).

## Feature Ownership

| Feature                             | Primary Developer | Secondary Developer |
|-------------------------------------|-------------------|---------------------|
| User authentication (Devise)        | Li Kwan Ho        | Lam Chun To         |
| Multi‑tenant architecture           | Lam Chun To       | Lin Chung Ho        |
| Venue & Equipment CRUD              | Lam Chun To       | Lin Chung Ho        |
| Booking system                      | Lam Chun To       | Lin Chung Ho        |
| Approval workflow (staff dashboard) | Lam Chun To       | Lin Chung Ho        |
| Conflict detection & availability   | Lin Chung Ho      | Lam Chun To         |
| Models & Validation                 | Lin Chung Ho      | -                   |
| Google Maps integration             | Li Kwan Ho        | -                   |
| ActionCable (Real‑time)             | Lin Chung Ho      | -                   |
| Email notifications (SendGrid)      | Li Kwan Ho        | -                   |
| Fuzzy search (Ransack)              | Li Kwan Ho        | Lam Chun To         |
| UI/UX design & Tailwind CSS         | Lam Chun To       | Chan Pak Ho         |
| Testing (RSpec + Cucumber)          | Chan Pak Ho       | -                   |
| Debugging                           | All members       | -                   |
| Deployment                          | Li Kwan Ho        | -                   |
| CI & CD                             | Lin Chung Ho      | Chan Pak Ho         |

## Team

| Name                | Student ID   | GitHub Username |
|---------------------|--------------|-----------------|
| Li Kwan Ho          | 1155234491   | nncsuki         |
| Chan Pak Ho         | 1155234608   | Jaden280        |
| Lin Chung Ho        | 1155234923   | ForestL06       |
| Lam Chun To         | 1155236012   | railgun0617     |

---

**Questions or issues?** Please open a GitHub issue or contact the team through email 1155236012@link.cuhk.edu.hk / 1155234608@link.cuhk.edu.hk .
