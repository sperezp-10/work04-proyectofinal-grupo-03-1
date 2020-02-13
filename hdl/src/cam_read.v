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
		input pclk,	// Clock de la camara
		input rst,	// Reset
		input vsync,	// Sincronizacion vertical
		input href,	// Sincronizacion horizontal
		input [7:0] px_data,	// Datos de entrada
		input btnP,	// Boton de foto

		output reg [AW-1:0] mem_px_addr = 0,	// Direccion de escritura
		output reg [7:0]  mem_px_data = 0,	// Dato a escribir
		output reg px_wr = 0,	// Orden de escribir
		output reg [7:0] Row,	// Contador de filas
		output reg [7:0] Pixel	// Contador de pixeles
   );
	
reg [0:0] vsync_old = 1;	// vsync anterior
reg [2:0] position = 0;		// estado de la FSM
reg pic = 0;			// Control de foto
reg [7:0] crow = 0;		// Contador dinamico de filas
reg [7:0] cpixel = 0;		// Contador dinamico de pixeles

always @ (posedge btnP) begin		// Cambio de control de foto
	
	pic = pic + 1;
	
end

always @ (posedge vsync) begin		// actualizacion de contador de filas y pixeles
	
	Row = crow;
	Pixel = cpixel;
	
end

always @ (posedge pclk) begin		// FSM

	case(position)
			0: begin 	// S0 
					if (!pic) begin
						mem_px_addr = 15'b111111111111111;	// Reinicio de dirreccion
						crow = 0;				// Reinicio de contador de filas
						if (!vsync && vsync_old) position = 1;	// Inicio de captura de la imagen
					end
				end
			1: begin 	// S1
					if (vsync && !vsync_old) position = 0;		// Finalizacion de imagen
					if (href) begin					// Inicio de fila 
						crow = crow + 1;			// Sumador contador de fila
						cpixel = 0;				// Reinicio de contador de pixeles
						px_wr <= 0;				// Cambio señal de escritura
						mem_px_data[7] = px_data[7];		// Reductor de formato
						mem_px_data[6] = px_data[6];
						mem_px_data[5] = px_data[5];
						mem_px_data[4] = px_data[2];
						mem_px_data[3] = px_data[1];
						mem_px_data[2] = px_data[0];
						position = 3;
					end
				end
			2: begin 	// S2
					px_wr <= 0;					// Cambio señal de escritura
					cpixel = cpixel + 1;				// Sumador contador de pixeles
					mem_px_addr = mem_px_addr+1;			// Sumador de direccion
					mem_px_data[7] = px_data[7];			// Reductor de formato
					mem_px_data[6] = px_data[6];
					mem_px_data[5] = px_data[5];
					mem_px_data[4] = px_data[2];
					mem_px_data[3] = px_data[1];
					mem_px_data[2] = px_data[0];
					position = 3;
				end
			3: begin 	// S3
					mem_px_data[1] = px_data[4];			// Reductor de formato
					mem_px_data[0] = px_data[3];
					px_wr <= 1;					// Cambio señal de escritura
					if (href)	position = 2;			// Finalizador de fila
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
