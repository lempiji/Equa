namespace "std"
{
	concept "ICallable"
	:description("�֐��Ăяo�����\�ł��邱�Ƃ�\�����܂��B")
	{
		metamethod "__call"
		:description("�֐��Ăяo�����s���܂��B");
	};
	
	concept "ICalculable"
	:description("�l�����Z���\�ł��邱�Ƃ�\�����܂��B")
	{
		metamethod "__add"
		:description("���Z���s���܂��B");
		metamethod "__sub"
		:description("���Z���s���܂��B");
		metamethod "__mul"
		:description("���Z���s���܂��B");
		metamethod "__div"
		:description("���Z���s���܂��B");
	};
	
	concept "IClonable"
	:description("�R�s�[���s���邱�Ƃ�\�����܂��B")
	{
		method "Clone"
		:description("�R�s�[�����ʃC���X�^���X��Ԃ��܂��B");
	};
}
