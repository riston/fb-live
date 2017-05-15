defmodule FbLive.MazeBase do
  use Bitwise

  @da %{ :n => 1, :s => 2, :e => 4, :w => 8, :sp => 16, :ep => 32 }

  @dx %{:e => 1, :w => -1, :n => 0, :s => 0}
  @dy %{:e => 0, :w => 0, :n => -1, :s => 1}
  @opposite %{:e => @da[:w], :w => @da[:e], :n => @da[:s], :s => @da[:n]}

  def generate(start_point, end_point, size) do
    grid = 1..(size*size) 
    |> Enum.map(fn _ -> 0 end)

    generate_acc(grid, size, start_point)
    |> set_start_point(size, start_point)
    |> set_end_point(size, end_point)
  end

  def generate_acc(grid, size, pos) do
    {x, y} = pos
    [:n, :e, :s, :w] 
    |> Enum.shuffle
    |> Enum.reduce(grid, fn(dir, acc) ->
      [nx, ny] = [x + @dx[dir], y + @dy[dir]]

      if between?(ny, 0, size - 1) and 
        between?(nx, 0, size - 1) and 
        Enum.at(acc, at(nx, ny, size)) === 0 do

        indexC = at(x, y, size)
        indexN = at(nx, ny, size)

        new_grid = acc
        |> List.update_at(indexC, &(bor(&1, @da[dir])))
        |> List.update_at(indexN, &(bor(&1, @opposite[dir])))

        generate_acc(new_grid, size, {nx, ny})
      else 
        acc
      end
    end)
  end

  def set_start_point(grid, size, pos) do
    {x, y} = pos
    index = at(x, y, size)
    List.update_at(grid, index, &(bor(&1, @da[:sp])))
  end

  def set_end_point(grid, size, pos) do
    {x, y} = pos
    index = at(x, y, size)
    List.update_at(grid, index, &(bor(&1, @da[:ep])))
  end
  
  def is_move_valid?(grid, next_direction) do
    index = Enum.find_index(grid, fn(x) -> 
      (x &&& @da[:sp]) === @da[:sp] end)
    value = Enum.at(grid, index, :none)

    case value do
      :none -> false
      _ -> band(value, @da[next_direction]) === @da[next_direction] 
    end
  end

  def is_game_over?(grid) do
    current_index = Enum.find_index(grid, fn(x) -> 
      (x &&& @da[:sp]) === @da[:sp] end)

    end_index = Enum.find_index(grid, fn(x) -> 
      (x &&& @da[:ep]) === @da[:ep] end)
    
    current_index == end_index
  end

  def next_move(grid, size, direction) do
    if !is_move_valid?(grid, direction) do
      {:error, "Not a valid move"}
    else
      index = Enum.find_index(grid, fn(x) -> 
        (x &&& @da[:sp]) === @da[:sp] end)
      [x, y] = from(index, size)

      [nx, ny] = [x + @dx[direction], y + @dy[direction]]
      next_index = at(nx, ny, size)

      new_grid = grid
      |> List.update_at(index, &(&1 &&& bnot(@da[:sp]))) # Remove the previous
      |> List.update_at(next_index, &(&1 ||| @da[:sp])) # Move to next position
      
      {:ok, new_grid}
    end
  end

  def between?(n, min, max) when n <= max and n >= min, do: true
  def between?(_, _, _), do: false

  def at(x, y, size), do: x + y * size
  def from(x, size), do: [rem(x, size), trunc(x / size)]
end