# OmniBird Backend

A Ruby on Rails API service for managing email sequences and integrations with email providers like Google and Microsoft.

## Requirements

- Ruby 3.3.5
- PostgreSQL
- Redis (for production)

## Setup

1. Clone the repository
2. Install dependencies:

```bash
bundle install
```

3. Setup database:

```bash
cp env.example .env  # Create and configure your environment variables
bin/rails db:setup
```

4. Start the server:
```bash
bin/rails server
```

## Features

- Email sequence management
- Integration with Gmail and Microsoft Outlook
- Contact management
- API documentation via Swagger
- Authentication system
- ...

## API Documentation

Once the server is running, visit `http://localhost:3001/swagger` to view the API documentation.

## Testing

Run the test suite:
```bash
bin/rspec
```

## Code Quality

Run the linter:
```bash
bin/rubocop
```

## License

MIT License
