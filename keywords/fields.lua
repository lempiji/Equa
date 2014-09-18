
do
	local field_base = {};
	field_base.description = function(self, desc)
		self.__desc = desc;
		return self;
	end;
	field_base.attributes = function(self, ...)
		for i = 1, arg.n do
			table.insert(self.__attributes, arg[i]);
		end
		return self;
	end;
	field_base.init = function(self, value)
		self.__init = value;
		return self;
	end;
	
	local field_meta = {};
	field_meta.__index = field_base;
	
	field = function(name)
		local field = {
			__type = "field",
			__name = name,
			__desc = "",
			__attributes = {},
			__init = nil
		};
		return setmetatable(field, field_meta);
	end
end
