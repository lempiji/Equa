
local IQueryable = std.query.IQueryable;
local ICombiner = std.combiner.ICombiner;
local List = std.collection.List;

local _wrap = coroutine.wrap;
local _yield = coroutine.yield;

namespace "std"
{
	namespace "combiner"
	{
		class "Combiner"
		:implements(ICombiner)
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
			
			method "Compute"
			:body(function(self)
				return nil;
			end);
		}
	}
}
local Combiner = std.combiner.Combiner;

namespace "std"
{
	namespace "combiner"
	{
		class "Count"
		:inherits(Combiner)
		{
			metamethod "_init"
			:body(function(self, source)
				Combiner._init(self, source);
			end);
			method "Compute"
			:attributes(override)
			:body(function(self)
				local count = 0;
				for item in self._source:Values() do
					count = count + 1;
				end
				return count;
			end);
		};
		class "CountIf"
		:inherits(Combiner)
		{
			metamethod "_init"
			:body(function(self, pred, source)
				Combiner._init(self, source);
				self._pred = pred;
			end);
			
			method "Compute"
			:attributes(override)
			:body(function(self)
				local pred = self._pred;
				local count = 0;
				for item in self._source:Values() do
					if (pred(item)) then
						count = count + 1;
					end
				end
				return count;
			end);
		};
		
		class "Aggregate"
		:inherits(Combiner)
		{
			metamethod "_init"
			:body(function(self, accumlator, source)
				Combiner._init(self, source);
				self._accumlator = accumlator;
			end);
			
			method "Compute"
			:attributes(override)
			:body(function(self)
				local accumlator = self._accumlator;
				local work;
				for item in self._source:Values() do
					if (work) then
						work = accumlator(work, item);
					else
						work = item;
					end
				end
				return work;
			end);
		};
		
		class "Max"
		:inherits(Combiner)
		{
			method "Compute"
			:attributes(override)
			:body(function(self)
				local co = self._source:Values();
				local max = co();
				for item in co do
					if (max < item) then
						max = item;
					end
				end
				return max;
			end);
		};
		class "Min"
		:inherits(Combiner)
		{
			method "Compute"
			:attributes(override)
			:body(function(self)
				local co = self._source:Values();
				local min = co();
				for item in co do
					if (item < min) then
						min = item;
					end
				end
				return min;
			end);
		};
		
		class "Sum"
		:inherits(Combiner)
		{
			method "Compute"
			:attributes(override)
			:body(function(self)
				local sum;
				for item in self._source:Values() do
					if (sum) then
						sum = sum + item;
					else
						sum = item;
					end
				end
				return sum;
			end);
		};
		
		class "Average"
		:inherits(Combiner)
		{
			method "Compute"
			:attributes(override)
			:body(function(self)
				local sum;
				local count = 0;
				for item in self._source:Values() do
					count = count + 1;
					if (sum) then
						sum = sum + item;
					else
						sum = item;
					end
				end
				return sum and (sum / count) or nil;
			end);
		};
		
		class "ToList"
		:inherits(Combiner)
		{
			method "Compute"
			:attributes(override)
			:body(function(self)
				local result = List:new();
				for item in self._source:Values() do
					result:Add(item);
				end
				return result;
			end);
		};
	}
}