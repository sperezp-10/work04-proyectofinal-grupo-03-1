`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:14:22 12/02/2019 
// Design Name: 
// Module Name:    cam_read 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module cam_read #(
		parameter AW = 15 // Cantidad de bits  de la dirección 
		)(
		input pclk,
		input rst,
		input vsync,
		input href,
		input [7:0] px_data,
		input btnP,

		output reg [AW-1:0] mem_px_addr = 0,
		output reg [7:0]  mem_px_data = 0,
		output reg px_wr = 0,
		output reg [7:0] Row,
		output reg [7:0] Pixel
   );
	
reg [0:0] vsync_old = 1;
reg [2:0] position = 0;
reg pic = 0;
reg [7:0] crow = 0;
reg [7:0] cpixel = 0;

always @ (posedge btnP) begin
	
	pic = pic + 1;
	
end

always @ (posedge vsync) begin
	
	Row = crow;
	Pixel = cpixel;
	
end

always @ (posedge pclk) begin

	case(position)
			0: begin 
					if (!pic) begin
						mem_px_addr = 15'b111111111111111;
						crow = 0;
						if (!vsync && vsync_old) position = 1;
					end
				end
			1: begin 
					if (vsync && !vsync_old) position = 0;
					if (href) begin
						crow = crow + 1;
						cpixel = 0;
						px_wr <= 0;
						mem_px_data[7] = px_data[7];
						mem_px_data[6] = px_data[6];
						mem_px_data[5] = px_data[5];
						mem_px_data[4] = px_data[2];
						mem_px_data[3] = px_data[1];
						mem_px_data[2] = px_data[0];
						position = 3;
					end
				end
			2: begin 
					px_wr <= 0;
					cpixel = cpixel + 1;
					mem_px_addr = mem_px_addr+1;
					mem_px_data[7] = px_data[7];
					mem_px_data[6] = px_data[6];
					mem_px_data[5] = px_data[5];
					mem_px_data[4] = px_data[2];
					mem_px_data[3] = px_data[1];
					mem_px_data[2] = px_data[0];
					position = 3;
				end
			3: begin 
					mem_px_data[1] = px_data[4];
					mem_px_data[0] = px_data[3];
					px_wr <= 1;
					if (href)	position = 2;
					else			position = 1;
				end
			default: begin
							px_wr <= 0;
						end
		endcase
		vsync_old = vsync;
end

endmodule
	

/********************************************************************************

Por favor colocar en este archivo el desarrollo realizado por el grupo para la 
captura de datos de la camara 

debe tener en cuenta el nombre de las entradas  y salidad propuestas 

********************************************************************************/

