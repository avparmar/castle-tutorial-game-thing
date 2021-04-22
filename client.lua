require 'common'

local client = clientServer.client

client.enabled = true
client.start('127.0.0.1:22122')

function client.connect()
  print('client: connected to server')
end

function client.disconnect()
  print('clien: disconnected from server')
end

function client.keypressed(key)
  if client.connected then
    client.send('pressedKey', key)
  end
end

function client.receive(message, ...)
  if message == 'otherClientPressedKey' then
    local otherClientId, key = ...
    print('client: other client ' .. otherClientId .. " pressed key '" .. key .. "'")
  end
end