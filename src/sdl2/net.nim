#
#  SDL_net:  An example cross-platform network library for use with SDL
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
#
# $Id$
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
    host*: uint32           # 32-bit IPv4 host address
    port*: uint16           # 16-bit protocol port

  TcpSocket* = pointer

const
  INADDR_ANY* = 0x00000000
  INADDR_NONE* = 0xFFFFFFFF
  INADDR_LOOPBACK* = 0x7F000001
  INADDR_BROADCAST* = 0xFFFFFFFF
# The maximum channels on a a UDP socket
const
  SDLNET_MAX_UDPCHANNELS* = 32
# The maximum addresses bound to a single UDP socket channel
const
  SDLNET_MAX_UDPADDRESSES* = 4
type
  UDPsocket* = ptr object
  UDPpacket* = object
    channel*: cint          # The src/dst channel of the packet
    data*: ptr uint8        # The packet data
    len*: cint              # The length of the packet data
    maxlen*: cint           # The size of the data buffer
    status*: cint           # packet status after sending
    address*: IpAddress     # The source/dest address of an incoming/outgoing packet

#*********************************************************************
# Hooks for checking sockets for available data
#*********************************************************************
type
  SocketSet* = pointer
# Any network socket can be safely cast to this socket type
type
  GenericSocketObj* = object
    ready*: cint
  GenericSocket* = ptr GenericSocketObj

when not defined(SDL_Static):
  {.push dynlib: LibName, callconv: cdecl.}
# This function gets the version of the dynamically linked SDL_net library.
#   it should NOT be used to fill a version structure, instead you should
#   use the SDL_NET_VERSION() macro.
#

proc linkedVersion*(): ptr SDL_Version {.importc: "SDLNet_Linked_Version".}
# Initialize/Cleanup the network API
#   SDL must be initialized before calls to functions in this library,
#   because this library uses utility functions from the SDL library.
#
proc init*(): cint {.importc: "SDLNet_Init".}
proc quit*() {.importc: "SDLNet_Quit".}
#*********************************************************************
# IPv4 hostname resolution API
#*********************************************************************

# Resolve a host name and port to an IP address in network form.
#   If the function succeeds, it will return 0.
#   If the host couldn't be resolved, the host portion of the returned
#   address will be INADDR_NONE, and the function will return -1.
#   If 'host' is NULL, the resolved host will be set to INADDR_ANY.
#
proc resolveHost*(address: ptr IpAddress; host: cstring; port: uint16): cint {.importc: "SDLNet_ResolveHost".}
# Resolve an ip address to a host name in canonical form.
#   If the ip couldn't be resolved, this function returns NULL,
#   otherwise a pointer to a static buffer containing the hostname
#   is returned.  Note that this function is not thread-safe.
#
proc resolveIP*(ip: ptr IpAddress): cstring {.importc: "SDLNet_ResolveIP".}
# Get the addresses of network interfaces on this system.
#   This returns the number of addresses saved in 'addresses'
#
proc getLocalAddresses*(addresses: ptr IpAddress; maxcount: cint): cint {.importc: "SDLNet_GetLocalAddresses".}
#*********************************************************************
# TCP network API
#*********************************************************************

# Open a TCP network socket
#   If ip.host is INADDR_NONE or INADDR_ANY, this creates a local server
#   socket on the given port, otherwise a TCP connection to the remote
#   host and port is attempted. The address passed in should already be
#   swapped to network byte order (addresses returned from
#   SDLNet_ResolveHost() are already in the correct form).
#   The newly created socket is returned, or NULL if there was an error.
#
proc tcpOpen*(ip: ptr IpAddress): TcpSocket {.importc: "SDLNet_TCP_Open".}
# Accept an incoming connection on the given server socket.
#   The newly created socket is returned, or NULL if there was an error.
#
proc tcpAccept*(server: TcpSocket): TcpSocket {.importc: "SDLNet_TCP_Accept".}
# Get the IP address of the remote system associated with the socket.
#   If the socket is a server socket, this function returns NULL.
#
proc tcpGetPeerAddress*(sock: TcpSocket): ptr IpAddress {.importc: "SDLNet_TCP_GetPeerAddress".}
# Send 'len' bytes of 'data' over the non-server socket 'sock'
#   This function returns the actual amount of data sent.  If the return value
#   is less than the amount of data sent, then either the remote connection was
#   closed, or an unknown socket error occurred.
#
proc tcpSend*(sock: TcpSocket; data: pointer; len: cint): cint {.importc: "SDLNet_TCP_Send".}
# Receive up to 'maxlen' bytes of data over the non-server socket 'sock',
#   and store them in the buffer pointed to by 'data'.
#   This function returns the actual amount of data received.  If the return
#   value is less than or equal to zero, then either the remote connection was
#   closed, or an unknown socket error occurred.
#
proc tcpRecv*(sock: TcpSocket; data: pointer; maxlen: cint): cint {.importc: "SDLNet_TCP_Recv".}
# Close a TCP network socket
proc tcpClose*(sock: TcpSocket) {.importc: "SDLNet_TCP_Close".}
#*********************************************************************
# UDP network API
#*********************************************************************

# Allocate/resize/free a single UDP packet 'size' bytes long.
#   The new packet is returned, or NULL if the function ran out of memory.
#
proc allocPacket*(size: cint): ptr UDPpacket {.importc: "SDLNet_AllocPacket".}
proc resizePacket*(packet: ptr UDPpacket; newsize: cint): cint {.importc: "SDLNet_ResizePacket".}
proc freePacket*(packet: ptr UDPpacket) {.importc: "SDLNet_FreePacket".}
# Allocate/Free a UDP packet vector (array of packets) of 'howmany' packets,
#   each 'size' bytes long.
#   A pointer to the first packet in the array is returned, or NULL if the
#   function ran out of memory.
#
proc allocPacketV*(howmany: cint; size: cint): ptr ptr UDPpacket {.importc: "SDLNet_AllocPacketV".}
proc freePacketV*(packetV: ptr ptr UDPpacket) {.importc: "SDLNet_FreePacketV".}
# Open a UDP network socket
#   If 'port' is non-zero, the UDP socket is bound to a local port.
#   The 'port' should be given in native byte order, but is used
#   internally in network (big endian) byte order, in addresses, etc.
#   This allows other systems to send to this socket via a known port.
#
proc udpOpen*(port: uint16): UDPsocket {.importc: "SDLNet_UDP_Open".}
# Set the percentage of simulated packet loss for packets sent on the socket.
#
proc udpSetPacketLoss*(sock: UDPsocket; percent: cint) {.importc: "SDLNet_UDP_SetPacketLoss".}
# Bind the address 'address' to the requested channel on the UDP socket.
#   If the channel is -1, then the first unbound channel that has not yet
#   been bound to the maximum number of addresses will be bound with
#   the given address as it's primary address.
#   If the channel is already bound, this new address will be added to the
#   list of valid source addresses for packets arriving on the channel.
#   If the channel is not already bound, then the address becomes the primary
#   address, to which all outbound packets on the channel are sent.
#   This function returns the channel which was bound, or -1 on error.
#
proc udpBind*(sock: UDPsocket; channel: cint; address: ptr IpAddress): cint {.importc: "SDLNet_UDP_Bind".}
# Unbind all addresses from the given channel
proc udpUnbind*(sock: UDPsocket; channel: cint) {.importc: "SDLNet_UDP_Unbind".}
# Get the primary IP address of the remote system associated with the
#   socket and channel.  If the channel is -1, then the primary IP port
#   of the UDP socket is returned -- this is only meaningful for sockets
#   opened with a specific port.
#   If the channel is not bound and not -1, this function returns NULL.
#
proc udpGetPeerAddress*(sock: UDPsocket; channel: cint): ptr IpAddress {.importc: "SDLNet_UDP_GetPeerAddress".}
# Send a vector of packets to the the channels specified within the packet.
#   If the channel specified in the packet is -1, the packet will be sent to
#   the address in the 'src' member of the packet.
#   Each packet will be updated with the status of the packet after it has
#   been sent, -1 if the packet send failed.
#   This function returns the number of packets sent.
#
proc udpSendV*(sock: UDPsocket; packets: ptr ptr UDPpacket;
               npackets: cint): cint {.importc: "SDLNet_UDP_SendV".}
# Send a single packet to the specified channel.
#   If the channel specified in the packet is -1, the packet will be sent to
#   the address in the 'src' member of the packet.
#   The packet will be updated with the status of the packet after it has
#   been sent.
#   This function returns 1 if the packet was sent, or 0 on error.
#
#   NOTE:
#   The maximum size of the packet is limited by the MTU (Maximum Transfer Unit)
#   of the transport medium.  It can be as low as 250 bytes for some PPP links,
#   and as high as 1500 bytes for ethernet.
#
proc udpSend*(sock: UDPsocket; channel: cint; packet: ptr UDPpacket): cint {.importc: "SDLNet_UDP_Send".}
# Receive a vector of pending packets from the UDP socket.
#   The returned packets contain the source address and the channel they arrived
#   on.  If they did not arrive on a bound channel, the the channel will be set
#   to -1.
#   The channels are checked in highest to lowest order, so if an address is
#   bound to multiple channels, the highest channel with the source address
#   bound will be returned.
#   This function returns the number of packets read from the network, or -1
#   on error.  This function does not block, so can return 0 packets pending.
#
proc udpRecvV*(sock: UDPsocket; packets: ptr ptr UDPpacket): cint {.importc: "SDLNet_UDP_RecvV".}
# Receive a single packet from the UDP socket.
#   The returned packet contains the source address and the channel it arrived
#   on.  If it did not arrive on a bound channel, the the channel will be set
#   to -1.
#   The channels are checked in highest to lowest order, so if an address is
#   bound to multiple channels, the highest channel with the source address
#   bound will be returned.
#   This function returns the number of packets read from the network, or -1
#   on error.  This function does not block, so can return 0 packets pending.
#
proc udpRecv*(sock: UDPsocket; packet: ptr UDPpacket): cint {.importc: "SDLNet_UDP_Recv".}
# Close a UDP network socket
proc udpClose*(sock: UDPsocket) {.importc: "SDLNet_UDP_Close".}

# Allocate a socket set for use with SDLNet_CheckSockets()
#   This returns a socket set for up to 'maxsockets' sockets, or NULL if
#   the function ran out of memory.
#
proc allocSocketSet*(maxsockets: cint): SocketSet {.importc: "SDLNet_AllocSocketSet".}
# Add a socket to a set of sockets to be checked for available data
proc addSocket*(set: SocketSet; sock: GenericSocket): cint {.importc: "SDLNet_AddSocket".}

# Remove a socket from a set of sockets to be checked for available data
proc delSocket*(set: SocketSet; sock: GenericSocket): cint {.importc: "SDLNet_DelSocket".}

# This function checks to see if data is available for reading on the
#   given set of sockets.  If 'timeout' is 0, it performs a quick poll,
#   otherwise the function returns when either data is available for
#   reading, or the timeout in milliseconds has elapsed, which ever occurs
#   first.  This function returns the number of sockets ready for reading,
#   or -1 if there was an error with the select() system call.
#
proc checkSockets*(set: SocketSet; timeout: uint32): cint {.importc: "SDLNet_CheckSockets".}
# After calling CheckSockets(), you can use this function on a
#   socket that was in the socket set, to find out if data is available
#   for reading.
#

# Free a set of sockets allocated by SDL_NetAllocSocketSet()
proc freeSocketSet*(set: SocketSet) {.importc: "SDLNet_FreeSocketSet".}
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
proc write32* (value: uint32, dest: pointer) {.importc: "SDLNet_Write32".}
proc read16* (src: pointer): uint16 {.importc: "SDLNet_Read16".}
proc read32* (src: pointer): uint32 {.importc: "SDLNet_Read32".}

when not defined(SDL_Static):
  {.pop.}

proc tcpAddSocket*(set: SocketSet; sock: TcpSocket): cint =
  addSocket(set, cast[GenericSocket](sock))

proc udpAddSocket*(set: SocketSet; sock: UDPsocket): cint =
  addSocket(set, cast[GenericSocket](sock))


proc tcpDelSocket*(set: SocketSet; sock: TcpSocket): cint {.inline.} =
  delSocket(set, cast[GenericSocket](sock))

proc udpDelSocket*(set: SocketSet; sock: UDPsocket): cint {.inline.} =
  delSocket(set, cast[GenericSocket](sock))


##define SDLNet_SocketReady(sock) _SDLNet_SocketReady((SDLNet_GenericSocket)(sock))
#proc _SDLNet_SocketReady*(sock: SDLNet_GenericSocket): cint =
#  #return (sock != NULL) && (sock->ready);
proc socketReady* (sock: GenericSocket): bool =
  not(sock.isNil) and sock.ready > 0

{.deprecated: [TIPaddress: IpAddress].}
{.deprecated: [AddSocket: addSocket].}
{.deprecated: [AllocPacket: allocPacket].}
{.deprecated: [AllocPacketV: allocPacketV].}
{.deprecated: [AllocSocketSet: allocSocketSet].}
{.deprecated: [CheckSockets: checkSockets].}
{.deprecated: [DelSocket: delSocket].}
{.deprecated: [FreePacket: freePacket].}
{.deprecated: [FreePacketV: freePacketV].}
{.deprecated: [FreeSocketSet: freeSocketSet].}
{.deprecated: [GetError: getError].}
{.deprecated: [GetLocalAddresses: getLocalAddresses].}
{.deprecated: [Init: init].}
{.deprecated: [Linked_Version: linkedVersion].}
{.deprecated: [Quit: quit].}
{.deprecated: [Read16: read16].}
{.deprecated: [Read32: read32].}
{.deprecated: [ResizePacket: resizePacket].}
{.deprecated: [ResolveHost: resolveHost].}
{.deprecated: [ResolveIP: resolveIP].}
{.deprecated: [SetError: setError].}
{.deprecated: [SocketReady: socketReady].}
{.deprecated: [TCP_Accept: tcpAccept].}
{.deprecated: [TCP_AddSocket: tcpAddSocket].}
{.deprecated: [TCP_Close: tcpClose].}
{.deprecated: [TCP_DelSocket: tcpDelSocket].}
{.deprecated: [TCP_GetPeerAddress: tcpGetPeerAddress].}
{.deprecated: [TCP_Open: tcpOpen].}
{.deprecated: [TCP_Recv: tcpRecv].}
{.deprecated: [TCP_Send: tcpSend].}
{.deprecated: [UDP_AddSocket: udpAddSocket].}
{.deprecated: [UDP_Bind: udpBind].}
{.deprecated: [UDP_Close: udpClose].}
{.deprecated: [UDP_DelSocket: udpDelSocket].}
{.deprecated: [UDP_GetPeerAddress: udpGetPeerAddress].}
{.deprecated: [UDP_Open: udpOpen].}
{.deprecated: [UDP_Recv: udpRecv].}
{.deprecated: [UDP_RecvV: udpRecvV].}
{.deprecated: [UDP_Send: udpSend].}
{.deprecated: [UDP_SendV: udpSendV].}
{.deprecated: [UDP_SetPacketLoss: udpSetPacketLoss].}
{.deprecated: [UDP_Unbind: udpUnbind].}
{.deprecated: [Write16: write16].}
{.deprecated: [Write32: write32].}
