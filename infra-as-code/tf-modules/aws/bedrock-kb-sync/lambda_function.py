"""AWS Bedrock Knowledge Base Sync Lambda Function."""

import json
import os

import boto3
from botocore.exceptions import ClientError

bedrock = boto3.client("bedrock-agent")

KB_ID = os.environ.get("KNOWLEDGE_BASE_ID")
DS_ID = os.environ.get("DATA_SOURCE_ID")


def lambda_handler(event, context):
    """Trigger a Bedrock ingestion job and return immediately."""

    print(f"Event received: {json.dumps(event)}")

    # Get KB and DS IDs from event or environment
    kb_id = event.get("knowledgeBaseId", KB_ID)
    ds_id = event.get("dataSourceId", DS_ID)
    description = event.get("description", "Lambda-triggered sync job")

    if not kb_id or not ds_id:
        error_msg = "Missing required parameters: knowledgeBaseId and dataSourceId"
        print(f"ERROR: {error_msg}")
        return {
            "statusCode": 400,
            "body": json.dumps({"error": error_msg})
        }

    print(f"Starting sync job for KB: {kb_id}, DS: {ds_id}")

    try:
        response = bedrock.start_ingestion_job(
            knowledgeBaseId=kb_id,
            dataSourceId=ds_id,
            description=description
        )

        job_id = response["ingestionJob"]["ingestionJobId"]
        status = response["ingestionJob"]["status"]

        print(f"Sync job started successfully: {job_id} ({status})")

        return {
            "statusCode": 200,
            "body": json.dumps({
                "jobId": job_id,
                "knowledgeBaseId": kb_id,
                "dataSourceId": ds_id,
                "status": status,
                "description": description,
            })
        }

    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        error_msg = e.response["Error"]["Message"]

        print(f"ERROR: AWS API error - {error_code}: {error_msg}")

        if error_code == "ResourceNotFoundException":
            print("Knowledge Base or Data Source not found. Check IDs.")
        elif error_code == "ConflictException":
            print("A sync job is already running. Wait for it to complete.")
        elif error_code == "ValidationException":
            print("Invalid parameters provided.")

        return {
            "statusCode": 500,
            "body": json.dumps({
                "error": error_code,
                "message": error_msg
            })
        }

    except Exception as e:
        print(f"ERROR: Unexpected error - {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
