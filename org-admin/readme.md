# Org Admin Request and Management Pipeline

This repository provides a GitHub Actions-based pipeline to manage organization admin access. The pipeline includes workflows for both promoting and demoting users based on request files and expiration times.

## Overview

- **Org Admin Request:**  
  Users can request temporary organization admin access by creating a new JSON file in the `org-admin` directory. Rename the provided template to `new-request.json` and fill in the required details (username, duration in hours, and reason for the request).

- **Promotion Workflow:**  
  When a new request file is added or modified under the `org-admin` directory, the promotion workflow validates the request, verifies that the user is a member of the organization, and promotes the user to org admin for the specified duration.

- **Demotion Workflow:**  
  A scheduled demotion workflow runs periodically to check for expired admin requests. Expired requests trigger a demotion of the user (changing their role back to member) and the removal of the request file from the repository.

## Pipeline Components

### Request Template

To request org admin access, use the provided template:

```json
{
  "username": "githubUserName",
  "duration": 3,
  "reason": "Need to create a new repo"
}
```

### Promotion Workflow

- **Trigger:**
  The promotion workflow is triggered on push events that affect JSON files in the `org-admin` directory.

- **Steps:**
  - **Checkout Repository:** Uses the latest version of the repository.
  - **Collect Request Files:** Scans the `org-admin` directory for JSON files and extracts the username from each file.
  - **Generate GitHub App Token:** Uses a composite action to create a GitHub App token.
  - **Authenticate with GitHub CLI:** Sets up authentication using the generated token.
  - **Promote User:** For each valid request, the workflow verifies organization membership via the GitHub API and promotes the user to org admin using the GitHub CLI.

### Demotion Workflow

- **Trigger:**
  The demotion workflow runs on a schedule (e.g., every hour).

- **Steps:**
  - **Checkout Repository:** Clones the repository with full history.
  - **Process Expired Requests:** Iterates over JSON files in `org-admin`, checking if each request has expired based on the file's commit timestamp and the specified duration.
  - **Demote User:** For expired requests, the workflow demotes the user by updating their org membership to "member" and removes the corresponding request file.
  - **Commit and Push Changes:** Commits and pushes the changes back to the repository, using the appropriate authentication to bypass branch protection rules when configured.

## Conclusion

This pipeline streamlines the process of granting and revoking temporary org admin access through automated workflows. By using consistent configurations and robust processes, it minimizes manual intervention and ensures secure, controlled access.
