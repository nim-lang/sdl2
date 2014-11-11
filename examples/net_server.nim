

import sdl2, sdl2/net

var
  local: TIPaddress
  server: TCPSocket

if net.Init() < 0: 
  quit($net.GetError())

if ResolveHost(addr local, nil, 2000) < 0:
  quit($net.GetError())

server = TCP_Open(addr local)
if server.isNil:
  quit($net.GetError())

var running = true
while running:
  let client = server.TCP_Accept
  if not client.isNil:

    let remote = TCP_GetPeerAddress(client)
    if remote.isNil:
      quit($net.GetError())
    else:
      echo "Host connected: ", ResolveIP(remote)

    var buffer: array[513,char]
    let buf = buffer[0].addr
    while true:
      if client.TCP_Recv(buf, 512) > 0:
        let s = $buf
        echo "<< ", s
        if s == "exit":
          echo "disconnecting.."
          break
        elif s == "shutdown":
          echo "quitting..."
          running = false
          break

    client.TCP_Close

server.TCP_Close
net.Quit()

