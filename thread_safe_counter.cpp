// References
// [1] https://en.cppreference.com/w/cpp/language/cv

class ThreadsafeCounter
{
    mutable std::mutex m; // The "M&M rule": mutable and mutex go together
    int data = 0;

public:
    int get() const
    {
        std::lock_guard<std::mutex> lk(m);
        return data;
    }
 
    void inc()
    {
        std::lock_guard<std::mutex> lk(m);
        ++data;
    }
};

int main()
{
}