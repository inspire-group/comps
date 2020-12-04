import socket
import time

msgFromClient       = "Hello UDP Server"
bytesToSend         = str.encode(msgFromClient)
serverAddressPort   = ("10.3.0.4", 20001)
bufferSize          = 1024
 

# Create a UDP socket at client side
UDPClientSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)

while True:
  # Send to server using created UDP socket
  UDPClientSocket.sendto(bytesToSend, serverAddressPort)
  msgFromServer = UDPClientSocket.recvfrom(bufferSize)
  msg = "Message from Server {}".format(msgFromServer[0])
  time.sleep(0.5)

print(msg)
