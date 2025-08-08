import requests
import zipfile
import os
import argparse
import logging

logging.basicConfig(level=logging.INFO)

def fetch_plugin_hpi(plugin_name, plugin_version):
    url = f"https://updates.jenkins.io/download/plugins/{plugin_name}/{plugin_version}/{plugin_name}.hpi"

    response = requests.get(url)

    if response.status_code == 200:
        hpi_file = f"{plugin_name}.hpi"
        with open(hpi_file, "wb") as f:
            f.write(response.content)
        return hpi_file
    else:
        print(
            f"Failed to download {plugin_name} version {plugin_version}. HTTP Status Code: {response.status_code}"
        )
        return None


def check_plugin_compatibility(plugin_path, jenkins_version):
    with zipfile.ZipFile(plugin_path, "r") as z:
        with z.open("META-INF/MANIFEST.MF") as manifest:
            for line in manifest:
                line = line.decode("utf-8").strip()
                if line.startswith("Jenkins-Version:"):
                    min_version = line.split(":")[1].strip()
                    if min_version <= jenkins_version:
                        return True, min_version
                    else:
                        return False, min_version
    return False, None


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Check Jenkins plugin compatibility.")
    parser.add_argument(
        "--plugin-name",
        type=str,
        required=True,
        help="The name of the plugin (e.g., git)",
    )
    parser.add_argument(
        "--plugin-version",
        type=str,
        required=True,
        help="The version of the plugin (e.g., 4.10.0)",
    )
    parser.add_argument(
        "--jenkins-version",
        type=str,
        required=True,
        help="Your Jenkins version (e.g., 2.289.3)",
    )

    args = parser.parse_args()

    hpi_file = fetch_plugin_hpi(args.plugin_name, args.plugin_version)

    if hpi_file and os.path.exists(hpi_file):
        compatible, min_version = check_plugin_compatibility(
            hpi_file, args.jenkins_version
        )
        if compatible:
            logging.info(f"{args.plugin_name} min_req_jenkins:{min_version} checked_against_jenkins:{args.jenkins_version} Status:Compatible")
        else:
            logging.info(f"{args.plugin_name} min_req_jenkins:{min_version} checked_against_jenkins:{args.jenkins_version} Status:Incompatible")

        os.remove(hpi_file)
        print(compatible)
    else:
        print(None)
