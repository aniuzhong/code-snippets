// References
// [1] https://gist.github.com/thelinked/6997598

#include <iostream>
#include <chrono>
#include <queue>
#include <thread>
#include <mutex>
#include <condition_variable>

template <typename T>
class LockingQueue
{
public:
    void push(const T& data)
    {
        {
        std::lock_guard<std::mutex> lock(m_guard);
        m_queue.push(data);
        }
    }
    
    bool empty() const
    {
        std::lock_guard<std::mutex> lock(m_guard);
        return m_queue.empty();
    }

    bool try_pop(T& value)
    {
        std::lock_guard<std::mutex> lock(m_guard);
        if (m_queue.empty())
            return false;
        value = m_queue.front();
        m_queue.pop();
        return true;
    }

    void wait_and_pop(T& value)
    {
        std::unique_lock<std::mutex> lock(m_guard);
        while (m_queue.empty())
            m_signal.wait(lock);
        value = m_queue.front();
        m_queue.pop();
    }
    
    bool try_wait_and_pop(T& value, int milli)
    {
        std::unique_lock<std::mutex> lock(m_guard);
        while (m_queue.empty()) {
            m_signal.wait_for(lock, std::chrono::milliseconds(milli));
            return false;
        }
        value = m_queue.front();
        m_queue.pop();
        return true;
    }

private:
    std::queue<T> m_queue;
    mutable std::mutex m_guard;
    std::condition_variable m_signal;
};

int main()
{
}
