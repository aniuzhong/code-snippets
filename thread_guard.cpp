// References
// [1] CCIA 2.1.3 Waiting in exceptional circumstances

#include <exception>
#include <iostream>
#include <stdexcept>
#include <thread>

class thread_guard
{
    std::thread& m_t;

public:
    explicit thread_guard(std::thread& t)
        : m_t(t)
    {
    }
    ~thread_guard()
    {
        if (m_t.joinable())
            m_t.join();
    }
    thread_guard(const thread_guard&) = delete;
    thread_guard operator=(const thread_guard&) = delete;
};

struct func
{
    int& m_i;
    func(int& i) : m_i(i) {}
    void operator() ()
    {
        for (unsigned j = 0; j < 1000000; ++j)
            m_i += 42;
    }
};

void throw_in_current_thread()
{
    throw std::runtime_error("Oops\n");
}

void f()
{
    int some_local_state = 0;
    func my_func(some_local_state);
    std::thread t(my_func);
    thread_guard g(t);
    
    throw_in_current_thread();
}

int main()
{
    try {
        f();
    } catch (const std::exception& e) {
        std::cout << e.what();
    }
}
