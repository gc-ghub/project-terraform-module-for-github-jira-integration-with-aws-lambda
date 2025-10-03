# app.py
import json
import os
import base64
import boto3
import requests
from requests.auth import HTTPBasicAuth

secrets_client = boto3.client("secretsmanager")

def get_jira_creds(secret_arn):
    if not secret_arn:
        # fallback to env vars (not recommended for production)
        return {
            "JIRA_ISSUES_URL": os.getenv("JIRA_ISSUES_URL"),
            "JIRA_EMAIL": os.getenv("JIRA_EMAIL"),
            "JIRA_API_TOKEN": os.getenv("JIRA_API_TOKEN")
        }

    resp = secrets_client.get_secret_value(SecretId=secret_arn)
    secret_str = resp.get("SecretString", "{}")
    return json.loads(secret_str)

def lambda_handler(event, context):
    # API Gateway HTTP API -> event["body"] holds payload
    body = event.get("body")
    if not body:
        return {"statusCode": 400, "body": json.dumps({"message": "No body"})}

    try:
        data = json.loads(body)
    except Exception:
        # If body is double-encoded or already a dict
        if isinstance(body, dict):
            data = body
        else:
            return {"statusCode": 400, "body": json.dumps({"message": "Invalid JSON"})}

    comment_body = data.get("comment", {}).get("body", "").strip()

    if comment_body != "/createjira":
        return {
            "statusCode": 200,
            "body": json.dumps({"message": "No Jira ticket created. Comment did not contain /createjira."})
        }

    secret_arn = os.getenv("JIRA_SECRET_ARN")  # Terraform will set this
    creds = get_jira_creds(secret_arn)

    url = creds.get("JIRA_ISSUES_URL")
    email = creds.get("JIRA_EMAIL")
    api_token = creds.get("JIRA_API_TOKEN")

    if not (url and email and api_token):
        return {"statusCode": 500, "body": json.dumps({"message": "Jira credentials missing"})}

    auth = HTTPBasicAuth(email, api_token)

    headers = {
        "Accept": "application/json",
        "Content-Type": "application/json"
    }

    payload = {
        "fields": {
            "description": {
                "content": [
                    {
                        "content": [
                            {
                                "text": f"Jira Ticket created from GitHub comment: {comment_body}",
                                "type": "text"
                            }
                        ],
                        "type": "paragraph"
                    }
                ],
                "type": "doc",
                "version": 1
            },
            "issuetype": {"id": "10014"},  # adjust
            "project": {"key": "SI"},
            "summary": "Automated Jira Ticket from GitHub /createjira comment"
        }
    }

    resp = requests.post(url, headers=headers, auth=auth, json=payload)

    try:
        resp_json = resp.json()
    except Exception:
        resp_json = {"text": resp.text}

    return {
        "statusCode": resp.status_code,
        "body": json.dumps(resp_json)
    }
