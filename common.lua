
EQUA_MAJOR_VERSION = 1;
EQUA_MINOR_VERSION = 1;

function object_type(_obj)
	local t = type(_obj);
	if (t == "table" and _obj.__type) then
		return _obj.__type;
	end
	return t;
end
function object_name(_obj)
	local t = type(_obj);
	if (t == "table" and _obj.__name) then
		return _obj.__name;
	end
	return t;
end

function is_class(_obj)
	return object_type(_obj) == "class";
end
function is_instance(_obj)
	return object_type(_obj) == "instance";
end
function is_concept(_obj)
	return object_type(_obj) == "concept";
end
function is_namespace(_obj)
	return object_type(_obj) == "namespace";
end
function is_enum(_obj)
	return object_type(_obj) == "enum";
end
function is_element(_obj)
	return object_type(_obj) == "element";
end
function is_method(_obj)
	return object_type(_obj) == "method";
end
function is_metamethod(_obj)
	return object_type(_obj) == "metamethod";
end
function is_field(_obj)
	return object_type(_obj) == "field";
end
function is_event(_obj)
	return object_type(_obj) == "event";
end

function typeof(_instance)
	return _instance.__class;
end
function super(_instance)
	return _instance.__class.__super.__members;
end
