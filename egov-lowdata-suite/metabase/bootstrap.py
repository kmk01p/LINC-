#!/usr/bin/env python3
import os
import sys
import requests

MB_BASE_URL = os.getenv('MB_BASE_URL', 'http://localhost:3000')
MB_SESSION = os.getenv('MB_SESSION', '')
MB_DATABASE_ID = int(os.getenv('MB_DATABASE_ID', '1'))


def create_collection(project_name, project_id):
    url = f"{MB_BASE_URL}/api/collection"
    headers = {
        'Content-Type': 'application/json',
        'X-Metabase-Session': MB_SESSION
    }
    payload = {
        'name': f'Project: {project_name}',
        'description': f'Auto-generated for project {project_id}',
        'color': '#509EE3'
    }
    
    response = requests.post(url, headers=headers, json=payload)
    if response.status_code in [200, 201]:
        return response.json()['id']
    else:
        print(f"Failed to create collection: {response.text}", file=sys.stderr)
        sys.exit(1)


def create_card(collection_id, card_name, project_id, sql_query):
    url = f"{MB_BASE_URL}/api/card"
    headers = {
        'Content-Type': 'application/json',
        'X-Metabase-Session': MB_SESSION
    }
    
    display_type = 'scalar' if 'COUNT' in sql_query else 'table'
    
    payload = {
        'name': card_name,
        'collection_id': collection_id,
        'display': display_type,
        'visualization_settings': {},
        'dataset_query': {
            'type': 'native',
            'database': MB_DATABASE_ID,
            'native': {
                'query': sql_query
            }
        }
    }
    
    response = requests.post(url, headers=headers, json=payload)
    if response.status_code in [200, 201]:
        print(f"Created card: {card_name}")
        return response.json()['id']
    else:
        print(f"Failed to create card {card_name}: {response.text}", file=sys.stderr)
        return None


def bootstrap_project(project_name, project_id):
    collection_id = create_collection(project_name, project_id)
    
    cards = [
        ("Reach Ops", f"SELECT COUNT(*) FROM submissions_raw WHERE project_id = '{project_id}'"),
        ("Quality Ops", f"SELECT status, COUNT(*) FROM quality_flags WHERE project_id = '{project_id}' GROUP BY status"),
        ("Action List", f"SELECT * FROM quality_flags WHERE project_id = '{project_id}' AND status = 'flagged' LIMIT 100"),
        ("Diagnosis Distribution", f"SELECT payload->>'diagnosis' as diagnosis, COUNT(*) FROM submissions_raw WHERE project_id = '{project_id}' GROUP BY diagnosis"),
        ("Attach Validity", f"SELECT COUNT(*) FROM submissions_raw WHERE project_id = '{project_id}' AND media IS NOT NULL"),
        ("Model Health", "SELECT 'Model Health' as metric, 100 as score")
    ]
    
    card_ids = []
    for card_name, sql in cards:
        card_id = create_card(collection_id, card_name, project_id, sql)
        if card_id:
            card_ids.append(card_id)
    
    print(f"Bootstrap complete. Collection ID: {collection_id}, Cards: {card_ids}")
    return collection_id, card_ids


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: python bootstrap.py <project_name> <project_id>")
        sys.exit(1)
    
    project_name = sys.argv[1]
    project_id = sys.argv[2]
    
    bootstrap_project(project_name, project_id)
