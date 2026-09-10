#!/bin/bash

set -e

echo "========================================"
echo "Cortex Demo - MongoDB to S3 Backup"
echo "========================================"

python <<'PY'
import boto3
import json
import os
from datetime import datetime, timezone
from pymongo import MongoClient

BUCKET = os.environ.get("S3_BUCKET")

if not BUCKET:
    raise RuntimeError("S3_BUCKET environment variable is required")

mongo = MongoClient(
    host=os.getenv(
        "MONGO_HOST",
        "mongodb.cortex-security-lab.svc.cluster.local"
    ),
    port=int(os.getenv("MONGO_PORT", "27017")),
    username=os.getenv("MONGO_USERNAME", "demo_admin"),
    password=os.getenv("MONGO_PASSWORD", "DemoMongoPassword123!"),
    authSource="admin"
)

db = mongo["customers"]

customers = list(
    db.customers.find({}, {"_id": 0})
)

backup = {
    "classification": "CONFIDENTIAL-DEMO",
    "source": "eks-workload-backup",
    "timestamp": datetime.now(timezone.utc).isoformat(),
    "customers": customers
}

sts = boto3.client("sts")

identity = sts.get_caller_identity()

print("AWS identity:")
print(identity["Arn"])

timestamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")

key = f"mongodb-backup/runtime/customers-{timestamp}.json"

s3 = boto3.client(
    "s3",
    region_name=os.getenv("AWS_REGION", "sa-east-1")
)

s3.put_object(
    Bucket=BUCKET,
    Key=key,
    Body=json.dumps(backup, indent=2).encode(),
    ContentType="application/json"
)

print(f"Backup written to s3://{BUCKET}/{key}")
print(f"Customers exported: {len(customers)}")
PY
