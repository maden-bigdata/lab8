csv = require('csv')

local CHUNK = 10000
local QUERY = "INSERT INTO lab8.userlog FORMAT CSV"

function upload_to_clickhouse(csv_data)
    local stream = io.popen('clickhouse-client --query="' .. QUERY .. '"\r\n', "w")
    stream:write(csv_data)
    stream:close()
end

-- Connect to tarantool space
box.cfg{listen = 3301}
local space = box.schema.space.create('userlog', {if_not_exists=true})
local index = space:create_index('primary', { parts={'Day','TickTime','Speed'}, if_not_exists=true})

print("Transfering data...")
local start_time = os.time()
local row_count = 0
local buffer = {}
local current_length = 0
for _, tuple in index:pairs() do
    row_count = row_count + 1
    table.insert(buffer, tuple:totable())

    if current_length == CHUNK then
        upload_to_clickhouse(csv.dump(buffer))
        buffer = {}
        current_length = 0
    else
        current_length = current_length + 1
    end
end
-- Transfer last chunk
if (#buffer) then
    upload_to_clickhouse(csv.dump(buffer))
end

local elapsed = os.difftime(os.time(), start_time)
print("Transfered " .. row_count .. " rows in " .. elapsed .. " seconds")
