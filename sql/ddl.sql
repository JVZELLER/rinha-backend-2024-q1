CREATE TABLE "clients" (
    "id" bigserial,
    "balance" bigint,
    "limit" bigint,
    "inserted_at" timestamp NOT NULL,
    "updated_at" timestamp NOT NULL,
    PRIMARY KEY ("id")
);
CREATE TABLE "entries" (
    "id" bigserial,
    "amount" bigint,
    "type" varchar(255),
    "description" varchar(255),
    "client_id" bigint,
    CONSTRAINT "entries_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "clients"("id"),
    "inserted_at" timestamp NOT NULL,
    PRIMARY KEY ("id")
);
CREATE INDEX entries_client_id_inserted_at_index ON public.entries USING btree (client_id, inserted_at);
CREATE OR REPLACE FUNCTION fn_insert_entry(
        entry_amount bigint,
        entry_type varchar(1),
        entry_description varchar(10),
        client_id int8
    ) RETURNS jsonb AS $$
DECLARE client_limit bigint;
client_balance bigint;
BEGIN -- Updates client balance
WITH updated_client_data AS (
    UPDATE clients
    SET balance = clients.balance + entry_amount
    WHERE id = client_id
    RETURNING balance,
        "limit"
)
SELECT balance,
    "limit"
FROM updated_client_data INTO client_balance,
    client_limit;
-- Check if client exists
IF client_balance IS NULL
OR client_limit IS NULL THEN RAISE EXCEPTION 'client_not_found';
END IF;
-- Check client has invalid balance
IF client_limit * -1 > client_balance THEN RAISE EXCEPTION 'entry_amount_exceeds_client_limit';
END IF;
-- Insert entry
INSERT INTO entries (
        amount,
        type,
        description,
        client_id,
        inserted_at
    )
VALUES (
        entry_amount,
        entry_type,
        entry_description,
        client_id,
        now()
    );
-- Return client balance and limit as JSONB
RETURN jsonb_build_object('limit', client_limit, 'balance', client_balance);
END;
$$ LANGUAGE plpgsql;