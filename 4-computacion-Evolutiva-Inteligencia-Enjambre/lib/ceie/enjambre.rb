require "gnuplot"
module Ceie
  class Enjambre
	
		attr_accessor :cantidad, :particulas, :epocas  
		attr_accessor :rango, :dimension, :bestPosGlobal, :funcion 
	
	def initialize(cantidad,rango,epocas,funcion,dimension)
		@cantidad = cantidad
		@epocas = epocas
		@rango = rango
		@dimension = dimension     
		@bestPosGlobal = []
		@funcion = funcion
		@particulas = initializeProblem
	end

	def initializeProblem
		particulas = []		
	  @cantidad.times do
		 particulas << {:pos => [initRand], :vel =>[initRand], :fitness => [], :bestpos => [] }
		end
		#Rellenamos el instante 0
		@bestPosGlobal = particulas[0][:pos][0]
		particulas.each do |particula|
			particula[:fitness] << calculateFitness(particula[:pos][0])
			particula[:bestpos] = particula[:pos][0]
			@bestPosGlobal = particula[:pos][0] if(particula[:fitness][0] < calculateFitness(@bestPosGlobal))
		end
		particulas
	end

	def initRand
		v = []
		indice = 0
		r = Random.new
		@dimension.times do
		v << r.rand(@rango[indice][0]..@rango[indice][1])
		indice +=1
		end
	v
	end

	
	def resolver
	  c1 = 2.5
		c2 = 2.5
		tiempo = 1
		while(tiempo < @epocas)   #condicion de corte
			@particulas.each do |particula|
				particula[:vel]     << actualizarVel(particula,c1,c2,tiempo)
				particula[:pos]     << actualizarPos(particula,tiempo)
				particula[:fitness] << actualizarFitness(particula,tiempo)
				replaceBestPos(particula)
			end
		tiempo +=1
	graficarSolucion if (tiempo % 1 == 0)
	p @bestPosGlobal
	p calculateFitness(@bestPosGlobal)
	p "*************"
	end
	x = @bestPosGlobal
	p "el punto x,y de la funcion es"
	p @bestPosGlobal
	p "el fitness"
	p  calculateFitness(x)
	end

	def actualizarVel(particula,c1,c2,tiempo)
		vel = []
		indice = 0
		@dimension.times do
		aux1 = particula[:vel][tiempo-1][indice] 
		aux2 = c1 *rand * (particula[:bestpos][indice]- particula[:pos][tiempo-1][indice]) 
		aux3 = c2 *rand *  (@bestPosGlobal[indice] - particula[:pos][tiempo-1][indice])
		aux = aux1+aux2+aux3
		vel << aux
		indice+=1
		end
	vel
	end

	def actualizarPos(particula,tiempo)
	pos = []
	indice = 0
	 @dimension.times do
		aux = particula[:pos][tiempo-1][indice] + particula[:vel][tiempo][indice]
		if (aux > @rango[indice][0] && aux < @rango[indice][1])
		pos << particula[:pos][tiempo-1][indice] + particula[:vel][tiempo][indice]
		else
		if (aux <= @rango[indice][0])
		pos << @rango[indice][0]
		else
		if (aux >= @rango[indice][1])
		pos << @rango[indice][1]
		end
		end
		end
	indice +=1
	end
	pos
	end

	def actualizarFitness(particula,tiempo)
		calculateFitness(particula[:pos][tiempo])
	end

	def replaceBestPos(particula)
		if(particula[:fitness].last < calculateFitness(particula[:bestpos]))
			particula[:bestpos] = particula[:pos].last
		end
		if(particula[:fitness].last < calculateFitness(@bestPosGlobal))
			@bestPosGlobal = particula[:pos].last
		end
	end
	
	def calculateFitness(x)
	   case @funcion
		when 1
	   return  funcion1(x[0])
		when 2
	   return  funcion2(x[0])
		when 3
	   return  funcion3(x)
   		 end
  end

	#funciones
	#[-512..512]
	def funcion1(x)
	  -x * Math.sin(Math.sqrt(x.abs))
	end
  #[0..20]
	def funcion2(x)
	 x + 5 * Math.sin(3*x) +  8 * Math.cos(5*x)  ##sin esta en radianes
	end
	#[-100..100] en x;y
	def funcion3(x)
	 (x[0]**2.0 + x[1]**2.0)**0.25 *(Math.sin((50*(x[0]**2.0 + x[1]**2.0)**0.1)**2.0) +1)		
	end

	#fin funciones

	def graficarSolucion
  	Gnuplot.open do |gp|
  	Gnuplot::Plot.new( gp ) do |plot|
  		plot.title  "Ejercicio-3"
  		plot.ylabel "y"
  		plot.xlabel "x"
	
		
		#grafico la mejor particula
		x = @bestPosGlobal
		y = calculateFitness(x)

		case @funcion
		when 1
        	plot.xrange "[-512.0:512.0]"
					plot.data = [
        	Gnuplot::DataSet.new("-x*sin(sqrt(abs(x)))") { |ds|
          	ds.with = "lines"
  	        ds.linewidth = 2
		  		},
        	Gnuplot::DataSet.new([[x[0]],[y]]) { |ds|
          	ds.with = "linespoint"
          	ds.linewidth = 3
						ds.title = "Minimo"
		  		}]
		when 2
        	plot.xrange "[0.0:20.0]"
					plot.data = [
        	Gnuplot::DataSet.new("x + 5*sin(3*x) + 8*cos(5*x)") { |ds|
           	ds.with = "lines"
           	ds.linewidth = 2
		   		},
         	Gnuplot::DataSet.new([[x[0]],[y]]) { |ds|
                ds.with = "linespoint"
	        ds.linewidth = 3
					ds.title = "Minimo"
		   		}]
		end
		end
		end
                
	#	if(@funcion == 3)
  #  		Gnuplot.open do |gp|
  #   		Gnuplot::SPlot.new( gp ) do |plot|
	#				plot.title  "Ejercicio-3"
  #    		plot.ylabel "y"
  #    		plot.xlabel "x"
  #    		plot.xrange "[-100.0:100.0]"
  #    		plot.yrange "[-100.0:100.0]"
	#      	x = @bestPosGlobal
	#      	y = calculateFitness(x)
	#				plot.data = [
  #      	Gnuplot::DataSet.new("x**2+y**2")]
	#				#{ |ds|
	#				#((x**2.0 + y**2.0)**0.25)*(sin((50*(x**2.0 + y**2.0)**0.1)+1))**2.0") 

  #        #	ds.with = "lines"
  #        #	ds.linewidth = 2
	#  			#}
  #      #	Gnuplot::DataSet.new([x,y]) { |ds|
  #      #  	ds.with = "linespoint"
  #      #  	ds.linewidth = 3
	#      #  	ds.title = "Minimo"
	#  		#	}
	#			#]

	#		end
	#	end
	#	end


		end
end
end
