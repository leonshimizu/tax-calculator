# Tax Calculator Application

This repository contains the backend for the Tax Calculator application, which is built with Ruby on Rails. The backend integrates with a Ruby script for Excel file processing and communicates with a React.js frontend.

## Table of Contents

- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
  - [Ruby Setup](#ruby-setup)
  - [Rails Setup](#rails-setup)
- [Running the Application](#running-the-application)
- [Deployment](#deployment)
- [Additional Information](#additional-information)

## Getting Started

To get a local copy up and running, follow these simple steps.

## Prerequisites

Make sure you have the following installed on your machine:

- **Homebrew** (macOS)
- **rbenv** or **RVM** for managing Ruby versions

## Setup Instructions

### Ruby Setup

1. **Install Homebrew** (macOS only):

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install rbenv and ruby-build**:

   ```bash
   brew install rbenv ruby-build
   ```

3. **Initialize rbenv**:

   ```bash
   rbenv init
   ```

4. **Update your shell configuration**:

   ```bash
   echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
   source ~/.zshrc
   ```

5. **Install Ruby 3.2.3**:

   ```bash
   rbenv install 3.2.3
   ```

6. **Set the global Ruby version**:

   ```bash
   rbenv global 3.2.3
   ```

   Alternatively, to set the Ruby version locally for this app only:

   ```bash
   rbenv local 3.2.3
   ```

7. **Verify the Ruby version**:

   ```bash
   ruby -v
   ```

8. **Install Bundler**:

   ```bash
   gem install bundler
   ```

9. **Rehash rbenv shims**:

   ```bash
   rbenv rehash
   ```

### Rails Setup

1. **Install project dependencies**:

   ```bash
   bundle install
   ```

2. **Set up the database**:

   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

3. **Reset the database** (if needed):

   ```bash
   rails db:drop db:create db:migrate db:schema:cache:clear db:seed
   ```

## Running the Application

1. **Start the Rails server**:

   ```bash
   rails server
   ```

2. **Access the application**:

   Open your browser and navigate to `http://localhost:3000`.

## Deployment

This application is automatically deployed to Render when commits are pushed to the main branch.

- **Backend** is hosted at [tax-calculator-2-0.onrender.com](https://tax-calculator-2-0.onrender.com).
- **Frontend** is hosted at [tax-calculator-frontend-2-0.onrender.com](https://tax-calculator-frontend-2-0.onrender.com).
- **Database** is hosted at [Render PostgreSQL Dashboard](https://dashboard.render.com/d/dpg-cr1ceq23esus73at4vtg-a/info).

## Additional Information

- **Frontend Code Repository**: [GitHub Repository](https://github.com/leonshimizu/tax-calculator-frontend)
- **Automatic Deployments**: Changes pushed to the main branch are automatically deployed online.
