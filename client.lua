require 'common'

local client = clientServer.client

if USE_LOCAL_SERVER then
  client.enabled = true
  client.start('127.0.0.1:22122')
else
  client.useCastleConfig()
end

local share = client.share
local home = client.home
local playerImages = {}
local PLAYER_SPEED = 200

function client.connect()
  print('client: connected to server')

  local player = share.players[client.id]
  home.x, home.y = player.x, player.y

  home.pic = 'https://pbs.twimg.com/media/DbfOOKDWkAAcV35.jpg'
  player.pic = home.pic
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

function client.draw()
  if client.connected then
    for clientId, player in pairs(share.players) do
      local x, y = player.x, player.y
      if clientId == client.id then
        x, y = home.x, home.y
      end

      if not playerImages[clientId] then
        playerImages[clientId] = {}
      end

      if playerImages[clientId].image then
        -- Image loaded. Draw it.
        local image = playerImages[clientId].image
        love.graphics.draw(image, x - 20, y - 20, 0, 40 / image:getWidth(), 40 / image:getHeight())
      else
        -- Image not loaded. Draw a rectangle.
        love.graphics.rectangle('fill', x - 20, y - 20, 40, 40)

        -- If a photo is available and we haven't fetched it yet,
        -- start fetching it and then save the image
        if player.pic and not playerImages[clientId].fetched then
          playerImages[clientId].fetched = true
          network.async(function()
            local image = love.graphics.newImage(player.pic)
          playerImages[clientId].image = image
          end)
        end
      end
    end
  else
    love.graphics.print('connecting...', 20, 20)
  end
end

function client.update(dt)
  if client.connected then
    if love.keyboard.isDown('left') then
      home.x = home.x - PLAYER_SPEED * dt
    end
    if love.keyboard.isDown('right') then
      home.x = home.x + PLAYER_SPEED * dt
    end
    if love.keyboard.isDown('up') then
      home.y = home.y - PLAYER_SPEED * dt
    end
    if love.keyboard.isDown('down') then
      home.y = home.y + PLAYER_SPEED * dt
    end
  end
end
