#!/bin/bash

color="\033[1;35m" # magenta
reset="\033[0m"
echo -e "${color}Collecting packages info${reset}"

PKG_INFO_DIR="/tmp/pkg_info"
mkdir -p ${PKG_INFO_DIR}
# Determine the OS version
os_version=$(lsb_release -cs)

# Generate a list of installed packages
dpkg -l > ${PKG_INFO_DIR}/installed-packages.txt

# Create a file for manual tools versions
echo '[Manual Tools Versions]' > ${PKG_INFO_DIR}/manual-installed.txt

# Check and log Java version
if command -v java >/dev/null; then
    java -version 2>&1 | head -n 1 >> ${PKG_INFO_DIR}/manual-installed.txt
fi

# Check and log JFrog CLI version
if command -v jf >/dev/null; then
    jf -v >> ${PKG_INFO_DIR}/manual-installed.txt
fi

# Check and log Git version
if command -v git >/dev/null; then
    git --version >> ${PKG_INFO_DIR}/manual-installed.txt
fi

# Function to handle Bionic-specific tasks
handle_bionic() {
    # Check and log Perl JSON::PP version
    perl -MJSON::PP -e 'print "Perl JSON::PP: $JSON::PP::VERSION\n"' >> ${PKG_INFO_DIR}/manual-installed.txt || \
        echo 'Perl JSON::PP not found' >> ${PKG_INFO_DIR}/manual-installed.txt

    # Add a header for Perl modules list
    echo '[Perl Modules List]' >> ${PKG_INFO_DIR}/manual-installed.txt

    # List installed Perl modules
    perl -MExtUtils::Installed -e 'print join("\n", ExtUtils::Installed->new()->modules()),"\n";' >> ${PKG_INFO_DIR}/manual-installed.txt || \
        echo 'Could not list Perl modules' >> ${PKG_INFO_DIR}/manual-installed.txt
}

# Function to handle Python package listing
handle_python_packages() {
    echo '[Python Packages List]' >> ${PKG_INFO_DIR}/manual-installed.txt
    # List installed Python packages
    if command -v pip >/dev/null; then
        pip list >> ${PKG_INFO_DIR}/manual-installed.txt
    else
        echo 'pip not found' >> ${PKG_INFO_DIR}/manual-installed.txt
    fi
}

# Execute OS-specific tasks
if [ "$os_version" = "bionic" ]; then
    handle_bionic
elif [ "$os_version" = "xenial" ] || [ "$os_version" = "focal" ]; then
    handle_python_packages
fi
