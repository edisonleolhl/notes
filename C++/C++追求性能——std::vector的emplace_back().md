C++11之前，对代码有点追求的程序员，如果事先知道vector的大小，会预先reserve出确定的空间，代码如下：

```c++
#include <iostream>
#include <vector>
#include <string>
using namespace std;

class Student{
 public:
  Student() = default;
  Student(string name): name_(name) {
    cout << "ctor called" << endl;
  }
  Student(const Student& student): name_(student.name_) {
    cout << "copy ctor called" << endl;
  }
  Student(const Student&& student): name_(student.name_) {
    cout << "move ctor called" << endl;
  }
  ~Student() = default;
 private:
  string name_;
};

int main() {
  vector<Student> vec;
  vec.reserve(4);
  cout << "size: " << vec.size() << " , capacity: " << vec.capacity() << endl;
  vec.push_back(Student("alice"));
  cout << "size: " << vec.size() << " , capacity: " << vec.capacity() << endl;
  vec.push_back(Student("bob"));
  cout << "size: " << vec.size() << " , capacity: " << vec.capacity() << endl;
  vec.push_back(Student("cindy"));
  cout << "size: " << vec.size() << " , capacity: " << vec.capacity() << endl;
  vec.push_back(Student("daisy"));
  cout << "size: " << vec.size() << " , capacity: " << vec.capacity() << endl;
  return 0;
}
```

输出：

```c++
$./a.out 
size: 0 , capacity: 4
ctor called
move ctor called
size: 1 , capacity: 4
ctor called
move ctor called
size: 2 , capacity: 4
ctor called
move ctor called
size: 3 , capacity: 4
ctor called
move ctor called
size: 4 , capacity: 4
```

看上去不错了，每次通过ctor与move ctor即可构造出对象。

但在C++11后，引入了emplace_back，看一下[cppreference](https://en.cppreference.com/w/cpp/container/vector/emplace_back)的介绍：

> Appends a new element to the end of the container. The element is constructed through [std::allocator_traits::construct](https://en.cppreference.com/w/cpp/memory/allocator_traits/construct), which typically uses placement-new to construct the element in-place at the location provided by the container. The arguments args... are forwarded to the constructor as [std::forward](http://en.cppreference.com/w/cpp/utility/forward)<Args>(args)....

> If the new [size()](https://en.cppreference.com/w/cpp/container/vector/size) is greater than [capacity()](https://en.cppreference.com/w/cpp/container/vector/capacity) then all iterators and references (including the past-the-end iterator) are invalidated. Otherwise only the past-the-end iterator is invalidated.

看上去挺香的，可以直接在末尾构造出对象，并且使用的是placement-new操作符，就地（in-place）构造，并且使用了std::forward完美转发，需要注意的是最后一句，如果新的size大于capacity，则所有迭代器都会失效，因为这涉及到vector的扩容机制了，每次扩容时都会开辟一个新空间，再把原来的元素复制到新空间去，再回收原空间（详细过程可参考侯捷的STL源码剖析）

于是把代码修改为：

```c++
  vector<Student> vec;
  vec.reserve(4);
  cout << "size: " << vec.size() << " , capacity: " << vec.capacity() << endl;
  vec.emplace_back("alice");
  cout << "size: " << vec.size() << " , capacity: " << vec.capacity() << endl;
  vec.emplace_back("bob");
  cout << "size: " << vec.size() << " , capacity: " << vec.capacity() << endl;
  vec.emplace_back("cindy");
  cout << "size: " << vec.size() << " , capacity: " << vec.capacity() << endl;
  vec.emplace_back("daisy");
  cout << "size: " << vec.size() << " , capacity: " << vec.capacity() << endl;
```

输出：

```c++
$./a.out 
size: 0 , capacity: 4
ctor called
size: 1 , capacity: 4
ctor called
size: 2 , capacity: 4
ctor called
size: 3 , capacity: 4
ctor called
size: 4 , capacity: 4
```

可以看到，每次插入时，只需要一次构造，当元素数量很大时，这是一个很大的优化。

注意，不要像下面的这样调用emplace_back，否则前功尽弃了：

```c++
  vector<Student> vec;
  vec.reserve(4);
  cout << "size: " << vec.size() << " , capacity: " << vec.capacity() << endl;
  Student stu1 = Student("alice");
  vec.emplace_back(stu1);
  cout << "size: " << vec.size() << " , capacity: " << vec.capacity() << endl;
  Student stu2 = Student("bob");
  vec.emplace_back(stu2);
  cout << "size: " << vec.size() << " , capacity: " << vec.capacity() << endl;
  Student stu3 = Student("cindy");
  vec.emplace_back(stu3);
  cout << "size: " << vec.size() << " , capacity: " << vec.capacity() << endl;
  Student stu4 = Student("daisy");
  vec.emplace_back(stu4);
  cout << "size: " << vec.size() << " , capacity: " << vec.capacity() << endl;
```

输出：

```c++
$./a.out 
size: 0 , capacity: 4
ctor called
copy ctor called
size: 1 , capacity: 4
ctor called
copy ctor called
size: 2 , capacity: 4
ctor called
copy ctor called
size: 3 , capacity: 4
ctor called
copy ctor called
size: 4 , capacity: 4
```

这种代码并没有原地（in-place）构造对象，所以还是得经过copy ctor。
> 原文发表于 https://www.jianshu.com/p/0c304500c20b, by 2020.06.24 20:15:20