
do
	local element_base = {};
	element_base.description = function(self, desc)
		self.__desc = desc;
		return self;
	end;
	
if (_DEBUG) then
	element_base.value = function(self, value)
		if (type(value) ~= "number") then
			error(string.format("bad argument#1 on element:value (number excepted, got %s)", object_type(value)), 2);
		end
		self.__value = value;
		return self;
	end;
else
	element_base.value = function(self, value)
		self.__value = value;
		return self;
	end;
end
	
	local element_meta = {
		__index = element_base;
	};
	element_meta.__index = element_base;
	
	element = function(name)
		local element = {
			__type = "element",
			__name = name,
			__desc = "",
			__value = nil
		}
		return setmetatable(element, element_meta);
	end
end
