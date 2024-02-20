/*
 * References
 * [1] https://thispointer.com/c11-how-to-use-stdthread-as-a-member-variable-in-class
 * [2] https://en.cppreference.com/w/cpp/thread/thread/operator=
 *
 */

#include <chrono>
#include <functional>
#include <iostream>
#include <thread>
#include <vector>

class ThreadWrapper // See [1]
{
    std::thread m_thread_handler;

public:
    ThreadWrapper(const ThreadWrapper&) = delete;
    ThreadWrapper& operator=(const ThreadWrapper&) = delete;
    ThreadWrapper(ThreadWrapper&&) noexcept;
    ThreadWrapper& operator=(ThreadWrapper&&) noexcept;
    ThreadWrapper(std::function<void()> func);
    ~ThreadWrapper();
};

ThreadWrapper::ThreadWrapper(std::function<void()> func)
    : m_thread_handler(func)
{
}

ThreadWrapper::ThreadWrapper(ThreadWrapper&& other) noexcept
    : m_thread_handler(std::move(other.m_thread_handler))
{
    std::cout << "Move Constructor is called" << std::endl;
}

ThreadWrapper& ThreadWrapper::operator=(ThreadWrapper&& other) noexcept
{
    std::cout << "Move Assignment is called" << std::endl;

    // If m_thread_handler still has an associated running thread
    // (i.e. joinable() == true),  calls std::terminate(), see [2].
    if (m_thread_handler.joinable())
        m_thread_handler.join();
    m_thread_handler = std::move(other.m_thread_handler);
    return *this;
}

ThreadWrapper::~ThreadWrapper()
{
    if (m_thread_handler.joinable())
        m_thread_handler.join();
}

int main()
{
    // Creating a std::function object
    std::function<void()> func = []() {
        // Sleep for 1 second
        std::this_thread::sleep_for(std::chrono::seconds(1));
        // Print thread ID
        std::cout << "From Thread ID:" << std::this_thread::get_id() << std::endl;
    };

    {
        // Create a ThreadWrapper object
        // It will internally start the thread
        ThreadWrapper thwp(func);

        // When wrapper will go out of scope, its destructor will be called
        // which will internally join the member thread object
    }

    // Create a vector of ThreadWrapper objects
    std::vector<ThreadWrapper> thwps;
    thwps.reserve(2);

    // Add ThreadWrapper objects in thread
    ThreadWrapper thwp1(func);
    ThreadWrapper thwp2(func);
    thwps.push_back(std::move(thwp1));
    thwps.push_back(std::move(thwp2));

    ThreadWrapper thwp3(func);

    // Change the content of vector
    thwps[1] = std::move(thwp3);

    // When vector will go out of scope, its destructor will be called.
    // which will internally call the destructor of all ThreadWrapper objects,
    // which in turn joinsthe member thread object.
}

