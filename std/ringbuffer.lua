local _setn = table.setn;
local _insert = table.insert;
local _remove = table.remove;

local _wrap = coroutine.wrap;
local _yield = coroutine.yield;

namespace "std"
{
	class "RingBuffer"
	:description("新しい要素の追加により古い要素が消える固定長のFIFOコレクションです。")
	{
		metamethod "_init"
		:body(function(self, size)
			self._size = size or 4;
			self._count = 0;
			for i=1, self._size do
				self[i] = nil;
			end
			_setn(self, self._size);
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
		:body(function(self)
			_setn(self, 0);
			self._count = 0;
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
		
		method "Add"
		:body(function(self, obj)
			if (self._size > self._count) then
				self._count = self._count + 1;
			end
			_remove(self, 1);
			_insert(self, obj);
		end);
		
		method "Pairs"
		:body(function(self)
			return _wrap(
				function()
					local len = self._size;
					for i = 1, len do
						_yield(i, self[i]);
					end
				end
			);
		end);
		
		method "PairValues"
		:body(function(self)
			return _wrap(
				function()
					local len = self._size;
					for i = len - self._count + 1, len do
						_yield(i, self[i]);
					end
				end
			);
		end);
	}
}