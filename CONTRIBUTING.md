# CONTRIBUTING.md

## Getting Started

1. Fork the repository
2. Clone your fork
3. Create a feature branch: `git checkout -b feature/your-feature`
4. Make your changes
5. Commit with descriptive messages: `git commit -m "Add feature"`
6. Push to your fork: `git push origin feature/your-feature`
7. Open a Pull Request

## Development Setup

### Local Development
```bash
./scripts/setup-local.sh
```

### Running Services
```bash
# Run all services
docker-compose up -d

# Run a specific service
docker-compose up -d auth-service

# View logs
docker-compose logs -f
```

## Code Standards

- **Node.js**: Follow ES6+ conventions
- **React**: Use functional components with hooks
- **Database**: Use prepared statements to prevent SQL injection
- **API**: Follow REST conventions
- **Error Handling**: Always return meaningful error messages

## Testing

### Backend
```bash
cd backend
npm test
```

### Frontend
```bash
cd frontend
npm test
```

## Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

## Pull Request Process

1. Update README.md with any new features
2. Update DEPLOYMENT.md if infrastructure changes
3. Add tests for new features
4. Ensure all tests pass
5. Get approval from maintainers

## Reporting Bugs

When reporting a bug, please include:
- Steps to reproduce
- Expected behavior
- Actual behavior
- Your environment (OS, Node version, etc.)

## Feature Requests

Feature requests are welcome! Please describe:
- Use case
- Expected behavior
- Possible implementation
- Benefits
