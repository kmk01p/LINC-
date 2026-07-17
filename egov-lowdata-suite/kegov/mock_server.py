#!/usr/bin/env python
"""
mock_server.py

A minimal Flask server that mocks the K-eGov endpoint used for publishing
aggregated metrics. It accepts POST requests at `/publish` and returns
HTTP 202 to simulate acceptance of the payload.
"""
from flask import Flask, request, jsonify

app = Flask(__name__)


@app.route('/publish', methods=['POST'])
def publish():
    payload = request.get_json()
    if not payload:
        return jsonify({'error': 'No payload'}), 400
    return jsonify({'status': 'accepted'}), 202


@app.route('/health', methods=['GET'])
def health():
    return jsonify(status='ok')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)