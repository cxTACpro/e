local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"
function Signal.new()
	print('new')
	local self = setmetatable({}, Signal)
	self._bindableEvent = Instance.new("BindableEvent")
	self._argData = nil
	self._argCount = nil -- Prevent edge case of :Fire("A", nil) --> "A" instead of "A", nil
	return self
end
function Signal:Fire(...)
	print('fire')
	self._argData = {...}
	self._argCount = select("#", ...)
	self._bindableEvent:Fire()
	self._argData = nil
	self._argCount = nil
end
function Signal:Connect(handler)
	print('connect')
	if not (type(handler) == "function") then
		error(("connect(%s)"):format(typeof(handler)), 2)
	end
	return self._bindableEvent.Event:Connect(function()
		handler(unpack(self._argData, 1, self._argCount))
	end)
end
function Signal:Wait()
	print('wait')
	self._bindableEvent.Event:Wait()
	assert(self._argData, "Missing arg data, likely due to :TweenSize/Position corrupting threadrefs.")
	return unpack(self._argData, 1, self._argCount)
end
function Signal:Destroy()
	print('delelete')
	if self._bindableEvent then
		self._bindableEvent:Destroy()
		self._bindableEvent = nil
	end
	self._argData = nil
	self._argCount = nil
end
return Signal
