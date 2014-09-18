
local _getn = table.getn;
local _setn = table.setn;
local _insert = table.insert;
local _remove = table.remove;

namespace "std"
{
	class "Signal"
	:description("主にイベント発行用のクラスです。")
	{
		metamethod "_init"
		:description("イニシャライザです。")
		:body(function(self)
			self._slots = {};
		end);
		
		method "Emit"
		:description("関連付けられたスロットを全て呼び出します。")
		:body(function(self, ...)
			local n = _getn(self._slots);
			if (n == 0) then
				return;
			end
			
			local execs = {};
			for i = 1, n do
				execs[i] = self._slots[i];
			end
			for i = 1, n do
				execs[i](unpack(arg));
			end
		end);
		metamethod "__call"
		:description("Emitと同等の関数呼び出しを定義します。")
		:body(function(self, ...)
			local n = _getn(self._slots);
			if (n == 0) then
				return;
			end
			
			local execs = {};
			for i = 1, n do
				execs[i] = self._slots[i];
			end
			for i = 1, n do
				execs[i](unpack(arg));
			end
		end);
		
		method "Connect"
		:description("関数呼び出しが可能なスロットを関連付けます。")
		:body(function(self, slot)
			_insert(self._slots, slot);
		end);
		
		method "Disconnect"
		:description("関連付けられているスロットを外します。")
		:body(function(self, slot)
			local c = 0;
			local slots = self._slots;
			for i = _getn(slots), 1, -1 do
				if (slots[i] == slot) then
					_remove(slots, i);
				end
			end
		end);
	}
}
