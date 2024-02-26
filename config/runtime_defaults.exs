defaults = %{
  "DATABASE_NAME" => "rinha",
  "DATABASE_USER" => "admin",
  "DATABASE_PASS" => "123",
  "DATABASE_HOST" => "db",
  "DATABSE_POOL_SIZE" => "100"
}

set_default_env = fn {name, value} ->
  should_set? =
    case System.get_env(name) do
      nil -> true
      "" -> true
      _ -> false
    end

  if should_set? do
    System.put_env(name, value)
  end

  :ok
end

for default <- defaults do
  set_default_env.(default)
end
