module uart(clk,rst,rx,tx_data_in,start,rx_data_out,tx,tx_active,done_tx);

parameter clk_freq = 50000000; //MHz
parameter baud_rate = 19200; //bits per second
parameter clock_divide = (clk_freq/baud_rate);

  input clk,rst; 
  input rx;
  input [7:0] tx_data_in;
  input start;
  output tx; 
  output [7:0] rx_data_out;
  output tx_active;
  output done_tx;
	
	
uart_rx 
       #(.clk_freq(clk_freq),
	 .baud_rate(baud_rate)
	)
      receiver
             (
              .clk(clk),
	      .rst(rst),
	      .rx(rx),
	      .rx_data_out(rx_data_out)
             );


uart_tx 
       #(.clk_freq(clk_freq),
	 .baud_rate(baud_rate)
        )
      transmitter			 
               (               
                .clk(clk),
		.rst(rst),
		.start(start),
		.tx_data_in(tx_data_in),
		.tx(tx),
		.tx_active(tx_active),
		.done_tx(done_tx)
               );

endmodule

// Code your design here
module uart_tx(clk,rst,start,tx_data_in,tx,tx_active,done_tx);

parameter clk_freq = 50000000; //MHz
parameter baud_rate = 19200; //bits per second
input clk,rst;
input start;
input [7:0] tx_data_in;
output tx;
output tx_active;
output logic done_tx;

localparam clock_divide = (clk_freq/baud_rate);

enum bit [2:0]{ tx_IDLE = 3'b000,
                tx_START = 3'b001,
		tx_DATA = 3'b010,
	        tx_STOP = 3'b011,
		tx_DONE = 3'b100 } tx_STATE, tx_NEXT;
					 
logic [11:0] clk_div_reg,clk_div_next;
logic [7:0] tx_data_reg, tx_data_next;
logic tx_out_reg,tx_out_next;
logic [2:0] index_bit_reg,index_bit_next;

assign tx_active = (tx_STATE == tx_DATA);
assign tx = tx_out_reg;

always_ff @(posedge clk) begin
if(rst) begin
tx_STATE <= tx_IDLE;
clk_div_reg <= 0;
tx_out_reg <= 0;
tx_data_reg <= 0;
index_bit_reg <= 0;
end
else begin
tx_STATE <= tx_NEXT;
clk_div_reg <= clk_div_next;
tx_out_reg <= tx_out_next;
tx_data_reg <= tx_data_next;
index_bit_reg <= index_bit_next;
end
end

always @(*) begin
tx_NEXT = tx_STATE;
clk_div_next = clk_div_reg;
tx_out_next = tx_out_reg;
tx_data_next = tx_data_reg;
index_bit_next = index_bit_reg;
done_tx = 0;

case(tx_STATE)

tx_IDLE: begin
tx_out_next = 1;
clk_div_next = 0;
index_bit_next = 0;
if(start == 1) begin
tx_data_next = tx_data_in;
tx_NEXT = tx_START;
end
else begin
tx_NEXT = tx_IDLE;
end
end

tx_START: begin
tx_out_next = 0;
if(clk_div_reg < clock_divide-1) begin
clk_div_next = clk_div_reg + 1'b1;
tx_NEXT = tx_START;
end
else begin
clk_div_next = 0;
tx_NEXT = tx_DATA;
end
end

tx_DATA: begin
tx_out_next = tx_data_reg[index_bit_reg];
if(clk_div_reg < clock_divide-1) begin
clk_div_next = clk_div_reg + 1'b1;
tx_NEXT = tx_DATA;
end
else begin
clk_div_next = 0;
if(index_bit_reg < 7) begin
index_bit_next = index_bit_reg + 1'b1;
tx_NEXT = tx_DATA;
end
else begin
index_bit_next = 0;
tx_NEXT = tx_STOP; 
end
end
end

tx_STOP: begin
tx_out_next = 1;
if(clk_div_reg < clock_divide-1) begin
clk_div_next = clk_div_reg + 1'b1;
tx_NEXT = tx_STOP;
end
else begin
clk_div_next = 0;
tx_NEXT = tx_DONE;
end
end

tx_DONE: begin
done_tx = 1;
tx_NEXT = tx_IDLE;
end

default: tx_NEXT = tx_IDLE;
endcase
end

endmodule 


module uart_rx(clk,rst,rx,rx_data_out);

parameter clk_freq = 50000000; //MHz
parameter baud_rate = 19200; //bits per second
input clk;
input rst;
input rx;
output [7:0] rx_data_out;

localparam clock_divide = (clk_freq/baud_rate);

enum bit [2:0] { rx_IDLE = 3'b000,
                 rx_START = 3'b001,
		 rx_DATA = 3'b010,
		 rx_STOP = 3'b011,
		 rx_DONE = 3'b100 } rx_STATE, rx_NEXT;
					 
logic [11:0] clk_div_reg,clk_div_next;
logic [7:0] rx_data_reg,rx_data_next;
logic [2:0] index_bit_reg,index_bit_next;


always_ff @(posedge clk) begin
if(rst) begin
rx_STATE <= rx_IDLE;
clk_div_reg <= 0;
rx_data_reg <= 0;
index_bit_reg <= 0;
end
else begin
rx_STATE <= rx_NEXT;
clk_div_reg <= clk_div_next;
rx_data_reg <= rx_data_next;
index_bit_reg <= index_bit_next;
end
end

always @(*) begin
rx_NEXT = rx_STATE;
clk_div_next = clk_div_reg;
rx_data_next = rx_data_reg;
index_bit_next = index_bit_reg;

case(rx_STATE)					 

rx_IDLE: begin
clk_div_next = 0;
index_bit_next = 0;
if(rx == 0) begin
rx_NEXT = rx_START;
end
else begin
rx_NEXT = rx_IDLE;
end
end

rx_START: begin
if(clk_div_reg == (clock_divide-1)/2) begin
if(rx == 0) begin
clk_div_next = 0;
rx_NEXT = rx_DATA;
end
else begin
rx_NEXT = rx_IDLE;
end
end
else begin
clk_div_next = clk_div_reg + 1'b1;
rx_NEXT = rx_START;
end
end

rx_DATA: begin
if(clk_div_reg < clock_divide-1) begin
clk_div_next = clk_div_reg + 1'b1;
rx_NEXT = rx_DATA;
end
else begin
clk_div_next = 0;
rx_data_next[index_bit_reg] = rx;
if(index_bit_reg < 7) begin
index_bit_next = index_bit_reg + 1'b1;
rx_NEXT = rx_DATA;
end
else begin
index_bit_next = 0;
rx_NEXT = rx_STOP;
end
end
end

rx_STOP: begin
if(clk_div_reg < clock_divide - 1) begin
clk_div_next = clk_div_reg + 1'b1;
rx_NEXT = rx_STOP;
end
else begin
clk_div_next = 0;
rx_NEXT = rx_DONE;
end
end

rx_DONE: begin
rx_NEXT = rx_IDLE;
end

default: rx_NEXT = rx_IDLE;
endcase
end

assign rx_data_out = rx_data_reg;

endmodule
