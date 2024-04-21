from pwn import * # pip install pwntools
from Cryptodome.Util.number import bytes_to_long, long_to_bytes

import json
import codecs
import base64

r = remote('socket.cryptohack.org', 13377, level = 'debug')

def json_recv():
    line = r.recvline()
    return json.loads(line.decode())

def json_send(hsh):
    request = json.dumps(hsh).encode()
    r.sendline(request)

def decode_data(received):
    encoding = received["type"]
    encoded = received["encoded"]
    if encoding == "base64":
        decoded = base64.b64decode(encoded).decode()
    elif encoding == "hex":
        decoded = bytes.fromhex(encoded).decode()
    elif encoding == "rot13":
        decoded = codecs.encode(encoded, 'rot_13')
    elif encoding == "bigint":
        decoded = long_to_bytes(int(encoded,16)).decode()
    elif encoding == "utf-8":
        decoded = "".join([chr(b) for b in encoded])
    return {"decoded": decoded}



received = json_recv()

while(received):
    print("Received type: ")
    print(received["type"])
    print("Received encoded value: ")
    print(received["encoded"])
    to_send = decode_data(received)
    json_send(to_send)
    received = json_recv()
