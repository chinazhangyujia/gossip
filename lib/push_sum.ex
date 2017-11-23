defmodule PushSum do
  def push_sum(i, j, s, w, topology) do
    receive do
      {received_s, received_w, map, count} -> terminate?(received_s, received_w, map, count, s, w, i, j, topology)
#      push_sum(i, j, s, w, count, topology)
    end
  end

  def terminate?(received_s, received_w, map, count, s, w, i, j, topology) do
    IO.puts "I receive the s and w"
    new_s = received_s + s
    new_w = received_w + w
    dif = new_s / new_w - s / w
    case count do
      6 -> exit(s / w)
      _ -> find_next(topology, i, j, Map.size(map)) |> next_pid(map) |> send_to_next(new_s / 2, new_w / 2, map, count, dif, i, j, topology)
    end
  end

  def find_next(topology, i, j, n) do
    case topology do
      "random" -> next_random_node(i, j, n)
      "linear" -> next_linear_node(i, j, n)
      "grid" -> next_grid_node(i, j, n)
      "imperfect" -> next_imperfect_grid_node(i, j, n)
    end
  end


  #  next random node
  def next_random_node(i, j, n) do
    y = Enum.random(0..(n - 1))
    case y == j do
      true -> next_random_node(i, j, n)
      false -> {i, y}
    end
  end

  #  next grid node
  def next_grid_node(i, j, n) do
    m = round(:math.sqrt(n))
    x = Enum.random([i + 1, i - 1])
    y = Enum.random([j - 1, j + 1])
    case x < 0 || x >= m || y < 0 || y >= m do
      true -> next_grid_node(i, j, n)
      false -> {x, y}
    end
  end


  #  next linear node
  def next_linear_node(i, j, n) do
    y = Enum.random([j - 1, j + 1])
    case y < 0 || y >= n do
      true -> next_linear_node(i, j, n)
      false -> {i, y}
    end
  end

  #  next imperfect grid node
  def next_imperfect_grid_node(i, j, n) do
    m = round(:math.sqrt(n))
    x = Enum.random([i + 1, i - 1])
    y = Enum.random([j - 1, j + 1])
    case x < 0 || x >= m || y < 0 || y >= m do
      true -> next_imperfect_grid_node(i, j, n)
      false -> {x, y}
    end
  end



  def next_pid(position, map) do
    map[position]
  end

  def send_to_next(pid, send_s, send_w, map, count, dif, i, j, topology) do
    case dif < 1.0e-10 do
      true -> send pid, {send_s, send_w, map, count + 1}
      false -> send pid, {send_s, send_w, map, 0}
    end
    push_sum(i, j, send_s, send_w, topology)
  end

end
