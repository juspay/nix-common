import os
import json
import re
import argparse
from typing import Any, Dict, List

def extract_details(obj):
    instance_type = obj.get("instanceType", "")
    print(f"Instance Type: {instance_type}")
    if "typeerror" in instance_type.lower():
        return None
    
    enum_match = re.search(r"ServiceConfigKey\s+(\w+)", instance_type)
    enum = enum_match.group(1) if enum_match else None
    print(f"Enum: {enum}")

    instance_definition = obj.get("instanceDefinition", "").replace('\\n', ' ').replace('\\', '')
    match = re.search(r'getKey\s*\(?[^\)]+?\)?\s*=\s*(.*)', instance_definition)

    if match:
        after_equal = match.group(1).strip()
        parts = re.findall(r'[_A-Za-z0-9]+', after_equal)

        if parts:
            basekey = max(parts, key=len)
            dimensions = [part for part in parts if part != basekey]
        else:
            basekey = None
            dimensions = []
    else:
        basekey = None
        dimensions = []
        
    if enum and basekey:
        return {
            "enum": enum,
            "basekey": basekey,
            "dimensions": dimensions if dimensions else None
        }
    return None

def process_json_file(file_path):
    extracted_keys = []

    with open(file_path, 'r') as file:
        data = json.load(file)

    if isinstance(data, list):
        for obj in data:
            if "instanceType" in obj and "ServiceConfigKey" in obj.get("instanceType", ""):
                details = extract_details(obj)
                if details:
                    extracted_keys.append(details)
    elif isinstance(data, dict):
        if "instanceType" in data and "ServiceConfigKey" in data.get("instanceType", ""):
            details = extract_details(data)
            if details:
                extracted_keys.append(details)

    return extracted_keys

def search_and_extract(folder):
    all_keys = []

    for root, _, files in os.walk(folder):
        for file in files:
            if file.endswith('instance_code.json'):
                file_path = os.path.join(root, file)
                keys = process_json_file(file_path)
                all_keys.extend(keys)

    return all_keys

def write_output(data: List[Dict[str, Any]], output_path: str):
    # Ensure the directory exists
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    with open(output_path, 'w') as f:
        json.dump(data, f, indent=2)
def main():
    parser = argparse.ArgumentParser(description='Extract keys from JSON files.')
    parser.add_argument('--folder-path', default='./tmp', help='Path to the folder containing JSON files.')
    parser.add_argument('--output-path', required=True, help='Path to the output JSON file.')

    args = parser.parse_args()

    extracted_keys = search_and_extract(args.folder_path)
    if len(extracted_keys) != 0:
        write_output(extracted_keys, args.output_path)
        print(f"Output written to: {args.output_path}")

if __name__ == "__main__":
    main()
