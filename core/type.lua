
namespace "core"
{
	class "TypeInfo"
	:description("型情報を扱うためのクラスです。")
	{
		metamethod "_init"
		:description("型定義を受け取るイニシャライザです。")
		:body(function(self, def)
			self._def = def;
		end);
		
		method "GetTypeName"
		:description("型の種類を取得します。")
		:body(function(self)
			return self._def.__type;
		end);
		
		method "GetName"
		:description("型の名前を取得します。")
		:body(function(self)
			return self._def.__name;
		end);
		
		method "GetDescription"
		:description("型の説明を取得します。")
		:body(function(self)
			return self._def.__desc;
		end);
		
		metamethod "__eq"
		:description("型の同値性を確認します。")
		:body(function(self, other)
			return self._def == other._def;
		end);
	}
}
local TypeInfo = core.TypeInfo;

namespace "core"
{
	class "TypeInfo_Class"
	:inherits(TypeInfo)
	:description("クラスの定義情報を扱うためのクラスです。")
	{
		metamethod "_init"
		:description("クラス定義を受け取るイニシャライザです。")
		:precondition(function(self, def_class)
			if (object_type(def_class) ~= "class") then
				error(string.format(
					"bad argument#1 on TypeInfo_Class._init (class excepted, got %s)",
					object_type(_def)), 2);
			end
		end)
		:body(function(self, def_class)
			TypeInfo._init(self, def_class);
		end);
		
		method "GetFields"
		:description("クラス定義情報からフィールド定義の一覧を取得します。")
		:body(function(self)
			return self._def.__fields;
		end);
		
		method "GetMethods"
		:description("クラス定義情報からメソッド定義の一覧を取得します。")
		:body(function(self)
			return self._def.__methods;
		end);
		
		method "GetMetamethods"
		:description("クラス定義情報からメタメソッド定義の一覧を取得します。")
		:body(function(self)
			return self._def.__metamethods;
		end);
		
		method "GetConcepts"
		:description("クラス定義情報から実装時のコンセプト定義一覧を取得します。")
		:body(function(self)
			return self._def.__concepts;
		end);
		
		method "GetSuperClass"
		:description("基底クラスの定義を取得します。")
		:body(function(self)
			return self._def.__super;
		end);
		
		method "GetAttributes"
		:description("クラスの属性を取得します。")
		:body(function(self)
			return self._def.__attributes;
		end);
		
		method "IsFinalClass"
		:description("クラス定義が継承できないかどうか取得します。")
		:body(function(self)
			for _, attr in pairs(self._def.__attributes) do
				if (attr == final) then
					return true;
				end
			end
			return false;
		end);
		
		method "IsAbstractClass"
		:description("クラス定義が抽象クラスかどうか取得します。")
		:body(function(self)
			for _, attr in pairs(self._def.__attributes) do
				if (attr == abstract) then
					return true;
				end
			end
			return false;
		end);
		
		method "IsStaticClass"
		:description("クラス定義が静的クラスかどうか取得します。")
		:body(function(self)
			for _, attr in pairs(self._def.__attributes) do
				if (attr == static) then
					return true;
				end
			end
			return false;
		end);
		
		method "Is"
		:description("クラスが引数から派生しているか確認します。")
		:precondition(function(self, super)
			if (object_type(def_class) ~= "class") then
				error(string.format(
					"bad argument#1 on TypeInfo_Class:Is (class excepted, got %s)",
					object_type(_def)), 2);
			end
		end)
		:body(function(self, super)
			if (self._def == super) then
				return true;
			end
			local _super = self._def.__super;
			while (_super) do
				if (_super == super) then
					return true;
				end
				_super = _super.__super;
			end
			return false;
		end);
		method "As"
		:description("クラスがコンセプトを満たしているか確認します。")
		:body(function(self, concept)
			return concept:implemented(self._def);
		end);
		
		method "CreateInstance"
		:description("クラス定義からインスタンスを生成します。")
		:body(function(self, ...)
			return self._def:new(unpack(arg));
		end);
	};

	class "TypeInfo_Method"
	:description("メソッドの定義情報を扱うためのクラスです。")
	:inherits(TypeInfo)
	{
		metamethod "_init"
		:description("メソッド定義を受け取るイニシャライザです。")
		:precondition(function(self, _def)
			if (object_type(_def) ~= "method") then
				error(string.format(
					"bad argument#1 on TypeInfo_Method._init (method excepted, got %s)",
					object_type(_def)), 2);
			end
		end)
		:body(function(self, _def)
			TypeInfo._init(self, _def);
		end);
		
		method "IsStaticMethod"
		:description("静的クラスメソッドであるかを判断します。")
		:body(function(self)
			return table.isearch(self._def, static) ~= nil;
		end);
		
		method "IsMemberMethod"
		:description("メンバメソッドであるかを判断します。")
		:body(function(self)
			return table.isearch(self._def, static) == nil;
		end);
	};

	class "TypeInfo_Metamethod"
	:description("メタメソッドの定義情報を扱うためのクラスです。")
	:inherits(TypeInfo)
	{
		metamethod "_init"
		:description("メタメソッド定義を受け取るイニシャライザです。")
		:precondition(function(self, _def)
			if (object_type(_def) ~= "metamethod") then
				error(string.format(
					"bad argument#1 on TypeInfo_Metamethod._init (metamethod excepted, got %s)",
					object_type(_def)), 2);
			end
		end)
		:body(function(self, _def)
			TypeInfo._init(self, _def);
		end);
		
		method "IsInitializer"
		:description("イニシャライザであるかを判断します。")
		:body(function(self)
			return self._def.__name == "_init";
		end);
	};

	class "TypeInfo_Field"
	:description("フィールドの定義情報を扱うためのクラスです。")
	:inherits(TypeInfo)
	{
		metamethod "_init"
		:description("フィールド定義を受け取るイニシャライザです。")
		:precondition(function(self, _def)
			if (object_type(_def) ~= "field") then
				error(string.format(
					"bad argument#1 on TypeInfo_Field._init (field excepted, got %s)",
					object_type(_def)), 2);
			end
		end)
		:body(function(self, _def)
			TypeInfo._init(self, _def);
		end);
		
		method "IsStaticField"
		:description("静的フィールドか否かを取得します。")
		:body(function(self)
			return table.isearch(self._def.__attributes, static) ~= nil;
		end);
		
		method "GetValue"
		:description("列挙体要素の値を取得します。")
		:body(function(self)
			return self._def.__init;
		end);
	};

	class "TypeInfo_Attribute"
	:description("属性の定義情報を扱うためのクラスです。")
	:inherits(TypeInfo)
	{
		metamethod "_init"
		:description("属性を受け取るイニシャライザです。")
		:precondition(function(self, _def)
			if (object_type(_def) ~= "attribute") then
				error(string.format(
					"bad argument#1 on TypeInfo_Attribute._init (attribute excepted, got %s)",
					object_type(_def)), 2);
			end
		end)
		:body(function(self, _def)
			TypeInfo._init(self, _def);
		end);
	};

	class "TypeInfo_Event"
	:description("イベントの定義情報を扱うためのクラスです。")
	:inherits(TypeInfo)
	{
		metamethod "_init"
		:description("イベントを受け取るイニシャライザです。")
		:precondition(function(self, _def)
			if (object_type(_def) ~= "event") then
				error(string.format(
					"bad argument#1 on TypeInfo_Event._init (event excepted, got %s)",
					object_type(_def)), 2);
			end
		end)
		:body(function(self, _def)
			TypeInfo._init(self, _def);
		end);
		
		method "Connect"
		:description("ターゲットとイベントリスナーを指定して接続処理を行います。")
		:body(function(self, target, obj)
			target[self:GetName()]:Connect(obj);
		end);
		
		method "Disconnect"
		:description("ターゲットとイベントリスナーを指定して切断処理を行います。")
		:body(function(self, target, obj)
			target[self:GetName()]:Disconnect(obj);
		end);
	};

	class "TypeInfo_Namespace"
	:description("名前空間の定義情報を扱うためのクラスです。")
	:inherits(TypeInfo)
	{
		metamethod "_init"
		:description("名前空間を受け取るイニシャライザです。")
		:precondition(function(self, _def)
			if (object_type(_def) ~= "namespace") then
				error(string.format(
					"bad argument#1 on TypeInfo_Namespace._init (namespace excepted, got %s)",
					object_type(_def)), 2);
			end
		end)
		:body(function(self, _def)
			TypeInfo._init(self, _def);
		end);
		
		method "GetClasses"
		:description("内部に宣言されているクラスの一覧を取得します。")
		:body(function(self)
			return self._def.__classes;
		end);
		method "GetConcepts"
		:description("内部に宣言されているコンセプトの一覧を取得します。")
		:body(function(self)
			return self._def.__concepts;
		end);
		method "GetEnums"
		:description("内部に宣言されている列挙体の一覧を取得します。")
		:body(function(self)
			return self._def.__enums;
		end);
		
		method "GetInnerNamespaces"
		:description("内部に宣言されている名前区間の一覧を取得します。")
		:body(function(self)
			return self._def.__namespaces;
		end);
	};
	
	class "TypeInfo_Enum"
	:description("列挙体の定義情報を扱うためのクラスです。")
	:inherits(TypeInfo)
	{
		metamethod "_init"
		:description("列挙体を受け取るイニシャライザです。")
		:precondition(function(self, _def)
			if (object_type(_def) ~= "enum") then
				error(string.format(
					"bad argument#1 on TypeInfo_Enum._init (element excepted, got %s)",
					object_type(_def)), 2);
			end
		end)
		:body(function(self, _def)
			TypeInfo._init(self, _def);
		end);
		
		method "GetElements"
		:description("列挙体要素の一覧を取得します。")
		:body(function(self)
			return self._def.__elements;
		end);
		
		method "ForElements"
		:description("列挙体要素を巡回するためのメソッドです。")
		:body(function(self)
			return coroutine.wrap(function()
				for _, element in pairs(self._def.__elements) do
					coroutine.yield(element.__name, element.__value);
				end
			end);
		end);
	};
	
	class "TypeInfo_Element"
	:inherits(TypeInfo)
	:description("列挙体要素の定義情報を扱うためのクラスです。")
	{
		metamethod "_init"
		:description("列挙体要素を受け取るイニシャライザです。")
		:precondition(function(self, _def)
			if (object_type(_def) ~= "enum") then
				error(string.format(
					"bad argument#1 on TypeInfo_Element._init (element excepted, got %s)",
					object_type(_def)), 2);
			end
		end)
		:body(function(self, _def)
			TypeInfo._init(self, _def);
		end);
		
		method "GetValue"
		:description("列挙体要素の値を取得します。")
		:body(function(self)
			return self._def.__value;
		end);
	};
	
	class "TypeInfo_Concept"
	:inherits(TypeInfo)
	:description("コンセプトの定義情報を扱うためのクラスです。")
	{
		metamethod "_init"
		:description("コンセプトを受け取るイニシャライザです。")
		:precondition(function(self, _def)
			if (is_concept(_def)) then
				error(string.format(
					"bad argument#1 on TypeInfo_Element._init (element excepted, got %s)",
					object_type(_def)), 2);
			end
		end)
		:body(function(self, _def)
			TypeInfo._init(self, _def);
		end);
		
		method "GetMethods"
		:description("コンセプトが実装を強制するメソッドの一覧を取得します。")
		:body(function(self)
			return self._def.__methods;
		end);
		
		method "GetMetamethods"
		:description("コンセプトが実装を強制するメタメソッドの一覧を取得します。")
		:body(function(self)
			return self._def.__metamethods;
		end);
		
		method "GetFields"
		:description("コンセプトが実装を強制するフィールドの一覧を取得します。")
		:body(function(self)
			return self._def.__fields;
		end);
	}
}
local ClassInfo = core.TypeInfo_Class;
local MethodInfo = core.TypeInfo_Method;
local FieldInfo = core.TypeInfo_Field;
local MetamethodInfo = core.TypeInfo_Metamethod;
local AttributeInfo = core.TypeInfo_Attribute;
local NamespaceInfo = core.TypeInfo_Namespace;
local EnumInfo = core.TypeInfo_Enum;
local ElementInfo = core.TypeInfo_Element;
local ConceptInfo = core.TypeInfo_Concept;
local EventInfo = core.TypeInfo_Event;

function type_info(t)
	local _type = object_type(t);
	if (_type == "class") then
		return ClassInfo:new(t);
	elseif (_type == "instance") then
		return ClassInfo:new(t.__class);
	elseif (_type == "method") then
		return MethodInfo:new(t);
	elseif (_type == "event") then
		return ElementInfo:new(t);
	elseif (_type == "enum") then
		return EnumInfo:new(t);
	elseif (_type == "namespace") then
		return NamespaceInfo:new(t);
	elseif (_type == "concept") then
		return ConceptInfo:new(t);
	elseif (_type == "field") then
		return FieldInfo:new(t);
	elseif (_type == "metamethod") then
		return MetamethodInfo:new(t);
	elseif (_type == "attribute") then
		return AttributeInfo:new(t);
	elseif (_type == "element") then
		return ElementInfo:new(t);
	else
		return nil;
	end
end