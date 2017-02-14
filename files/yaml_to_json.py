#! /usr/bin/env python
'''
Usage:
    python yaml_json.py < my.yaml > my.json
'''
import json
import sys
import yaml

def main():
    '''
    This is doc
    '''
    json_data = json.dumps(yaml.load(sys.stdin), separators=(',', ':'))
    sys.stdout.write(json_data)

if __name__ == "__main__":
    main()
