# 在 Catch2 中使用 GMock 打桩

参考 github 项目：[catch2-with-gmock](https://github.com/matepek/catch2-with-gmock)

已 [TDD_Learning](https://github.com/HATTER-LONG/TDD_Learning/tree/master/test/Catch2/PlaceDescriptionServiceTestByGMock) 项目这部分代码为例：

首先 main 函数中需要进行初始化工作：

```cpp
#define CATCH_CONFIG_RUNNER
#include "catch2/catch.hpp"

#include "gmock/gmock.h"

int main(int argc, char** argv)
{
    int gmockArgC = 1;
    ::testing::InitGoogleMock(&gmockArgC, argv);

    struct Listener : public testing::EmptyTestEventListener
    {
        void OnTestPartResult(const testing::TestPartResult& Result) override
        {
            std::string filename = "unknown";
            size_t linenumber = 0;
            std::string message = "unknown";

            if (Result.file_name() != nullptr) filename = Result.file_name();

            if (Result.line_number() != -1) linenumber = static_cast<std::size_t>(Result.line_number());

            if (Result.message() != nullptr) message = Result.message();

            ::Catch::SourceLineInfo sourceLineInfo(filename.c_str(), linenumber);

            if (Result.fatally_failed())
            {
                ::Catch::AssertionHandler assertion(
                    "GTEST", sourceLineInfo, "", ::Catch::ResultDisposition::Normal);

                assertion.handleMessage(::Catch::ResultWas::ExplicitFailure, message);

                assertion.setCompleted();
            }
            else if (Result.nonfatally_failed())
            {
                ::Catch::AssertionHandler assertion(
                    "GTEST", sourceLineInfo, "", ::Catch::ResultDisposition::ContinueOnFailure);

                assertion.handleMessage(::Catch::ResultWas::ExplicitFailure, message);

                assertion.setCompleted();
            }
        }
    };

    ::testing::UnitTest::GetInstance()->listeners().Append(new Listener);

    delete ::testing::UnitTest::GetInstance()->listeners().Release(
        ::testing::UnitTest::GetInstance()->listeners().default_result_printer());

    Catch::Session session;

    int returnCode = session.applyCommandLine(argc, argv);
    if (returnCode != 0)   // Indicates a command line error
        return returnCode;

    int result = session.run();

    return result;
}
```

接下来就可以在[测试源文件](https://github.com/HATTER-LONG/TDD_Learning/blob/master/test/Catch2/PlaceDescriptionServiceTestByGMock/PlaceDescriptionServiceTest.cpp)中进行打桩了：

```cpp
class HttpStub : public Http
{
public:
    MOCK_METHOD(void, initialize, (), (override));
    MOCK_METHOD(string, get, (const string&), (const override));
};
```

同样也可以使用 GMock 提供的断言方法：

```cpp
Expectation expect = EXPECT_CALL(*m_httpStub, initialize());
EXPECT_CALL(*m_httpStub, get(expectedURL)).After(expect);
```

CMakeLists.txt 配置如下：

```cpp
  
find_package(Catch2 REQUIRED CONFIG)
find_package(jsoncpp REQUIRED CONFIG)
find_package(CURL REQUIRED CONFIG)
find_package(GTest REQUIRED CONFIG)

FILE(GLOB SRCFILELIST
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
    "${CMAKE_SOURCE_DIR}/Src/PlaceDescriptionServiceMock/*.cpp"
   )

# 当前使用的 googletest 版本为 1.10.x MOCK_METHOD 宏在编译器下会有错误信息，依据 gmock issues 无用报错 关闭相关警告
add_definitions(-Wno-gnu-zero-variadic-macro-arguments)
add_executable(cathc2_PlaceDescriptionServiceByGmock ${SRCFILELIST})

target_link_libraries(cathc2_PlaceDescriptionServiceByGmock
    Catch2::Catch2WithMain
    GTest::gmock
    jsoncpp_lib_static
    CURL::libcurl
    ${LOCAL_LINK_LIB} 
    )
```
