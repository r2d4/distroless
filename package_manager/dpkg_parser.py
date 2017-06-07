import argparse
import gzip
import re

parser = argparse.ArgumentParser(
    description = "Downloads a deb package from a package source file"
)

parser.add_argument("--packages-file", action='store', required=True,
                    help='The file path of the Packages.gz file')
parser.add_argument("--package-name", action='store', required=True,
                    help='The name of the package to search for and download')
parser.add_argument("--mirror-url", action='store', required=True,
                    help='The base url for the package list mirror')
parser.add_argument("--output-file", action='store', required=True,
                    help='The location to write the deb package')

def main():
    # args = parser.parse_args()
    packages_file = "/home/matt/Downloads/Packages.gz"
    with gzip.open(packages_file, 'rb') as f:
        data = f.read()
        metadata = parse_package_metadata(data, ':')

def parse_package_metadata(data, separator):
    metadata = []
    found = False

    raw_entries = [line.rstrip() for line in data.splitlines()]
    parsed_entries = []
    current_key = None
    current_entry = {}

    for line in raw_entries:
        if line:
            if re.match(r'\s', line):
                #If the line starts with indentation,
                #it is a continuation of the previous key
                if current_entry is None or current_key is None:
                    raise Exception("Found incorrect indention on line:" + line)
                current_entry[current_key] += line.strip()
            elif separator in line:
                (key, value) = line.split(separator, 1)
                current_key = key.strip()
                if current_key in current_entry:
                    raise Exception("Duplicate key for package metadata:" + current_key + "\n" + current_entry)
                current_entry[current_key] = value.strip()
            else:
                raise Exception("Valid line, but no delimiter or indentation:" + line)
        else:
            if current_entry:
                parsed_entries.append(current_entry)
            current_entry = {}
            current_key = None
    if current_entry:
        parsed_entries.append(current_entry)
    return parsed_entries
            
if __name__ == "__main__":
    main()