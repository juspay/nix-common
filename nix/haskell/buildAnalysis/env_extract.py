import json
import os
import argparse
from typing import Dict, List, Any


def parse_env_info(data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    env_info = []
    for item in data:
        function_name = item.get("function_name_", [None])[0]
        if function_name and function_name.startswith("$_in$"):
            function_name = function_name[5:]

        for type_info in item.get("typeVsFields", []):
            if type_info["type_name"].endswith("$JuspayEnv"):
                fields = type_info["fieldsVsExprs"]["Left"]
                env_data = {"function_name": function_name}
                for field in fields:
                    field_name = field["field_name"]
                    expression = field["expression"]
                    if field_name == "key":
                        env_data["env_lookup"] = expression.strip('"')
                    elif field_name == "actionLeft":
                        try:
                            if expression.startswith("mkDefaultEnvAction"):
                                default_value = (
                                    expression.strip()
                                    .replace("mkDefaultEnvAction", "")
                                    .split("::")[0]
                                    .strip()[1:]
                                )
                                value_type = (
                                    expression.strip()
                                    .replace("mkDefaultEnvAction", "")
                                    .split("::")[1]
                                    .strip()[:-1]
                                )
                                env_data["default_value"] = default_value
                                env_data["throw_exception"] = False
                                env_data["type"] = value_type
                            else:
                                env_data["default_value"] = False
                                env_data["throw_exception"] = True
                                env_data["type"] = None
                        except Exception as e:
                            print(e,expression)
                    elif field_name == "decryptFunc":
                        env_data["decryption"] = not (expression == "pure")
                    elif field_name == "logWhenThrowException":
                        env_data["log_when_throw_exception"] = not (expression == "Nothing")
                env_info.append(env_data)
    return env_info


def process_files(directory: str) -> List[Dict[str, Any]]:
    all_env_info = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith("typeUpdates.json"):
                file_path = os.path.join(root, file)
                with open(file_path, "r") as f:
                    data = json.load(f)
                    all_env_info.extend(parse_env_info(data))
    return all_env_info


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

    env_info = process_files(args.input_dir)
    if len(env_info) != 0:
        write_output(env_info, args.output_path)
        print(f"Output written to: {args.output_path}")


if __name__ == "__main__":
    main()