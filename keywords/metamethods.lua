
local _insert = table.insert;

do
	local metamethod_base = {};
	metamethod_base.description = function(self, desc)
		self.__desc = desc;
		return self;
	end;
	metamethod_base.attributes = function(self, ...)
		for i = 1, arg.n do
			_insert(self.__attributes, arg[i]);
		end
		return self;
	end;
	metamethod_base.body = function(self, body)
		self.__body = body;
		return self;
	end;
	metamethod_base.args = function(self, ...)
		for i = 1, arg.n do
			_insert(self.__args, arg[i]);
		end
		return self;
	end;
	metamethod_base.returns = function(self, ...)
		for i = 1, arg.n do
			_insert(self.__returns, arg[i]);
		end
		return self;
	end;
	metamethod_base.precondition = function(self, body)
		self.__pre = body;
		return self;
	end;
	metamethod_base.postcondition = function(self, body)
		self.__post = body;
		return self;
	end
	
if (_DEBUG) then
	local raw_error = error;
	local hooked_error = function(message, level)
		raw_error(message, (level or 1) + 2);
	end;
	
	metamethod_base.getFunction = function(self)
		if (self.__pre and self.__post) then
			return function(obj, ...)
				error = hooked_error;
				self.__pre(obj, unpack(arg));
				local result = {self.__body(obj, unpack(arg))};
				self.__post(obj, unpack(result));
				error = raw_error;
				return unpack(result);
			end;
		elseif (self.__pre) then
			return function(obj, ...)
				error = hooked_error;
				self.__pre(obj, unpack(arg));
				local result = {self.__body(obj, unpack(arg))};
				error = raw_error;
				return unpack(result);
			end;
		elseif (self.__post) then
			return function(obj, ...)
				error = hooked_error;
				local result = {self.__body(obj, unpack(arg))};
				self.__post(obj, unpack(result));
				error = raw_error;
				return unpack(result);
			end;
		else
			return self.__body;
		end
	end;
else
	metamethod_base.getFunction = function(self)
		return self.__body
	end;
end
	
	local nil_metamethod = function() end;
	
	local metamethod_meta = {};
	metamethod_meta.__index = metamethod_base;
	
	metamethod = function(name)
		local metamethod = {
			__type = "metamethod",
			__name = name,
			__desc = "",
			__attributes = {},
			__pre = nil,
			__post = nil,
			__body = nil_metamethod,
			__args = {},
			__returns = {}
		};
		return setmetatable(metamethod, metamethod_meta);
	end
end
