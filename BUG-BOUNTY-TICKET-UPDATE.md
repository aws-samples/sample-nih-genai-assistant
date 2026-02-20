# Bug Bounty Ticket Update - Report 3523640

## Fix Summary
Successfully implemented SourceArn restrictions for all 5 vulnerable Lambda permission resources to prevent confused deputy attacks.

## Branch Information
- **Branch Name**: `security/fix-lambda-permissions-confused-deputy`
- **GitHub URL**: https://github.com/aws-samples/sample-nih-genai-assistant/tree/security/fix-lambda-permissions-confused-deputy
- **Commit**: [Include commit SHA after viewing on GitHub]

## Changes Made

### File Modified
`bucketfiles/nih-grants-lambdas.yaml`

### Lambda Permissions Updated
Added `SourceArn` property to 5 AWS::Lambda::Permission resources:

1. **ConfigNIHQueryGrantsLambdaPermission**
   - Added: `SourceArn: !Sub 'arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:*/*/POST/search'`

2. **ConfigContextHTMLScraperLambdaPermission**
   - Added: `SourceArn: !Sub 'arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:*/*/POST/scrapeURLContext'`

3. **ConfigNIHGrantListS3ArtifactsLambdaPermission**
   - Added: `SourceArn: !Sub 'arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:*/*/POST/listS3Artifacts'`

4. **ConfigNIHGrantCheckTemplateStatusLambdaPermission**
   - Added: `SourceArn: !Sub 'arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:*/*/POST/checkTemplateStatus'`

5. **ConfigNIHModelPromptsLambdaPermission**
   - Added: `SourceArn: !Sub 'arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:*/*/POST/modelPrompts'`

## Testing Results

### Deployment
- **Status**: ✅ Successfully deployed
- **Region**: us-east-1
- **Account**: 688567266976
- **Stack Name**: bug-bounty-report-confused-deputy
- **Deployment Date**: February 11, 2026

### Lambda Resource Policy Verification
All 5 Lambda functions now have SourceArn conditions in their resource policies:

**NIHQueryGrants:**
```json
{
  "Condition": {
    "ArnLike": {
      "AWS:SourceArn": "arn:aws:execute-api:us-east-1:688567266976:*/*/POST/search"
    }
  }
}
```

**ContextHTMLScraper:**
```json
{
  "Condition": {
    "ArnLike": {
      "AWS:SourceArn": "arn:aws:execute-api:us-east-1:688567266976:*/*/POST/scrapeURLContext"
    }
  }
}
```

**NIHGrantListS3Artifacts:**
```json
{
  "Condition": {
    "ArnLike": {
      "AWS:SourceArn": "arn:aws:execute-api:us-east-1:688567266976:*/*/POST/listS3Artifacts"
    }
  }
}
```

**NIHGrantCheckTemplateStatus:**
```json
{
  "Condition": {
    "ArnLike": {
      "AWS:SourceArn": "arn:aws:execute-api:us-east-1:688567266976:*/*/POST/checkTemplateStatus"
    }
  }
}
```

**NIHModelPrompts:**
```json
{
  "Condition": {
    "ArnLike": {
      "AWS:SourceArn": "arn:aws:execute-api:us-east-1:688567266976:*/*/POST/modelPrompts"
    }
  }
}
```

### Security Impact
The SourceArn restrictions now ensure that:
- Lambda functions can ONLY be invoked by API Gateway endpoints within the same AWS account (688567266976)
- Lambda functions can ONLY be invoked by API Gateway endpoints in the same region (us-east-1)
- Lambda functions can ONLY be invoked via the specific HTTP method and path (POST to designated endpoints)
- External API Gateways from other AWS accounts are blocked from invoking these functions
- The confused deputy attack vector is eliminated

## Verification Commands Used
```bash
aws lambda get-policy --function-name NIHQueryGrants --region us-east-1
aws lambda get-policy --function-name ContextHTMLScraper --region us-east-1
aws lambda get-policy --function-name NIHGrantListS3Artifacts --region us-east-1
aws lambda get-policy --function-name NIHGrantCheckTemplateStatus --region us-east-1
aws lambda get-policy --function-name NIHModelPrompts --region us-east-1
```

## Screenshots to Attach
1. CloudFormation stack successful deployment
2. Lambda resource policy for NIHQueryGrants showing SourceArn
3. Lambda resource policy for ContextHTMLScraper showing SourceArn
4. Lambda resource policy for NIHGrantListS3Artifacts showing SourceArn
5. Lambda resource policy for NIHGrantCheckTemplateStatus showing SourceArn
6. Lambda resource policy for NIHModelPrompts showing SourceArn
7. API Gateway test showing legitimate requests still work (optional)

## Request for Review
The fix has been implemented and tested in the security branch. Please review the changes and verify the fix addresses the reported vulnerability. Once approved, the changes will be merged to the main branch.

## Timeline
- **Report Received**: January 25, 2026
- **Fix Committed**: February 11, 2026
- **Fix Deployed & Tested**: February 11, 2026
- **Days to Fix**: 17 days (within 30-day commitment)

## Next Steps
1. VoF team review and verification
2. Upon approval, merge security branch to main
3. Update ticket with merged commit SHA
4. Close vulnerability report
