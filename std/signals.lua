
local _getn = table.getn;
local _setn = table.setn;
local _insert = table.insert;
local _remove = table.remove;

namespace "std"
{
	class "Signal"
	:description("��ɃC�x���g���s�p�̃N���X�ł��B")
	{
		metamethod "_init"
		:description("�C�j�V�����C�U�ł��B")
		:body(function(self)
			self._slots = {};
		end);
		
		method "Emit"
		:description("�֘A�t����ꂽ�X���b�g��S�ČĂяo���܂��B")
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
		:description("Emit�Ɠ����̊֐��Ăяo�����`���܂��B")
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
		:description("�֐��Ăяo�����\�ȃX���b�g���֘A�t���܂��B")
		:body(function(self, slot)
			_insert(self._slots, slot);
		end);
		
		method "Disconnect"
		:description("�֘A�t�����Ă���X���b�g���O���܂��B")
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
