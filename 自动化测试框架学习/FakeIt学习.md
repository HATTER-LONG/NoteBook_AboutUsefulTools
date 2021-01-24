# FakeIt 使用学习

- [FakeIt 使用学习](#fakeit-使用学习)
  - [前言](#前言)
  - [Include](#include)
  - [Stubbing](#stubbing)
  - [Faking](#faking)
  - [参数匹配 Argument Matching](#参数匹配-argument-matching)
  - [调用匹配 Invocation Matching](#调用匹配-invocation-matching)
  - [验证 Verification](#验证-verification)
  - [验证没有其他调用 Verify No Other Invocations](#验证没有其他调用-verify-no-other-invocations)
  - [验证范围 Verification Scoping](#验证范围-verification-scoping)
  - [监视 Spying](#监视-spying)
  - [将桩重置为初始状态 Reset Mock to Initial State](#将桩重置为初始状态-reset-mock-to-initial-state)
  - [继承与动态转换 Inheritance & Dynamic Casting](#继承与动态转换-inheritance--dynamic-casting)
  - [Mock 重载方法 Mocking Overloaded Methods](#mock-重载方法-mocking-overloaded-methods)

> 本篇基于 FakeIt 版本：SHA-1: 814f28cd509ef2a8cdf7fe370bd9ec6d3b181dc7 / 2020-8-2

## 前言

FakeIt 旨在实现简具有表达性的测试桩函数。其中主要利用了一些 C++11 标准的特性，因此在使用 FakeIt 时确保编译器支持 C++11 标准。

## Include

想要使用 FakeIt 首先添加对应的头文件，以及对应的命名空间：

```cpp
#include <fakeit.hpp>

using namespace fakeit;
```

## Stubbing

假设存在以下需要进行打桩的接口：

```cpp
struct SomeInterface {
   virtual int foo(int) = 0;
   virtual int bar(int,int) = 0;
};
```

使用 FakeIt 打桩：

```cpp
Mock<SomeInterface> mock;
// 只返回一次值，第二次调用会出错
When(Method(mock,foo)).Return(1);

// 设定多次返回的值，第一次返回 1, 第二次返回 2, 第三次返回 3
When(Method(mock,foo)).Return(1,2,3);
When(Method(mock,foo)).Return(1).Return(2).Return(3);//含义同上

// 设定 56 次调用返回 1.
When(Method(mock,foo)).Return(56_Times(1));

// Return many values many times (First 100 calls will return 1, next 200 calls will return 2)
When(Method(mock,foo)).Return(100_Times(1), 200_Times(2));

// 一直返回 1
When(Method(mock,foo)).AlwaysReturn(1);
Method(mock,foo) = 1;//含义同上
```

设定带有参数时特殊返回值的桩函数：

```cpp
// 设置当传入 1 (foo(1)) 时返回 100 注意仅可以调用一次
When(Method(mock,foo).Using(1)).Return(100);
When(Method(mock,foo)(1)).Return(100);

// 设置当传入 1 (foo(1)) 时永远返回 100。其他的调用则一直返回 0
When(Method(mock,foo)).AlwaysReturn(0); // Any invocation of foo will return 0
When(Method(mock,foo).Using(1)).AlwaysReturn(100); // override only for 'foo(1)'

// 这两句的含义时一样的，都是当传入 1 (foo(1)) 时永远返回 0
When(Method(mock,foo).Using(1)).AlwaysReturn(0);
Method(mock,foo).Using(1) = 0;
```

设定带有抛出异常的桩函数：

```cpp
// Throw once
When(Method(mock,foo)).Throw(exception());
// Throw several times
When(Method(mock,foo)).Throw(exception(),exception());
// Throw many times
When(Method(mock,foo)).Throw(23_Times(exception()));
// Always throw
When(Method(mock,foo)).AlwaysThrow(exception());
```

其他技巧：

```cpp
// 使用 lamdba 函数设定想要实现的桩函数具体内容
When(Method(mock,foo)).Do([](int a)->int{ ... });
When(Method(mock,foo)).AlwaysDo([](int a)->int{ ... });
// Or, with C++14:
When(Method(mock,foo)).AlwaysDo([](auto a){ ... });
```

虚析构函数打桩：

```cpp
struct SomeInterface {
   virtual ~SomeInterface() = 0;
};
Mock<SomeInterface> mock;
When(Dtor(mock)).Do([](){ ... });
```

## Faking

大部分情况下打桩函数不会有什么具体操作。可以通过使用 Faking 显式地方法来指定“无为”行为。

```cpp
struct SomeInterface {
   virtual void foo(int) = 0;
   virtual int bar(int,int) = 0;
   virtual ~SomeInterface() = 0;
};
```

```cpp
Mock<SomeInterface> mock;

// Following 3 lines do exactly the same:
Fake(Method(mock,foo));
When(Method(mock,foo)).AlwaysReturn();
When(Method(mock,foo)).AlwaysDo([](...){});

// And here is another example:
Fake(Method(mock,bar));
When(Method(mock,bar)).AlwaysReturn(0);
When(Method(mock,bar)).AlwaysDo([](...){return 0;});
```

也可以一次声明多个桩函数：

`Fake(method1, method2, ...)`

```cpp
Fake(Method(mock,foo), Method(mock,bar));
```

Fake 析构：

```cpp
Fake(Dtor(mock)); // same as When(Dtor(mock)).AlwaysDo([](){});
```

## 参数匹配 Argument Matching

```cpp
// Stub foo to return 1 only when:  arg > 1.
When(Method(mock,foo).Using(Gt(1)).Return(1);

// Stub foo to return 1 only when:  arg >= 1.
When(Method(mock,foo).Using(Ge(1)).Return(1);

// Stub foo to return 1 only when:  arg < 1.
When(Method(mock,foo).Using(Lt(1)).Return(1);

// Stub foo to return 1 only when:  arg <= 1.
When(Method(mock,foo).Using(Le(1)).Return(1);

// Stub foo to return 1 only when:  arg != 1.
When(Method(mock,foo).Using(Ne(1)).Return(1);

// Stub foo to return 1 only when:  arg == 1.
// The following 2 lines do exactly the same
When(Method(mock,foo).Using(Eq(1)).Return(1);
When(Method(mock,foo).Using(1)).Return(1);

// Stub foo to return 1 for any value.
// The following 2 lines do exactly the same
When(Method(mock,foo).Using(Any<int>()).Return(1);
When(Method(mock,foo).Using(_).Return(1);

// Stub foo to return 1 when arg1 == 1 and arg2 is any int.
// The following 3 lines do exactly the same:
When(Method(mock,foo).Using(1, _)).Return(1);
When(Method(mock,foo).Using(1, Any<int>())).Return(1);
When(Method(mock,foo).Using(Eq(1), _)).Return(1);
```

## 调用匹配 Invocation Matching

如何仅匹配参数 “a” 大于参数 “b” 的调用？
在这些情况下，参数匹配不够强大，因为每个参数匹配器仅限于一个参数。这里需要的是调用匹配。

```cpp
// Stub foo to return 1 only when argument 'a' is even.
auto argument_a_is_even = [](int a){return a%2==0;};
When(Method(mock,foo).Matching(argument_a_is_even)).Return(1);

// Throw exception only when argument 'a' is negative.
auto argument_a_is_negative = [](int a){return a < 0;};
When(Method(mock,foo).Matching(argument_a_is_negative)).Throw(exception());

// Stub bar to throw exception only when argument 'a' is bigger than argument 'b'.
auto a_is_bigger_than_b = [](int a, int b){return a > b;};
When(Method(mock,bar).Matching(a_is_bigger_than_b)).Throw(exception());
// Or, with C++14:
When(Method(mock,bar).Matching([](auto a, auto b){return a > b;})).Throw(exception());
```

## 验证 Verification

```cpp
Mock<SomeInterface> mock;
When(Method(mock,foo)).AlwaysReturn(1);

SomeInterface & i = mock.get();

// Production code:
i.foo(1);
i.foo(2);
i.foo(3);
i.bar(2,1);

// 验证 foo 是否至少被调用一次 (The four lines do exactly the same)
Verify(Method(mock,foo));
Verify(Method(mock,foo)).AtLeastOnce();
Verify(Method(mock,foo)).AtLeast(1);
Verify(Method(mock,foo)).AtLeast(1_Time);

// 验证 foo 是否被正确调用了3次。. (The next two lines do exactly the same)
Verify(Method(mock,foo)).Exactly(3);
Verify(Method(mock,foo)).Exactly(3_Times);

// 验证 foo(1) 刚被调用一次
Verify(Method(mock,foo).Using(1)).Once();
Verify(Method(mock,foo).Using(1)).Exactly(Once);

// 验证 bar(a>b) 被调用一次
Verify(Method(mock,bar).Matching([](int a, int b){return a > b;})).Exactly(Once);
// Or, with C++14:
Verify(Method(mock,bar).Matching([](auto a, auto b){return a > b;})).Exactly(Once);
```

验证调用顺序：

```cpp
// 验证 foo(1) 在 foo(3) 之前的任何地方被调用过
Verify(Method(mock,foo).Using(1), Method(mock,foo).Using(3));
```

验证确切的调用顺序：

- 可以通过以下方式表示序列：

- 两次连续的 foo 调用:

```cpp
Method(mock,foo) * 2
```

- 调用 foo 后再调用 bar：

```cpp
Method(mock,foo) + Method(mock,bar)
```

- 连续两次调用 foo + bar，即 foo + bar + foo + bar：

```cpp
(Method(mock,foo) + Method(mock,bar)) * 2
```

- 验证实际调用序列中是否存在特定序列：

```cpp
// 验证实际的调用序列至少包含两次连续的 foo 调用。
Verify(Method(mock,foo) * 2);

// 验证实际调用序列是否包含一次连续两次的 foo 调用。
Verify(Method(mock,foo) * 2).Exactly(Once);

// 验证实际的调用序列包含对 foo（1）的调用，然后对 bar（1,2）进行恰好两次的调用。
Verify(Method(mock,foo).Using(1) + Method(mock,bar).Using(1,2)).Exactly(2_Times);
```

一个序列包含多个 Mock 实例：

```cpp
Mock<SomeInterface> mock1;
Mock<SomeInterface> mock2;

When(Method(mock1,foo)).AlwaysReturn(0);
When(Method(mock2,foo)).AlwaysReturn(0);

SomeInterface & i1 = mock1.get();
SomeInterface & i2 = mock2.get();

// Production code:
i1.foo(1);
i2.foo(1);
i1.foo(2);
i2.foo(2);
i1.foo(3);
i2.foo(3);

// Verify exactly 3 occurrences of the sequence {mock1.foo(any int) + mock2.foo(any int)}.
Verify(Method(mock1,foo) + Method(mock2,foo)).Exactly(3_Times);
```

## 验证没有其他调用 Verify No Other Invocations

```cpp
Mock<SomeInterface> mock;
When(Method(mock,foo)).AlwaysReturn(0);
When(Method(mock,bar)).AlwaysReturn(0);
SomeInterface& i  = mock.get();

// call foo twice and bar once.
i.foo(1);
i.foo(2);
i.bar("some string");

// verify foo(1) was called.
Verify(Method(mock,foo).Using(1));

// Verify no other invocations of any method of mock.
// Will fail since foo(2) & bar("some string") are not verified yet.
VerifyNoOtherInvocations(mock);

// Verify no other invocations of method foo only.
// Will fail since foo(2) is not verified yet.
VerifyNoOtherInvocations(Method(mock,foo));

Verify(Method(mock,foo).Using(2));

// Verify no other invocations of any method of mock.
// Will fail since bar("some string") is not verified yet.
VerifyNoOtherInvocations(mock);

// Verify no other invocations of method foo only.
// Will pass since both foo(1) & foo(2) are now verified.
VerifyNoOtherInvocations(Method(mock,foo));

Verify(Method(mock,bar)); // verify bar was invoked (with any arguments)

// Verify no other invocations of any method of mock.
// Will pass since foo(1) & foo(2) & bar("some string") are now verified.
VerifyNoOtherInvocations(mock);.
```

## 验证范围 Verification Scoping

验证作用域，显式指定用于验证序列的一组实际调用的方法。

假设我们具有以下接口：

```cpp
struct IA {
   virtual void a1(int) = 0;
   virtual void a2(int) = 0;
};
struct IB {
   virtual void b1(int) = 0;
   virtual void b2(int) = 0;
};
```

以及以下两个模拟对象

```cpp
Mock<IA> aMock;
Mock<IB> bMock;
```

生产代码将创建以下实际调用列表：

```cpp
aMock.a1(1);
bMock.b1(1);
aMock.a2(1);
bMock.b2(1);
```

验证：

```cpp
// Will PASS since the scenario {aMock.a1 + bMock.b1} is part of the
// actual list {aMock.a1 + bMock.b1 + aMock.a2 + bMock.b2}
// {aMock.a1 + bMock.b1} 是实际调用列表
// {aMock.a1 + bMock.b1 + aMock.a2 + bMock.b2} 的一部分 因此此项通过
Using(aMock,bMock).Verify(Method(aMock, a1) + Method(bMock, b1));

// Will FAIL since the scenario {aMock.a1 + bMock.b1} is not part of the
// actual list {aMock.a1 + aMock.a2}
// 使用 Using 指定为 aMock 的调用，因此实际调用列表为 {aMock.a1 + aMock.a2}，
// 而  {aMock.a1 + bMock.b1} 不是其中一部分 因此此项失败
Using(aMock).Verify(Method(aMock, a1) + Method(bMock, b1));

// Will PASS since the scenario {aMock.a1 + aMock.a2} is part of the
// actual list {aMock.a1 + aMock.a2}
// 同上
Using(aMock).Verify(Method(aMock, a1) + Method(aMock, a2));
```

默认情况下，FakeIt 使用已验证场景中涉及的所有模拟对象来隐式定义验证范围。 即以下两行的功能完全相同：

```cpp
// 显示调用 aMock 和 bMock 的所有方法调用
Using(aMock,bMock).Verify(Method(aMock, a1) + Method(bMock, b1));

// 隐式使用 aMock 和 Mock 的所有方法调用
Verify(Method(aMock, a1) + Method(bMock, b1));
```

## 监视 Spying

在某些情况下，监视现有对象非常有用。 FakeIt 是唯一支持监视的 C++ 开源模拟框架。

```cpp
class SomeClass {
public:
   virtual int func1(int arg) {
      return arg;
   }
   virtual int func2(int arg) {
      return arg;
   }
};

SomeClass obj;
Mock<SomeClass> spy(obj);

When(Method(spy, func1)).AlwaysReturn(10); // Override to return 10
Spy(Method(spy, func2)); // 监视 func2 而不更改任何行为

SomeClass& i = spy.get();
cout << i.func1(1); // will print 10.
cout << i.func2(1); // func2 没有桩函数
```

通常，所有 Mock 和验证功能都对监视对象起作用，就像对模拟对象起作用一样。

## 将桩重置为初始状态 Reset Mock to Initial State

在大多数情况下，需要在每个测试方法之前/之后将 mock 对象重置为初始状态。为此，只需将每个模拟对象的以下行添加到测试的初始化/清理代码中。

```cpp
mock.Reset();
```

您还可以通过以下方式保留存根并仅清除收集的调用数据：

```cpp
mock.ClearInvocationHistory();
```

## 继承与动态转换 Inheritance & Dynamic Casting

```cpp
struct A {
  virtual int foo() = 0;
};

struct B : public A {
  virtual int foo() override = 0;
};

struct C : public B
{
   virtual int foo() override = 0;
};
```

支持转基类：

```cpp
Mock<C> cMock;
When(Method(cMock, foo)).AlwaysReturn(0);

C& c = cMock.get();
B& b = c;
A& a = b;

cout << c.foo(); // prints 0
cout << b.foo(); // prints 0
cout << a.foo(); // prints 0
```

dynamic_cast 支持：

```cpp
Mock<C> cMock;
When(Method(cMock, foo)).AlwaysReturn(0);

A& a = cMock.get(); // get instance and upcast to A&

B& b = dynamic_cast<B&>(a); // downcast to B&
cout << b.foo(); // prints 0

C& c = dynamic_cast<C&>(a); // downcast to C&
cout << c.foo(); // prints 0
```

## Mock 重载方法 Mocking Overloaded Methods

Mock 重载的方法时，只需要指定方法的原型：

```cpp
struct SomeInterface {
  virtual int func() = 0;
  virtual int func(int) = 0;
  virtual int func(int, std::string) = 0;
};

Mock<SomeInterface> mock;

//stub the func with prototype: int()
When(OverloadedMethod(mock,func, int()) ).Return(1);
//stub the func with prototype: int(int)
When(OverloadedMethod(mock,func, int(int)) ).Return(2);
//stub the func with prototype: int(int,std::string)
When(OverloadedMethod(mock,func, int(int, std::string)) ).Return(3);

SomeInterface& i = mock.get();
cout << i.func();     // will print 1
cout << i.func(1);    // will print 2
cout << i.func(1,""); // will print 3
```

mock const 重载的方法类似：

```cpp
struct SomeInterface {
  virtual int func(int) = 0;
  virtual int func(int) const = 0;
};

Mock<SomeInterface> mock;

//stub the func with prototype: int(int)
When(OverloadedMethod(mock,func, int(int)) ).Return(1);
//stub the const func with prototype: int(int)
When(ConstOverloadedMethod(mock,func, int(int)) ).Return(2);

      SomeInterface& v = mock.get();
const SomeInterface& c = mock.get();

cout << v.func(1);    // will print 1
cout << c.func(1);    // will print 2
```
