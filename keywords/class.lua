
local _getn = table.getn;
local _insert = table.insert;
local _isearch = table.isearch;
local _icontains_if = table.icontains_if;
local _format = string.format;

do
	local class_base = {};
	class_base.description = function(self, desc)
		if (desc == nil or object_type(desc) ~= "string") then
			error(_format("description excepted 'string' (got %s)", object_type(desc)), 2);
		end
		self.__desc = desc;
		return self;
	end;
	class_base.inherits = function(self, super)
		if (super == nil or object_type(super) ~= "class") then
			error(_format("description excepted 'class' (got %s)", object_type(super)), 2);
		end
		self.__super = super;
		return self;
	end;
	class_base.attributes = function(self, ...)
		for i = 1, arg.n do
			if (object_type(arg[i]) ~= "attribute") then
				error(_format("description excepted 'attribute' (got %s)", object_type(arg[i])), 2);
			end
			_insert(self.__attributes, arg[i]);
		end
		return self;
	end
	class_base.implements = function(self, ...)
		for i = 1, arg.n do
			if (object_type(arg[i]) ~= "concept") then
				error(_format("description excepted 'concept' (got %s)", object_type(arg[i])), 2);
			else
				_insert(self.__concepts, arg[i]);
			end
		end
		return self;
	end
	
	local init_events = function(_class, instance)
		for i = 1, _getn(_class.__events) do
			instance[_class.__events[i].__name] = std.Signal:new();
		end
	end;
	
	local normal_allocator = function(_class, ...)
		local self = setmetatable({
			__type = "instance",
			__class = _class
		}, _class.__meta);
		
		_class._init(self, unpack(arg));
		return self;
	end;
	local evented_allocator = function(_class, ...)
		local self = setmetatable({
			__type = "instance",
			__class = _class
		}, _class.__meta);
		
		init_events(_class, self);
		_class._init(self, unpack(arg));
		return self;
	end;
	local abstract_allocator = function()
		error("cannot create instance, this class is 'abstract' class", 2);
	end;
	local static_allocator = function()
		error("cannot create instance, this class is 'static' class", 2);
	end;
	local package_allocator = function()
		error("cannot create instance, this class is 'package' class", 2);
	end;
	
	local class_meta = {};
	class_meta.__index = class_base;
	class_meta.__call = function(self, impl)
		--型によって振り分けておく
		local _objType;
		for _, value in pairs(impl) do
			_objType = object_type(value);
			if (_objType == "method") then
				_insert(self.__methods, value);
			elseif (_objType == "metamethod") then
				_insert(self.__metamethods, value);
			elseif (_objType == "event") then
				_insert(self.__events, value);
			elseif (_objType == "field") then
				_insert(self.__fields, value);
			else
				error(_format("declared type is unknown (got %s)", _objType), 2);--未対応の型
			end
		end
		
		--属性によっては最初に色々エラー
		if (_isearch(self.__super.__attributes, final)) then--finalクラスだったらエラー
			error("this super class is 'final'");
		end
		
		--メソッドを実装
		for _, value in pairs(self.__methods) do
			if (_isearch(value.__attributes, static)) then--staticメソッドの実装
				if (self[value.__name]) then--名前がかぶってる時はエラー
					error(_format("static method's index '%s' is already exists", tostring(value.__name)), 2);
				end
				if (self.__super[value.__name]) then
					if (_isearch(value.__attributes, override)) then
						local _attributes;
						for _, m in pairs(self.__super.__methods) do
							if (m.__name == value.__name
									and _isearch(m.__attributes, static)) then
								_attributes = m.__attributes;
								break;
							end
						end
						if (_attributes and _isearch(_attributes, final)) then--オーバーライド不可能なメソッド
							error(_format("this method(%s) is not overridable, its 'final'", value.__name), 2);
						else
							self[value.__name] = value:getFunction();
						end
					else
						error(_format("must write 'override' keyword on '%s'", value.__name), 2);--オーバーライドの記述が必要
					end
				else
					self[value.__name] = value:getFunction();
				end
			else--メンバメソッドの実装
				if (self.__members[value.__name]) then--名前がかぶってる時はエラー
					error(_format("method's index '%s' is already exists", tostring(value.__name)), 2);
				end
				if (self.__super.__members[value.__name]) then
					if (table.search(value.__attributes, override)) then
						local _attributes;
						for _, m in pairs(self.__super.__methods) do
							if (m.__name == value.__name
									and not(_isearch(m.__attributes, static))) then
								_attributes = m.__attributes;
								break;
							end
						end
						if (_attributes and _isearch(_attributes, final)) then--オーバーライド禁止メソッド
							error(_format("this method(%s) is not overridable, its 'final'", value.__name), 2);
						else
							self.__members[value.__name] = value:getFunction();
						end
					else
						error(_format("must write 'override' keyword on '%s'", value.__name), 2);--オーバーライドの記述が必要
					end
				else
					self.__members[value.__name] = value:getFunction();
				end
			end
		end
		
		--メタメソッドを実装
		for _, value in pairs(self.__metamethods) do
			if (value.__name == "_init") then
				if (_isearch(value.__attributes, static)) then
					self.__sinit = value:getFunction();
				else
					self._init = value:getFunction();
				end
			else
				self.__meta[value.__name] = value:getFunction();
			end
		end
		--基底クラスを辿って、未実装なメタメソッドとイベントを実装
		local _super = self.__super;
		while (_super) do
			for _, value in pairs(_super.__metamethods) do
				if (value.__name == "_init") then
					if (_isearch(value.__attributes, static)) then
						if (self.__sinit == nil) then
							self.__sinit = value:getFunction();
						end
					else
						if (self._init == nil) then
							self._init = value:getFunction();
						end
					end
				else
					if (self.__meta[value.__name] == nil) then
						self.__meta[value.__name] = value:getFunction();
					end
				end
			end
			for _, value in pairs(_super.__events) do
				if (not _icontains_if(self.__events, function(v) return v.__name == value.__name; end)) then
					_insert(self.__events, value);
				end
			end
			_super = _super.__super;
		end
		
		--クラス属性を見てstaticかabstractならアロケータ削除
		--イベントが存在するならイベント実装用アロケータを付与
		--そうでないなら通常のアロケータを付与
		if (_isearch(self.__attributes, static)) then
			self.new = static_allocator;
		elseif (_isearch(self.__attributes, abstract)) then
			self.new = abstract_allocator;
		elseif (_getn(self.__events) > 0) then
			self.new = evented_allocator;
		else
			self.new = normal_allocator;
		end
		
		--メタテーブルを設定して付与
		self.__meta.__index = self.__members;
		setmetatable(self, nil);
		setmetatable(self.__members, {__index = self.__super.__members});
		setmetatable(self, {__index = self.__super});
		
		--クラスのフィールドを初期化
		for _, value in pairs(self.__fields) do
			if (value.__init and _isearch(value.__attributes, static)) then
				if (type(value.__init) == "function") then--フィールドに関数は無し。static methodを使う。
					self[value.__name] = value.__init(self);
				else
					self[value.__name] = value.__init;
				end
			end
		end
		
		--静的コンストラクタを呼ぶ
		if (self.__sinit) then
			self:__sinit();
		end
		
		--パッケージクラスなら改めてアロケータを削除
		if (_isearch(self.__attributes, package)) then
			self.new = package_allocator;
		end
		
		--一通り終わってコンセプトチェック
		for _, value in pairs(self.__concepts) do
			local b, result = value:implemented(self);
			if (not b) then
				error(_format("concept check is failed by '%s' (%s)", value.__name, tostring(result[1])), 2);
			end
		end
		return self;
	end;
	
	class = function(name)
		local _class = {
			__type = "class",
			__name = name,
			__desc = "",
			__super = Object,
			__concepts = {},
			__attributes = {},
			__concepts = {},
			__fields = {},
			__methods = {},
			__metamethods = {},
			__members = {},
			__events = {},
			__meta = {}
		};
		return setmetatable(_class, class_meta);
	end
end
