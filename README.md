# UART_PROTOCOAL

## Introduction
Uart=Stands for Universal Asynchronous Reception and Transmission (UART)
A simple serial communication protocol that allows the host communicates with the auxiliary device. UART supports bi-directional, asynchronous and serial data transmission. It has two data lines, one to transmit (TX) and another to receive (RX) which is used to communicate through digital pin 0, digital pin 1.

It is an asynchronous protocal so it is not required clk for syncronous insted of clk here we define start and stop bit in packets for reciver/transmitter to know that from when data transmission start when it is Stop. When reciver recives the start bit then it is srart the reading data at baud rate.

#### Working of UART
Uart TX getting data from a databus. In databus data is coming in parllal form from the other device(like CPU). Then UART TX added satrt bit, parity bit and stop bit and prapared a data packet. From UART TX to UART RX data transmitting in serial form. At the RX end reciver start reading data bit by bit and removing start. parity and stop bit and send it to other device using data bus where data again transmitting in Parllal form from UART RX to other device using databus.

##### UART PACKET
In Uart packet have following bits-
- start bit - 1 bit, Indicating the starting of data. 
- Stop bit - 1 or 2 bit Indicating the stop of data
- Parity bit - 0 or 1 bit (Optional) describing the oddness or eveness of data or Its help to detecting data error in received data packet(like any bit changed from 0 to 1 or vice versa).
- Data bits- 5 to 9 bits. 

![image](https://user-images.githubusercontent.com/72481400/227790541-7093161d-d9a2-430f-bb43-06c1f67c8b64.png)


### UART MAIN ARCHITECTURE- 
Mainly In UART Tx and Rx have 5 components TX And RX block 2 FIFO Blocks and one Baud Generator.But in my design i consider only 3 blocks TX, RX and Baud_rate generator but Baud rate generator programmin include inside both blocks(TX and RX).

![image](https://user-images.githubusercontent.com/72481400/227788719-f004eee4-8e0a-4690-bcdb-a8761c2d3902.png)


#### TX BLOCK- explained in uart working.
input signals- 
clk .clock generation.
rst - 1bit -used for reset and reach to IDLE satate.
start - 1 bit. -starting bit indicating that data going to start after this.
tx_data_in - 8bit -data input.
Output signals-
tx -data out- 1bit
tx_active- 1bit -repersent that data transmission is going on.
done_tx- 1bit - transmission is done.

#### RX BLOCK- explained in uart working.
input signals-
clk -closk generation
rst- 1bit -used for reset and reach to IDLE satate.
rx -data in coming from UART TX bit by bit - 1bit
rx_data_out - data out -8bit.

#### FIFO BLOCK- 
It is used when we have different frequency for UART TX/RX and other device from where th data is coming. If we didn't use FIFO then having possiblity to lose the data. So for this we adding FIFO both side of UART.

**Note:- In my design I am not using FIFO both side.**

#### Baud Rate-
It is define as rate at which data(indformation) is transfered in communication channel. EX- if any channel have baud rate 19.2k its mean that particular channel capable to transfer maximum 19.2k bits in one second.

baud rate = (fclk)/(16*USARTDIV)

**Note:- In my design baud rate= 19.2k and clk = 50MHz.**


Status used in design- In both fsm uart TX and RX containg following 5 states-
- IDLE
- START
- DATA 
- STOP
- DONE


## Contact
Created by [@teekamkhandelwal] - feel free to contact me!

## Refrence
[1] FIFO- https://github.com/teekamkhandelwal/Verilog_based_some_application_projects/tree/main/syncronous_fifo

[2]. UART TX- https://github.com/teekamkhandelwal/Uart_tx_main
 


