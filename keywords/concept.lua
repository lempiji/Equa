
local _getn = table.getn;
local _insert = table.insert;
local _isearch = table.isearch;
local _icontains_if = table.icontains_if;
do
	local concept_meta = {};
	local concept_base = {};
	concept_base.description = function(self, desc)
		self.__desc = desc;
		return self;
	end;
	concept_base.implemented = function(self, _class)
		local _methods = _class.__methods;
		local _method;
		local _n = _getn(self.__methods);
		local _m = _getn(self.__metamethods);
		local _e = _getn(self.__events);
		local _count = 0;
		local _result = {};
		
		for i = 1, _n do
			if (_isearch(self.__methods[i].__attributes, static)) then
				if (_class[self.__methods[i].__name]) then
					_count = _count +1;
				else
					_insert(_result, self.__methods[i].__name);
				end
			else
				if (_class.__members[self.__methods[i].__name]) then
					_count = _count + 1;
				else
					_insert(_result, self.__methods[i].__name);
				end
			end
		end
		for i=1, _m do
			if (self.__metamethods[i].__name ~= "_init") then
				if (_class.__meta[self.__metamethods[i].__name]) then
					_count = _count + 1;
				else
					_insert(_result, self.__metamethods[i].__name);
				end
			else
				_count = _count + 1;
			end
		end
		for i = 1, _e do
			temp = self.__events[i];
			if (_icontains_if(_class.__events, function(v) return v.__name == temp.__name; end)) then
				_count = _count + 1;
			else
				_insert(_result, self.__events[i].__name);
			end
		end

		return _count == (_n + _m + _e), _result;
	end;
	
	concept_meta.__index = concept_base;
	concept_meta.__call = function(self, imp)
		local _type;
		for _, value in pairs(imp) do
			_type = object_type(value);
			if (_type == "method") then
				_insert(self.__methods, value);
			elseif (_type == "metamethod") then
				_insert(self.__metamethods, value);
			elseif (_type == "event") then
				_insert(self.__events, value);
			elseif (_type == "field") then
				_insert(self.__fields, value);
			else
				error("concept can have method, metamethod, field or event only", 2);
			end
		end
		return self;
	end;
	
	concept = function(name)
		local concept = {
			__type = "concept",
			__name = name,
			__desc = "",
			__methods = {},
			__metamethods = {},
			__fields = {},
			__events = {}
		};
		return setmetatable(concept, concept_meta);
	end
end
