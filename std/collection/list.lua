
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
		:description("数値インデックス的なリストコレクションを表します。")
		{
			metamethod "_init"
			:description("配列を指定して初期化可能なイニシャライザです。")
			:body(function(self, array)
				self._list = array or {};
			end);
			
			method "Clone"
			:description("インスタンスを複製して返します。")
			:body(function(self)
				local list = self._list;
				local result = List:new();
				for i = 1, _getn(list) do
					result._list[i] = list[i];
				end
				return result;
			end);
			
			method "Get"
			:description("インデックスを指定して要素を取得します。")
			:body(function(self, index)
				return self._list[index];
			end);
			method "Set"
			:description("インデックスを指定して要素を設定します。")
			:body(function(self, index, value)
				self._list[index] = value;
			end);
			
			method "Length"
			:description("リストの要素の数を取得します。")
			:body(function(self)
				return _getn(self._list);
			end);
			
			method "IsEmpty"
			:description("リスト内に要素があるか判定します。")
			:body(function(self)
				return _getn(self._list) == 0;
			end);
			
			method "Clear"
			:description("リスト内の要素を全てクリアします。")
			:body(function(self)
				self._list = {};
			end);
			
			method "CopyTo"
			:description("リスト内の要素をターゲットのリストへコピーします。")
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
			:description("特定のオブジェクトが含まれるか判断します。")
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
			:description("特定の述語を満たすオブジェクトが含まれるか判断して返します。")
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
			:description("渡されたオブジェクトを前方から探索して最初に見つかったインデックスを返します。")
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
			:description("渡されたオブジェクトを後方から探索して最初に見つかったインデックスを返します。")
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
			:description("渡されたオブジェクトが含まれるインデックスを全てリストにして返します。")
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
			:description("渡された述語を満たす要素を前方から探索して最初に見つかったインデックスを返します。")
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
			:description("渡された述語を満たす要素を後方から探索して最初に見つかったインデックスを返します。")
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
			:description("渡された述語を満たす要素のインデックスを全てリストにして返します。")
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
			:description("渡された述語を満たす要素を前方から探索して最初に見つかった要素を返します。")
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
			:description("渡された述語を満たす要素を後方から探索して最初に見つかった要素を返します。")
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
			:description("渡された述語を満たす要素を前方から探索して見つかった要素を全てリストにして返します。")
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