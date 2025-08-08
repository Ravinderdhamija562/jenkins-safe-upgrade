import requests
from bs4 import BeautifulSoup
import zipfile
import os
import sys

RED = "\033[91m"
YELLOW = "\033[93m" 
RESET_COLOR = "\033[0m"

def print_help():
    print("Usage: python script.py <plugin_file> <Jenkins_Version>")
    print("Please provide exactly two parameters.")
    print("Example: python plugins.txt 2.462.1")

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

def get_plugin_versions_excluding_latest(plugin_name):
    plugin_url = f"https://updates.jenkins.io/download/plugins/{plugin_name}/"

    response = requests.get(plugin_url)

    if response.status_code != 200:
        print(
            f"Failed to fetch plugin page for {plugin_name}. Status code: {response.status_code}"
        )
        return []

    soup = BeautifulSoup(response.text, "html.parser")

    version_links = soup.find_all("a")

    versions = []
    for link in version_links:
        href = link.get("href")
        if href:
            try:
                version = href.split('/')[-2]
            except Exception as e:
                print(f"{RED}ERROR: Could not extract version for plugin:{plugin_name} from link:{href}. Error: {e}{RESET_COLOR}")
                continue
            versions.append(version)

    if versions:
        versions = versions[2:] #First link is the link to latest, 2nd is latest. Latest is already checked for compatibility hence skipping it.


    return versions

def fetch_plugins_compatible_version(plugin_file):
    update_center_url = "https://updates.jenkins.io/current/update-center.actual.json" # It has the latest version info only

    try:
        response = requests.get(update_center_url)
        response.raise_for_status()
        update_center_data = response.json()
    except requests.RequestException as e:
        print(f"{RED}ERROR fetching update center data: {e}{RESET_COLOR}")
        return

    plugins_info=update_center_data["plugins"]

    with open(plugin_file, "r") as file:
        plugins = [line.strip().split(':')[0] for line in file if line.strip()] # our plugin.txt file is in the format plugin:version

    for plugin in plugins:
        plugin_info = plugins_info.get(plugin)

        if plugin_info:
            latest_version = plugin_info['version']
            required_jenkins = plugin_info['requiredCore']
            if required_jenkins <= CHECK_COMPATIBILITY_AGAINST_JENKINS_VERSION:
                print(f"{plugin}:{latest_version} min_req_jenkins:{required_jenkins} checked_against_jenkins:{CHECK_COMPATIBILITY_AGAINST_JENKINS_VERSION} Status:Compatible")
            else:
                print(f"{YELLOW}{plugin}:{latest_version} min_req_jenkins:{required_jenkins} checked_against_jenkins:{CHECK_COMPATIBILITY_AGAINST_JENKINS_VERSION} Status:Incompatible{RESET_COLOR}")
                versions = get_plugin_versions_excluding_latest(plugin)

                for version in versions:
                    hpi_file = fetch_plugin_hpi(plugin, version)
                    found=False

                    if hpi_file and os.path.exists(hpi_file):
                        compatible, min_req_jenkins = check_plugin_compatibility(hpi_file, CHECK_COMPATIBILITY_AGAINST_JENKINS_VERSION)
                        os.remove(hpi_file)
                        if compatible:
                            print(f"{plugin}:{version} min_req_jenkins:{min_req_jenkins} checked_against_jenkins:{CHECK_COMPATIBILITY_AGAINST_JENKINS_VERSION} Status:Compatible")
                            found=True
                            break
                        else:
                            print(f"{YELLOW}{plugin}:{version} min_req_jenkins:{min_req_jenkins} checked_against_jenkins:{CHECK_COMPATIBILITY_AGAINST_JENKINS_VERSION} Status:Incompatible{RESET_COLOR}")
                    else:
                        print(f"{RED}ERROR: Could not check the compatibility for {plugin} {version}{RESET_COLOR}")
                if found==False:
                    print(f"{RED}ERROR: Could not fetch any compatible version for plugin {plugin} for jenkins:{CHECK_COMPATIBILITY_AGAINST_JENKINS_VERSION}{RESET_COLOR}")
        else:
            print(f"{RED}ERROR: Could not fetch the info for plugin {plugin}{RESET_COLOR}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print_help()
    else:
        plugin_file = sys.argv[1]
        CHECK_COMPATIBILITY_AGAINST_JENKINS_VERSION = sys.argv[2]
        #plugin_file = "plugins.txt"
        if not os.path.exists(plugin_file):
            print(f'{RED}ERROR: Could not find specified plugin file:{plugin_file}{RESET_COLOR}')
            sys.exit(1)

        fetch_plugins_compatible_version(plugin_file)
