
local _insert = table.insert;
local _format = string.format;

do
	local event_base = {};
	event_base.attributes = function(self, ...)
		for i = 1, arg.n do
			_insert(self.__attributes, arg[i]);
		end
		return self;
	end;
	event_base.description = function(self, desc)
		if (desc == nil or type(desc) ~= "string") then
			error(_format("description excepted 'string' (got %s)", object_type(desc)), 2);
		end
		self.__desc = desc;
		return self;
	end;
	
	local event_meta = {};
	event_meta.__index = event_base;
	
	event = function(name)
		local event = {
			__type = "event",
			__name = name,
			__desc = "",
			__attributes = {}
		};
		return setmetatable(event, event_meta);
	end;
end
