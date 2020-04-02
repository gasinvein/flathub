#!/usr/bin/env python3

import json
import urllib.request
import urllib.parse
import hashlib
import logging
import argparse

THEIA_ELECTRON_DIR = "main/theia-electron"

def get_remote_sha256(url):
    logging.info(f"Calculating sha256 of {url}")
    response = urllib.request.urlopen(url)
    sha256 = hashlib.sha256()
    while True:
        data = response.read(4096)
        if not data:
            break
        sha256.update(data)
    return sha256.hexdigest()

def generate_sources(package_json):
    sources = []
    commands = []
    plugins_dir = package_json["theiaPluginsDir"]
    plugins = package_json["theiaPlugins"]
    for plugin_name, plugin_url in plugins.items():
        sources += [{
            "type": "file",
            "url": plugin_url,
            "sha256": get_remote_sha256(plugin_url),
            "dest": f"{THEIA_ELECTRON_DIR}/{plugins_dir}",
            "dest-filename": f"{plugin_name}.zip"
        }]
        commands += [
            f"unzip {plugin_name}.zip -d {plugin_name}",
            f"rm {plugin_name}.zip"
        ]
    sources += [{
        "type": "shell",
        "dest": f"{THEIA_ELECTRON_DIR}/{plugins_dir}",
        "commands": commands
    }]
    return sources

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("package_json")
    parser.add_argument("-o", "--output", required=False)
    args = parser.parse_args()
    if args.output is not None:
        outfile = args.output
    else:
        outfile = "generated-extra-sources.json"
    with open(args.package_json, "r") as package_json_file:
        package_json = json.load(package_json_file)
    generated_sources = generate_sources(package_json)
    with open(outfile, "w") as out:
        json.dump(generated_sources, out, indent=4, sort_keys=False)

if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    main()
