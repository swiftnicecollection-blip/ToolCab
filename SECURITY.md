# Security Policy

## Reporting Security Issues

If you discover a security vulnerability in ToolCab, please report it responsibly.

**Do not** publicly disclose the issue until it has been addressed.

To report a security issue:

1. Open a private issue or contact the maintainers directly
2. Provide a detailed description of the vulnerability
3. Include steps to reproduce if possible
4. Suggest a fix if you have one

## Security Best Practices

When contributing to ToolCab, please follow these guidelines:

### Do Not Commit Secrets

- Never commit API keys, tokens, or credentials
- Never commit private keys or certificates
- Use environment variables for sensitive configuration

### Dependency Management

- Keep dependencies updated
- Review security advisories for packages used
- Run `flutter pub outdated` regularly

### Data Handling

- ToolCab stores data locally on the device
- No user data is transmitted to external servers
- Implement proper input validation for user-provided content

### Code Review

- All code changes undergo review
- Security-sensitive changes receive additional scrutiny

## Current Security Status

ToolCab is designed with privacy in mind:

- No authentication system (no passwords stored)
- No external API calls for user data
- Local-only storage using Hive
- No analytics or tracking

## Updates

This security policy may be updated as the project evolves. Check back for the latest version.
