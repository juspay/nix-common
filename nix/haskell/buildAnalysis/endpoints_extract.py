import json
import os
import argparse
from typing import Dict, List, Any

def parse_endpoints_info(data: List[Dict[str, Any]]) -> Dict[str, Any]:
    endpoint_info = dict()
    for (k,v) in data.items():
        for handler in v:
            if "/".join(handler.get("path'")) != "":
                if endpoint_info.get(k) == None:
                    endpoint_info[k] = []
                endpoint_info[k].append("/".join(handler.get("path'")))

    return endpoint_info


def process_files(directory: str) -> List[Dict[str, Any]]:
    all_endpoints_info = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(".module_apis.json"):
                file_path = os.path.join(root, file)
                with open(file_path, "r") as f:
                    data = json.load(f)
                    d = parse_endpoints_info(data)
                    if len(d) != 0:
                        all_endpoints_info.append(d)
    return all_endpoints_info


def write_output(data: List[Dict[str, Any]], output_path: str):
    # Ensure the directory exists
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, 'w') as f:
        json.dump(data, f, indent=2)


def main():
    parser = argparse.ArgumentParser(description='Process environment information and write to specified output path')
    parser.add_argument('--input-dir', default='./tmp', help='Input directory containing typeUpdates.json files')
    parser.add_argument('--output-path', required=True, help='Path where the output JSON file should be written')

    args = parser.parse_args()

    endpoints_info = process_files(args.input_dir)
    if len(endpoints_info) != 0:
        write_output(endpoints_info, args.output_path)
        print(f"Output written to: {args.output_path}")


if __name__ == "__main__":
    main()