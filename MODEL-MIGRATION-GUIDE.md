# Claude 3.7 Sonnet to Claude Sonnet 4.5 Migration Guide

## Overview
This guide documents the changes needed to migrate from Claude 3.7 Sonnet to Claude Sonnet 4.5 before the April 28, 2026 EOL date.

## Files Requiring Changes

### 1. bucketfiles/nih-grants-codebuild.yaml (Line 299)

**Current:**
```yaml
- aws lambda create-function --function-name NIHTemplateGen --code ImageUri=$AWS_ECR_REPOSITORY_URI:$IMAGE_TAG --package-type Image --role $LAMBDAROLEARN --timeout 900 --memory-size 3008 --environment Variables="{DDB_TABLE=nih-grants-table, MODEL_ID=arn:aws:bedrock:$AWS_REGION:$AWS_ACCOUNT_ID:inference-profile/us.anthropic.claude-3-7-sonnet-20250219-v1:0, REGION=$AWS_REGION, S3_OUTPUT_BUCKET=$NIHCONTEXTBUCKET, MODEL_OUTOUT_TOKENS=16000, MODEL_REGION=$AWS_REGION, WS_DDB_TABLE=nih-ws-table, WS_ENDPOINT=$WSENDPOINT, AK=$AK}"
```

**Updated:**
```yaml
- aws lambda create-function --function-name NIHTemplateGen --code ImageUri=$AWS_ECR_REPOSITORY_URI:$IMAGE_TAG --package-type Image --role $LAMBDAROLEARN --timeout 900 --memory-size 3008 --environment Variables="{DDB_TABLE=nih-grants-table, MODEL_ID=arn:aws:bedrock:$AWS_REGION:$AWS_ACCOUNT_ID:inference-profile/us.anthropic.claude-sonnet-4-5-20250929-v1:0, REGION=$AWS_REGION, S3_OUTPUT_BUCKET=$NIHCONTEXTBUCKET, MODEL_OUTOUT_TOKENS=16000, MODEL_REGION=$AWS_REGION, WS_DDB_TABLE=nih-ws-table, WS_ENDPOINT=$WSENDPOINT, AK=$AK}"
```

**Change:** Replace `us.anthropic.claude-3-7-sonnet-20250219-v1:0` with `us.anthropic.claude-sonnet-4-5-20250929-v1:0`

### 2. bucketfiles/nih-grants-lambdas.yaml (Line 529)

**Current:**
```yaml
- Fn::Sub:
  - 'arn:aws:bedrock:*:${AWS::AccountId}:inference-profile/us.anthropic.claude-3-7-sonnet-20250219-v1:0'
  - account: !Ref "AWS::AccountId"
```

**Updated:**
```yaml
- Fn::Sub:
  - 'arn:aws:bedrock:*:${AWS::AccountId}:inference-profile/us.anthropic.claude-sonnet-4-5-20250929-v1:0'
  - account: !Ref "AWS::AccountId"
```

**Change:** Replace `us.anthropic.claude-3-7-sonnet-20250219-v1:0` with `us.anthropic.claude-sonnet-4-5-20250929-v1:0`

## Alternative: Use Global Cross-Region Inference

For better availability and throughput, consider using the global inference profile:

**CodeBuild:**
```yaml
MODEL_ID=arn:aws:bedrock:$AWS_REGION:$AWS_ACCOUNT_ID:inference-profile/global.anthropic.claude-sonnet-4-5-20250929-v1:0
```

**IAM Policy:**
```yaml
- Fn::Sub:
  - 'arn:aws:bedrock:*:${AWS::AccountId}:inference-profile/global.anthropic.claude-sonnet-4-5-20250929-v1:0'
  - account: !Ref "AWS::AccountId"
```

## Lambda Code Changes (If Applicable)

If the NIHTemplateGen Lambda code directly references inference parameters, ensure:

### Breaking Change: Temperature vs Top_P
Claude Sonnet 4.5 only supports ONE of `temperature` OR `top_p`, not both.

**Before (Claude 3.7):**
```python
response = bedrock_runtime.invoke_model(
    modelId=model_id,
    body=json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 16000,
        "temperature": 0.7,
        "top_p": 0.9,  # Both allowed in 3.7
        "messages": messages
    })
)
```

**After (Claude Sonnet 4.5):**
```python
response = bedrock_runtime.invoke_model(
    modelId=model_id,
    body=json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 16000,
        "temperature": 0.7,  # Choose ONE
        # "top_p": 0.9,  # Remove this
        "messages": messages
    })
)
```

### New Stop Reason: Refusal
Handle the new "refusal" stop reason:

```python
if response['stop_reason'] == 'refusal':
    # Model declined to generate content due to safety policies
    # Reset conversation context or handle appropriately
    pass
```

## Optional: Enable Extended Thinking

For complex reasoning tasks, you can enable extended thinking (costs extra):

```python
response = bedrock_runtime.converse(
    modelId='us.anthropic.claude-sonnet-4-5-20250929-v1:0',
    messages=[{'role': 'user', 'content': [{'text': "Your prompt here"}]}],
    inferenceConfig={'maxTokens': 2048},
    additionalModelRequestFields={
        "thinking": {
            "type": "enabled",
            "budget_tokens": 1024
        }
    }
)

# Access reasoning
reasoning_text = response['output']['message']['content'][0]['reasoningContent']['reasoningText']['text']
assistant_response = response['output']['message']['content'][1]['text']
```

## Testing Checklist

- [ ] Update both YAML files with new model ID
- [ ] Sync bucketfiles to S3
- [ ] Trigger CodeBuild to rebuild NIHTemplateGen Lambda
- [ ] Verify Lambda environment variable shows new MODEL_ID
- [ ] Test template generation with sample prompts
- [ ] Compare outputs with Claude 3.7 baseline
- [ ] Verify no errors related to inference parameters
- [ ] Check CloudWatch logs for any "refusal" stop reasons
- [ ] Monitor costs (Claude Sonnet 4.5 may have different pricing)
- [ ] Load test to ensure performance meets requirements

## Rollback Plan

If issues arise:

1. Revert both YAML files to Claude 3.7 model ID
2. Sync bucketfiles to S3
3. Trigger CodeBuild to rebuild Lambda
4. Verify rollback successful

Keep Claude 3.7 configuration until April 2026 if needed.

## Timeline

- **Now - Feb 2026**: Plan and prepare migration
- **March 2026**: Execute migration and testing
- **April 28, 2026**: Claude 3.7 Sonnet EOL - must be migrated by this date

## References

- [AWS Blog: Migrate to Claude Sonnet 4.x](https://aws.amazon.com/blogs/machine-learning/migrate-from-anthropics-claude-sonnet-3-x-to-claude-sonnet-4-x-on-amazon-bedrock/)
- [Anthropic Model Deprecations](https://docs.anthropic.com/en/docs/resources/model-deprecations)
- [Claude 4 Prompt Engineering Best Practices](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering)
- [Extended Thinking Documentation](https://docs.anthropic.com/en/docs/build-with-claude/extended-thinking)
