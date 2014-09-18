
local IEnumerable = std.collection.IEnumerable;
local IQueryable = std.query.IQueryable;

local _insert = table.insert;
local _remove = table.remove;
local _getn = table.getn;
local _setn = table.setn;
local _sort = table.sort;
local _wrap = coroutine.wrap;
local _yield = coroutine.yield;

local List;
namespace "std"
{
	namespace "collection"
	{
		class "List"
		:implements(IEnumerable, IQueryable)
		:description("���l�C���f�b�N�X�I�ȃ��X�g�R���N�V������\���܂��B")
		{
			metamethod "_init"
			:description("�z����w�肵�ď������\�ȃC�j�V�����C�U�ł��B")
			:body(function(self, array)
				self._list = array or {};
			end);
			
			method "Clone"
			:description("�C���X�^���X�𕡐����ĕԂ��܂��B")
			:body(function(self)
				local list = self._list;
				local result = List:new();
				for i = 1, _getn(list) do
					result._list[i] = list[i];
				end
				return result;
			end);
			
			method "Get"
			:description("�C���f�b�N�X���w�肵�ėv�f���擾���܂��B")
			:body(function(self, index)
				return self._list[index];
			end);
			method "Set"
			:description("�C���f�b�N�X���w�肵�ėv�f��ݒ肵�܂��B")
			:body(function(self, index, value)
				self._list[index] = value;
			end);
			
			method "Length"
			:description("���X�g�̗v�f�̐����擾���܂��B")
			:body(function(self)
				return _getn(self._list);
			end);
			
			method "IsEmpty"
			:description("���X�g���ɗv�f�����邩���肵�܂��B")
			:body(function(self)
				return _getn(self._list) == 0;
			end);
			
			method "Clear"
			:description("���X�g���̗v�f��S�ăN���A���܂��B")
			:body(function(self)
				self._list = {};
			end);
			
			method "CopyTo"
			:description("���X�g���̗v�f���^�[�Q�b�g�̃��X�g�փR�s�[���܂��B")
			:body(function(self, target)
				local n = _getn(self._list);
				local from = self._list;
				local to = target._list;
				_setn(to, n);
				for i = 1, n do
					to[i] = from[i];
				end
			end);
			
			method "Contains"
			:description("����̃I�u�W�F�N�g���܂܂�邩���f���܂��B")
			:body(function(self, obj)
				local list = self._list;
				for i = 1, _getn(self._list) do
					if (list[i] == obj) then
						return true;
					end
				end
				return false;
			end);
			method "ContainsIf"
			:description("����̏q��𖞂����I�u�W�F�N�g���܂܂�邩���f���ĕԂ��܂��B")
			:body(function(self, pred)
				local list = self._list;
				for i = 1, _getn(list) do
					if (pred(list[i])) then
						return true;
					end
				end
				return false;
			end);
			
			method "FindFirst"
			:description("�n���ꂽ�I�u�W�F�N�g��O������T�����čŏ��Ɍ��������C���f�b�N�X��Ԃ��܂��B")
			:body(function(self, obj)
				local list = self._list;
				for i = 1, _getn(list) do
					if (list[i] == obj) then
						return i;
					end
				end
				return nil;
			end);
			method "FindLast"
			:description("�n���ꂽ�I�u�W�F�N�g���������T�����čŏ��Ɍ��������C���f�b�N�X��Ԃ��܂��B")
			:body(function(self, obj)
				local list = self._list;
				for i = _getn(list), 1, -1 do
					if (list[i] == obj) then
						return i;
					end
				end
				return nil;
			end);
			method "FindAll"
			:description("�n���ꂽ�I�u�W�F�N�g���܂܂��C���f�b�N�X��S�ă��X�g�ɂ��ĕԂ��܂��B")
			:body(function(self, obj)
				local list = self._list;
				local result = List:new();
				for i = 1, _getn(list) do
					if (list[i] == obj) then
						result:Add(i);
					end
				end
				return result;
			end);
			
			method "FindIfFirst"
			:description("�n���ꂽ�q��𖞂����v�f��O������T�����čŏ��Ɍ��������C���f�b�N�X��Ԃ��܂��B")
			:body(function(self, pred)
				local list = self._list;
				for i = 1, _getn(list) do
					if (pred(list[i])) then
						return i;
					end
				end
				return nil;
			end);
			method "FindIfLast"
			:description("�n���ꂽ�q��𖞂����v�f���������T�����čŏ��Ɍ��������C���f�b�N�X��Ԃ��܂��B")
			:body(function(self, pred)
				local list = self._list;
				for i = _getn(list), 1, -1 do
					if (pred(list[i])) then
						return i;
					end
				end
				return nil;
			end);
			method "FindIfAll"
			:description("�n���ꂽ�q��𖞂����v�f�̃C���f�b�N�X��S�ă��X�g�ɂ��ĕԂ��܂��B")
			:body(function(self, pred)
				local list = self._list;
				local result = List:new();
				for i = 1, _getn(list) do
					if (pred(list[i])) then
						result:Add(i);
					end
				end
				return result;
			end);
			
			method "SearchIfFirst"
			:description("�n���ꂽ�q��𖞂����v�f��O������T�����čŏ��Ɍ��������v�f��Ԃ��܂��B")
			:body(function(self, pred)
				local list = self._list;
				for i = 1, _getn(list) do
					if (pred(list[i])) then
						return list[i];
					end
				end
				return nil;
			end);
			method "SearchIfLast"
			:description("�n���ꂽ�q��𖞂����v�f���������T�����čŏ��Ɍ��������v�f��Ԃ��܂��B")
			:body(function(self, pred)
				local list = self._list;
				for i = _getn(list), 1, -1 do
					if (pred(list[i])) then
						return list[i];
					end
				end
				return nil;
			end);
			method "SearchIfAll"
			:description("�n���ꂽ�q��𖞂����v�f��O������T�����Č��������v�f��S�ă��X�g�ɂ��ĕԂ��܂��B")
			:body(function(self, pred)
				local list = self._list;
				local result = List:new();
				for i = 1, _getn(list) do
					if (pred(list[i])) then
						result:Add(list[i]);
					end
				end
				return result;
			end);
			
			method "Add"
			:body(function(self, obj)
				_insert(self._list, obj);
			end);
			
			method "Insert"
			:body(function(self, pos, obj)
				_insert(self._list, pos, obj);
			end);
			
			method "Concat"
			:body(function(self, range)
				local result = List:new();
				local list = self._list;
				for i = 1, _getn(list) do
					result._list[i] = list[i];
				end
				for value in range:Values() do
					_insert(result._list, value);
				end
			end);
			method "ConcatAssign"
			:body(function(self, range)
				local list = self._list;
				for value in range:Values() do
					_insert(list, v);
				end
			end);
			
			method "RemoveAt"
			:body(function(self, index)
				_remove(self._list, index);
			end);
			
			method "RemoveFirst"
			:body(function(self, obj)
				local list = self._list;
				for i = 1, _getn(list) do
					if (list[i] == obj) then
						_remove(list, i);
						return i;
					end
				end
				return nil;
			end);
			method "RemoveLast"
			:body(function(self, obj)
				local list = self._list;
				for i = _getn(list), 1, -1 do
					if (list[i] == obj) then
						_remove(list, i);
						return i;
					end
				end
				return nil;
			end);
			method "RemoveAll"
			:body(function(self, obj)
				local list = self._list;
				local n = _getn(list);
				local d = 0;
				for i = 1, n do
					if (list[i] == obj) then
						d = d + 1;
					else
						list[i], list[i - d] = list[i - d], list[i];
					end
				end
				_setn(list, n - d);
				return d;
			end);
			
			method "RemoveIfFirst"
			:body(function(self, pred)
				local list = self._list;
				for i = 1, _getn(list) do
					if (pred(list[i])) then
						_remove(list, i);
						return true;
					end
				end
				return false;
			end);
			method "RemoveIfLast"
			:body(function(self, pred)
				local list = self._list;
				for i = _getn(list), 1, -1 do
					if (pred(list[i])) then
						_remove(list, i);
						return true;
					end
				end
				return false;
			end);
			method "RemoveIfAll"
			:body(function(self, pred)
				local list = self._list;
				local n = _getn(list);
				local d = 0;
				for i = 1, n do
					if (pred(list[i])) then
						d = d + 1;
					else
						list[i], list[i - d] = list[i - d], list[i];
					end
				end
				_setn(list, n - d);
				return d;
			end);
			
			method "Sort"
			:body(function(self)
				_sort(self._list);
			end);
			method "SortBy"
			:body(function(self, pred)
				_sort(self._list, pred);
			end);
			method "Reverse"
			:body(function(self)
				_sort(self._list, function(a, b) return b < a; end);
			end);
			
			method "Apply"
			:body(function(self, func)
				local list = self._list;
				for i = 1, _getn(list) do
					list[i] = func(list[i]);
				end
			end);
			method "ApplyRange"
			:body(function(self, func, from, to)
				local list = self._list;
				for i = from or 1, to or _getn(list) do
					list[i] = func(list[i]);
				end
			end);
			
			method "Pairs"
			:body(function(self)
				local list = self._list;
				return _wrap(function()
					for i = 1, _getn(list) do
						_yield(i, list[i]);
					end
				end);
			end);
			
			method "Keys"
			:body(function(self)
				local list = self._list;
				return _wrap(function()
					for i = 1, _getn(list) do
						_yield(i);
					end
				end);
			end);
			method "Values"
			:body(function(self)
				local list = self._list;
				return _wrap(function()
					for i = 1, _getn(list) do
						_yield(list[i]);
					end
				end);
			end);
			
			metamethod "__concat"
			:body(function(self, rhs)
				return self:Concat(rhs);
			end);
		}
	}
}
List = std.collection.List;