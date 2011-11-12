require "gnuplot"

module Ceie
  class GeneticSalesman
    attr_accessor :poblacion, :cantidad, :tamanioCromosoma, :fitness, :cromosomaMin, :funcion 
    attr_accessor :tamanioNumero, :probabilidad, :qsubm, :epocas, :fitnessReq, :tamanioNumero
    attr_accessor :costos, :cantidad_ciudades

    def initialize(cantidad, tamanioCromosoma, fitnessReq, epocas, tamanioNumero, costos, cantidad_ciudades)
      @cantidad = cantidad
      @tamanioCromosoma = tamanioCromosoma
      @epocas = epocas
      @fitnessReq = fitnessReq
      @fitness = []
      @probabilidad = []
      @qsubm = []
      @tamanioNumero = tamanioNumero   ##esto varia de acuerdo al problema
      @poblacion = initializePoblacion
      @costos = costos
      @cantidad_ciudades = cantidad_ciudades
    end

    def initializePoblacion
      @poblacion = []
      ciudades = [0, 1, 2, 3, 4, 5, 6, 7]
      @cantidad.times do
        # sort_by... mezcla aleatoriamente las ciudades
        @poblacion << ciudades.sort_by{rand}[0...8]
      end
      @poblacion
    end

     def resolver
      contador = 0
      cantidad-padres = @cantidad/2
      porcentajeMutacion = 15
      evaluarPoblacion

      while((@epocas > contador) && (@fitness.min > @fitnessReq))

       indiceMin = @fitness.index(@fitness.min)
       @cromosomaMin = @poblacion[indiceMin].clone #guardo el mejor

       indicesPadres = seleccionarPoblacionRuleta(cantidad-padres)

       cruza(indicesPadres)

       p "el fitness mejor es:  #{@fitness.min}" 
			 #if contador % 50 == 0


       mutacion(porcentajeMutacion)

       #recupero el mejor y lo cambio por el peor
       indiceMax = @fitness.index(@fitness.max)
       @poblacion.delete_at(indiceMax)
       @poblacion.insert(indiceMax,@cromosomaMin)


       evaluarPoblacion
       contador+=1
      end
      
      p index = @fitness.min
      indice = @fitness.index(index)
      p "El camino mas corto es:"
      p @poblacion[indice]

    end

    def evaluarPoblacion
      @fitness.clear
      @poblacion.each_index do |i|
        @fitness <<  funcion4(@poblacion[i])
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
      # operador basado en cruce basado en ciclos CX
      poblacion = []
      indicePadres.each_slice(2) do |indice_padre, indice_madre|
        hijo  = []
        hija  = []
        padre = []
        madre = []
        padre = @poblacion[indice_padre]
        madre = @poblacion[indice_madre]

        #ciudades = [0, 1, 2, 3, 4, 5, 6, 7]
        #hijo =  ciudades.sort_by{rand}[0...8]
        #hija =  ciudades.sort_by{rand}[0...8]

        #  Operador de Cruza basado en la alternancia de las posiciones AP
        #  padre = (1 2 3 4 5 6 7 8)
        #  madre = (3 7 5 1 6 8 2 4),
        #  selecciona las ciudades alternativamente del primer y segundo padre 
        #  en el orden ocupado por los mismos, omitiendose aquellas
        #  ciudades que ya se encuentran presenten en la gira descendiente.
        #  hijo = (1 3 2 7 5 4 6 8).
        #  hija = (3 1 7 2 5 4 6 8).
        i = 0
        while hijo.count != @cantidad_ciudades-1
          hijo << padre[i] if !hijo.include?(padre[i])
          hijo << madre[i] if !hijo.include?(madre[i]) and hijo.count != @cantidad_ciudades-1
          i += 1
        end

        # intercambio los padres y hago lo mismo
        i = 0
        aux   = padre
        madre = padre
        padre = aux
        while hija.count != @cantidad_ciudades-1
          hija << padre[i] if !hija.include?(padre[i])
          hija << madre[i] if !hija.include?(madre[i]) and hija.count != @cantidad_ciudades-1
          i += 1
        end

        poblacion << hijo
        poblacion << hija
        poblacion << madre
        poblacion << padre
      end
      @poblacion = poblacion
    end

    def mutacion(porcentaje)
      @poblacion.each_index do |i|
        if rand < porcentaje/100.0
          indice_1 = rand(@poblacion[i].count)
          indice_2 = rand(@poblacion[i].count)

          # compruebo que no sean iguales
          while indice_1 == indice_2 do
            indice_2 = rand(@poblacion[i].count)
          end

          # intercambio
          aux = @poblacion[i][indice_1]
          @poblacion[i][indice_1] = @poblacion[i][indice_2]
          @poblacion[i][indice_2] = aux
        end
      end
    end

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

    def funcion4(camino)
      inicio = camino.first
      y = 0.0
      ciudad_inicio = camino.first
      camino.each_index do | i |
        inicio  = camino[i]
        destino = camino[i+1]
        if destino != nil
          y += @costos[inicio][destino]
        end
      end
      y
    end
  end
end
