module Ceie
class Bintodec
	attr_accessor :aceptaNegativo, :cantNum, :vector, :resultado
  
	def initialize(vector,cantNum,aceptaNegativo)
		@vector = vector
		@cantNum = cantNum
		@aceptaNegativo = aceptaNegativo
		@resultado = bin2dec
	end

	
	def bin2dec
    dec = 0.0;
		if(@aceptaNegativo)
		tamanio = @cantNum-1
		@vector.each_index do |i|
		if(i!=0)
			dec += @vector[i]* (2**tamanio)
		  tamanio =tamanio- 1
			end
		end
		if(@vector[0] == 1)
		  dec
		else
		  dec = -1 * dec
		end
		else
		tamanio = @cantNum-1
		@vector.each_index do |i|
			dec += @vector[i]* (2**tamanio)
		  tamanio =tamanio-1
			end
			dec
		end
		dec
	end
end
end
