## 数组

#### 26.从排序数组中删除重复项 （数组）

给定一个排序数组，你需要在**[原地](http://baike.baidu.com/item/原地算法)**删除重复出现的元素，使得每个元素只出现一次，返回移除后数组的新长度。不要使用额外的数组空间，你必须在**[原地](https://baike.baidu.com/item/原地算法)修改输入数组**并在使用 O (1) 额外空间的条件下完成。你不需要考虑数组中超出新长度后面的元素。

##### 216ms（战胜17.87%cpp）的解答：

```c++
class Solution {
public:
    int removeDuplicates(vector<int>& nums) {
        if(nums.empty()){
            return 0;
        }
        auto temp = nums.begin();
        for(auto it = nums.begin() + 1; it != nums.end();){
            if(*it == *temp){
                nums.erase(it);
            }
            else{
                temp = it;
                ++it;
            }
        }
        return nums.size();
    }
};
```

思考：效率一般，因为题目中说明“不需要考虑数组中超出新长度后面的元素”，其实不需要用erase函数，因为vector在尾部之外的位置插入/删除元素可能很慢，所以用两个指针，一个遍历原数组，一个指示当前操作的最后一个元素，最后用迭代器的减法操作输出数组大小即可。

##### 24ms（战胜94.20%cpp）的解答：

```c++
class Solution {
public:
    int removeDuplicates(vector<int>& nums) {
        if(nums.empty()){
            return 0;
        }
        int pre = 0;
        for(int curr = 1; curr < nums.size(); ++curr){
            if(nums[curr] == nums[pre]){
                ;
            }
            else{
                ++pre;
                nums[pre] = nums[curr];
            }
        }
        return ++pre;
    }
};
```

思考：前面的解答明显杀鸡用牛刀，直接用两个指针，快指针每步都增加，慢指针仅在两个指针所指的数字不同时才增加，当快指针走完整个数组时，慢指针加一即为新数组的个数。

 ![img](https://camo.githubusercontent.com/74ae3265f10552715023aef368d9d8e15e051965/68747470733a2f2f6275636b65742d313235373132363534392e636f732e61702d6775616e677a686f752e6d7971636c6f75642e636f6d2f32303138313131363131353630312e676966) 

####  122.买卖股票的最佳时机 II（数组）

给定一个数组，它的第 *i* 个元素是一支给定股票第 *i* 天的价格。

设计一个算法来计算你所能获取的最大利润。你可以尽可能地完成更多的交易（多次买卖一支股票）。

**注意：**你不能同时参与多笔交易（你必须在再次购买前出售掉之前的股票）。 

##### 0ms（战胜100%cpp）的解答：

```c++
class Solution {
public:
    int maxProfit(vector<int>& prices) {
        // catch every increasing period
        if(prices.empty()) return 0;
        int profit = 0;
        for(int curr = 0; curr < prices.size() - 1; ++curr){
            if(prices[curr + 1] > prices[curr]){
                profit = profit + prices[curr + 1] - prices[curr];
            }
        }
        return profit;
    }
};
```

思考：相当于贪心，每次能赚一笔是一笔，短线操作，反正没有手续费:P

#### 189. 旋转数组（数组）

给定一个数组，将数组中的元素向右移动 *k* 个位置，其中 *k* 是非负数。

**说明:**

- 尽可能想出更多的解决方案，至少有三种不同的方法可以解决这个问题。
- 要求使用空间复杂度为 O (1) 的 **原地** 算法。

##### 第一次尝试（空间复杂度为O(1)，时间复杂度为O(kn)，因超时无法通过）：

```c++
class Solution {
public:
    void rotate(vector<int>& nums, int k) {
        int n = nums.size();
        int last;
        for(int ki = 0; ki < k; ++ki){
            last = nums[n - 1];
            for(int i = n - 1; i > 0; --i){
                nums[i] = nums[i - 1];
            }
            nums[0] = last;
        }
    }
};
```

思考：超时，很明显这种方法很笨，嵌套for循环，时间复杂度是O(kn)，当k与n很大时，效率太低！

##### 第二次尝试（空间复杂度为O(n)，时间复杂度为O(n)）：

**思路**：先确定首元素在旋转后的位置，这样分为两个子数组，用一个临时数组存放旋转后的值，最后赋值给原数组

20ms（战胜94.85%cpp）的解答：

```c++
class Solution {
public:
    void rotate(vector<int>& nums, int k) {
        int offset = k % nums.size();
        if(offset == 0) return;
        int n = nums.size();
        vector<int> temp;
        for(int i = n-offset; i < n; ++i){
            temp.push_back(nums[i]);
        }
        for(int i = 0; i < n-offset; ++i){
            temp.push_back(nums[i]);
        }
        nums = temp;
    }
};
```



##### 第三次尝试（空间复杂度为O(1)，时间复杂度为O(n)）：

如果  `n = 7 , k = 3`，给定数组  `[1,2,3,4,5,6,7]`  ，向右旋转后的结果为 `[5,6,7,1,2,3,4]`。

**思路：**把原数组划分为两个部分来看：`前 n - k 个元素 [1,2,3,4]` 和 `后k个元素 [5,6,7]`，进行分开处理

1. 定义 reverse 逆转方法：将数组元素反转，比如 [1,2,3,4] 逆转后变成  [4,3,2,1]
2.  对前 n - k 个元素 [1,2,3,4] 进行逆转后得到 [4,3,2,1]
3.  对后 k 个元素 [5,6,7] 进行逆转后得到 [7,6,5]
4.  将前后元素 [4,3,2,1,7,6,5] 逆转得到：[5,6,7,1,2,3,4]
    **注意：还要处理 k > 数组长度的情况，对 k 进行取模**

##### 24ms（战胜76.34%cpp）的解答：

```c++
class Solution {
public:
    void reverseVec(vector<int>& nums, int k){
        int n = nums.size();
        for(int i = 0; i < (n-k) / 2; ++i){
            swap(nums[i], nums[n-k-1-i]);
        }
        for(int i = 0; i < k/2; ++i){
            swap(nums[i+n-k], nums[n-1-i]);
        }
        for(int i = 0; i < n/2; ++i){
            swap(nums[i], nums[n-1-i]);
        }
    }
    void rotate(vector<int>& nums, int k) {
        int offset = k % nums.size();
        if(offset == 0) return;
        reverseVec(nums, offset);
    }
};
```

#### 217.存在重复元素

##### 56ms（战胜54.17%的cpp）的解答：

思路：利用cpp的关联容器set来存放唯一的键，一个循环遍历依次判断

```c++
class Solution {
public:
    bool containsDuplicate(vector<int>& nums) {
        if(nums.size() == 0 || nums.size() == 1) return false;
        set<int> dic;
        for(int i = 0; i < nums.size(); ++i){
            if(dic.find(nums[i]) == dic.end()){
                dic.insert(nums[i]);
            }
            else{
                return true;
            }
        }
        return false;
    }
};
```

##### 效率差不多代码更少的解答：

思路：直接将数组赋值给set，相同值会被删除，最后比较set与原数组大小是否相等即可

```c++
class Solution {
public:
    bool containsDuplicate(vector<int>& nums) {
        set<int> hashset(nums.begin(),nums.end());
            return hashset.size()!=nums.size();
    }
};
```

##### 先排序再前后比较的解法：

思路：先将数组排序，然后一个循环依次遍历，考察前后两元素是否相等，用到了泛型算法sort 

```c++
class Solution {
public:
    bool containsDuplicate(vector<int>& nums) {
        if(nums.size() < 2) return false;
        sort(nums.begin(),nums.end());
        for(int i = 0;i < nums.size()-1; ++i)
        {
            if(nums[i]==nums[i+1])
                return true;
        }
        return false;
    }
};
```

#### 137.只出现一次的数字

给定一个**非空**整数数组，除了某个元素只出现一次以外，其余每个元素均出现两次。找出那个只出现了一次的元素。

**说明：**

你的算法应该具有线性时间复杂度。 你可以不使用额外空间来实现吗？ 

##### 24ms（战胜41.51%cpp）的解答：

思路：先利用cpp的sort泛型算法排序，然后遍历，依次比较当前与前后是否相同，**但是并没有实现线性时间复杂度！**

```c++
class Solution {
public:
    int singleNumber(vector<int>& nums) {
        if(nums.size() == 1){
            return nums[0];
        }
        sort(nums.begin(), nums.end());
        if(nums[0] != nums[1]){
            return nums[0];
        }
        for(int i = 1; i < nums.size()-1; ++i){
            if(nums[i-1] != nums[i] && nums[i] != nums[i+1]){
                return nums[i];
            }
        }
        return nums[nums.size()-1];
    }
};
```

##### 同样时间，线性时间复杂度但用了额外空间的解答：

思路：利用关联容器map来记录每个数字的出现次数，最后再遍历找到找出现一次的数字

```c++
class Solution {
public:
    int singleNumber(vector<int>& nums) {
        if(nums.size() == 1){
            return nums[0];
        }
        map<int, int> intCount;
        for(int i = 0; i < nums.size(); ++i){
            ++intCount[nums[i]];
        }
        // for(auto it = intCount.begin(); it != intCount.end(); ++it){
        //     if(it->second == 1){
        //         return it->first;
        //     }
        // }
        for(const auto &w : intCount){
            if(w.second == 1){
                return w.first;
            }
        }
        return 0; // never reach here
    }
};
```

##### 最佳解法，线性时间复杂度，没有额外空间：

思路：充分理解题干，利用异或，把所有元素异或一遍，结果即为落单的元素

```c++
class Solution {
public:
    int singleNumber(vector<int>& nums) {
        int result = 0;
        for(const auto &num : nums){
            result ^= num;
        }
        return result;
    }
};
```

#### 350.两个数组的交集 II

给定两个数组，编写一个函数来计算它们的交集。

```
输入: nums1 = [1,2,2,1], nums2 = [2,2]
输出: [2,2]
```

**说明：**

- 输出结果中每个元素出现的次数，应与元素在两个数组中出现的次数一致。
- 我们可以不考虑输出结果的顺序。

进阶:

- 如果给定的数组已经排好序呢？你将如何优化你的算法？
- 如果 *nums1* 的大小比 *nums2* 小很多，哪种方法更优？
- 如果 *nums2* 的元素存储在磁盘上，磁盘内存是有限的，并且你不能一次加载所有的元素到内存中，你该怎么办？

##### 第一次尝试，8ms（战胜95.77%cpp）：

思路：对于小数组里的每一个数，在大数组里寻找，若找到，则添加进交集中并删除

```c++
class Solution {
public:
    vector<int> intersect(vector<int>& nums1, vector<int>& nums2) {
        vector<int> result;
        if(nums1.size() < nums2.size()){
            for(int i = 0; i < nums1.size(); ++i){
                auto it = find(nums2.begin(), nums2.end(), nums1[i]);
                if(it != nums2.end()){
                    result.push_back(*it);
                    nums2.erase(it);
                }
            }
        }
        else{
            for(int i = 0; i < nums2.size(); ++i){
                auto it = find(nums1.begin(), nums1.end(), nums2[i]);
                if(it != nums1.end()){
                    result.push_back(*it);
                    nums1.erase(it);
                }
            }
        }
        return result;
    }
};
```

##### 第二次尝试，4ms（战胜99.74%的cpp）：

思路：将nums1的元素映射到map中的出现次数，然后遍历nums2，若当前数字在map中，则添加进res，并且map对应值-1，想了一下，这种方法与两个数组哪个大无关

```c++
class Solution {
public:
    vector<int> intersect(vector<int>& nums1, vector<int>& nums2) {
        vector<int> res;
        map<int, int> intCount;
        for(const auto &num : nums1){
            ++intCount[num];
        }
        for(const auto &num : nums2){
            auto it = intCount.find(num);
            if(it != intCount.end() && it->second != 0){
                res.push_back(it->first);
                --intCount[num];
            }
        }
        return res;
    }
};
```

##### 进阶1，第一次尝试的优化：

思路：若两个数组已排序，则搜索操作不必遍历整个数组，只要当待搜数字比迭代器要小时就可以跳出迭代，因为迭代器后面的数字肯定不小于当前迭代器的数字

```c++
class Solution {
public:
    vector<int> intersect(vector<int>& nums1, vector<int>& nums2) {
        vector<int> result;
        sort(nums1.begin(), nums1.end());	 // to pass some unsorted test case
        sort(nums2.begin(), nums2.end());  // to pass some unsorted test case
        if(nums1.size() < nums2.size()){
            for(int i = 0; i < nums1.size(); ++i){
                // auto it = find(nums2.begin(), nums2.end(), nums1[i]);
                for(auto it = nums2.begin(); it != nums2.end(); ++it){
                    if(nums1[i] < *it){
                        break;  // sorted vector, skip the iteration if
                    }
                    if(nums1[i] == *it){
                        result.push_back(*it);
                        nums2.erase(it);
                        break;
                    }
                }
            }
        }
        else{
            for(int i = 0; i < nums2.size(); ++i){
                for(auto it = nums1.begin(); it != nums1.end(); ++it){
                    if(nums2[i] < *it){
                        break;  // sorted vector, skip the iteration if
                    }
                    if(nums2[i] == *it){
                        result.push_back(*it);
                        nums1.erase(it);
                        break;
                    }
                }
            }
        }
        return result;
    }
};
```

##### 进阶1，两个指针齐头并进，4ms（战胜99.74%的cpp）：

思路：两个指针对应两个数组头部，如果相等则同时+1，并且放入res，如果小于，则小于的指针+1，

```c++
class Solution {
public:
    vector<int> intersect(vector<int>& nums1, vector<int>& nums2) {
        vector<int> res;
        sort(nums1.begin(), nums1.end());	 
        sort(nums2.begin(), nums2.end());  
        auto it1 = nums1.begin();
        auto it2 = nums2.begin();
        while(it1 != nums1.end() && it2 != nums2.end()){
            if(*it1 == *it2){
                res.push_back(*it1);
                ++it1;
                ++it2;
            }
            else if(*it1 < *it2){
                ++it1;
            }
            else{
                ++it2;
            }
        }
        return res;
    }
};
```

#### 66.加一

给定一个由**整数**组成的**非空**数组所表示的非负整数，在该数的基础上加一。

最高位数字存放在数组的首位， 数组中每个元素只存储**单个**数字。

你可以假设除了整数 0 之外，这个整数不会以零开头。

##### 8ms的解答：

思路：倒序遍历数组，用一个进位标志，注意最后还需要处理首位进位的情况

```c++
class Solution {
public:
    vector<int> plusOne(vector<int>& digits) {
        bool carry = true;
        for(int i = digits.size()-1; carry && i >= 0; --i){
            if(digits[i] == 9){
                digits[i] = 0;
                carry = true;
            }
            else{
                ++digits[i];
                carry = false;
                return digits;
            }
        }
        if(carry && digits[0] == 0){
            digits.insert(digits.begin(), 1);
        }
        return digits;
    }
};
```

#### 283.移动零

给定一个数组 `nums`，编写一个函数将所有 `0` 移动到数组的末尾，同时保持非零元素的相对顺序。

```
输入: [0,1,0,3,12]
输出: [1,3,12,0,0]
```

**说明**:

1. 必须在原数组上操作，不能拷贝额外的数组。
2. 尽量减少操作次数。

##### 第一次尝试，超出时间限制：

思路：从头到尾遍历数组，若发现0，则删除，在数组末尾插入0，**超时原因估计是在循环遍历时增加/删除了vector中的元素，导致后面的迭代器失效**！

```c++
class Solution {
public:
    void moveZeroes(vector<int>& nums) {
        for(auto it = nums.begin(); it != nums.end();){
            if(*it == 0){
                it = nums.erase(it);
                nums.push_back(0);
            }
            else{
                ++it;
            }
        }
    }
};
```

##### 修改后，24ms（战胜53.4%的cpp）：

```c++
class Solution {
public:
    void moveZeroes(vector<int>& nums) {
        auto it = nums.begin(); 
        int zeroCount = 0;
        while(it != nums.end()){
            if(*it == 0){
                it = nums.erase(it);
                // nums.push_back(0); // inserting during iteration invalidates iterator it
                ++zeroCount;
            }
            else{
                ++it;
            }
        }
        for(int i = 0; i < zeroCount; ++i){
            nums.push_back(0);
        }
    }
};
```

##### 优化：

思路：维持一个计数器index记录**非0**的出现次数，遍历，如果不是0，则将非0值移到第index个位置上，然后index+1，最后将数组后index个元素置为0

特点：记录非0数字

```c++
class Solution {
public:
    void moveZeroes(vector<int>& nums) {
        int index = 0;  // record non-zero count
        for(int i = 0; i < nums.size(); ++i){
            if(nums[i] != 0){
                nums[index] = nums[i];
                ++index;
            }
        }
        for(int i = index; i < nums.size(); ++i){
            nums[i] = 0;
        }
    }
};
```

##### 继续优化：

思路：上一版本的最后for循环可以省略

```c++
class Solution {
public:
    void moveZeroes(vector<int>& nums) {
        int index = 0;  // record non-zero count
        for(int i = 0; i < nums.size(); ++i){
            if(nums[i] != 0 && i != index){
                nums[index] = nums[i];
                ++index;
                nums[i] = 0;
            }
            else if(nums[i] != 0 && i == index){
                ++index;
            }
        }
    }
};
```

#### 1.两数之和

给定一个整数数组 `nums` 和一个目标值 `target`，请你在该数组中找出和为目标值的那 **两个** 整数，并返回他们的数组下标。

你可以假设每种输入只会对应一个答案。但是，你不能重复利用这个数组中同样的元素。

**示例:**

```
给定 nums = [2, 7, 11, 15], target = 9

因为 nums[0] + nums[1] = 2 + 7 = 9
所以返回 [0, 1]
```

##### 第一次尝试，188ms（战胜45.39%的cpp）：

思路：嵌套循环，没什么好说的，笨方法，时间复杂度为O(n^2)，空间复杂度为O(1)

```c++
class Solution {
public:
    vector<int> twoSum(vector<int>& nums, int target) {
        vector<int> res;
        int sum;
        for(int i = 0; i < nums.size(); ++i){
            for(int j = i+1; j < nums.size(); ++j){
                sum = nums[i] + nums[j];
                if(sum == target){
                    res.push_back(i);
                    res.push_back(j);
                    return res;
                }
            }
        }
        return res;
    }
};
```

##### 优化，一遍哈希表，8ms（战胜98.36%的cpp）：

思路： 采取一边插入哈希表一边寻找一边在已经插入的哈希表中寻找的方式，每次都拿着即将插入哈希表的数字然后在哈希表中找是否存在剩下的那个函数，在哈希表查找时间可以认为是O(1)，总的时间复杂度就是O(n)，而哈希表是用空间换取时间的典型，所以空间复杂度为O(n)

```c++
class Solution {
public:
    vector<int> twoSum(vector<int>& nums, int target) {
        vector<int> res;
        unordered_map<int, int> hash;  //由于unorder_map速度要比map快所以选择无序哈希表  
        for(int i = 0; i < nums.size(); ++i){
            int another = target - nums[i];
            if(hash.count(another)){  // 不存在则为0
                res = vector<int>({hash[another], i});
                return res;
            }
            hash[nums[i]] = i;
        }
        return res;
    }
};
```

#### 36.有效的数独

 判断一个 9x9 的数独是否有效。只需要**根据以下规则**，验证已经填入的数字是否有效即可。

1. 数字 `1-9` 在每一行只能出现一次。
2. 数字 `1-9` 在每一列只能出现一次。
3. 数字 `1-9` 在每一个以粗实线分隔的 `3x3` 宫内只能出现一次。

**说明:**

- 一个有效的数独（部分已被填充）不一定是可解的。
- 只需要根据以上规则，验证已经填入的数字是否有效即可。
- 给定数独序列只包含数字 `1-9` 和字符 `'.'` 。
- 给定数独永远是 `9x9` 形式的。

##### 第一次尝试，36ms（战胜18.06%的cpp）：

思路：没什么好说，笨方法。。

```c++
class Solution {
public:
    bool isValidSudoku(vector<vector<char>>& board) {
        // verify row
        set<int> nums;
        for(int i = 0; i < 9; ++i){
            for(int j = 0; j < 9; ++j){
                if(board[i][j] != '.'){
                    if(nums.find(board[i][j]) == nums.end()){
                        nums.insert(board[i][j]);
                    }
                    else{
                        return false;
                    }
                }

            }
            nums.clear();
        }
        for(int i = 0; i < 9; ++i){
            for(int j = 0; j < 9; ++j){
                if(board[j][i] != '.'){
                    if(nums.find(board[j][i]) == nums.end()){
                        nums.insert(board[j][i]);
                    }
                    else{
                        return false;
                    }
                }

            }
            nums.clear();
        }
        for(int row = 0; row < 3; ++row){
            for(int col = 0; col < 3; ++col){
                for(int i = 0; i < 3; ++i){
                    for(int j = 0; j < 3; ++j){
                        if(board[i+row*3][j+col*3] != '.'){
                            if(nums.find(board[i+row*3][j+col*3]) == nums.end()){
                                nums.insert(board[i+row*3][j+col*3]);
                            }
                            else{
                                return false;
                            }
                        }

                    }
                }
            nums.clear();
            }

        }
        return true;
    }
};
```

##### 优化：

思路：上面的嵌套循环跑了三次，实际上只需要一次嵌套循环，但是需要三个辅助空间

```c++
class Solution {
public:
    bool isValidSudoku(vector<vector<char>>& board) {
        // record row
        vector<unordered_set<int>> row(9);
        // record column
        vector<unordered_set<int>> col(9);
        // record block
        vector<unordered_set<int>> block(9);
        // record index of row, column, block
        int r, c, b;
        for(int i = 0; i < 9; ++i){
            for(int j = 0; j < 9; ++j){
                if(board[i][j] != '.'){
                    if(row[i].find(board[i][j]) != row[i].end()){
                        return false;
                    }    
                    else{
                        row[i].insert(board[i][j]);
                    }
                    if(col[j].find(board[i][j]) != col[j].end()){
                        return false;
                    }    
                    else{
                        col[j].insert(board[i][j]);
                    }
                    b = i/3+3*(j/3);
                    if(block[b].find(board[i][j]) != block[b].end()){
                        return false;
                    }
                    else{
                        block[b].insert(board[i][j]);
                    }
                }
                
            }
        }
        return true;
    }
};
```

#### 48.旋转图像

给定一个 *n* × *n* 的二维矩阵表示一个图像。

将图像顺时针旋转 90 度。

**说明：**

你必须在**[原地](https://baike.baidu.com/item/原地算法)**旋转图像，这意味着你需要直接修改输入的二维矩阵。**请不要**使用另一个矩阵来旋转图像。

##### 第一次尝试，4ms（战胜96.21%的cpp）：

思路：因为需要原地旋转，所以要在矩阵内部交换元素，找规律发现：某点在顺时针旋转90°四次后会回到原点，于是可以从最外圈开始依次遍历，只需要n/2次即可：`for(int layer = 0; layer < n/2; ++layer)`，在圈数循环的内部，再嵌套一个循环，遍历当前圈的第一行（除开最后一个元素），判断条件为：` for(int j = layer; j < n-layer-1; ++j)`。

设A`(i', j'), B(i'', j''), C(i''', j'''), D(i'''', j'''')`四点为旋转后的点，满足以下关系：

`i' + j'' = n - 1`,  `i'' = j'`

`i'' + j''' = n - 1`,  `i''' = j''`

`i''' + j'''' = n - 1`,  `i'''' = j'''`

`i'''' + j' = n - 1`,  `i' = j'''`

代码就很清晰了，用一个长度为4的数组记录这几个点的值即可

```c++
class Solution {
public:
    void rotate(vector<vector<int>>& matrix) {
        int n = matrix.size();
        vector<int> arr;
        for(int layer = 0; layer < n/2; ++layer){
            for(int j = layer; j < n-layer-1; ++j){
                arr.clear();
                arr.push_back(matrix[layer][j]);
                arr.push_back(matrix[j][n-1-layer]);
                arr.push_back(matrix[n-1-layer][n-1-j]);
                arr.push_back(matrix[n-1-j][layer]);
                matrix[j][n-1-layer] = arr[0];
                matrix[n-1-layer][n-1-j] = arr[1];
                matrix[n-1-j][layer] = arr[2];
                matrix[layer][j] = arr[3];
            }
        }
    }
};
```

##### 先转置再翻转每一行，也是4ms：

思路：往右旋转90°，相当于矩阵先转置，再翻转每一行，注意循环的终止条件，时间复杂度O(N^2)，空间复杂度为O(1)

```c++
class Solution {
public:
    void rotate(vector<vector<int>>& matrix) {
        int n = matrix.size();
        for(int i = 0; i < n; ++i){
            for(int j = i; j < n; ++j){
                swap(matrix[i][j], matrix[j][i]);
            }
        }
        for(int i = 0; i < n; ++i){
            for(int j = 0; j < n/2; ++j){
                swap(matrix[i][j], matrix[i][n-1-j]);
            }
        }
    }
};
```

---

## 字符串

#### 344.反转字符串

编写一个函数，其作用是将输入的字符串反转过来。输入字符串以字符数组 `char[]` 的形式给出。

不要给另外的数组分配额外的空间，你必须**[原地](https://baike.baidu.com/item/原地算法)修改输入数组**、使用 O (1) 的额外空间解决这一问题。

你可以假设数组中的所有字符都是 [ASCII](https://baike.baidu.com/item/ASCII) 码表中的可打印字符。

##### 第一次尝试，100ms（战胜24.9%的cpp）：

思路：循环前半个数组，与后半个数组依次交换

```c++
class Solution {
public:
    void reverseString(vector<char>& s) {
        for(int i = 0; i < s.size()/2; ++i){
            swap(s[i], s[s.size()-1-i]);
        }
    }
};
```

##### 优化，手写swap，48ms（战胜99.03%的cpp）：

```c++
class Solution {
public:
    void reverseString(vector<char>& s) {
        int temp;
        for(int i = 0; i < s.size()/2; ++i){
            temp = s[i]; 
            s[i] = s[s.size()-1-i];
            s[s.size()-1-i] = temp;
        }
    }
};
```

#### 7.整数反转

给出一个 32 位的有符号整数，你需要将这个整数中每位上的数字进行反转。

**注意:**

假设我们的环境只能存储得下 32 位的有符号整数，则其数值范围为 [−2^31, 2^31 − 1]。请根据这个假设，如果反转后整数溢出那么就返回 0。

##### 又快又好的解法：

思路：循环，从个位开始，每次循环获得当前位数上的数，加到扩大十倍的answer中，这样可以翻转数字（高位变低位、低位变高位），然后每次除以10取整，可以得到x中更高的位数，这种做法不用考虑正负数，注意用到了INT_MAX、INT_MIN这两个常量

```c++
class Solution {
public:
    int reverse(int x) {
        long long answer = 0;
        while(x != 0){
            answer = answer * 10 + x % 10;
            x /= 10;
        }
        if(answer > INT_MAX || answer < INT_MIN){
            return 0;
        }
        return answer;
    }
};
```

拓展：

INT_MIN 在标准头文件 limits.h 中定义。

```c++
define INT_MAX 2147483647
define INT_MIN (-INT_MAX - 1)
```

在 C/C++ 语言中，**不能够直接使用 - 2147483648（−2^31） 来代替最小负数，因为这不是一个数字，而是一个表达式**。表达式的意思是对整数 21473648 取负，但是 2147483648 已经溢出了 int 的上限，所以定义为（-INT_MAX -1）。

C 中 int 类型是 32 位的，范围是 - 2147483648（−2^31） 到 2147483647（2^31−1）。 
（1）最轻微的上溢是 INT_MAX + 1 : 结果是 INT_MIN; 
（2）最严重的上溢是 INT_MAX + INT_MAX : 结果是 - 2; 
（3）最轻微的下溢是 INT_MIN - 1: 结果是是 INT_MAX; 
（4）最严重的下溢是 INT_MIN + INT_MIN: 结果是 0 。

#### 387.字符串中的第一个唯一字符

给定一个字符串，找到它的第一个不重复的字符，并返回它的索引。如果不存在，则返回 -1。
**注意事项：**您可以假定该字符串只包含小写字母。

**案例:**

```
s = "leetcode"
返回 0.

s = "loveleetcode",
返回 2.
```

##### 第一次尝试，60ms（战胜57.72%cpp）：

思路：利用map，映射字符与它出现次数，第一次遍历建立map，第二次遍历从头开始判断每个字符的出现次数是否为1，非常直观的解法

时间复杂度： O(N)，只遍历了两遍字符串，同时散列表中查找操作是常数时间复杂度的。

空间复杂度： O(N)，用到了散列表来存储字符串中每个元素出现的次数。

 ```c++
class Solution {
public:
    int firstUniqChar(string s) {
        unordered_map<char, int> hash;
        for(int i = 0; i < s.size(); ++i){
            ++hash[s[i]];
        }
        for(int i = 0; i < s.size(); ++i){
            if(hash[s[i]] == 1){
                return i;
            }
        }
        return -1;
    }
};
 ```

##### 优化，用大小为256的数组来代替map：

思路：思路大致一样，用到了题干的提示：您可以假定该字符串只包含小写字母。

```c++
class Solution {
public:
    int firstUniqChar(string s) {
        int arr[26] = {0};
        for(int i = 0; i < s.size(); ++i){
            ++arr[s[i] - 'a'];
        }
        for(int i = 0; i < s.size(); ++i){
            if(arr[s[i] - 'a'] == 1){
                return i;
            }
        }
        return -1;
    }
};
```

#### 242.有效的字母异位词

给定两个字符串 *s* 和 *t* ，编写一个函数来判断 *t* 是否是 *s* 的字母异位词。

**示例 1:**

```
输入: s = "anagram", t = "nagaram"
输出: true
```

**示例 2:**

```
输入: s = "rat", t = "car"
输出: false
```

**说明:**
你可以假设字符串只包含小写字母。

**进阶:**
如果输入字符串包含 unicode 字符怎么办？你能否调整你的解法来应对这种情况？ 

##### 第一次尝试，12ms（战胜84.76%的cpp）：

思路：假设字符串只包含小写字母，时空最快的方式是用大小为26的数组记录26个字母的出现次数，遍历第一个字符串时递增，遍历第二个字符串时递减，如果最后这个数组全为0，则说明真

时间复杂度：O(n)。时间复杂度为 O(n) 因为访问计数器表是一个固定的时间操作。
空间复杂度：O(1)。尽管我们使用了额外的空间，但是空间的复杂性是 O(1)，因为无论 N 有多大，表的大小都保持不变。

```c++
class Solution {
public:
    bool isAnagram(string s, string t) {
        if(s.size() != t.size()){
            return false;
        }
        int alphabet[26] = {0};
        for(auto &ch : s){
            ++alphabet[ch-'a'];
        }
        for(auto &ch : t){
            --alphabet[ch-'a'];
        }
        for(int i = 0; i < 26; ++i){
            if(alphabet[i] != 0){
                return false;
            }
        }
        return true;
    }
};
```

##### 进阶，如果包含unicode字符：

思路：使用哈希表（c++中用unordered_map）而不是固定大小的计数器。想象一下，分配一个大的数组来适应整个 Unicode 字符范围，这个范围可能超过 100 万。哈希表是一种更通用的解决方案，可以适应任何字符范围。

#### 125.验证回文字符串

给定一个字符串，验证它是否是回文串，只考虑字母和数字字符，可以忽略字母的大小写。

**说明：**本题中，我们将空字符串定义为有效的回文串。

**示例 1:**

```
输入: "A man, a plan, a canal: Panama"
输出: true
```

**示例 2:**

```
输入: "race a car"
输出: false
```

##### 第一次尝试， 12ms（战胜61.38%的cpp）：

思路：两个指针，一个从头往尾扫，一个从尾往头扫，每次记得判断是否是数字或字母，如果扫到的两个值不相等，则不是回文串，注意一下两个指针交叉时的一些特殊处理

```c++
class Solution {
public:
    bool isPalindrome(string s) {
        if(s.empty() || s.size() == 1) return true;
        int low = 0, high = s.size()-1;
        while(low <= high){
            while(!isNumOrLetter(s[low]) && low < high){
                ++low;
            }
            while(!isNumOrLetter(s[high]) && low < high){
                --high;
            }
            if(low >= high){
                return true;
            }
            if(tolower(s[low]) != tolower(s[high])){
                return false;
            }
            ++low;
            --high;
        }
        return true;
    }
private:
    bool isNumOrLetter(char ch){
        if('a' <= ch && ch <= 'z'){
            return true;
        }
        if('A' <= ch && ch <= 'Z'){
            return true;
        }
        if('0' <= ch && ch <= '9'){
            return true;
        }
        return false;
    }
};
```

##### 优化，用isalnum这个标准库函数代替手写的isNumOrLetter函数：

```c++
class Solution {
public:
    bool isPalindrome(string s) {
        // 双指针
		if (s.size() <= 1) return true;
		int i = 0, j = s.size() - 1;
		while (i < j) {
			while (i < j && !isalnum(s[i])) // 排除所有非字母或数字的字符
				i++;
			while (i < j && !isalnum(s[j]))
				j--;
			if (tolower(s[i++]) != tolower(s[j--])) //统一转换成小写字母再比较
				return false;
		}
		return true;
    }
};
```

#### 8.字符串转换整数 (atoi)

请你来实现一个 `atoi` 函数，使其能将字符串转换成整数。

首先，该函数会根据需要丢弃无用的开头空格字符，直到寻找到第一个非空格的字符为止。

当我们寻找到的第一个非空字符为正或者负号时，则将该符号与之后面尽可能多的连续数字组合起来，作为该整数的正负号；假如第一个非空字符是数字，则直接将其与之后连续的数字字符组合起来，形成整数。

该字符串除了有效的整数部分之后也可能会存在多余的字符，这些字符可以被忽略，它们对于函数不应该造成影响。

注意：假如该字符串中的第一个非空格字符不是一个有效整数字符、字符串为空或字符串仅包含空白字符时，则你的函数不需要进行转换。

在任何情况下，若函数不能进行有效的转换时，请返回 0。

**说明：**

假设我们的环境只能存储 32 位大小的有符号整数，那么其数值范围为 [−231, 231 − 1]。如果数值超过这个范围，请返回  INT_MAX (231 − 1) 或 INT_MIN (−231) 。 

**示例 1:**

```
输入: "42"
输出: 42
```

**示例 2:**

```
输入: "   -42"
输出: -42
解释: 第一个非空白字符为 '-', 它是一个负号。
     我们尽可能将负号与后面所有连续出现的数字组合起来，最后得到 -42 。
```

**示例 3:**

```
输入: "4193 with words"
输出: 4193
解释: 转换截止于数字 '3' ，因为它的下一个字符不为数字。
```

**示例 4:**

```
输入: "words and 987"
输出: 0
解释: 第一个非空字符是 'w', 但它不是数字或正、负号。
     因此无法执行有效的转换。
```

**示例 5:**

```
输入: "-91283472332"
输出: -2147483648
解释: 数字 "-91283472332" 超过 32 位有符号整数范围。 
     因此返回 INT_MIN (−231) 。
```

##### 第一次尝试，0ms（战胜100%的cpp）：

思路：只需要一次遍历，首先是firstSearch找到首个不为空的字符，若无效则直接返回0，若为正负号则记录下来，若为数字则直接赋给answer（此时answer为空），然后继续遍历，若为数字则加到扩大了十倍的answer的后面，若无效则直接返回0，最后判断INT_MIN、INT_MAX的关系即可

```c++
class Solution {
public:
    int myAtoi(string str) {
        int i = 0;
        bool searchFirst = true;
        bool answerSign = true; 
        long long answer = 0;
        while(i < str.size()){
            if(searchFirst){
                if(str[i] == ' '){
                    ++i;
                    continue;
                }
                if(!isdigit(str[i]) && str[i] != '+' && str[i] != '-'){
                    return 0;
                }
                if(str[i] == '+'){
                    answerSign = true;
                }
                if(str[i] == '-'){
                    answerSign = false;
                }
                if(isdigit(str[i])){
                    answer = str[i] - '0';
                }
                searchFirst = false;    // complete first search
                ++i;
                continue;
            }
            if(!isdigit(str[i]) || answer > INT_MAX){
                break;
            }
            answer = answer * 10 + (str[i] - '0');
            ++i;
        }
        if(!answerSign){
            answer = -answer;
        }            
        if(answer < INT_MIN){
            return INT_MIN;
        } 
        if(answer > INT_MAX){
            return INT_MAX;
        }
        return answer;
    }
};
```

##### 相同思路但更为简洁的代码：

```c++
class Solution {
public:
    int myAtoi(string str) {
        int res=0,i=0,flag=1;
        while(str[i]==' ') i++;
        if(str[i]=='-') flag=0;
        if(str[i]=='+'||str[i]=='-') i++;
        while(i<str.length()&&isdigit(str[i])){
            int r=str[i]-'0';
            if(res>INT_MAX/10||(res==INT_MAX/10&&r>7)){
                return flag?INT_MAX:INT_MIN;
            }
            res=res*10+r;
            i++;
        }
        return flag?res:-res;
    }
};
```

#### 28.实现 strStr ()

实现 [strStr()](https://baike.baidu.com/item/strstr/811469) 函数。

给定一个 haystack 字符串和一个 needle 字符串，在 haystack 字符串中找出 needle 字符串出现的第一个位置 (从 0 开始)。如果不存在，则返回 **-1**。

**示例 1:**

```
输入: haystack = "hello", needle = "ll"
输出: 2
```

**示例 2:**

```
输入: haystack = "aaaaa", needle = "bba"
输出: -1
```

**说明:**

当 `needle` 是空字符串时，我们应当返回什么值呢？这是一个在面试中很好的问题。

对于本题而言，当 `needle` 是空字符串时我们应当返回 0 。这与 C 语言的 [strstr()](https://baike.baidu.com/item/strstr/811469) 以及 Java 的 [indexOf()](https://docs.oracle.com/javase/7/docs/api/java/lang/String.html#indexOf(java.lang.String)) 定义相符。 

##### 第一次尝试，4ms（战胜93.79%cpp）：

思路：两个指针，第一个指针i从头到尾遍历haystack，第二个指针j遍历needle，当发现有不同时，不能仅让j归零，应该先让i回退j-1步（如果i>j-1的话，否则不回退），再让j为0，如果最后发现剩余的haystack都不够塞满needle，果断返回-1

时间复杂度： O(M*N)，类似于BF（Brute Force）算法

特点：非常直观，但其实效率不高（时间少可能是因为正好迎合了测试用例），有点类似暴力匹配的感觉

```c++
class Solution {
public:
    int strStr(string haystack, string needle) {
        if(needle.empty()) return 0;
        if(haystack.size() < needle.size()) return -1;
        int i = 0, j = 0;
        while(i < haystack.size()){
            while(haystack[i] != needle[j] && i < haystack.size()) ++i;
            while(haystack[i] == needle[j]){
                if(j == needle.size() - 1){
                    return i-j;
                }
                ++i; 
                ++j;
            }
            // go back to the place where it is the place right after the previous match
            if(i > j - 1){      
                i -= j - 1;
            }
            if(i > haystack.size() - needle.size()){
                return -1;
            }
            j = 0;
        }
        return -1;
    }
};
```

##### 字符串匹配算法 ——KMP算法：

思路：KMP 算法是一种字符串匹配算法，由 D.E.Knuth，J.H.Morris 和 V.R.Pratt 提出的，因此人们称它为克努特 — 莫里斯 — 普拉特算法（简称 KMP 算法）。在暴力匹配中，我们在 txt 中从 i 开始与 pattern 串匹配至 i + pattern.length()，一旦匹配失败，则从 i + 1 子串重新匹配。此时我们抛弃了前面的匹配信息。

而 KMP 算法目的就是：在出错时，**利用原有的匹配信息**，尽量减少重新匹配的次数。 可以发现 KMP 算法的主串下标**永不后退** 

时间复杂度：O(M+N) 

缺陷：现实中，中间内容与前缀相同的单词、词汇并不多见，而长句更是除了排比句之外就很少见了，因此，在花费时间空间生成了有限状态机之后，很有可能会出现一直都是重置状态而很少降价状态的情况出现。对于长句而言，状态机所占用的空间是巨大的，而并不高效，相反纯暴力解法对于短 pattern 串。而言，总体运行时间却并不比它慢

参考连接： [http://www.ruanyifeng.com/blog/2013/05/Knuth%E2%80%93Morris%E2%80%93Pratt_algorithm.html](http://www.ruanyifeng.com/blog/2013/05/Knuth–Morris–Pratt_algorithm.html) 

##### 字符串匹配算法——BM算法：

时间复杂度：最差与KMP算法一样O(M+N)，最好是O(N)

参考链接： http://www.ruanyifeng.com/blog/2013/05/boyer-moore_string_search_algorithm.html 

##### 字符串匹配算法——Sunday算法：

最坏情况：O(nm)
平均情况：O(n)

#### 38.报数

报数序列是一个整数序列，按照其中的整数的顺序进行报数，得到下一个数。其前五项如下：

```
1.     1
2.     11
3.     21
4.     1211
5.     111221
```

`1` 被读作 `"one 1"` (`"一个一"`) , 即 `11`。
`11` 被读作 `"two 1s"` (`"两个一"`）, 即 `21`。
`21` 被读作 `"one 2"`,  "`one 1"` （`"一个二"` , `"一个一"`) , 即 `1211`。

给定一个正整数 *n*（1 ≤ *n* ≤ 30），输出报数序列的第 *n* 项。

注意：整数顺序将表示为一个字符串。

**示例 1:**

```
输入: 1
输出: "1"
```

**示例 2:**

```
输入: 4
输出: "1211"
```

##### 第一次尝试，4ms（战胜91.49%的cpp）：

思路：首先要看懂题目，其实是把报数序列看作字符串，从头开始遍历，寻找重复子串，记录下来，循环n-1次，思路很清晰，但是很容易出错，要非常细致，用时1h

```c++
class Solution {
public:
    string countAndSay(int n) {
        if(n == 1) return "1";
        string s = {"1"};
        string s_new = {"1"};
        int i = 0;
        char pre = ' ';
        int count = 1;
        while(i < n - 1){
            pre = s[0];
            if(s.size() == 1){
                s_new.append("1");
            }
            for(int j = 1; j < s.size(); ++j){
                if(pre == s[j]){
                    ++count;
                    if(j == s.size() - 1){
                        s_new.append(to_string(count));
                        s_new.append(string(1, pre)); // convert single char to string
                        count = 1;
                    }
                }
                else{
                    s_new.append(to_string(count));
                    s_new.append(string(1, pre)); // convert single char to string
                    pre = s[j];
                    count = 1;
                    if(j == s.size() - 1){
                        s_new.append(to_string(count));
                        s_new.append(string(1, pre)); // convert single char to string
                    }
                }
            }
            i++;
            s = s_new;
            s_new = {""};
        }
        return s;
    }
};
```

##### 优化一下代码：

思路：for循环里的if-else都用append操作，可以提取出来放在for循环下面，再优化一下s.size()==1时的情景

```c++
class Solution {
public:
    string countAndSay(int n) {
        if(n == 1) return "1";
        string s = "1";
        string s_new;
        int i = 0;
        char pre = ' ';
        int count = 1;
        while(i < n - 1){
            s_new = "";
            pre = s[0];
            count = 1;            
            for(int j = 1; j < s.size(); ++j){
                if(pre == s[j]){
                    ++count;
                }
                else{
                    s_new.append(to_string(count));
                    s_new.append(string(1, pre)); // convert single char to string
                    pre = s[j];
                    count = 1;
                }
            }
            s_new.append(to_string(count));
            s_new.append(string(1, pre)); // convert single char to string
            s = s_new;
            i++;            
        }
        return s;
    }
};
```

##### 递归解法：

思路：可以看到，每次循环都是以上一次字符串为输入的，所以很容易构造递归函数

#### 14.最长公共前缀

编写一个函数来查找字符串数组中的最长公共前缀。

如果不存在公共前缀，返回空字符串 `""`。

**示例 1:**

```
输入: ["flower","flow","flight"]
输出: "fl"
```

**示例 2:**

```
输入: ["dog","racecar","car"]
输出: ""
解释: 输入不存在公共前缀。
```

**说明:**

所有输入只包含小写字母 `a-z` 。

##### 第一次尝试， 8ms（战胜71.83%的cpp）：

思路：大循环，里面用一个指针扫过各字符串同样位置的值，如果都相等，则指针递增，直至有异样或者到达某字符串结尾

时间复杂度：O(S)，S 是所有字符串中字符数量的总和。最坏的情况下，n 个字符串都是相同的。

空间复杂度：O(1)，我们只需要使用常数级别的额外空间。

```c++
class Solution {
public:
    string longestCommonPrefix(vector<string>& strs) {
        if(strs.empty()){
            return "";
        }
        int n = strs.size();
        if(n == 1){
            return strs[0];
        }
        for(int i = 0; i < n; ++i){
            if(strs[i].size() == 0){
                return "";
            }
        }
        int pointer = 0;
        char ch;
        string res = "";
        while(true){
            ch = strs[0][pointer];
            for(int i = 1; i < n; ++i){
                if(pointer == strs[i].size()){
                    return res;
                }
                if(strs[i][pointer] != ch){
                    return res;
                }
                else{
                    ch = strs[i][pointer];
                }
            }
            res += ch;
            ++pointer;
        }
        return "";
    }
};
```

---

## 链表

#### 237.删除链表中的节点

请编写一个函数，使其可以删除某个链表中给定的（非末尾）节点，你将只被给定要求被删除的节点。

现有一个链表 -- head = [4,5,1,9]，它可以表示为:

![img](https://assets.leetcode-cn.com/aliyun-lc-upload/uploads/2019/01/19/237_example.png)

 

**示例 1:**

```
输入: head = [4,5,1,9], node = 5
输出: [4,1,9]
解释: 给定你链表中值为 5 的第二个节点，那么在调用了你的函数之后，该链表应变为 4 -> 1 -> 9.
```

**示例 2:**

```
输入: head = [4,5,1,9], node = 1
输出: [4,5,9]
解释: 给定你链表中值为 1 的第三个节点，那么在调用了你的函数之后，该链表应变为 4 -> 5 -> 9.
```

**说明:**

- 链表至少包含两个节点。
- 链表中所有节点的值都是唯一的。
- 给定的节点为非末尾节点并且一定是链表中的一个有效节点。
- 不要从你的函数中返回任何结果。

##### 唯一解：

思路：因为函数的输入只有待删除的节点，根本没法从头遍历，但是要删除这个节点，不一定要实实在在地释放这个这个节点的内存，可以这样做：把它的后继节点的值赋值给它，再把它的后继节点删除，这样看上去就像是没有这个节点了。这种方法只能适用于待删除节点是链表的中间节点，而题目已经说了待删除节点肯定不是尾节点。

 时间和空间复杂度都是：O(1)

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    void deleteNode(ListNode* node) {
        node->val = node->next->val;
        node->next = node->next->next;
    }
};
```

优化，释放内存：

```c++
        ListNode *delNode = node->next;
        node->val = delNode->val;
        node->next = delNode->next;
        delete delNode;
```

#### 19.删除链表的倒数第 N 个节点

给定一个链表，删除链表的倒数第 *n* 个节点，并且返回链表的头结点。

**示例：**

```
给定一个链表: 1->2->3->4->5, 和 n = 2.

当删除了倒数第二个节点后，链表变为 1->2->3->5.
```

**说明：**

给定的 *n* 保证是有效的。

**进阶：**

你能尝试使用一趟扫描实现吗？ 

##### 第一次尝试，用相同长度的向量记录，一遍扫描：

思路：从头到尾扫描链表，每次扫描把节点添加到向量里面，最后就是找到待删除节点的前驱节点，使其后继节点为待删除节点的后继节点，注意几个特殊情况：待删除节点为头/尾节点，链表长度为1等等

空间复杂度为O(n)，时间复杂度为O(n)，明显可以在空间上改进

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    ListNode* removeNthFromEnd(ListNode* head, int n) {
        if(head->next == NULL){
            return NULL;
        }
        vector<ListNode*> node_list = {head};
        ListNode* node = head;
        while(node->next != NULL){
            node = node->next;
            node_list.push_back(node);
        }
        if(n == 1){
            node_list[node_list.size()-2]->next = NULL;
            return head;
        }
        if(n == node_list.size()){
            return head->next;
        }
        node_list[node_list.size()-1-n]->next = node_list[node_list.size()-1-n]->next->next;
        return head;
    }
};
```

##### 空间复杂度为O(1)的一遍扫描：

思路：两个指针，第一个指针首先从头开始移动n+1步，然后两个指针一起出发，这两个指针中间恰好隔了n个节点，当第一个指针到达空节点时，第二个指针到达从最后一个节点起数的第n个节点，这时候重新链接即可

空间复杂度为O(n)，时间复杂度为O(n)，非常妙！

这里还用到了**哑节点（dummy node）**， 该节点位于列表头部，指向原本的head。哑结点用来简化某些极端情况，例如列表中只含有一个节点，或需要删除列表的头部。 

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    ListNode* removeNthFromEnd(ListNode* head, int n) {
        if(head->next == NULL){
            return NULL;
        }
        ListNode *dummy = new ListNode(0);
        dummy->next = head;
        ListNode *first = dummy;
        ListNode *second = dummy;
        int step = 0;
        while(step < n+1){
            first = first->next;
            ++step;
        }
        while(first != NULL){
            first = first->next;
            second = second->next;
        }
        second->next = second->next->next;
        return dummy->next;  // error occurs if return head when delete head
    }
};
```

#### 206.反转链表

反转一个单链表。

**示例:**

```
输入: 1->2->3->4->5->NULL
输出: 5->4->3->2->1->NULL
```

**进阶:**
你可以迭代或递归地反转链表。你能否用两种方法解决这道题？

##### 迭代，第一次尝试，8ms（战胜97.44%的cpp）：

思路：迭代，当前迭代的后面个节点都需要记录下来，注意一下首尾特殊情况

- 时间复杂度：O(n)，假设 n是列表的长度，时间复杂度是 O(n)。
- 空间复杂度：O(1)。

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    ListNode* reverseList(ListNode* head) {
        if(head == NULL || head->next == NULL){
            return head;
        }
        ListNode *temp, *afterTemp = head->next, *node = head;
        while(afterTemp->next != NULL){
            temp = afterTemp;
            afterTemp = temp->next;
            temp->next = node;
            if(node == head){
                node->next = NULL;
            }
            node = temp;
        }
        if(node == head){
            node->next = NULL;
        }
        afterTemp->next = node;
        return afterTemp;
    }
};
```

##### 迭代，代码优化，效率差不多：

思路：在遍历列表时，将当前节点的 next 指针改为指向前一个元素。由于节点没有引用其上一个节点，因此必须事先存储其前一个元素。在更改引用之前，还需要另一个指针来存储下一个节点。不要忘记在最后返回新的头引用。

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    ListNode* reverseList(ListNode* head) {
        if(head == NULL || head->next == NULL){
            return head;
        }
        ListNode *temp, *prev = NULL, *curr = head;
        while(curr != NULL){
            temp = curr->next;
            curr->next = prev;
            prev = curr;
            curr = temp;
        }
        return prev;
    }
};
```

##### 递归：

思路：关键在于反向工作。

假设链表为：n1->n2->...nk-1->nk->nk+1->...->nm->NULL

假设已经翻转到nk+1了：n1->n2->...nk-1->nk->nk+1<-...<-nm

下一步是要让nk+1指向nk，即

```c++
nk->next->next = nk;
```

从head开始，首先递归至末尾，然后跳出一层递归，往头部移动，再跳出一层，再往头部移动

时间复杂度：O(n)，假设 n 是列表的长度，那么时间复杂度为 O(n)。
空间复杂度：O(n)，由于使用递归，将会使用隐式栈空间。递归深度可能会达到 n 层。

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    ListNode* reverseList(ListNode* head) {
      	// cout << "head->val: " << head->val << endl;
        if(head == NULL || head->next == NULL){
            return head;
        }
        ListNode *p = reverseList(head->next);
      	// cout << "p->val: " << p->val << endl;
        head->next->next = head;
        head->next = NULL;  // ensure original head->next is NULL
        return p;
    }
};
```

为了方便理解，控制台输出head->val、p->val，结果如下，输入链表为[1,2,3,4,5]：

```
head->val: 1
head->val: 2
head->val: 3
head->val: 4
head->val: 5
p->val: 5
p->val: 5
p->val: 5
p->val: 5
```

可以看到，首先递归到最深层，也就是链表末尾5，依次往前翻转，注意到p的值不变，最后跳出递归时的返回值p即为新的头节点

#### 21.合并两个有序链表

将两个有序链表合并为一个新的有序链表并返回。新链表是通过拼接给定的两个链表的所有节点组成的。 

**示例：**

```
输入：1->2->4, 1->3->4
输出：1->1->2->3->4->4
```

##### 第一次尝试，16ms（战胜42.6%的cpp）：

思路：构造一个哑节点，其后慢慢延伸合并后的结果，遍历，每次比较l1与l2的大小，令当前节点的后继节点为其中较小值的节点，然后当前节点就变成了较小值节点，较小值节点后移，非常直观

时间复杂度：O(n + m) 。因为每次循环迭代中，l1 和 l2 只有一个元素会被放进合并链表中， while 循环的次数等于两个链表的总长度。所有其他工作都是常数级别的，所以总的时间复杂度是线性的。

空间复杂度：O(1) 。迭代的过程只会产生几个指针，所以它所需要的空间是常数级别的。

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    ListNode* mergeTwoLists(ListNode* l1, ListNode* l2) {
        if(l1 == NULL) return l2;
        if(l2 == NULL) return l1;
        ListNode *dummy = new ListNode(0), *curr = dummy;
        while(l1 != NULL && l2 != NULL){
            if(l1->val <= l2->val){
                curr->next = l1;
                curr = l1;
                l1 = l1->next;
            }
            else{
                curr->next = l2;
                curr = l2;
                l2 = l2->next;
            }
        }
        curr->next = (l1 != NULL) ? l1 : l2; 
        return dummy->next;
    }
};
```

##### 迭代解法：

思路：

list1[0] + merge(list1[1:], list2),     if list1[0] < list2[0]

list2[0] + merge(list1, list2[1:]),	otherwise

也就是说，两个链表头部较小的一个与剩下元素的 `merge` 操作结果合并。

我们直接将以上递归过程建模，首先考虑边界情况。
特殊的，如果 l1 或者 l2 一开始就是 null ，那么没有任何操作需要合并，所以我们只需要返回非空链表。否则，我们要判断 l1 和 l2 哪一个的头元素更小，然后递归地决定下一个添加到结果里的值。如果两个链表都是空的，那么过程终止，所以递归过程最终一定会终止。

时间复杂度：O(n + m)。 因为每次调用递归都会去掉 l1 或者 l2 的头元素（直到至少有一个链表为空），函数 mergeTwoList 中只会遍历每个元素一次。所以，时间复杂度与合并后的链表长度为线性关系。

空间复杂度：O(n + m)。调用 mergeTwoLists 退出时 l1 和 l2 中每个元素都一定已经被遍历过了，所以 n + m 个栈帧会消耗 O(n + m)的空间。

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    ListNode* mergeTwoLists(ListNode* l1, ListNode* l2) {
        if(l1 == NULL) return l2;
        if(l2 == NULL) return l1;
        if(l1->val < l2->val){
            l1->next = mergeTwoLists(l1->next, l2);
            return l1;
        }
        else{
            l2->next = mergeTwoLists(l1, l2->next);
            return l2;
        }
    }
};
```

#### 234.回文链表

请判断一个链表是否为回文链表。

**示例 1:**

```
输入: 1->2
输出: false
```

**示例 2:**

```
输入: 1->2->2->1
输出: true
```

**进阶：**
你能否用 O (n) 时间复杂度和 O (1) 空间复杂度解决此题？

##### 第一次尝试，O(n)时间，O(n)空间：

思路：先遍历整个链表，把值存储到一个向量中，再用指针判断向量内首尾是否相等

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    bool isPalindrome(ListNode* head) {
        if(head == NULL) return true;
        vector<int> nums;
        ListNode *curr = head;
        while(curr != NULL){
            nums.push_back(curr->val);
            curr = curr->next; 
        }
        for(int i = 0; i < nums.size()/2; ++i){
            if(nums[i] != nums[nums.size()-1-i]){
                return false;
            }
        }
        return true;
    }
};
```

##### 优化，O(n)时间，O(1)空间：

思路：维持快慢两个指针，快指针是慢指针的两倍，当快指针到达末尾时，慢指针即到达重点。在慢指针步进的每一步中，翻转链表。最后比较前半个链表和后半个链表是否相等即可。

注意：

1. 翻转链表时用到了前驱节点与前驱前驱节点，因为当前节点不能改变next，否则就取不到下一个了，只能更改前驱节点的next
2. 跳出第一个while循环时，当前的slow节点还未翻转，得与pre翻转，然后p2指向后半链表的头节点，然后看此时fast是否为NULL，这里其实就是判断链表是奇数还是偶数，所以p1指向翻转后的前半链表的头节点
3. 最后同时递增p1、p2，依次比较

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    bool isPalindrome(ListNode* head) {
        if(head == NULL) return true;
        ListNode *slow = head, *fast = head->next, *pre = NULL, *prepre = NULL;
        while(fast != NULL && fast->next != NULL){
            fast = fast->next->next;
            pre = slow;
            slow = slow->next;
            pre->next = prepre;
            prepre = pre;
        }
        ListNode *p2 = slow->next;
        slow->next = pre;
        ListNode *p1 = (fast == NULL ? slow->next : slow);
        while(p1 != NULL){
            if(p1->val != p2->val){
                return false;
            }
            p1 = p1->next;
            p2 = p2->next;
        }
        return true;
    }
};
```

#### 141.环形链表

给定一个链表，判断链表中是否有环。

为了表示给定链表中的环，我们使用整数 `pos` 来表示链表尾连接到链表中的位置（索引从 0 开始）。 如果 `pos` 是 `-1`，则在该链表中没有环。

 

**示例 1：**

```
输入：head = [3,2,0,-4], pos = 1
输出：true
解释：链表中有一个环，其尾部连接到第二个节点。
```

![img](https://assets.leetcode-cn.com/aliyun-lc-upload/uploads/2018/12/07/circularlinkedlist.png)

**示例 2：**

```
输入：head = [1,2], pos = 0
输出：true
解释：链表中有一个环，其尾部连接到第一个节点。
```

![img](https://assets.leetcode-cn.com/aliyun-lc-upload/uploads/2018/12/07/circularlinkedlist_test2.png)

**示例 3：**

```
输入：head = [1], pos = -1
输出：false
解释：链表中没有环。
```

![img](https://assets.leetcode-cn.com/aliyun-lc-upload/uploads/2018/12/07/circularlinkedlist_test3.png)

 

**进阶：**

你能用 *O(1)*（即，常量）内存解决此问题吗？ 

##### 第一次尝试，哈希表：

思路：建立一个哈希表，节点内存地址 映射到 是否已访问的标志，遍历所有节点，如果当前节点为空则没有环返回false，如果当前节点访问过则有环返回true

空间复杂度：很明显用到了一个哈希表，O(n)

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    bool hasCycle(ListNode *head) {
        if(head == NULL || head->next == NULL) return false;
        unordered_set<ListNode*> hash = {head};  
        ListNode *curr = head;
        while(curr != NULL){
            curr = curr->next;
            if(hash.find(curr) != hash.end()){
                return true;
            }
            else{
                hash.insert(curr);
            }
        }
        return false;
    }
};
```



##### 空间复杂度为O(1)的双指针解法：

思路：快慢指针，快指针速度是慢指针速度的两倍，如果快指针指向了NULL，则没有环返回false，如果快指针慢指针相等，则说明有环返回true

想像一下两个速度不一样的运动员在操场上跑圈，操场是有环的，所以两者肯定会相遇，这就是这种解法的思想

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    bool hasCycle(ListNode *head) {
        if(head == NULL || head->next == NULL) return false;
        ListNode *slow = head, *fast = head->next;
        while(fast != NULL && fast->next != NULL){
            slow = slow->next;
            fast = fast->next->next;
            if(slow == fast){
                return true;
            }
        }
        return false;
    }
};
```

---

## 树

#### 104.二叉树的最大深度

给定一个二叉树，找出其最大深度。

二叉树的深度为根节点到最远叶子节点的最长路径上的节点数。

**说明:** 叶子节点是指没有子节点的节点。

**示例：**
给定二叉树 `[3,9,20,null,null,15,7]`，

```
    3
   / \
  9  20
    /  \
   15   7
```

返回它的最大深度 3 。

##### 第一次尝试，递归，前序遍历：

思路：前序遍历其实是深度优先搜索（DFS）的一种实现，前序遍历的思想很直观，迭代，从根节点出发，获取当前值，继续遍历左子树，左边遍历完之后，遍历右子树，用递归来做二叉树的遍历是非常清晰的，下面是c语言描述的前序遍历

```c
void pre_order(TreeNode * Node)
{
    if(Node != NULL)
    {
        printf("%d ", Node->data);
        pre_order(Node->left);
        pre_order(Node->right);
    }
```

在本题中，为了获取最大深度，递归函数的参数与返回值就得携带当前的深度信息，因为递归越深，二叉树越深，所以用depth来指示当前深度

```c++
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode(int x) : val(x), left(NULL), right(NULL) {}
 * };
 */
class Solution {
public:
    int maxDepth(TreeNode* root) {
        if(root == nullptr) return 0;
        return preOrderSearch(root, 0);
    }
    int preOrderSearch(TreeNode* root, int depth){
        if(root == nullptr) return depth;
        ++depth;
        int leftDepth = preOrderSearch(root->left, depth);
        int rightDepth = preOrderSearch(root->right, depth);
        return leftDepth > rightDepth ? leftDepth : rightDepth;
    }
};
```

##### 代码优化：

思路：递归函数不需要参数，直接把maxDepth作为递归函数即可

```c++
class Solution {
public:
    int maxDepth(TreeNode* root) {
        if(root == nullptr) return 0;
        int leftDepth = maxDepth(root->left);
        int rightDepth = maxDepth(root->right);
        return 1 + (leftDepth > rightDepth ? leftDepth : rightDepth);
    }
};
```

##### 这题还可以用非递归的DFS解决，但需要栈这种数据结构，也可以使用广度优先搜索（BFS），但需要队列这种数据结构

#### 98.验证二叉搜索树

给定一个二叉树，判断其是否是一个有效的二叉搜索树。

假设一个二叉搜索树具有如下特征：

- 节点的左子树只包含**小于**当前节点的数。
- 节点的右子树只包含**大于**当前节点的数。
- 所有左子树和右子树自身必须也是二叉搜索树。

**示例 1:**

```
输入:
    2
   / \
  1   3
输出: true
```

**示例 2:**

```
输入:
    5
   / \
  1   4
     / \
    3   6
输出: false
解释: 输入为: [5,1,4,null,null,3,6]。
     根节点的值为 5 ，但是其右子节点值为 4 。
```

##### 第一次尝试，递归函数传入哈希表：

思路：

首先我以为只需要递归自身就可以了，但是前驱节点的值也需要与当前值判断，所以递归函数还需要传入一个哈希表，另外两个函数参数是为了构造哈希表而传入的，花了一个多小时终于AC了，用时212ms（战胜0%），内存60.3MB，可以看出这种解法非常低效

```c++
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode(int x) : val(x), left(NULL), right(NULL) {}
 * };
 */
class Solution {
public:
    bool isValidBST(TreeNode* root) {
        if(root == nullptr) return true;
        if(root->left != nullptr && root->left->val >= root->val) return false;
        if(root->right != nullptr && root->right->val <= root->val) return false;
        unordered_map<int, bool> hash;  // record predecessor
        bool l = recursion(root->left, hash, root->val, true);
        bool r = recursion(root->right, hash, root->val, false);
        return l && r;
    }
    bool recursion(TreeNode* root, unordered_map<int, bool> hash, int val, bool isLeft){
        if(root == nullptr) return true;
        if(root->left != nullptr && root->left->val >= root->val) return false;
        if(root->right != nullptr && root->right->val <= root->val) return false;
        for(const auto &pair : hash){
            if(pair.second){
                if(root->val >= pair.first){
                    return false;
                }
            }
            else{
                if(root->val <= pair.first){
                    return false;
                }
            }
            
        }
        hash[val] = isLeft;
        bool l = recursion(root->left, hash, root->val, true);
        bool r = recursion(root->right, hash, root->val, false);
        return l && r;
    }
};
```

##### 优化，递归函数传入上下界：

思路：每次迭代时，若往左子树探索，则左子树的upper即为当前节点的值，若往右子树探索，则右子树的lower即为当前节点的值，这题的测试用例可能会出现INT_MIN、INT_MAX，所以得用long long解决这个case

12ms（战胜96.42%的cpp），内存消耗20.6MB，明显比传入哈希表效率高

时间复杂度O(n)，空间复杂度O(n)

```c++
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode(int x) : val(x), left(NULL), right(NULL) {}
 * };
 */
class Solution {
public:
    bool isValidBST(TreeNode* root) {
        if(root == nullptr) return true;
        long long i = 1;
        long long lower = -i+INT_MIN; 
        long long upper = i+INT_MAX;
        bool l = recursion(root->left, lower, root->val);
        bool r = recursion(root->right, root->val, upper);
        return l && r;
    }
    bool recursion(TreeNode* root, long long lower, long long upper){
        if(root == nullptr) return true;
        if(root->val >= upper || root->val <= lower) return false;
        bool l = recursion(root->left, lower, root->val);
        bool r = recursion(root->right, root->val, upper);
        return l && r;
    }
};
```

##### 最佳版本，递归的中序遍历：

思路： `左子树 -> 结点 -> 右子树`的顺序遍历整个二叉树，对于二叉搜索树而言，每个元素都应该比下一个元素小 

时间复杂度，最坏情况下（树为二叉搜索树或破坏条件的元素是最有叶节点）为O(n)

```c++
class Solution {
public:
    long last = LONG_MIN;  // record last value in inorder list(incresing list)
    bool isValidBST(TreeNode* root) {
        if(root == nullptr) return true;
        bool l = isValidBST(root->left); // traversal left subtree
        if(root->val <= last) return false;
        last = root->val;
        bool r = isValidBST(root->right);// traversal right subtree
        return l && r;;
    }
};
```

#### 101.对称二叉树

给定一个二叉树，检查它是否是镜像对称的。

例如，二叉树 `[1,2,2,3,4,4,3]` 是对称的。

```
    1
   / \
  2   2
 / \ / \
3  4 4  3
```

但是下面这个 `[1,2,2,null,3,null,3]` 则不是镜像对称的:

```
    1
   / \
  2   2
   \   \
   3    3
```

**说明:**

如果你可以运用递归和迭代两种方法解决这个问题，会很加分。 

##### 第一次尝试，前序遍历和后序遍历：

思路：镜像对称的二叉树，其前序遍历和后序遍历的列表一样，但是后来发现有错，比如`[1,2,2,2,null,2]`，其前序遍历列表和后序列表都是[2, 2, 1, 2, 2]

思路虽然错了，错误代码也放上来作为参考：

```c++
    bool isSymmetric(TreeNode* root) {
        if(root == nullptr) return true;
        vector<TreeNode*> pre_vec = {root};
        preorderRecursion(root, pre_vec);
        vector<TreeNode*> post_vec = {root};
        postorderRecursion(root, post_vec);
        for(int i = 0; i < pre_vec.size(); ++i){
            if(pre_vec[i]->val != post_vec[i]->val){
                return false;
            }
        }
        return true;
    }
    void preorderRecursion(TreeNode* root, vector<TreeNode*> &vec){
        if(root == nullptr) return;
        preorderRecursion(root->left, vec);
        vec.push_back(root);
        preorderRecursion(root->right, vec);
    }
    void postorderRecursion(TreeNode* root, vector<TreeNode*> &vec){
        if(root == nullptr) return;
        postorderRecursion(root->right, vec);
        vec.push_back(root);
        postorderRecursion(root->left, vec);
    }
```

##### 修正错误：

思路：上个代码没法判断前序遍历列表和后序遍历列表的同位置元素是否是对称的，观察到它们两个节点如果一左一右或一右一左地从父节点延伸出，则它们是镜面对称的，于是可以在构建前序/后序遍历列表时，把这个信息也加进去，列表的每个元素是一个pair，它包含了TreeNode*与一个用来指示是否是左叶结点的bool

一次时间8ms（战胜72.84%的cpp），一次4ms（战胜94.72%的cpp），内存消耗16.1MB

```c++
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode(int x) : val(x), left(NULL), right(NULL) {}
 * };
 */
class Solution {
public:
    bool isSymmetric(TreeNode* root) {
        if(root == nullptr) return true;
        vector<pair<TreeNode*, bool>> pre_vec;
        preorderRecursion(root, pre_vec, true);
        vector<pair<TreeNode*, bool>> post_vec;
        postorderRecursion(root, post_vec, false);
        for(int i = 0; i < pre_vec.size(); ++i){
            if(pre_vec[i].first->val != post_vec[i].first->val){
                return false;
            }
            else if(pre_vec[i].second == post_vec[i].second){
                return false;    
            }
        }
        return true;
    }
    void preorderRecursion(TreeNode* root, vector<pair<TreeNode*, bool>> &vec, bool isLeft){
        if(root == nullptr) return;
        preorderRecursion(root->left, vec, true);
        vec.push_back(make_pair(root, isLeft));
        preorderRecursion(root->right, vec, false);
    }
    void postorderRecursion(TreeNode* root, vector<pair<TreeNode*, bool>> &vec, bool isLeft){
        if(root == nullptr) return;
        postorderRecursion(root->right, vec, false);
        vec.push_back(make_pair(root, isLeft));
        postorderRecursion(root->left, vec, true);
    }
};
```

##### 递归最佳版本：

思路：左右同时出发，双管齐下！

时间复杂度：O(n)，因为我们遍历整个输入树一次，所以总的运行时间为 O(n)，其中 n是树中结点的总数。
空间复杂度：递归调用的次数受树的高度限制。在最糟糕情况下，树是线性的，其高度为 O(n)。因此，在最糟糕的情况下，由栈上的递归调用造成的空间复杂度为 O(n)。

```c++
class Solution {
public:
    bool isSymmetric(TreeNode* root) {
        return isSym(root, root);
    }
    bool isSym(TreeNode *p, TreeNode *q){
        if(p == nullptr && q == nullptr) return true;
        if(!p || !q) return false;	// one is nullptr, the other is not, so return false
        if(p->val == q->val) return isSym(p->left, q->right) && isSym(p->right, q->left);
        return false;
    }
};
```

##### 迭代最佳版本：

思路：左右同时出发，双管齐下！用双端队列存储节点，在迭代开始时，从队列头部拿出两个节点，如果这两个节点都有值且相等，则当前迭代成功，然后在队列后面加入左左、右右、左右、右左四个叶节点，连续两个的值应该是相等的，注意刚开始队列要先加入root节点两次

```c++
class Solution {
public:
    bool isSymmetric(TreeNode* root) {
        if(root == nullptr) return true;
        deque<TreeNode*> q = {root, root};
        TreeNode *t1, *t2;
        while(!q.empty()){
            t1 = q.front();
            q.pop_front();
            t2 = q.front();
            q.pop_front();
            if(t1 == nullptr && t2 == nullptr) continue;
            if(t1 == nullptr || t2 == nullptr) return false;
            if(t1->val != t2->val) return false;
            q.push_back(t1->left);
            q.push_back(t2->right);
            q.push_back(t1->right);
            q.push_back(t2->left);
        }
        return true;
    }
};
```

#### 102.二叉树的层次遍历

给定一个二叉树，返回其按层次遍历的节点值。 （即逐层地，从左到右访问所有节点）。

例如:
给定二叉树: `[3,9,20,null,null,15,7]`,

```
    3
   / \
  9  20
    /  \
   15   7
```

返回其层次遍历结果：

```
[
  [3],
  [9,20],
  [15,7]
]
```

##### 第一次尝试，BFS+层数记录：

思路：很容易想到BFS，但是没法记录每个节点所在层数，加上一个层数信息，也许可以解决问题，普通的BFS用迭代的解法，需要借助队列，比如第101题对称二叉树中就用到了`deque<TreeNode*>`，在这里为了记录层数信息，可以`deque<pair<TreeNode*, int>>`

4ms（战胜96.5%的cpp）， 内存消耗13.6 MB 

```c++
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode(int x) : val(x), left(NULL), right(NULL) {}
 * };
 */
class Solution {
public:
    vector<vector<int>> levelOrder(TreeNode* root) {
        vector<vector<int>> vecs;
        if(root == nullptr) return vecs;
        //vecs.push_back(vector<int>{root->val});
        deque<pair<TreeNode*, int>> q;
        q.push_back(make_pair(root, 0));
        TreeNode* node;
        int depth;
        while(!q.empty()){
            node = q.front().first;
            depth = q.front().second;
            q.pop_front();
            if(depth == vecs.size()){
                vecs.push_back(vector<int>{});
            }
            vecs[depth].push_back(node->val);  
            if(node->left != nullptr){
                q.push_back(make_pair(node->left, depth+1));
            }
            if(node->right != nullptr){
                q.push_back(make_pair(node->right, depth+1));
            }
        }
        return vecs;
    }
};
```

#### 108.将有序数组转换为二叉搜索树

将一个按照升序排列的有序数组，转换为一棵高度平衡二叉搜索树。

本题中，一个高度平衡二叉树是指一个二叉树*每个节点* 的左右两个子树的高度差的绝对值不超过 1。

**示例:**

```
给定有序数组: [-10,-3,0,5,9],

一个可能的答案是：[0,-3,9,-10,null,5]，它可以表示下面这个高度平衡二叉搜索树：

      0
     / \
   -3   9
   /   /
 -10  5
```

##### 第一次尝试，两个指针从数组中间往两边出发：

思路：两个指针low、high，从数据中点向两边移动，用两个队列存储当前节点，节点的值即为指针对应的值

最后发现思路是错的，比如给定有序数组: [-10,-3,0,5,9]，左子树的确可以像图中那样，但是右子树就错了

```
      0
     / \
   -3   5
   /   /
 -10  9
```

##### 第二次尝试，递归二分：

思路：观察可知，根节点肯定位于数组中间，而根节点的左叶节点作为左子树的根，肯定位于数组1/4处，而根节点的右叶节点作为右子树的根，肯定位于数组3/4处，这样就很容易写出递归的代码

16ms（战胜98.47%的cpp），内存消耗20.9MB

```c++
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode(int x) : val(x), left(NULL), right(NULL) {}
 * };
 */
class Solution {
public:
    TreeNode* sortedArrayToBST(vector<int>& nums) {
        if(nums.empty()) return nullptr;
        return recursion(nums, 0, nums.size()-1);
    }
    TreeNode* recursion(vector<int>& nums, int lower, int upper){
        if(lower > upper) return nullptr;
        int mid = (lower+upper)/2;
        TreeNode *root = new TreeNode(nums[mid]);
        root->left = recursion(nums, lower, mid-1);
        root->right = recursion(nums, mid+1, upper);
        return root;
    }
};
```

最后发现，AC的代码几乎跟我这个差不多，这题是独立完成的，耗时1h左右吧，我自己竟然也可以写出这么简洁高效的代码了！

---

#### 88.合并两个有序数组

给定两个有序整数数组 *nums1* 和 *nums2*，将 *nums2* 合并到 *nums1* 中*，*使得 *num1* 成为一个有序数组。

**说明:**

- 初始化 *nums1* 和 *nums2* 的元素数量分别为 *m* 和 *n*。
- 你可以假设 *nums1* 有足够的空间（空间大小大于或等于 *m + n*）来保存 *nums2* 中的元素。

**示例:**

```
输入:
nums1 = [1,2,3,0,0,0], m = 3
nums2 = [2,5,6],       n = 3

输出: [1,2,2,3,5,6]
```

 