#
#  net:  An example cross-platform network library for use with SDL
#  Copyright (C) 1997-2013 Sam Lantinga <slouken@libsdl.org>
#  Copyright (C) 2012 Simeon Maxein <smaxein@googlemail.com>
#
#  This software is provided 'as-is', without any express or implied
#  warranty.  In no event will the authors be held liable for any damages
#  arising from the use of this software.
#
#  Permission is granted to anyone to use this software for any purpose,
#  including commercial applications, and to alter it and redistribute it
#  freely, subject to the following restrictions:
#
#  1. The origin of this software must not be misrepresented; you must not
#     claim that you wrote the original software. If you use this software
#     in a product, an acknowledgment in the product documentation would be
#     appreciated but is not required.
#  2. Altered source versions must be plainly marked as such, and must not be
#     misrepresented as being the original software.
#  3. This notice may not be removed or altered from any source distribution.

## Cross-platform networking library.
##
##
## Network Byte Order
## ------------------
## Also known as `Big-Endian`. Which means the most significant byte comes
## first in storage. Sparc and Motorola 68k based chips are MSB ordered.
##
## `Little-Endian` (LSB) is stored in the opposite order, with the least
## significant byte first in memory. Intel and AMD are two LSB machines.
##
## For network addresses, 1.2.3.4 is always stored as `{0x01 0x02 0x03 0x04}`.

import sdl2

when not defined(SDL_Static):
  when defined(windows):
    const LibName* = "SDL2_net.dll"
  elif defined(macosx):
    const LibName* = "libSDL2_net.dylib"
  else:
    const LibName* = "libSDL2_net(|-2.0).so(|.0)"
else:
  static: echo "SDL_Static option is deprecated and will soon be removed. Instead please use --dynlibOverride:SDL2."

type
  IpAddress* = object
    ## This type contains the information used
    ## to form network connections and sockets.
    host*: uint32           # 32-bit IPv4 host address
    port*: uint16           # 16-bit protocol port

  TcpSocket* = pointer
    ## This is an opaque data type used for TCP connections.
    ## This is a pointer, and so it could be `nil` at times.
    ## `nil` would indicate no socket has been established.

const
  INADDR_ANY* = 0x00000000 ## Used for listening on all network interfaces.
  INADDR_NONE* = 0xFFFFFFFF ## Which has limited applications.
  INADDR_LOOPBACK* = 0x7F000001
  INADDR_BROADCAST* = 0xFFFFFFFF
    ## Used as destination when sending a message to all clients
    ## on a subnet that allows broadcasts.

const
  SDLNET_MAX_UDPCHANNELS* = 32
    ## The maximum channels on a a UDP socket
const
  SDLNET_MAX_UDPADDRESSES* = 4
    ## The maximum addresses bound to a single UDP socket channel

type
  UDPsocket* = ptr object
    ## This is an opaque data type used for UDP sockets.
    ## This is a pointer, and so it could be `nil` at times.
    ## `nil` would indicate no socket has been established.

  UDPpacket* = object
    ## `channel` The (software) channel number for this packet.
    ## This can also be used as a priority value for the packet.
    ## If no channel is assigned, the value is `-1`.
    ##
    ## `data` The data contained in this packet, this is the meat.
    ##
    ## `len` This is the meaningful length of the data in bytes.
    ##
    ## `maxlen` This is size of the data buffer, which may be larger
    ## than the meaningful length. This is only used for packet creation
    ## on the senders side.
    ##
    ## `status` This contains the number of bytes sent, or a `-1` on errors,
    ## after sending. This is useless for a received packet.
    ##
    ## `address` This is the resolved `IPaddress` to be used when sending,
    ## or it is the remote source of a received packet.
    ##
    ## This struct is used with UDPsockets to send and receive data.
    ## It also helps keep track of a packets sending/receiving settings and
    ## status. The channels concept helps prioritize, or segregate differring
    ## types of data packets.
    channel*: cint          ## The src/dst channel of the packet
    data*: ptr uint8        ## The packet data
    len*: cint              ## The length of the packet data
    maxlen*: cint           ## The size of the data buffer
    status*: cint           ## packet status after sending
    address*: IpAddress
      ## The source/dest address of an incoming/outgoing packet

#*********************************************************************
# Hooks for checking sockets for available data
#*********************************************************************
type
  SocketSet* = pointer
    ## This is an opaque data type used for socket sets.
    ## This is a pointer, and so it could be `nil` at times.
    ## `nil` would indicate no socket set has been created.
type
  GenericSocketObj* = object
    ready*: cint
  GenericSocket* = ptr GenericSocketObj
    ## This data type is able to be used for both
    ## `UDPsocket` and `TCPsocket` types.
    ##
    ## `ready` Non-zero when data is ready to be read,
    ## or a server socket has a connection attempt ready to be accepted.
    ##
    ## After calling `net.checkSockets()`, if this socket is in
    ## `net.socketSet()` used, the `ready` will be set according
    ## to activity on the socket. This is the only real use for this type,
    ## as it doesn't help you know what type of socket it is.

when not defined(SDL_Static):
  {.push dynlib: LibName, callconv: cdecl.}

proc linkedVersion*(): ptr SDL_Version {.importc: "SDLNet_Linked_Version".}
  ## This procedure gets the version of the dynamically linked net library.
  # TODO Add an equivalent `NET_VERSION` macro (version template ?) and this
  # comment:
  # It should NOT be used to fill a version structure, instead you should
  # use the `version()` template.

proc init*(): cint {.importc: "SDLNet_Init".}
  ## Initialize the network API.
  ##
  ## SDL must be initialized before calls to procedures in this library,
  ## because this library uses utility procedures from the SDL library.
  ##
  ## `Return` `0` on success, `-1` on errors.

proc quit*() {.importc: "SDLNet_Quit".}
  ## Shutdown and cleanup the network API.
  ##
  ## After calling this all sockets are closed,
  ## and the net procedures should not be used.
  ## You may, of course, use `net.init()` to use the functionality again.

#*********************************************************************
# IPv4 hostname resolution API
#*********************************************************************

proc resolveHost*(address: ptr IpAddress; host: cstring; port: uint16): cint {.
  importc: "SDLNet_ResolveHost".}
  ## Resolve a host name and port to an IP address in network form.
  ##
  ## `address` points to the `IPaddress` that will be filled in.
  ## It doesn't need to be set before calling this,
  ## but it must be allocated in memory.
  ##
  ## `host` For connecting to a server, this is the hostname or IP
  ## in a string.
  ##
  ## For becoming a server, this is `nil`.
  ##
  ## If you do use `nil`, all network interfaces would be listened to for
  ## incoming connections, using the `INADDR_ANY` address.
  ##
  ## `port` For connecting to a server, this is the the servers listening
  ## port number.
  ##
  ## For becoming a server, this is the port to listen on.
  ##
  ## If you are just doing Domain Name Resolution functions, this can be `0`.
  ##
  ## Resolve the string `host`, and fill in the `IPaddress` pointed to by
  ## `address` with the resolved IP and the port number passed in through
  ## `port`.
  ##
  ## This is the best way to fill in the `IPaddress` struct for later use.
  ## This procedure does not actually open any sockets, it is used to prepare
  ## the arguments for the socket opening procedures.
  ##
  ## `WARNING:` this procedure will put the `host` and `port`
  ## into Network Byte Order into the `address` fields, so make sure
  ## you pass in the data in your hosts byte order (normally not an issue).
  ##
  ## `Return` `0` on success. `-1` on errors,
  ## plus `address.host` will be `INADDR_NONE`.
  ## An error would likely be that the address could not be resolved.
  ##
  ## For a server listening on all interfaces, on port 1234:
  ##
  ## .. code-block:: nim
  ##   # create a server type IPaddress on port 1234
  ##   var ipaddress: IPaddress
  ##   net.resolveHost(addr(ipaddress), nil, 1234)
  ##
  ## For a client connection to "host.domain.ext", at port 1234:
  ##
  ## .. code-block:: nim
  ##   # create an IPaddress for host name "host.domain.ext" on port 1234
  ##   # this is used by a client
  ##   var ipaddress: IPaddress
  ##   net.resolveHost(addr(ipaddress), "host.domain.ext", 1234)

proc resolveIP*(ip: ptr IpAddress): cstring {.importc: "SDLNet_ResolveIP".}
  ## Resolve an ip address to a host name in canonical form.
  ##
  ## `address` points to the `IPaddress` that will be resolved
  ## to a host name. The `address.port` is ignored.
  ##
  ## Resolve the IPv4 numeric address in `address.host`,
  ## and return the hostname as a string.
  ##
  ## `Note` that this procedure is not thread-safe.
  ##
  ## `Return` a valid char pointer (`cstring`) on success.
  ## The returned hostname will have host and domain, as in "host.domain.ext".
  ## `nil` is returned on errors, such as when it's not able to resolve
  ## the host name. The returned pointer is not to be freed.
  ## Each time you call this procedure the previous pointer's data will change
  ## to the new value, so you may have to copy it into a local buffer to keep
  ## it around longer.

proc getLocalAddresses*(addresses: ptr IpAddress; maxcount: cint): cint {.
  importc: "SDLNet_GetLocalAddresses".}
  ## Get the addresses of network interfaces on this system.
  ##
  ## `Return` the number of addresses saved in `addresses`.

#*********************************************************************
# TCP network API
#*********************************************************************

proc tcpOpen*(ip: ptr IpAddress): TcpSocket {.importc: "SDLNet_TCP_Open".}
  ## Open a TCP network socket.
  ##
  ## `ip` This points to the `IPaddress` that contains the resolved
  ## IP address and port number to use.
  ##
  ## If `ip.host` is `INADDR_NONE` or `INADDR_ANY`, this creates a local
  ## server socket on the given port, otherwise a TCP connection to the
  ## remote host and port is attempted. The address passed in should already
  ## be swapped to network byte order (addresses returned from
  ## `resolveHost()` are already in the correct form).
  ##
  ## `Return` a valid `TCPsocket` on success, which indicates a successful
  ## connection has been established, or a socket has been created that is
  ## valid to accept incoming TCP connections.
  ## `nil` is returned on errors, such as when it's not able to create
  ## a socket, or it cannot connect to host and/or port contained in ip.
  ##
  ## .. code-block:: nim
  ##   # connect to localhost at port 9999 using TCP (client)
  ##   var
  ##     ip: IPaddress
  ##     tcpsock: TCPsocket
  ##
  ##   if net.resolveHost(addr(ip), "localhost", 9999) == -1:
  ##     echo "net.resolveHost: ", net.getError()
  ##     quit(QuitFailure)
  ##
  ##   tcpsock = net.tcpOpen(addr(ip))
  ##   if tcpsock == nil:
  ##     echo "net.tcpOpen: ", net.getError()
  ##     quit(QuitFailure)
  ##
  ## .. code-block:: nim
  ##   # create a listening TCP socket on port 9999 (server)
  ##   var
  ##     ip: IPaddress
  ##     tcpsock: TCPsocket
  ##
  ##   if net.resolveHost(addr(ip), nil, 9999) == -1:
  ##     echo "net.resolveHost: ", net.getError()
  ##     quit(QuitFailure)
  ##
  ##   tcpsock = net.tcpOpen(addr(ip))
  ##   if tcpsock == nil:
  ##     echo "net.tcpOpen: ", net.getError()
  ##     quit(QuitFailure)

proc tcpAccept*(server: TcpSocket): TcpSocket {.importc: "SDLNet_TCP_Accept".}
proc accept*(server: TcpSocket): TcpSocket {.importc: "SDLNet_TCP_Accept".}
  ## Accept an incoming connection on the given `server` `TCPsocket`.
  ##
  ## `server` This is the server `TCPsocket` which was previously created
  ## by `net.tcpOpen()`.
  ##
  ## Do not use this procedure on a connected socket. Server sockets are never
  ## connected to a remote host. What you get back is a new `TCPsocket` that
  ## is connected to the remote host.
  ##
  ## This is a non-blocking call, so if no connections are there to be
  ## accepted, you will get a `nil` `TCPsocket` and the program will
  ## continue going.
  ##
  ## `Return` a valid `TCPsocket` on success, which indicates a successful
  ## connection has been established. `nil` is returned on errors, such as
  ## when it's not able to create a socket, or it cannot finish connecting to
  ## the originating host and port. There also may not be a connection attempt
  ## in progress, so of course you cannot accept nothing, and you get a `nil`
  ## in this case as well.
  ##
  ## .. code-block:: nim
  ##   # accept a connection coming in on server_tcpsock
  ##   var new_tcpsock: TCPsocket
  ##
  ##   new_tcpsock = server_tcpsock.accept()
  ##   if new_tcpsock == nil:
  ##     echo "accept: ", net.getError()
  ##   else:
  ##     # communicate over new_tcpsock

proc tcpGetPeerAddress*(sock: TcpSocket): ptr IpAddress {.
  importc: "SDLNet_TCP_GetPeerAddress".}
proc getPeerAddress*(sock: TcpSocket): ptr IpAddress {.
  importc: "SDLNet_TCP_GetPeerAddress".}
  ## Get the IP address of the remote system associated with the socket.
  ##
  ## `sock` This is a valid `TCPsocket`.
  ##
  ## Get the Peer's (the other side of the connection, the remote side,
  ## not the local side) IP address and port number.
  ##
  ## `Return` an `IPaddress`. `nil` is returned on errors,
  ## or when `sock` is a server socket.
  ##
  ## .. code-block:: nim
  ##   # get the remote IP and port
  ##   # var new_tcpsock: TCPsocket
  ##   var remote_ip: ptr IPaddress
  ##
  ##   remote_ip = new_tcpsock.getPeerAddress()
  ##   if remote_ip == nil:
  ##     echo "getPeerAddress: ", net.getError()
  ##     echo "This may be a server socket."
  ##   else:
  ##     # print the info in IPaddress or something else...

proc tcpSend*(sock: TcpSocket; data: pointer; len: cint): cint {.
  importc: "SDLNet_TCP_Send".}
proc send*(sock: TcpSocket; data: pointer; len: cint): cint {.
  importc: "SDLNet_TCP_Send".}
  ## Send `len` bytes of `data` over the non-server socket `sock`.
  ##
  ## `sock` This is a valid, connected, `TCPsocket`.
  ##
  ## `data` This is a pointer to the data to send over `sock`.
  ##
  ## `len` This is the length (in bytes) of the `data`.
  ##
  ## Send `data` of length `len` over the socket `sock`.
  ## This routine is not used for server sockets.
  ##
  ## `Return` the number of bytes sent. If the number returned is less than
  ## `len`, then an error occured, such as the client disconnecting.
  ##
  ## .. code-block:: nim
  ##   # send a hello over sock
  ##   # var sock: TCPsocket
  ##   var
  ##     msg = ['H', 'e', 'l', 'l', 'o', '!']
  ##
  ##   if sock.send(addr(msg), msg.len) < msg.len:
  ##     echo "send: ", net.getError()
  ##     # it may be ood to disconnect sock because it is likely invalid now

proc tcpRecv*(sock: TcpSocket; data: pointer; maxlen: cint): cint {.
  importc: "SDLNet_TCP_Recv".}
proc recv*(sock: TcpSocket; data: pointer; maxlen: cint): cint {.
  importc: "SDLNet_TCP_Recv".}
  ## Receive up to `maxlen` bytes of data over the non-server socket
  ## `sock`, and store them in the buffer pointed to by `data`.
  ##
  ## `sock` This is a valid, connected, `TCPsocket`.
  ##
  ## `data` This is a pointer to the buffer that receives the data
  ## from `sock`.
  ##
  ## `maxlen` This is the maximum length (in bytes) that will be read
  ## into `data`.
  ##
  ## Receive data of `exactly` length `maxlen` bytes from the socket
  ## `sock`, into the memory pointed to by `data`.
  ##
  ## This routine is not used for server sockets.
  ##
  ## Unless there is an error, or the connection is closed, the buffer will
  ## read `maxlen` bytes. If you read more than is sent from the other end,
  ## then it will wait until the full requested length is sent, or until the
  ## connection is closed from the other end.
  ##
  ## You may have to read 1 byte at a time for some applications, for instance,
  ## text applications where blocks of text are sent, but you want to read line
  ## by line. In that case you may want to find the newline characters yourself
  ## to break the lines up, instead of reading some inordinate amount of text
  ## which may contain many lines, or not even a full line of text.
  ##
  ## `Return` the number of bytes received. If the number returned is
  ## less than or equal to `0`, then an error occured, or the remote host
  ## has closed the connection.
  ##
  ## .. code-block:: nim
  ##   # receive some text from sock
  ##   # var sock: TCPsocket
  ##   const
  ##     MaxLen = 1024
  ##   var
  ##     msg: array[MaxLen, char]
  ##
  ##   if sock.recv(addr(msg[0]), MaxLen) <= 0:
  ##     # an error may have occured, but sometimes you can just ignore it
  ##     # it may be good to disconnect sock because it is likely invalid now
  ##
  ##   echo "Received: ", msg

proc tcpClose*(sock: TcpSocket) {.importc: "SDLNet_TCP_Close".}
proc close*(sock: TcpSocket) {.importc: "SDLNet_TCP_Close".}
  ## Close a TCP network socket.
  ##
  ## `sock` A valid `TCPsocket`.
  ## This can be a server or client type socket.
  ##
  ## This shutsdown, disconnects, and closes the `TCPsocket` sock.
  ##
  ## After this, you can be assured that this socket is not in use anymore.
  ## You can reuse the `sock` variable after this to open a new connection
  ## with `net.tcpOpen()`. Do not try to use any other procedures on
  ## a closed socket, as it is now invalid.
  ##
  ## `Return` nothing, this always succeeds for all we need to know.

#*********************************************************************
# UDP network API
#*********************************************************************

proc allocPacket*(size: cint): ptr UDPpacket {.importc: "SDLNet_AllocPacket".}
  ## Allocate a single UDP packet `size` bytes long.
  ##
  ## `size` Size, in bytes, of the data buffer to be allocated in the new
  ## `UDPpacket`. Zero is invalid.
  ##
  ## Create (via malloc) a new `UDPpacket` with a data buffer
  ## of `size` bytes.
  ## The new packet should be freed using `destroy()` when you are
  ## done using it.
  ##
  ## `Return` a pointer to a new empty `UDPpacket`.
  ## `nil` is returned on errors, such as out-of-memory.
  ##
  ## .. code-block:: nim
  ##   # create a new UDPpacket to hold 1024 bytes of data
  ##   var packet: ptr UDPpacket
  ##
  ##   packet = net.allocPacket(1024)
  ##   if packet == nil:
  ##     echo "net.allocPacket: ", net.getError()
  ##     # perhaps do something else since you can't make this packet
  ##   else:
  ##     # do stuff with this new packet
  ##     # destroy this packet when finished with it

proc resizePacket*(packet: ptr UDPpacket; newsize: cint): cint {.
  importc: "SDLNet_ResizePacket".}
proc resize*(packet: ptr UDPpacket; newsize: cint): cint {.
  importc: "SDLNet_ResizePacket".}
  ## Resize a single UDP packet `size` bytes long.
  ##
  ## `packet` A pointer to the `UDPpacket` to be resized.
  ##
  ## `size` The new desired size, in bytes, of the data buffer
  ## to be allocated in the `UDPpacket`.
  ##
  ## Resize a `UDPpacket`'s data buffer to `size` bytes. The old data
  ## buffer will not be retained, so the new buffer is invalid after this call.
  ##
  ## `Return` the new size of the data in the packet.
  ## If the number returned is less than what you asked for, that's an error.
  ##
  ## .. code-block:: nim
  ##   # resize a UDPpacket to hold 2048 bytes of data
  ##   # var packet: ptr UDPpacket
  ##   var newsize: int
  ##
  ##   newsize = packet.resize(2048)
  ##   if newsize < 2048:
  ##     echo "resize: ", net.getError()
  ##     # perhaps do something else since you didn't get the buffer you wanted
  ##   else:
  ##     # do stuff with the resized packet

proc freePacket*(packet: ptr UDPpacket) {.importc: "SDLNet_FreePacket".}
proc destroy*(packet: ptr UDPpacket) {.importc: "SDLNet_FreePacket".}
  ## Free a single UDP packet.
  ##
  ## `packet` A pointer to the `UDPpacket` to be freed from memory.
  ##
  ##  Free a `UDPpacket` from memory.
  ##  Do not use this `UDPpacket` after this procedure is called on it.
  ##
  ## `Return` nothing, this always succeeds.
  ##
  ## .. code-block:: nim
  ##   # free a UDPpacket
  ##   # var packet: ptr UDPpacket
  ##
  ##   destroy(packet)
  ##   packet = nil # just to help you know that it is freed

proc allocPacketV*(howmany: cint; size: cint): ptr ptr UDPpacket {.
  importc: "SDLNet_AllocPacketV".}
  ## Allocate a UDP packet vector (array of packets) of `howmany` packets,
  ## each `size` bytes long.
  ##
  ## `howmany` The number of UDPpackets to allocate.
  ##
  ## `size` Size, in bytes, of the data buffers to be allocated in the new
  ## UDPpackets. Zero is invalid.
  ##
  ## Create (via malloc) a vector of new UDPpackets, each with data buffers of
  ## `size` bytes. The new packet vector should be freed using
  ## `net.freePacketV()` when you are done using it. The returned vector
  ## is one entry longer than requested, for a terminating `nil`.
  ##
  ## `Return` a pointer to a new empty `UDPpacket` vector.
  ## `nil` is returned on errors, such as out-of-memory.
  ##
  ## .. code-block:: nim
  ##   # create a new UDPpacket vector to hold 1024 bytes of data in 10 packets
  ##   var packetV: ptr ptr UDPpacket
  ##
  ##   packetV = net.allocPacketV(10, 1024)
  ##   if packetV == nil:
  ##     echo "net.allocPacketV: ", net.getError()
  ##     # perhaps do something else since you can't make this packet
  ##   else:
  ##     # do stuff with this new packet vector
  ##     # net.freePacketV this packet vector when finished with it

proc freePacketV*(packetV: ptr ptr UDPpacket) {.importc: "SDLNet_FreePacketV".}
  ## Free a UDP packet vector (array of packets).
  ##
  ## `packetV` A pointer to the `UDPpacket` vector to be freed from memory.
  ##
  ## Free a `UDPpacket` vector from memory. Do not use this `UDPpacket`
  ## vector, or any `UDPpacket` in it, after this procedure is called on it.
  ##
  ## `Return` nothing, this always succeeds.
  ##
  ## .. code-block:: nim
  ##   # free a UDPpacket vector
  ##   # var packetV: ptr ptr UDPpacket
  ##
  ##   net.freePacketV(packetV)
  ##   packetV = nil # just to help you know that it is freed

proc udpOpen*(port: uint16): UDPsocket {.importc: "SDLNet_UDP_Open".}
  ## Open a UDP network socket.
  ##
  ## `port` This is the port number (in native byte order) on which to
  ## receive UDP packets. Most servers will want to use a known port number
  ## here so that clients can easily communicate with the server.
  ## This can also be zero, which then opens an anonymous unused port number,
  ## to most likely be used to send UDP packets from.
  ## The `port` should be given in native byte order, but is used
  ## internally in network (big endian) byte order, in addresses, etc.
  ## This allows other systems to send to this socket via a known port.
  ##
  ## Open a socket to be used for UDP packet sending and/or receiving.
  ## If a non-zero port is given it will be used, otherwise any open port
  ## number will be used automatically.
  ##
  ## Unlike TCP sockets, this socket does not require a remote host IP to
  ## connect to, this is because UDP ports are never actually connected like
  ## TCP ports are. This socket is able to send and receive directly after
  ## this simple creation.
  ##
  ## `Note` that below I say server, but clients may also open a specific
  ## port, though it is prefered that a client be more flexible, given that
  ## the port may be already allocated by another process, such as a server.
  ## In such a case you will not be able to open the socket, and your program
  ## will be stuck, so it is better to just use whatever port you are given by
  ## using a specified port of zero. Then the client will always work.
  ## The client can inform the server what port to talk back to, or the server
  ## can just look at the source of the packets it is receiving to know where
  ## to respond to.
  ##
  ## `Return` a valid `UDPsocket` on success. `nil` is returned on errors,
  ## such as when it's not able to create a socket, or it cannot assign the
  ## non-zero port as requested.
  ##
  ## .. code-block:: nim
  ##   # create a UDPsocket on port 6666 (server)
  ##   var udpsock: UDPsocket
  ##
  ##   udpsock = net.udpOpen(6666)
  ##   if udpsock == nil:
  ##     echo "net.udpOpen: ", net.getError()
  ##     quit(QuitFailure)
  ##
  ## .. code-block:: nim
  ##   # create a UDPsocket on any available port (client)
  ##   var udpsock: UDPsocket
  ##
  ##   udpsocket = net.udpOpen(0)
  ##   if udpsock == nil:
  ##     echo "net.udpOpen: ", net.getError()
  ##     quit(QuitFailure)

proc udpSetPacketLoss*(sock: UDPsocket; percent: cint) {.
  importc: "SDLNet_UDP_SetPacketLoss".}
proc setPacketLoss*(sock: UDPsocket; percent: cint) {.
  importc: "SDLNet_UDP_SetPacketLoss".}
  ## Bind the address `address` to the requested channel on the UDP socket.
  ##
  ## `sock` the UDPsocket on which to assign the address.
  ##
  ## `channel` The channel to assign address to.
  ## This should be less than `net.MAX_UDPCHANNELS`.
  ## If `-1` is used, then the first unbound channel will be used, this should
  ## only be used for incomming packet filtering, as it will find the first
  ## channel with less than `SDLNET_MAX_UDPADDRESSES` assigned to it and use
  ## that one.
  ## If the `channel` is already bound, this new address will be added to
  ## the list of valid source addresses for packets arriving on the channel.
  ## If the `channel` is not already bound, then the address becomes the
  ## primary address, to which all outbound packets on the channel are sent.
  ##
  ## `address` The resolved `IPaddress` to assign to the socket's channel.
  ## The host and port are both used. It is not helpful to bind `0.0.0.0`
  ## to a channel.
  ##
  ## Incoming packets are only allowed from bound addresses for the socket
  ## channel.
  ## All outgoing packets on that channel, regardless of the packets internal
  ## address, will attempt to send once on each bound address on that channel.
  ## You may assign up to `net.MAX_UDPADDRESSES` to each channel.
  ##
  ## `Return` the channel number that was bound. `-1` is returned on errors,
  ## such as no free channels, or this channel has `net.MAX_UDPADDRESSES`
  ## already assigned to it, or you have used a channel higher or equal to
  ## `net.MAX_UDPCHANNELS`, or lower than `-1`.
  ##
  ## .. code-block:: nim
  ##   # Bind address to the first free channel
  ##   # var udpsock: UDPsocket
  ##   # var address: IPaddress
  ##   var channel: int
  ##
  ##   channel = net.udpBind(udpsock, -1, address)
  ##   if channel == -1:
  ##     echo "net.udpBind: ", net.getError()
  ##     # do something because we failed to bind

proc udpBind*(sock: UDPsocket; channel: cint; address: ptr IpAddress): cint {.
  importc: "SDLNet_UDP_Bind".}
  ## Bind the address `address` to the requested channel on the UDP socket.
  ##
  ## `sock` the UDPsocket on which to assign the address.
  ##
  ## `channel` The channel to assign address to.
  ## This should be less than `net.MAX_UDPCHANNELS`.
  ## If `-1` is used, then the first unbound channel will be used, this should
  ## only be used for incomming packet filtering, as it will find the first
  ## channel with less than `SDLNET_MAX_UDPADDRESSES` assigned to it and use
  ## that one.
  ## If the `channel` is already bound, this new address will be added to
  ## the list of valid source addresses for packets arriving on the channel.
  ## If the `channel` is not already bound, then the address becomes the
  ## primary address, to which all outbound packets on the channel are sent.
  ##
  ## `address` The resolved `IPaddress` to assign to the socket's channel.
  ## The host and port are both used. It is not helpful to bind `0.0.0.0`
  ## to a channel.
  ##
  ## Incoming packets are only allowed from bound addresses for the socket
  ## channel.
  ## All outgoing packets on that channel, regardless of the packets internal
  ## address, will attempt to send once on each bound address on that channel.
  ## You may assign up to `net.MAX_UDPADDRESSES` to each channel.
  ##
  ## `Return` the channel number that was bound. `-1` is returned on errors,
  ## such as no free channels, or this channel has `net.MAX_UDPADDRESSES`
  ## already assigned to it, or you have used a channel higher or equal to
  ## `net.MAX_UDPCHANNELS`, or lower than `-1`.
  ##
  ## .. code-block:: nim
  ##   # Bind address to the first free channel
  ##   # var udpsock: UDPsocket
  ##   # var address: IPaddress
  ##   var channel: int
  ##
  ##   channel = net.udpBind(udpsock, -1, address)
  ##   if channel == -1:
  ##     echo "net.udpBind: ", net.getError()
  ##     # do something because we failed to bind

proc udpUnbind*(sock: UDPsocket; channel: cint) {.importc: "SDLNet_UDP_Unbind".}
proc unbind*(sock: UDPsocket; channel: cint) {.importc: "SDLNet_UDP_Unbind".}
  ## Unbind all addresses from the given channel.
  ##
  ## `sock` A valid `UDPsocket` to unbind addresses from.
  ##
  ## `channel` The channel to unbind the addresses from in the `UDPsocket`.
  ##
  ## This removes all previously assigned (bound) addresses from a socket
  ## channel. After this you may bind new addresses to the socket channel.
  ##
  ## `Return` nothing, this always succeeds.
  ##
  ## .. code-block:: nim
  ##   # unbind all addresses on the UDPsocket channel 0
  ##   # var udpsock: UDPsocket
  ##
  ##   udpsock.unbind(0)

proc udpGetPeerAddress*(sock: UDPsocket; channel: cint): ptr IpAddress {.
  importc: "SDLNet_UDP_GetPeerAddress".}
proc getPeerAddress*(sock: UDPsocket; channel: cint): ptr IpAddress {.
  importc: "SDLNet_UDP_GetPeerAddress".}
  ## Get the primary IP address of the remote system associated with the
  ## `socket` and `channel`.
  ##
  ## `sock` A valid `UDPsocket` that probably has an address assigned
  ## to the channel.
  ##
  ## `channel` The channel to get the primary address from in the socket.
  ## If the `channel` is `-1`, then the primary IP port of the UDP socket
  ## is returned - this is only meaningful for sockets opened with a specific
  ## port.
  ##
  ## Get the primary address assigned to this channel. Only the first bound address is returned. When channel is `-1`, get the port that this socket
  ## is bound to on the local computer, this only means something if you
  ## opened the socket with a specific port number.
  ## Do not free the returned `IPaddress` pointer.
  ##
  ## `Return` a pointer to an `IPaddress`.
  ## `nil` is returned for unbound channels and on any errors.
  ##
  ## .. code-block:: nim
  ##   # get the primary address bound to UDPsocket channel 0
  ##   # var udpsock: UDPsocket
  ##   var address: ptr IPaddress
  ##
  ##   address = udpsock.getPeerAddress(0)
  ##   if address == nil:
  ##     echo "getPeerAddress: ", net.getError()
  ##     # do something because we failed to get the address
  ##   else:
  ##     # perhaps print out address.host and address.port

proc udpSendV*(sock: UDPsocket; packets: ptr ptr UDPpacket;
               npackets: cint): cint {.importc: "SDLNet_UDP_SendV".}
proc send*(sock: UDPsocket; packets: ptr ptr UDPpacket;
               npackets: cint): cint {.importc: "SDLNet_UDP_SendV".}
  ## Send a vector of packets to the the channels specified within the packet.
  ##
  ## `sock` A valid `UDPsocket`.
  ##
  ## `packetV` The vector of packets to send.
  ##
  ## `npackets` number of packets in the `packetV` vector to send.
  ##
  ## Send `npackets` of `packetV` using the specified `sock` socket.
  ##
  ## Each packet is sent in the same way as in `sock.send(packet)`.
  ##
  ## `Note:` Don't forget to set the length of the packets in the `len`
  ## element of the `packets` you are sending!
  ##
  ## If the channel specified in the packet is `-1`, the packet will be sent
  ## to the address in the `src` member of the `packet`.
  ##
  ## Each packet will be updated with the status of the packet after it has
  ## been sent, `-1` if the packet send failed.
  ##
  ## `Return` the number of destinations sent to that worked, for each
  ## packet in the vector, all summed up. `0` is returned on errors.
  ##
  ## .. code-block:: nim
  ##   # send a vector of 10 packets using UDPsocket
  ##   # var udpsock: UDPsocket
  ##   # var packetV: ptr ptr UDPpacket
  ##   var numsent: int
  ##
  ##   numsent = udpsock.send(packetV, 10)
  ##   if numsent == 0:
  ##     echo "send: ", net.getError()
  ##     # do something because we failed to send
  ##     # this may just be because no addresses are bound to the channels...


proc udpSend*(sock: UDPsocket; channel: cint; packet: ptr UDPpacket): cint {.
  importc: "SDLNet_UDP_Send".}
proc send*(sock: UDPsocket; channel: cint; packet: ptr UDPpacket): cint {.
  importc: "SDLNet_UDP_Send".}
  ## Send a single `packet` to the specified `channel`.
  ##
  ## `sock` A valid `UDPsocket`.
  ##
  ## `channel` What channel to sent packet on.
  ##
  ## `packet` The packet to send.
  ##
  ## Send `packet` using the specified socket `sock`, using the specified
  ## `channel` or else the `packet`'s address.
  ##
  ## If `channel` is not `-1` then the packet is sent to all the `socket`
  ## channels bound addresses. If socket `sock`'s channel is not bound to
  ## any destinations, then the packet is not sent at all!
  ##
  ## If the channel is `-1`, then the `packet`'s address is used
  ## as the destination.
  ##
  ## `Note:` Don't forget to set the length of the packet in the `len`
  ## element of the `packet` you are sending!
  ##
  ## `Note:` The `packet.channel` will be set to the channel passed in to
  ## this procedure.
  ##
  ## `Note:` The maximum size of the packet is limited by the MTU (Maximum
  ## Transfer Unit) of the transport medium. It can be as low as `250` bytes
  ## for some PPP links, and as high as `1500` bytes for ethernet. Beyond that
  ## limit the packet will fragment, and make delivery more and more unreliable
  ## as lost fragments cause the whole packet to be discarded.
  ##
  ## `Return` The number of destinations sent to that worked.
  ## `0` is returned on errors.
  ##
  ## `Note` that since a channel can point to multiple destinations, there
  ## should be just as many packets sent, so dont assume it will always return
  ## `1` on success. Unfortunately there's no way to get the number of
  ## destinations bound to a channel, so either you have to remember
  ## the number bound, or just test for the zero return value indicating all
  ## channels failed.
  ##
  ## .. code-block:: nim
  ##   # send a packet using a UDPsocket,
  ##   # using the packet's channel as the channel
  ##   # var udpsock: UDPsocket
  ##   # var packet: ptr UDPpacket
  ##   var numsent: int
  ##
  ##   numsent = udpsock.send(packet.channel, packet)
  ##   if numsent == 0:
  ##     echo "send: ", net.getError()
  ##     # do something because we failed to send
  ##     # this may just be because no addresses are bound to the channel...
  ##
  ## Here's a way of sending one packet using it's internal channel setting.
  ## This is actually what `send()` ends up calling for you.
  ##
  ## .. code-block:: nim
  ##   # send a packet using a UDPsocket,
  ##   # using the packet's channel as the channel
  ##   # var udpsock: UDPsocket
  ##   # var packet: ptr UDPpacket
  ##   var numsent: int
  ##
  ##   numsent = sock.send(addr(packet), 1)
  ##   if nusment == 0:
  ##     echo "send: ", net.getError()
  ##     # do something because we failed to send
  ##     # this may just be because no addresses are bound to the channel...

proc udpRecvV*(sock: UDPsocket; packets: ptr ptr UDPpacket): cint {.
  importc: "SDLNet_UDP_RecvV".}
proc recv*(sock: UDPsocket; packets: ptr ptr UDPpacket): cint {.
  importc: "SDLNet_UDP_RecvV".}
  ## Receive a vector of pending packets from the UDP socket.
  ##
  ## `sock` A valid `UDPsocket`.
  ##
  ## `packet` The packet to receive into.
  ##
  ## Receive into a packet vector on the specified socket `sock`.
  ##
  ## `packetV` is a `nil` terminated array. Packets will be received until
  ## the `nil` is reached, or there are none ready to be received.
  ##
  ## This call is otherwise the same as `sock.recv(packet)`.
  ##
  ## The returned packets contain the source address and the channel they
  ## arrived on.  If they did not arrive on a bound channel, the the channel
  ## will be set to `-1`.
  ##
  ## The channels are checked in highest to lowest order, so if an address is
  ## bound to multiple channels, the highest channel with the source address
  ## bound will be returned.
  ##
  ## This procedure does not block, so can return `0` packets pending.
  ##
  ## `Return` the number of packets received.
  ## `0` is returned when no packets are received.
  ## `-1` is returned on errors.
  ##
  ## .. code-block:: nim
  ##   # try to receive some waiting udp packets
  ##   # var udpsock: UDPsocket
  ##   # var packetV: ptr ptr UDPpacket
  ##   var numrecv, i: int
  ##
  ##   numrecv = udpsock.recv(addr(packetV))
  ##   if numrecv == -1:
  ##     # handle error, perhaps just print out the net.getError string.
  ##
  ##   for i in 0..numrecv-1:
  ##     # do something with packetV[i]

proc udpRecv*(sock: UDPsocket; packet: ptr UDPpacket): cint {.
  importc: "SDLNet_UDP_Recv".}
proc recv*(sock: UDPsocket; packet: ptr UDPpacket): cint {.
  importc: "SDLNet_UDP_Recv".}
  ## Receive a single packet from the UDP socket.
  ##
  ## `sock` A valid `UDPsocket`.
  ##
  ## `packet` The packet to receive into.
  ##
  ## Receive a packet on the specified sock socket.
  ##
  ## The `packet` you pass in must have enough of a data size allocated for
  ## the incoming packet data to fit into. This means you should have knowledge
  ## of your size needs before trying to receive UDP packets.
  ## The packet will have it's address set to the remote sender's address.
  ##
  ## The `socket`'s channels are checked in highest to lowest order,
  ## so if an address is bound to multiple channels, the highest channel
  ## with the source address bound will be retreived before the lower bound
  ## channels. So, the packets channel will also be set to the highest numbered
  ## channel that has the remote address and port assigned to it. Otherwise the
  ## channel will `-1`, which you can filter out easily if you want to ignore
  ## unbound source address.
  ##
  ## `Note` that the local and remote channel numbers do not have to, and
  ## probably won't, match, as they are only local settings, they are not sent
  ## in the packet.
  ##
  ## This is a non-blocking call, meaning if there's no data ready to be
  ## received the procedure will return.
  ##
  ## `Return` `1` is returned when a packet is received.
  ## `0` is returned when no packets are received.
  ## `-1` is returned on errors.
  ##
  ## .. code-block:: nim
  ##   # try to receive a waiting udp packet
  ##   # var udpsock: UDPsocket
  ##   var
  ##     packet: UDPpacket
  ##     numrecv: int
  ##
  ##   numrecv = udpsock.recv(addr(packet))
  ##   if numrecv > 0:
  ##     # do something with packet

proc udpClose*(sock: UDPsocket) {.importc: "SDLNet_UDP_Close".}
proc close*(sock: UDPsocket) {.importc: "SDLNet_UDP_Close".}
  ## Close a UDP network socket.
  ##
  ## `sock` A valid `UDPsocket` to shutdown, close, and free.
  ##
  ## Shutdown, close, and free a `UDPsocket`.
  ## Don't use the `UDPsocket` after calling this, except to open a new one.
  ##
  ## `Return` nothing, this always succeeds.
  ##
  ## .. code-block:: nim
  ##   # var udpsock: UDPsocket
  ##
  ##   close(udpsock)
  ##   udpsock = nil # this helps us know that this
  ##                 # UDPsocket is not valid anymore

proc allocSocketSet*(maxsockets: cint): SocketSet {.
  importc: "SDLNet_AllocSocketSet".}
  ## Allocate a socket set for use with `net.checkSockets()`.
  ##
  ## `maxsockets` The maximum number of sockets you will want to watch.
  ##
  ## Create a socket set that will be able to watch up to maxsockets number
  ## of sockets. The same socket set can be used for both UDP and TCP sockets.
  ##
  ## `Return` A new, empty, `SocketSet`.
  ## `nil` is returned on errors, such as out-of-memory.
  ##
  ## .. code-block:: nim
  ##   # create a socket set to handle up to 16 sockets
  ##   var sset: SocketSet
  ##
  ##   sset = net.allocSocketSet(16)
  ##   if sset == nil:
  ##     echo "net.allocSocketSet: ", net.getError()
  ##     quit(QuitFailure) # most of the time this is a major error,
  ##                       # but do what you want

proc addSocket*(set: SocketSet; sock: GenericSocket): cint {.
  importc: "SDLNet_AddSocket".}
proc incl*(set: SocketSet; sock: GenericSocket): cint {.
  importc: "SDLNet_AddSocket".}
  ## Add a socket to a set of sockets to be checked for available data.
  ##
  ## `set` The socket set to add this socket to.
  ##
  ## `sock` The socket to add to the socket set.
  ##
  ## Add a socket to a socket set that will be watched.
  ##
  ## TCP and UDP sockets should be added using the corrosponding template
  ## (as in net.tcpAddSocket for a TCP socket). The generic socket
  ## procedure will be called by the TCP and UDP templates.
  ## Both TCP and UDP sockets may be added to the same socket set.
  ## TCP clients and servers may all be in the same socket set.
  ## There is no limitation on the sockets in the socket set,
  ## other than they have been opened.
  ##
  ## `Return` the number of sockets used in the set on success.
  ## `-1` is returned on errors.
  ##
  ## **See also:**
  ## * `tcpAddSocket proc<#tcpAddSocket,SocketSet,TcpSocket>`_
  ## * `incl proc<#incl,SocketSet,UDPSocket>`_
  ##
  ## .. code-block:: nim
  ##   # add two sockets to a socket set
  ##   # var sset: SocketSet
  ##   # var udpsock: UDPsocket
  ##   # var tcpsock: TCPsocket
  ##   var numused: int
  ##
  ##   numused = sset.incl udpsock
  ##   if numused == -1:
  ##     echo "incl: ", net.getError()
  ##     # perhaps you need to restart the set and make it bigger..
  ##
  ##   numused = sset.incl tcpsock
  ##   if numused == -1:
  ##     echo "incl: ", net.getError()
  ##     # perhaps you need to restart the set and make it bigger...

proc delSocket*(set: SocketSet; sock: GenericSocket): cint {.
  importc: "SDLNet_DelSocket".}
proc excl*(set: SocketSet; sock: GenericSocket): cint {.
  importc: "SDLNet_DelSocket".}
  ## Remove a socket from a set of sockets to be checked for available data.
  ##
  ## `sset` The socket set to remove this socket from.
  ##
  ## `sock` The socket to remove from the socket set.
  ##
  ## Remove a socket from a socket set.
  ##
  ## Use this before closing a socket that you are watching with a socket set.
  ## This doesn't close the socket. Call the appropriate template for TCP or
  ## UDP sockets. The generic socket procedure will be called by the TCP and
  ## UDP templates.
  ##
  ## `Return` the number of sockets used in the set on success.
  ## `-1` is returned on errors.
  ##
  ## **See also:**
  ## * `tcpDelSocket proc<#tcpDelSocket,SocketSet,TcpSocket>`_
  ## * `udpDelSocket proc<#udpDelSocket,SocketSet,UdpSocket>`_
  ##
  ## .. code-block:: nim
  ##   # remove two sockets from a socket set
  ##   # var sset: SocketSet
  ##   # udpsock: UDPsocket
  ##   # tcpsock: TCPsocket
  ##   var numused: int
  ##
  ##   numused = sset.excl udpsock
  ##   if numused == -1:
  ##     echo "excl: ", net.getError()
  ##
  ##   numused = sset.excl tcpsock
  ##   if numused == -1:
  ##     echo "excl: ", net.getError()
  ##     # perhaps the socket is not in the set

proc checkSockets*(set: SocketSet; timeout: uint32): cint {.
  importc: "SDLNet_CheckSockets".}
  ## This procedure checks to see if data is available for reading on the
  ## given set of sockets.
  ##
  ## `set` The socket set to check.
  ##
  ## `timeout` The amount of time (in milliseconds).
  ## `0` means no waiting.
  ## `-1` means to wait over 49 days! (think about it)
  ##
  ## Check all sockets in the socket set for activity. If a non-zero
  ## `timeout` is given then this procedure will wait for activity,
  ## or else it will wait for `timeout` milliseconds.
  ##
  ## `Note:` "activity" also includes disconnections and other errors,
  ## which would be determined by a failed read/write attempt.
  ##
  ## `Return` the number of sockets with activity.
  ## `-1` is returned on errors,
  ## and you may not get a meaningful error message.
  ## `-1` is also returned for an empty set (nothing to check).
  ##
  ## .. code-block:: nim
  ##   # wait for up to 1 second for network activity
  ##   # var sset: SocketSet
  ##   var numready: int
  ##
  ##   numready = net.checkSockets(sset, 1000)
  ##   if numready == -1:
  ##     echo "net.checkSockets: ", net.getError()
  ##     # most of the time this is a system error
  ##   else:
  ##     if numready > 0:
  ##       echo "There are ", numready, " sockets with activity!"
  ##       # check all sockets with net.socketReady
  ##       # and handle the active ones.

proc freeSocketSet*(set: SocketSet) {.importc: "SDLNet_FreeSocketSet".}
proc destroy*(set: SocketSet) {.importc: "SDLNet_FreeSocketSet".}
  ## Free a set of sockets allocated by `allocSocketSet()`.
  ##
  ## `set` The socket set to free from memory.
  ##
  ## Free the socket set from memory.
  ##
  ## Do not reference the `set` after this call,
  ## except to allocate a new one.
  ##
  ## `Return` nothing, this call always succeeds.
  ##
  ## .. code-block:: nim
  ##   # free a socket set
  ##   # var set: SocketSet
  ##
  ##   destroy(set)
  ##   set = nil # this helps us remember that this set is not allocated

#*********************************************************************
# Error reporting functions
#*********************************************************************
proc setError*(fmt: cstring) {.varargs, importc: "SDLNet_SetError".}
proc getError*(): cstring {.importc: "SDLNet_GetError".}
#*********************************************************************
# Inline functions to read/write network data
#*********************************************************************
# Warning, some systems have data access alignment restrictions

proc write16* (value: uint16, dest: pointer) {.importc: "SDLNet_Write16".}
  ## Write a 16-bit value to network packet buffer.
  ##
  ## `value` The 16bit number to put into the area buffer.
  ##
  ## `area` The pointer into a data buffer, at which to put the number.
  ##
  ## Put the 16bit (a short on 32bit systems) value into the data buffer area
  ## in network byte order. This helps avoid byte order differences between
  ## two systems that are talking over the network. The value can be a signed
  ## number, the unsigned parameter type doesn't affect the data. The area
  ## pointer need not be at the beginning of a buffer, but must have at least
  ## 2 bytes of space left, including the byte currently pointed at.

proc write32* (value: uint32, dest: pointer) {.importc: "SDLNet_Write32".}
  ## Write a 32-bit value to network packet buffer.
  ##
  ## `value` The 32bit number to put into the area buffer.
  ##
  ## `area` The pointer into a data buffer, at which to put the number.
  ##
  ## Put the 32bit (a long on 32bit systems) value into the data buffer area
  ## in network byte order. This helps avoid byte order differences between
  ## two systems that are talking over the network. The value can be a signed
  ## number, the unsigned parameter type doesn't affect the data. The area
  ## pointer need not be at the beginning of a buffer, but must have at least
  ## 4 bytes of space left, including the byte currently pointed at.

proc read16* (src: pointer): uint16 {.importc: "SDLNet_Read16".}
  ## Read a 16-bit value from network packet buffer.
  ##
  ## `area` The pointer into a data buffer, at which to get the number from.
  ##
  ## Get a 16bit (a short on 32bit systems) value from the data buffer area
  ## which is in network byte order. This helps avoid byte order differences
  ## between two systems that are talking over the network. The returned value
  ## can be a signed number, the unsigned parameter type doesn't affect the
  ## data. The area pointer need not be at the beginning of a buffer, but must
  ## have at least 2 bytes of space left, including the byte currently pointed
  ## at.

proc read32* (src: pointer): uint32 {.importc: "SDLNet_Read32".}
  ## Read a 32-bit value from network packet buffer.
  ##
  ## `area` The pointer into a data buffer, at which to get the number from.
  ##
  ## Get a 32bit (a long on 32bit systems) value from the data buffer area
  ## which is in network byte order. This helps avoid byte order differences
  ## between two systems that are talking over the network. The returned value
  ## can be a signed number, the unsigned parameter type doesn't affect the
  ## data. The area pointer need not be at the beginning of a buffer, but must
  ## have at least 4 bytes of space left, including the byte currently pointed
  ## at.

when not defined(SDL_Static):
  {.pop.}

proc tcpAddSocket*(set: SocketSet; sock: TcpSocket): cint =
  addSocket(set, cast[GenericSocket](sock))
proc incl*(set: SocketSet; sock: TcpSocket): cint =
  addSocket(set, cast[GenericSocket](sock))

proc udpAddSocket*(set: SocketSet; sock: UDPsocket): cint =
  addSocket(set, cast[GenericSocket](sock))
proc incl*(set: SocketSet; sock: UDPsocket): cint =
  addSocket(set, cast[GenericSocket](sock))


proc tcpDelSocket*(set: SocketSet; sock: TcpSocket): cint {.inline.} =
  delSocket(set, cast[GenericSocket](sock))
proc excl*(set: SocketSet; sock: TcpSocket): cint {.inline.} =
  delSocket(set, cast[GenericSocket](sock))

proc udpDelSocket*(set: SocketSet; sock: UDPsocket): cint {.inline.} =
  delSocket(set, cast[GenericSocket](sock))
proc excl*(set: SocketSet; sock: UDPsocket): cint {.inline.} =
  delSocket(set, cast[GenericSocket](sock))

proc socketReady* (sock: GenericSocket): bool =
  ## Check whether a socket has been marked as active.
  ##
  ## `sock` The socket to check for activity.
  ## Both `UDPsocket` and `TCPsocket` can be used with this procedure.
  ##
  ## This procedure should only be used on a socket in a socket set,
  ## and that set has to have had `net.CheckSockets()` called upon it.
  ##
  ## `Return` non-zero for activity. `0` is returned for no activity.
  ##
  ## .. code-block:: nim
  ##   # wait forever for a connection attempt
  ##   # var sset: SocketSet
  ##   # var serversock, client: TCPsocket
  ##   var numready: int
  ##
  ##   numready = net.checkSockets(sset, 1000)
  ##   if numready == -1:
  ##     echo "net.checkSockets: ", net.getError()
  ##     # most of the time this is a system error
  ##   elif numready > 0:
  ##     echo "There are ", numready, " sockets with activity!"
  ##     # check all sockets with net.socketReady
  ##     # and hanlde the active ones.
  ##     if net.socketReady(serversock):
  ##       client = net.tcpAccept(serversock)
  ##       if client:
  ##         # play with the client.
  ##
  ## To just quickly do network handling with no waiting, we do this.
  ##
  ## .. code-block:: nim
  ##   # check for, and handle UDP data
  ##   # var sset: SocketSet
  ##   # udpsock: UDPsocket
  ##   # packet: ptr UDPpacket
  ##   var numready, numpkts: int
  ##
  ##   numready = net.checkSockets(sset, 0)
  ##   if numready == -1:
  ##     echo "net.checkSockets: ", net.getError()
  ##     # most of the time this is a system error
  ##   elif numready > 0:
  ##     echo "There are ", numready, " sockets with activity!"
  ##     # check all sockets with net.socketReady
  ##     # and handle the active ones.
  ##     if udpsock.recv(addr(packet))
  ##     if numpkts > 0:
  ##       # process the packet.

  not(sock.isNil) and sock.ready > 0
