import argparse
import json
import os
import re
import urllib.parse

argument_parser = argparse.ArgumentParser(
    formatter_class=argparse.RawDescriptionHelpFormatter,
    prog="Obsidian File Opener",
    description="Open and create files in Obsidian with template support.",
    epilog="""
    \n\n
    Template config file format (json):  

    {
        "filename_regex": "template_path"
    }

    example:
    {
        "\\\\.md$": "~/Templates/default.md"
        "\\\\.excalidraw\\\\.md$": "~/Templates/excalidraw.md"
    }
    """,
)
argument_parser.add_argument("file", help="file to open/create")
argument_parser.add_argument(
    "-c", "--config", help="path to json template config file", required=True
)
args = argument_parser.parse_args()
path = os.path.abspath(args.file)
url_params = {
    "path": path,
}

if not os.path.exists(path):
    filename = os.path.basename(path)
    with open(args.config) as f:
        config = json.loads(f.read())
    template_content = ""

    for regex, template in config.items():
        if re.search(regex, filename):
            print(f"Template regex is matching: {regex}")
            with open(os.path.expanduser(template), encoding="utf-8") as f:
                template_content = f.read()
            break
    with open(path, "w", encoding="utf-8") as f:
        f.write(template_content)

encoded = urllib.parse.urlencode(url_params, quote_via=urllib.parse.quote)
os.system(f"xdg-open obsidian://open?{encoded}")
