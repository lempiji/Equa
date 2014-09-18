
local _insert = table.insert;
local _format = string.format;

do
	local enum_base = {};
	enum_base.description = function(self, desc)
		if (desc == nil or object_type(desc) ~= "string") then
			error(_format("bad argument#1 on enum description (string excepted, got %s)", object_type(desc)), 2);
		end
		self.__desc = desc;
		return self;
	end;
	
	local enum_meta = {};
	enum_meta.__index = enum_base;
	enum_meta.__call = function(self, impl)
		local objType;
		for _, value in pairs(impl) do
			objType = object_type(value);
			if (objType == "element") then
				_insert(self.__elements, value);
			else
				error(string.format("declared type is unknown (got %s)", _objType), 2);--–¢‘Î‰ž‚ÌŒ^
			end
		end
		
		local index = 0;
		for _, value in pairs(self.__elements) do
			index = value.__value or index + 1;
			value.__value = index;
			
			if (self[value.__name]) then
				error(_format("already exists element '%s'", value.__name));
			end
			self[value.__name] = value.__value;
		end
		
		setmetatable(self, nil);
		return self;
	end;
	
	function enum(name)
		local self = {
			__type = "enum",
			__name = name,
			__desc = "",
			__elements = {}
		};
		return setmetatable(self, enum_meta);
	end
end