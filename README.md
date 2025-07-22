# NIH Grant Assistant CloudFormation Nested Stack

> **Note**: This is sample code for non-production usage. You should work with your security and legal teams to meet your organizational security, regulatory, and compliance requirements before deployment.

## Important Disclaimers
- The stack that these templates create are for demonstration purposes only
- It should be deployed in a non-production account with no other resources
- The delete-script associated with the root stack will remove AWS services associated with it
- The Stack is restricted to a single region in each AWS account
- The Stack will create resources that will incur costs
- The latest Firefox browser is recommended for optimal experience
- We use GitHub Issues to track ideas, feedback, tasks, or bugs
- It is recommended you get help from your account SA to deploy and delete the nested stacks
- Review the LICENSE file, all files in this repo fall under those terms

# Contents
- [Architecture](#architecture)
- [Account Setup](#account-setup)
- [Enable Bedrock in a Region](#enable-bedrock-in-a-region)
- [Deployment](#deployment)
- [Post CloudFormation Steps](#post-cloudformation-steps)
- [Deleting the Stack](#deleting-the-stack)
- [Lambda Memory Sizing](#lambda-memory-sizing)
- [Accessing OpenSearch Dashboard](#accessing-opensearch-dashboard)
- [Operations](#operations)
- [Cost](#costs)
- [Errors](#errors)

# Architecture
![Architecture Diagram](./documentation/Arch-01.png)

# Account Setup
The preferred set up is to create a new account in your Organization and add an Identity Center user to that account with the AdministratorAccess permission set.

# Enable Bedrock in a Region
1. Login to your AWS account that has the AdministratorAccess policy
2. From AWS Console, navigate to Bedrock in us-east-1 or us-west-2
3. Select "Enable Selected Models" and enable the Anthropic models
   
   ![Bedrock Access](./documentation/BedrockAccess-1.png)

# Deployment
1. Login to your AWS account that has the AdministratorAccess policy
2. Create an S3 bucket in the REGION you will deploy the stack to (us-east-1 or us-west-2). An example bucket name would be `[AWS Account #]-researcher-cloudformation-bucket-[AWS REGION]`. Remember bucket names must be unique; adding your AWS account number and deployment region to the bucket name will help make it unique.
3. Upload all files from the `bucketfiles` directory in the git repo into the root of the bucket you created above.
4. From the CloudFormation console, deploy the `root.yaml` - see screenshots below.
5. Verify you are in the correct region!

> **Note**: Average time to deploy all stacks and for CodeBuild to finish is about 25 minutes.

![CloudFormation Start](./documentation/CloudFormation-Start.png)
![CloudFormation Start 1](./documentation/CloudFormation-Start1.png)

### Create a new Stack
![CloudFormation Create New](./documentation/CloudFormation-CreateNew.png)

### Upload the root.yaml template from the repo
![CloudFormation Upload Root Template](./documentation/CloudFormation-UploadRootTemplate.png)

### Enter the Stack Details
Give the stack a name (e.g. genai-stack) and enter the bucket name you created earlier as parameters.

![CloudFormation Stack Details](./documentation/CloudFormation-StackDetails.png)

### Enter the Stack Options
![CloudFormation Stack Options](./documentation/CloudFormation-StackOptions.png)

### Acknowledge Stack Creation of Resources
![CloudFormation Acknowledge](./documentation/CloudFormation-Ack.png)

### Wait for Stack to complete

# Post CloudFormation Steps 

## After the entire stack completes successfully, check CodeBuild Status
Both codebuild projects MUST complete successfully before you can deploy the app to Amplify.

1. From AWS Console, navigate to CodeBuild
2. Select Build Projects in left Navigation bar
3. Choose build project name
4. You must see the following in order to proceed - both projects need to be successful

   ![CodeBuild Success](./documentation/CodeBuildSuccess.png)

## Modify WAF IP Address or Delete the Rule
For security reasons, the default setup comes with a WAF IP Set and Rule that only allows a default IPv4 and IPv6 to access Amplify. You must add your IPs to the Set or you can delete the WAF Rule and allow all IPs if your security team approves.

### To Delete the Rule:
1. Go to Web ACLs, Select rule and disassociate from the service, then you can delete the rule
2. From AWS Console, navigate to WAF & Shield

   ![Remove WAF ACL 1](./documentation/RemoveWAFACL-1.png)
   ![Remove WAF ACL 2](./documentation/RemoveWAFACL-2.png)
   ![Remove WAF ACL 3](./documentation/RemoveWAFACL-3.png)
3. Delete the rule

### To Modify the IP Set:
> **Important**: Some ISPs use IPv4 and some use IPv6, so you might want to change both. Also, being on a VPN can obfuscate your public IP.

1. From AWS Console, navigate to WAF & Shield
2. Select IP Sets in left Navigation bar
3. Choose BlockIPSet

   ![WAF 01](./documentation/WAF-01.png)
   
4. Find your public IP address and add it using correct format like `99.234.54.13/32` - You can use https://checkip.amazonaws.com/

   ![WAF 02](./documentation/WAF-02.png)

## Deploy UI
1. Download `nih-bot-amplify-build.zip` from the S3 bucket you created initially that has the template files in it
2. Navigate to Amplify in the AWS console and create new app
3. Deploy without GIT

   ![Deploy App 01](./documentation/DeployApp-01.png)
   
4. Keep default app Name and branch Name 

   ![Deploy App 02](./documentation/DeployApp-02.png)
   
5. Choose `nih-bot-amplify-build.zip` from your local computer

   ![Deploy App 03](./documentation/DeployApp-03.png)
   ![Deploy App 04](./documentation/DeployApp-04.png)
   
6. Once it is uploaded, deployment will begin. When you see the green Deployed, Select the link under Domain.

   ![Deploy App 05](./documentation/DeployApp-05.png)

## Create a Cognito Account User
Cognito is used for Authentication of the Amplify App.

![Deploy App 06](./documentation/DeployApp-06.png)
![Deploy App 07](./documentation/DeployApp-07.png)
![Deploy App 08](./documentation/DeployApp-08.png)

### Verify user with code from email
**IMPORTANT**: At this step, you will not get a code emailed to you for security reasons, and an AWS Admin MUST manually confirm the user.

The Admin should:
1. Go to Cognito
2. Select the User pool created
3. On the left side, Select "Users"
4. Confirm the recently created user

   ![Admin Confirm](./documentation/AdminConfirm.png)
   ![Admin Confirm 1](./documentation/AdminConfirm1.png)

Once this is done, the user can refresh the page and login into the app. You will be asked to verify your Account Recovery email, and a code will then be sent to that email for verification. After entering the code and verifying, the app will appear.

## Exercise the Application with Your Data
![Deploy App 09](./documentation/DeployApp-09.png)

## Test the UI with Grants Data
The GitHub repo has a test-files directory with files related to NIH-Grant PAR-23-025.

1. Start by searching on PAR-23-025 and follow the screenshots below to generate a grant template
2. **Note**: Generation can take up to 10 minutes
3. Once it is complete, Select the Template Download link and review the generated grant
   
   > **IMPORTANT**: The presigned URL link will only last 15 minutes

![Test 01](./documentation/test-01.png)
![Test 02](./documentation/test-02.png)
![Test 03](./documentation/test-03.png)
![Test 04](./documentation/test-04.png)

## Test the Generic Path
The UI defaults to the **NIH Research** path described above, but there is also a **Generic Path** that can be selected.

This path allows for simple Retrieval Augmented Generation (RAG) capability:
- You can upload one or more files and have the content of those files included in a prompt that you create yourself
- This is meant to help you with sections of the NIH Grant proposal or AIMs document but can be used more generically as well
- Some examples of generic prompts are in the test-files directory in the file GenericPrompts.txt
- To use the uploaded content, you must include this sentence in your prompt: **Start this task by carefully reviewing the content between the \<docs\> tags that follow \<docs\> {docs} \</docs\>.**

![Generic 01](./documentation/Generic-01.png)
![Generic 02](./documentation/Generic-02.png)

# Operations
## Available Grants Uploading

1. The initial install loads grants based on a default filter. If you want to change the grants to suit your research needs, the below instructions will guide you.
2. In a browser, go to https://grants.nih.gov/funding/searchguide/index.html#/
3. Select Advanced Search
4. In Funding Organizations, select NIH and AHRQ or your Orgs
5. Select the Activities that you need
6. Select the Funding Types that you need
7. Release Date 01/02/2019 or as desired - Current Day update each day
8. Filter by any other categories of interest
9. Export the xlsx file locally
10. Open xlsx and save as csv file
11. Upload csv to folder the context bucket under available-grants/AllGuideResultsReport
12. Verify lambda is triggered and grants get uploaded to opensearch collection by viewing the /aws/lambda/NIHGrantLoader log group

The current grants csv file came from the below search filter:

![Default Grants Filter](./documentation/DefaultGrantsFilter.png)

# Deleting the Stack
Before deleting the root stack, some resources need to be removed. You can do this from the console or from a provided script. ** IMPORTANT ** The preferred way is with the script as it makes sure that right services are deleted before you delete the stack.

## From the console, perform the following:

### 1. Delete all containers from ECR and then delete the repository
![ECR Delete Container](./documentation/ECR-DeleteContainer.png)
![ECR Delete Repo](./documentation/ECR-DeleteRepo.png)

### 2. Empty the context bucket and then delete the bucket
![S3 Empty](./documentation/S3-Empty.png)
![S3 Delete](./documentation/S3-Delete.png)

### 3. Delete lambda trigger on Queue and then Delete SQS Queue
> Note: This will take a minute or two, so wait for it to complete

![SQS Queue Select](./documentation/SQS-Queue-Select.png)
![SQS Trigger Delete](./documentation/SQS-Trigger-Delete.png)
![SQS Queue Delete](./documentation/SQS-Queue-Delete.png)

### 4. Delete NIHTemplateGen Lambda Function
![Lambda Delete](./documentation/Lambda-Delete.png)

### 5. Delete Amplify App
![Amplify View App](./documentation/Amplify-View-App.png)
![Amplify General](./documentation/Amplify-General.png)
![Amplify Delete App](./documentation/Amplify-Delete-App.png)

### 6. NOW you can delete the root stack 😊
![CloudFormation Delete Stack](./documentation/CloudFormation-DeleteStack.png)

## Using the CLI Script
If you have experience with the AWS CLI, there is a script under `/documentation/scripts` in the repo that will perform these steps.

The requirements for running the script are in the comment section at the top of `pre-delete-stack.sh`. Once you have satisfied those requirements, set your AWS environment and run `pre-delete-stack.sh` from a bash shell.

![Script Setup](./documentation/Script-setup.png)
![Script Env](./documentation/Script-Env.png)
![Script Terminal 3](./documentation/Script-Terminal3.png)

# Lambda Memory Sizing
The memory size for all Lambda Functions is set to 3008 MB. You should increase these for TextTract and Bedrock Lambdas to 8019 MB for better performance.

# Accessing OpenSearch Dashboard
To access OpenSearch Dashboard, edit "Data access policies" for the "Access policy name" called quickstart-access-policy. For the "Selected Principals" add the role `role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_xxxxxxx` where this matches your Identity Center user.

# Model Access
The default model is Sonnet 3.7 which from our testing provides the best results. Other models that can be used include the following. Your mileage may vary. Replace the MODEL_ID Environment Variable in NIHTemplateGen:

- `anthropic.claude-3-haiku-20240307-v1:0`
- `amazon.nova-pro-v1:0`
- `nova-lite-v1:0`
- `arn:aws:bedrock:us-east-1:xxxxxxxxxxxx:inference-profile/us.anthropic.claude-3-7-sonnet-20250219-v1:0`
- `arn:aws:bedrock:us-west-2:xxxxxxxxxxxx:inference-profile/us.anthropic.claude-3-7-sonnet-20250219-v1:0`
- `arn:aws:bedrock:us-east-1:xxxxxxxxxxxx:inference-profile/us.anthropic.claude-3-5-haiku-20241022-v1:0`
- `arn:aws:bedrock:us-west-2:xxxxxxxxxxxx:inference-profile/us.anthropic.claude-3-5-haiku-20241022-v1:0`

# Changing the Navigation colors and image.
### 1. Download the nih-bot-amplify-build.zip to your local machine and unzip. You should see files similar to the following.
![AU-files](./documentation/AmplifyUpdate-00.png)
### 2. Modify the file called index-xxxxxxx.css. Globally replace #f47321 with the primary HTML color of your choice and #005030 with the secondary HTML color of your choice.
### 3. Replace the image file aws-samples-img.png with a high resolution png file of your choice. Make sure you use the file name aws-samples-img.png.
### 4. From within the directory where these files live, zip up the contents up one level. 
``` zip -r ../nih-bot-amplify-build.zip . ```
### 5. Deploy the new zip file to Amplify

![AU-deploy1](./documentation/AmplifyUpdate-01.png)

![AU-deploy2](./documentation/AmplifyUpdate-02.png)

![AU-deploy3](./documentation/AmplifyUpdate-03.png)


# Costs
A rough estimate for running the AI and associated services in AWS is $20-25 per day.

![Cost 01](./documentation/Cost-01.png)

# Errors
> "Everything fails, all the time!" - Werner Vogels 😠

Below are some common errors we have seen:

## Error - The bucket you are attempting to access must be addressed using the specified endpoint
- Bucket you created is in a different region than where you are deploying

## Error - Unable to get Region Mapping
![CloudFormation Wrong Region](./documentation/CloudFormation-WrongRegion.png)
- This stack can only be deployed in us-west-2 or us-east-1

## Error - S3 Access Denied
![CloudFormation Bad Bucket Name](./documentation/CloudFormation-BadBucketName.png)
- The bucket name you provided in the Stack Details is wrong

## Error - Failed to Create
![CloudFormation Existing Resource](./documentation/CloudFormation-ExistingResource.png)
- You are attempting to deploy but some resources already exist like an Elastic Container Repository, a Lambda Function, an SQS Queue, or the S3 Context Bucket

## Error in GrantLoader Lambda
```
{
    "level": "ERROR",
    "location": "lambda_handler:111",
    "message": "Exception thrown adding to index str(TransportError(500, 'exception', 'Internal error occurred while processing request'))",
    "timestamp": "2024-10-31 18:01:09,381+0000",
    "service": "service_undefined",
    "xray_trace_id": "1-6723c5cd-429c18467ebdee14000594e6"
}
```
- Rerun lambda by dropping csv file into the correct folder

## Error in InvokeModel
- `(AccessDeniedException) when calling the InvokeModel operation`
- You have not provided access to the Bedrock Model. Modify access and run again.

## WebSocket Error
This can happen for various reasons, usually due to a bad network connection on the client. These are usually transient.

- `Uncaught (in promise) NetworkError: A network error has occurred.`
- Or socket closed error messages with details about WebSocket connection issues
- When your network connection improves, try again

## Error in Document Formatting
- The model is responsible for HTML formatting. Sometimes this doesn't happen cleanly even though the content is there. Run again if this happens.

## Error: Input Tokens Exceeded
- If you submit too many documents to the model for any of the prompts, or if the size of all the documents exceeds the input tokens allowed by the model, you will receive this error. Reduce your documents and "Start Over".

## Error: n error occurred (ValidationException) when calling the InvokeModel operation: Input is too long for requested model.
- Same as above. If you submit too many documents to the model for any of the prompts, or if the size of all the documents exceeds the input tokens allowed by the model, you will receive this error. Reduce your documents and "Start Over".

## Error: Download Link Has Expired
```xml
<Error>
<Code>AccessDenied</Code>
<Message>Request has expired</Message>
<X-Amz-Expires>900</X-Amz-Expires>
<Expires>2025-04-11T11:07:04Z</Expires>
<ServerTime>2025-04-11T11:09:31Z</ServerTime>
<RequestId>5GPKTPCJDNX267FN</RequestId>
<HostId>
fUQYcF3YR+2k3K9Tpfv+AA+YRYzQpqmBlyD9wqb3erZ3jIUYL0SZuXqKZL/dcE/CbNPEUhOCuoQ=
</HostId>
</Error>
```
- Download links only last 15 minutes

## Error: CodeBuild project nih-grants-codebuild fails / Unable to find nih-bot-amplify-build.zip
When this codebuild projects fails with below error, run it again in codebuild. There may have been a network error during install.

```
An error occurred (AccessDeniedException) when calling the CreateFunction operation: Lambda does not have permission to access the ECR image. Check the ECR permissions.
566
567[Container] 2025/05/01 15:37:42.246171 Command did not exit successfully aws lambda create-function --function-name NIHTemplateGen --code ImageUri=$AWS_ECR_REPOSITORY_URI:$IMAGE_TAG --package-type Image --role $LAMBDAROLEARN --timeout 900 --memory-size 3008 --environment Variables="{DDB_TABLE=nih-grants-table, MODEL_ID=arn:aws:bedrock:$AWS_REGION:$AWS_ACCOUNT_ID:inference-profile/us.anthropic.claude-3-7-sonnet-20250219-v1:0, REGION=$AWS_REGION, S3_OUTPUT_BUCKET=$NIHCONTEXTBUCKET, MODEL_OUTOUT_TOKENS=16000, MODEL_REGION=$AWS_REGION, WS_DDB_TABLE=nih-ws-table, WS_ENDPOINT=$WSENDPOINT, AK=$AK}" exit status 254
568[Container] 2025/05/01 15:37:42.250816 Phase complete: POST_BUILD State: FAILED
```

## When you run into other errors
Create a github issue and we will look into it