# Security Fix Testing & Verification Checklist

## Pre-Deployment
- [ ] Ensure you're on the security branch: `git checkout security/fix-lambda-permissions-confused-deputy`
- [ ] Verify the fix in local file: `bucketfiles/nih-grants-lambdas.yaml` shows SourceArn for all 5 permissions
- [ ] Sync bucketfiles to S3: `aws s3 sync bucketfiles s3://nih-genai-<your-bucket>/`

## CloudFormation Deployment
- [ ] Deploy/update CloudFormation stack using `root.yaml`
- [ ] Wait for stack UPDATE_COMPLETE status
- [ ] Screenshot: CloudFormation Events tab showing successful update
- [ ] Screenshot: CloudFormation Resources tab showing the 5 Lambda functions

## Lambda Resource Policy Verification
For EACH of the 5 Lambda functions, verify and capture screenshots:

### 1. NIHQueryGrants
- [ ] Navigate to: Lambda Console → NIHQueryGrants → Configuration → Permissions
- [ ] Click on Resource-based policy statements
- [ ] Screenshot showing policy includes:
  - Principal: apigateway.amazonaws.com
  - SourceArn: `arn:aws:execute-api:${Region}:${Account}:*/*/POST/search`

### 2. ContextHTMLScraper
- [ ] Navigate to: Lambda Console → ContextHTMLScraper → Configuration → Permissions
- [ ] Click on Resource-based policy statements
- [ ] Screenshot showing policy includes:
  - Principal: apigateway.amazonaws.com
  - SourceArn: `arn:aws:execute-api:${Region}:${Account}:*/*/POST/scrapeURLContext`

### 3. NIHGrantListS3Artifacts
- [ ] Navigate to: Lambda Console → NIHGrantListS3Artifacts → Configuration → Permissions
- [ ] Click on Resource-based policy statements
- [ ] Screenshot showing policy includes:
  - Principal: apigateway.amazonaws.com
  - SourceArn: `arn:aws:execute-api:${Region}:${Account}:*/*/POST/listS3Artifacts`

### 4. NIHGrantCheckTemplateStatus
- [ ] Navigate to: Lambda Console → NIHGrantCheckTemplateStatus → Configuration → Permissions
- [ ] Click on Resource-based policy statements
- [ ] Screenshot showing policy includes:
  - Principal: apigateway.amazonaws.com
  - SourceArn: `arn:aws:execute-api:${Region}:${Account}:*/*/POST/checkTemplateStatus`

### 5. NIHModelPrompts
- [ ] Navigate to: Lambda Console → NIHModelPrompts → Configuration → Permissions
- [ ] Click on Resource-based policy statements
- [ ] Screenshot showing policy includes:
  - Principal: apigateway.amazonaws.com
  - SourceArn: `arn:aws:execute-api:${Region}:${Account}:*/*/POST/modelPrompts`

## Functional Testing
Test that legitimate API Gateway calls still work:

### Test 1: Search Endpoint (NIHQueryGrants)
- [ ] Navigate to: API Gateway Console → nihGrantsApi → Resources → /search → POST
- [ ] Test with valid Cognito authorization token
- [ ] Screenshot showing successful 200 response
- [ ] Verify Lambda was invoked successfully

### Test 2: Model Prompts Endpoint (NIHModelPrompts)
- [ ] Navigate to: API Gateway Console → nihGrantsApi → Resources → /modelPrompts → POST
- [ ] Test with valid Cognito authorization token
- [ ] Screenshot showing successful 200 response
- [ ] Verify Lambda was invoked successfully

### Test 3: List Artifacts Endpoint (NIHGrantListS3Artifacts)
- [ ] Navigate to: API Gateway Console → nihGrantsApi → Resources → /listS3Artifacts → POST
- [ ] Test with valid Cognito authorization token
- [ ] Screenshot showing successful 200 response
- [ ] Verify Lambda was invoked successfully

## Security Verification (Optional but Recommended)
- [ ] Attempt to invoke Lambda directly from a different API Gateway (should fail)
- [ ] Screenshot showing access denied error

## Documentation for Ticket
Prepare the following for bug bounty ticket:

### Screenshots to Attach:
- [ ] CloudFormation stack update success (Events tab)
- [ ] CloudFormation Resources tab showing 5 Lambda functions
- [ ] Resource policy for NIHQueryGrants with SourceArn
- [ ] Resource policy for ContextHTMLScraper with SourceArn
- [ ] Resource policy for NIHGrantListS3Artifacts with SourceArn
- [ ] Resource policy for NIHGrantCheckTemplateStatus with SourceArn
- [ ] Resource policy for NIHModelPrompts with SourceArn
- [ ] Successful API Gateway test (at least 1 endpoint)

### Ticket Update Content:
- [ ] Branch reference: `security/fix-lambda-permissions-confused-deputy`
- [ ] GitHub branch link: https://github.com/aws-samples/sample-nih-genai-assistant/tree/security/fix-lambda-permissions-confused-deputy
- [ ] Description of fix applied
- [ ] Testing results summary
- [ ] All screenshots attached
- [ ] Request for VoF team review and verification

### Ticket Status Update:
- [ ] Set status to "Pending"
- [ ] Set pending reason to "Verification of fix"
- [ ] Add "AWS ITSec Pen-Test Engineers" group to ticket permissions

## Post-Approval (After VoF Team Approves)
- [ ] Merge security branch to main:
  ```bash
  git checkout main
  git merge security/fix-lambda-permissions-confused-deputy
  git push origin main
  ```
- [ ] Update ticket with merged commit SHA
- [ ] Confirm fix is deployed to production/main branch

## Notes
- Region used for testing: _______________
- AWS Account ID: _______________
- CloudFormation Stack Name: _______________
- Deployment Date: _______________
- Tester: _______________
