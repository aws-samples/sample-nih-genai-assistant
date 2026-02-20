# Claude 3.7 Sonnet Deprecation Notice

## Current Status
Your template is using: `us.anthropic.claude-3-7-sonnet-20250219-v1:0`

## Deprecation Timeline
- **Legacy Status**: Claude 3.7 Sonnet is NOW in legacy status
- **End of Life Date**: **April 28, 2026**
- **Action Required**: Migrate to Claude Sonnet 4.5 before April 28, 2026

## Where It's Used
Based on code search, Claude 3.7 Sonnet is referenced in:

1. **bucketfiles/nih-grants-lambdas.yaml** (line 529)
   - IAM policy for Bedrock access
   - ARN: `arn:aws:bedrock:*:${AWS::AccountId}:inference-profile/us.anthropic.claude-3-7-sonnet-20250219-v1:0`

2. **bucketfiles/nih-grants-codebuild.yaml** (line 299)
   - Lambda environment variable MODEL_ID
   - Used by NIHTemplateGen Lambda function

## Recommended Migration

### New Model ID
Replace with: `us.anthropic.claude-sonnet-4-5-20250929-v1:0`

Or use the global cross-region inference profile:
`global.anthropic.claude-sonnet-4-5-20250929-v1:0`

### Key Changes in Claude Sonnet 4.5
1. **Context window**: Expanded from 200K to 1M tokens (beta)
2. **Extended thinking**: Built-in reasoning capabilities (optional, costs extra)
3. **Tool use**: Parallel tool execution with reasoning between calls
4. **Breaking change**: Only supports ONE of temperature OR top_p (not both)
5. **New stop reason**: "refusal" when model declines due to safety policies

### Migration Steps

1. **Update IAM Policy** (bucketfiles/nih-grants-lambdas.yaml):
```yaml
- Fn::Sub:
  - 'arn:aws:bedrock:*:${AWS::AccountId}:inference-profile/us.anthropic.claude-sonnet-4-5-20250929-v1:0'
  - account: !Ref "AWS::AccountId"
```

2. **Update CodeBuild** (bucketfiles/nih-grants-codebuild.yaml):
```yaml
MODEL_ID=arn:aws:bedrock:$AWS_REGION:$AWS_ACCOUNT_ID:inference-profile/us.anthropic.claude-sonnet-4-5-20250929-v1:0
```

3. **Test Lambda Code**:
   - Verify inference parameter usage (temperature OR top_p, not both)
   - Test with existing prompts
   - Check for any new "refusal" stop reasons in responses
   - Consider enabling extended thinking for complex reasoning tasks (optional)

4. **Evaluate Performance**:
   - Run test suite against new model
   - Compare outputs with Claude 3.7 Sonnet
   - Verify cost implications (4.5 may have different pricing)

## Timeline Recommendation

Given that:
- Claude 3.7 EOL is April 28, 2026
- You're currently fixing a security issue
- This is sample/educational code

**Suggested approach:**
1. Fix security issue first (current priority)
2. Create separate issue/PR for model migration
3. Target migration completion by March 2026 (1 month buffer before EOL)

## References
- [AWS Blog: Migrate to Claude Sonnet 4.x](https://aws.amazon.com/blogs/machine-learning/migrate-from-anthropics-claude-sonnet-3-x-to-claude-sonnet-4-x-on-amazon-bedrock/)
- [Anthropic Model Deprecations](https://docs.anthropic.com/en/docs/resources/model-deprecations)
- [AWS Bedrock Claude Models](https://aws.amazon.com/bedrock/claude/)

## Action Items
- [ ] Create GitHub issue for model migration
- [ ] Schedule testing window for Claude Sonnet 4.5
- [ ] Update documentation with new model requirements
- [ ] Test Lambda functions with new model
- [ ] Update CloudFormation templates
- [ ] Deploy and verify in test environment
- [ ] Update production before April 28, 2026
