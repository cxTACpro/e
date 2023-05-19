local freeRunnerThread = nil
local function acquireRunnerThreadAndCallEventHandler(fn, ...)
	local acquiredRunnerThread = freeRunnerThread
	freeRunnerThread = nil
	fn(...)
	freeRunnerThread = acquiredRunnerThread
end
local function runEventHandlerInFreeThread(...)
	acquireRunnerThreadAndCallEventHandler(...)
	while true do
		acquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end
local Connection = {}
Connection.__index = Connection
function Connection.new(signal, fn)
	return setmetatable({
		_connected = true,
		_signal = signal,
		_fn = fn,
		_next = false,
	}, Connection)
end
function Connection:Disconnect()
	assert(self._connected, "Can't disconnect a connection twice.", 2)
	self._connected = false
    local signal = self._signal
	if signal._handlerListHead == self then
		signal._handlerListHead = self._next
	else
		local prev = signal._handlerListHead
		while prev and prev._next ~= self do
			prev = prev._next
		end
		if prev then
			prev._next = self._next
		end
	end

    if signal.connectionsChanged then
		signal.totalConnections -= 1
        signal.connectionsChanged:Fire(-1)
    end
end
setmetatable(Connection, {
	__index = function(tb, key)
		error(("Attempt to get Connection::%s (not a valid member)"):format(tostring(key)), 2)
	end,
	__newindex = function(tb, key, value)
		error(("Attempt to set Connection::%s (not a valid member)"):format(tostring(key)), 2)
	end
})

-- Signal class
local Signal = {}
Signal.__index = Signal

function Signal.new(createConnectionsChangedSignal)
	local self = setmetatable({
		_handlerListHead = false,	
	}, Signal)
    if createConnectionsChangedSignal then
        self.totalConnections = 0
		self.connectionsChanged = Signal.new()
	end
    return self
end

function Signal.Connect(fn)
	local connection = Connection.new(self, fn)
	if self._handlerListHead then
		connection._next = self._handlerListHead
		self._handlerListHead = connection
	else
		self._handlerListHead = connection
	end

	if self.connectionsChanged then
        self.totalConnections += 1
		self.connectionsChanged:Fire(1)
	end
	return connection
end
function Signal.DisconnectAll()
	self._handlerListHead = false

    if self.connectionsChanged then
		self.connectionsChanged:Fire(-self.totalConnections)
		self.connectionsChanged:Destroy()
		self.connectionsChanged = nil
		self.totalConnections = 0
	end
end
Signal.Destroy = Signal.DisconnectAll
Signal.destroy = Signal.DisconnectAll
function Signal.Fire(...)
	local item = self._handlerListHead
	while item do
		if item._connected then
			if not freeRunnerThread then
				freeRunnerThread = coroutine.create(runEventHandlerInFreeThread)
			end
			task.spawn(freeRunnerThread, item._fn, ...)
		end
		item = item._next
	end
end
function Signal.Wait()
	local waitingCoroutine = coroutine.running()
	local cn;
	cn = self.Connect(function(...)
		cn:Disconnect()
		task.spawn(waitingCoroutine, ...)
	end)
	return coroutine.yield()
end
return Signal
