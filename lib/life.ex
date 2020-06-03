defmodule Life_parallel do

    """ 
    RULES
    1. Any live cell with fewer than two live neighbours dies, as if by underpopulation.
    2. Any live cell with two or three live neighbours lives on to the next generation.
    3. Any live cell with more than three live neighbours dies, as if by overpopulation.
    4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
    """
  
    def start do
      matrix_size = 25
      #Existen dos opciones para probar el funcionamiento. Estos fueron sacadas del siguiente sitio web: https://bitstorm.org/gameoflife/
      #Opción 1: Small Exploder
      #Opción 2: 10 Cell Row
      #Opción 3: Glider
      option = 2
  
      matrix_original = generate_generation_0(option, matrix_size)
      IO.inspect matrix_original
      next_generation(matrix_original, 0)
      #Benchmark.measure fn -> next_generation(matrix_original, 0) end
    end
  
    def generate_generation_0(op, matrix_size) when op == 1 do 
      matrix = Matrix.new(matrix_size, matrix_size)
  
      matrix = Matrix.set(matrix, 10, 10, 1)
      matrix = Matrix.set(matrix, 11, 9, 1)
      matrix = Matrix.set(matrix, 11, 10, 1)
      matrix = Matrix.set(matrix, 11, 11, 1)
      matrix = Matrix.set(matrix, 12, 9, 1)
      matrix = Matrix.set(matrix, 12, 11, 1)
      matrix = Matrix.set(matrix, 13, 10, 1)
      matrix
    end
  
    def generate_generation_0(op, matrix_size) when op == 2 do 
      matrix = Matrix.new(matrix_size, matrix_size)
  
      matrix = Matrix.set(matrix, 10, 8, 1)
      matrix = Matrix.set(matrix, 10, 9, 1)
      matrix = Matrix.set(matrix, 10, 10, 1)
      matrix = Matrix.set(matrix, 10, 11, 1)
      matrix = Matrix.set(matrix, 10, 12, 1)
      matrix = Matrix.set(matrix, 10, 13, 1)
      matrix = Matrix.set(matrix, 10, 14, 1)
      matrix = Matrix.set(matrix, 10, 15, 1)
      matrix = Matrix.set(matrix, 10, 16, 1)
      matrix = Matrix.set(matrix, 10, 17, 1)
  
      matrix
    end
  
    def generate_generation_0(op, matrix_size) when op == 3 do 
      matrix = Matrix.new(matrix_size, matrix_size)
  
      matrix = Matrix.set(matrix, 5, 2, 1)
      matrix = Matrix.set(matrix, 6, 3, 1)
      matrix = Matrix.set(matrix, 7, 1, 1)
      matrix = Matrix.set(matrix, 7, 2, 1)
      matrix = Matrix.set(matrix, 7, 3, 1)
  
      matrix
    end
  
    def next_generation(matrix, iter) when iter <= 100 do
      next_gen = next_row_aux(matrix)
      Process.sleep(500)
      IO.inspect next_gen
      next_generation(next_gen, iter+1)
    end
  
    def next_generation(matrix, iter) when iter > 100 do
        Process.sleep(500)
        IO.inspect next_row_aux(matrix)
        next_row_aux(matrix)
    end
  
    def next_row_aux(matrix_original) do
        {matrix,_} = Enum.map_reduce(matrix_original, 0, fn row, acc -> 
            Task.async(fn -> {next_col(matrix_original, row, acc, 0), acc+1} end)
            |> Task.await
        end)
        matrix
    end

    def next_col(matrix_original, row, row_index, col) when col < length(matrix_original) do
        next_col(matrix_original, verify_rules(matrix_original, row, row_index, col), row_index, col+1)
    end

    def next_col(matrix_original, row, row_index, col) when col >= length(matrix_original) do
        row
    end
  
    def cell_alive(cell) do
      if cell==1 do
        1
      else
        0
      end
    end
  
    #sup, der-sup, der
    def quantity_neighbours_alive(mtx, row, col, qty, pos) when col == 0 and row == length(mtx)-1 do
      case pos do
        :sup -> 
          cell = Matrix.elem(mtx, row-1, col)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :der_sup)
        :der_sup -> 
          cell = Matrix.elem(mtx, row-1, col+1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :der)
        :der -> 
          cell = Matrix.elem(mtx, row, col+1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :none)
        _ -> qty
      end
    end
  
    #izq, abj, izq-abj
    def quantity_neighbours_alive(mtx, row, col, qty, pos) when row == 0 and col == length(mtx)-1 do
      case pos do
        :izq -> 
          cell = Matrix.elem(mtx, row, col-1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :abj)
        :abj -> 
          cell = Matrix.elem(mtx, row+1, col)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :izq_abj)
        :izq_abj -> 
          cell = Matrix.elem(mtx, row+1, col-1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :none)
        _ -> qty
      end
    end
  
    #izq, izq-sup, sup
    def quantity_neighbours_alive(mtx, row, col, qty, pos) when col == length(mtx)-1 and row == length(mtx)-1 do
      case pos do
        :izq -> 
          cell = Matrix.elem(mtx, row, col-1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :izq_sup)
        :izq_sup -> 
          cell = Matrix.elem(mtx, row-1, col-1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :sup)
        :sup -> 
          cell = Matrix.elem(mtx, row-1, col)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :none)
        _ -> qty
      end
    end
  
    #der, der-abj, abj
    def quantity_neighbours_alive(mtx, row, col, qty, pos) when col == 0 and row == 0 do
      case pos do
        :der -> 
          cell = Matrix.elem(mtx, row, col+1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :der_abj)
        :der_abj -> 
          cell = Matrix.elem(mtx, row+1, col+1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :abj)
        :abj -> 
          cell = Matrix.elem(mtx, row+1, col)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :none)
        _ -> qty
      end
    end
  
    #sup, der-sup, der, der-abj, abj
    def quantity_neighbours_alive(mtx, row, col, qty, pos) when col == 0 and row > 0 and row < length(mtx)-1 do
      case pos do
        :sup -> 
          cell = Matrix.elem(mtx, row-1, col)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :der_sup)
        :der_sup -> 
          cell = Matrix.elem(mtx, row-1, col+1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :der)
        :der -> 
          cell = Matrix.elem(mtx, row, col+1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :der_abj)
        :der_abj -> 
          cell = Matrix.elem(mtx, row+1, col+1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :abj)
        :abj -> 
          cell = Matrix.elem(mtx, row+1, col)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :none)
        _ -> qty
      end
    end
  
    #izq, der, der-abj, abj, izq-abj
    def quantity_neighbours_alive(mtx, row, col, qty, pos) when col > 0 and row == 0 and col < length(mtx)-1 do
      case pos do
        :izq -> 
          cell = Matrix.elem(mtx, row, col-1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :der)
        :der -> 
          cell = Matrix.elem(mtx, row, col+1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :der_abj)
        :der_abj -> 
          cell = Matrix.elem(mtx, row+1, col+1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :abj)
        :abj -> 
          cell = Matrix.elem(mtx, row+1, col)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :izq_abj)
        :izq_abj -> 
          cell = Matrix.elem(mtx, row+1, col-1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :none)
        _ -> qty
      end
    end
  
    #izq, izq-sup, sup, abj, izq-abj
    def quantity_neighbours_alive(mtx, row, col, qty, pos) when row > 0 and col == length(mtx)-1 and row < length(mtx)-1 do
      case pos do
        :izq -> 
          cell = Matrix.elem(mtx, row, col-1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :izq_sup)
        :izq_sup -> 
          cell = Matrix.elem(mtx, row-1, col-1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :sup)
        :sup -> 
          cell = Matrix.elem(mtx, row-1, col)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :abj)
        :abj -> 
          cell = Matrix.elem(mtx, row+1, col)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :izq_abj)
        :izq_abj -> 
          cell = Matrix.elem(mtx, row+1, col-1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :none)
        _ -> qty
      end
    end
  
    #izq, izq-sup, sup, der-sup, der
    def quantity_neighbours_alive(mtx, row, col, qty, pos) when col > 0 and col < length(mtx)-1 and row == length(mtx)-1 do
      case pos do
        :izq -> 
          cell = Matrix.elem(mtx, row, col-1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :izq_sup)
        :izq_sup -> 
          cell = Matrix.elem(mtx, row-1, col-1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :sup)
        :sup -> 
          cell = Matrix.elem(mtx, row-1, col)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :der_sup)
        :der_sup -> 
          cell = Matrix.elem(mtx, row-1, col+1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :der)
        :der -> 
          cell = Matrix.elem(mtx, row, col+1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :none)
        _ -> qty
      end
    end
  
    #izq, izq-sup, sup, der-sup, der, der-abj, abj, izq-abj
    def quantity_neighbours_alive(mtx, row, col, qty, pos) when col > 0 and row > 0 and col < length(mtx)-1 and row < length(mtx)-1 do
      case pos do
        :izq -> 
          cell = Matrix.elem(mtx, row, col-1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :izq_sup)
        :izq_sup -> 
          cell = Matrix.elem(mtx, row-1, col-1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :sup)
        :sup -> 
          cell = Matrix.elem(mtx, row-1, col)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :der_sup)
        :der_sup -> 
          cell = Matrix.elem(mtx, row-1, col+1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :der)
        :der -> 
          cell = Matrix.elem(mtx, row, col+1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :der_abj)
        :der_abj -> 
          cell = Matrix.elem(mtx, row+1, col+1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :abj)
        :abj -> 
          cell = Matrix.elem(mtx, row+1, col)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :izq_abj)
        :izq_abj -> 
          cell = Matrix.elem(mtx, row+1, col-1)
          quantity_neighbours_alive(mtx, row, col, qty+cell_alive(cell), :none)
        _ -> qty
      end
    end
  
    def verify_rules(matrix_original, row, row_index, col) when col == 0 and row == 0 do
      qty_alive = quantity_neighbours_alive(matrix_original, row_index, col, 0, :der)
  
      cond do
        qty_alive < 2 or qty_alive > 3 -> List.replace_at(row, col, 0)
        qty_alive == 3 -> List.replace_at(row, col, 1)
        true -> row
      end
    end
   
    def verify_rules(matrix_original, row, row_index, col) when col == 0 and row > 0 do
      qty_alive = quantity_neighbours_alive(matrix_original, row_index, col, 0, :sup)
  
      cond do
        qty_alive < 2 or qty_alive > 3 -> List.replace_at(row, col, 0)
        qty_alive == 3 -> List.replace_at(row, col, 1)
        true ->row
      end
    end

    def verify_rules(matrix_original, row, row_index, col) when col > 0 do
        qty_alive = quantity_neighbours_alive(matrix_original, row_index, col, 0, :izq)
        cond do
            qty_alive < 2 or qty_alive > 3 -> List.replace_at(row, col, 0)
            qty_alive == 3 ->  List.replace_at(row, col, 1)
          true -> row
        end
      end
  
  end
  