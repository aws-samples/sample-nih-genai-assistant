# AWS Amplify v6 Migration Guide

## Overview
The UI build is failing due to AWS Amplify v6 breaking changes. The code uses v5 import syntax but package.json specifies v6.

## Current Error
```
[vite]: Rollup failed to resolve import "@aws-amplify/auth" from "/root/ui/src/Components/Admin/index.jsx"
```

## Root Cause
- **package.json** specifies: `"aws-amplify": "^6.0.12"`
- **Code** uses v5 imports: `import { Auth } from '@aws-amplify/auth'`
- AWS Amplify v6 changed the import structure and API

## Why This Started Failing
The package.json uses `"latest"` and `^` version ranges, which means dependencies auto-update:
```json
"@aws-amplify/ui-react": "latest",
"vite": "^6.0.11"
```

When CodeBuild runs `npm install`, it pulls the newest compatible versions, which may have breaking changes.

## Solution Options

### Option 1: Update Code to Amplify v6 (Recommended)
Modernize the codebase to use the latest Amplify version.

### Option 2: Downgrade to Amplify v5 (Quick Fix)
Lock to the older version that the code was written for.

---

## Option 1: Update to Amplify v6 (Recommended)

### Files to Modify
Located in `nih-bot-raw.zip` (extract, modify, rezip, upload to S3)

### Step 1: Identify Files with Old Imports
```bash
# Extract the zip
unzip nih-bot-raw.zip

# Find all files importing from @aws-amplify
grep -r "@aws-amplify" src/ --include="*.jsx" --include="*.js"
```

### Step 2: Update Import Statements

**Old v5 Syntax:**
```javascript
import { Auth } from '@aws-amplify/auth';
import { Storage } from '@aws-amplify/storage';
import { API } from '@aws-amplify/api';
```

**New v6 Syntax:**
```javascript
import { fetchAuthSession, signOut, signIn, getCurrentUser } from 'aws-amplify/auth';
import { uploadData, getUrl, remove } from 'aws-amplify/storage';
import { get, post, put, del } from 'aws-amplify/api';
```

### Step 3: Update API Calls

**Authentication Changes:**

Old v5:
```javascript
// Get current user
const user = await Auth.currentAuthenticatedUser();

// Sign out
await Auth.signOut();

// Get session
const session = await Auth.currentSession();
const token = session.getIdToken().getJwtToken();
```

New v6:
```javascript
// Get current user
const { username, userId, signInDetails } = await getCurrentUser();

// Sign out
await signOut();

// Get session
const { tokens } = await fetchAuthSession();
const token = tokens.idToken.toString();
```

**Storage Changes:**

Old v5:
```javascript
// Upload
await Storage.put('filename.txt', file, {
  contentType: 'text/plain'
});

// Download
const url = await Storage.get('filename.txt');
```

New v6:
```javascript
// Upload
await uploadData({
  key: 'filename.txt',
  data: file,
  options: {
    contentType: 'text/plain'
  }
}).result;

// Download
const { url } = await getUrl({ key: 'filename.txt' });
```

**API Changes:**

Old v5:
```javascript
const response = await API.get('apiName', '/path', {
  headers: { Authorization: token }
});
```

New v6:
```javascript
const { body } = await get({
  apiName: 'apiName',
  path: '/path',
  options: {
    headers: { Authorization: token }
  }
}).response;
const response = await body.json();
```

### Step 4: Update Amplify Configuration

**Old v5 (aws-exports.js):**
```javascript
import Amplify from 'aws-amplify';
import awsconfig from './aws-exports';

Amplify.configure(awsconfig);
```

**New v6:**
```javascript
import { Amplify } from 'aws-amplify';
import awsconfig from './aws-exports';

Amplify.configure(awsconfig);
```

### Step 5: Repackage and Deploy

```bash
# Rezip the updated code
zip -r nih-bot-raw.zip . -x "*.DS_Store" -x "node_modules/*" -x "dist/*"

# Upload to S3
aws s3 cp nih-bot-raw.zip s3://scotth-the-researcher-bucket-us-east-1/

# Trigger CodeBuild (or it will trigger automatically on next stack update)
```

---

## Option 2: Downgrade to Amplify v5 (Quick Fix)

### Step 1: Update package.json

**Current:**
```json
{
  "dependencies": {
    "aws-amplify": "^6.0.12",
    "@aws-amplify/ui-react": "latest"
  }
}
```

**Updated:**
```json
{
  "dependencies": {
    "aws-amplify": "5.3.12",
    "@aws-amplify/auth": "5.6.5",
    "@aws-amplify/storage": "5.9.5",
    "@aws-amplify/api": "5.4.5",
    "@aws-amplify/ui-react": "5.3.2"
  }
}
```

### Step 2: Lock All Dependency Versions

Replace all `"latest"` and `^` with specific versions:

```json
{
  "dependencies": {
    "@aws-amplify/ui-react": "5.3.2",
    "@awsui/components-react": "3.0.600",
    "@awsui/global-styles": "1.0.32",
    "vite": "6.0.11"
  }
}
```

### Step 3: Repackage and Deploy

```bash
# Rezip with updated package.json
zip -r nih-bot-raw.zip . -x "*.DS_Store" -x "node_modules/*" -x "dist/*"

# Upload to S3
aws s3 cp nih-bot-raw.zip s3://scotth-the-researcher-bucket-us-east-1/

# Trigger CodeBuild
```

---

## Testing After Fix

1. **Verify CodeBuild Success:**
   ```bash
   aws codebuild list-builds-for-project \
     --project-name nih-grants-codebuild \
     --region us-east-1
   ```

2. **Check Build Logs:**
   - Look for successful `npm run build`
   - Verify `nih-bot-amplify-build.zip` created

3. **Test UI Deployment:**
   - Deploy to Amplify
   - Verify authentication works
   - Test file uploads
   - Test API calls

---

## Recommended Approach

**Phase 1: Security Fix (Current)**
- Merge confused deputy fix to main
- Don't worry about UI build for now

**Phase 2: Maintenance Release**
- Create new branch: `feature/amplify-v6-migration`
- Update to Amplify v6 (Option 1)
- Update to Claude Sonnet 4.5 (from MODEL-MIGRATION-GUIDE.md)
- Test thoroughly
- Merge to main

**Phase 3: Lock Dependencies**
- Replace all `"latest"` with specific versions
- Create package-lock.json for reproducible builds
- Document tested dependency versions

---

## Timeline

- **Security Fix**: Merge now (UI build not critical for Lambda security)
- **Amplify v6 Migration**: Target March 2026
- **Claude 4.5 Migration**: Target March 2026 (before April 28 EOL)

---

## References

- [AWS Amplify v6 Migration Guide](https://docs.amplify.aws/javascript/build-a-backend/auth/moving-to-production/)
- [Amplify v6 Breaking Changes](https://docs.amplify.aws/javascript/build-a-backend/auth/concepts/migration/)
- [Amplify v6 Auth API](https://docs.amplify.aws/javascript/build-a-backend/auth/)
- [Amplify v6 Storage API](https://docs.amplify.aws/javascript/build-a-backend/storage/)

---

## Notes

- The UI build failure does NOT affect the Lambda security fix
- The Lambda functions work independently of the UI
- The UI is deployed separately via Amplify
- CodeBuild failure only prevents UI updates, not Lambda deployments
