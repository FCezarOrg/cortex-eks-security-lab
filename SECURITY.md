# Security Policy

## Purpose of This Repository

Cortex EKS Security Lab is an intentionally vulnerable security testing environment.

The repository contains insecure configurations, outdated dependencies, synthetic credentials, and synthetic sensitive data for demonstration and training purposes.

These conditions are intentional and are used to demonstrate cloud-native security capabilities including:

- Application Security
- CSPM
- KSPM
- Cloud Workload Protection
- CIEM
- DSPM
- Attack Path Analysis
- Runtime Security

## Synthetic Credentials

Credentials committed to this repository are intentionally fake and must never provide access to real systems.

Examples include:

- Demo database passwords
- Fake AWS-style credentials
- Fake API keys
- Fake application tokens

Do not replace these values with real credentials.

## Sensitive Data

Any sensitive-data patterns included in this project must be synthetic.

Never upload:

- Customer data
- Production data
- Real financial information
- Real personal information
- Real authentication credentials

## Deployment

Deploy this project only in an isolated AWS account or controlled lab environment.

The infrastructure intentionally creates insecure and potentially Internet-accessible resources.

Do not deploy this project into a production environment.

## Reporting an Unexpected Security Issue

If you identify a security issue that is unrelated to the intentionally vulnerable behavior of the lab, report it privately to the repository owner rather than publishing credentials or sensitive information in a public issue.

## Disclaimer

This project is intended exclusively for authorized security testing, demonstrations, training, and research.
