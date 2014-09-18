namespace "std"
{
	namespace "collection"
	{
		concept "IEnumerable"
		{
			method "Pairs"
			:description("for-in�\���ɂėp����A�L�[�ƒl��񋓂��邽�߂̃��\�b�h�ł�");
			
			method "Keys"
			:description("for-in�\���ŗp����A�L�[��񋓂��邽�߂̃��\�b�h�ł��B");
			method "Values"
			:description("for-in�\���ŗp����A�l��񋓂��邽�߂̃��\�b�h�ł��B");
		}
	}
}

namespace "std"
{
	namespace "query"
	{
		concept "IQueryable"
		{
			method "Values"
			:description("for-in�\���ŗp����A�l��񋓂��邽�߂̃��\�b�h�ł��B");
		}
	}
}
namespace "std"
{
	namespace "combiner"
	{
		concept "ICombiner"
		{
			method "Compute"
			:description("IQueryable�̗v�f�𓝍����ĒP��̒l��Ԃ����߂̃��\�b�h�ł��B");
		}
	}
}