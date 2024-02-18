defmodule RinhaBackend.Repo.Migrations.CreateInsertEntryFunction do
  use Ecto.Migration

  def up do
    repo().query!(~s/
        CREATE OR REPLACE FUNCTION fn_insert_entry(
            entry_amount bigint,
            entry_type varchar(1),
            entry_description varchar(10),
            client_id int8
        ) RETURNS jsonb AS
        $$
        DECLARE
        client_limit bigint;
        client_balance bigint;
        BEGIN
          -- Updates client balance
          WITH updated_client_data AS (
            UPDATE clients
            SET balance = clients.balance + entry_amount
            WHERE id = client_id
            RETURNING balance, "limit"
          )
          SELECT balance, "limit"
          FROM updated_client_data
          INTO client_balance, client_limit;


          -- Check if client exists
          IF client_balance IS NULL OR client_limit IS NULL THEN
            RAISE EXCEPTION 'client_not_found';
          END IF;

          -- Check client has invalid balance
          IF client_limit  * -1 > client_balance THEN
            RAISE EXCEPTION 'entry_amount_exceeds_client_limit';
          END IF;

          -- Insert entry
          INSERT INTO entries (amount, type, description, client_id, inserted_at) VALUES (entry_amount, entry_type, entry_description, client_id, now());

          -- Return client balance and limit as JSONB
          RETURN jsonb_build_object('limit', client_limit, 'balance', client_balance);
        END;
        $$
        LANGUAGE plpgsql;
      /)
  end

  def down do
    repo().query!(~s/
      DROP FUNCTION fn_insert_entry (bigint, varchar(1), varchar(10), int8);
    /)
  end
end
