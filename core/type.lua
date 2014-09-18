
namespace "core"
{
	class "TypeInfo"
	:description("�^�����������߂̃N���X�ł��B")
	{
		metamethod "_init"
		:description("�^��`���󂯎��C�j�V�����C�U�ł��B")
		:body(function(self, def)
			self._def = def;
		end);
		
		method "GetTypeName"
		:description("�^�̎�ނ��擾���܂��B")
		:body(function(self)
			return self._def.__type;
		end);
		
		method "GetName"
		:description("�^�̖��O���擾���܂��B")
		:body(function(self)
			return self._def.__name;
		end);
		
		method "GetDescription"
		:description("�^�̐������擾���܂��B")
		:body(function(self)
			return self._def.__desc;
		end);
		
		metamethod "__eq"
		:description("�^�̓��l�����m�F���܂��B")
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
	:description("�N���X�̒�`�����������߂̃N���X�ł��B")
	{
		metamethod "_init"
		:description("�N���X��`���󂯎��C�j�V�����C�U�ł��B")
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
		:description("�N���X��`��񂩂�t�B�[���h��`�̈ꗗ���擾���܂��B")
		:body(function(self)
			return self._def.__fields;
		end);
		
		method "GetMethods"
		:description("�N���X��`��񂩂烁�\�b�h��`�̈ꗗ���擾���܂��B")
		:body(function(self)
			return self._def.__methods;
		end);
		
		method "GetMetamethods"
		:description("�N���X��`��񂩂烁�^���\�b�h��`�̈ꗗ���擾���܂��B")
		:body(function(self)
			return self._def.__metamethods;
		end);
		
		method "GetConcepts"
		:description("�N���X��`��񂩂�������̃R���Z�v�g��`�ꗗ���擾���܂��B")
		:body(function(self)
			return self._def.__concepts;
		end);
		
		method "GetSuperClass"
		:description("���N���X�̒�`���擾���܂��B")
		:body(function(self)
			return self._def.__super;
		end);
		
		method "GetAttributes"
		:description("�N���X�̑������擾���܂��B")
		:body(function(self)
			return self._def.__attributes;
		end);
		
		method "IsFinalClass"
		:description("�N���X��`���p���ł��Ȃ����ǂ����擾���܂��B")
		:body(function(self)
			for _, attr in pairs(self._def.__attributes) do
				if (attr == final) then
					return true;
				end
			end
			return false;
		end);
		
		method "IsAbstractClass"
		:description("�N���X��`�����ۃN���X���ǂ����擾���܂��B")
		:body(function(self)
			for _, attr in pairs(self._def.__attributes) do
				if (attr == abstract) then
					return true;
				end
			end
			return false;
		end);
		
		method "IsStaticClass"
		:description("�N���X��`���ÓI�N���X���ǂ����擾���܂��B")
		:body(function(self)
			for _, attr in pairs(self._def.__attributes) do
				if (attr == static) then
					return true;
				end
			end
			return false;
		end);
		
		method "Is"
		:description("�N���X����������h�����Ă��邩�m�F���܂��B")
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
		:description("�N���X���R���Z�v�g�𖞂����Ă��邩�m�F���܂��B")
		:body(function(self, concept)
			return concept:implemented(self._def);
		end);
		
		method "CreateInstance"
		:description("�N���X��`����C���X�^���X�𐶐����܂��B")
		:body(function(self, ...)
			return self._def:new(unpack(arg));
		end);
	};

	class "TypeInfo_Method"
	:description("���\�b�h�̒�`�����������߂̃N���X�ł��B")
	:inherits(TypeInfo)
	{
		metamethod "_init"
		:description("���\�b�h��`���󂯎��C�j�V�����C�U�ł��B")
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
		:description("�ÓI�N���X���\�b�h�ł��邩�𔻒f���܂��B")
		:body(function(self)
			return table.isearch(self._def, static) ~= nil;
		end);
		
		method "IsMemberMethod"
		:description("�����o���\�b�h�ł��邩�𔻒f���܂��B")
		:body(function(self)
			return table.isearch(self._def, static) == nil;
		end);
	};

	class "TypeInfo_Metamethod"
	:description("���^���\�b�h�̒�`�����������߂̃N���X�ł��B")
	:inherits(TypeInfo)
	{
		metamethod "_init"
		:description("���^���\�b�h��`���󂯎��C�j�V�����C�U�ł��B")
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
		:description("�C�j�V�����C�U�ł��邩�𔻒f���܂��B")
		:body(function(self)
			return self._def.__name == "_init";
		end);
	};

	class "TypeInfo_Field"
	:description("�t�B�[���h�̒�`�����������߂̃N���X�ł��B")
	:inherits(TypeInfo)
	{
		metamethod "_init"
		:description("�t�B�[���h��`���󂯎��C�j�V�����C�U�ł��B")
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
		:description("�ÓI�t�B�[���h���ۂ����擾���܂��B")
		:body(function(self)
			return table.isearch(self._def.__attributes, static) ~= nil;
		end);
		
		method "GetValue"
		:description("�񋓑̗v�f�̒l���擾���܂��B")
		:body(function(self)
			return self._def.__init;
		end);
	};

	class "TypeInfo_Attribute"
	:description("�����̒�`�����������߂̃N���X�ł��B")
	:inherits(TypeInfo)
	{
		metamethod "_init"
		:description("�������󂯎��C�j�V�����C�U�ł��B")
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
	:description("�C�x���g�̒�`�����������߂̃N���X�ł��B")
	:inherits(TypeInfo)
	{
		metamethod "_init"
		:description("�C�x���g���󂯎��C�j�V�����C�U�ł��B")
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
		:description("�^�[�Q�b�g�ƃC�x���g���X�i�[���w�肵�Đڑ��������s���܂��B")
		:body(function(self, target, obj)
			target[self:GetName()]:Connect(obj);
		end);
		
		method "Disconnect"
		:description("�^�[�Q�b�g�ƃC�x���g���X�i�[���w�肵�Đؒf�������s���܂��B")
		:body(function(self, target, obj)
			target[self:GetName()]:Disconnect(obj);
		end);
	};

	class "TypeInfo_Namespace"
	:description("���O��Ԃ̒�`�����������߂̃N���X�ł��B")
	:inherits(TypeInfo)
	{
		metamethod "_init"
		:description("���O��Ԃ��󂯎��C�j�V�����C�U�ł��B")
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
		:description("�����ɐ錾����Ă���N���X�̈ꗗ���擾���܂��B")
		:body(function(self)
			return self._def.__classes;
		end);
		method "GetConcepts"
		:description("�����ɐ錾����Ă���R���Z�v�g�̈ꗗ���擾���܂��B")
		:body(function(self)
			return self._def.__concepts;
		end);
		method "GetEnums"
		:description("�����ɐ錾����Ă���񋓑̂̈ꗗ���擾���܂��B")
		:body(function(self)
			return self._def.__enums;
		end);
		
		method "GetInnerNamespaces"
		:description("�����ɐ錾����Ă��閼�O��Ԃ̈ꗗ���擾���܂��B")
		:body(function(self)
			return self._def.__namespaces;
		end);
	};
	
	class "TypeInfo_Enum"
	:description("�񋓑̂̒�`�����������߂̃N���X�ł��B")
	:inherits(TypeInfo)
	{
		metamethod "_init"
		:description("�񋓑̂��󂯎��C�j�V�����C�U�ł��B")
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
		:description("�񋓑̗v�f�̈ꗗ���擾���܂��B")
		:body(function(self)
			return self._def.__elements;
		end);
		
		method "ForElements"
		:description("�񋓑̗v�f�����񂷂邽�߂̃��\�b�h�ł��B")
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
	:description("�񋓑̗v�f�̒�`�����������߂̃N���X�ł��B")
	{
		metamethod "_init"
		:description("�񋓑̗v�f���󂯎��C�j�V�����C�U�ł��B")
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
		:description("�񋓑̗v�f�̒l���擾���܂��B")
		:body(function(self)
			return self._def.__value;
		end);
	};
	
	class "TypeInfo_Concept"
	:inherits(TypeInfo)
	:description("�R���Z�v�g�̒�`�����������߂̃N���X�ł��B")
	{
		metamethod "_init"
		:description("�R���Z�v�g���󂯎��C�j�V�����C�U�ł��B")
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
		:description("�R���Z�v�g���������������郁�\�b�h�̈ꗗ���擾���܂��B")
		:body(function(self)
			return self._def.__methods;
		end);
		
		method "GetMetamethods"
		:description("�R���Z�v�g���������������郁�^���\�b�h�̈ꗗ���擾���܂��B")
		:body(function(self)
			return self._def.__metamethods;
		end);
		
		method "GetFields"
		:description("�R���Z�v�g����������������t�B�[���h�̈ꗗ���擾���܂��B")
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