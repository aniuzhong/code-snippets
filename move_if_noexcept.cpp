/*
 * References
 * [1] https://gieseanw.wordpress.com/2020/08/28/friendly-reminder-to-mark-your-move-constructors-noexcept/
 * [2] https://en.cppreference.com/w/cpp/language/exceptions#Exception_safety
 * 
 * In Andy's blog([2]), we knew following truth,
 * - std::vector::push_back make "strong exception guarantees", std::vector will keep unchanged if push_back fails.
 * - If emplace_back causes the vector to reallocate, it can't exactly std::move() your elements to the new storage
 *   if the operation might throw, so it will copy them instead
 * - If we mark our move constructor as noexcept, we will only performing moves on rellocation
 * - If no copy operation is available, it will begrudgingly use your throwing move constructor and forsake all
 *   exception guarantees
 */

#include <iostream>
#include <stdexcept>
#include <vector>

class nothrow_move_constructable
{
public:
    nothrow_move_constructable(size_t sz, char ch)
        : m_data(sz, 'a')
    {
    }

    nothrow_move_constructable(const nothrow_move_constructable& other)
        : m_data(other.m_data)
    {
        std::cout << "Copied\n";
    }

    nothrow_move_constructable(nothrow_move_constructable&& other) noexcept
        : m_data(std::move(other.m_data))
    {
        std::cout << "Moved\n";
    }

private:
    std::string m_data;
};

int main()
{
    std::vector<nothrow_move_constructable> vec;

    std::cout << "vec.size(): " << vec.size() << '\n';

    vec.emplace_back(1024, 'a');

    std::cout << "vec.size(): " << vec.size() << '\n';

    vec.emplace_back(1024, 'a');

    std::cout << "vec.size(): " << vec.size() << '\n';
}
