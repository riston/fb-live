defmodule FbLive.MazeBaseTest do
    use ExUnit.Case
    alias FbLive.MazeBase

    @test_grid [20 ,10 ,6 ,14 ,12 ,10 ,4 ,12 ,12 ,10 ,6 ,9 ,3 ,5 ,10 ,5 ,10 ,6 ,12 ,9 ,5 ,10 ,1 ,6 ,9 ,2 ,3 ,5 ,12 ,10 ,2 ,5 ,10 ,35 ,6 ,11 ,3 ,6 ,12 ,11 ,7 ,10 ,5 ,9 ,1 ,3 ,3 ,5 ,10 ,3 ,3 ,7 ,12 ,12 ,12 ,9 ,5 ,10 ,3 ,3 ,3 ,3 ,6 ,12 ,12 ,12 ,10 ,3 ,3 ,3 ,3 ,3 ,3 ,4 ,14 ,8 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,6 ,11 ,6 ,9 ,3 ,3 ,3 ,1 ,5 ,13 ,9 ,1 ,5 ,12 ,13 ,9 ,1]
    @size 10

    def debug_grid(grid) do
        IO.puts ""
        grid 
        |> Enum.chunk(@size) 
        |> Enum.each(fn row ->
            line = row
            |> Enum.map(&(String.pad_leading(Integer.to_string(&1), 3)))
            |> Enum.join()
            
            IO.puts line
        end)
    end

    test "Maze init test" do
        size = 10
        MazeBase.generate({0, 0}, {1, 1}, size)
    end

    test "is next move valid" do
        assert MazeBase.is_move_valid?(@test_grid, :e) === true
        assert MazeBase.is_move_valid?(@test_grid, :n) === false
        assert MazeBase.is_move_valid?(@test_grid, :s) === false
        assert MazeBase.is_move_valid?(@test_grid, :w) === false
    end

    test "making the move" do
        {:ok, grid} = MazeBase.next_move(@test_grid, @size, :e)
        assert Enum.at(grid, 0) === 4
        assert Enum.at(grid, 1) === 26

        {:ok, after_grid} = MazeBase.next_move(grid, @size, :s)
        
        assert Enum.at(after_grid, 0) === 4
        assert Enum.at(after_grid, 1) === 10
        assert Enum.at(after_grid, 11) === 25
    end

    test "multiple move test" do
        grid = ~w[e s w s e s e s e n]a
        |> Enum.reduce(@test_grid, fn(d, grid) -> 
            {:ok, after_grid} = MazeBase.next_move(grid, @size, d) 
            after_grid
        end)
        
        assert MazeBase.is_game_over?(grid) === true
    end

    test "multiple move test through endpoint" do
        grid = ~w[e s w s e s e s e n n e n w n e e]a
        |> Enum.reduce(@test_grid, fn(d, grid) -> 
            {:ok, after_grid} = MazeBase.next_move(grid, @size, d) 
            after_grid
        end)

        debug_grid(grid)
        IO.puts "Before creating new grid"

        {:ok, after_grid} = MazeBase.next_move(grid, @size, :s)
        debug_grid(after_grid)

        # assert MazeBase.is_game_over?(grid) === true
    end

    test "making invalid moves" do
        {:error, _} = MazeBase.next_move(@test_grid, @size, :n)
        {:error, _} = MazeBase.next_move(@test_grid, @size, :w)
        {:error, _} = MazeBase.next_move(@test_grid, @size, :s)
    end

    test "is between" do
        assert MazeBase.between?(-1, 0, 3) === false
        assert MazeBase.between?(4, 0, 3) === false

        assert MazeBase.between?(1, 0, 3) === true
        assert MazeBase.between?(0, 0, 3) === true
        assert MazeBase.between?(3, 0, 3) === true
    end

    test "convert coordinates" do
        size = 20
        assert MazeBase.at(1, 1, size) === 21
        assert MazeBase.at(0, 0, size) === 0
        assert MazeBase.at(20, 20, size) === 420

        assert MazeBase.from(0, size) === [0, 0]
        assert MazeBase.from(4, size) === [4, 0]
        assert MazeBase.from(5, size) === [5, 0]
        assert MazeBase.from(1, size) === [1, 0]
        assert MazeBase.from(27, size) === [7, 1]

        smaller = 10
        assert MazeBase.from(5, smaller) === [5, 0]
    end
end