# Final Project Test Results

## F1 — Initial deployment
The pipeline built and pushed the three images, deployed dev,
and waited for approval before deploying prod.
Both environments passed smoke and version checks.
Voting was verified through the result page.

## F2 — Environment separation
Changed option_a to Pizza in dev.tfvars only.
The dev plan showed OPTION_A changing to Pizza.
The prod plan did not change OPTION_A.
After deployment, dev showed Pizza and prod kept the original option.

## F3 — Application update
Changed the vote page heading to Voting App v2.
The pipeline built new images.
The dev health endpoint returned HTTP 200 throughout the monitored deployment.
Prod waited for approval and received the same image tag.
The new heading was verified in both environments.

## F4 — Failed deployment and rollback
Added an intentional startup failure to vote/app.py.
The dev deployment rolled back to the previous working task definition.
The apply and smoke test succeeded, but Verify deployed version failed
with exit code 2 because the running task definition differed from the desired one.
Prod deployment was skipped.

The first monitoring attempt had DNS resolution timeouts in the local VM.
After temporarily changing the VM DNS configuration, the test was repeated.
The monitoring returned HTTP 200 throughout the repeated test.

The intentional failure was then removed through a pull request.
The recovery pipeline successfully deployed dev and prod.

## F5 — Cleanup
Terraform destroy completed successfully in this order:
- prod: 43 resources destroyed.
- dev: 43 resources destroyed.
- bootstrap: 13 resources destroyed.

No RDS automated backups remained in eu-north-1.
