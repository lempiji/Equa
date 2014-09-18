namespace "std"
{
	namespace "collection"
	{
		concept "IEnumerable"
		{
			method "Pairs"
			:description("for-in構文にて用いる、キーと値を列挙するためのメソッドです");
			
			method "Keys"
			:description("for-in構文で用いる、キーを列挙するためのメソッドです。");
			method "Values"
			:description("for-in構文で用いる、値を列挙するためのメソッドです。");
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
			:description("for-in構文で用いる、値を列挙するためのメソッドです。");
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
			:description("IQueryableの要素を統合して単一の値を返すためのメソッドです。");
		}
	}
}