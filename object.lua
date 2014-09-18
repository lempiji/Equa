Object = {};
--共通属性
Object.__type = "class";
Object.__name = "Object";
Object.__desc = "全てのクラスはこのクラスから派生します。";

--クラス属性
Object.__super = nil;
Object.__concepts = {};
Object.__attributes = {};
Object.__fields = {};
Object.__methods = {};
Object.__metamethods = {};
Object.__members = {};
Object.__events = {};
Object.__meta = {};

--イニシャライザ(コンストラクタ)
Object._init = function(self) end;


Object.__methods[0] = method "ToString"
	:description("インスタンスを人が読み取れる文字列へ変換します。")
	:body(function(self)
		return self.__class.__name;
	end);

Object.__metamethods[0] = metamethod "_init"
	:description("イニシャライザです。")
	:body(Object._init);
Object.__metamethods[1] = metamethod "__tostring"
	:description("tostringに対応するメタメソッドです。")
	:body(function(self)
		return self:ToString();
	end);

Object.__members.ToString = Object.__methods[0].__body;

Object.__meta.__index = Object.__members;
Object.__meta.__tostring = Object.__metamethods[1].__body;

Object.new = function(_class, ...)
	local self = setmetatable({
		__type = "instance",
		__class = _class
	}, _class.__meta);
	
	if (_class.__super) then
		self._super = _class.__super.__members;
	end
	_class._init(self, unpack(arg));
	return self;
end
