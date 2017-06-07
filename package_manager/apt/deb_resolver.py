import argparse

parser = argparse.ArgumentParser(
    description = "Downloads a deb package from a package source file"
)

parser.add_argument("--source-file", action='store', required=True,
                    help='The file path of the Packages.gz file')
parser.add_argument("--pkg-name", action='store', required=True,
                    help='The name of the package to search for and download')
parse.add_argument("--source-url", action='store', required=True,
                    help='The base url for the package list mirror')
parser.add_argument("--output-file", action='store', required=True,
                    help='The location to write the deb package')

def main():
    args = parser.parse_args()

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
                #If the line starts with a space or tab,
                #it is a continuation of the previous key
                if current_entry is None or current_key is None:
                    continue
                current_entry[current_key] += line.strip()
            elif separator in line:
                (key, value) = line.split(sep, 1)
                current_key = key.strip()
                current_entry[current_key] = value.strip()
            else:
                print "Unknown state"
            
        else:
            if current_entry:
                parsed_entries.append(current_entry)
            current_entry = {}
            current_key = None
    if current_entry:
        parsed_entries.append(current_entry)
    return parsed_entries
            
