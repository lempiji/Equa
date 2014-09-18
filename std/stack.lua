
local _getn = table.getn;
local _setn = table.setn;

local _wrap = coroutine.wrap;
local _yield = coroutine.yield;

namespace "std"
{
	class "Stack"
	:description("標準的なスタックです。")
	{
		metamethod "_init"
		:body(function(self)
			self._top = 1;
		end);
		
		method "Count"
		:body(function(self)
			return self._top - 1;
		end);
		
		method "IsEmpty"
		:body(function(self)
			return self._top <= 1;
		end);
		
		method "Contains"
		:body(function(self, obj)
			for i = 1, self._top - 1 do
				if (self[i] == obj) then
					return true;
				end
			end
			return false;
		end);
		
		method "Clear"
		:postcondition(function(self)
			if (not self:IsEmpty()) then
				error("stack is not empty!", 2);
			end
		end)
		:body(function(self)
			for i = 1, self._top - 1 do
				self[i] = nil;
			end
			self._top = 1;
		end);
		
		method "Peek"
		:precondition(function(self)
			if (self:IsEmpty()) then
				error("stack is empty", 2);
			end
		end)
		:body(function(self)
			return self[self._top - 1];
		end);
		
		method "Push"
		:body(function(self, obj)
			self[self._top] = obj;
			self._top = self._top + 1;
		end);
		
		method "Pop"
		:precondition(function(self)
			if (self:IsEmpty()) then
				error("stack is empty", 2);
			end
		end)
		:body(function(self)
			self._top = self._top - 1;
			local tmp = self[self._top];
			self[self._top] = nil;
			return tmp;
		end);
		
		method "Pairs"
		:body(function(self)
			return _wrap(
				function()
					local _top = self._top;
					for i = 1, _top - 1 do
						_yield(i, self[_top - i]);
					end
				end
			);
		end);
	}
}