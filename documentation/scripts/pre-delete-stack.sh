#!/bin/bash
#
# USE AT YOUR OWN RISK, MILEAGE MAY VARY :-)
#
# This script runs on a mac
# You need to have aws cli 2 installed
# You need to run in a bash shell
# You need creds in your env, get them from your Idenity Center user and make sure region is set correctly
# You need your account id and region to pass into the script
# You need jq installed - brew install jq
# This assumes you have a clean account without any other services except the ones created by the CloudFormation Templates
# You need to have delete-ecr-images.sh in same directory as this script
#
usage() { echo "Usage: $0 [-a <account id>] [-r <region>]" 1>&2; exit 1; }

while getopts ":a:r:" o; do
    case "${o}" in
        a)
            a=${OPTARG}
            ;;
        r)
            r=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${a}" ] || [ -z "${r}" ]; then
    usage
fi

echo "a = ${a}"
echo "r = ${r}"
accountid=$a
region=$r
echo "Account ID $accountid"
echo "Region $region"


# Delete NIHTemplateGen
aws lambda delete-function --function-name NIHTemplateGen --region $region
# List source events for SQS Queue
echo "list event source mappings"
UUID=$(echo `aws lambda list-event-source-mappings --region $region` | jq -r '.EventSourceMappings[0].UUID')
echo "Event Source UUD $UUID"
# Delete first event source mapping
echo "delete event source mappings"
aws lambda delete-event-source-mapping --uuid $UUID --region $region
# Delete SQS Queue
QUEUE=$(aws sqs list-queues --region $region | jq -r '.QueueUrls[0]')
echo " SQS Queue $QUEUE"
aws sqs delete-queue --queue-url $QUEUE --region $region
# Delete images and ECR Repository
reponame=nih-grants-repository-$region-$accountid
echo "ECR repository $reponame"
# nih-grants-repository-us-east-1-160885294718
./delete-ecr-images.sh $region $reponame
aws ecr delete-repository --repository-name $reponame --region $region
# Delete S3 Bucket
contextbucket=s3://nih-grants-context-$region-$accountid
echo "S3 Context Bucket $contextbucket"
aws s3 rm $contextbucket --recursive
aws s3 rb $contextbucket --force 

# Delete Log Bucket
logsbucket=s3://nih-grants-access-logs-$region-$accountid
echo "S3 Logs Bucket $contextbucket"
aws s3 rm $logsbucket --recursive
aws s3 rb $logsbucket --force 
# list amplify Apps
ID=$(echo `aws amplify list-apps --region $region` | jq -r '.apps[0].appId')
echo $ID
# Delete Amplify App - update App Id each time
aws amplify delete-app --app-id $ID --region $region
# Delete CloudFormation Stack
# go to console and delete the root stack