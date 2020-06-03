defmodule QR_paralelism do
#-------------------------------------------------------SUMA Y RESTA VECTORES--------------------------------------------
    def resta([head|tail], [], []) do
      [head|tail]
    end

    def resta([head1|[]], [head2|[]], []) do
      [head1-head2]
    end    

    def resta([head1|tail1], [head2|tail2], []) do
      rest = resta(tail1, tail2, [])
      [head1-head2|rest]
    end


    def suma([head|tail], [], []) do
      [head|tail]
    end

    def suma([head1|[]], [head2|[]], []) do
      [head1+head2]
    end   

    def suma([head1|tail1], [head2|tail2], []) do
      rest = suma(tail1, tail2, [])
      [head1+head2|rest]
    end
#-------------------------------------------------------PRODUCTO_PUNTO_VECTORES--------------------------------------------
    def producto_punto_por_vector(v_original, q_vector) do
      producto_punto = producto_punto(v_original, q_vector, 0)
      Enum.map(q_vector, fn num -> num*producto_punto end)
    end

    def producto_punto([head|[]], [head2|[]], acum) do
      acum + head*head2
    end

    def producto_punto(v_original, q_vector, acum) do
      [head|tail] = v_original
      [head2|tail2] = q_vector

      acum = acum + head*head2
      producto_punto(tail, tail2, acum)
    end



#-------------------------------------------------------Matriz_Q-------------------------------------------------------
    def first_q_vector(v_original, []) do
      resp = Enum.map(v_original, fn x -> x*x end )
      |> Enum.sum
      |> :math.sqrt

      Enum.map(v_original, fn num -> num/resp end )
    end

    def reduce_q_vectors(v_original, q_vectors) do
        Enum.reduce(q_vectors, [], fn vector, v_final -> 
          suma(producto_punto_por_vector(v_original, vector), v_final, [])
        end)
    end

    def reduce_v2(v_original, q_vectors) do
      cond do
        length(q_vectors) < 50 ->  
          reduce_q_vectors(v_original, q_vectors)

        length(q_vectors) >= 50 -> 
          len = Kernel.trunc(length(q_vectors)/2)
          {parte1, parte2} = Enum.split(q_vectors, len)

          len1 = Kernel.trunc(length(parte1)/2)
          len2 = Kernel.trunc(length(parte2)/2)
          {p1, p2} = Enum.split(parte1, len1)
          {p3, p4} = Enum.split(parte2, len2)

          p1_id = Task.async( fn -> reduce_v2(v_original, p1) end)
          p2_id = Task.async( fn -> reduce_v2(v_original, p2) end)
          p3_id = Task.async( fn -> reduce_v2(v_original, p3) end)
          p4_id = reduce_v2(v_original, p4)
          suma(suma(Task.await(p1_id), Task.await(p2_id), []), suma(Task.await(p3_id), p4_id, []), [])
      end
    end

    def q_mtz([head|tail], []) do
      q_vector = first_q_vector(head, [])
      q_mtz(tail, [q_vector])
    end
    
    def q_mtz([head|[]], list) do
      aux = reduce_v2(head, list)
      rest = resta(head, aux, [])
      
      q_vector = first_q_vector(rest, [])
      list++[q_vector]
    end

    def q_mtz([head|tail], list) do
      aux = reduce_v2(head, list)
      q_vector = first_q_vector(resta(head, aux, []), [])
      q_mtz(tail, list++[q_vector])
    end

#-------------------------------------------------------Multiplicación de Matrices--------------------------------------------
  def dmultiply(matrix, vec) do
    Enum.map(matrix, fn(row)->
      Task.async(fn -> dot_product(row, vec) end)
      |> Task.await
      end) 
  end

  def dot_product(row_a, vec) do
    Stream.zip(row_a, vec)
    |> Enum.map(fn({x, y}) -> x * y end)
    |> Enum.sum
   end 

   def mtz_multiply(mtzQ, mtzA) do
    Enum.map(mtzQ, fn col ->
      Task.async(fn -> dmultiply(mtzA, col) end)
      |> Task.await
    end)
   end

#-------------------------------------------------------PROGRAMA----------------------------------------------------------
    def start do
      matriz_A = [[1,1,0],[1,0,1],[0,1,1]]
      #n = 300
      #mtz = Matrix.ones(n,n)
      matriz_Q = q_mtz(matriz_A, [])
      matriz_Q_transpuesta = matriz_Q
      matriz_R = mtz_multiply(matriz_Q_transpuesta, matriz_A)

      IO.puts "Matriz Original (columnas), Matriz Q (Columnas), Matriz R (Filas)"
      {matriz_A, matriz_Q, matriz_R}
    end

end


