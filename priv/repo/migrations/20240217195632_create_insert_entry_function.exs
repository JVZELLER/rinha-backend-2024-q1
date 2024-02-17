defmodule RinhaBackend.Repo.Migrations.CreateInsertEntryFunction do
  use Ecto.Migration

  def change do
    repo().query!(~s/
      CREATE OR REPLACE FUNCTION insert_entry(
          entry_type varchar(1),
          client_id bigint,
          entry_amount bigint
      ) RETURNS void AS
      $$
      BEGIN
        with updated_client_data as (
          update clients
          set balance = clients.balance + case when entry_type = 'd' then entry_amount * -1 else entry_amount end
          where where id = client_id;
          returning balance, limit;
        ), inserted_entry as
          INSERT INTO entries (type, client_id, amount, inserted_at) VALUES (entry_type, client_id, entry_amount, now());
        )




          -- Check if the entry type is 'd' (debt)
          IF entry_type = 'd' THEN
              -- Check if the entry amount exceeds the client's limit
              IF entry_amount - (SELECT balance FROM clients WHERE id = client_id) < (SELECT limit FROM clients WHERE id = client_id) * -1 THEN
                  RAISE EXCEPTION 'Entry amount exceeds client limit!';
              END IF;
          END IF;

          -- Insert the entry into the "entries" table
          INSERT INTO entries (type, client_id, amount) VALUES (entry_type, client_id, entry_amount);

          -- Update the client's balance accordingly
          UPDATE clients SET balance = balance + entry_amount WHERE id = client_id;
      END;
      $$
      LANGUAGE plpgsql;

    /)
  end
end
