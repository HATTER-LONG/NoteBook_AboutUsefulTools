# Catch2 自动测试框架学习

- [Catch2 自动测试框架学习](#catch2-自动测试框架学习)
  - [断言宏 Assertion Macros](#断言宏-assertion-macros)
    - [浮点比较 Floating point comparisons](#浮点比较-floating-point-comparisons)
    - [异常 Exceptions](#异常-exceptions)
    - [匹配器断言宏 Matcher expressions](#匹配器断言宏-matcher-expressions)
    - [线程安全 Thread Safety](#线程安全-thread-safety)
    - [逗号分隔表达式 Expressions with commas](#逗号分隔表达式-expressions-with-commas)
  - [Matchers](#matchers)
    - [内置匹配器 Built in matchers](#内置匹配器-built-in-matchers)
    - [字符串匹配器 String matchers](#字符串匹配器-string-matchers)
    - [容器匹配器 vector matchers](#容器匹配器-vector-matchers)
    - [浮点匹配器 Floating point matchers](#浮点匹配器-floating-point-matchers)
    - [通用匹配器 Generic matchers](#通用匹配器-generic-matchers)
    - [异常匹配器 Exception matchers](#异常匹配器-exception-matchers)
    - [自定义匹配器 Custom matchers](#自定义匹配器-custom-matchers)
  - [记录宏 Logging macros](#记录宏-logging-macros)
    - [全局记录 Logging without local scope](#全局记录-logging-without-local-scope)
    - [流控宏 Streaming macros](#流控宏-streaming-macros)
    - [快速捕获变量或表达式的值 Quickly capture value of variables or expressions](#快速捕获变量或表达式的值-quickly-capture-value-of-variables-or-expressions)
  - [测试用例与节 Test cases and sections](#测试用例与节-test-cases-and-sections)
    - [标签 Tags](#标签-tags)
    - [特殊标签 Special Tags](#特殊标签-special-tags)
    - [标签别名 Tag aliases](#标签别名-tag-aliases)
    - [BDD 风格的测试用例 BDD-style test cases](#bdd-风格的测试用例-bdd-style-test-cases)
    - [类型参数化的测试用例 Type parametrised test cases](#类型参数化的测试用例-type-parametrised-test-cases)
    - [基于签名的参数化测试用例 Signature based parametrised test cases](#基于签名的参数化测试用例-signature-based-parametrised-test-cases)
  - [测试固件 Test fixtures](#测试固件-test-fixtures)
    - [定义测试固件 Defining test fixtures](#定义测试固件-defining-test-fixtures)
    - [基于特征的参数化测试固件 Signature-based parametrised test fixtures](#基于特征的参数化测试固件-signature-based-parametrised-test-fixtures)
    - [在模板类型列表中指定类型的模板固件 Template fixtures with types specified in template type lists](#在模板类型列表中指定类型的模板固件-template-fixtures-with-types-specified-in-template-type-lists)
  - [报告器 Reporters](#报告器-reporters)
    - [使用不同的报告器 Using different reporters](#使用不同的报告器-using-different-reporters)
  - [事件监听器 Event Listeners](#事件监听器-event-listeners)
    - [实现时间监听器 Implementing a Listener](#实现时间监听器-implementing-a-listener)
    - [钩子事件 Events that can be hooked](#钩子事件-events-that-can-be-hooked)
  - [测试数据生成器 Data Generators](#测试数据生成器-data-generators)
    - [GENERATE 和 SECTION 组合使用 Combining GENERATE and SECTION](#generate-和-section-组合使用-combining-generate-and-section)
    - [默认提供的生成器 Provided generators](#默认提供的生成器-provided-generators)
    - [生成器接口 Generator interface](#生成器接口-generator-interface)
  - [其他宏 Other macros](#其他宏-other-macros)
    - [断言相关的宏 Assertion related macros](#断言相关的宏-assertion-related-macros)
    - [测试用例相关的宏 Test case related macros](#测试用例相关的宏-test-case-related-macros)
  - [编写基准测试 Authoring benchmarks](#编写基准测试-authoring-benchmarks)
    - [执行程序 Execution procedure](#执行程序-execution-procedure)
    - [基准规范 Benchmark specification](#基准规范-benchmark-specification)
    - [高级基准测试 Advanced benchmarking](#高级基准测试-advanced-benchmarking)
    - [基准的构造函数和析构函数 Constructors and destructors](#基准的构造函数和析构函数-constructors-and-destructors)
    - [优化器 The optimizer](#优化器-the-optimizer)

> 本篇基于 Catch2 版本：2.13.0 / 2020-7-19

## 断言宏 Assertion Macros

Catch 的断言宏主要分两种，REQUIRE 族当失败时停止测试与 CHECK 族失败后继续执行。

1. REQUIRE( *expression* )
2. CHECK( *expression* )

```cpp
CHECK( str == "string value" );
CHECK( thisReturnsTrue() );
REQUIRE( i == 42 );
```

另外提供两个逻辑非的断言宏

1. REQUIRE_FALSE( *expression* )
2. CHECK_FALSE( *expression* )

```cpp
REQUIRE_FALSE( thisReturnsFalse() );
```

注意 Catch 并不支持复杂的逻辑判断，如：

```cpp
CHECK(a == 1 && b == 2);
```

### 浮点比较 Floating point comparisons

比较浮点需要指定精度，Catch 提供了一种称为 Approx 的包装器类来执行浮点值比较的方法。同时提供了一个简写方式 `_a` ，注意它在 Catch::literals 命名空间下。

```cpp
REQUIRE( performComputation() == Approx( 2.1 ) );

using namespace Catch::literals;
REQUIRE( performComputation() == 2.1_a );
```

`Approx` 的默认情况可以适配大多数情况，Catch 也提供了以下三种自定义方法:

- __epsilon__ - epsilon serves to set the coefficient by which a result
can differ from `Approx`'s value before it is rejected.
_By default set to `std::numeric_limits<float>::epsilon()*100`._
- __margin__ - margin serves to set the the absolute value by which
a result can differ from `Approx`'s value before it is rejected.
_By default set to `0.0`._
- __scale__ - scale is used to change the magnitude of `Approx` for relative check.
_By default set to `0.0`._

```cpp
Approx target = Approx(100).epsilon(0.01);
100.0 == target; // Obviously true
200.0 == target; // Obviously still false
100.5 == target; // True, because we set target to allow up to 1% difference

Approx target = Approx(100).margin(5);
100.0 == target; // Obviously true
200.0 == target; // Obviously still false
104.0 == target; // True, because we set target to allow absolute difference of at most 5
```

### 异常 Exceptions

期待无异常抛出的断言宏：

1. EQUIRE_NOTHROW( expression )
2. CHECK_NOTHROW( expression )

期待有异常抛出的断言宏：

1. REQUIRE_THROWS( expression )
2. CHECK_THROWS( expression )

期待有特定异常抛出的断言宏：

1. REQUIRE_THROWS_AS( expression, exception type )
2. CHECK_THROWS_AS( expression, exception type )

期待抛出一个转化为字符串后于提供字符串或字符匹配器匹配的异常 (匹配器在下边会有介绍)：

1. REQUIRE_THROWS_WITH( expression, string or string matcher )
2. CHECK_THROWS_WITH( expression, string or string matcher )

```cpp
REQUIRE_THROWS_WITH( openThePodBayDoors(), Contains( "afraid" ) && Contains( "can't do that" ) );
REQUIRE_THROWS_WITH( dismantleHal(), "My mind is going" );
```

期待抛出一个于匹配器匹配的异常：

1. REQUIRE_THROWS_MATCHES( expression, exception type, matcher for given exception type )
2. CHECK_THROWS_MATCHES( expression, exception type, matcher for given exception type )

> 请注意，THROW 断言系列期望传递单个表达式，而不是一个语句或一系列语句。 如果要检查更复杂的操作序列，可以使用 C++ 11 lambda函数。

```cpp
REQUIRE_NOTHROW([&](){
    int i = 1;
    int j = 2;
    auto k = i + j;
    if (k == 3) {
        throw 1;
    }
}());
```

### 匹配器断言宏 Matcher expressions

匹配器会在下边介绍到[官方文档](https://github.com/catchorg/Catch2/blob/master/docs/matchers.md#top)，这里主要描述匹配器断言宏：

1. REQUIRE_THAT( lhs, matcher expression )
2. CHECK_THAT( lhs, matcher expression )

匹配器可以使用 &&、|| 和 ！逻辑操作。

### 线程安全 Thread Safety

当前 Catch 的断言是不支持线程安全的，详情请参考[官方文档](https://github.com/catchorg/Catch2/blob/master/docs/limitations.md#thread-safe-assertions)

### 逗号分隔表达式 Expressions with commas

由于预处理于编译不同的规则，造成断言宏在逗号分隔上会有问题，例如

```cpp
REQUIRE_THROWS_AS(std::pair<int, int>(1, 2), std::invalid_argument);
```

会编译失败，因为预处理器看到提供了3个参数，但宏只接受2个参数。

使用 typedef 解决：

```c++
using int_pair = std::pair<int, int>;
REQUIRE_THROWS_AS(int_pair(1, 2), std::invalid_argument);
```

括号表达式(不通用，它可能需要在Catch方面进行额外更改才能正常工作):

```c++
TEST_CASE_METHOD((Fixture<int, int>), "foo", "[bar]") {
    SUCCEED();
}
```

## Matchers

Matchers 是一种易于组合的断言形式，便于复杂的自定义类型配合使用。

Matchers 主要与 REQUIRE_THAT 或 CHECK_THAT 断言宏配合使用，并且匹配器之间还可以通过逻辑与或非组合。

```cpp
using Catch::Matchers::EndsWith; // or Catch::EndsWith
std::string str = getStringFromSomewhere();
REQUIRE_THAT( str, EndsWith( "as a service" ) );

REQUIRE_THAT( str,
    EndsWith( "as a service" ) ||
    (StartsWith( "Big data" ) && !Contains( "web scale" ) ) );  // 组合
```

同时 Matchers 还支持多个参数，进而更加精准的断言，例如使用内置的字符串匹配器接受第二个参数标志位，指定是否区分大小写：

```cpp
REQUIRE_THAT( str, EndsWith( "as a service", Catch::CaseSensitive::No ) );
```

注意，组合操作不会获取 Matchers 的所有权，也就是使用者必须要确保其声明周期：

```cpp
TEST_CASE("Bugs, bugs, bugs", "[Bug]"){
    std::string str = "Bugs as a service";

    auto match_expression = Catch::EndsWith( "as a service" ) ||
        (Catch::StartsWith( "Big data" ) && !Catch::Contains( "web scale" ) );
    REQUIRE_THAT(str, match_expression);
}
```

### 内置匹配器 Built in matchers

Catch2 默认提供了一些 Matchers，它们都在 Catch::Matchers::foo 命名空间下，同样也可以导入到 Catch 命名空间。

内置的匹配器分为两种，一种是匹配器类型本身以及创建模板匹配器时提供模板参数推导的帮助器函数。例如，用于检查 std::vector 的两个实例是否相同的匹配器是 `EqualsMatcher<T>`，但是希望用户改用 Equals 帮助器函数。

### 字符串匹配器 String matchers

字符串匹配器包括 `StartsWith`, `EndsWith`, `Contains`, `Equals`, `Matches`。前四个都是将指定字符串与结果进行特定规则匹配，而 Matches 则通过 ECMAScript 正则表达式匹配整个字符串。每个提供的 std::string 匹配器还带有一个可选的第二个参数，该参数决定是否区分大小写（默认情况下，它们区分大小写）。

### 容器匹配器 vector matchers

Catch2 提供 5 个内置的匹配器针对 std::vector:

1. `Contains` 检查结果中是否存在指定变量。
2. `VectorContains` 检查结果中是否存在指定的元素。
3. `Equals` 它检查结果是否与特定向量完全相等（注意元素顺序）。
4. `UnorderedEquals` 检查结果是否等于排列下的特定向量。
5. `Approx` 它检查结果是否与特定向量“近似相等”（顺序很重要，但比较是通过“近似”完成的）。

### 浮点匹配器 Floating point matchers

Catch2 提供 3 个内置的浮点匹配器

1. `WithinAbsMatcher` 接受目标一定距离内的浮点数。它使用 `WithinAbs(double target, double margin)` 枸橘函数构造。
2. `WithinUlpsMatcher` 接受在目标的 ULP 一定范围内的浮点数。 因为对于浮点数和双精度数，ULP 比较需要以不同的方式进行，所以此匹配器的工具函数有两个重载，`WithinULP(float target, int64_t ULPs)`、`WithinULP(double target, int64_t ULPs)`。
3. `WithinRelMatcher` 接受浮点数，该浮点数与目标数近似相等，并且具有特定的公差。 换句话说，它检查 `|lhs - rhs| <= epsilon * max(|lhs|, |rhs|)`。四个工具构造函数 `WithinRel(double target, double margin)`, `WithinRel(float target, float margin)`, `WithinRel(double target)`, `WithinRel(float target)`。

### 通用匹配器 Generic matchers

Catch 可以提供一些通用的匹配器:

```cpp
REQUIRE_THAT("Hello olleH",
             Predicate<std::string>(
                 [] (std::string const& str) -> bool { return str.front() == str.back(); },
                 "First and last character should be equal") //第二个参数是谓词的可选描述，仅在报告结果时使用。
);
```

### 异常匹配器 Exception matchers

Catch2 还提供了一个异常匹配器，可用于验证异常消息是否与所需字符串完全匹配。匹配器是 ExceptionMessageMatcher，我们还提供了一个辅助函数 Message。匹配的异常必须显示从 std::exception 派生，并且消息的匹配是完全正确的，包括大小写。

```cpp
REQUIRE_THROWS_MATCHES(throwsDerivedException(),  DerivedException,  Message("DerivedException::what"));
```

### 自定义匹配器 Custom matchers

1. 首先从 `Catch::MatcherBase<T>` 派生出一个 Matcher 类，其中 T 是要测试的类型。构造函数接受并存储所需的任何参数（例如要与之进行比较的参数），然后重写两个方法：match() 和 describe()。
2. 一个简单的构建器功能。 这是从测试代码实际调用的内容，并允许重载。

```cpp
// The matcher class
class IntRange : public Catch::MatcherBase<int> {
    int m_begin, m_end;
public:
    IntRange( int begin, int end ) : m_begin( begin ), m_end( end ) {}

    // Performs the test for this matcher
    bool match( int const& i ) const override {
        return i >= m_begin && i <= m_end;
    }

    // Produces a string describing what this matcher does. It should
    // include any provided data (the begin/ end in this case) and
    // be written as if it were stating a fact (in the output it will be
    // preceded by the value under test).
    virtual std::string describe() const override {
        std::ostringstream ss;
        ss << "is between " << m_begin << " and " << m_end;
        return ss.str();
    }
};

// The builder function
inline IntRange IsBetween( int begin, int end ) {
    return IntRange( begin, end );
}

// ...

// Usage
TEST_CASE("Integers are within a range")
{
    CHECK_THAT( 3, IsBetween( 1, 10 ) );
    CHECK_THAT( 100, IsBetween( 1, 10 ) );
}
```

## 记录宏 Logging macros

在测试期间可以记录并输出详细的数据信息，使用 INFO 可以实现记录打印的效果，但是要注意打印的相关变量有效作用域，并且如果在 INFO 记录之前就出现错误则不会上报。

```cPP
TEST_CASE("Foo") {
    INFO("Test case start");
    for (int i = 0; i < 2; ++i) {
        INFO("The number is " << i);
        CHECK(i == 0);
    }
}
//当 FOO 测试失败时，会输出当前记录的打印：
//Test case start
//The number is 1
TEST_CASE("Bar") {
    INFO("Test case start");
    for (int i = 0; i < 2; ++i) {
        INFO("The number is " << i);
        CHECK(i == i);
    }
    CHECK(false);
}
//当 Bar 测试失败时，只会输出打印：
//Test case start
//超过作用域的不会在上报
```

### 全局记录 Logging without local scope

- `UNSCOPED_INFO` 与 `INFO` 有两点不同：
  1. 不受声明周期的限制。
  2. 信息上报则只受下问最近的一个断言宏控制输出。

```cpp
void print_some_info() {
    UNSCOPED_INFO("Info from helper");
}

TEST_CASE("Baz") {
    print_some_info();
    for (int i = 0; i < 2; ++i) {
        UNSCOPED_INFO("The number is " << i);
    }
    CHECK(false);
}
// Baz 失败后输出打印：
// Info from helper
// The number is 0
// The number is 1

TEST_CASE("Qux") {
    INFO("First info");
    UNSCOPED_INFO("First unscoped info");
    CHECK(false);

    INFO("Second info");
    UNSCOPED_INFO("Second unscoped info");
    CHECK(false);
}
//当第一个 CHECK 失败后：
//First info
//First unscoped info
//到达第二个 CHECK 失败后：
//First info
//Second info
//Second unscoped info
```

### 流控宏 Streaming macros

所有的日志记录宏都可以向 c++ 的标准输入输出一样使用 << 进行数据流控制。

```cpp
INFO( "The number is " << i );
```

1. INFO ( message expression )：消息会被记录在缓冲区，直到断言失败后一起上报，缓冲的信息收到生命周期限制。
2. UNSCOPED_INFO( message expression )：与 INFO 类似，但是记录的数据不受生命周期限制，具体细节见前文。
3. WARN( message expression )：WARN 的信息总是上报，但是不会终止测试。
4. FAIL( message expression )：FAIL 的信息总是上报，并且测试用例失败终止。
5. FAIL_CHECK( message expression )：与 FAIL 类似，但是不会终止用例。

### 快速捕获变量或表达式的值 Quickly capture value of variables or expressions

CAPTURE( expression1, expression2, ... )：有时，只需要记录变量或表达式的值。使用 CAPTURE 宏，该宏可以接受变量或表达式，并在捕获时打印出该变量/表达式及其值。

```cpp
int a = 1, b = 2, c = 3;
CAPTURE( a, b, c, a + b, c > b, a == 1);
/*
a := 1
b := 2
c := 3
a + b := 3
c > b := true
a == 1 := true
*/
```

还可以捕获在括号（例如函数调用），方括号或花括号（例如初始值设定项）中使用逗号的表达式。 要正确捕获包含模板参数列表的表达式（换句话说，它包含尖括号之间的逗号），需要将该表达式括在括号内：`CAPTURE( (std::pair<int, int>{1, 2}) );`

## 测试用例与节 Test cases and sections

Catch2 提供了用于单元测试的宏，同时还提供了一种特殊的测试方式`节`：

- TEST_CASE( test name [, tags ] )
- SECTION( section name )

test name 与 section name 字符串格式并且要唯一，tags 同样时字符串格式它标识一个或多个用方括号标记的标签。

### 标签 Tags

标签允许任意数量的附加字符串与测试用例相关联。可以通过标签-甚至是组合了多个标签的表达式来选择（用于运行或仅用于列出）测试用例。 在最基本的层次上，它们提供了一种将几个相关测试组合在一起的简单方法。

```cpp
TEST_CASE( "A", "[widget]" ) { /* ... */ }
TEST_CASE( "B", "[widget]" ) { /* ... */ }
TEST_CASE( "C", "[gadget]" ) { /* ... */ }
TEST_CASE( "D", "[widget][gadget]" ) { /* ... */ }
```

使用 `"[widget]"` 标签选中 A、B、D，`"[gadget]"` 标签选中 C、D，`"[widget][gadget]"` 标签仅选中 D。标记名称不区分大小写，并且支持任何 ASCII 字符串，包括空格 `[tag with spaces]` 和 `[I said "good day"]`，都是可以被过滤的。

### 特殊标签 Special Tags

Catch2 保留所有以非字母数字字符开头的标签名称用于定义了许多“特殊”标签，这些标签对测试运行器本身具有意义，均以符号字符开头。 以下是当前定义的特殊标签及其含义的列表。

1. [!hide] or [.]：跳过当前测试用例。一般 hide 标签会与其他标签共同使用，类似于 `[.][integration]` ，这样默认是不会运行当前测试用例，但是可以通过命令行指定 integration 标签来运行。`[.][integration]` 还可以缩写成 `[.integration]`。
2. [!throws]：让 Catch 知道，即使测试成功此用例也可能引发异常。使用 -e 或 --nothrow 运行时，这将导致测试被排除。
3. [!mayfail]：如果任何给定的断言失败（但仍会报告），则不会使测试失败。这对于标记正在进行的工作或不想立即解决但仍希望在测试中进行跟踪的已知问题很有用。
4. [!shouldfail]：类似于 `[!mayfail]`，但如果通过则无法通过测试。如果您希望收到有关意外或第三方修复程序的通知，这将很有用。
5. [!nonportable]：表示行为在平台或编译器之间可能有所不同。
6. `[#<filename>]`：使用 -＃ 或 --filenames-as-tags 运行 Catch2 会向所有包含的测试中添加以 ＃ 开头的文件名（并去除所有扩展名）作为标签，例如 testfile.cpp 中的测试将全部标记为[#testfile]。
7. `[@<alias>]`：标签别名以 @ 开头。
8. [!benchmark]：这个测试案例实际上是一个基准。 这是一项实验性功能，目前尚无文档。 如果您想尝试一下，请查看projects / SelfTest / Benchmark.tests.cpp了解详细信息。

### 标签别名 Tag aliases

在标签表达式和通配测试名称（以及两者的组合）之间，可以构建非常复杂的模式来指示要运行哪些测试用例。 如果经常使用复杂模式，则能够为表达式创建别名很方便。 可以使用以下形式通过代码完成此操作：

```cpp
CATCH_REGISTER_TAG_ALIAS( <alias string>, <tag expression> )
```

别名必须以@字符开头。 标签别名的示例是：

```cpp
CATCH_REGISTER_TAG_ALIAS( "[@nhf]", "[failing]~[.]" )
```

当在命令行上使用 [@nhf] 时，它将匹配所有标记为 [failing] 的测试，但这些测试没有被隐藏。

### BDD 风格的测试用例 BDD-style test cases

行为驱动开发模式的编写测试用例：

- SCENARIO( scenario name [, tags ] )：与 TEST_CASE 类似，只不过重新命名了，应该与 BDD 配套使用。

- GIVEN( something )
- WHEN( something )
- THEN( something )：这三个宏都是映射到 SECTION 上的。

- AND_GIVEN( something )
- AND_WHEN( something )
- AND_THEN( something )：与 上边三个宏类似，只不过命名特殊带有 AND。

```cpp
SCENARIO( "vectors can be sized and resized", "[vector]" ) {

    GIVEN( "A vector with some items" ) {
        std::vector<int> v( 5 );

        REQUIRE( v.size() == 5 );
        REQUIRE( v.capacity() >= 5 );

        WHEN( "the size is increased" ) {
            v.resize( 10 );

            THEN( "the size and capacity change" ) {
                REQUIRE( v.size() == 10 );
                REQUIRE( v.capacity() >= 10 );
            }
        }
        WHEN( "the size is reduced" ) {
            v.resize( 0 );

            THEN( "the size changes but not capacity" ) {
                REQUIRE( v.size() == 0 );
                REQUIRE( v.capacity() >= 5 );
            }
        }
        WHEN( "more capacity is reserved" ) {
            v.reserve( 10 );

            THEN( "the capacity changes but not the size" ) {
                REQUIRE( v.size() == 5 );
                REQUIRE( v.capacity() >= 10 );
            }
        }
        WHEN( "less capacity is reserved" ) {
            v.reserve( 0 );

            THEN( "neither size nor capacity are changed" ) {
                REQUIRE( v.size() == 5 );
                REQUIRE( v.capacity() >= 5 );
            }
        }
    }
}
```

### 类型参数化的测试用例 Type parametrised test cases

除了TEST_CASE，Catch2 还支持按类型参数化的测试用例，形式为 TEMPLATE_TEST_CASE，TEMPLATE_PRODUCT_TEST_CASE 和 TEMPLATE_LIST_TEST_CASE。

- TEMPLATE_TEST_CASE( test name , tags, type1, type2, ..., typen )

测试名称和标签与 TEST_CASE 中的名称和标签完全相同，不同之处在于必须提供标签字符串（但是可以为空）。 从 type1 到 typen 是该测试用例应运行的类型的列表，并且在测试代码中，当前类型可用作 TestType 类型。

> 由于 C++ 预处理程序的限制，如果要指定具有多个模板参数的类型，则需要将其括在括号中 `std::map<int, std::string>` needs to be passed as `(std::map<int, std::string>)`。

```cpp
TEMPLATE_TEST_CASE( "vectors can be sized and resized", "[vector][template]", int, std::string, (std::tuple<int,float>) ) {

    std::vector<TestType> v( 5 );// 使用

    REQUIRE( v.size() == 5 );
    REQUIRE( v.capacity() >= 5 );

    SECTION( "resizing bigger changes size and capacity" ) {
        v.resize( 10 );

        REQUIRE( v.size() == 10 );
        REQUIRE( v.capacity() >= 10 );
    }
    SECTION( "resizing smaller changes size but not capacity" ) {
        v.resize( 0 );

        REQUIRE( v.size() == 0 );
        REQUIRE( v.capacity() >= 5 );

        SECTION( "We can use the 'swap trick' to reset the capacity" ) {
            std::vector<TestType> empty;
            empty.swap( v );

            REQUIRE( v.capacity() == 0 );
        }
    }
    SECTION( "reserving smaller does not change size or capacity" ) {
        v.reserve( 0 );

        REQUIRE( v.size() == 5 );
        REQUIRE( v.capacity() >= 5 );
    }
}
```

- TEMPLATE_PRODUCT_TEST_CASE( test name , tags, (template-type1, template-type2, ..., template-typen), (template-arg1, template-arg2, ..., template-argm) )

template-type1 到 template-typen 是模板模板类型的列表，应该与 template-arg1 到 template-argm 中的每一个结合使用，从而产生 n * m 个测试用例。在测试用例中，使用 TestType 表示不同的类型。

要将一种以上类型指定为单个 template-type 或 template-arg，您必须将这些类型括在另外的括号中，例如 `((int, float), (char, double))`指定2个模板参数，每个模板参数由2种具体类型（分别为int，float 和 char，double）组成。 如果仅指定一种类型作为模板类型或 template-args 的完整集合，则也可以省略括号的外部集合。

```cpp
template< typename T>
struct Foo {
    size_t size() {
        return 0;
    }
};

TEMPLATE_PRODUCT_TEST_CASE("A Template product test case", "[template][product]", (std::vector, Foo), (int, float)) {
    TestType x;
    REQUIRE(x.size() == 0);
}
```

```cpp
TEMPLATE_PRODUCT_TEST_CASE("Product with differing arities", "[template][product]", std::tuple, (int, (int, double), (int, double, float))) {
    TestType x;
    REQUIRE(std::tuple_size<TestType>::value >= 1);
}
```

虽然在单个 TEMPLATE_TEST_CASE 或 TEMPLATE_PRODUCT_TEST_CASE 中指定的类型数量有上限，但该限制非常高，在实践中不应遇到。

- TEMPLATE_LIST_TEST_CASE( test name, tags, type list )

类型列表是应在其上实例化测试用例的类型的通用列表。 列表可以是 std::tuple，boost::mpl::list，boost::mp11::mp_list 或带有模板 `<typename ...>` 签名的任何内容。可以在多个测试用例中重用类型列表。

```cpp
using MyTypes = std::tuple<int, char, float>;
TEMPLATE_LIST_TEST_CASE("Template test case with test types specified inside std::tuple", "[template][list]", MyTypes)
{
    REQUIRE(sizeof(TestType) > 0);
}
```

### 基于签名的参数化测试用例 Signature based parametrised test cases

除了类型参数化的测试用例之外，Catch2 还支持签名基本参数化的测试用例，形式为 TEMPLATE_TEST_CASE_SIG 和 TEMPLATE_PRODUCT_TEST_CASE_SIG。 这些测试用例具有类似的语法，例如类型参数化的测试用例，并带有一个附加的位置参数来指定签名。

- Signature：签名有一些严格的规则，遵循这些测试用例才能正常工作：
  1. 具有多个模板参数的签名 `typename T, size_t S` 在测试用例声明中必须具有此格式 `((typename T, size_t S), T, S)`。
  2. 带有可变参数模板参数的签名，例如 `typename T，size_t S，typename ... Ts` 在测试用例声明中必须具有此格式`((typename T, size_t S, typename...Ts), T, S, Ts...)`。
  3. 具有单个非类型模板参数的签名，例如 `int V` 在测试用例声明中必须具有此格式 `((int V), V)`。
  4. 具有单一类型模板参数的签名，例如 不应使用 typename T ，因为它实际上是 TEMPLATE_TEST_CASE。

- TEMPLATE_TEST_CASE_SIG( test name , tags, signature, type1, type2, ..., typen )：在 TEMPLATE_TEST_CASE_SIG 测试用例中，可以使用签名中定义的模板参数的名称。

```cpp
TEMPLATE_TEST_CASE_SIG("TemplateTestSig: arrays can be created from NTTP arguments", "[vector][template][nttp]",
  ((typename T, int V), T, V), (int,5), (float,4), (std::string,15), ((std::tuple<int, float>), 6)) {

    std::array<T, V> v;
    REQUIRE(v.size() > 1);
}
```

- TEMPLATE_PRODUCT_TEST_CASE_SIG( test name , tags, signature, (template-type1, template-type2, ..., template-typen), (template-arg1, template-arg2, ..., template-argm) )

```cpp
template<typename T, size_t S>
struct Bar {
    size_t size() { return S; }
};

TEMPLATE_PRODUCT_TEST_CASE_SIG("A Template product test case with array signature", "[template][product][nttp]", ((typename T, size_t S), T, S), (std::array, Bar), ((int, 9), (float, 42))) {
    TestType x;
    REQUIRE(x.size() > 0);
}
```

## 测试固件 Test fixtures

### 定义测试固件 Defining test fixtures

虽然 Catch 允许将测试分组为测试用例中的各个部分，但有时使用更传统的测试 fixture 对它们分组仍然很方便。Catch 也完全支持这一点。您将测试固件定义为一个简单的结构:

```cpp
class UniqueTestsFixture {
  private:
   static int uniqueID;
  protected:
   DBConnection conn;
  public:
   UniqueTestsFixture() : conn(DBConnection::createConnection("myDB")) {
   }
  protected:
   int getID() {
     return ++uniqueID;
   }
 };

 int UniqueTestsFixture::uniqueID = 0;

 TEST_CASE_METHOD(UniqueTestsFixture, "Create Employee/No Name", "[create]") {
   REQUIRE_THROWS(conn.executeSQL("INSERT INTO employee (id, name) VALUES (?, ?)", getID(), ""));
 }
 TEST_CASE_METHOD(UniqueTestsFixture, "Create Employee/Normal", "[create]") {
   REQUIRE(conn.executeSQL("INSERT INTO employee (id, name) VALUES (?, ?)", getID(), "Joe Bloggs"));
 }
 ```

这里的两个测试用例将创建唯一命名的 UniqueTestsFixture 派生类，从而可以访问受 getID（）保护的方法和 conn 成员变量。 这样可以确保两个测试用例都能够使用相同的方法（DRY原理）创建DBConnection，并且确保创建的任何 ID 都是唯一的，从而使执行测试的顺序无关紧要。

Catch2 还提供了 TEMPLATE_TEST_CASE_METHOD 和 TEMPLATE_PRODUCT_TEST_CASE_METHOD，它们可以与测试组一起使用，以对多种不同类型进行测试。 与 TEST_CASE_METHOD 不同， TEMPLATE_TEST_CASE_METHOD 和 TEMPLATE_PRODUCT_TEST_CASE_METHOD 要求标签规范为非空，因为它后面是其他宏参数。

还要注意，由于 C++ 预处理程序的限制，如果要指定具有多个模板参数的类型，则需要将其括在括号中，例如 `std::map<int, std::string>` 需要以 `(std::map<int, std::string>)` 的形式传递。 在 TEMPLATE_PRODUCT_TEST_CASE_METHOD 的情况下，如果类型列表的成员应由多个类型组成，则需要将其括在另一对括号中，例如 `(std::map, std::pair)` 和 `((int, float), (char, double))`。

```cpp
template< typename T >
struct Template_Fixture {
    Template_Fixture(): m_a(1) {}

    T m_a;
};

TEMPLATE_TEST_CASE_METHOD(Template_Fixture,"A TEMPLATE_TEST_CASE_METHOD based test run that succeeds", "[class][template]", int, float, double) {
    REQUIRE( Template_Fixture<TestType>::m_a == 1 );
}

template<typename T>
struct Template_Template_Fixture {
    Template_Template_Fixture() {}

    T m_a;
};

template<typename T>
struct Foo_class {
    size_t size() {
        return 0;
    }
};

TEMPLATE_PRODUCT_TEST_CASE_METHOD(Template_Template_Fixture, "A TEMPLATE_PRODUCT_TEST_CASE_METHOD based test succeeds", "[class][template]", (Foo_class, std::vector), int) {
    REQUIRE( Template_Template_Fixture<TestType>::m_a.size() == 0 );
}
```

### 基于特征的参数化测试固件 Signature-based parametrised test fixtures

Catch2 还提供 TEMPLATE_TEST_CASE_METHOD_SIG 和 TEMPLATE_PRODUCT_TEST_CASE_METHOD_SIG 以支持使用非类型模板参数的灯具。 这些测试用例的工作方式类似于 TEMPLATE_TEST_CASE_METHOD 和 TEMPLATE_PRODUCT_TEST_CASE_METHOD，并带有用于签名的附加位置参数。

```cpp
template <int V>
struct Nttp_Fixture{
    int value = V;
};

TEMPLATE_TEST_CASE_METHOD_SIG(Nttp_Fixture, "A TEMPLATE_TEST_CASE_METHOD_SIG based test run that succeeds", "[class][template][nttp]",((int V), V), 1, 3, 6) {
    REQUIRE(Nttp_Fixture<V>::value > 0);
}

template<typename T>
struct Template_Fixture_2 {
    Template_Fixture_2() {}

    T m_a;
};

template< typename T, size_t V>
struct Template_Foo_2 {
    size_t size() { return V; }
};

TEMPLATE_PRODUCT_TEST_CASE_METHOD_SIG(Template_Fixture_2, "A TEMPLATE_PRODUCT_TEST_CASE_METHOD_SIG based test run that succeeds", "[class][template][product][nttp]", ((typename T, size_t S), T, S),(std::array, Template_Foo_2), ((int,2), (float,6)))
{
    REQUIRE(Template_Fixture_2<TestType>{}.m_a.size() >= 2);
}
```

### 在模板类型列表中指定类型的模板固件 Template fixtures with types specified in template type lists

Catch2 还提供 TEMPLATE_LIST_TEST_CASE_METHOD，以支持模板类型列表中指定类型的模板固定装置。 此测试用例与 TEMPLATE_TEST_CASE_METHOD 相同，仅区别在于类型的来源。这使您可以在多个测试案例中重用模板类型列表。

```cpp
using MyTypes = std::tuple<int, char, double>;
TEMPLATE_LIST_TEST_CASE_METHOD(Template_Fixture, "Template test case method with test types specified inside std::tuple", "[class][template][list]", MyTypes)
{
    REQUIRE( Template_Fixture<TestType>::m_a == 1 );
}
```

## 报告器 Reporters

Catch2 具有模块化的报告系统，并捆绑了一些有用的内置报告器。您还可以编写自己的报告器。

### 使用不同的报告器 Using different reporters

可以从命令行轻松控制要使用的报告程序。要指定报告者，使用 -r 或--reporter，后跟报告者的名称，例如：

```cpp
-r xml
```

- 如果您未指定报告程序，则默认情况下使用控制台报告程序。 内置有四个报告器：
  1. console：控制台以文本行形式写入，格式化为典型的终端宽度，如果检测到有能力的终端，则使用颜色。
  2. compact：类似于控制台的紧凑型设备，但针对最小输出进行了优化，每个输入一行。
  3. junit：编写与 Ant 的 junit report 目标相对应的 xml。 对于了解 Junit 的构建系统很有用。 由于 junit 格式的结构方式，运行必须在写入任何内容之前完成。
  4. xml：编写专门为 Catch 设计的 xml 格式。 与 junit 不同，这是一种流格式，因此结果将逐步传递。

在 Catch 信息库中（包括include \ reporters），还有一些针对特定构建系统的其他报告程序，如果想使用它们，可以将其 #include 到项目中。 在一个源文件中执行此操作-与拥有 CATCH_CONFIG_MAIN 或 CATCH_CONFIG_RUNNER 的源文件方式相同。

## 事件监听器 Event Listeners

侦听器是可以在 Catch 中注册的类，该类将在测试运行期间通过事件（例如测试用例的开始或结束）传递给事件。 侦听器实际上是 Reporter 的类型，有一些细微差别：

1. 在代码中注册后，它们会自动使用-您无需在命令行上指定它们。
2. 除了（在之前）任何报告程序之外，还可以调用它们，并且您可以注册多个侦听器。
3. 它们从 `Catch::TestEventListenerBase` 派生而来，它具有所有事件的默认存根，因此您不必强制实施不感兴趣的事件。
4. 使用 CATCH_REGISTER_LISTENER 注册。

### 实现时间监听器 Implementing a Listener

只需从 Catch::TestEventListenerBase 派生一个类并在主源文件（即定义 CATCH_CONFIG_MAIN 或 CATCH_CONFIG_RUNNER 的文件）中或在定义 CATCH_CONFIG_EXTERNAL_INTERFACES 的文件中实现您感兴趣的方法。

```cpp
//210-Evt-EventListeners.cpp
#define CATCH_CONFIG_MAIN
#include "catch.hpp"

struct MyListener : Catch::TestEventListenerBase {

    using TestEventListenerBase::TestEventListenerBase; // inherit constructor

    void testCaseStarting( Catch::TestCaseInfo const& testInfo ) override {
        // Perform some setup before a test case is run
    }

    void testCaseEnded( Catch::TestCaseStats const& testCaseStats ) override {
        // Tear-down after a test case is run
    }
};
CATCH_REGISTER_LISTENER( MyListener )
```

### 钩子事件 Events that can be hooked

以下是可以在侦听器中覆盖的方法：

```cpp
// The whole test run, starting and ending
virtual void testRunStarting( TestRunInfo const& testRunInfo );
virtual void testRunEnded( TestRunStats const& testRunStats );

// Test cases starting and ending
virtual void testCaseStarting( TestCaseInfo const& testInfo );
virtual void testCaseEnded( TestCaseStats const& testCaseStats );

// Sections starting and ending
virtual void sectionStarting( SectionInfo const& sectionInfo );
virtual void sectionEnded( SectionStats const& sectionStats );

// Assertions before/ after
virtual void assertionStarting( AssertionInfo const& assertionInfo );
virtual bool assertionEnded( AssertionStats const& assertionStats );

// A test is being skipped (because it is "hidden")
virtual void skipTest( TestCaseInfo const& testInfo );
```

有关事件的更多信息（例如测试用例的名称）包含在作为参数传递的结构中-只需查看源代码即可查看哪些字段可用。

## 测试数据生成器 Data Generators

数据生成器（也称为数据驱动/参数化测试用例）可以跨不同的输入值重用同一组断言。 在 Catch2 中，它们遵循 TEST_CASE和SECTION 宏的顺序和嵌套，并且它们的嵌套节在生成器中每个值运行一次。

```cpp
TEST_CASE("Generators") {
    auto i = GENERATE(1, 3, 5);
    REQUIRE(is_odd(i));
}
```

TEST_CASE 将被输入3次，i 的值依次为 1、3 和 5。generate 还可以在同一范围内多次使用，在这种情况下，结果将是生成器中所有元素的笛卡尔积。这意味着在下面的代码片段中，测试用例将运行 6(2*3) 次。

```cpp
TEST_CASE("Generators") {
    auto i = GENERATE(1, 2);
    auto j = GENERATE(3, 4, 5);
}
```

Catch2 中的生成器分为两部分，GENERATE 宏以及已经提供的生成器，以及允许用户实现自己的生成器的 `IGenerator <T>` 接口。

### GENERATE 和 SECTION 组合使用 Combining GENERATE and SECTION

GENERATE 可以看作是隐式的 SECTION，从使用 GENERATE 的位置到作用域的末尾。这可以用于各种效果。下面显示了最简单的用法，其中第一个部分运行 `4（2 * 2` 次，而第二个部分运行 6 次`（12 * 3）`。

```cpp
TEST_CASE("Generators") {
    auto i = GENERATE(1, 2);
    SECTION("one") {
        auto j = GENERATE(-3, -2);
        REQUIRE(j < i);
    }
    SECTION("two") {
        auto k = GENERATE(4, 5, 6);
        REQUIRE(j != k);
    }
}
```

The specific order of the SECTIONs will be "one", "one", "two", "two", "two", "one"

GENERATE 引入虚拟 SECTION 的实现方式也可以用于使生成器仅重播某些 SECTION，而不必显式添加 SECTION。 例如，下面的代码报告3个断言，因为“第一”部分运行一次，而“第二”部分运行两次。

```cpp
TEST_CASE("GENERATE between SECTIONs") {
    SECTION("first") { REQUIRE(true); }
    auto _ = GENERATE(1, 2);
    SECTION("second") { REQUIRE(true); }
}
```

这会导致令人惊讶的复杂测试流程。例如，下面的测试将报告 14 个断言：

```cpp
TEST_CASE("Complex mix of sections and generates") {
    auto i = GENERATE(1, 2);
    SECTION("A") {
        SUCCEED("A");
    }
    auto j = GENERATE(3, 4);
    SECTION("B") {
        SUCCEED("B");
    }
    auto k = GENERATE(5, 6);
    SUCCEED();
}
```

### 默认提供的生成器 Provided generators

Catch2 提供的生成器功能包括以下几个部分：

1. GENERATE 宏，用于将生成器表达式与测试用例集成在一起。
2. 两个基本生成器：
   1. `SingleValueGenerator<T>`：仅包含单个元素。
   2. `FixedValuesGenerator<T>`：包含多个元素。
3. 5个通用生成器，可修改其他生成器：
   1. `FilterGenerator<T, Predicate>`：从 Predicate 返回 “false” 的生成器中滤除元素。
   2. `TakeGenerator<T>`：从生成器中获取前 n 个元素。
   3. `RepeatGenerator<T>`：重复生成器的输出 n 次。
   4. `MapGenerator<T, U, Func>`：返回将 Func 应用于来自其他生成器的元素的结果。
   5. `ChunkGenerator<T>`：从生成器返回 n 个元素的块（通过 vector 容器）。
4. 4个专用生成器：
   1. `RandomIntegerGenerator<Integral>` -- 从范围生成随机积分。
   2. `RandomFloatGenerator<Float>` -- 从范围生成随机浮点数。
   3. `RangeGenerator<T>` -- 生成一个算术范围内的所有值。
   4. `IteratorGenerator<T>` -- 从迭代器范围复制并返回值。

生成器还具有关联的辅助函数，这些函数可以推断其类型，从而使它们的用法更好：

- `value(T&&)` for `SingleValueGenerator<T>`
- `values(std::initializer_list<T>)` for `FixedValuesGenerator<T>`
- `table<Ts...>(std::initializer_list<std::tuple<Ts...>>)` for `FixedValuesGenerator<std::tuple<Ts...>>`
- `filter(predicate, GeneratorWrapper<T>&&)` for `FilterGenerator<T, Predicate>`
- `take(count, GeneratorWrapper<T>&&)` for `TakeGenerator<T>`
- `repeat(repeats, GeneratorWrapper<T>&&)` for `RepeatGenerator<T>`
- `map(func, GeneratorWrapper<T>&&)` for `MapGenerator<T, U, Func>` (map `U` to `T`, deduced from `Func`)
- `map<T>(func, GeneratorWrapper<U>&&)` for `MapGenerator<T, U, Func>` (map `U` to `T`)
- `chunk(chunk-size, GeneratorWrapper<T>&&)` for `ChunkGenerator<T>`
- `random(IntegerOrFloat a, IntegerOrFloat b)` for `RandomIntegerGenerator` or `RandomFloatGenerator`
- `range(Arithemtic start, Arithmetic end)` for `RangeGenerator<Arithmetic>` with a step size of `1`
- `range(Arithmetic start, Arithmetic end, Arithmetic step)` for `RangeGenerator<Arithmetic>` with a custom step size
- `from_range(InputIterator from, InputIterator to)` for `IteratorGenerator<T>`
- `from_range(Container const&)` for `IteratorGenerator<T>`

```cpp
TEST_CASE("Generating random ints", "[example][generator]") {
    SECTION("Deducing functions") {
        auto i = GENERATE(take(100, filter([](int i) { return i % 2 == 1; }, random(-100, 100))));
        REQUIRE(i > -100);
        REQUIRE(i < 100);
        REQUIRE(i % 2 == 1);
    }
}
```

除了在 Catch2 中注册生成器外，GENERATE 宏还有一个目的，那就是提供一种生成定制生成器的简单方法，如本页第一个示例所示，在此我们将其用作 `auto i = GENERATE(1, 2, 3)` ;。这种用法将逐句地将每一个都转换为单个 `SingleValueGenerator<int>`，然后将它们全部放置在连接其他生成器的特殊生成器中。它也可以与其他生成器一起用作参数，例如 `auto i = GENERATE(0, 2, take(100, random(300, 3000)));`。 这很有用，例如 如果您知道特定的输入有问题，并想分别进行测试。

出于安全原因，不能在 GENERATE 宏中使用变量。 这样做是因为生成器表达式将超出声明周期，因此使用引用会引入问题。 如果需要在生成器表达式中使用变量，请确保仔细考虑生命周期的影响并使用 GENERATE_COPY 或 GENERATE_REF。

还可以通过使用 `as<type>` 作为宏的第一个参数来覆盖推断的类型。如果您希望它们以 `std::string` 的类型提供，这在处理字符串文字时可能会很有用。

```cpp
TEST_CASE("type conversion", "[generators]") {
    auto str = GENERATE(as<std::string>{}, "a", "bb", "ccc");
    REQUIRE(str.size() > 0);
}
```

### 生成器接口 Generator interface

您还可以通过继承 `IGenerator<T>` 接口来实现自己的生成器：

```cpp
template<typename T>
struct IGenerator : GeneratorUntypedBase {
    // via GeneratorUntypedBase:
    // Attempts to move the generator to the next element.
    // Returns true if successful (and thus has another element that can be read)
    virtual bool next() = 0;

    // Precondition:
    // The generator is either freshly constructed or the last call to next() returned true
    virtual T const& get() const = 0;
};
```

## 其他宏 Other macros

此页面可作为未在其他地方记录的宏的参考。目前，这些宏分为 2 个大致类别，即“与断言相关的宏”和“与测试用例相关的宏”。

### 断言相关的宏 Assertion related macros

- `CHECKED_IF` & `CHECKED_ELSE`：CHECKED_IF( expr ) 是一个 if 替换，它也将 Catch2 的字符串化机制应用于 expr 并记录结果。与 if 一样，仅当表达式的计算结果为 true 时，才输入 CHECKED_IF 之后的块。 CHECKED_ELSE( expr ) 的工作方式类似，但是只有在 expr 评估为 false 时才进入该块。

```cpp
int a = ...;
int b = ...;
CHECKED_IF( a == b ) {
    // This block is entered when a == b
} CHECKED_ELSE ( a == b ) {
    // This block is entered when a != b
}
```

- CHECK_NOFAIL：CHECK_NOFAIL( expr ) 是 CHECK 的变体，如果 expr 评估为 false，它不会使测试用例失败。 这对于检查某些假设可能很有用，而在测试未必一定失败的情况下可能被违反。

```cpp
main.cpp:6:
FAILED - but was ok:
  CHECK_NOFAIL( 1 == 2 )

main.cpp:7:
PASSED:
  CHECK( 2 == 2 )
```

- SUCCEED
SUCCEED( msg ) is mostly equivalent with INFO( msg ); REQUIRE( true );. 换句话说，“成功”适用于仅达到特定水平即表示测试已成功的情况。

```cpp
TEST_CASE( "SUCCEED showcase" ) {
    int I = 1;
    SUCCEED( "I is " << I );
}
```

- STATIC_REQUIRE：STATIC_REQUIRE( expr ) 是一个宏，可以与 static_assert 相同的方式使用，但也可以向 Catch2 注册成功，因此在运行时报告为成功。通过在包含 Catch2 标头之前定义CATCH_CONFIG_RUNTIME_STATIC_REQUIRE，也可以将整个检查推迟到运行时。

```cpp
TEST_CASE("STATIC_REQUIRE showcase", "[traits]") {
    STATIC_REQUIRE( std::is_void<void>::value );
    STATIC_REQUIRE_FALSE( std::is_void<int>::value );
}
```

### 测试用例相关的宏 Test case related macros

- METHOD_AS_TEST_CASE：METHOD_AS_TEST_CASE( member-function-pointer, description ) 可以将类的成员函数注册为 Catch2 测试用例。对于以这种方式注册的每个方法，将分别实例化该类。

```cpp
class TestClass {
    std::string s;

public:
    TestClass()
        :s( "hello" )
    {}

    void testCase() {
        REQUIRE( s == "hello" );
    }
};


METHOD_AS_TEST_CASE( TestClass::testCase, "Use class's method as a test case", "[class]" )
```

- REGISTER_TEST_CASE：REGISTER_TEST_CASE( function, description ) 将一个函数注册为测试用例。 该函数必须具有 `void()` 签名，描述可以包含名称和标签。

```cpp
REGISTER_TEST_CASE( someFunction, "ManuallyRegistered", "[tags]" );
```

请注意，注册仍必须在启动 `Catch2` 的会话之前进行。 这意味着它要么需要在全局构造函数中完成，要么需要在用户自己的 main 中创建 Catch2 的会话之前。

- ANON_TEST_CASE：ANON_TEST_CASE 将 TEST_CASE 替换自动生成唯一名称。这样做的好处是您不必为测试用例考虑一个名称，“缺点是该名称不一定在不同链接之间保持稳定，因此可能很难直接指定运行。

```cpp
ANON_TEST_CASE() {
    SUCCEED("Hello from anonymous test case");
}
```

- DYNAMIC_SECTION：DYNAMIC_SECTION is a SECTION where the user can use operator<< to create the final name for that section. This can be useful with e.g. generators, or when creating a SECTION dynamically, within a loop.

```cpp
TEST_CASE( "looped SECTION tests" ) {
    int a = 1;

    for( int b = 0; b < 10; ++b ) {
        DYNAMIC_SECTION( "b is currently: " << b ) {
            CHECK( b > a );
        }
    }
}
```

## 编写基准测试 Authoring benchmarks

请注意，默认情况下基准测试支持处于禁用状态，要启用它，您需要定义 CATCH_CONFIG_ENABLE_BENCHMARKING。有关更多详细信息，请参见编译时[配置文档](https://gitee.com/mirrors/Catch2/blob/master/docs/configuration.md#top)。

编写基准并不容易。Catch 简化了某些方面，但是您始终需要注意各个方面。在编写基准测试时，了解有关 Catch 运行代码方式的一些知识将非常有帮助。

- 用户代码：用户代码是用户提供的要测量的代码。
- 运行：一次运行是对用户代码的一次执行。
- 样本：一个样本是通过测量执行一定数量的运行所花费的时间而获得的一个数据点。如果可用时钟的分辨率不足以精确测量一次运行，则一个样本可以包含一个以上的运行。给定基准执行的所有样本均以相同的运行次数获得。

### 执行程序 Execution procedure

现在，我可以解释如何在Catch中执行基准测试。 有三个主要步骤，尽管不必为每个基准重复第一个步骤：

1. 环境探测：在执行任何基准测试之前，先估算时钟的分辨率。此时还估计了其他一些环境伪影，例如调用时钟函数的成本，但它们几乎对结果没有任何影响。
2. 估计参数：用户代码执行几次，以获得每个样本中应进行的运行量的估计。这也具有在实际测量开始之前将相关代码和数据带入缓存的潜​​在影响。
3. 测量：通过执行每个样品在上一步中估计的运行次数，依次收集所有样品。

这已经为我们提供了一个为Catch编写基准的重要规则：基准必须是可重复的。用户代码将被执行几次，并且在估计步骤中将被执行的次数是事先未知的，因为它取决于执行代码所花费的时间。无法重复执行的用户代码将导致虚假结果或崩溃。

### 基准规范 Benchmark specification

基准可以在 Catch 测试用例内的任何地方指定。有一个简单的高级版本的 BENCHMARK 宏。

让我们看一下如何对朴素的斐波那契实现进行基准测试：

```cpp
std::uint64_t Fibonacci(std::uint64_t number) {
    return number < 2 ? 1 : Fibonacci(number - 1) + Fibonacci(number - 2);
}
```

最简单的基准测试此功能的方法是在我们的测试用例中添加一个BENCHMARK 宏：

```cpp
TEST_CASE("Fibonacci") {
    CHECK(Fibonacci(0) == 1);
    // some more asserts..
    CHECK(Fibonacci(5) == 8);
    // some more asserts..

    // now let's benchmark:
    BENCHMARK("Fibonacci 20") {
        return Fibonacci(20);
    };

    BENCHMARK("Fibonacci 25") {
        return Fibonacci(25);
    };

    BENCHMARK("Fibonacci 30") {
        return Fibonacci(30);
    };

    BENCHMARK("Fibonacci 35") {
        return Fibonacci(35);
    };
}
```

- 有以下几点注意：
  1. 当 BENCHMARK 扩展为 lambda 表达式时，有必要在右括号后添加分号（与第一个实验版本相反）。
  2. 返回值是避免编译器优化基准代码的便捷方法。

输出：

```cpp
-------------------------------------------------------------------------------
Fibonacci
-------------------------------------------------------------------------------
C:\path\to\Catch2\Benchmark.tests.cpp(10)
...............................................................................
benchmark name                                  samples       iterations    estimated
                                                mean          low mean      high mean
                                                std dev       low std dev   high std dev
-------------------------------------------------------------------------------
Fibonacci 20                                            100       416439   83.2878 ms
                                                       2 ns         2 ns         2 ns
                                                       0 ns         0 ns         0 ns

Fibonacci 25                                            100       400776   80.1552 ms
                                                       3 ns         3 ns         3 ns
                                                       0 ns         0 ns         0 ns

Fibonacci 30                                            100       396873   79.3746 ms
                                                      17 ns        17 ns        17 ns
                                                       0 ns         0 ns         0 ns

Fibonacci 35                                            100       145169   87.1014 ms
                                                     468 ns       464 ns       473 ns
                                                      21 ns        15 ns        34 ns
```

### 高级基准测试 Advanced benchmarking

上面显示的最简单的用例，不带参数，仅运行需要测量的用户代码。 但是，如果使用 BENCHMARK_ADVANCED 宏并在宏之后添加 Catch::Benchmark::Chronometer 参数，则可以使用某些高级功能。简单基准测试的内容每次运行被调用一次，而高级基准测试的块恰好被调用两次：一次在估计阶段，另一次在执行阶段。

```cpp
BENCHMARK("simple"){ return long_computation(); };

BENCHMARK_ADVANCED("advanced")(Catch::Benchmark::Chronometer meter) {
    set_up();
    meter.measure([] { return long_computation(); });
};
```

这些高级基准不再完全由要测量的用户代码组成。 在这些情况下，要通过 Catch::Benchmark::Chronometer::measure 成员函数提供要测量的代码。 这使您可以设置基准可能需要的但不包含在测量中的任何类型的状态，例如制作随机整数向量以馈入排序算法。

对 Catch::Benchmark::Chronometer::measure 的单个调用通过调用传入的可调用对象来执行实际测量，该对象在必要时会多次传递。在测量之外需要执行的任何操作都可以在测量调用之外进行。

传递给度量的可调用对象可以选择接受一个int参数。

```cpp
meter.measure([](int i) { return long_computation(i); });
```

如果它接受一个 int 参数，则将传入每次运行的序列号，从 0 开始。这对于例如要测量某些变异代码很有用。可以通过调用 Catch::Benchmark::Chronometer::runs 事先知道运行次数。有了这个，就可以设置一个不同的实例，以便每次运行都可以对其进行突变。

```cpp
std::vector<std::string> v(meter.runs());
std::fill(v.begin(), v.end(), test_string());
meter.measure([&v](int i) { in_place_escape(v[i]); });
```

请注意，不可简单地将同一实例用于不同的运行，并在每次运行之间将其重置，因为那样会导致重置代码污染测量结果。

也可以仅向简单的 BENCHMARK 宏提供参数名称，以获取与提供带 int 参数的 meter.measure 的可调用对象相同的语义：

BENCHMARK("indexed", i){ return long_computation(i); };

### 基准的构造函数和析构函数 Constructors and destructors

所有这些工具都为您提供了很多帮助，但是有两件事仍然需要特殊处理:构造函数和析构函数。问题是，如果使用自动对象，它们会在作用域结束时被销毁，因此最终需要同时度量构建和销毁的时间。如果使用动态分配，最终会在度量中包含分配内存的时间。

为了解决这个难题，Catch提供了类模板，允许您在不进行动态分配的情况下手动构造和销毁对象，并且允许您分别度量构造和销毁。

```cpp
BENCHMARK_ADVANCED("construct")(Catch::Benchmark::Chronometer meter) {
    std::vector<Catch::Benchmark::storage_for<std::string>> storage(meter.runs());
    meter.measure([&](int i) { storage[i].construct("thing"); });
};

BENCHMARK_ADVANCED("destroy")(Catch::Benchmark::Chronometer meter) {
    std::vector<Catch::Benchmark::destructable_object<std::string>> storage(meter.runs());
    for(auto&& o : storage)
        o.construct("thing");
    meter.measure([&](int i) { storage[i].destruct(); });
};
```

`Catch::Benchmark::storage_for<T>` 对象只是适用于 T 对象的原始存储片段。 您可以使用 `Catch::Benchmark::storage_for::construct` 成员函数来调用构造函数并在该存储中创建对象。 因此，如果要测量某个构造函数运行所花费的时间，则只需测量运行此函数所花费的时间即可。

当 `Catch::Benchmark::storage_for<T>` 对象的生命周期结束时，如果在那里构造了实际对象，它将被自动销毁，因此不会泄漏任何内容。

但是，如果你想测量析构函数，我们需要使用 `Catch::Benchmark::destructable_object<T>`。这些对象类似于T对象的结构中的 `Catch::Benchmark::storage_for<T>`，但它不会自动销毁任何东西。相反，你需要调用 `Catch::Benchmark::destructable_object::destruct`析构成员函数，你可以用它来测量销毁时间。

### 优化器 The optimizer

有时优化器会优化掉您想要度量的代码。有几种使用结果的方法可以防止优化器删除它们。您可以使用 volatile 关键字，也可以将值输出到标准输出或文件中，这两种方法都会迫使程序以某种方式实际生成该值。

Catch 增加了第三个选项。作为用户代码提供的任何函数返回的值都保证会被计算而不会被优化出来。这意味着，如果您的用户代码由计算某个值组成，那么您不需要费心使用 volatile 或强制输出。从函数中返回它。这有助于保持代码的自然方式。

```cpp
// may measure nothing at all by skipping the long calculation since its
// result is not used
BENCHMARK("no return"){ long_calculation(); };

// the result of long_calculation() is guaranteed to be computed somehow
BENCHMARK("with return"){ return long_calculation(); };
```

但是，对优化器没有任何其他形式的控制。 由您决定编写一个基准，该基准可以实际测量所需的内容，而不仅仅是测量无所事事的时间。

总结起来，有两个简单的规则：在 Catch 中仍然可以使用手写代码来控制优化的任何事情； Catch 使用户代码的返回值变成无法优化的可观察效果。
