
local List = std.collection.List;
local Queue = std.Queue;

local INotifier;
local IObserver;
local IConnection;
local AnonymouseNotifier;
local AnonymouseObserver;
local AnonymouseConnection;
local CompositeConnection;
local Subject;
local FlexibleNotifier;

namespace "std"
{
	concept "INotifier"
	{
		method "Subscribe"
		:body(function(self, observer)
			--return IConnection:new();
		end);
		
		method "ToFlexible"
		:description("Linq形式のメソッドチェーンを使えるようにFlexibleNotifierでラップします。")
		:body(function(self)
			return FlexibleNotifier:new(self);
		end);
	};
	
	concept "IObserver"
	{
		method "OnNext"
		:body(function(self, obj)
		end);
		method "OnError"
		:body(function(self, error)
		end);
		method "OnCompleted"
		:body(function(self)
		end);
		
		metamethod "__call"
		:body(function(self, obj)
			self:OnNext(obj);
		end);
	};
	
	concept "IConnection"
	{
		method "IsAlive"
		:body(function(self)
		end);
		
		method "Disconnect"
		:body(function(self)
		end);
	};
}
INotifier = std.INotifier;
IObserver = std.IObserver;
IConnection = std.IConnection;

namespace "std"
{
	class "AnonymouseNotifier"
	:implements(INotifier)
	{
		metamethod "_init"
		:body(function(self, subscribe)
			self._subscribe = subscribe;
		end);
		
		method "Subscribe"
		:body(function(self, observer)
			if (self._subscribe) then
				return self._subscribe(observer);
			end
			return nil;
		end);
		
		method "ToFlexible"
		:body(function(self)
			return FlexibleNotifier:new(self);
		end);
	};
	
	class "AnonymouseObserver"
	:implements(IObserver)
	{
		metamethod "_init"
		:body(function(self, onNext, onCompleted, onError)
			self._onNext = onNext;
			self._onCompleted = onCompleted;
			self._onError = onError;
			self._stopped = false;
		end);
		metamethod "__call"
		:body(function(self, obj)
			self:OnNext(obj);
		end);
		
		method "OnNext"
		:body(function(self, obj)
			if (self._stopped) then
				return;
			end
			
			if (self._onNext) then
				self._onNext(obj);
			end
		end);
		
		method "OnCompleted"
		:body(function(self)
			if (self._stopped) then
				return;
			end
			
			self:Stop();
			if (self._onCompleted) then
				self._onCompleted();
			end
		end);
		
		method "OnError"
		:body(function(self, err)
			if (self._stopped) then
				return;
			end
			
			if (self._onError) then
				self._onError(err);
			end
		end);
		
		method "Stop"
		:body(function(self)
			self._stopped = true;
		end);
	};
	
	class "AnonymouseConnection"
	:implements(IConnection)
	{
		metamethod "_init"
		:body(function(self, disconnect)
			self._isAlive = disconnect ~= nil;
			self._disconnect = disconnect;
		end);
		
		method "IsAlive"
		:body(function(self)
			return self._isAlive;
		end);
		
		method "Disconnect"
		:body(function(self)
			if (not self:IsAlive()) then
				return;
			end
			
			self._isAlive = false;
			if (self._disconnect) then
				self._disconnect();
				self._disconnect = false;
			end
		end);
		
		method "SetDisconnect"
		:body(function(self, disconnect)
			self._disconnect = disconnect;
			if (disconnect) then
				self._isAlive = true;
			end
		end);
	};
	
	class "CompositeConnection"
	:implements(IConnection)
	{
		metamethod "_init"
		:body(function(self)
			self._isAlive = true;
			self._connections = List:new();
		end);
		
		method "IsAlive"
		:body(function(self)
			return self._isAlive;
		end);
		
		method "Disconnect"
		:body(function(self)
			if (not self:IsAlive()) then
				return;
			end
			
			self._isAlive = false;
			local list = self._connections:Clone();
			self._connections:Clear();
			
			if (not list:IsEmpty()) then
				for obj in list:Values() do
					obj:Disconnect();
				end
			end
		end);
		
		method "Length"
		:body(function(self)
			return self._connections:Length();
		end);
		
		method "Add"
		:body(function(self, connection)
			if (not self:IsAlive()) then
				connection:Disconnect();
			else
				self._connections:Add(connection);
			end
		end);
		method "Remove"
		:body(function(self, connection)
			return self._connections:RemoveFirst(connection);
		end);
		
		method "Values"
		:body(function(self)
			return self._connections:Values();
		end);
	};
	
	class "Subject"
	:implements(INotifier, IObserver)
	{
		metamethod "_init"
		:body(function(self)
			self._stop = false;
			self._observers = List:new();
		end);
		
		method "Subscribe"
		:body(function(self, observer)
			if (self._stop) then
				return nil;
			end
			
			self._observers:Add(observer);
			return AnonymouseConnection:new(function()
				self._observers:RemoveFirst(observer);
			end);
		end);
		
		method "OnNext"
		:body(function(self, obj)
			if (self._stop) then
				return;
			end
			
			local buffer = self._observers:Clone();
			for observer in buffer:Values() do
				observer:OnNext(obj);
			end
		end);
		method "OnCompleted"
		:body(function(self)
			if (self._stop) then
				return;
			end
			
			local buffer = self._observers:Clone();
			self:Stop();
			for observer in buffer:Values() do
				observer:OnCompleted();
			end
		end);
		method "OnError"
		:body(function(self, err)
			if (self._stop) then
				return;
			end
			
			local buffer = self._observers:Clone();
			for observer in buffer:Values() do
				observer:OnError();
			end
		end);
		
		method "Stop"
		:body(function(self)
			self._stop = true;
		end);
		
		method "ToFlexible"
		:body(function(self)
			return FlexibleNotifier:new(self);
		end);
		
		metamethod "__call"
		:body(function(self, obj)
			self:OnNext(obj);
		end);
	}
}
AnonymouseNotifier = std.AnonymouseNotifier;
AnonymouseObserver = std.AnonymouseObserver;
AnonymouseConnection = std.AnonymouseConnection;
CompositeConnection = std.CompositeConnection;

namespace "std"
{
	class "FlexibleNotifier"
	:implements(INotifier)
	{
		metamethod "_init"
		:body(function(self, source)
			self._source = source;
		end);
		
		method "Subscribe"
		:body(function(self, observer)
			if (self._source) then
				return self._source:Subscribe(observer);
			end
			return nil;
		end);
		
		method "ToFlexible"
		:body(function(self)
			return self;
		end);
		
		method "Do"
		:body(function(self, action)
			return AnonymouseNotifier:new(function(observer)
				return self._source:Subscribe(AnonymouseObserver:new(
					function(obj)
						action(obj);
						observer:OnNext(obj);
					end,
					function()
						observer:OnCompleted();
					end,
					function(e)
						observer:OnError(e);
					end)
				);
			end):ToFlexible();
		end);
		
		method "DistinctUntilChanged"
		:body(function(self, comp)
			return AnonymouseNotifier:new(function(observer)
				local current;
				local initialized = false;
				return self._source:Subscribe(AnonymouseObserver:new(
					function(obj)
						if (initialized) then
							if (comp) then
								if (not comp(current, obj)) then
									observer:OnNext(obj);
									current = obj;
								end
							elseif (current ~= obj) then
								observer:OnNext(obj);
								current = obj;
							end
						else
							initialized = true;
							observer:OnNext(obj);
							current = obj;
						end
					end,
					function()
						observer:OnCompleted();
					end,
					function(e)
						observer:OnError(e);
					end)
				);
			end):ToFlexible();
		end);
		
		method "Select"
		:body(function(self, selector)
			return AnonymouseNotifier:new(function(observer)
				return self._source:Subscribe(AnonymouseObserver:new(
					function(obj)
						observer:OnNext(selector(obj));
					end,
					function()
						observer:OnCompleted();
					end,
					function(e)
						observer:OnError(e);
					end)
				);
			end):ToFlexible();
		end);
		
		method "SelectMany"
		:body(function(self, selector)
			return AnonymouseNotifier:new(function(observer)
				return self._source:Subscribe(AnonymouseObserver:new(
					function(obj)
						for value in selector(obj):Values() do
							observer:OnNext(value);
						end
					end,
					function()
						observer:OnCompleted();
					end,
					function(e)
						observer:OnError(e);
					end)
				);
			end):ToFlexible();
		end);
		
		method "Where"
		:body(function(self, pred)
			return AnonymouseNotifier:new(function(observer)
				return self._source:Subscribe(AnonymouseObserver:new(
					function(obj)
						if (pred(obj)) then
							observer:OnNext(obj);
						end
					end,
					function()
						observer:OnCompleted();
					end,
					function(err)
						observer:OnError(err);
					end)
				);
			end):ToFlexible();
		end);
		
		method "Skip"
		:body(function(self, n)
			return AnonymouseNotifier:new(function(observer)
				local count = n;
				return self._source:Subscribe(AnonymouseObserver:new(
					function(obj)
						if (count <= 0) then
							observer:OnNext(obj);
						else
							count = count - 1;
						end
					end,
					function()
						observer:OnCompleted();
					end,
					function(err)
						observer:OnError(err);
					end)
				);
			end):ToFlexible();
		end);
		method "SkipWhile"
		:description("与えられた述語条件を満たす間通知されないNotifierを作成します。")
		:body(function(self, pred)
			return AnonymouseNotifier:new(function(observer)
				local opened = false;
				return self._source:Subscribe(AnonymouseObserver:new(
					function(obj)
						if (not opened) then
							opened = pred(obj);
						end
						if (opened) then
							observer:OnNext(obj);
						end
					end,
					function()
						observer:OnCompleted();
					end,
					function(err)
						observer:OnError(err);
					end)
				);
			end):ToFlexible();
		end);
		method "SkipUntil"
		:description("他のNotifierから通知を受け取るまで通知をスキップするNotifierを合成します")
		:body(function(self, other)
			return AnonymouseNotifier:new(function(observer)
				local opened = false;
				local group = CompositeConnection:new();
				local connection1 = other:Subscribe(AnonymouseObserver:new(
					function(obj)
						opened = true;
						connection1:Disconnect();
					end,
					function()
						observer:OnCompleted();
						opened = true;
					end,
					function(err)
						observer:OnError(err);
					end
				));
				group:Add(connection1);
				local connection2 = self._source:Subscribe(AnonymouseObserver:new(
					function(obj)
						if (opened) then
							observer:OnNext(obj);
						end
					end,
					function()
						observer:OnCompleted();
						group:Disconnect();
					end,
					function(err)
						observer:OnError(err);
					end)
				);
				group:Add(connection2);
				return group;
			end):ToFlexible();
		end);
		
		method "Take"
		:body(function(self, n)
			return AnonymouseNotifier:new(function(observer)
				local count = n;
				return self._source:Subscribe(AnonymouseObserver:new(
					function(obj)
						if (count > 0) then
							count = count - 1;
							observer:OnNext(obj);
							if (count == 0) then
								observer:OnCompleted();
							end
						end
					end,
					function()
						observer:OnCompleted();
					end,
					function(err)
						observer:OnError(err);
					end)
				);
			end):ToFlexible();
		end);
		method "TakeWhile"
		:description("与えられた述語条件を満たさなくなると通知が停止するNotifierを作成します。")
		:body(function(self, pred)
			return AnonymouseNotifier:new(function(observer)
				local opened = false;
				return self._source:Subscribe(AnonymouseObserver:new(
					function(obj)
						if (not opened) then
							opened = not pred(obj);
						end
						if (opened) then
							observer:OnNext(obj);
						else
							observer:OnCompleted();
						end
					end,
					function()
						observer:OnCompleted();
					end,
					function(err)
						observer:OnError(err);
					end)
				);
			end):ToFlexible();
		end);
		method "TakeUntil"
		:description("他のNotifierから通知を受け取ると通知を停止するNotifierを合成します")
		:body(function(self, other)
			return AnonymouseNotifier:new(function(observer)
				local group = CompositeConnection:new();
				local finished = false;
				
				group:Add(other:Subscribe(AnonymouseObserver:new(
					function(obj)
						if (not finished) then
							observer:OnCompleted();
							finished = true;
						end
						group:Disconnect();
					end,
					function()
						group:Disconnect();
					end,
					function(err)
						observer:OnError(err);
					end
				)));
				
				group:Add(self._source:Subscribe(AnonymouseObserver:new(
					function(obj)
						observer:OnNext(obj);
					end,
					function()
						if (not finished) then
							observer:OnCompleted();
							finished = true;
						end
						group:Disconnect();
					end,
					function(err)
						observer:OnError(err);
					end)));
				return group;
			end):ToFlexible();
		end);
		
		method "RedirectTo"
		:description("通知によって他のNotifierを追加購読するようになるNotifierを合成します")
		:body(function(self, selector)
			return AnonymouseNotifier:new(function(observer)
				local stopped = false;
				local group = CompositeConnection:new();
				local outerConnection = AnonymouseConnection:new();
				group:Add(outerConnection);
				
				outerConnection:SetDisconnect(self._source:Subscribe(AnonymouseObserver:new(
					function(innerObj)
						local innerSource = selector(innerObj);
						local innerConnection = AnonymouseConnection:new();
						local connection = innerSource:Subscribe(AnonymouseObserver:new(
							function(obj)
								observer:OnNext(obj);
							end,
							function()
								group:Remove(innerConnection);
								if (stopped and (group:Length() == 1)) then
									observer:OnCompleted();
								end
							end,
							function(err)
								observer:OnError(err);
							end
						));
						innerConnection:SetDisconnect(connection);
					end,
					function()
						stopped = true;
						if (group:Length() == 1) then
							observer:OnCompleted();
						end
					end,
					function(err)
						observer:OnError(err);
					end
				)));
				return group;
			end):ToFlexible();
		end);
		
		method "Zip"
		:description("2つのNotifierの要素を相互に関連付けた新たなNotifierを合成します")
		:body(function(self, other, selector)
			return AnonymouseNotifier:new(function(observer)
				local leftQueue = Queue:new();
				local leftFinished = false;
				local rightQueue = Queue:new();
				local rightFinished = false;
				
				local group = CompositeConnection:new();
				
				group:Add(self._source:Subscribe(AnonymouseObserver:new(
					function(obj)
						leftQueue:Push(obj);
						while (not leftQueue:IsEmpty() and not rightQueue:IsEmpty()) do
							observer:OnNext(selector(leftQueue:Pop(), rightQueue:Pop()));
						end
					end,
					function()
						if (not leftFinished and rightFinished) then
							observer:OnCompleted();
						end
						leftFinished = true;
					end,
					function(err)
						observer:OnError(err);
					end
				)));
				group:Add(other:Subscribe(AnonymouseObserver:new(
					function(obj)
						rightQueue:Push(obj);
						while (not leftQueue:IsEmpty() and not rightQueue:IsEmpty()) do
							observer:OnNext(selector(leftQueue:Pop(), rightQueue:Pop()));
						end
					end,
					function()
						if (leftFinished and not rightFinished) then
							observer:OnCompleted();
						end
						rightFinished = true;
					end,
					function(err)
						observer:OnError(err);
					end
				)));
				
				return group;
			end):ToFlexible();
		end);
		
		method "Aggregate"
		:body(function(self, accumlator, init)
			return AnonymouseNotifier:new(
				function(observer)
					init = init or 0;
					return self._source:Subscribe(
						AnonymouseObserver:new(
							function(obj)
								init = accumlator(init, obj);
							end,
							function()
								observer:OnNext(init);
								observer:OnCompleted();
							end,
							function(err)
								observer:OnError(err);
							end
						)
					);
				end
			);
		end);
		
		method "Min"
		:body(function(self, selector, init)
			return self._sourceToFlexible()
				:Aggregate(function(old, now)
					if (selector) then
						if (selector(old) > selector(now)) then
							return now;
						else
							return old;
						end
					else
						if (old > now) then
							return now;
						else
							return old;
						end
					end
				end,
				init
			);
		end);
		method "Max"
		:body(function(self, selector, init)
			return self._sourceToFlexible()
				:Aggregate(function(old, now)
					if (selector) then
						if (selector(old) < selector(now)) then
							return now;
						else
							return old;
						end
					else
						if (old < now) then
							return now;
						else
							return old;
						end
					end
				end,
				init
			);
		end);
	};
}
FlexibleNotifier = std.FlexibleNotifier;

namespace "std"
{
	class "NotifierFactory"
	:attributes(static)
	{
		method "FromSignal"
		:attributes(static)
		:body(function(signal, selector)
			return AnonymouseNotifier:new(
				function(observer)
					local slot = observer;
					if (selector) then
						slot = function(...)
							observer:OnNext(selector(unpack(arg)));
						end;
					end
					signal:Connect(slot);
					return AnonymouseConnection:new(
						function()
							signal:Disconnect(slot);
						end
					);
				end
			):ToFlexible();
		end);
	};
}
