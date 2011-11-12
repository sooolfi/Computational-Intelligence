require "gnuplot"
module Ceie
  class Genetic
		attr_accessor :poblacion, :cantidad, :tamanioCromosoma, :fitness, :cromosomaMin, :funcion 
		attr_accessor :tamanioNumero, :probabilidad, :qsubm, :epocas
	
	def initialize(cantidad,tamanioCromosoma,epocas,funcion)
		@cantidad = cantidad
		@tamanioCromosoma = tamanioCromosoma
		@epocas = epocas
		@fitness = []
		@probabilidad = []
		@qsubm = []
		@funcion = funcion
		@poblacion = initializePoblacion
	end

	def initializePoblacion
		@poblacion = []
		@cantidad.times do
			aux =[]
			@tamanioCromosoma.times do
			 aux << rand.round
			end
			@poblacion << aux
	  end
		@poblacion
	end

########Metodo principal

 	def resolver
		contador = 0
		cantidad = 20
		porcentajeMutacion = 15
		evaluarPoblacion
		while(@epocas > contador) 
		  
		 indiceMin = @fitness.index(@fitness.min)
		 @cromosomaMin = @poblacion[indiceMin].clone #guardo el mejor
		 
		 indicesPadres = seleccionarPoblacionRuleta(cantidad)
		 cruza(indicesPadres)
	   mutacion(porcentajeMutacion)
		
		 #recupero el mejor y lo cambio por el peor
 	 	 indiceMax = @fitness.index(@fitness.max)
		 @poblacion.delete_at(indiceMax)
 	 	 @poblacion.insert(indiceMax,@cromosomaMin)

		 evaluarPoblacion
		 contador+=1
		 graficar if((contador % 500 == 0)&&(@funcion != 3))
		end
	  index = @fitness.min
		indice = @fitness.index(index)
		

		##Mostramos los resultados

	  	case @funcion
			when 1
			decx = Ceie::Bintodec.new(@poblacion[indice],9,true)
	  	p "El punto x de la funcion es"
			p decx.resultado
			when 2
			decx = Ceie::Bintodec.new(@poblacion[indice],4,false)
	  	p "El punto x de la funcion es"
			p decx.resultado
			when 3
			xvector = @poblacion[indice][0...20]
	  	yvector = @poblacion[indice][20...40]
	  	decx = Ceie::Bintodec.new(xvector,5,true)
	  	decy = Ceie::Bintodec.new(yvector,5,true)
	  	x = decx.resultado
	  	y = decy.resultado
	  	p "El punto x,y de la funcion es:"
	  	p "[#{x},#{y}]"
			end	
			graficar if (@funcion !=3)


	end

#######::::::::::::::#Metodos algoritmo Genetico

	def evaluarPoblacion
		@fitness.clear
		@poblacion.each_index do |i|
				case funcion
				when 1
				 x = Ceie::Bintodec.new(@poblacion[i],9,true)
			   @fitness <<  funcion1(x.resultado)
				when 2
				 x = Ceie::Bintodec.new(@poblacion[i],4,false)
			   @fitness <<  funcion2(x.resultado)
	      when 3
				 @fitness << funcion3(i)   #funcion determina que parte del cromosoma es de x e y 
				end
		end
	end

	############aplicamos el metodo de la ruleta rusa###############
	
	def crearProbabilidad
		@probabilidad.clear
		sumaFitness = @fitness.inject {|sum,x| sum+=x }
		@fitness.each do |fitnes|
			@probabilidad << fitnes / sumaFitness
		end
		index=1
		@qsubm.clear
		@probabilidad.each do
			@qsubm << sumarCant(index,@probabilidad)
			index+=1
		end
	end
	
	def seleccionarPoblacionRuleta(cantidad)
	  crearProbabilidad
		indices = []
		cantidad.times do
		r = rand
		indiceaux = @fitness.index(@fitness.min)
		@qsubm.each_index do |i|
			if (@qsubm[i] < r && @qsubm[i+1]>=r)
			 indiceaux = i+1
			end
		end
		   indices << indiceaux
		end
		indices
	end

	def cruza(indicePadres)
		ptoCruza = rand(@tamanioCromosoma-1)
		hijos = []
		indicePadres.each_slice(2) do |indice_0, indice_1|
			hijos << @poblacion[indice_0][0...ptoCruza] + @poblacion[indice_1][ptoCruza...@tamanioCromosoma]
		  hijos << @poblacion[indice_1][0...ptoCruza] + @poblacion[indice_0][ptoCruza...@tamanioCromosoma]
		end
		poblacion = []
		indicePadres.each do |i|
		  poblacion << @poblacion[i]
		end
		poblacion += hijos
		@poblacion = poblacion
	end

	def mutacion(porcentaje)
		@poblacion.each_index do |i|
		 if(rand < porcentaje/100.0)
		  indice = rand(@poblacion[i].count)
			if(@poblacion[i][indice]==0)
			 @poblacion[i][indice]=1
		   else
			 @poblacion[i][indice]=0
		   end
		 end
		end
   end	

#######::::::::::::::#Fin Metodos algoritmo Genetico

#######::::::::::::::#Funciones auxiliares


	#devuelve la suma de los cant componentes del vector
	def sumarCant(cant,vector)
		sum = 0.0
		index = 0
		while(cant > index)
			sum += vector[index]
			index +=1
		end
		sum
	end

	#funciones para el ejercicio1
	#[-512..512]
	def funcion1(x)
	  y = -x * Math.sin(Math.sqrt(x.abs))
	 # y = -x * Math.sin(Math.sqrt(x.abs * (Math::PI / 180.0 )))
		y
	end
  #[0..20]
	def funcion2(x)
		y = x + 5 * Math.sin(3*x) +  8 * Math.cos(5*x)  ##sin esta en radianes
		y
	end
	def funcion3(i)
		#i es la posicion
		#los 20 primeros bits representan a x y los 20 siguientes a y
		xvector = @poblacion[i][0...20]
		yvector = @poblacion[i][20...40]
		decx = Ceie::Bintodec.new(xvector,5,true)
		decy = Ceie::Bintodec.new(yvector,5,true)
		x = decx.resultado
		y = decy.resultado
		r = (x**2.0 + y**2.0)**0.25 *(Math.sin((50*(x**2.0 + y**2.0)**0.1)**2.0) +1.0)
		r
	end

	#fin funciones

    def graficar()
    Gnuplot.open do |gp|
     Gnuplot::Plot.new( gp ) do |plot|

      plot.title  "Ejercicio-1"
      plot.ylabel "y"
      plot.xlabel "x"
			x = []
			y = []
			
			y << @fitness.min
		  indice = @fitness.index(y.first)
		  case @funcion
			when 1
			xv = Ceie::Bintodec.new(@poblacion[indice],9,true)
			x << xv.resultado
			when 2
			xv = Ceie::Bintodec.new(@poblacion[indice],4,false)
			x << xv.resultado
			end

			case funcion
				when 1
        plot.xrange "[-512.0:512.0]"
		  	plot.data = [
        Gnuplot::DataSet.new("-x*sin(sqrt(abs(x)))") { |ds|
          ds.with = "lines"
          ds.linewidth = 2
		  		},
        Gnuplot::DataSet.new([x,y]) { |ds|
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
         Gnuplot::DataSet.new([x,y]) { |ds|
           ds.with = "linespoint"
           ds.linewidth = 3
		   		ds.title = "Minimo"
		   		}]
				end

    end
		end
   end

end
end
