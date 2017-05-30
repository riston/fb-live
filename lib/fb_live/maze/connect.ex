
defmodule FbLive.MazeConnect do
    require Logger
    alias FbLive.MazeBase
    alias FbLive.MazeState
    use GenServer

    @grid_size 10
    @test_grid [20 ,10 ,6 ,14 ,12 ,10 ,4 ,12 ,12 ,10 ,6 ,9 ,3 ,5 ,10 ,5 ,10 ,6 ,12 ,9 ,5 ,10 ,1 ,6 ,9 ,2 ,3 ,5 ,12 ,10 ,2 ,5 ,10 ,35 ,6 ,11 ,3 ,6 ,12 ,11 ,7 ,10 ,5 ,9 ,1 ,3 ,3 ,5 ,10 ,3 ,3 ,7 ,12 ,12 ,12 ,9 ,5 ,10 ,3 ,3 ,3 ,3 ,6 ,12 ,12 ,12 ,10 ,3 ,3 ,3 ,3 ,3 ,3 ,4 ,14 ,8 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,6 ,11 ,6 ,9 ,3 ,3 ,3 ,1 ,5 ,13 ,9 ,1 ,5 ,12 ,13 ,9 ,1]
    @channel_name "command:lobby"

    def start_link(_default) do
        GenServer.start_link(__MODULE__, %{}, name: :maze)
    end

    def init(%{}) do
        new_grid = generate_maze()
        new_state = %MazeState{ grid: new_grid }
        {:ok, new_state}
    end

    def generate_maze() do
        start_pos = {0, 0}
        end_pos = {:rand.uniform(@grid_size - 1), :rand.uniform(@grid_size - 1)}
        Logger.info "Generating new maze"

        MazeBase.generate(start_pos, end_pos, @grid_size)
        |> IO.inspect
    end

    def new_game() do
        new_grid = generate_maze()
        new_state = %MazeState{ grid: new_grid }
        GenServer.cast(:maze, {:new, new_state})        
    end
    def new_game(%{test: true}) do
        Logger.info "Started the maze connect"

        new_state = %MazeState{ grid: @test_grid }
        GenServer.cast(:maze, {:new, new_state})        
    end

    def make_move(direction) do
        GenServer.cast(:maze, {:move, direction})
    end

    def get_grid() do
        GenServer.cast(:maze, {:current})
    end

    def get_state() do
        GenServer.call(:maze, {:state})
    end

    def next_level() do
        Process.send_after(:maze, {:next}, 5 * 1000)
    end

    def serialize_state(state = %MazeState{}) do
        %{
            "level" => state.level,
            "status" => state.status,
            "grid" => state.grid,
            "total_moves" => state.total_moves
        }
    end

    def handle_call({:state}, _from, state) do
        {:reply, serialize_state(state), state}
    end

    def handle_info({:next}, state) do
        Logger.info "Next level #{state.level}"

        new_grid = generate_maze()
        new_state = state
        |> Map.put(:grid, new_grid)
        |> Map.put(:status, "play")

        FbLive.Endpoint.broadcast! @channel_name, "current", serialize_state(new_state)

        {:noreply, new_state}
    end

    def handle_cast({:new, new_state}, _state) do
        FbLive.Endpoint.broadcast! @channel_name, "current", serialize_state(new_state)
        {:noreply, new_state}
    end

    def handle_cast({:current}, state) do
        Logger.info "Requesting current grid state"

        FbLive.Endpoint.broadcast! @channel_name, "current", serialize_state(state)
        {:noreply, state}
    end

    def handle_cast({:move, direction}, %MazeState{ status: "win" } = state) do
        Logger.warn "Game is over, unable to make move to #{direction}"
        {:noreply, state}
    end

    def handle_cast({:move, direction}, %MazeState{ grid: grid, status: "play" } = state) do
        Logger.info "Make move in grid #{direction}"

        new_grid = case MazeBase.next_move(grid, @grid_size, direction) do
            {:ok, grid} -> grid 
            {:error, message} -> 
                Logger.error message
                grid
        end

        new_state = Map.put(state, :grid, new_grid)
        new_state = case MazeBase.is_game_over?(new_grid) do
            true -> 
                next_level()
                current = Map.get(new_state, :level, 1)

                new_state
                |> Map.put(:level, current + 1)
                |> Map.put(:status, "win")
            false -> new_state
        end

        moves = Map.get(new_state, :total_moves, 0)
        new_state = Map.put(new_state, :total_moves, 1 + moves)
        
        FbLive.Endpoint.broadcast! @channel_name, "current", serialize_state(new_state)

        {:noreply, new_state}
    end

    def handle_cast(request, state) do
        super(request, state)
    end
end