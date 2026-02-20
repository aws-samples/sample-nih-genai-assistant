# Security Fix Summary - Authentication Bypass Vulnerability

## Bug Bounty Report ID: 3523640

## Vulnerability Description
Five Lambda functions had overly permissive resource policies allowing any API Gateway in any AWS account to invoke them, bypassing Cognito authentication. This is a "confused deputy" attack vulnerability.

## Affected Lambda Functions
1. NIHQueryGrants
2. NIHModelPrompts  
3. NIHGrantListS3Artifacts
4. ContextHTMLScraper
5. NIHGrantCheckTemplateStatus

## Fix Applied
Added `SourceArn` property to all 5 AWS::Lambda::Permission resources in `bucketfiles/nih-grants-lambdas.yaml`.

## Files Modified
- `bucketfiles/nih-grants-lambdas.yaml` - Added SourceArn to 5 Lambda permissions

## Files Verified (Already Secure)
- `bucketfiles/nih-grants-ws-api.yaml` - WebSocket API permissions already have SourceArn
- `bucketfiles/nih-grants-s3.yaml` - S3 Lambda permissions already have SourceAccount

### Changes Made:

**ConfigNIHQueryGrantsLambdaPermission:**
- Added: `SourceArn: !Sub 'arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:*/*/POST/search'`

**ConfigContextHTMLScraperLambdaPermission:**
- Added: `SourceArn: !Sub 'arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:*/*/POST/scrapeURLContext'`

**ConfigNIHGrantListS3ArtifactsLambdaPermission:**
- Added: `SourceArn: !Sub 'arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:*/*/POST/listS3Artifacts'`

**ConfigNIHGrantCheckTemplateStatusLambdaPermission:**
- Added: `SourceArn: !Sub 'arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:*/*/POST/checkTemplateStatus'`

**ConfigNIHModelPromptsLambdaPermission:**
- Added: `SourceArn: !Sub 'arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:*/*/POST/modelPrompts'`

## How the Fix Works
The SourceArn restricts Lambda invocation to only the specific API Gateway endpoints in the same AWS account and region. The pattern `*/*/POST/<path>` means:
- First `*` = any API Gateway stage
- Second `*` = any API Gateway REST API ID  
- `POST/<path>` = specific HTTP method and resource path

This prevents external API Gateways from other accounts from invoking these functions.

## Testing Instructions
1. Sync bucketfiles to your S3 bucket: `aws s3 sync bucketfiles s3://nih-genai-<your-bucket>/`
2. Deploy the CloudFormation stack using `root.yaml`
3. Verify Lambda resource policies now include SourceArn conditions
4. Test that legitimate API Gateway calls still work through Cognito authentication
5. Verify that external API Gateway attempts are blocked

## Ticket Process (Based on Correspondence)

### Before Submitting for Verification:
1. **Test the fix** - Deploy and verify it works correctly
2. **Document the fix** - Provide detailed description in ticket correspondence
3. **Reference artifacts** - Link to GitHub commit/PR as related resource
4. **Set ticket status** - Change to "Pending" with reason "Verification of fix"
5. **Ensure access** - Add "AWS ITSec Pen-Test Engineers" group to ticket permissions

### Who Should Review:
- Your AppSec affinity engineer (for technical guidance)
- The VoF (Verification of Fix) team will review after submission
- AWS Bug Bounty team (@mtkunz mentioned in correspondence)

### Timeline:
- Fix-by date committed: Within 30 days (as stated in correspondence)
- VoF processing based on severity, need-by date, and backlog

### Verification Portal:
Submit through: Verification of Fix Portal (mentioned in correspondence)
Track at: "My Submitted Tickets"

## Additional Notes
- This is sample/educational code with explicit non-production disclaimers
- Severity rated as "Low" due to limited real-world impact
- Fix aligns with AWS best practices for preventing confused deputy attacks
