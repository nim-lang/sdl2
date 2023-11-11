import sdl2/net

var
  local: IpAddress
  server: TcpSocket

if net.init() < 0:
  quit($net.getError())

if resolveHost(addr local, nil, 2000) < 0:
  quit($net.getError())

server = tcpOpen(addr local)
if server.isNil:
  quit($net.getError())

var running = true
while running:
  let client = server.accept()
  if not client.isNil:

    let remote = client.getPeerAddress()
    if remote.isNil:
      quit($net.getError())
    else:
      echo "Host connected: ", resolveIP(remote)

    var buffer: array[513,char]
    let buf = buffer[0].addr
    while true:
      if client.tcpRecv(buf, 512) > 0:
        let s = $cast[cstring](buf)
        echo "<< ", s
        if s == "exit":
          echo "disconnecting.."
          break
        elif s == "shutdown":
          echo "quitting..."
          running = false
          break

    client.close()

server.close()
net.quit()
