defmodule MyApp.CLI  do
  def main(args) do
    Process.flag(:trap_exit, true)
    start_time = :erlang.system_time
    [actor_num, topology, algorithm] = args
    actor_num = String.to_integer(actor_num)
    choose_topology(topology, actor_num, algorithm)
    |> run(algorithm)

    receive do
      msg -> IO.puts "Message Received: #{inspect msg}, time cost #{:erlang.system_time - start_time} microsecond"
    end
  end

  def choose_topology(topology, actor_num, algorithm) do
    case topology do
      "random" -> random_topology(actor_num, algorithm)
      "linear" -> linear_topology(actor_num, algorithm)
      "grid" -> grid_topology(actor_num, algorithm)
      "imperfect" -> imperfect_grid_topology(actor_num, algorithm)
    end
  end

#  random topology
  def random_topology(actor_num, algorithm) do
#    Enum.each(0..(actor_num - 1), fn x -> Map.put(map, {0, x}, spawn(Gossip, :pass_rumor, [0, x, 0, "random"])) end)
    case algorithm do
      "gossip" -> Enum.reduce(0..(actor_num - 1), %{}, fn x,acc -> Map.put(acc, {0, x}, spawn_link(Gossip, :pass_rumor, [0, x, 0, "random"])) end)
      "push_sum" -> Enum.reduce(0..(actor_num - 1), %{}, fn x,acc -> Map.put(acc, {0, x}, spawn_link(PushSum, :push_sum, [0, x, x, 1, "random"])) end)
    end
#    Enum.reduce(0..(actor_num - 1), %{}, fn x,acc -> Map.put(acc, {0, x}, spawn_link(Gossip, :pass_rumor, [0, x, 0, "random"])) end)
  end

#  linear topology
  def linear_topology(actor_num, algorithm) do
    case algorithm do
      "gossip" -> Enum.reduce(0..(actor_num - 1), %{}, fn x,acc -> Map.put(acc, {0, x}, spawn_link(Gossip, :pass_rumor, [0, x, 0, "linear"])) end)
      "push_sum" -> Enum.reduce(0..(actor_num - 1), %{}, fn x,acc -> Map.put(acc, {0, x}, spawn_link(PushSum, :push_sum, [0, x, x, 1, "linear"])) end)
    end
#    Enum.reduce(0..(actor_num - 1), %{}, fn x,acc -> Map.put(acc, {0, x}, spawn_link(Gossip, :pass_rumor, [0, x, 0, "linear"])) end)
  end

#  grid topology
  def grid_topology(actor_num, algorithm) do
    n = round(:math.sqrt(actor_num))
    actor_num = n * n;
    case algorithm do
      "gossip" -> Enum.reduce(0..(actor_num - 1), %{}, fn x,acc -> Map.put(acc, {div(x, n), rem(x, n)}, spawn_link(Gossip, :pass_rumor, [div(x, n), rem(x, n), 0, "grid"])) end)
      "push_sum" -> Enum.reduce(0..(actor_num - 1), %{}, fn x,acc -> Map.put(acc, {div(x, n), rem(x, n)}, spawn_link(PushSum, :push_sum, [div(x, n), rem(x, n), x, 1, "grid"])) end)
    end
#    Enum.reduce(0..(actor_num - 1), %{}, fn x,acc -> Map.put(acc, {div(x, n), rem(x, n)}, spawn_link(Gossip, :pass_rumor, [div(x, n), rem(x, n), 0, "grid"])) end)
  end

#  imperfect grid topology
  def imperfect_grid_topology(actor_num, algorithm) do
    n = round(:math.sqrt(actor_num))
    actor_num = n * n;
    case algorithm do
      "gossip" -> Enum.reduce(0..(actor_num - 1), %{}, fn x,acc -> Map.put(acc, {div(x, n), rem(x, n)}, spawn_link(Gossip, :pass_rumor, [div(x, n), rem(x, n), 0, "imperfect"])) end)
      "push_sum" -> Enum.reduce(0..(actor_num - 1), %{}, fn x,acc -> Map.put(acc, {div(x, n), rem(x, n)}, spawn_link(PushSum, :push_sum, [div(x, n), rem(x, n), x, 1, "imperfect"])) end)
    end
#    Enum.reduce(0..(actor_num - 1), %{}, fn x,acc -> Map.put(acc, {div(x, n), rem(x, n)}, spawn_link(Gossip, :pass_rumor, [div(x, n), rem(x, n), 0, "imperfect"])) end)
  end


  def run(map, algorithm) do
#    7 is the rumor
    case algorithm do
      "gossip" -> send map[{0, 0}], {Application.get_env(:gossip, :rumor, 7), map}
      "push_sum" -> send map[{0, 0}], {Application.get_env(:gossip, :initial_s, 0), Application.get_env(:gossip, :initial_w, 0), map, 0}
    end
  end
end
