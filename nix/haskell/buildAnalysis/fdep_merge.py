import json
import os
import concurrent.futures
import zipfile
import sys
import argparse

# base_dir_path = "./tmp/fdep/"
fdep = dict()
top_lvl_functions = list()


def replace_all(text, replacements):
    for old, new in replacements:
        text = text.replace(old, new)
    return text


def get_module_name(base_dir_path, path, to_replace=""):
    path = path.replace(base_dir_path, "")
    patterns = [
        ("src/", "src/"),
        ("src-generated/", "src-generated/"),
        ("src-extras/", "src-extras/"),
    ]
    for pattern, split_pattern in patterns:
        if pattern in path:
            path = path.split(split_pattern)[-1]
            break
    module_name = replace_all(path, [("/", "."), (to_replace, "")])
    return module_name


def list_files_recursive(directory):
    files_list = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if ".hs.json" in file:
                files_list.append(os.path.join(root, file))
    return files_list


def process_each_fdep_module(obj, code_string_dict):
    local_fdep = {}

    def update_nested_key(d, keys, value):
        current = d
        try:
            for key in keys[:-1]:
                if current != None:
                    if current.get(key) == None:
                        current[key] = {}
                        current[key]["where_functions"] = {}
                    else:
                        if current[key].get("where_functions") == None:
                            current[key]["where_functions"] = {}
                    current = current[key]
                else:
                    current = {}
                    current["where_functions"] = {}
            current["where_functions"][keys[-1]] = value
        except Exception as e:
            print("update_nested_key", e)

    for functionsName, functionData in obj.items():
        if not "::" in functionsName:
            fName = functionsName.replace("$_in$", "")
            srcLoc = functionsName.replace("$_in$", "").split("**")[1]
            try:
                if local_fdep != None and local_fdep.get(fName) == None:
                    local_fdep[fName] = {}
                    local_fdep[fName]["function_name"] = fName
                    local_fdep[fName]["src_loc"] = srcLoc
                    if code_string_dict.get(fName) != None:
                        local_fdep[fName]["stringified_code"] = code_string_dict.get(
                            fName, {}
                        ).get("parser_stringified_code", "")
                for i in functionData:
                    if i != None and i.get("typeSignature") != None:
                        local_fdep[fName]["function_signature"] = i.get("typeSignature")
                    elif i != None and i.get("expr") != None:
                        if local_fdep[fName].get("functions_called") == None:
                            local_fdep[fName]["functions_called"] = []
                        local_fdep[fName]["functions_called"].append(i.get("expr"))
                    else:
                        local_fdep[fName]["functions_called"] = []
            except Exception as e:
                exc_type, exc_obj, exc_tb = sys.exc_info()
                fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
                print(e, fname, exc_tb.tb_lineno)
        else:
            parentFunctions = functionsName.replace("$_in$", "").split("::")
            (currentFunctionName, currentFunctionSrcLocation) = parentFunctions[
                (len(parentFunctions) - 1)
            ].split("**")
            currentFunctionDict = dict()
            for i in functionData:
                if i != None and i.get("typeSignature") != None:
                    currentFunctionDict["function_signature"] = i.get("typeSignature")
                    currentFunctionDict["src_log"] = currentFunctionSrcLocation
                    currentFunctionDict["function_name"] = currentFunctionName
                elif i != None and i.get("expr") != None:
                    if currentFunctionDict.get("functions_called") == None:
                        currentFunctionDict["functions_called"] = []
                    currentFunctionDict["functions_called"].append(i.get("expr"))
            update_nested_key(local_fdep, parentFunctions, currentFunctionDict)
    try:
        for functionName, functionData in local_fdep.items():
            functions_called = functionData.get("functions_called", [])
            unique_elements = dict()
            for item in functions_called:
                key = (
                    item.get("_type")
                    + "**"
                    + item.get("name")
                    + "**"
                    + item.get("module_name")
                    + "**"
                    + item.get("package_name")
                )
                unique_elements[key] = item
            local_fdep[functionName]["functions_called"] = list(
                unique_elements.values()
            )
    except Exception as e:
        print("removing duplicates", e)
    return local_fdep


def process_fdep_output(file):
    code_string_dict = dict()
    if os.path.exists(file.replace(".hs.json", ".hs.function_code.json")):
        with open(file.replace(".hs.json", ".hs.function_code.json")) as code_string:
            code_string_dict = json.load(code_string)
    with open(file, "r") as f:
        local_data = process_each_fdep_module(json.load(f), code_string_dict)

    # try:
    #     ## cleanup
    #     if os.path.exists(file):
    #         os.remove(file)
    #     else:
    #         print("The file does not exist")
    #     if os.path.exists(file.replace(".hs.json", ".hs.function_code.json")):
    #         os.remove(file.replace(".hs.json", ".hs.function_code.json"))
    #     else:
    #         print("The file does not exist")
    # except Exception as e:
    #     print(e)

    return local_data


def main():
    parser = argparse.ArgumentParser(
        description="Process environment information and write to specified output path"
    )
    parser.add_argument(
        "--input-dir",
        default="./tmp/fdep/",
        help="Input directory containing typeUpdates.json files",
    )
    parser.add_argument(
        "--output-path",
        required=True,
        help="Path where the output JSON file should be written",
    )

    args = parser.parse_args()

    files = list_files_recursive(args.input_dir)

    with concurrent.futures.ThreadPoolExecutor(max_workers=20) as executor:
        future_to_file = {
            executor.submit(process_fdep_output, file): file for file in files
        }
        for future in concurrent.futures.as_completed(future_to_file):
            file = future_to_file[future]
            try:
                module_name = get_module_name(args.input_dir, file, ".hs.json")
                fdep[module_name] = future.result()
                top_lvl_functions.extend(list(fdep[module_name].keys()))
            except Exception as e:
                print(f"Error reading {file}: {e}")
    os.makedirs(os.path.dirname(args.output_path), exist_ok=True)
    with zipfile.ZipFile(args.output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        json_data = json.dumps(fdep,indent=4)

        with zipf.open('data.json', 'w') as json_file:
            json_file.write(json_data.encode('utf-8'))


if __name__ == "__main__":
    main()
