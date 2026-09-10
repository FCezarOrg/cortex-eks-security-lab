from flask import Flask, jsonify
from pymongo import MongoClient
from pymongo.errors import PyMongoError
import os
import socket

app = Flask(__name__)

# ==========================================================
# SECURITY DEMO ONLY
# Synthetic credentials intentionally hardcoded.
# ==========================================================

DEMO_INTERNAL_API_KEY = "demo_internal_api_key_123456789"
DEMO_DB_PASSWORD = "DemoMongoPassword123!"

MONGO_HOST = os.getenv(
    "MONGO_HOST",
    "mongodb.cortex-security-lab.svc.cluster.local"
)

MONGO_PORT = int(os.getenv("MONGO_PORT", "27017"))
MONGO_USERNAME = os.getenv("MONGO_USERNAME", "demo_admin")
MONGO_PASSWORD = os.getenv("MONGO_PASSWORD", DEMO_DB_PASSWORD)


def get_database():
    client = MongoClient(
        host=MONGO_HOST,
        port=MONGO_PORT,
        username=MONGO_USERNAME,
        password=MONGO_PASSWORD,
        authSource="admin",
        serverSelectionTimeoutMS=3000
    )

    return client["customers"]


@app.route("/")
def home():
    return jsonify({
        "application": "Cortex EKS Security Lab",
        "version": "2.0",
        "hostname": socket.gethostname(),
        "environment": os.getenv("ENVIRONMENT", "demo"),
        "database": MONGO_HOST
    })


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy"
    }), 200


@app.route("/api/customers")
def customers():
    try:
        db = get_database()

        records = list(
            db.customers.find(
                {},
                {
                    "_id": 0
                }
            )
        )

        return jsonify({
            "classification": "CONFIDENTIAL-DEMO",
            "source": "mongodb",
            "count": len(records),
            "customers": records
        })

    except PyMongoError as error:
        return jsonify({
            "status": "database_error",
            "error": str(error)
        }), 500


@app.route("/api/customer/<customer_id>")
def customer(customer_id):
    try:
        db = get_database()

        record = db.customers.find_one(
            {
                "customer_id": customer_id
            },
            {
                "_id": 0
            }
        )

        if not record:
            return jsonify({
                "error": "customer_not_found"
            }), 404

        return jsonify(record)

    except PyMongoError as error:
        return jsonify({
            "status": "database_error",
            "error": str(error)
        }), 500


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=8080
    )
