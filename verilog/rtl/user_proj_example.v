// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    


	wire clk;
	wire [7:0] in_data;
	wire [7:0] out1,out2,out3,out4,out5;
	
	assign clk = wb_clk_i;
	assign in_data = la_data_in[7:0];
	assign la_data_out[15:8] = out1;
	assign la_data_out[23:16] = out2;
	assign la_data_out[31:24] = out3;
	assign la_data_out[39:32] = out4;
	assign la_data_out[47:40] = out5;
    	main uut(clk,in_data,out1,out2,out3,out4,out5);
endmodule

module main(clk,in,out1,out2,out3,out4,out5);

input [7:0] in;
input clk;
output [7:0] out1;
output [7:0] out2;
output [7:0] out3;
output [7:0] out4;
output [7:0] out5;

systolic_module dut(clk,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,out1,out2,out3,out4,out5);

endmodule


module systolic_module(clk,
	input_top_1,
	input_top_2,
	input_top_3,
	input_top_4,
	input_top_5,
	input_left_1,
	input_left_2,
	input_left_3,
	input_left_4,
	input_left_5,
	input_diag_top_0,
	input_diag_top_1,
	input_diag_top_2,
	input_diag_left_1,
	input_diag_left_2,
	output_bottom_5,
	output_bottom_4,
	output_bottom_3,
	output_right_4,
	output_right_3);
    
    input clk;
    
    parameter MATRIX_SIZE = 3;
    parameter ARRAY_SIZE = 2 * MATRIX_SIZE - 1;
    parameter REG_WIDTH = 8; // system type
   
    // systolic array
    wire [REG_WIDTH-1:0] array_input_top [ARRAY_SIZE-1:0]; //REVIEW THE TYPE AFTER ADDING STREAMING MEMORY
    wire [REG_WIDTH-1:0] array_input_left [ARRAY_SIZE-1:0];
    wire [REG_WIDTH-1:0]  c_in_left [ARRAY_SIZE-1:0];  // some of them are dummy, TOP AND BOTTOM TAKES THE PREFERNCE OVER LEFT AND RIGHT
    wire [REG_WIDTH-1:0]  c_in_top [ARRAY_SIZE-1:0]; // some of them are dummy
    wire [REG_WIDTH-1:0] c_out_right [ARRAY_SIZE-1:0]; // some of them are dummy
    wire [REG_WIDTH-1:0] c_out_bottom [ARRAY_SIZE-1:0]; //some of them are dummy
    wire [REG_WIDTH-1:0] array_output_bottom [ARRAY_SIZE-1:0];
    wire [REG_WIDTH-1:0] array_output_right [ARRAY_SIZE-1:0];
    
    
    
    // wires/connections in the systolic arrays
    wire [REG_WIDTH-1:0] horizontal_wires [ARRAY_SIZE-1:0][ARRAY_SIZE-2:0];
    wire [REG_WIDTH-1:0] vertical_wires [ARRAY_SIZE-2:0][ARRAY_SIZE-1:0];
    wire [REG_WIDTH-1:0] diagonal_wires [ARRAY_SIZE-2:0][ARRAY_SIZE-2:0];
    
    //interface to systolic arrays
    input [REG_WIDTH-1:0] input_top_1;
    input [REG_WIDTH-1:0] input_top_2;
    input [REG_WIDTH-1:0] input_top_3;
    input [REG_WIDTH-1:0] input_top_4;
    input [REG_WIDTH-1:0] input_top_5;
    input [REG_WIDTH-1:0] input_left_1;
    input [REG_WIDTH-1:0] input_left_2;
    input [REG_WIDTH-1:0] input_left_3;
    input [REG_WIDTH-1:0] input_left_4;
    input [REG_WIDTH-1:0] input_left_5;
    input [REG_WIDTH-1:0] input_diag_top_0;
    input [REG_WIDTH-1:0] input_diag_top_1;
    input [REG_WIDTH-1:0] input_diag_top_2;
    input [REG_WIDTH-1:0] input_diag_left_1;
    input [REG_WIDTH-1:0] input_diag_left_2;
    output [REG_WIDTH-1:0] output_bottom_5;
    output [REG_WIDTH-1:0] output_bottom_4;
    output [REG_WIDTH-1:0] output_bottom_3;
    output [REG_WIDTH-1:0] output_right_4;
    output [REG_WIDTH-1:0] output_right_3;
    
    assign array_input_top[0] = input_top_1;
    assign array_input_top[1] = input_top_2;
    assign array_input_top[2] = input_top_3;
    assign array_input_top[3] = input_top_4;
    assign array_input_top[4] = input_top_5;
    assign array_input_left[0] = input_left_1; 
    assign array_input_left[1] = input_left_2;
    assign array_input_left[2] = input_left_3;
    assign array_input_left[3] = input_left_4;
    assign array_input_left[4] = input_left_5;
    assign c_in_top[0] = input_diag_top_0;
    assign c_in_top[1] = input_diag_top_1;
    assign c_in_top[2] = input_diag_top_2;
    assign c_in_left[1] = input_diag_left_1;
    assign c_in_left[2] = input_diag_left_2;
    
    assign output_bottom_5 = c_out_bottom[4];
    assign output_bottom_4 = c_out_bottom[3];
    assign output_bottom_3 = c_out_bottom[2];
    assign output_right_4 = c_out_right[3];
    assign output_right_3 = c_out_right[2];
    
    
    // interface done
    
    
    // creating the systolic array
    generate ////////
        genvar row_index;
        genvar column_index;
        
        for(row_index = 0;row_index < ARRAY_SIZE; row_index = row_index + 1) begin
            for(column_index = 0;column_index < ARRAY_SIZE; column_index = column_index + 1) begin                 
                // CONNECTING BOUNDARIES
                
                //PE element(.clk(clk),.a_n_1(array_input_left[row_index]),.b_n_1(array_input_top[column_index]),.c_n_1(c_in_top[column_index]),.a_n(horizontal_wires[row_index][column_index]),.b_n(array_input_left[row_index]),.c_ab(diagonal_wires[row_index][column_index]));
            
            
                // LOGICALLY CONNECTING PART
                 if(row_index < MATRIX_SIZE -1) begin
                    if(column_index < MATRIX_SIZE+row_index) begin     
                        if(row_index == 0 && column_index==0)  begin // LEFT TOP // covering corners DEPENDS ON THE CONDITION
                            PE element(.clk(clk),.a_n_1(array_input_left[row_index]),.b_n_1(array_input_top[column_index]),.c_n_1(c_in_top[column_index]),.a_n(horizontal_wires[row_index][column_index]),.b_n(vertical_wires[row_index][column_index]),.c_ab(diagonal_wires[row_index][column_index]));
                        end
                        else if(column_index == 0) begin// LEFT inputs
                            PE element(.clk(clk),.a_n_1(array_input_left[row_index]),.b_n_1(vertical_wires[row_index-1][column_index]),.c_n_1(c_in_left[row_index]),.a_n(horizontal_wires[row_index][column_index]),.b_n(vertical_wires[row_index][column_index]),.c_ab(diagonal_wires[row_index][column_index]));
                        end
                        else if(row_index == 0) begin // TOP inputs
                            PE element(.clk(clk),.a_n_1(horizontal_wires[row_index][column_index-1]),.b_n_1(array_input_top[column_index]),.c_n_1(c_in_top[column_index]),.a_n(horizontal_wires[row_index][column_index]),.b_n(vertical_wires[row_index][column_index]),.c_ab(diagonal_wires[row_index][column_index]));
                        end // internal elements
                        else begin 
                            PE element(.clk(clk),.a_n_1(horizontal_wires[row_index][column_index-1]),.b_n_1(vertical_wires[row_index-1][column_index]),.c_n_1(diagonal_wires[row_index-1][column_index-1]),.a_n(horizontal_wires[row_index][column_index]),.b_n(vertical_wires[row_index][column_index]),.c_ab(diagonal_wires[row_index][column_index]));
                        end
                        //PE element(.clk(clk),.a_n_1(),.b_n_1(),.c_n_1(),.a_n(),.b_n(),.c_ab());
                    end
                    else begin
                        if(row_index == 0 && column_index==ARRAY_SIZE-1)  begin // RIGHT TOP // covering corners DEPENDS ON THE CONDITION
                            delay_element element(.clk(clk),.a_n_1(horizontal_wires[row_index][column_index-1]),.b_n_1(array_input_top[column_index]),.a_n(array_output_right[row_index]),.b_n(vertical_wires[row_index][column_index]));
                        end
                        else if(column_index == ARRAY_SIZE-1) begin// RIGHT 
                            delay_element element(.clk(clk),.a_n_1(horizontal_wires[row_index][column_index-1]),.b_n_1(vertical_wires[row_index-1][column_index]),.a_n(array_output_right[row_index]),.b_n(vertical_wires[row_index][column_index]));
                        end
                        else if(row_index == 0) begin // TOP inputs
                            delay_element element(.clk(clk),.a_n_1(horizontal_wires[row_index][column_index-1]),.b_n_1(array_input_top[column_index]),.a_n(horizontal_wires[row_index][column_index]),.b_n(vertical_wires[row_index][column_index]));
                        end // internal elements
                        else begin 
                            delay_element element(.clk(clk),.a_n_1(horizontal_wires[row_index][column_index-1]),.b_n_1(vertical_wires[row_index-1][column_index]),.a_n(horizontal_wires[row_index][column_index]),.b_n(vertical_wires[row_index][column_index]));
                        end                    
                        //delay_element element(.clk(),.a_n_1(),.b_n_1(),.a_n(),.b_n());
                    end
                end
                else if(row_index == MATRIX_SIZE-1) begin
                    if(column_index == 0) begin //LEFT end
                       PE element(.clk(clk),.a_n_1(array_input_left[row_index]),.b_n_1(vertical_wires[row_index-1][column_index]),.c_n_1(c_in_left[row_index]),.a_n(horizontal_wires[row_index][column_index]),.b_n(vertical_wires[row_index][column_index]),.c_ab(diagonal_wires[row_index][column_index]));
                    end
                    else if(column_index == ARRAY_SIZE-1) begin // RIGHT end
                       PE element(.clk(clk),.a_n_1(horizontal_wires[row_index][column_index-1]),.b_n_1(vertical_wires[row_index-1][column_index]),.c_n_1(diagonal_wires[row_index-1][column_index-1]),.a_n(array_output_right[row_index]),.b_n(vertical_wires[row_index][column_index]),.c_ab(c_out_right[row_index]));                    
                    end
                    else begin //internal elements
                       PE element(.clk(clk),.a_n_1(horizontal_wires[row_index][column_index-1]),.b_n_1(vertical_wires[row_index-1][column_index]),.c_n_1(diagonal_wires[row_index-1][column_index-1]),.a_n(horizontal_wires[row_index][column_index]),.b_n(vertical_wires[row_index][column_index]),.c_ab(diagonal_wires[row_index][column_index]));                        
                    end
                    // PE element(.clk(clk),.a_n_1(),.b_n_1(),.c_n_1(),.a_n(),.b_n(),.c_ab());
                end
                else begin
                    if(column_index < MATRIX_SIZE+row_index-ARRAY_SIZE) begin // intended : MATRIX_SIZE - 1 + row_index - ARRAY_SIZE+1
                        if((row_index == ARRAY_SIZE-1) && (column_index == 0)) begin//LEFT BOTTOM corner
                            delay_element element(.clk(clk),.a_n_1(array_input_left[row_index]),.b_n_1(vertical_wires[row_index-1][column_index]),.a_n(horizontal_wires[row_index][column_index]),.b_n(array_output_bottom[column_index]));
                        end
                        else if(column_index == 0) begin //LEFT
                            delay_element element(.clk(clk),.a_n_1(array_input_left[row_index]),.b_n_1(vertical_wires[row_index-1][column_index]),.a_n(horizontal_wires[row_index][column_index]),.b_n(array_output_bottom[column_index]));
                        end
                        else if(row_index == ARRAY_SIZE - 1) begin //BOTTOM
                            delay_element element(.clk(clk),.a_n_1(horizontal_wires[row_index][column_index-1]),.b_n_1(vertical_wires[row_index-1][column_index]),.a_n(horizontal_wires[row_index][column_index]),.b_n(array_output_bottom[column_index]));
                        end
                        else begin
                            delay_element element(.clk(clk),.a_n_1(horizontal_wires[row_index][column_index-1]),.b_n_1(vertical_wires[row_index-1][column_index]),.a_n(horizontal_wires[row_index][column_index]),.b_n(vertical_wires[row_index][column_index]));
                        end
                        //delay_element element(.clk(),.a_n_1(),.b_n_1(),.a_n(),.b_n());
                    end
                    else begin
                        if((row_index == ARRAY_SIZE-1) && (column_index == ARRAY_SIZE-1)) begin//RIGHT BOTTOM
                            PE element(.clk(clk),.a_n_1(horizontal_wires[row_index][column_index-1]),.b_n_1(vertical_wires[row_index-1][column_index]),.c_n_1(diagonal_wires[row_index-1][column_index-1]),.a_n(array_output_right[row_index]),.b_n(array_output_bottom[column_index]),.c_ab(c_out_bottom[column_index]));  
                        end
                        else if(column_index == ARRAY_SIZE-1) begin // RIGHT
                            PE element(.clk(clk),.a_n_1(horizontal_wires[row_index][column_index-1]),.b_n_1(vertical_wires[row_index-1][column_index]),.c_n_1(diagonal_wires[row_index-1][column_index-1]),.a_n(array_output_right[row_index]),.b_n(vertical_wires[row_index][column_index]),.c_ab(c_out_right[row_index]));  
                        end
                        else if(row_index == ARRAY_SIZE - 1) begin //BOTTOM
                            PE element(.clk(clk),.a_n_1(horizontal_wires[row_index][column_index-1]),.b_n_1(vertical_wires[row_index-1][column_index]),.c_n_1(diagonal_wires[row_index-1][column_index-1]),.a_n(horizontal_wires[row_index][column_index]),.b_n(array_output_bottom[column_index]),.c_ab(c_out_bottom[column_index]));  
                        end
                        else begin
                            PE element(.clk(clk),.a_n_1(horizontal_wires[row_index][column_index-1]),.b_n_1(vertical_wires[row_index-1][column_index]),.c_n_1(diagonal_wires[row_index-1][column_index-1]),.a_n(horizontal_wires[row_index][column_index]),.b_n(vertical_wires[row_index][column_index]),.c_ab(diagonal_wires[row_index][column_index]));   
                        end
                        
                        //PE element(.clk(clk),.a_n_1(),.b_n_1(),.c_n_1(),.a_n(),.b_n(),.c_ab());
                    end
                end           
            end
            
        end
    
    endgenerate//////////
    // systolic array created
endmodule

module PE #(parameter REG_WIDTH = 8) (clk,a_n_1,b_n_1,c_n_1,a_n,b_n,c_ab);
    
    input clk;
    input [REG_WIDTH-1:0] a_n_1;
    input [REG_WIDTH-1:0] b_n_1;
    input [REG_WIDTH-1:0] c_n_1;
    output reg [REG_WIDTH-1:0] a_n; //NEED NOT BE REG, JUST USED HERE TO SIMPLIFY
    output reg [REG_WIDTH-1:0] b_n; // POINT OF OPTIMISATION, CAN REMOVE REG
    output reg [REG_WIDTH-1:0] c_ab;
    
    always @(posedge clk) begin
        a_n <= a_n_1;
        b_n <= b_n_1;
        c_ab <= a_n_1 * b_n_1 + c_n_1;
    end
endmodule

module delay_element #(parameter REG_WIDTH = 8) (clk,a_n_1,b_n_1,a_n,b_n,);
    
    input clk;
    input [REG_WIDTH-1:0] a_n_1;
    input [REG_WIDTH-1:0] b_n_1;
    output reg [REG_WIDTH-1:0] a_n; //NEED NOT BE REG, JUST USED HERE TO SIMPLIFY
    output reg [REG_WIDTH-1:0] b_n; // POINT OF OPTIMISATION, CAN REMOVE REG
    
    always @(posedge clk) begin
        a_n <= a_n_1;
        b_n <= b_n_1;
    end
endmodule
`default_nettype wire
