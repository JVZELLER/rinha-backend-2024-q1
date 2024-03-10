defaults = %{
  "DATABASE_NAME" => "rinha",
  "DATABASE_USER" => "admin",
  "DATABASE_PASS" => "123",
  "DATABASE_HOST" => "localhost",
  "DATABSE_POOL_SIZE" => "5",
  "READ_DATABSE_POOL_SIZE" => "5",
  "ECTO_QUEUE_TARGET" => "5000",
  "ECTO_QUEUE_INTERVAL" => "5000",
  "ECTO_REPO_TIMEOUT" => "30000",
  "APP_INSTANCE" => "localhost",
  "BACK_PRESSURE" => "true",
  "CONCURRENCY" => "1",
  "TIMEOUT_IN_SECONDS" => "4",
  "DISPATCH_TIMEOUT_IN_MS" => "200"
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
