
local IQueryable = std.query.IQueryable;
local List = std.collection.List;

local _wrap = coroutine.wrap;
local _yield = coroutine.yield;

namespace "std"
{
	namespace "query"
	{
		class "Query"
		:implements(IQueryable)
		{
			metamethod "_init"
			:body(function(self, source)
				self:SetSource(source);
			end);
			
			method "GetSource"
			:body(function(self)
				return self._source;
			end);
			method "SetSource"
			:body(function(self, source)
				self._source = source;
			end);
			
			method "Values"
			:body(function(self)
				return self._source:Values();
			end);
		}
	}
}
local Query = std.query.Query;

namespace "std"
{
	namespace "query"
	{
		class "Where"
		:inherits(Query)
		:implements(IQueryable)
		{
			metamethod "_init"
			:body(function(self, pred, source)
				Query._init(self, source);
				self._pred = pred;
			end);
			
			method "Values"
			:attributes(override)
			:body(function(self)
				return _wrap(function()
					local pred = self._pred;
					for item in self._source:Values() do
						if (pred(item)) then
							_yield(item);
						end
					end
				end);
			end);
		};
		
		class "Select"
		:inherits(Query)
		:implements(IQueryable)
		{
			metamethod "_init"
			:body(function(self, func, source)
				Query._init(self, source);
				self._func = func;
			end);
			
			method "Values"
			:attributes(override)
			:body(function(self)
				return _wrap(function()
					local func = self._func;
					for item in self._source:Values() do
						_yield(func(item));
					end
				end);
			end);
		};
		
		class "Join"
		:inherits(Query)
		:implements(IQueryable)
		{
			metamethod "_init"
			:body(function(self, source1, source2)
				Query._init(self, source1);
				self._source2 = source2;
			end);
			
			method "Values"
			:attributes(override)
			:body(function(self)
				return _wrap(function()
					for item in self._source:Values() do
						_yield(item);
					end
					for item in self._source2:Values() do
						_yield(item);
					end
				end);
			end);
		};
		
		class "Skip"
		:inherits(Query)
		:implements(IQueryable)
		{
			metamethod "_init"
			:body(function(self, n, source)
				Query._init(self, source);
				self._n = n or 0;
			end);
			
			method "Values"
			:attributes(override)
			:body(function(self)
				return _wrap(function()
					local n = self._n;
					local count = 1;
					for item in self._source:Values() do
						if (count > n) then
							_yield(item);
						end
						count = count + 1;
					end
				end);
			end);
		};
		
		class "Take"
		:inherits(Query)
		:implements(IQueryable)
		{
			metamethod "_init"
			:body(function(self, n, source)
				Query._init(self, source);
				self._n = n or 0;
			end);
			
			method "Values"
			:attributes(override)
			:body(function(self)
				return _wrap(function()
					local n = self._n;
					local count = 1;
					for item in self._source:Values() do
						if (count > n) then
							return;
						end
						_yield(item);
						count = count + 1;
					end
				end);
			end);
		};
		
		class "Stride"
		:inherits(Query)
		:implements(IQueryable)
		{
			metamethod "_init"
			:body(function(self, stride, source)
				Query._init(self, source);
				self._stride = stride or 0;
			end);
			
			method "Values"
			:attributes(override)
			:body(function(self)
				return _wrap(function()
					local stride = self._stride;
					local count = stride;
					for item in self._source:Values() do
						if (count == stride) then
							_yield(item);
							count = 0;
						else
							count = count + 1;
						end
					end
				end);
			end);
		};
		
		class "Repeat"
		:inherits(Query)
		:implements(IQueryable)
		{
			metamethod "_init"
			:body(function(self, rep, source)
				Query._init(self, source);
				self._repeat = rep or 1;
			end);
			
			method "Values"
			:attributes(override)
			:body(function(self)
				return _wrap(function()
					for i = 1, self._repeat do
						for item in self._source:Values() do
							_yield(item);
						end
					end
				end);
			end);
		};
	}
}
