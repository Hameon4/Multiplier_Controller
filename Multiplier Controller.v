`timescale 1ns / 1ps


module multiplier_controller(
    output reg Add_cmd,
    output reg Shift_cmd,
    output reg Load_cmd,
    output reg  STOP,
    input reset,
    input Clk,
    input start,
    input lsb
    );

     integer count  = 0;


     reg  [2:0] current_state,next_state;

     parameter IDLE=3'b000, INIT=3'b001, TEST = 3'b010, ADD=3'b011, SHIFT=3'b100;

     always @ (posedge Clk or posedge  reset)
     begin

     if (reset)
     begin
     current_state <= IDLE;

     end

    else begin
     current_state <=next_state;
       end
       end
   always @ (start or current_state or lsb or count)
     begin
     case (current_state)
     IDLE: if (start==0) begin STOP<=1; next_state <= IDLE; end  else begin next_state <= INIT; end

     INIT:  begin Load_cmd <= 1;
            next_state <= TEST; end

     TEST:  if(lsb)
            begin Add_cmd <= 1; next_state <= ADD; end
            else begin Shift_cmd <= 1; count <= count + 1; next_state <= SHIFT; end

     ADD:   begin Add_cmd <=1 ; count <= count + 1; next_state <= SHIFT; end

     SHIFT:  if(count != 4)begin next_state <= TEST;end
             else begin  STOP <= 1; next_state <= IDLE;end
             default: begin Load_cmd <= 0; Add_cmd <= 0; Shift_cmd<=0; STOP<=1;end

       endcase
     end
endmodule

//////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps


module multiplier_controller_tb();

 reg Reset, clk, lsb, start;
    wire stop, Add_cmd, Load_cmd, Shift_cmd;

    multiplierController uut(

    .Add_cmd(Add_cmd),
    .Shift_cmd(Shift_cmd),
    .Load_cmd(Load_cmd),
    .stop(stop),
    .Reset(Reset),
    .clk(clk),
    .start(start),
    .lsb(lsb)
    );

    initial begin
    #0 Reset = 1'b1;
    #10 Reset = 1'b0;
    end

    initial begin
    clk = 0;
    forever #5 clk = ~clk;
    end


    initial begin
    #30 lsb = 1'b1; start = 1'b0;
    #40 lsb = 1'b0; start = 1'b1;
    #40 lsb = 1'b0; start = 1'b1;
    #40 lsb = 1'b1; start = 1'b0;
    #40 lsb = 1'b0; start = 1'b1;
    #10 $stop;
    end
endmodule
//////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps


module shift_register(
   input [3:0] a,
   input [3:0] b,
   output reg [7:0] Out,
   output reg [8:0] CaQ
    );

        always @( a or b)
         begin

          CaQ  = a;
          //1
          if(CaQ[0])
          begin
          CaQ[8:4] = b + CaQ[7:4];
          CaQ = CaQ >>1;
          end
          else
          begin
          CaQ = CaQ >>1;
          end

          //2
          if(CaQ[0])
                begin
                CaQ[8:4] = b+CaQ[7:4];
                CaQ = CaQ >>1;
                end
                else
                begin
                CaQ = CaQ >>1;
                end

                //3
                if(CaQ[0])
                      begin
                      CaQ[8:4] = b+CaQ[7:4];
                      CaQ = CaQ >>1;
                      end
                      else
                      begin
                      CaQ = CaQ >>1;
                      end


                      //4
                      if(CaQ[0])
                            begin
                            CaQ[8:4] = b+CaQ[7:4];
                            CaQ = CaQ >>1;
                            end
                            else
                            begin
                            CaQ = CaQ >>1;
                            end


          Out = CaQ[7:0];

     end
endmodule
/////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps


module shift_register_tb();

    reg [3:0] a;
    reg [3:0] b;
    wire [7:0] c;
    wire [8:0] CaQ;

shiftRegister uut(

    .a(a),
    .b(b),
    .c(c),
    .CaQ(CaQ)
    );


    initial
    begin

            #0   a=4'b1011;
                 b=4'b0101;

            #10   a=4'b0011;
                  b=4'b0001;

            #10   a=4'b1001;
                  b=4'b1111;

            #10   $stop;

 end
endmodule
