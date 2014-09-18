namespace "std"
{
	concept "ICallable"
	:description("関数呼び出しが可能であることを表明します。")
	{
		metamethod "__call"
		:description("関数呼び出しを行います。");
	};
	
	concept "ICalculable"
	:description("四則演算が可能であることを表明します。")
	{
		metamethod "__add"
		:description("加算を行います。");
		metamethod "__sub"
		:description("加算を行います。");
		metamethod "__mul"
		:description("加算を行います。");
		metamethod "__div"
		:description("加算を行います。");
	};
	
	concept "IClonable"
	:description("コピーが行えることを表明します。")
	{
		method "Clone"
		:description("コピーした別インスタンスを返します。");
	};
}
