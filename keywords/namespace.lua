
local _insert = table.insert;

do
	local namespace_meta = {};
	local parent_stack = {_G};
	local parent_stack_level = 1;
	local push_stack = function(n)
		parent_stack_level = parent_stack_level + 1;
		parent_stack[parent_stack_level] = n;
		return n;
	end;
	local pop_stack = function()
		parent_stack[parent_stack_level] = nil;
		parent_stack_level = parent_stack_level - 1;
	end;
	local peek_stack = function()
		return parent_stack[parent_stack_level];
	end;
	
	namespace_meta.__call = function(self, t)
		local info;
		for index, value in pairs(t) do
			info = object_type(value);
			if (info == "namespace") then
				info = object_name(value);
				if (not self[info]) then
					self[info] = value;
					_insert(self.__namespaces, value);
				end
			elseif (info == "concept") then
				info = object_name(value);
				if (not self[info]) then
					self[info] = value;
					_insert(self.__concepts, value);
				else
					error("already exists concept '" .. object_name(value) .. "'", 2);
					error(string.format("already exists concept '%s'", object_name(value)), 2);
				end
			elseif (info == "class") then
				info = object_name(value);
				if (not self[info]) then
					self[info] = value;
					_insert(self.__classes, value);
				else
					error(string.format("already exists class '%s'", object_name(value)), 2);
				end
			elseif (info == "enum") then
				info = object_name(value);
				if (not self[info]) then
					self[info] = value;
					_insert(self.__enums, value);
				else
					error(string.format("already exists enum '%s'", object_name(value)), 2);
				end
			else
				self[index] = value;
			end
		end
		
		pop_stack();
		if (parent_stack_level == 1) then
			--ÉOÉçÅ[ÉoÉãÇ÷é¿ëï
			_G[self.__name] = self;
		end
		
		setmetatable(self, nil);
		return self;
	end;
	
	namespace = function(name)
		local n = peek_stack()[name];
		if (not n or (object_type(n) ~= "namespace")) then
			n = {
				__type = "namespace",
				__name = name,
				__classes = {},
				__concepts = {},
				__enums = {},
				__namespaces = {}
			};
		end
		return push_stack(setmetatable(n, namespace_meta));
	end
end
