#!/usr/bin/env python3

import json
import urllib.parse
import hashlib
import logging
import argparse
import asyncio
import aiohttp

THEIA_ELECTRON_DIR = "main/theia-electron"

async def get_remote_sha256(url):
    logging.info(f"started sha256({url})")
    sha256 = hashlib.sha256()
    async with aiohttp.ClientSession() as http_session:
        async with http_session.get(url) as response:
            async for data in response.content.iter_chunked(4096):
                sha256.update(data)
    logging.info(f"done sha256({url})")
    return sha256.hexdigest()

async def get_plugin_sources(dest, plugin_name, plugin_url):
    return [{
        "type": "archive",
        "archive-type": "zip",
        "url": plugin_url,
        "sha256": await get_remote_sha256(plugin_url),
        "dest": f"{dest}/{plugin_name}"
    }]

async def generate_sources(package_json):
    sources = []
    commands = []
    plugins_dir = package_json["theiaPluginsDir"]
    plugins = package_json["theiaPlugins"]
    dest = f"{THEIA_ELECTRON_DIR}/{plugins_dir}"
    coros = [get_plugin_sources(dest, n, u) for n, u in plugins.items()]
    for plugin_sources in await asyncio.gather(*coros):
        sources += plugin_sources
    sources += [{
        "type": "shell",
        "dest": f"{THEIA_ELECTRON_DIR}/{plugins_dir}",
        "commands": commands
    }]
    return sources

async def main():
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
    generated_sources = await generate_sources(package_json)
    with open(outfile, "w") as out:
        json.dump(generated_sources, out, indent=4, sort_keys=False)

if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    asyncio.run(main())
