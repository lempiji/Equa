local _insert = table.insert;
local _remove = table.remove;

local _wrap = coroutine.wrap;
local _yield = coroutine.yield;

namespace "std"
{
	class "Queue"
	:description("ïWèÄìIÇ»QueueÇ≈Ç∑ÅB")
	{
		metamethod "_init"
		:body(function(self)
			self._count = 0;
		end);
		
		method "Count"
		:body(function(self)
			return self._count;
		end);
		
		method "IsEmpty"
		:body(function(self)
			return self._count == 0;
		end);
		
		method "Clear"
		:postcondition(function(self)
			if (not self:IsEmpty()) then
				error("queue is not empty!", 2);
			end
		end)
		:body(function(self)
			while (not self:IsEmpty()) do
				self:Pop();
			end
		end);
		
		method "Contains"
		:body(function(self, obj)
			for i = 1, self._count do
				if (self[i] == obj) then
					return true;
				end
			end
			return false;
		end);
		
		method "Peek"
		:precondition(function(self)
			if (self:IsEmpty()) then
				error("queue is empty", 2);
			end
		end)
		:body(function(self)
			return self[1];
		end);
		
		method "Push"
		:body(function(self, obj)
			_insert(self, obj);
			self._count = self._count + 1;
		end);
		method "Pop"
		:precondition(function(self)
			if (self:IsEmpty()) then
				error("queue is empty", 2);
			end
		end)
		:body(function(self)
			self._count = self._count - 1;
			return _remove(self, 1);
		end);
		
		method "Pairs"
		:body(function(self)
			return _wrap(
				function()
					local _count = self._count;
					for i = 1, _count do
						_yield(i, self[i]);
					end
				end
			);
		end);
	}
}