# Workspace QA Cleanup Rule

- QA screenshots, rendered comparison images, temporary QA reports, and other verification-only artifacts must be deleted by the agent immediately after verification is complete.
- Do not leave files such as `qa-*.png`, `qa-*.jpg`, `qa-*.webp`, or `design-qa.md` in the workspace after the final QA result has been recorded in the user-facing response.
- Preserve production assets and user-created files. Only remove artifacts created by the agent for temporary verification.
