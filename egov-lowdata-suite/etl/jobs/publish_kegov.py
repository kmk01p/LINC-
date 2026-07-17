#!/usr/bin/env python
"""
publish_kegov.py

Script to publish aggregated metrics to the K-eGov endpoint. For the purposes
of this repository this is a stub that demonstrates HTTP POST to the mock
server defined in kegov/mock_server.py.
"""
import os
import datetime
import json
import requests


def run():
    payload = {
        'timestamp': datetime.datetime.utcnow().isoformat() + 'Z',
        'metrics': {
            'submissions': 0,
            'diagnosis_counts': {}
        }
    }
    endpoint = os.environ.get('KEGOV_ENDPOINT', 'http://kegov-mock:5000/publish')
    print(f"[publish_kegov] Publishing to {endpoint}")
    try:
        resp = requests.post(endpoint, json=payload)
        print(f"[publish_kegov] Response code: {resp.status_code}")
    except Exception as exc:
        print(f"[publish_kegov] Error publishing: {exc}")


if __name__ == '__main__':
    run()