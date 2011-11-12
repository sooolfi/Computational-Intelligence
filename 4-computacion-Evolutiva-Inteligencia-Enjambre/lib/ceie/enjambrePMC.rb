module Ceie
  class EnjambrePMC
	
		attr_accessor :cantidad, :particulas, :epocas  
		attr_accessor :bestPosGlobal, :entradas, :capas 

		#capas es asi [4,3,2] osea 3 capas , con 4, 3 y 2 neuronas respectivamente
	def initialize(cantidad,epocas,entradas,capas)
		@cantidad = cantidad
		@epocas = epocas
		@entradas = entradas
		@capas = capas
		@particulas = initializeProblem
	end

	def initializeProblem
		particulas = []
	  @cantidad.times do
		 particulas << {:pos => [inicializar], :vel =>[inicializar], :fitness => [], :bestpos => [] }
		end
		
		@bestPosGlobal = particulas[0][:pos][0]
		particulas.each do |particula|
			particula[:fitness] << calculateFitness(particula[:pos][0])
			particula[:bestpos] << particula[:pos][0]
			@bestPosGlobal = particula[:pos][0] if(particula[:fitness][0] < calculateFitness(@bestPosGlobal))
		end
		particulas
	end

	def inicializar
		dimension = (@entradas[0].count-1) *capas[0]
		aux = []
		aux2 = rellenar(dimension)
		aux << aux2
		contador = @capas.count-1
		@capas.each_index do |i|
				if(i < @capas.count-1)
				dimension = @capas[i] * @capas[i+1] 
				aux << rellenar(dimension)
				end
		end
		aux
	end 

	def rellenar(dimension)
		vector = Array.new(dimension)
		vector.each_index do |i|
			vector[i] = rand
		end
		vector
	end

	def calculateFitness(pesos)
		#en este caso el fitness es el error en el PMC
		forwardPropagation(pesos)
	end

	def calcularFitnessMin
		min = 1.0
		@particulas.each do |particula|
			if(particula[:fitness].last < min)
			min = particula[:fitness].last
			end
		end
		min
	end

	def resolver
	  c1 = 2.0
		c2 = 2.0
		tiempo = 1
		fitnesMin = calcularFitnessMin
		while((tiempo < @epocas) && (fitnesMin > 0.1))
			@particulas.each do |particula|
				particula[:vel]     << actualizarVel(particula,c1,c2,tiempo)		
				particula[:pos]     << actualizarPos(particula,tiempo)				
		  	particula[:fitness] << actualizarFitness(particula,tiempo)
				replaceBestPos(particula)
			end
			tiempo +=1
			fitnesMin = calcularFitnessMin
			p "**************************"
			p "Error en la iteracion #{tiempo}: "
			p fitnesMin
		end
			p "Los Pesos para configurar la red para el caso Clouds.csv son:" 
			p @bestPosGlobal.flatten
	end

	def actualizarVel(particula,c1,c2,tiempo)
		vel = []
		@capas.each_index do |i|
			vaux = []
			aux = particula[:pos][tiempo-1][i] #sacamos los pesos correspondientes a las capas
				aux.each_index do |j|
				 sum = particula[:vel][tiempo-1][i][j]
				 sum1 = c1 * rand * (particula[:bestpos][0][i][j] - particula[:pos][tiempo-1][i][j])
				 sum2 = c2 * rand * (@bestPosGlobal[i][j] - particula[:pos][tiempo-1][i][j]) 
				vaux << sum+sum1+sum2  	
				end
			vel << vaux
	  end
	  vel
	end

	def actualizarPos(particula,tiempo)
		pos = []
		@capas.each_index do |i|
			paux = []
			aux = particula[:pos][tiempo-1][i]
				aux.each_index do |j|
					sum = particula[:pos][tiempo-1][i][j] + particula[:vel][tiempo][i][j]
					paux << sum
				end
				pos << paux
		end				
		pos
  end

	def actualizarFitness(particula,tiempo)
		calculateFitness(particula[:pos][tiempo])
	end

	def replaceBestPos(particula)
		if(particula[:fitness].last < calculateFitness(particula[:bestpos][0]))
			particula[:bestpos] = [particula[:pos].last]
		end
		if(particula[:fitness].last < calculateFitness(@bestPosGlobal))
			@bestPosGlobal = particula[:pos].last
		end
	end
	

	#################   PMC  ##########################

   def forwardPropagation(pesos)
		error = [] 
		 @entradas.each_index do |i|	
     	entradaAux = @entradas[i].clone
			index = entradaAux.count-1
     	entradaAux.delete_at(index) # Se elimina la última xq es la deseada
     	y = Array.new
       @capas.each_index do |i|
			 y = calculateOutput(pesos[i],entradaAux,i)
       entradaAux=y
     	end
			
			if(y.first.round == @entradas[i].last)
				error << 0
				else
				error << 1
			end
			#se puede hacer con error cuadratico medio
     	#error << (((@entradas[i].last-y.first)**2)/2.0)
	 	end

		# porcentaje de errores
		porcentajeError = 0
		error.each {|err| porcentajeError+=err }
		porcentajeError/5000.0
		#mean = 0.0
		#error.each { |err| mean +=err }
		#mean/error.count
	 end

    def calculateOutput(pesos,entrada,capa)
			y  = Array.new
      for i in 0..(@capas[capa]-1)
        sum = 0
        for k in 0..(entrada.length-1)
          pos = mapearPos(i,k,entrada.count)
					sum = sum + pesos[pos] * entrada[k]
        end
        sum = sigmoide(sum, 30)
        y << sum
      end
			y
    end

    def sigmoide(y,a)
       y =  1.0/(1.0 +  Math.exp(-a*y))
    end

		def mapearPos(i,j,entradacount)
			i*entradacount + j		
		end
end
end
