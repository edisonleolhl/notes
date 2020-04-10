# LeetCode record

## 数组

### 1.两数之和

给定一个整数数组 `nums` 和一个目标值 `target`，请你在该数组中找出和为目标值的那 **两个** 整数，并返回他们的数组下标。

你可以假设每种输入只会对应一个答案。但是，你不能重复利用这个数组中同样的元素。

**示例:**

```c++
给定 nums = [2, 7, 11, 15], target = 9

因为 nums[0] + nums[1] = 2 + 7 = 9
所以返回 [0, 1]
```

 第一次尝试，188ms（战胜45.39%的cpp）

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

 优化，一遍哈希表，8ms（战胜98.36%的cpp）

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

### 11.盛最多水的容器

给定 n 个非负整数 a1，a2，...，an，每个数代表坐标中的一个点 (i, ai) 。在坐标内画 n 条垂直线，垂直线 i 的两个端点分别为 (i, ai) 和 (i, 0)。找出其中的两条线，使得它们与 x 轴共同构成的容器可以容纳最多的水。

说明：你不能倾斜容器，且 n 的值至少为 2。

示例:

输入: [1,8,6,2,5,4,8,3,7]
输出: 49

 盛最多水的容器的暴力解法

时间复杂度O(n^2)

```c++
class Solution {
public:
    int maxArea(vector<int>& height) {
        // brute force
        int maxA = 0, tempA = 0;
        for(int i = 0; i < height.size(); ++i){
            for(int j = i; j < height.size(); ++j){
                tempA = (j - i) * (height[i] < height[j] ? height[i] : height[j]);
                maxA = maxA > tempA ? maxA : tempA;
            }
        }
        return maxA;
    }
};
```

 双指针

思路两线段之间形成的区域总是会受到其中较短那条长度的限制。此外，两线段距离越远，得到的面积就越大。

我们在由线段长度构成的数组中使用两个指针，一个放在开始，一个置于末尾。 在每一步中，计算矩形，更新 maxA，并将**指向较短线段的指针向较长线段那端移动一步**，两个指针相互靠近时，矩形的底是变小的，所以只有高变大才有可能面积变大，所以，让短的那个边向中间靠近，这个思想挺巧妙的

时间复杂度O(n)

```c++
class Solution {
public:
    int maxArea(vector<int>& height) {
        int maxA = 0, tempA = 0;
        int i = 0, j = height.size()-1;
        while(i < j){
            tempA = (j - i) * (height[i] < height[j] ? height[i] : height[j]);
            maxA = maxA > tempA ? maxA : tempA;
            if(height[i] > height[j]){
                --j;
            }
            else{
                ++i;
            }
        }
        return maxA;
    }
};
```

### 15.三数之和

给定一个包含 n 个整数的数组 nums，判断 nums 中是否存在三个元素 a，b，c ，使得 a + b + c = 0 ？找出所有满足条件且不重复的三元组。

注意：答案中不可以包含重复的三元组。

例如, 给定数组 nums = [-1, 0, 1, 2, -1, -4]，

满足要求的三元组集合为：
[
  [-1, 0, 1],
  [-1, -1, 2]
]

 三数之和的双指针

思路：暴力没意思，回想一下第1题2sum，用到了哈希表来换取时间，这里也是一样，选择两个数后，第三个数必为0-前两个数之和。

- 首先排序，用快排可以做到O(nlogn)的时间
- 然后在外层循环for(i)里面设置双指针，初始值为i+1和nums.size()-1，考察nums[lo]+nums[hi]与-nums[i]，若前者大，说明两数和取大了，--hi，若前者小，说明两数和取小了，++lo
- 当nums[lo]+nums[hi]=-nums[i]时，此为可行解，输出到result中
- 去重操作：输出可行解后，lo右移到第一个不相等的元素位置，hi左移到第一个不相等的元素位置，这就非常巧妙地避免了重复
- 当lo>hi时，结束这次迭代，++i

时间复杂度为O(n^2)

详细代码如下摘抄自[solution](https://leetcode-cn.com/problems/3sum/solution/cpai-xu-hou-jia-ji-de-fang-shi-xiang-xi-zhu-shi-by/)

```c++
class Solution {
    public:

    vector<vector<int>> threeSum(vector<int>& nums) {
        // 创建符合题设类型的变量用于返回
        vector<vector<int>> _results;
        int _size = nums.size();
        // 判断传入数组nums的size，小于3，则返回空
        if (_size < 3) return _results;
        // 对nums进行从头到尾的升序排列
        sort(nums.begin(), nums.end(), less<int>());
        // 循环遍历nums元素，此处的“-2”是为了当i移动到最后的时候，右侧留出l和r的位置
        for (int i = 0; i < _size - 2; i++) {
            // 如果三个数中的第一个数就大于0，在升序排列的nums中，后续的数只可能更大
            // 所以三数之和不可能为0了，则不用继续判断了，直接返回结果
            if (nums[i] > 0) break;
            // 从nums首元素往后，判断前一个元素nums[i - 1]是否等于当前元素nums[i]
            // 如果相等则跳过当次循环，持续向后循环判断（continue）
            // 否则，开始定位三个数中的后两个数
            if (i > 0 && nums[i - 1] == nums[i]) continue;
            // l为位置i后续位置的最左侧，r为位置i后续位置的最右侧
            int l = i + 1, r = _size - 1;
            // 当位置l未和位置r重合的时候，循环操作
            // 这里的操作是指向中间夹，即l有时会右移或r有时会左移
            while (l < r) {
                // 求三数之和sum
                int sum = nums[i] + nums[l] + nums[r];
                // 如果sum等于0
                if (0 == sum) {
                    // 把结果以三个数为一个vector的形式，推入要返回的变量
                    _results.push_back({nums[i], nums[l], nums[r]});
                    // 和for循环下的第2行一个道理
                    // 在位置l和r未重合时，判断后一个元素是否等于当前元素
                    // 如果相等则持续向后循环判断，否则跳出循环，继续计算新的三数之和
                    // 此处的“持续向后”，由++l或--r实现，因为l要右移，且r要左移
                    // 此处依然注意必须要把自加和自减放在前面，否则会在取值之后才自加或自减
                    while (l < r && nums[l] == nums[++l]);
                    while (l < r && nums[r] == nums[--r]);
                }
                // else代表如果sum不等于0，用三目运算符操作
                // 如果sum大于0，为了让sum小一点，需要把最右侧的值变小，左移一个位置
                // 否则，即sum小于0，为了让sum变大，需要把最左侧的值变大，右移一个位置
                else (sum > 0) ? r-- : l++;
            }
        }
        // 循环完成后，返回结果
        return _results;
    }
};

作者：lao-cui-tou-ai-xiao-ye-ai-zhu
链接：https://leetcode-cn.com/problems/3sum/solution/cpai-xu-hou-jia-ji-de-fang-shi-xiang-xi-zhu-shi-by/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

### 16.最接近的三数之和

给定一个包括 n 个整数的数组 nums 和 一个目标值 target。找出 nums 中的三个整数，使得它们的和与 target 最接近。返回这三个数的和。假定每组输入只存在唯一答案。

例如，给定数组 nums = [-1，2，1，-4], 和 target = 1.

与 target 最接近的三个数的和为 2. (-1 + 2 + 1 = 2).

仿照第15题的双指针法

思路：用nearest记录当前已知的最接近的解，注意要通过所有testcase有点麻烦，nearest的初始值不要设为INT_MAX，否则在abs(nearest-target)时可能会上溢，当sum==target时，可以直接返回

```c++
class Solution {
public:
    int threeSumClosest(vector<int>& nums, int target) {
        sort(nums.begin(), nums.end());
        int low = 0;
        int high = 0;
        int nearest = nums[0] + nums[1] + nums[2];
        int sum = 0;
        for(int i = 0; i < nums.size() - 2; ++i){
            low = i + 1;
            high = nums.size() - 1;
            while(low < high){
                sum = nums[i] + nums[low] + nums[high];
                if(abs(sum - target) < abs(nearest - target)){
                    nearest = sum;
                }
                if(sum > target){
                    --high;
                }
                else if(sum < target){
                    ++low;
                }
                else{
                    return target;
                }
            }
        }
        return nearest;
    }
};
```

125/125 cases passed (16 ms)
Your runtime beats 32.48 % of cpp submissions
Your memory usage beats 97.11 % of cpp submissions (8.5 MB)

 最接近三数之和的去重

16题与15题的去重不太一样，因为是找接近的，所以不是在更新内移动指针去重，而是在`sum>target`和`sum<target`中移动指针去重，这里有个问题，对于

```c++
                if(sum > target){
                    --high;
                    // 解决nums[low]重复
                    while(low < high && nums[high] == nums[high - 1]) --high;
                }
```

当面对数组[-1, 0, 1, 1, 55]，target=3时，expected answer=2，当i指向0，low指向第一个1，high指向55时，进入上面的if分支，high左移，指向第二个1，然后此时进入while循环，发现成立，high再左移，指向第一个1，执行完后，发现while(low < high)不成立了，所以0，1，1的最优解被跳过了

其实原因在于，if分支里是先--high，再解决nums[low]重复，这里面的判断应该是

```c++
                if(sum > target){
                    --high;
                    // 解决nums[low]重复
                    while(low < high && nums[high] == nums[high + 1]) --high;
                }
```

综上，去重的代码为，用时明显减少

```c++
class Solution {
public:
    int threeSumClosest(vector<int>& nums, int target) {
        sort(nums.begin(), nums.end());
        int low = 0;
        int high = 0;
        int nearest = nums[0] + nums[1] + nums[2];
        int sum = 0;
        for(int i = 0; i < nums.size() - 2; ++i){
            // 解决nums[i]重复
            if(i > 0 && nums[i] == nums[i - 1]) continue;
            low = i + 1;
            high = nums.size() - 1;
            while(low < high){
                sum = nums[i] + nums[low] + nums[high];
                if(abs(sum - target) < abs(nearest - target)){
                    nearest = sum;
                }
                if(sum > target){
                    --high;
                    // 解决nums[low]重复
                    while(low < high && nums[high] == nums[high + 1]) --high;
                }
                else if(sum < target){
                    ++low;
                    // 解决nums[high]重复
                    while(low < high && nums[low] == nums[low - 1]) ++low;
                }
                else{
                    return target;
                }
            }
        }
        return nearest;
    }
};
```

125/125 cases passed (4 ms)
Your runtime beats 99.68 % of cpp submissions
Your memory usage beats 87.01 % of cpp submissions (8.7 MB)

### 18.四数之和

给定一个包含 n 个整数的数组 nums 和一个目标值 target，判断 nums 中是否存在四个元素 a，b，c 和 d ，使得 a + b + c + d 的值与 target 相等？找出所有满足条件且不重复的四元组。

注意：

答案中不可以包含重复的四元组。

示例：

给定数组 nums = [1, 0, -1, 0, -2, 2]，和 target = 0。

满足要求的四元组集合为：
[
  [-1,  0, 0, 1],
  [-2, -1, 1, 2],
  [-2,  0, 0, 2]
]

 还是双指针法

思路：最外层套一层for循环，里面还是三数之和，时间复杂度为O(n^3)，注意去重操作的写法

```c++
class Solution {
public:
    vector<vector<int>> fourSum(vector<int>& nums, int target) {
        vector<vector<int>> result;
        sort(nums.begin(), nums.end());
        int len = nums.size();
        int threeTarget = 0;
        int threeSum = 0;
        int low = 0;
        int high = 0;
        for(int index = 0; index < len - 3; ++index){
            // avoid duplication of nums[index]
            if(index > 0 && nums[index] == nums[index - 1]) continue;
            threeTarget = target - nums[index];
            for(int i = index + 1; i < len - 2; ++i){
                // avoid duplication of nums[i], notet that i > index + 1
                if(i > index + 1 && nums[i] == nums[i - 1]) continue;
                int low = i + 1;
                int high = len - 1;
                while(low < high){
                    threeSum = nums[i] + nums[low] + nums[high];
                    if(threeSum == threeTarget){
                        result.push_back({nums[index], nums[i], nums[low], nums[high]});
                        --high;
                        while(low < high && nums[high] == nums[high + 1]) --high;
                        ++low;
                        while(low < high && nums[low] == nums[low - 1]) ++low;
                    }
                    else if(threeSum > threeTarget){
                        --high;
                        // avoid duplication of nums[high]
                        while(low < high && nums[high] == nums[high + 1]) --high;
                    }
                    else{
                        ++low;
                        // avoid duplication of nums[low]
                        while(low < high && nums[low] == nums[low - 1]) ++low;
                    }
                }
            }
        }
        return result;
    }
};
```

282/282 cases passed (56 ms)
Your runtime beats 52.37 % of cpp submissions
Your memory usage beats 86.07 % of cpp submissions (9.1 MB)

### 26.从排序数组中删除重复项 （数组）

给定一个排序数组，你需要在**[原地](http://baike.baidu.com/item/原地算法)**删除重复出现的元素，使得每个元素只出现一次，返回移除后数组的新长度。不要使用额外的数组空间，你必须在**[原地](https://baike.baidu.com/item/原地算法)修改输入数组**并在使用 O (1) 额外空间的条件下完成。你不需要考虑数组中超出新长度后面的元素。

216ms（战胜17.87%cpp）的解答

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

24ms（战胜94.20%cpp）的解答

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

### 27.移除元素

给定一个数组 nums 和一个值 val，你需要原地移除所有数值等于 val 的元素，返回移除后数组的新长度。

不要使用额外的数组空间，你必须在原地修改输入数组并在使用 O(1) 额外空间的条件下完成。

元素的顺序可以改变。你不需要考虑数组中超出新长度后面的元素。

示例 1:

给定 nums = [3,2,2,3], val = 3,

函数应该返回新的长度 2, 并且 nums 中的前两个元素均为 2。

你不需要考虑数组中超出新长度后面的元素。
示例 2:

给定 nums = [0,1,2,2,3,0,4,2], val = 2,

函数应该返回新的长度 5, 并且 nums 中的前五个元素为 0, 1, 3, 0, 4。

注意这五个元素可为任意顺序。

你不需要考虑数组中超出新长度后面的元素。
说明:

为什么返回数值是整数，但输出的答案是数组呢?

请注意，输入数组是以“引用”方式传递的，这意味着在函数里修改输入数组对于调用者是可见的。

你可以想象内部操作如下:

// nums 是以“引用”方式传递的。也就是说，不对实参作任何拷贝
int len = removeElement(nums, val);

// 在函数里修改输入数组对于调用者是可见的。
// 根据你的函数返回的长度, 它会打印出数组中该长度范围内的所有元素。
for (int i = 0; i < len; i++) {
    print(nums[i]);
}

 快慢指针

第一次提交就AC了，这题跟26题做法差不多，就用快慢指针就好了

```c++
class Solution {
public:
    int removeElement(vector<int>& nums, int val) {
        int slow = 0, fast = 0, len = nums.size();
        while(fast < len){
            if(nums[fast] == val){
                ++fast;
                continue;
            }
            nums[slow++] = nums[fast++];
        }
        return slow;
    }
};
```

113/113 cases passed (8 ms)
Your runtime beats 45.29 % of cpp submissions
Your memory usage beats 73.78 % of cpp submissions (8.7 MB)

### 31.下一个排列

实现获取下一个排列的函数，算法需要将给定数字序列重新排列成字典序中下一个更大的排列。

如果不存在下一个更大的排列，则将数字重新排列成最小的排列（即升序排列）。

必须原地修改，只允许使用额外常数空间。

以下是一些例子，输入位于左侧列，其相应输出位于右侧列。
1,2,3 → 1,3,2
3,2,1 → 1,2,3
1,1,5 → 1,5,1

 第一次尝试，错误理解了题意

对于题目的理解，关键在于“下一个更大的排序”是指什么，我以为是从后面开始遍历的，如果是递增的话就swap，如果遍历完整个数组都没有swap过，那么就数组反序，用一半的swap即可，

```c++
class Solution {
public:
    void nextPermutation(vector<int>& nums) {
        int len = nums.size();
        int swapFlag = false;
        for(int i = len - 1; i > 0 ; --i){
            if(nums[i] > nums[i - 1]){
                swap(nums[i], nums[i-1]);
                swapFlag = true;
                break;
            }
        }
        if(!swapFlag){
            for(int i = 0; i < len / 2; ++i){
                swap(nums[i], nums[len - 1 - i]);
            }
        }
    }
};
```

发现WA了

Wrong Answer
154/265 cases passed (N/A)

Testcase
[1,3,2]

Answer
[3,1,2]

Expected Answer
[2,1,3]

 nextPermutation的本质

通过移动某个数字，来让整个字符串增加【最小】的量，你可以把[1,3,2]看成132，下一个应该是213，而不是312，故应该输出[2,1,3]

- 判断按照字典序有木有下一个，如果完全降序就没有下一个
- 如何判断有木有下一个呢？只要存在 a [i-1] < a [i] 的升序结构就有下一个，而且我们应该从右往左找，一旦找到，因为这样才是真正下一个
- 当发现 a [i-1] < a [i] 的结构时，从在 [i, ∞] 中找到最接近 a [i-1] 并且又大于 a [i-1] 的数字，由于降序，从右往左遍历即可得到 k
- 然后交换 a [i-1] 与 a [k]，然后对 [i, ∞] 排序即可，因为已经是降序，所以排序只需要首尾不停交换即可
- 上面说的很抽象，还是需要拿一些例子思考才行，比如 [0,5,4,3,2,1]，下一个应该是 [1,0,2,3,4,5]，具体做法：当i=1时发现nums[1]>nums[0]，然后从右边找比nums[0]大并且最接近nums[0]的序号j，找到j=5，交换nums[0]与nums[5]，然后对nums[1]~nums[5]升序排列，因为这一段已经是降序排列的，所以只需要前后调换即可

```c++
class Solution {
public:
    void nextPermutation(vector<int>& nums) {
        int len = nums.size();
        if(len <= 1) return;
        int swapFlag = false;
        for(int i = len - 1; i > 0 ; --i){
            if(nums[i] > nums[i - 1]){
                for(int j = len - 1; j >= i; --j){
                    if(nums[j] > nums[i - 1]){
                        swap(nums[j], nums[i - 1]);
                        for(int k = i; k < i + (len - i) / 2; ++k){
                            swap(nums[k], nums[len - 1 - (k - i)]);
                        }
                        swapFlag = true;
                        break;
                    }
                }
                break;
            }
        }
        if(!swapFlag){
            for(int i = 0; i < len / 2; ++i){
                swap(nums[i], nums[len - 1 - i]);
            }
        }
    }
};
```

265/265 cases passed (20 ms)
Your runtime beats 9.01 % of cpp submissions
Your memory usage beats 95.94 % of cpp submissions (8.4 MB)

 用reverse代替前后调换

用swap写前后调换，很容易出错，特别是只reverse数组的一部分，下面的代码我编写了很久才写对

```c++
                        for(int k = i; k < i + (len - i) / 2; ++k){
                            swap(nums[k], nums[len - 1 - (k - i)]);
                        }
```

可以直接调用reverse函数，该函数的底层逻辑其实也是swap

```c++
template <class BidirectionalIterator>
  void reverse (BidirectionalIterator first, BidirectionalIterator last)
{
  while ((first!=last)&&(first!=--last)) {
    std::iter_swap (first,last);
    ++first;
  }
```

于是题解可以稍显简单，没有那个嵌套的for循环

```c++
class Solution {
public:
    void nextPermutation(vector<int>& nums) {
        int len = nums.size();
        if(len <= 1) return;
        int swapFlag = false;
        for(int i = len - 1; i > 0 ; --i){
            if(nums[i] > nums[i - 1]){
                for(int j = len - 1; j >= i; --j){
                    if(nums[j] > nums[i - 1]){
                        swap(nums[j], nums[i - 1]);
                        reverse(nums.begin() + i, nums.end());
                        swapFlag = true;
                        break;
                    }
                }
                break;
            }
        }
        if(!swapFlag){
            reverse(nums.begin(), nums.end());
        }
    }
};
```

265/265 cases passed (12 ms)
Your runtime beats 62.94 % of cpp submissions
Your memory usage beats 93 % of cpp submissions (8.5 MB)

### 36.有效的数独

 判断一个 9x9 的数独是否有效。只需要**根据以下规则**，验证已经填入的数字是否有效即可。

1. 数字 `1-9` 在每一行只能出现一次。
2. 数字 `1-9` 在每一列只能出现一次。
3. 数字 `1-9` 在每一个以粗实线分隔的 `3x3` 宫内只能出现一次。

**说明:**

- 一个有效的数独（部分已被填充）不一定是可解的。
- 只需要根据以上规则，验证已经填入的数字是否有效即可。
- 给定数独序列只包含数字 `1-9` 和字符 `'.'` 。
- 给定数独永远是 `9x9` 形式的。

 第一次尝试，36ms（战胜18.06%的cpp）

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

优化

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

### 48.旋转图像

给定一个 *n* × *n* 的二维矩阵表示一个图像。

将图像顺时针旋转 90 度。

**说明：**

你必须在**[原地](https://baike.baidu.com/item/原地算法)**旋转图像，这意味着你需要直接修改输入的二维矩阵。**请不要**使用另一个矩阵来旋转图像。

 第一次尝试，4ms（战胜96.21%的cpp）

思路：因为需要原地旋转，所以要在矩阵内部交换元素，找规律发现：某点在顺时针旋转90°四次后会回到原点，于是可以从最外圈开始依次遍历，只需要n/2次即可：`for(int layer = 0; layer < n/2; ++layer)`，在圈数循环的内部，再嵌套一个循环，遍历当前圈的第一行（除开最后一个元素），判断条件为：`for(int j = layer; j < n-layer-1; ++j)`。

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

 先转置再翻转每一行，也是4ms

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

### 66.加一

给定一个由**整数**组成的**非空**数组所表示的非负整数，在该数的基础上加一。

最高位数字存放在数组的首位， 数组中每个元素只存储**单个**数字。

你可以假设除了整数 0 之外，这个整数不会以零开头。

 8ms的解答

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

### 122.买卖股票的最佳时机 II（数组）

给定一个数组，它的第 *i* 个元素是一支给定股票第 *i* 天的价格。

设计一个算法来计算你所能获取的最大利润。你可以尽可能地完成更多的交易（多次买卖一支股票）。

**注意：**你不能同时参与多笔交易（你必须在再次购买前出售掉之前的股票）。

0ms（战胜100%cpp）的解答

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

### 137.只出现一次的数字

给定一个**非空**整数数组，除了某个元素只出现一次以外，其余每个元素均出现两次。找出那个只出现了一次的元素。

**说明：**

你的算法应该具有线性时间复杂度。 你可以不使用额外空间来实现吗？

24ms（战胜41.51%cpp）的解答

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

同样时间，线性时间复杂度但用了额外空间的解答

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

 最佳解法，线性时间复杂度，没有额外空间

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

### 189. 旋转数组（数组）

给定一个数组，将数组中的元素向右移动 *k* 个位置，其中 *k* 是非负数。

**说明:**

- 尽可能想出更多的解决方案，至少有三种不同的方法可以解决这个问题。
- 要求使用空间复杂度为 O (1) 的 **原地** 算法。

第一次尝试（空间复杂度为O(1)，时间复杂度为O(kn)，因超时无法通过）

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

第二次尝试（空间复杂度为O(n)，时间复杂度为O(n)）

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

第三次尝试（空间复杂度为O(1)，时间复杂度为O(n)）

如果  `n = 7 , k = 3`，给定数组  `[1,2,3,4,5,6,7]`  ，向右旋转后的结果为 `[5,6,7,1,2,3,4]`。

**思路：**把原数组划分为两个部分来看：`前 n - k 个元素 [1,2,3,4]` 和 `后k个元素 [5,6,7]`，进行分开处理

1. 定义 reverse 逆转方法：将数组元素反转，比如 [1,2,3,4] 逆转后变成  [4,3,2,1]
2. 对前 n - k 个元素 [1,2,3,4] 进行逆转后得到 [4,3,2,1]
3. 对后 k 个元素 [5,6,7] 进行逆转后得到 [7,6,5]
4. 将前后元素 [4,3,2,1,7,6,5] 逆转得到：[5,6,7,1,2,3,4]
    **注意：还要处理 k > 数组长度的情况，对 k 进行取模**

24ms（战胜76.34%cpp）的解答

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

### 217.存在重复元素

56ms（战胜54.17%的cpp）的解答

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

效率差不多代码更少的解答

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

先排序再前后比较的解法

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

### 283.移动零

给定一个数组 `nums`，编写一个函数将所有 `0` 移动到数组的末尾，同时保持非零元素的相对顺序。

```c++
输入: [0,1,0,3,12]
输出: [1,3,12,0,0]
```

**说明**:

1. 必须在原数组上操作，不能拷贝额外的数组。
2. 尽量减少操作次数。

 第一次尝试，超出时间限制

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

 修改后，24ms（战胜53.4%的cpp）

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

 优化

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

 继续优化

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

### 350.两个数组的交集 II

给定两个数组，编写一个函数来计算它们的交集。

```c++
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

 第一次尝试，8ms（战胜95.77%cpp）

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

 第二次尝试，4ms（战胜99.74%的cpp）

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

 进阶1，第一次尝试的优化

思路：若两个数组已排序，则搜索操作不必遍历整个数组，只要当待搜数字比迭代器要小时就可以跳出迭代，因为迭代器后面的数字肯定不小于当前迭代器的数字

```c++
class Solution {
public:
    vector<int> intersect(vector<int>& nums1, vector<int>& nums2) {
        vector<int> result;
        sort(nums1.begin(), nums1.end());   // to pass some unsorted test case
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

 进阶1，两个指针齐头并进，4ms（战胜99.74%的cpp）

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

## 字符串

### 7.整数反转

给出一个 32 位的有符号整数，你需要将这个整数中每位上的数字进行反转。

**注意:**

假设我们的环境只能存储得下 32 位的有符号整数，则其数值范围为 [−2^31, 2^31 − 1]。请根据这个假设，如果反转后整数溢出那么就返回 0。

 又快又好的解法

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

### 8.字符串转换整数 (atoi)

请你来实现一个 `atoi` 函数，使其能将字符串转换成整数。

首先，该函数会根据需要丢弃无用的开头空格字符，直到寻找到第一个非空格的字符为止。

当我们寻找到的第一个非空字符为正或者负号时，则将该符号与之后面尽可能多的连续数字组合起来，作为该整数的正负号；假如第一个非空字符是数字，则直接将其与之后连续的数字字符组合起来，形成整数。

该字符串除了有效的整数部分之后也可能会存在多余的字符，这些字符可以被忽略，它们对于函数不应该造成影响。

注意：假如该字符串中的第一个非空格字符不是一个有效整数字符、字符串为空或字符串仅包含空白字符时，则你的函数不需要进行转换。

在任何情况下，若函数不能进行有效的转换时，请返回 0。

**说明：**

假设我们的环境只能存储 32 位大小的有符号整数，那么其数值范围为 [−231, 231 − 1]。如果数值超过这个范围，请返回  INT_MAX (231 − 1) 或 INT_MIN (−231) 。

**示例 1:**

```c++
输入: "42"
输出: 42
```

**示例 2:**

```c++
输入: "   -42"
输出: -42
解释: 第一个非空白字符为 '-', 它是一个负号。
     我们尽可能将负号与后面所有连续出现的数字组合起来，最后得到 -42 。
```

**示例 3:**

```c++
输入: "4193 with words"
输出: 4193
解释: 转换截止于数字 '3' ，因为它的下一个字符不为数字。
```

**示例 4:**

```c++
输入: "words and 987"
输出: 0
解释: 第一个非空字符是 'w', 但它不是数字或正、负号。
     因此无法执行有效的转换。
```

**示例 5:**

```c++
输入: "-91283472332"
输出: -2147483648
解释: 数字 "-91283472332" 超过 32 位有符号整数范围。
     因此返回 INT_MIN (−231) 。
```

 第一次尝试，0ms（战胜100%的cpp）

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

 相同思路但更为简洁的代码

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

### 14.最长公共前缀

编写一个函数来查找字符串数组中的最长公共前缀。

如果不存在公共前缀，返回空字符串 `""`。

**示例 1:**

```c++
输入: ["flower","flow","flight"]
输出: "fl"
```

**示例 2:**

```c++
输入: ["dog","racecar","car"]
输出: ""
解释: 输入不存在公共前缀。
```

**说明:**

所有输入只包含小写字母 `a-z` 。

 第一次尝试， 8ms（战胜71.83%的cpp）

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

### 28.实现 strStr ()

实现 [strStr()](https://baike.baidu.com/item/strstr/811469) 函数。

给定一个 haystack 字符串和一个 needle 字符串，在 haystack 字符串中找出 needle 字符串出现的第一个位置 (从 0 开始)。如果不存在，则返回 **-1**。

**示例 1:**

```c++
输入: haystack = "hello", needle = "ll"
输出: 2
```

**示例 2:**

```c++
输入: haystack = "aaaaa", needle = "bba"
输出: -1
```

**说明:**

当 `needle` 是空字符串时，我们应当返回什么值呢？这是一个在面试中很好的问题。

对于本题而言，当 `needle` 是空字符串时我们应当返回 0 。这与 C 语言的 [strstr()](https://baike.baidu.com/item/strstr/811469) 以及 Java 的 [indexOf()](https://docs.oracle.com/javase/7/docs/api/java/lang/String.html#indexOf(java.lang.String)) 定义相符。

 第一次尝试，4ms（战胜93.79%cpp）

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

字符串匹配算法 ——KMP算法

TODO

思路：KMP 算法是一种字符串匹配算法，由 D.E.Knuth，J.H.Morris 和 V.R.Pratt 提出的，因此人们称它为克努特 — 莫里斯 — 普拉特算法（简称 KMP 算法）。在暴力匹配中，我们在 txt 中从 i 开始与 pattern 串匹配至 i + pattern.length()，一旦匹配失败，则从 i + 1 子串重新匹配。此时我们抛弃了前面的匹配信息。

而 KMP 算法目的就是：在出错时，**利用原有的匹配信息**，尽量减少重新匹配的次数。 可以发现 KMP 算法的主串下标**永不后退**

时间复杂度：O(M+N)

缺陷：现实中，中间内容与前缀相同的单词、词汇并不多见，而长句更是除了排比句之外就很少见了，因此，在花费时间空间生成了有限状态机之后，很有可能会出现一直都是重置状态而很少降价状态的情况出现。对于长句而言，状态机所占用的空间是巨大的，而并不高效，相反纯暴力解法对于短 pattern 串。而言，总体运行时间却并不比它慢

参考连接： [http://www.ruanyifeng.com/blog/2013/05/Knuth%E2%80%93Morris%E2%80%93Pratt_algorithm.html](http://www.ruanyifeng.com/blog/2013/05/Knuth–Morris–Pratt_algorithm.html)

 字符串匹配算法——BM算法

时间复杂度：最差与KMP算法一样O(M+N)，最好是O(N)

参考链接：[阮一峰的一篇博客](http://www.ruanyifeng.com/blog/2013/05/boyer-moore_string_search_algorithm.html)

 字符串匹配算法——Sunday算法

最坏情况：O(nm)
平均情况：O(n)

### 38.报数

报数序列是一个整数序列，按照其中的整数的顺序进行报数，得到下一个数。其前五项如下：

```c++
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

```c++
输入: 1
输出: "1"
```

**示例 2:**

```c++
输入: 4
输出: "1211"
```

 第一次尝试，4ms（战胜91.49%的cpp）

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

 优化一下代码

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

 递归解法

思路：可以看到，每次循环都是以上一次字符串为输入的，所以很容易构造递归函数

### 125.验证回文字符串

给定一个字符串，验证它是否是回文串，只考虑字母和数字字符，可以忽略字母的大小写。

**说明：**本题中，我们将空字符串定义为有效的回文串。

**示例 1:**

```c++
输入: "A man, a plan, a canal: Panama"
输出: true
```

**示例 2:**

```c++
输入: "race a car"
输出: false
```

 第一次尝试， 12ms（战胜61.38%的cpp）

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

 优化，用isalnum这个标准库函数代替手写的isNumOrLetter函数

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

### 242.有效的字母异位词

给定两个字符串 *s* 和 *t* ，编写一个函数来判断 *t* 是否是 *s* 的字母异位词。

**示例 1:**

```c++
输入: s = "anagram", t = "nagaram"
输出: true
```

**示例 2:**

```c++
输入: s = "rat", t = "car"
输出: false
```

**说明:**
你可以假设字符串只包含小写字母。

**进阶:**
如果输入字符串包含 unicode 字符怎么办？你能否调整你的解法来应对这种情况？

 第一次尝试，12ms（战胜84.76%的cpp）

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

 进阶，如果包含unicode字符

思路：使用哈希表（c++中用unordered_map）而不是固定大小的计数器。想象一下，分配一个大的数组来适应整个 Unicode 字符范围，这个范围可能超过 100 万。哈希表是一种更通用的解决方案，可以适应任何字符范围。

### 344.反转字符串

编写一个函数，其作用是将输入的字符串反转过来。输入字符串以字符数组 `char[]` 的形式给出。

不要给另外的数组分配额外的空间，你必须**[原地](https://baike.baidu.com/item/原地算法)修改输入数组**、使用 O (1) 的额外空间解决这一问题。

你可以假设数组中的所有字符都是 [ASCII](https://baike.baidu.com/item/ASCII) 码表中的可打印字符。

 第一次尝试，100ms（战胜24.9%的cpp）

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

 优化，手写swap，48ms（战胜99.03%的cpp）

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

### 387.字符串中的第一个唯一字符

给定一个字符串，找到它的第一个不重复的字符，并返回它的索引。如果不存在，则返回 -1。
**注意事项：**您可以假定该字符串只包含小写字母。

**案例:**

```c++
s = "leetcode"
返回 0.

s = "loveleetcode",
返回 2.
```

 第一次尝试，60ms（战胜57.72%cpp）

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

 优化，用大小为256的数组来代替map

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

## 链表

一定要画图！

### 19.删除链表的倒数第N个节点(easy)

给定一个链表，删除链表的倒数第 *n* 个节点，并且返回链表的头结点。

示例：

给定一个链表: 1->2->3->4->5, 和 n = 2.

当删除了倒数第二个节点后，链表变为 1->2->3->5.

说明：

给定的 *n* 保证是有效的。

进阶：

你能尝试使用一趟扫描实现吗？

第一次尝试，用相同长度的向量记录，一遍扫描

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

空间复杂度为O(1)的一遍扫描

思路：两个指针，第一个指针首先从头开始移动n+1步，然后两个指针一起出发，这两个指针中间恰好隔了n个节点，当第一个指针到达空节点时，第二个指针到达从最后一个节点起数的第n个节点，这时候重新链接即可

保证输入数据n合法，所以不用判断n

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
        // 有可能删除头结点，所以要用哑结点
        ListNode* dummy = new ListNode(-1);
        dummy->next = head;
        ListNode* slow = dummy;
        ListNode* fast = dummy;
        while(n >= 0){
            fast = fast->next;
            --n;
        }
        while(fast){
            fast = fast->next;
            slow = slow->next;
        }
        slow->next = slow->next->next;
        return dummy->next;
    }
};
```

### 21.合并两个有序链表

将两个有序链表合并为一个新的有序链表并返回。新链表是通过拼接给定的两个链表的所有节点组成的。

**示例：**

```c++
输入：1->2->4, 1->3->4
输出：1->1->2->3->4->4
```

 第一次尝试，16ms（战胜42.6%的cpp）

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

迭代解法

思路：

list1[0] + merge(list1[1:], list2),     if list1[0] < list2[0]

list2[0] + merge(list1, list2[1:]), otherwise

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

### 23. 合并k个有序链表

合并 k 个排序链表，返回合并后的排序链表。请分析和描述算法的复杂度。

示例:

输入:
[
  1->4->5,
  1->3->4,
  2->6
]
输出: 1->1->2->3->4->4->5->6

构建最小堆，每次pop出最小值需要O(logk)，最后的链表中总共有N个节点，故时间复杂度为O(Nlogk)

```c++
class Solution {
public:
    ListNode* mergeKLists(vector<ListNode*>& lists) {
        auto cmp = [](ListNode* a, ListNode* b){
            return a->val > b->val; // 最小堆是用greater比较
        };
        priority_queue<ListNode*, vector<ListNode*>, decltype(cmp)> q(cmp); // 构建最小堆
        for(ListNode* head: lists) {
            if(head != nullptr)
                q.push(head);
        }
        ListNode* dummy = new ListNode(-1);
        ListNode* curr = dummy;
        while(!q.empty()) {
            ListNode* n = q.top();
            q.pop();
            if(n->next != nullptr)
                q.push(n->next);
            curr->next = n;
            curr = curr->next;
        }
        ListNode* head = dummy->next;
        delete dummy;
        return head;
    }
};
```

### 24. 两两交换链表中的节点(medium)

给定一个链表，两两交换其中相邻的节点，并返回交换后的链表。

你不能只是单纯的改变节点内部的值，而是需要实际的进行节点交换。

示例:

给定 1->2->3->4, 你应该返回 2->1->4->3.

建议：改变结构的题，最好在纸上画一下，因为很可能链表会断，所以要有三个指针，

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
    ListNode* swapPairs(ListNode* head) {
        if(!head) return nullptr;
        if(!head->next) return head;
        ListNode* dummy = new ListNode(0);
        dummy->next = head;
        ListNode* cur = dummy;
        ListNode* a;
        ListNode* b;
        while(cur && cur->next && cur->next->next){
            // cur->a->b->x...
            a = cur->next;
            b = a->next;
            cur->next = b;
            a->next = b->next;
            b->next = a;
            // cur->b->a->x...
            cur = a;
            // ->b->a->x(cur)...
        }
        return dummy->next;
    }
};
```

### 61. 旋转链表(medium)

给定一个链表，旋转链表，将链表每个节点向右移动 k 个位置，其中 k 是非负数。

示例 1:

输入: 1->2->3->4->5->NULL, k = 2
输出: 4->5->1->2->3->NULL
解释:
向右旋转 1 步: 5->1->2->3->4->NULL
向右旋转 2 步: 4->5->1->2->3->NULL
示例 2:

输入: 0->1->2->NULL, k = 4
输出: 2->0->1->NULL
解释:
向右旋转 1 步: 2->0->1->NULL
向右旋转 2 步: 1->2->0->NULL
向右旋转 3 步: 0->1->2->NULL
向右旋转 4 步: 2->0->1->NULL

题目本身不难，但是对于边界情况要很小心，还要注意一些特殊的用例，如[1]与0，[1]与1，[1,2]与2等等

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
    ListNode* rotateRight(ListNode* head, int k) {
        if(!head) return nullptr;
        if(k == 0 || !head->next) return head;
        ListNode* dummy = new ListNode(-1);
        dummy->next = head;
        ListNode* cur = head;
        ListNode* old_tail;
        ListNode* new_tail;
        int len = 1; // 已判空，肯定有头结点
        while(cur->next){
            cur = cur->next;
            ++len;
        }
        if(k % len == 0) return head;
        old_tail = cur; // 得到原链表的尾节点
        int step = (len - k % len); // 计算新链表的的头结点
        cur = head;
        while(--step){
            cur = cur->next;
        }
        new_tail = cur;
        dummy->next = new_tail->next; // 原链表的尾节点之后就是新头结点
        new_tail->next = nullptr; // 新链表的尾节点后置为空
        old_tail->next = head; // 原链表的尾节点后置为原链表头
        return dummy->next;
    }
};
```

### 82. 删除排序链表中的重复元素 II(medium)

给定一个排序链表，删除所有含有重复数字的节点，只保留原始链表中 没有重复出现 的数字。

示例 1:

输入: 1->2->3->3->4->4->5
输出: 1->2->5
示例 2:

输入: 1->1->1->2->3
输出: 2->3

思路：

一次遍历，用pre记录前驱节点，用cnt记录当前节点是否重复，如果重复则删除这一串重复节点，否则把cur赋值给pre，这种做法是不考虑释放空间的

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
    ListNode* deleteDuplicates(ListNode* head) {
        if(!head) return nullptr;
        ListNode* dummy = new ListNode(-1);
        dummy->next = head;
        ListNode* pre = dummy;
        ListNode* cur = head;
        int cnt = 1;
        while(cur){
            while(cur->next && cur->val == cur->next->val){
                cur = cur->next;
                ++cnt;
            }
            if(cnt > 1){ // 有重复元素，删除他们
                pre->next = cur->next;
                cnt = 1;
            }
            else{
                pre = cur;
            }
            cur = cur->next; // 到下一个不重复的元素
        }
        return dummy->next;
    }
};
```

### 83. 删除排序链表中的重复元素(easy)

给定一个排序链表，删除所有重复的元素，使得每个元素只出现一次。

示例 1:

输入: 1->1->2
输出: 1->2
示例 2:

输入: 1->1->2->3->3
输出: 1->2->3

保留第一个重复的元素，其余重复元素删除，不停地循环即可

情况1：如果下一个点和当前点相同，则删掉下一个节点

情况2：如果下一个点和当前点不同，则后移

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
    ListNode* deleteDuplicates(ListNode* head) {
        if(!head) return nullptr;
        ListNode* dummy = new ListNode(-1);
        dummy->next = head;
        ListNode* cur = head;
        ListNode* temp;
        while(cur->next){
            if(cur->val == cur->next->val){
                temp = cur->next;
                cur->next = cur->next->next;
                delete temp; // 释放空间
            }
            else{
                cur = cur->next;
            }
        }
        head = dummy->next;
        delete dummy; // 释放空间
        return head;
    }
};
```

### 92. 反转链表 II(medium)

反转从位置 m 到 n 的链表。请使用一趟扫描完成反转。

说明:
1 ≤ m ≤ n ≤ 链表长度。

示例:

输入: 1->2->3->4->5->NULL, m = 2, n = 4
输出: 1->4->3->2->5->NULL

一次遍历搞定，但要很小心很小心，最好画图，我自己完成时用了debug

![lc92](../image/lc92.png)

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
    ListNode* reverseBetween(ListNode* head, int m, int n) { // 假设传入[1,2,3,4,5],2,4
        if(!head) return nullptr;
        if(!head->next || m == n) return head;
        ListNode* dummy = new ListNode(-1);
        dummy->next = head;
        int step = n - m;
        ListNode* pre_tail = dummy; // 记录反转子链表的前驱，即1
        while(--m){
            pre_tail = pre_tail->next;
        }
        ListNode* pre = pre_tail->next;
        if(!pre) return head; // 不需要反转
        ListNode* mid_tail = pre; // 记录子链表的头结点，反转后变成子链表的尾节点，即2
        ListNode* cur = pre->next;
        if(!cur) return head; // 不需要反转
        ListNode* post;
        while(step--){ // 反转m到n之间
            post = cur->next;
            cur->next = pre;
            pre = cur;
            cur = post;
        }
        pre_tail->next = pre; // 1指向4
        mid_tail->next = cur; // 2指向5
        return dummy->next;
    }
};
```

### 141.环形链表(easy)

给定一个链表，判断链表中是否有环。

为了表示给定链表中的环，我们使用整数 `pos` 来表示链表尾连接到链表中的位置（索引从 0 开始）。 如果 `pos` 是 `-1`，则在该链表中没有环。

进阶：

你能用 *O(1)*（即，常量）内存解决此问题吗？

第一次尝试，哈希表

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

空间复杂度为O(1)的双指针解法

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

### 142. 环形链表 II(mdium)

给定一个链表，返回链表开始入环的第一个节点。 如果链表无环，则返回 null。

为了表示给定链表中的环，我们使用整数 pos 来表示链表尾连接到链表中的位置（索引从 0 开始）。 如果 pos 是 -1，则在该链表中没有环。

说明：不允许修改给定的链表。

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
    ListNode *detectCycle(ListNode *head) {
        if(!head || !head->next) return nullptr;
        ListNode* slow = head;
        ListNode* fast = head;
        while(true){
            slow = slow->next;
            if(!fast || !fast->next) return nullptr;
            fast = fast->next->next;
            if(slow == fast) break;
        }
        if(!fast->next) return nullptr;
        int cnt = 1; // 环中cnt个节点
        fast = fast->next;
        while(fast != slow){
            fast = fast->next;
            ++cnt;
        }
        slow = head, fast = head;
        while(cnt--) fast = fast->next; // fast先走cnt步
        while(slow != fast){
            slow = slow->next;
            fast = fast->next;
        }
        return slow;
    }
};
```

y总的双指针优化，不用计算环的大小，更加巧妙

![lc142](../image/lc142.png)

```c++
class Solution {
public:
    ListNode *detectCycle(ListNode *head) {
        if (!head || !head->next) return 0;
        ListNode *first = head, *second = head;

        while (first && second)
        {
            first = first->next;
            second = second->next;
            if (second) second = second->next;
            else return 0;

            if (first == second)
            {
                first = head;
                while (first != second)
                {
                    first = first->next;
                    second = second->next;
                }
                return first;
            }
        }

        return 0;
    }
};
```

### 148. 排序链表(medium)

在 O(n log n) 时间复杂度和常数级空间复杂度下，对链表进行排序。

示例 1:

输入: 4->2->1->3
输出: 1->2->3->4
示例 2:

输入: -1->5->3->4->0
输出: -1->0->3->4->5

快排需要栈空间，空间复杂度需要O(nlogn)，所以不符合题目要求，但这里也一并记录一下，来自ycx

其实链表快排比数组快排更容易想也更容易写

首先选取枢纽，假设就取第一个为枢纽，值为value，然后开辟三个链表，它们记录着小于val、等于val、大于val，只需要遍历一遍链表就可以得到这样的三个子链表，这其实就是**划分(partition)**

对于小于val与大于val的两个子链表，递归地去解决

链表快排是稳定的，因为是尾插，而不像数组快排那样交换

![sortList](../image/sortList.png)

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
    ListNode* get_tail(ListNode* head){
        while(head->next) head = head->next;
        return head;
    }
    ListNode* sortList(ListNode* head) {
        if(!head || !head->next) return head;
        auto left = new ListNode(-1); // 三个dummy节点，指向三个子链表头
        auto mid = new ListNode(-1);
        auto right = new ListNode(-1);
        auto ltail = left; // 三个尾节点，以供插入
        auto mtail = mid;
        auto rtail = right;
        int val = head->val;
        for(auto p = head; p; p = p->next){
            if(p->val < val) ltail = ltail->next = p;
            else if(p->val == val) mtail = mtail->next = p;
            else rtail = rtail->next = p;
        }
        ltail->next = mtail->next = rtail->next = nullptr; // 三个链表的尾后节点为nullptr

        // 分治
        left->next = sortList(left->next); // 返回排序后的子链表头部，放在left后面
        right->next = sortList(right->next);

        // 合并，拼接三个链表
        get_tail(left)->next = mid->next; // 因为mtail在左边子链表排序完后可能会变，所以这里要用一个函数
        get_tail(mid)->next = right->next;

         // 释放空间
        auto p = left->next;
        delete left;
        delete mid;
        delete right;

        return p;
    }
};
```

归并排序的时间复杂度也只需要O(nlogn)，用迭代方式可以实现额外空间复杂度为O(1)

TODO

### 160. 相交链表(easy)

编写一个程序，找到两个单链表相交的起始节点。

假设c为公共部分长度，a、b为各自独有的子长度

一般解法：先计算两个链表的长度，然后让长度长的指针先走完长度差的距离，第一次相遇就是答案了。总共经历了2(a+b+c)步。

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
    ListNode *getIntersectionNode(ListNode *headA, ListNode *headB) {
        if(!headA || !headB) return nullptr;
        ListNode* curA = headA;
        ListNode* curB = headB;
        int lenA = 1;
        int lenB = 1;
        while(curA){
            curA = curA->next;
            ++lenA;
        }
        while(curB){
            curB = curB->next;
            ++lenB;
        }
        int diff = abs(lenA - lenB);
        curA = headA, curB = headB;
        if(lenA > lenB){
            while(diff--) curA = curA->next;
        }
        else{
            while(diff--) curB = curB->next;
        }
        while(curA && curB){
            if(curA == curB) return curA;
            curA = curA->next;
            curB = curB->next;
        }
        return nullptr;
    }
};
```

y总的巧妙双指针

![lc160](../image/lc160.png)

```c++
class Solution {
public:
    ListNode *getIntersectionNode(ListNode *headA, ListNode *headB) {
        ListNode *p = headA, *q = headB;
        while (p != q)
        {
            if (p) p = p->next;
            else p = headB;
            if (q) q = q->next;
            else q = headA;
        }
        return p;
    }
};
```

### 206.反转链表(easy)

反转一个单链表。

**示例:**

```c++
输入: 1->2->3->4->5->NULL
输出: 5->4->3->2->1->NULL
```

**进阶:**
你可以迭代或递归地反转链表。你能否用两种方法解决这道题？

 迭代，第一次尝试，8ms（战胜97.44%的cpp）

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

 迭代，代码优化，效率差不多

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
            temp = curr->next; // 防止断链
            curr->next = prev;
            prev = curr;
            curr = temp;
        }
        return prev;
    }
};
```

 递归

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

```c++
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

二刷，递归用的做法有点不太一样，从头往后递归，用到一个递归辅助函数，其实与迭代的思路是一样，是为了递归而递归写的代码

```c++
class Solution {
public:
    ListNode* reverseList(ListNode* head) {
        if(!head) return nullptr;
        if(!head->next) return head;
        return core(head, nullptr);
    }
    ListNode* core(ListNode* cur, ListNode* pre){
        if(!cur) return pre;
        ListNode* post = cur->next;
        cur->next = pre;
        return core(post, cur);
    }
};
```

### 234.回文链表(easy)

请判断一个链表是否为回文链表。

**示例 1:**

```c++
输入: 1->2
输出: false
```

**示例 2:**

```c++
输入: 1->2->2->1
输出: true
```

**进阶：**
你能否用 O (n) 时间复杂度和 O (1) 空间复杂度解决此题？

 第一次尝试，O(n)时间，O(n)空间

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

 优化，O(n)时间，O(1)空间

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

### 237.删除链表中的节点(easy)

请编写一个函数，使其可以删除某个链表中给定的（非末尾）节点，你将只被给定要求被删除的节点。

现有一个链表 -- head = [4,5,1,9]，它可以表示为:

![img](https://assets.leetcode-cn.com/aliyun-lc-upload/uploads/2019/01/19/237_example.png)

示例 1:

输入: head = [4,5,1,9], node = 5
输出: [4,1,9]
解释: 给定你链表中值为 5 的第二个节点，那么在调用了你的函数之后，该链表应变为 4 -> 1 -> 9.

示例 2:

输入: head = [4,5,1,9], node = 1
输出: [4,5,9]
解释: 给定你链表中值为 1 的第三个节点，那么在调用了你的函数之后，该链表应变为 4 -> 5 -> 9.

说明:

- 链表至少包含两个节点。
- 链表中所有节点的值都是唯一的。
- 给定的节点为非末尾节点并且一定是链表中的一个有效节点。
- 不要从你的函数中返回任何结果。

唯一解

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

如果考虑C++的指针特性，可以用解引用一行代码解决，结构体的等号直接赋值即可

```c++
void deleteNode(ListNode* node){
    *(node) = *(node->next);
}
```

## 树

### 88.合并两个有序数组

给定两个有序整数数组 *nums1* 和 *nums2*，将 *nums2* 合并到 *nums1* 中*，*使得 *num1* 成为一个有序数组。

**说明:**

- 初始化 *nums1* 和 *nums2* 的元素数量分别为 *m* 和 *n*。
- 你可以假设 *nums1* 有足够的空间（空间大小大于或等于 *m + n*）来保存 *nums2* 中的元素。

**示例:**

```c++
输入:
nums1 = [1,2,3,0,0,0], m = 3
nums2 = [2,5,6],       n = 3

输出: [1,2,2,3,5,6]
```

 最朴素的解法，合并数组+排序

思路：非常符合直觉，但时间复杂度较差，为O((n + m)log(n+m)。这是由于这种方法没有利用两个数组本身已经有序这一点，不太推荐

 第一次尝试，两个指针遍历

思路：对于nums2的每一个元素，在nums1中确定插入的位置，在这里要用到容器的插入insert与resize函数，这种解法只能说完成了题目，用到了特定的容器操作，不具备一般性

```c++
class Solution {
public:
    void merge(vector<int>& nums1, int m, vector<int>& nums2, int n) {
        auto it = nums1.begin();
        nums1.resize(m);
        for(int j = 0; j < n; ++j){
            while(nums2[j] >= *it && it != nums1.end()) ++it;
            it = nums1.insert(it, nums2[j]);
            ++it;
        }
    }
};
```

 尝试改进

思路：如果不允许用容器的resize操作，那nums1的数据要在其他地方存储下来，这就需要O(m)的额外空间，时间复杂度仍是O(n+m)

```c++
class Solution {
public:
    void merge(vector<int>& nums1, int m, vector<int>& nums2, int n) {
        vector<int> temp;
        for(int i = 0; i < m; ++i){
            temp.push_back(nums1[i]);
        }
        for(int i = 0, j = 0, k = 0; k < m + n; ++k){
            if(i == m){
                while(j < n) nums1[k++] = nums2[j++];
                break;
            }
            if(j == n){
                while(i < m) nums1[k++] = temp[i++];
                break;
            }
            if(temp[i] < nums2[j]){
                nums1[k] = temp[i++];
            }
            else{
                nums1[k] = nums2[j++];
            }
        }
    }
};
```

 再改进，最佳版本

思路：既然nums1后面的n个位置都为0，那么从后往前遍历，把较大值放在nums1的末尾，这样nums1的实际值就不会被覆盖

```c++
class Solution {
public:
    void merge(vector<int>& nums1, int m, vector<int>& nums2, int n) {
        if(m == 0){
            nums1 = nums2;
            return;
        }
        if(n == 0) return;
        for(int i = m - 1, j = n - 1, k = m + n - 1; k >= 0; --k){
            if(i < 0){
                while(j >= 0) nums1[k--] = nums2[j--];
                return;
            }
            if(j < 0){
                while(i >= 0) nums1[k--] = nums1[i--];
                return;
            }
            if(nums1[i] > nums2[j]){
                nums1[k] = nums1[i--];
            }
            else{
                nums1[k] = nums2[j--];
            }
        }
    }
};
```

### 94. 二叉树的中序遍历(medium)

给定一个二叉树，返回它的中序 遍历。

示例:

输入: [1,null,2,3]
   1
    \
     2
    /
   3

输出: [1,3,2]
进阶: 递归算法很简单，你可以通过迭代算法完成吗

根据中序遍历的顺序，对于任一结点，优先访问其左孩子，而左孩子结点又可以看做一根结点，然后继续访问其左孩子结点，直到遇到左孩子结点为空的结点才进行访问，然后按相同的规则访问其右子树。因此其处理过程如下：

对于任一结点P，

1)若其左孩子不为空，则将P入栈并将P的左孩子置为当前的P，然后对当前结点P再进行相同的处理；
2)若其左孩子为空，则取栈顶元素并进行出栈操作，访问该栈顶结点，然后将当前的P置为栈顶结点的右孩子；
3)直到P为NULL并且栈为空则遍历结束

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
    vector<int> inorderTraversal(TreeNode* root) {
        if(!root) return vector<int>();
        vector<int> res;
        stack<TreeNode*> s;
        TreeNode* cur = root;
        while(cur || !s.empty()){
            while(cur){ // 1)
                s.push(cur);
                cur = cur->left;
            }
            cur = s.top(); // 2)
            s.pop();
            res.push_back(cur->val);
            cur = cur->right;
        }
        return res;
    }
};
```

### 98.验证二叉搜索树(medium)

给定一个二叉树，判断其是否是一个有效的二叉搜索树。

假设一个二叉搜索树具有如下特征：

- 节点的左子树只包含**小于**当前节点的数。
- 节点的右子树只包含**大于**当前节点的数。
- 所有左子树和右子树自身必须也是二叉搜索树。

**示例 1:**

```c++
输入:
    2
   / \
  1   3
输出: true
```

**示例 2:**

```c++
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

 第一次尝试，递归函数传入哈希表

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

 优化，递归函数传入上下界

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

 最佳版本，递归的中序遍历

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

### 101.对称二叉树(medium,based on 98)

给定一个二叉树，检查它是否是镜像对称的。

例如，二叉树 `[1,2,2,3,4,4,3]` 是对称的。

```c++
    1
   / \
  2   2
 / \ / \
3  4 4  3
```

但是下面这个 `[1,2,2,null,3,null,3]` 则不是镜像对称的:

```c++
    1
   / \
  2   2
   \   \
   3    3
```

说明:

如果你可以运用递归和迭代两种方法解决这个问题，会很加分。

第一次尝试，查看前序遍历和后序遍历是否相等，用的递归方法，非常繁琐

递归最佳版本

思路：左右同时出发，双管齐下！左右根节点是否相同，左根的左子树是否等于右根的右子树，左根的右子树是否等于右根的左子树

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
        if(!p || !q) return false;  // one is nullptr, the other is not, so return false
        return p->val == q->val && isSym(p->left, q->right) && isSym(p->right, q->left);
    }
};
```

迭代最佳版本

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

y总的思路：

用栈模拟递归，对根节点的左子树，我们用中序遍历；对根节点的右子树，我们用反中序遍历。则两个子树互为镜像，当且仅当同时遍历两课子树时，对应节点的值相等。

```c++
class Solution {
public:
    bool isSymmetric(TreeNode* root) {
        if(root == nullptr) return true;
        stack<TreeNode*> left, right;
        TreeNode* l = root->left;
        TreeNode* r = root->right;
        while(l || r || !left.empty() || !right.empty()){
            while(l && r){
                left.push(l);
                l = l->left;
                right.push(r);
                r = r->right;
            }
            if(l || r) return false; // l与r中有一个为空，另一个非空，则肯定不对称
            l = left.top();
            r = right.top();
            left.pop();
            right.pop();
            if(l->val != r->val) return false;
            l = l->right;
            r = r->left;
        }
        return true;
    }
};
```

### 102.二叉树的层次遍历(medium)

给定一个二叉树，返回其按层次遍历的节点值。 （即逐层地，从左到右访问所有节点）。

例如:
给定二叉树: `[3,9,20,null,null,15,7]`,

```c++
    3
   / \
  9  20
    /  \
   15   7
```

返回其层次遍历结果：

```c++
[
  [3],
  [9,20],
  [15,7]
]
```

第一次尝试，BFS+层数记录

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

y总的解法，不需要双端队列，只需要调用size函数即可知道下一层的个数

宽度优先遍历，一层一层来做。即：

- 将根节点插入队列中；
- 创建一个新队列，用来按顺序保存下一层的所有子节点；
- 对于当前队列中的所有节点，按顺序依次将儿子加入新队列，并将当前节点的值记录在答案中；
- 重复步骤2-3，直到队列为空为止。

```c++
class Solution {
public:
    vector<vector<int>> levelOrder(TreeNode* root) {
        vector<vector<int>> res;
        if (!root) return res;
        queue<TreeNode*> q;
        q.push(root);
        while (!q.empty())
        {
            int len = q.size(); // 下一层有多少个元素
            vector<int> level;
            for (int i = 0; i < len; i ++ )
            {
                auto t = q.front();
                q.pop();
                level.push_back(t->val);
                if (t->left) q.push(t->left);
                if (t->right) q.push(t->right);
            }
            if (level.size()) res.push_back(level);
        }
        return res;
    }
};
```

### 104.二叉树的最大深度

给定一个二叉树，找出其最大深度。

二叉树的深度为根节点到最远叶子节点的最长路径上的节点数。

**说明:** 叶子节点是指没有子节点的节点。

**示例：**
给定二叉树 `[3,9,20,null,null,15,7]`，

```c++
    3
   / \
  9  20
    /  \
   15   7
```

返回它的最大深度 3 。

 第一次尝试，递归，前序遍历

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

 代码优化

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

 这题还可以用非递归的DFS解决，但需要栈这种数据结构，也可以使用广度优先搜索（BFS），但需要队列这种数据结构

### 105. 从前序与中序遍历序列构造二叉树(medium)

根据一棵树的前序遍历与中序遍历构造二叉树。

注意:
你可以假设树中没有重复的元素。

例如，给出

前序遍历 preorder = [3,9,20,15,7]
中序遍历 inorder = [9,3,15,20,7]
返回如下的二叉树：

```c++
    3
   / \
  9  20
    /  \
   15   7
```

y总用哈希表存储了中序遍历各元素的位置，这样查找更快，代码也更简洁一点，我加了点注释

```c++
class Solution {
public:
    unordered_map<int,int> pos; // 元素-位置，没有重复的元素，所以可以用哈希表，这样查找时可以更快
    TreeNode* buildTree(vector<int>& preorder, vector<int>& inorder) {
        int n = preorder.size();
        for (int i = 0; i < n; i ++ )
            pos[inorder[i]] = i;
        return dfs(preorder, inorder, 0, n - 1, 0, n - 1);
    }
    TreeNode* dfs(vector<int>&pre, vector<int>&in, int pl, int pr, int il, int ir)
    {
        if (pl > pr) return NULL;
        int k = pos[pre[pl]] - il; // 左子树共有k个元素
        TreeNode* root = new TreeNode(pre[pl]); // 构造当前节点
        root->left = dfs(pre, in, pl + 1, pl + k, il, il + k - 1); // 递归构造当前节点的左子树
        root->right = dfs(pre, in, pl + k + 1, pr, il + k + 1, ir); // 递归构造当前节点的右子树
        return root; // 返回当前节点
    }
};
```

### 108.将有序数组转换为二叉搜索树

将一个按照升序排列的有序数组，转换为一棵高度平衡二叉搜索树。

本题中，一个高度平衡二叉树是指一个二叉树*每个节点* 的左右两个子树的高度差的绝对值不超过 1。

**示例:**

```c++
给定有序数组: [-10,-3,0,5,9],

一个可能的答案是：[0,-3,9,-10,null,5]，它可以表示下面这个高度平衡二叉搜索树：

      0
     / \
   -3   9
   /   /
 -10  5
```

 第一次尝试，两个指针从数组中间往两边出发

思路：两个指针low、high，从数据中点向两边移动，用两个队列存储当前节点，节点的值即为指针对应的值

最后发现思路是错的，比如给定有序数组: [-10,-3,0,5,9]，左子树的确可以像图中那样，但是右子树就错了

```c++
      0
     / \
   -3   5
   /   /
 -10  9
```

 第二次尝试，递归二分

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

### 124. 二叉树中的最大路径和(hard, based on 543)

给定一个非空二叉树，返回其最大路径和。

本题中，路径被定义为一条从树中任意节点出发，达到任意节点的序列。该路径至少包含一个节点，且不一定经过根节点。

示例 1:

输入: [1,2,3]

```c++
       1
      / \
     2   3
```

输出: 6
示例 2:

输入: [-10,9,20,null,null,15,7]

```c++
   -10
   / \
  9  20
    /  \
   15   7
```

输出: 42

与lc124模板一样

(递归，树的遍历) O(n2)

树中每条路径，都存在一个离根节点最近的点，我们把它记为割点，用割点可以将整条路径分为两部分：从该节点向左子树延伸的路径，和从该节点向右子树延伸的部分，而且两部分都是自上而下延伸的。

我们可以递归遍历整棵树，递归时维护从每个节点开始往下延伸的最大路径和。
对于每个点，递归计算完左右子树后，我们将左右子树维护的两条最大路径，和该点拼接起来，就可以得到以这个点为割点的最大路径。

然后维护从这个点往下延伸的最大路径：从左右子树的路径中选择权值大的一条延伸即可。

时间复杂度分析：每个节点仅会遍历一次，所以时间复杂度是 O(n)。

```c++
class Solution {
public:
    int ans;
    int maxPathSum(TreeNode* root) {
        ans = INT_MIN;
        dfs(root);
        return ans;
    }
    int dfs(TreeNode* root){
        if (!root) return 0;
        int left = max(0, dfs(root->left)); // 左子树最大值
        int right = max(0, dfs(root->right)); // 右子树最大值
        ans = max(ans, left + root->val + right); // 更新答案
        return root->val + max(left, right); // 返回当前节点为最高点的最大值
    }
};
```

### 173. 二叉搜索树迭代器（medium, based on 94)

实现一个二叉搜索树迭代器。你将使用二叉搜索树的根节点初始化迭代器。

调用 next() 将返回二叉搜索树中的下一个最小的数。

示例：

BSTIterator iterator = new BSTIterator(root);
iterator.next();    // 返回 3
iterator.next();    // 返回 7
iterator.hasNext(); // 返回 true
iterator.next();    // 返回 9
iterator.hasNext(); // 返回 true
iterator.next();    // 返回 15
iterator.hasNext(); // 返回 true
iterator.next();    // 返回 20
iterator.hasNext(); // 返回 false

提示：

next() 和 hasNext() 操作的时间复杂度是 O(1)，并使用 O(h) 内存，其中 h 是树的高度。
你可以假设 next() 调用总是有效的，也就是说，当调用 next() 时，BST 中至少存在一个下一个最小的数。

算法：（栈），把lc124的迭代代码拆分一下即可

用栈来模拟BST的中序遍历过程，当前结点进栈，代表它的左子树正在被访问。栈顶结点代表当前访问到的结点。

求后继时，只需要弹出栈顶结点，取出它的值。然后将它的右儿子以及右儿子的左儿子等一系列结点进栈，这一步代表找右子树中的最左子结点，并记录路径上的所有结点。
判断是否还存在后继只需要判断栈是否为空即可，因为栈顶结点是下一次即将被访问到的结点。

```c++
/**
 * Definition for binary tree
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode(int x) : val(x), left(NULL), right(NULL) {}
 * };
 */
class BSTIterator {
public:
    stack<TreeNode*> st;
    BSTIterator(TreeNode *root) {
        TreeNode *p = root;
        while (p) {
            st.push(p);
            p = p -> left;
        }
    }

    /** @return whether we have a next smallest number */
    bool hasNext() {
        return !st.empty();
    }

    /** @return the next smallest number */
    int next() {
        TreeNode *cur = st.top();
        st.pop();
        int v = cur -> val;
        cur = cur -> right;
        while (cur) {
            st.push(cur);
            cur = cur -> left;
        }
        return v;
    }
};

/**
 * Your BSTIterator will be called like this:
 * BSTIterator i = BSTIterator(root);
 * while (i.hasNext()) cout << i.next();
 */
```

### 236. 二叉树的最近公共祖先(medium)

给定一个二叉树, 找到该树中两个指定节点的最近公共祖先。

百度百科中最近公共祖先的定义为：“对于有根树 T 的两个结点 p、q，最近公共祖先表示为一个结点 x，满足 x 是 p、q 的祖先且 x 的深度尽可能大（一个节点也可以是它自己的祖先）。”

例如，给定如下二叉树:  root = [3,5,1,6,2,0,8,null,null,7,4]

示例 1:

输入: root = [3,5,1,6,2,0,8,null,null,7,4], p = 5, q = 1
输出: 3
解释: 节点 5 和节点 1 的最近公共祖先是节点 3。
示例 2:

输入: root = [3,5,1,6,2,0,8,null,null,7,4], p = 5, q = 4
输出: 5
解释: 节点 5 和节点 4 的最近公共祖先是节点 5。因为根据定义最近公共祖先节点可以为节点本身。

说明:

所有节点的值都是唯一的。
p、q 为不同节点且均存在于给定的二叉树中。

(递归) O(n)

考虑在左子树和右子树中查找这两个节点，如果两个节点分别位于左子树和右子树，则最低公共祖先为自己(root)，若左子树中两个节点都找不到，说明最低公共祖先一定在右子树中，反之亦然。考虑到二叉树的递归特性，因此可以通过递归来求得。

时间复杂度分析：需要遍历树，复杂度为 O(n)

```c++
class Solution {
public:
    TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
        if(root == nullptr || root == p || root == q) return root;
        TreeNode* left = lowestCommonAncestor(root->left, p, q);
        TreeNode* right = lowestCommonAncestor(root->right, p, q);
        if(!left) return right;
        if(!right) return left;
        return root;
    }
};
```

### 297. 二叉树的序列化与反序列化

序列化是将一个数据结构或者对象转换为连续的比特位的操作，进而可以将转换后的数据存储在一个文件或者内存中，同时也可以通过网络传输到另一个计算机环境，采取相反方式重构得到原数据。

请设计一个算法来实现二叉树的序列化与反序列化。这里不限定你的序列 / 反序列化算法执行逻辑，你只需要保证一个二叉树可以被序列化为一个字符串并且将这个字符串反序列化为原始的树结构。

示例:

你可以将以下二叉树：

```c++
    1
   / \
  2   3
     / \
    4   5
```

序列化为 "[1,2,3,null,null,4,5]"
提示: 这与 LeetCode 目前使用的方式一致，详情请参阅 LeetCode 序列化二叉树的格式。你并非必须采取这种方式，你也可以采用其他的方法解决这个问题。

说明: 不要使用类的成员 / 全局 / 静态变量来存储状态，你的序列化和反序列化算法应该是无状态的。

算法：(先序遍历序列化) O(n)

我们按照先序遍历，即可完整唯一的序列化一棵二叉树。但空结点需要在序列化中有所表示。

例如样例中的二叉树可以表示为 "1,2,n,n,3,4,n,n,5,n,n,"，其中n可以去掉，进行简化。

通过DFS即可序列化该二叉树；反序列化时，按照','作为分隔，构造当前结点后分别通过递归构造左右子树即可。

时间复杂度：每个结点仅遍历两次，故时间复杂度为O(n)。

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
class Codec {
public:
    // Encodes a tree to a single string.
    string serialize(TreeNode* root) {
        string res;
        dfs1(root, res);
        return res;
    }
    void dfs1(TreeNode* root, string& res){
        if (!root){
            res += "#,";
            return;
        }
        res += to_string(root->val) + ',';
        dfs1(root->left, res);
        dfs1(root->right, res);
    }

    // Decodes your encoded data to tree.
    TreeNode* deserialize(string data) {
        int u = 0;
        return dfs2(data, u);
    }
    TreeNode* dfs2(string &data, int &u)
    {
        if (data[u] == '#'){
            u += 2;
            return NULL;
        }
        int t = 0;
        bool is_minus = false;
        if (data[u] == '-'){
            is_minus = true;
            u ++;
        }
        while (data[u] != ','){
            t = t * 10 + data[u] - '0';
            u ++ ;
        }
        u ++ ; // 跳过','
        if (is_minus) t = -t;
        auto root = new TreeNode(t);
        root->left = dfs2(data, u);
        root->right = dfs2(data, u);
        return root;
    }
};
// Your Codec object will be instantiated and called as such:
// Codec codec;
// codec.deserialize(codec.serialize(root));
```

### 543. 二叉树的直径(medium)

给定一棵二叉树，你需要计算它的直径长度。一棵二叉树的直径长度是任意两个结点路径长度中的最大值。这条路径可能穿过也可能不穿过根结点。

示例 :
给定二叉树

```c++
          1
         / \
        2   3
       / \
      4   5
```

返回 3, 它的长度是路径 [4,2,1,3] 或者 [5,2,1,3]。

注意：两结点之间的路径长度是以它们之间边的数目表示。

在求树的深度的过程中，保存左右子深度之和的最大值，最后的ans即为最长路径

因为需要返回当前节点为最高点的最大长度，而返回值只能有一个（不考虑pair、vector什么的），所以ans作为全局变量

```c++
class Solution {
public:
    //递归函数的返回值定义为从当前结点到叶子结点的最大长度
    int dfs(TreeNode* node, int &ans)
    {
        if (!node) return 0;
        int d1 = dfs(node->left, ans); // 左子树最大长度
        int d2 = dfs(node->right, ans); // 右子树最大长度
        ans = max(ans, d1 + d2); // 更新全局答案
        return max(d1, d2) + 1; // 返回以当前节点为最高点的最大长度
    }
    int diameterOfBinaryTree(TreeNode* root) {
        int ans = 0;
        dfs(root, ans);
        return ans;  
    }
};
```

## 动态规划

### 5.最长回文子串

给定一个字符串 s，找到 s 中最长的回文子串。你可以假设 s 的最大长度为 1000。

示例 1：

输入: "babad"
输出: "bab"
注意: "aba" 也是一个有效答案。
示例 2：

输入: "cbbd"
输出: "bb"

 第一次尝试，类中心扩展的思想，超时

思路：设有一个中心点，在字符串中从左到右移动，每次在中心点向两边展开，检查两边的数字是否相等，若是则继续展开，直到不能展开，与已记录的最长回文子串比较长度，要注意，回文子串分为"abba"和"abcba"两种形式，所以有两个双层for循环

```c++
class Solution
{
public:
    string longestPalindrome(string s)
    {
        string longest = "";
        string temp = "";
        // check odd palindrome
        for (int i = 0; i < s.size(); ++i)
        {
            temp = s[i];
            for (int j = 1;; ++j)
            {
                if (i - j < 0 || i + j > s.size() - 1)
                {
                    if (temp.size() > longest.size())
                    {
                        longest = temp;
                    }
                    break;
                }
                if (s[i - j] != s[i + j])
                {
                    if (temp.size() > longest.size())
                    {
                        longest = temp;
                    }
                    break;
                }
                temp = s[i - j] + temp;
                temp = temp + s[i + j];
            }
        }
        // check even palindrome
        for (int i = 0; i < s.size(); ++i)
        {
            temp = "";
            for (int j = 0;; ++j)
            {
                if (i - j < 0 || i + 1 + j > s.size() - 1)
                {
                    if (temp.size() > longest.size())
                    {
                        longest = temp;
                    }
                    break;
                }
                if (s[i - j] != s[i + 1 + j])
                {
                    if (temp.size() > longest.size())
                    {
                        longest = temp;
                    }
                    break;
                }
                temp = s[i - j] + temp;
                temp = temp + s[i + 1 + j];
            }
        }
        return longest;
    }
};
```

运行结果：

Time Limit Exceeded

91/103 cases passed (N/A)

Testcase

"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"

 中心扩展

思路：上个解法的思路是对的，但是耗时太多，需要优化时间，上一步用到了太多了字符串拷贝，实际上只需要序号就行了，时间复杂度O(n^2)

```c++
class Solution
{
public:
    string longestPalindrome(string s)
    {
        if (s.empty())
            return "";
        if (s.size() == 1)
            return s;
        int start = 0, maxLen = 0;
        for (int i = 0; i < s.size(); ++i)
        {
            int len1 = expandAroundCenter(s, i, i);
            int len2 = expandAroundCenter(s, i, i + 1);
            int len = len1 > len2 ? len1 : len2;
            if (len > maxLen)
            {
                start = i - (len - 1) / 2;
                maxLen = len;
            }
        }
        return s.substr(start, maxLen);
    }
    int expandAroundCenter(string &s, int left, int right)
    {
        while (left >= 0 && right < s.size() && s[left] == s[right])
        {
            --left;
            ++right;
        }
        return right - left - 1;
    }
};
```

103/103 cases passed (24 ms)
Your runtime beats 86.17 % of cpp submissions
Your memory usage beats 98.16 % of cpp submissions (8.6 MB)

 最长回文子串的动态规划

思路：定义p[i][j] = true if s[i,j]是回文串, = false if s[i,j]不是回文串，于是有递推公式，p[i][j]=p[i+1][j-1]&&s[i]==s[j]

- 定义 “状态”，这里 “状态” 数组是二维数组。

    dp[l][r] 表示子串 s[l, r]（包括区间左右端点）是否构成回文串，是一个二维布尔型数组。即如果子串 s[l, r] 是回文串，那么 dp[l][r] = true。

- 找到 “状态转移方程”。

    首先，我们很清楚一个事实：

    1、当子串只包含 1 个字符，它一定是回文子串；

    2、当子串包含 2 个以上字符的时候：如果 s[l, r] 是一个回文串，例如 “abccba”，那么这个回文串两边各往里面收缩一个字符（如果可以的话）的子串 s[l + 1, r - 1] 也一定是回文串，即：如果 dp[l][r] == true 成立，一定有 dp[l + 1][r - 1] = true 成立。

    根据这一点，我们可以知道，给出一个子串 s[l, r] ，如果 s[l] != s[r]，那么这个子串就一定不是回文串。如果 s[l] == s[r] 成立，就接着判断 s[l + 1] 与 s[r - 1]，这很像中心扩散法的逆方法。

    事实上，当 s[l] == s[r] 成立的时候，dp[l][r] 的值由 dp[l + 1][r - l] 决定，这一点也不难思考：当左右边界字符串相等的时候，整个字符串是否是回文就完全由 “原字符串去掉左右边界” 的子串是否回文决定。但是这里还需要再多考虑一点点：“原字符串去掉左右边界” 的子串的边界情况。

    1、当原字符串的元素个数为 3 个的时候，如果左右边界相等，那么去掉它们以后，只剩下 1 个字符，它一定是回文串，故原字符串也一定是回文串；

    2、当原字符串的元素个数为 2 个的时候，如果左右边界相等，那么去掉它们以后，只剩下 0 个字符，显然原字符串也一定是回文串。

    把上面两点归纳一下，只要 s[l + 1, r - 1] 至少包含两个元素，就有必要继续做判断，否则直接根据左右边界是否相等就能得到原字符串的回文性。而 “s[l + 1, r - 1] 至少包含两个元素” 等价于 l + 1 < r - 1，整理得 l - r < -2，或者 r - l > 2。

    综上，如果一个字符串的左右边界相等，以下二者之一成立即可：
    1、去掉左右边界以后的字符串不构成区间，即 “ s[l + 1, r - 1] 至少包含两个元素” 的反面，即 l - r >= -2，或者 r - l <= 2；
    2、去掉左右边界以后的字符串是回文串，具体说，它的回文性决定了原字符串的回文性。

    于是整理成 “状态转移方程”：

    dp[l, r] = (s[l] == s[r] and (l - r >= -2 or dp[l + 1, r - 1]))

    或者

    dp[l, r] = (s[l] == s[r] and (r - l <= 2 or dp[l + 1, r - 1]))

```c++
class Solution
{
public:
    string longestPalindrome(string s)
    {
        if (s.size() == 1)
            return s;
        int len = s.size();
        int begin = 0, maxLen = 1;
        vector<vector<bool>> dp(len, vector<bool>(len, false));
        for(int r = 1; r < len; ++r){
            for(int l = 0; l < r; ++l){
                dp[l][r] = (s[l] == s[r] && (r - l <= 2 || dp[l + 1][r - 1]));
                if (dp[l][r] && r + 1 - l > maxLen)
                {
                    begin = l;
                    maxLen = r + 1 - l;
                }
            }
        }
        return s.substr(begin, maxLen);
    }  
};
```

103/103 cases passed (496 ms)
Your runtime beats 6.83 % of cpp submissions
Your memory usage beats 39.16 % of cpp submissions (18.8 MB)

### 53.最大子数组/最大连续子序列/最大子段和

给定一个整数数组 nums ，找到一个具有最大和的连续子数组（子数组最少包含一个元素），返回其最大和。

示例:

输入: [-2,1,-3,4,-1,2,1,-5,4],
输出: 6
解释: 连续子数组 [4,-1,2,1] 的和最大，为 6。
进阶:

如果你已经实现复杂度为 O (n) 的解法，尝试使用更为精妙的分治法求解。

 最大子序和的暴力解法

暴力解题，明显时间为O(n^2)，只击败8%，注意这里用到了INT_MIN，有人觉得：“寻找最大最小值的题目，初始值一定要定义成理论上的最小最大值”

```c++
class Solution {
public:
    int maxSubArray(vector<int>& nums) {
        // brute force
        if(nums.size() <= 0) return 0;
        if(nums.size() == 1) return nums[0];
        int maxSub = INT_MIN;
        int tempSub = 0;
        for(int i = 0; i < nums.size(); ++i){
            for(int j = i; j < nums.size(); ++j)
            {
                tempSub += nums[j];
                if(tempSub > maxSub) maxSub = tempSub;
            }
            tempSub = 0;
        }
        return maxSub;
    }
};
```

 最大子序和的动态规划

思路：设dp[i]是以i结尾（必须）的子序列的最大值，那么有状态转移方程`dp[i]=max{dp[i-1]+nums[i], nums[i]}`，时间是O(n)，空间是O(1)

```c++
class Solution
{
public:
    int maxSubArray(vector<int> &nums)
    {
        // dynamic programming
        if (nums.size() <= 0)
            return 0;
        if (nums.size() == 1)
            return nums[0];
        int maxSub = INT_MIN;
        int tempSub = 0;
        for (int i = 0; i < nums.size(); ++i)
        {
            if (tempSub > 0)
            {
                tempSub += nums[i];
            }
            else
            {
                tempSub = nums[i];
            }
            maxSub = maxSub > tempSub ? maxSub : tempSub;
        }
        return maxSub;
    }
};
```

202/202 cases passed (12 ms)
Your runtime beats 46.05 % of cpp submissions
Your memory usage beats 81.66 % of cpp submissions (9.2 MB)

 最大子序和的分治法

思路：分治法解决问题的模板：定义基本情况。将问题分解为子问题并递归地解决它们。合并子问题的解以获得原始问题的解。最大子序和出现在left~mid之间，或者穿过mid，或者mid+1~right之间，对于全在左边或全在右边的情况，递归即可，对于穿过mid的情况，从mid开始，往两边贪心求解各自的最大子序和，然后再加起来，即为穿过mid的最大子序和，分治法要注意临界情况

时间复杂度O(nlogn)，空间复杂度O(logn)，递归时栈使用的空间

```c++
class Solution
{
public:
    int maxSubArray(vector<int> &nums)
    {
        // divide-and-conquer
        if (nums.size() <= 0)
            return 0;
        if (nums.size() == 1)
            return nums[0];
        return maxSubHelper(nums, 0, nums.size() - 1);
    }
    int maxSubHelper(vector<int> &nums, int left, int right)
    {
        if (left == right)
            return nums[left];
        int mid = (left + right) / 2;
        int leftMax = maxSubHelper(nums, left, mid);
        int midMax = findMaxCrossing(nums, left, mid, right);
        int rightMax = maxSubHelper(nums, mid + 1, right);
        int result = (leftMax > midMax) ? leftMax : midMax;
        return (result > rightMax) ? result : rightMax;
    }
    int findMaxCrossing(vector<int> &nums, int left, int mid, int right)
    {
        // greedy, left side and right side, then calculate max
        int leftTempSub = 0;
        int leftMaxSub = INT_MIN;
        int rightTempSub = 0;
        int rightMaxSub = INT_MIN;
        for (int i = mid; i >= left; --i)
        {
            leftTempSub += nums[i];
            leftMaxSub = leftTempSub > leftMaxSub ? leftTempSub : leftMaxSub;
        }
        for (int i = mid + 1; i <= right; ++i)
        {
            rightTempSub += nums[i];
            rightMaxSub = rightTempSub > rightMaxSub ? rightTempSub : rightMaxSub;
        }
        return leftMaxSub + rightMaxSub;
    }
};
```

### 152. 乘积最大子数组/最大子数组积/最大子段积

给你一个整数数组 nums ，请你找出数组中乘积最大的连续子数组（该子数组中至少包含一个数字）。

示例 1:

输入: [2,3,-2,4]
输出: 6
解释: 子数组 [2,3] 有最大乘积 6。
示例 2:

输入: [-2,0,-1]
输出: 0
解释: 结果不能为 2, 因为 [-2,-1] 不是子数组。

负数乘以负数，会变成正数，所以解这题的时候我们需要维护两个变量，当前的最大值，以及最小值，最小值可能为负数，但没准下一步乘以一个负数，当前的最大值就变成最小值，而最小值则变成最大值了。

我们的动态方程可能这样：

`maxDP[i + 1] = max(maxDP[i] * A[i + 1], A[i + 1], minDP[i] * A[i + 1])`

`minDP[i + 1] = min(minDP[i] * A[i + 1], A[i + 1], maxDP[i] * A[i + 1])`

`dp[i + 1] = max(dp[i], maxDP[i + 1])`

这里，我们还需要注意元素为0的情况，如果A[i]为0，那么maxDP和minDP都为0，
我们需要从A[i + 1]重新开始。

```c++
class Solution {
public:
    int maxProduct(vector<int>& nums) {
        if(nums.empty()) return 0;
        int n = nums.size();
        int maxP = nums[0];
        int minP = nums[0];
        int ans = nums[0];
        int temp;
        for(int i = 1; i < n; ++i){
            temp = maxP; // 暂存，防止修改，给minP的计算用
            maxP = max(max(maxP*nums[i], minP*nums[i]), nums[i]);
            minP = min(min(temp*nums[i], minP*nums[i]), nums[i]);
            ans = max(ans, maxP);
        }
        return ans;
    }
};
```

### 63. 不同路径II

一个机器人位于一个 m x n 网格的左上角 （起始点在下图中标记为“Start” ）。

机器人每次只能向下或者向右移动一步。机器人试图达到网格的右下角（在下图中标记为“Finish”）。

现在考虑网格中有障碍物。那么从左上角到右下角将会有多少条不同的路径？

网格中的障碍物和空位置分别用 1 和 0 来表示。

说明：m 和 n 的值均不超过 100。

示例 1:

输入:
[
  [0,0,0],
  [0,1,0],
  [0,0,0]
]
输出: 2
解释:
3x3 网格的正中间有一个障碍物。
从左上角到右下角一共有 2 条不同的路径：

1. 向右 -> 向右 -> 向下 -> 向下
2. 向下 -> 向下 -> 向右 -> 向右

```c++
class Solution {
public:
    int uniquePathsWithObstacles(vector<vector<int>>& obstacleGrid) {
        int rows = obstacleGrid.size();
        int cols = obstacleGrid[0].size();
        vector<vector<long long>> dp(rows, vector<long long>(cols, 0)); // 有些TC太大了
        if (!obstacleGrid[0][0]) dp[0][0] = 1;
        for(int i = 0; i < rows; ++i){
            for(int j = 0; j < cols; ++j){
                if(i == 0 && j == 0) continue; // 特判
                dp[i][j] = 0;
                if(!obstacleGrid[i][j]){ // 当前格子没有阻碍物
                    if(i) dp[i][j] += dp[i-1][j]; // 不是在第一行的，才能从上往下转移
                    if(j) dp[i][j] += dp[i][j-1]; // 不是在第一列的，才能从左往右转移
                }
            }
        }
        return dp[rows-1][cols-1];
    }
};
```

空间优化，只需要O(n)

```c++
class Solution {
public:
    int uniquePathsWithObstacles(vector<vector<int>>& obstacleGrid) {
        int rows = obstacleGrid.size();
        int cols = obstacleGrid[0].size();
        if (!rows || !cols || obstacleGrid[0][0]) return 0; // 特判
        vector<long long> dp(cols);
        dp[0] = 1;
        for(int i = 0; i < rows; ++i){
            for(int j = 0; j < cols; ++j){
                if(i == 0 && j == 0) continue;
                if(obstacleGrid[i][j]){
                    dp[j] = 0;
                }
                else{
                    if(i) dp[j] = dp[j]; // 不是在第一行的，从上往下转移，其实这句可以省略
                    if(j) dp[j] += dp[j-1]; // 不是在第一列的，才能从左往右转移
                }
            }
        }
        return dp[cols-1];
    }
};
```

### 64. 最小路径和

给定一个包含非负整数的 m x n 网格，请找出一条从左上角到右下角的路径，使得路径上的数字总和为最小。

说明：每次只能向下或者向右移动一步。

示例:

输入:
[
  [1,3,1],
  [1,5,1],
  [4,2,1]
]
输出: 7
解释: 因为路径 1→3→1→1→1 的总和最小。

很简单的题，记dp[i][j]为行走到grid[i][j]的最小路径和，而dp[i][j]只有可能从dp[i-1][j]或dp[i][j-1]转移而来，所以可以用一位数组来优化，这样空间复杂度只需要O(n)，若可以修改参数，则可以在原数组上修改，那么空间复杂度为O(1)

```c++
class Solution {
public:
    int minPathSum(vector<vector<int>>& grid) {
        // if(grid.empty() || grid[0].empty()) return -1;
        int n = grid.size();
        int m = grid[0].size();
        vector<int> dp(m, 0);
        dp[0] = grid[0][0];
        for(int j = 1; j < m; ++j){
            dp[j] = dp[j-1] + grid[0][j]; // 第0行只有可能从左往右
        }
        for(int i = 1; i < n; ++i){
            for(int j = 0; j < m; ++j){
                if(j == 0) dp[j] += grid[i][j]; // 在最左边，只可能从上面转移过来
                else dp[j] = min(dp[j], dp[j-1]) + grid[i][j]; // 从上面或左边转移过来
            }
        }
        return dp[m-1];
    }
};
```

### 70.爬楼梯

假设你正在爬楼梯。需要 n 阶你才能到达楼顶。

每次你可以爬 1 或 2 个台阶。你有多少种不同的方法可以爬到楼顶呢？

注意：给定 n 是一个正整数。

示例 1：

```c++
输入： 2
输出： 2
解释： 有两种方法可以爬到楼顶。
1.  1 阶 + 1 阶
2.  2 阶
```

示例 2：

```c++
输入： 3
输出： 3
解释： 有三种方法可以爬到楼顶。
1.  1 阶 + 1 阶 + 1 阶
2.  1 阶 + 2 阶
3.  2 阶 + 1 阶
```

 动态规划，不就是找状态转移吗

思路：找动态转移，要想爬上第n阶，只有可能在第n-1阶与第n-2阶的基础上，前进一步或两步，这题求的就是有多少种可能，显然就是求个“最大值”，所以dp[i]=dp[i-1]+dp[i-2]，而dp[1]=1，dp[2]=2，所以输出是个斐波那契数列，这里可以用循环的方式写（注意swap的目的是让temp1为dp[i-2]，temp2为dp[i-1]，这样计算出来的dp[i]可以直接覆盖temp1）

```c++
class Solution {
public:
    int climbStairs(int n) {
        if(n == 1) return 1;
        if(n == 2) return 2;
        if(n == 3) return 3;
        int temp1 = 1, temp2 = 2;
        for(int i = 1; i <= n-2; ++i){
            temp1 += temp2;
            swap(temp1, temp2);
        }
        return temp2;
    }
};
```

时间复杂度：O(n)，单循环到 n 。

空间复杂度：O(1)

 递归实现

也可以用递归，但是要小心使用，像下面的代码在输入45时会超出时间限制！！！因为每个递归都分成了两个子递归，而他们其实是有重复的，白白浪费时间，时间复杂度：O(2^n)，树形递归的大小为 2^n2

```c++
class Solution {
public:
    int climbStairs(int n) {
        if(n <= 0) return 0;
        if(n == 1 || n == 2) return n;
        return climbStairs(n-1) + climbStairs(n-2);
    }
};

```

稍微优化一下，改成线性的尾递归，可以通过

```c++
class Solution {
public:
    int climbStairs(int n) {
        if (n <= 0)
            return 0;
        return recur(n);
    }

    int recur(int n, int temp1 = 1, int temp2 = 2, int curr = 3){
        if(n == 1 || n == 2)
            return n;
        if (n == curr)
            return temp1 + temp2;
        else
            return recur(n, temp2, temp1 + temp2, ++curr);
    }
};
```

时间复杂度：O(n)，树形递归的大小可以达到 n。
空间复杂度：O(n)，递归树的深度可以达到 n。

### 120. 三角形最小路径和

给定一个三角形，找出自顶向下的最小路径和。每一步只能移动到下一行中相邻的结点上。

例如，给定三角形：

[
     [2],
    [3,4],
   [6,5,7],
  [4,1,8,3]
]
自顶向下的最小路径和为 11（即，2 + 3 + 5 + 1 = 11）。

说明：

如果你可以只使用 O(n) 的额外空间（n 为三角形的总行数）来解决这个问题，那么你的算法会很加分。

题解：没有空间优化的dp

状态定义：dp[i][j]表示包含第i行第j列元素的最小路径和

初始化：dp[0][0]=triangle[0][0]

常规：triangle[i][j]一定会经过triangle[i-1][j]或者triangle[i-1][j-1]，所以状态dp[i][j]一定等于dp[i-1][j]或者dp[i-1][j-1]的最小值+triangle[i][j]

特殊：triangle[i][0]没有左上角 只能从triangle[i-1][j]经过，triangle[i][row[0].length]没有上面 只能从triangle[i-1][j-1]经过

转换方程：dp[i][j]=min(dp[i-1][j], dp[i-1][j-1]) + triangle[i][j]

题解：经过空间优化的dp

观察自顶向下的代码会发现，对第i行的最小路径和的推导，只需要第i-1行的dp[i - 1][j]和dp[i - 1][j - 1]元素即可。可以使用两个变量暂存。一维的dp数组只存储第i行的最小路径和。

为了最后得到结果方便，从下往上计算，最后得到dp[0]即为最小结果

```c++
class Solution {
public:
    int minimumTotal(vector<vector<int>>& triangle) {
        int n = triangle.size();
        vector<int> dp(triangle[n-1].begin(), triangle[n-1].end()); // 滚动数组，初始滚动数组为最后一行
        // 从下往上，每次滚动数组有效长度都会减1，直到三角形顶点，这时滚动数组有效位只有dp[0]
        for(int i = n - 2; i >= 0; --i){
            for(int j = 0; j <= i; ++j){     // i == triangle[i].size()-1
                dp[j] = min(dp[j], dp[j+1]) + triangle[i][j];
            }
        }
        return dp[0];
    }
};
```

如果还允许修改triangle的话，那么可以做到O(1)的额外空间

AcWing 898

```c++
#include <iostream>
#include <vector>
using namespace std;
int main(){
    int n;
    cin >> n;
    vector<vector<int>> maps(n, vector<int>(n, 0));
    for(int i = 0; i < n; ++i){
        for(int j = 0; j <= i; ++j){
            int temp;
            cin >> temp;
            maps[i][j] = temp;
        }
    }
    vector<int> dp(maps[n-1]);
    for(int i = n - 2; i >= 0; --i){
        for(int j = 0; j <= i; ++j){
            dp[j] = max(dp[j], dp[j+1]) + maps[i][j];
        }
    }
    cout << dp[0];
    return 0;
}
```

### 121.买卖股票的最佳时机

给定一个数组，它的第 i 个元素是一支给定股票第 i 天的价格。

如果你最多只允许完成一笔交易（即买入和卖出一支股票），设计一个算法来计算你所能获取的最大利润。

注意你不能在买入股票前卖出股票。

示例 1:

输入: [7,1,5,3,6,4]
输出: 5
解释: 在第 2 天（股票价格 = 1）的时候买入，在第 5 天（股票价格 = 6）的时候卖出，最大利润 = 6-1 = 5 。
     注意利润不能是 7-1 = 6, 因为卖出价格需要大于买入价格。
示例 2:

输入: [7,6,4,3,1]
输出: 0
解释: 在这种情况下, 没有交易完成, 所以最大利润为 0。

 买卖股票的最佳时机的暴力解法

明显时间复杂度为O(n^2)，运行时间只击败了9%

```c++
class Solution {
public:
    int maxProfit(vector<int>& prices) {
        // brute force
        if(prices.size() <= 1) return 0;
        int maxProfit = 0;
        int tempProfit = 0;
        for(int i = 0; i < prices.size(); ++i){
            for(int j = i+1; j < prices.size(); ++j){
                tempProfit = prices[j] - prices[i];
                if (tempProfit > maxProfit)
                {
                    maxProfit = tempProfit;
                }
            }
        }
        return maxProfit;
    }
};
```

 买卖股票的最佳时机的动态规划

思路：想一想，状态转移在哪，当遍历数组时，当前值对最优解的影响在哪？如果前面最小值买进，当前值卖出，这是一个可能，当然也有可能是之前的决策更优，所以可以设dp[i]为前i天最大收益，状态转移方程为`dp[i]=max{dp[i-1], prices[i]-min(prices[0],...prices[i-1])`

```c++
class Solution {
public:
    int maxProfit(vector<int>& prices) {
        // brute force
        if(prices.size() <= 1) return 0;
        int dp = 0;
        int prevMin = prices[0];
        for(int i = 1; i < prices.size(); ++i){
            if(prices[i] > prevMin){
                dp = maxTwo(dp, prices[i] - prevMin);
            }
            else{
                prevMin = prices[i];
            }
        }
        return dp;
    }

    int maxTwo(int a, int b){
        return a > b ? a : b;
    }
};
```

Accepted
200/200 cases passed (4 ms)
Your runtime beats 98.38 % of cpp submissions
Your memory usage beats 35.59 % of cpp submissions (9.5 MB)

### 198.打家劫舍

你是一个专业的小偷，计划偷窃沿街的房屋。每间房内都藏有一定的现金，影响你偷窃的唯一制约因素就是相邻的房屋装有相互连通的防盗系统，如果两间相邻的房屋在同一晚上被小偷闯入，系统会自动报警。

给定一个代表每个房屋存放金额的非负整数数组，计算你在不触动警报装置的情况下，能够偷窃到的最高金额。

示例 1:

输入: [1,2,3,1]
输出: 4
解释: 偷窃 1 号房屋 (金额 = 1) ，然后偷窃 3 号房屋 (金额 = 3)。
     偷窃到的最高金额 = 1 + 3 = 4 。
示例 2:

输入: [2,7,9,3,1]
输出: 12
解释: 偷窃 1 号房屋 (金额 = 2), 偷窃 3 号房屋 (金额 = 9)，接着偷窃 5 号房屋 (金额 = 1)。
     偷窃到的最高金额 = 2 + 9 + 1 = 12 。

 打家劫舍的动态规划

思路：因为不能连续偷窃两个相邻的房子，所以动态规划的状态转移方程得牵涉到前两项，`dp[i]=max{dp[i-2]+nums[i], dp[i-1]}`，时间复杂度为O(n)，空间复杂度为O(1)

```c++
class Solution {
public:
    int rob(vector<int>& nums) {
        // dp
        if(nums.size() < 1) return 0;
        if(nums.size() == 1) return nums[0];
        if(nums.size() == 2) return nums[0] > nums[1] ? nums[0] : nums[1];
        int prepre = nums[0];
        int pre = nums[0] > nums[1] ? nums[0] : nums[1];
        int curr = 0;
        int temp = 0;
        for(int i = 2; i < nums.size(); ++i){
            temp = prepre + nums[i];
            curr = temp > pre ? temp : pre;
            prepre = pre;
            pre = curr;
        }
        return curr;
    }
};
```

69/69 cases passed (0 ms)
Your runtime beats 100 % of cpp submissions
Your memory usage beats 92.05 % of cpp submissions (8.4 MB)

### 213. 打家劫舍 II

你是一个专业的小偷，计划偷窃沿街的房屋，每间房内都藏有一定的现金。这个地方所有的房屋都围成一圈，这意味着第一个房屋和最后一个房屋是紧挨着的。同时，相邻的房屋装有相互连通的防盗系统，如果两间相邻的房屋在同一晚上被小偷闯入，系统会自动报警。

给定一个代表每个房屋存放金额的非负整数数组，计算你在不触动警报装置的情况下，能够偷窃到的最高金额。

示例 1:

输入: [2,3,2]
输出: 3
解释: 你不能先偷窃 1 号房屋（金额 = 2），然后偷窃 3 号房屋（金额 = 2）, 因为他们是相邻的。
示例 2:

输入: [1,2,3,1]
输出: 4
解释: 你可以先偷窃 1 号房屋（金额 = 1），然后偷窃 3 号房屋（金额 = 3）。
     偷窃到的最高金额 = 1 + 3 = 4 。

题解：

环状排列意味着第一个房子和最后一个房子中只能选择一个偷窃，因此可以把此环状排列房间问题约化为两个单排排列房间子问题：

在不偷窃第一个房子的情况下（即 nums[1:]），最大金额是 p_1

在不偷窃最后一个房子的情况下（即 nums[:n-1]），最大金额是 p_2

综合偷窃最大金额： 为以上两种情况的较大值，即 max(p1,p2)。

### 337. 打家劫舍 III

在上次打劫完一条街道之后和一圈房屋后，小偷又发现了一个新的可行窃的地区。这个地区只有一个入口，我们称之为“根”。 除了“根”之外，每栋房子有且只有一个“父“房子与之相连。一番侦察之后，聪明的小偷意识到“这个地方的所有房屋的排列类似于一棵二叉树”。 如果两个直接相连的房子在同一天晚上被打劫，房屋将自动报警。

计算在不触动警报的情况下，小偷一晚能够盗取的最高金额。

示例 1:

输入: [3,2,3,null,3,null,1]

```shell
     3
    / \
   2   3
    \   \
     3   1
```

输出: 7
解释: 小偷一晚能够盗取的最高金额 = 3 + 3 + 1 = 7.
示例 2:

输入: [3,4,5,1,3,null,1]

```shell
     3
    / \
   4   5
  / \   \
 1   3   1
```

输出: 9
解释: 小偷一晚能够盗取的最高金额 = 4 + 5 = 9.

动态规划题解：

假设树的每一个根节点保存的数据改写成这个根节点及它下面的节点能获得的最大金额，那么：

当前根节点=max(下一层根节点的和，下下层根节点的和+当前根节点的值)

回溯题解：

对于一个子树来说，有两种情况：

1. 包含当前根节点
2. 不包含当前根节点

情况1：由于包含了根节点，所以不能选择左右儿子节点，这种情况的最大值为：当前节点 + 左儿子情况2 + 右二子情况2

情况2：不包含根节点

这种情况，可以选择左右儿子节点，所以有四种可能：

1. 左儿子情况1 + 右儿子情况1
2. 左儿子情况1 + 右儿子情况2
3. 左儿子情况2 + 右儿子情况1
4. 左儿子情况2 + 右儿子情况2

综合来说就是，max(左儿子情况1, 左儿子情况2) + max(右儿子情况1, 右儿子情况2)。

综合两种情况，深度优先，从叶子节点遍历到根节点即可。

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
    pair<int, int> dfs(TreeNode *root) {
        if (root == nullptr) {
            return { 0, 0 };
        }
        auto left_pair = dfs(root->left);
        auto right_pair = dfs(root->right);
        return { root->val + left_pair.second + right_pair.second,
                    max(left_pair.first, left_pair.second) +
                        max(right_pair.first, right_pair.second) };
    }
    int rob(TreeNode* root) {
        auto p = dfs(root);
        return max(p.first, p.second);
    }
};
```

### 322. 零钱兑换

给定不同面额的硬币 coins 和一个总金额 amount。编写一个函数来计算可以凑成总金额所需的最少的硬币个数。如果没有任何一种硬币组合能组成总金额，返回 -1。

示例 1:

输入: coins = [1, 2, 5], amount = 11
输出: 3
解释: 11 = 5 + 5 + 1
示例 2:

输入: coins = [2], amount = 3
输出: -1
说明:
你可以认为每种硬币的数量是无限的。

完全背包问题，硬币就是物品，金额就是体积，个数就是价值，一个硬币价值为1，要求最小值，而且要恰好为amount的体积，所以初始化为INT_MAX，f[0]=0

```c++
public:
    int coinChange(vector<int>& coins, int amount) {
        int n = coins.size(); // n个物品
        auto dp = vector<int>(amount + 1, INT_MAX);
        dp[0] = 0;
        for (int i = 0; i < n; ++i) {
            for(int j = coins[i]; j <= amount; ++j) {
                if(dp[j-coins[i]] != INT_MAX){
                    dp[j] = min(dp[j], dp[j-coins[i]] + 1);
                }
            }
        }
        return dp[amount] == INT_MAX ? -1 : dp[amount];
    }
};

```

### 354. 俄罗斯套娃信封问题

给定一些标记了宽度和高度的信封，宽度和高度以整数对形式 (w, h) 出现。当另一个信封的宽度和高度都比这个信封大的时候，这个信封就可以放进另一个信封里，如同俄罗斯套娃一样。

请计算最多能有多少个信封能组成一组“俄罗斯套娃”信封（即可以把一个信封放到另一个信封里面）。

说明:
不允许旋转信封。

示例:

输入: envelopes = [[5,4],[6,4],[6,7],[2,3]]
输出: 3
解释: 最多信封的个数为 3, 组合为: [2,3] => [5,4] => [6,7]

TODO

### 416. 分割等和子集

给定一个只包含正整数的非空数组。是否可以将这个数组分割成两个子集，使得两个子集的元素和相等。

注意:

每个数组中的元素不会超过 100
数组的大小不会超过 200
示例 1:

输入: [1, 5, 11, 5]

输出: true

解释: 数组可以分割成 [1, 5, 5] 和 [11].

示例 2:

输入: [1, 2, 3, 5]

输出: false

解释: 数组不能分割成两个元素和相等的子集.

题目给定一个数组，问是否可以将数组拆分成两份，并且两份的值相等，这里并不是说分成两个子数组，而是分成两个子集。

直观的想法是直接遍历一遍数组，这样我们可以得到数组中所有元素的和，这个和必须是偶数，不然没法分，其实很自然地就可以想到，我们要从数组中挑出一些元素，使这些元素的和等于原数组中元素总和的一半，“**从数组中找出一些元素让它们的和等于一个固定的值**”，这么一个信息能否让你想到背包类动态规划呢？

如果你能想到这个地方，再配上我们之前讲的 01 背包问题 的解法，那么这道题目就可以直接套解法了，这里我就不具体分析了。

参考代码

```c++
class Solution {
public:
    bool canPartition(vector<int>& nums) {
        int sum = 0;
        int n = nums.size();
        for(int i = 0; i < n; ++i){
            sum += nums[i];
        }
        if(sum % 2 != 0){
            return false;
        }
        int target = sum / 2;
        vector<bool> dp (target+1, false);
        dp[0] = true;
        for(int i = 0; i < n; ++i){
            for(int j = target; j >= nums[i]; --j){
                dp[j] = dp[j] | dp[j-nums[i]];
            }
        }
        return dp[target];
    }
};
```

### 887. 鸡蛋掉落/鹰蛋问题

你将获得 K 个鸡蛋，并可以使用一栋从 1 到 N  共有 N 层楼的建筑。每个蛋的功能都是一样的，如果一个蛋碎了，你就不能再把它掉下去。你知道存在楼层 F ，满足 0 <= F <= N 任何从高于 F 的楼层落下的鸡蛋都会碎，从 F 楼层或比它低的楼层落下的鸡蛋都不会破。每次移动，你可以取一个鸡蛋（如果你有完整的鸡蛋）并把它从任一楼层 X 扔下（满足 1 <= X <= N）。

你的目标是确切地知道 F 的值是多少。无论 F 的初始值如何，你确定 F 的值的最小移动次数是多少？

下面的O(n^2*m)的解法，在LeetCode上超时了

---

[AcWing 1048. 鸡蛋的硬度](https://www.acwing.com/problem/content/description/1050/)

输入格式

输入包括多组数据，每组数据一行，包含两个正整数 n 和 m，其中 n 表示楼的高度，m 表示你现在拥有的鸡蛋个数，这些鸡蛋硬度相同（即它们从同样高的地方掉下来要么都摔碎要么都不碎），并且小于等于 n。

你可以假定硬度为 x 的鸡蛋从高度小于等于 x 的地方摔无论如何都不会碎（没摔碎的鸡蛋可以继续使用），而只要从比 x 高的地方扔必然会碎。

对每组输入数据，你可以假定鸡蛋的硬度在 0 至 n 之间，即在 n+1 层扔鸡蛋一定会碎。

输出格式
对于每一组输入，输出一个整数，表示使用最优策略在最坏情况下所需要的扔鸡蛋次数。

数据范围

1≤n≤100,
1≤m≤10

输入样例：
100 1
100 2

输出样例：
100
14

样例解释
最优策略指在最坏情况下所需要的扔鸡蛋次数最少的策略。

如果只有一个鸡蛋，你只能从第一层开始扔，在最坏的情况下，鸡蛋的硬度是100，所以需要扔100次。如果采用其他策略，你可能无法测出鸡蛋的硬度(比如你第一次在第二层的地方扔,结果碎了,这时你不能确定硬度是0还是1)，即在最坏情况下你需要扔无限次，所以第一组数据的答案是100。

动态规划

(第一种状态定义) O(n^2*m)

- f[i, j]表示i层楼，j个鸡蛋的测量方案中最坏情况的最小值
- j个鸡蛋在足够多的情况下可以不用全部用完
- 状态转移：
  - 不使用第j个鸡蛋，方案数为f[i, j - 1]
  - 使用第j个鸡蛋，则有1~i层楼共i种情况可以扔，假设在第k层扔：
    - 蛋碎，搜索区间变成1~k-1（总共k-1个），鸡蛋个数减一，方案数为f[k - 1, j - 1]
    - 蛋没碎，搜索区间变成k+1~i（总共i-k层），第j个蛋可重复利用，方案数为f[i - k, j]
    - 枚举扔的楼层k，在所有可行方案中选择最大值即为最坏情况，答案就是这些情况的最小值
    - 如何理解max与min：我们能控制的，就选择最好情况的（这题要求最少次数，所以min）；我们不能控制的，就选择最坏情况，比如我们无法知道在第k层扔第j个鸡蛋的情况，所以就取蛋碎与蛋没碎的max

```c++
#include <iostream>
using namespace std;
int f[110][15], n, m;
int main() {
    while (cin >> n >> m) {
        for (int i = 1; i <= n; i ++ ) f[i][1] = i; // 只有1个鸡蛋，有多少层，就得扔多少次
        for (int i = 1; i <= m; i ++ ) f[1][i] = 1; // 只有1层，无论多少个鸡蛋，只需扔一次
        for (int i = 2; i <= n; i ++ ){
            for (int j = 2; j <= m; j ++ ) {
                f[i][j] = f[i][j - 1];              // 不扔第j个鸡蛋，那么就与只拥有j-1个鸡蛋的情况相同
                for (int k = 1; k <= i; k ++ ){     // 扔第j个鸡蛋，在i层汇总枚举所有层数k
                    int temp = max(f[k - 1][j - 1], f[i - k][j]);   // 我们不能控制该鸡蛋是否碎，所以取max
                    ++temp;                                         // 扔第j个鸡蛋，算作一次出手，所以+1
                    f[i][j] = min(f[i][j], temp);                   // 我们能控制是否扔该鸡蛋，所以取min
                }
            }
        }
        cout << f[n][m] << endl;
    }
    return 0;
}
```

(第二种状态定义) O(nm)

f[i, j]表示用j个鸡蛋测量i次能测量的区间长度的最大值

f[n][m]一定大于等于n，所以一定是有解的

枚举扔鸡蛋的楼层k，类似dp1，没碎测k楼以上，碎了测k楼以下，那么能测的最大高度就是上下两部分加上第k层楼这一层

因为只有可能碎或者不随，所以k楼以下、k楼以上独立，各自取最大值再相加再加第k层

![eggDP2](../image/eggdp2.png)

```c++
#include <iostream>
using namespace std;

int f[110][15], n, m;

int main() {
    while (cin >> n >> m) {
        for (int i = 1; i <= n; i ++ ) {
            for (int j = 1; j <= m; j ++ )
                f[i][j] = f[i - 1][j] + f[i - 1][j - 1] + 1;    // 没碎 + 碎了 + 1（第k层）
            if (f[i][m] >= n) {                                 // 已经能测量出n层了，可以提前终止
                cout << i << endl;
                break;
            }
        }
    }
    return 0;
}
```

### 阿里巴巴2020.3.20实习生笔试

弹钢琴，一段旋律中的每个音符可以用一个小写英文字母表示，当一段旋律的ASCII是非递减的，则旋律是高昂的，例如aaa，bcd。

现在小强已经学会了n段高昂旋律，想拼接成一个尽可能长的高昂旋律，问最长长度是多少

输入一行正整数n，接下来n行每行一个字符串，保证每个字符串的字符的ASCII都是非递减的，1<=n<=10^6，保证所有字符串长度之和不超过10^6，且仅有小写字母构成

输出一行一个整数代表答案

样例

输入
4
aaa
bcd
zzz
bcdef

输出
11

解释
将1，4，3段字符串拼接在一起，长度为11

```c++
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
using namespace std;
int main()
{
    int n;
    cin >> n;
    string temp;
    vector<string> strs(n+1);
    int dp[n+1]; // 以第i个字符串结尾最大长度
    for (int i = 1; i <= n; ++i)
    {
        cin >> temp;
        strs[i] = temp;
        dp[i] = temp.size(); // 每个字符串都可以以它们自己结尾
    }
    sort(strs.begin(), strs.end());
    for (int i = 1; i <= n; ++i){
        for (int j = 1; j < i; ++j){
            if(strs[j].back() <= strs[i].front()) // 第i个字符串可以接在第j个后面，j<i
                dp[i] = max(dp[i], dp[j] + (int)strs[i].size());
        }
    }
    // 遍历dp数组找答案
    int max_ = 0;
    for (int i = 1; i <= n; ++i){
        max_ = max(max_, dp[i]);
    }
    cout << max_ << endl;
    return 0;
}
```

### 300. 最长上升子序列

给定一个无序的整数数组，找到其中最长上升子序列的长度。

示例:

输入: [10,9,2,5,3,7,101,18]
输出: 4
解释: 最长的上升子序列是 [2,3,7,101]，它的长度是 4。
说明:

可能会有多种最长上升子序列的组合，你只需要输出对应的长度即可。
你算法的时间复杂度应该为 O(n2) 。
进阶: 你能将算法的时间复杂度降低到 O(n log n) 吗?

第一次尝试：原数组排序后，再与原数组求最长公共子序列（LCS），得到的长度即为最长上升子序列（LIS），但是这种做法只适用于数组没有重复数字的情况或者不严格递增（LIS中的Increasing包括等于号），假设输入[2,2]，则应该输出1，但是经过排序后的LCS比较，输出的是2，于是错误

O(n^2)时间的动态规划

定义状态：

- 由于一个子序列一定会以一个数结尾，于是将状态定义成：dp[i] 表示以 nums[i] 结尾的「上升子序列」的长度。
- 注意：这个定义中 nums[i] 必须被选取，且必须是这个子序列的最后一个元素。
- 这种状态定义比较套路，“以a[i]结尾的xxx"

状态转移：

- 遍历到 nums[i] 时，需要把下标 i 之前的所有的数都看一遍；
- 只要 nums[i] 严格大于在它位置之前的某个数，那么 nums[i] 就可以接在这个数后面形成一个更长的上升子序列；
- 因此，dp[i] 就等于下标 i 之前严格小于 nums[i] 的状态值的最大者+1。
- 语言描述：在下标 i 之前严格小于 nums[i] 的所有状态值中的最大者+1。

初始化：dp[i] = 1，1个字符显然是长度为1的上升子序列。

输出：根据定义，dp最后一个值不一定是最大值，所以要遍历dp找到最大值

```c++
class Solution {
public:
    int lengthOfLIS(vector<int>& nums) {
        if(nums.empty()) return 0;
        int n = nums.size();
        vector<int> dp(n, 1);
        for(int i = 1; i < n; ++i){
            for(int j = 0; j < i; ++j){
                // 如果nums[j] < nums[i]，则dp[i] = dp[j] + 1，遍历所有j<i的情况，取max
                if(nums[j] < nums[i]) dp[i] = max(dp[i], dp[j] + 1);
            }
        }
        int len = 1;
        for(int i = 0; i < n; ++i){
            len = max(len, dp[i]);
        }
        return len;
    }
};
```

O(nlogn)时间的动态规划

仔细分析：

- 上面的做法在遍历0...j时需要花费O(n)时间，外层遍历1...n也需要O(n)，所以总时间是O(n^2)，考虑一下能否加快一下内层遍历时间
- 我们考虑：是否可以通过重新设计状态定义，使整个dp为一个排序列表；这样在计算每个dp[k]时，就可以通过二分法遍历[0,k)区间元素，将此部分复杂度由O(N)降至O(logN)。
- 考虑一个简单的贪心，如果我们要使上升子序列尽可能的长，则我们需要让序列**上升得尽可能慢**，因此我们希望每次在上升子序列最后加上的那个数尽可能的小。
- 基于上面的贪心思路，我们维护一个数组d[i] ，表示**长度为i的最长上升子序列的末尾元素的最小值**，用len记录目前最长上升子序列的长度，起始时len为1，d[1] = nums[0]，显然d[i]是单调的，根据单调性即可用二分查找
- 我们依次遍历数组nums中的每个元素，并更新d和len
  - 如果nums[i] > d[len]，则更新len=len+1，并插入到d后面
  - 否则，在d[1...len]中找满足d[i-1] < nums[j] < d[i]的下标i，并更新d[i] = nums[j]，这可以用lower_bound来做

```c++
class Solution {
public:
    int lengthOfLIS(vector<int>& nums) {
        vector<int> minnums;
        for(int v : nums)
        {
            if(!minnums.size() || v > minnums.back()) // 如果d为空或者v大于d的末尾元素（即d的最大值
                minnums.push_back(v);
            else
                // lower_bound返回第一个不小于查找键k的元素的位置，再将v赋值到这个位置上
                *lower_bound(minnums.begin(), minnums.end(), v) = v;
        }
        return minnums.size();
    }
};
```

### 1143. 最长公共子序列

给定两个字符串 text1 和 text2，返回这两个字符串的最长公共子序列。

一个字符串的 子序列 是指这样一个新的字符串：它是由原字符串在不改变字符的相对顺序的情况下删除某些字符（也可以不删除任何字符）后组成的新字符串。
例如，"ace" 是 "abcde" 的子序列，但 "aec" 不是 "abcde" 的子序列。两个字符串的「公共子序列」是这两个字符串所共同拥有的子序列。

若这两个字符串没有公共子序列，则返回 0。

示例 1:

输入：text1 = "abcde", text2 = "ace"
输出：3  
解释：最长公共子序列是 "ace"，它的长度为 3。

示例 2:

输入：text1 = "abc", text2 = "abc"
输出：3
解释：最长公共子序列是 "abc"，它的长度为 3。
示例 3:

输入：text1 = "abc", text2 = "def"
输出：0
解释：两个字符串没有公共子序列，返回 0。

状态转移方程：

dp[i][j]=dp[i-1][j-1]+1; //text1[i-1]==text2[j-1]
dp[i][j]=max(dp[i][j],dp[i][j-1]); //text1[i-1]!=text2[j-1]

在利用二维dp数组存储结果时，需要用到dp[i-1][j-1] (左上方),dp[i-1][j] (上边),dp[i][j-1] (左边)。

这里开辟的数组是大了一圈的，正好在第0行和第0列都是0，这样在for循环里就不用特判了，非常方便！

```c++
class Solution {
public:
    int longestCommonSubsequence(string text1, string text2) {
        int n=text1.size(),m=text2.size();
        int dp[n+1][m+1];
        memset(dp, 0, sizeof(dp));
        for(int i = 1; i <= n; ++i){
            for(int j = 1; j <= m; ++j){
                if(text1[i-1] == text2[j-1]){
                    dp[i][j] = dp[i-1][j-1] + 1;
                }
                else{
                     dp[i][j] = max(dp[i-1][j], dp[i][j-1]);
                }
            }
        }
    return dp[n][m];
    }
};
```

优化为滚动数组存储结果时，由于在从左到右计算dp[j] (dp[i][j]) 的时候dp[j-1] (dp[i-1][j-1]) 已被更新为dp[j-1]（dp[i][j-1]），所以只需要提前定义一个变量last去存储二维dp数组左上方的值dp[i-1][j-1],即未被更新前的dp[j-1];

注意：计算每一行的第一个元素时候，last需要初始化为0。

```c++
class Solution {
public:
    int longestCommonSubsequence(string text1, string text2) {
        int n=text1.size(),m=text2.size();
        int dp[m+1];
        int last, temp;
        memset(dp, 0, sizeof(dp));
        for(int i = 1; i <= n; ++i, last = 0){
            for(int j = 1; j <= m; ++j){
                temp = dp[j];
                if(text1[i-1] == text2[j-1]){
                    dp[j] = last + 1;
                }
                else{
                     dp[j] = max(dp[j], dp[j-1]);
                }
                last = temp;
            }
        }
    return dp[m];
    }
};
```

AcWing 897

闫式dp分析法（对于这题也许没必要用）

状态表示

集合：a[1...i]与b[1...j]的公共子序列的集合

属性：max

集合划分：f[i][j]可以划分四种情况

- 00：即a[i]与b[j]都不在公共子序列里，f[i-1][j-1]
- 01：即a[i]不在，b[j]在，f[i-1][j]
- 10：即a[i]在，b[j]不在，f[i][j-1]
- 11：即a[i]在，b[j]在，f[i][j]，只有在a[i]==b[j]时才存在这种状态

因为这里是求max，所以上述分法是有重复的，这也是允许的，不难发现f[i-1][j-1]包含于f[i-1][j]，也包含于f[i][j-1]，所以只需求f[i-1][j]、f[i][j-1]、f[i][j]

![lcsyandp](../image/lcsyandp.png)

```c++
#include <iostream>
using namespace std;
const int N = 1010;
char a[N], b[N];
int f[N][N];
int n, m;
int main(){
    cin >> n >> m >> a + 1 >> b + 1; // 从1开始
    for(int i = 1; i <= n; ++i){
        for(int j = 1; j <= m; ++j){
            f[i][j] = max(f[i-1][j], f[i][j-1]);
            if(a[i] == b[j]) f[i][j] = max(f[i][j], f[i-1][j-1]+1);
        }
    }
    cout << f[n][m] << endl;
    return 0;
}
```

### 72. 编辑距离

给定两个单词 word1 和 word2，计算出将 word1 转换成 word2 所使用的最少操作数 。

你可以对一个单词进行如下三种操作：

插入一个字符
删除一个字符
替换一个字符
示例 1:

输入: word1 = "horse", word2 = "ros"
输出: 3
解释:
horse -> rorse (将 'h' 替换为 'r')
rorse -> rose (删除 'r')
rose -> ros (删除 'e')
示例 2:

输入: word1 = "intention", word2 = "execution"
输出: 5
解释:
intention -> inention (删除 't')
inention -> enention (将 'i' 替换为 'e')
enention -> exention (将 'n' 替换为 'x')
exention -> exection (将 'n' 替换为 'c')
exection -> execution (插入 'u')

```c++
class Solution {
public:
    int minDistance(string word1, string word2) {
        //集合表示 dp[i][j] 对前i个字符进行操作,转换为目标的前j个字符的操作次数 属性->操作次数最小值
        //集合划分 dp[i][j]的来源  考虑对第i个字符进行的操作是什么
        //1 插入操作 从而相等 所以先让前i个字符变为j-1字符，然后在第i处插入j代表的字符 即dp[i][j-1]+1
        //2 删除操作 从而相等 所以先让前i-1个字符变为j字符，然后在第i处删除 即dp[i-1][j]+1
        //3 替换操作 从而相等 if(i处等于j处 不需要替换) 即dp[i-1][j-1]
        //                   else 需要替换 dp[i-1][j-1]+1
        //上述取个最小值即可
        int n = word1.size(), m = word2.size();
        int dp[n+1][m+1];
        memset(dp, 0, sizeof(dp));
        // word1:1..m  ; word2:1..n
        for(int i = 0; i <= n; ++i) dp[i][0] = i; // word2长度为0，所以word1的i个都要删除
        for(int j = 0; j <= m; ++j) dp[0][j] = j; // word1长度为0，所以word1要增加i个
        for(int i = 1; i <= n; ++i){
            for(int j = 1; j <= m; ++j){
                dp[i][j] = min(dp[i][j-1], dp[i-1][j]) + 1; //插入和删除时
                dp[i][j] = min(dp[i][j], dp[i-1][j-1] + (word1[i-1]==word2[j-1] ? 0:1)); //替换时
                // 也可以用下面这两行
                // if(word1[i-1] == word2[j-1]) dp[i][j] = dp[i-1][j-1];
                // else dp[i][j] = min(min(dp[i-1][j]+1, dp[i][j-1]+1), dp[i-1][j-1]+1);
            }
        }
        return dp[n][m];
    }
};
```

## 设计

### 146. LRU缓存设计

运用你所掌握的数据结构，设计和实现一个  LRU (最近最少使用) 缓存机制。它应该支持以下操作： 获取数据 get 和 写入数据 put 。

获取数据 get(key) - 如果密钥 (key) 存在于缓存中，则获取密钥的值（总是正数），否则返回 -1。
写入数据 put(key, value) - 如果密钥不存在，则写入其数据值。当缓存容量达到上限时，它应该在写入新数据之前删除最近最少使用的数据值，从而为新的数据值留出空间。

进阶:

你是否可以在 O(1) 时间复杂度内完成这两种操作？

示例:

```c++
LRUCache cache = new LRUCache( 2 /* 缓存容量 */ );

cache.put(1, 1);
cache.put(2, 2);
cache.get(1);       // 返回  1
cache.put(3, 3);    // 该操作会使得密钥 2 作废
cache.get(2);       // 返回 -1 (未找到)
cache.put(4, 4);    // 该操作会使得密钥 1 作废
cache.get(1);       // 返回 -1 (未找到)
cache.get(3);       // 返回  3
cache.get(4);       // 返回  4
```

链表（存储）+哈希表+pair（存储key和value）

```c++
class LRUCache{
public:
    LRUCache(int cap){
        capacity = cap;
    }
    int get(int key){
        if(position.find(key) != position.end()){
            // 找到
            put(key, position[key]->second);
            isFound = true;
            return position[key]->second;
        }
        isFound = false;
        return -1;
    }
    void put(int key, int value){
        if(position.find(key) != position.end()){
            recent.erase(position[key]); // 从链表中删除
        }
        if(recent.size() >= capacity){
            // 超过缓存，删除最老的记录
            position.erase(recent.back().first);
            recent.pop_back();
        }
        recent.push_front(pair<int, int>(key, value));
        position[key] = recent.begin();
    }
    bool isFound; // get返回-1时，检查该变量即可知道是否得到相应缓存
private:
    int capacity;
    list<pair<int, int>> recent; // 用链表记录最近的key与value的pair
    unordered_map<int, list<pair<int, int>>::iterator> position; // 用哈希表记录位置，哈希表的键就是key
};
```

## DFS&回溯with闫学灿

### 784. 字母大小写全排列

给定一个字符串S，通过将字符串S中的每个字母转变大小写，我们可以获得一个新的字符串。返回所有可能得到的字符串集合。

示例:
输入: S = "a1b2"
输出: ["a1b2", "a1B2", "A1b2", "A1B2"]

输入: S = "3z4"
输出: ["3z4", "3Z4"]

输入: S = "12345"
输出: ["12345"]
注意：

S 的长度不超过12。
S 仅由数字和字母组成。

```c++
class Solution {
public:
    vector<string> letterCasePermutation(string S) {
        vector<string> ans;
        dfs(S, ans, 0);
        return ans;
    }
    void dfs(string& S, vector<string>& ans, int step){
        if(step == S.size()){
            ans.push_back(S);
        }
        else{
            dfs(S, ans, step+1);
            // 因为ASCI码中，0从30开始，'A'从65开始，'a'从97开始
            if(S[step] >= 'A'){
                // 65 = 二进制(100 0001)，97 = 二进制(110 0001)
                // 所以字母异或32就是在二进制的第五位取反，可以实现大小写字母互相转换
                S[step] ^= 32;
                dfs(S, ans, step+1);
            }
        }
    }
};
```

注意一个顺序问题，在上面的代码中，先dfs，再变形+dfs，如果先变形+dfs，再dfs，则输出顺序不一样，在OJ上算WA，除非是像下面这样（已AC）

```c++
            if(S[step] >= 'A'){

                S[step] ^= 32; // 变形
                dfs(S, ans, step+1);
                S[step] ^= 32; // 恢复现场
            }
            dfs(S, ans, step+1);
```

### 77. 组合

给定两个整数 n 和 k，返回 1 ... n 中所有可能的 k 个数的组合。

示例:

输入: n = 4, k = 2
输出:
[
  [2,4],
  [3,4],
  [2,3],
  [1,2],
  [1,3],
  [1,4],
]

不能漏，不能多，所以要保证顺序是从前往后的，比如[1,2]算一个答案，[2,1]就不算，因为重复了，而且注意组合内的数字都是唯一的

所以传入dfs的参数还需要一个start，说明当前可以取哪些可行数字

```c++
class Solution {
public:
    vector<vector<int>> combine(int n, int k) {
        vector<vector<int>> ans;
        vector<int> path;
        dfs(ans, path, 1, n, k);
        return ans;
    }
    void dfs(vector<vector<int>>& ans, vector<int>& path, int start, int n, int k){
        if(k == 0){
            ans.push_back(path);
            return;
        }
        for(int i = start; i <= n; ++i){
            path.push_back(i);
            dfs(ans, path, i+1, n, k-1);
            path.pop_back(); // 恢复现场
        }
    }
};
```

### 257. 二叉树的所有路径

给定一个二叉树，返回所有从根节点到叶子节点的路径。

说明: 叶子节点是指没有子节点的节点。

示例:

输入:

   1
 /   \
2     3
 \
  5

输出: ["1->2->5", "1->3"]

解释: 所有根节点到叶子节点的路径为: 1->2->5, 1->3

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
    vector<string> binaryTreePaths(TreeNode* root) {
        vector<string> ans;
        string path;
        dfs(ans, root, path);
        return ans;
    }
    void dfs(vector<string>& ans, TreeNode* root, string& path){
        if(root == nullptr) return;
        string temp = path; // 保存现场
        if(path.size()){
            path += "->"; // 特例判断，根节点前不需要->，其他节点前都需要->
        }
        path += to_string(root->val);
        if(!root->left && !root->right){
            ans.push_back(path);
        }
        else{
            dfs(ans, root->left, path);
            dfs(ans, root->right, path);
        }
        path = temp; // 恢复现场
    }
};
```

### 93. 复原IP地址

给定一个只包含数字的字符串，复原它并返回所有可能的 IP 地址格式。

示例:

输入: "25525511135"
输出: ["255.255.11.135", "255.255.111.35"]

```c++
class Solution {
public:
    vector<string> restoreIpAddresses(string s) {
        vector<string> ans;
        string path;
        dfs(ans, s, 0, 0, path);
        return ans;
    }
    void dfs(vector<string>& ans, string s, int start, int k, string path){ // 值传递，不用恢复现场
        if(k > 4) return;
        if(start == s.size()){
            // 有可能不是由4个数字组成的
            if(k == 4){
                ans.push_back(path.substr(1)); // substr(1)用来返回包括第1个位置之后的字符串（从0开始计数）
            }
            return;
        }
        if(s[start] == '0'){
            //0开头，必须自成1个数字，如"xx.0.xx"
            dfs(ans, s, start+1, k+1, path+".0");
        }
        else{
            for(int i = start, t = 0; i < s.size(); ++i){
                t = t * 10 + s[i] - '0'; // 构造数字
                if(t < 256){
                    dfs(ans, s, i+1, k+1, path+"."+to_string(t));
                }
                else{
                    break;
                }
            }
        }
    }
};
```

### 95. 不同的二叉搜索树 II

给定一个整数 n，生成所有由 1 ... n 为节点所组成的二叉搜索树。

示例:

输入: 3
输出:
[
  [1,null,3,2],
  [3,2,null,1],
  [3,1,null,null,2],
  [2,1,3],
  [1,null,2,null,3]
]
解释:
以上的输出对应以下 5 种不同结构的二叉搜索树：

   1         3     3      2      1
    \       /     /      / \      \
     3     2     1      1   3      2
    /     /       \                 \
   2     1         2                 3

先枚举根节点，再分别递归枚举左子树与右子树，然后再把左子树与右子树结合起来，方案总数不是相加，而是相乘

如果区间为0，则也要算一个方案，因为比如上面图形的第一个，根节点为1，没有左子树，但这也是一个方案

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
    vector<TreeNode*> generateTrees(int n) {
        if(!n) return vector<TreeNode*>();
        return dfs(1, n);
    }
    vector<TreeNode*> dfs(int l, int r){
        vector<TreeNode*> res;
        if(l > r){
            res.push_back(nullptr); // 也算一个方案！
            return res;
        }
        for(int i = l; i <= r; ++i){
            auto left = dfs(l, i-1);
            auto right = dfs(i+1, r);
            // 左子树和右子树的方案，方案总数是相乘的，所以用双层for循环
            for(auto &lt : left){
                for(auto &rt : right){
                    auto root = new TreeNode(i);
                    root->left = lt;
                    root->right = rt;
                    res.push_back(root);
                }
            }
        }
        return res;
    }
};
```

### 394. 字符串解码

给定一个经过编码的字符串，返回它解码后的字符串。

编码规则为: k[encoded_string]，表示其中方括号内部的 encoded_string 正好重复 k 次。注意 k 保证为正整数。

你可以认为输入字符串总是有效的；输入字符串中没有额外的空格，且输入的方括号总是符合格式要求的。

此外，你可以认为原始数据不包含数字，所有的数字只表示重复的次数 k ，例如不会出现像 3a 或 2[4] 的输入。

示例:

s = "3[a]2[bc]", 返回 "aaabcbc".
s = "3[a2[c]]", 返回 "accaccacc".
s = "2[abc]3[cd]ef", 返回 "abcabccdcdcdef".

方法一：括号要匹配，所以很容易联想到栈

方法二：每碰到一个`[`就需要递归一层，完成之后`]`再跳出该层

TODO

### 341. 扁平化嵌套列表迭代器

给你一个嵌套的整型列表。请你设计一个迭代器，使其能够遍历这个整型列表中的所有整数。

列表中的每一项或者为一个整数，或者是另一个列表。

示例 1:

输入: [[1,1],2,[1,1]]
输出: [1,1,2,1,1]
解释: 通过重复调用 next 直到 hasNext 返回 false，next 返回的元素的顺序应该是: [1,1,2,1,1]。
示例 2:

输入: [1,[4,[6]]]
输出: [1,4,6]
解释: 通过重复调用 next 直到 hasNext 返回 false，next 返回的元素的顺序应该是: [1,4,6]。

方法一：栈

方法二：DFS递归

### 756. 金字塔转换矩阵

现在，我们用一些方块来堆砌一个金字塔。 每个方块用仅包含一个字母的字符串表示。

使用三元组表示金字塔的堆砌规则如下：

对于三元组(A, B, C) ，“C”为顶层方块，方块“A”、“B”分别作为方块“C”下一层的的左、右子块。当且仅当(A, B, C)是被允许的三元组，我们才可以将其堆砌上。

初始时，给定金字塔的基层 bottom，用一个字符串表示。一个允许的三元组列表 allowed，每个三元组用一个长度为 3 的字符串表示。

如果可以由基层一直堆到塔尖就返回 true，否则返回 false。

示例 1:

输入: bottom = "BCD", allowed = ["BCG", "CDE", "GEA", "FFF"]
输出: true
解析:
可以堆砌成这样的金字塔:
    A
   / \
  G   E
 / \ / \
B   C   D

因为符合('B', 'C', 'G'), ('C', 'D', 'E') 和 ('G', 'E', 'A') 三种规则。
示例 2:

输入: bottom = "AABA", allowed = ["AAA", "AAB", "ABA", "ABB", "BAC"]
输出: false
解析:
无法一直堆到塔尖。
注意, 允许存在像 (A, B, C) 和 (A, B, D) 这样的三元组，其中 C != D。

注意：

bottom 的长度范围在 [2, 8]。
allowed 的长度范围在[0, 200]。
方块的标记字母范围为{'A', 'B', 'C', 'D', 'E', 'F', 'G'}。

### 1391. 检查网格中是否存在有效路径

给你一个 m x n 的网格 grid。网格里的每个单元都代表一条街道。grid[i][j] 的街道可以是：

1 表示连接左单元格和右单元格的街道。
2 表示连接上单元格和下单元格的街道。
3 表示连接左单元格和下单元格的街道。
4 表示连接右单元格和下单元格的街道。
5 表示连接左单元格和上单元格的街道。
6 表示连接右单元格和上单元格的街道。

![lc1391](../image/lc1391.png)

深搜，判断(x,y)从i方向到(a,b)，i为上下左右四个方向，每次要加上两个判断

- (x,y)的的i方向是否是1
- (a,b)的-i方向是否是1，直接与2异或即可

首先是先打个表，6种街道模型是6个长度为4的数组，不接通的方向为0，接通的方向为1

为了减少重复搜索，记录已访问过的块，这里直接修改原数组

```c++
class Solution {
public:
    bool hasValidPath(vector<vector<int>>& grid) {
        return dfs(0, 0, grid);
    }
    // 定义四个方向，x正半轴往下，y正半轴往右
    // 四个方向的遍历顺序为：上、右、下、左
    int dx[4] = {-1, 0, 1, 0}, dy[4] = {0, 1, 0, -1};
    // 打表：六个单元对应方向连通则为1，比如state[0]={0,1,0,1}，说明右与左连通
    int state[6][4] = {
        {0, 1, 0, 1},
        {1, 0, 1, 0},
        {0, 0, 1, 1},
        {0, 1, 1, 0},
        {1, 0, 0, 1},
        {1, 1, 0, 0},
    };

    bool dfs(int x, int y, vector<vector<int>>& grid) {
        int n = grid.size(), m = grid[0].size();
        if (x == n - 1 && y == m - 1) return true;

        int k = grid[x][y];
        grid[x][y] = 0; // 直接修改原数组，为0则说明已访问

        for (int i = 0; i < 4; i ++ ) { // 四个方向试一试
            int a = x + dx[i], b = y + dy[i];
            if (a < 0 || a >= n || b < 0 || b >= m || !grid[a][b]) continue;
            // 当前单元在i方向连通，下个单元在-i方向连通，i是0 1 2 3，i异或2可以得到反方向
            if (!state[k - 1][i] || !state[grid[a][b] - 1][i ^ 2]) continue;

            if (dfs(a, b, grid)) return true;
        }

        return false;
    }
};
```

## 模拟

### 415. 字符串相加

给定两个字符串形式的非负整数 num1 和num2 ，计算它们的和。

注意：

num1 和num2 的长度都小于 5100.
num1 和num2 都只包含数字 0-9.
num1 和num2 都不包含任何前导零。
你不能使用任何內建 BigInteger 库， 也不能直接将输入的字符串转换为整数形式。

```c++
class Solution {
public:
    string addStrings(string num1, string num2) {
        int len1 = num1.size();
        int len2 = num2.size();
        // 补齐两个大数的长度，使两个一样长
        while(len1 < len2){
            num1 = '0' + num1;
            len1++;
        }
        while(len1 > len2){
            num2 = '0' + num2;
            len2++;
        }
        string str = num1; // 待输出的sum
        int carry = 0;
        for(int i = len1 - 1; i >= 0; --i){ // 从后往前，一位位的加
            int sum = num1[i]-'0' + num2[i]-'0' + carry;
            str[i] = sum % 10 + '0';
            carry = sum / 10; // 进位
        }
        if(carry){ // 如果最高位产生了进位，则在最后输出前要加上1
            str = to_string(carry) + str;
        }
        return str;
    }
};
```

### 43. 字符串相乘

给定两个以字符串形式表示的非负整数 num1 和 num2，返回 num1 和 num2 的乘积，它们的乘积也表示为字符串形式。

示例 1:

输入: num1 = "2", num2 = "3"
输出: "6"
示例 2:

输入: num1 = "123", num2 = "456"
输出: "56088"
说明：

num1 和 num2 的长度小于110。
num1 和 num2 只包含数字 0-9。
num1 和 num2 均不以零开头，除非是数字 0 本身。
不能使用任何标准库的大数类型（比如 BigInteger）或直接将输入转换为整数来处理。

TODO

### 263. 丑数

编写一个程序判断给定的数是否为丑数。

丑数就是只包含质因数 2, 3, 5 的正整数。

示例 1:

输入: 6
输出: true
解释: 6 = 2 × 3
示例 2:

输入: 8
输出: true
解释: 8 = 2 × 2 × 2
示例 3:

输入: 14
输出: false
解释: 14 不是丑数，因为它包含了另外一个质因数 7。
说明：

1 是丑数。
输入不会超过 32 位有符号整数的范围: [−231,  231 − 1]。

```c++
class Solution {
public:
    bool isUgly(int num) {
        int d[] = {2, 3, 5};
        for(auto& prime : d){
            while(num > 1 && num % prime == 0){
                num /= prime;
            }
        }
        return num == 1;
    }
};
```

### 67. 二进制求和

给定两个二进制字符串，返回他们的和（用二进制表示）。

输入为非空字符串且只包含数字 1 和 0。

示例 1:

输入: a = "11", b = "1"
输出: "100"
示例 2:

输入: a = "1010", b = "1011"
输出: "10101"

先翻转，每位加法，carry是进位，sum是进位后当前位的和，最后再翻转

```c++
class Solution {
public:
    string addBinary(string a, string b) {
        if(a.empty()) return b;
        if(b.empty()) return a;
        reverse(a.begin(), b.end());
        reverse(b.begin(), b.end());
        int carry = 0;
        string ans;
        for(int i = 0; i < a.size() || i < b.size(); ++i){
            int ia = i >= a.size() ? 0 : a[i] - '0';
            int ib = i >= b.size() ? 0 : b[i] - '0';
            int sum = ia + ib + carry;
            cout << sum << " " << carry << endl;
            carry = sum / 2;
            sum = sum % 2;
            ans += to_string(sum);
        }
        if(carry) ans += '1';
        reverse(ans.begin(), ans.end());
        return ans;
    }
};
```

### 504. 七进制数

给定一个整数，将其转化为7进制，并以字符串形式输出。

示例 1:

输入: 100
输出: "202"
示例 2:

输入: -7
输出: "-10"
注意: 输入范围是 [-1e7, 1e7] 。

十进制转换为其他进制使用除x取余法

```c++
class Solution {
public:
    string convertToBase7(int num) {
        if(num == 0) return "0"; // 特判
        string ans;
        bool isPositive = true;
        if(num < 0){
            isPositive = false;
            num = -num;
        }
        while(num){
            ans += to_string(num % 7);
            num /= 7;
        }
        if(!isPositive) ans += "-";
        reverse(ans.begin(), ans.end());
        return ans;
    }
};
```

### 54. 螺旋矩阵

给定一个包含 m x n 个元素的矩阵（m 行, n 列），请按照顺时针螺旋顺序，返回矩阵中的所有元素。

示例 1:

输入:
[
 [ 1, 2, 3 ],
 [ 4, 5, 6 ],
 [ 7, 8, 9 ]
]
输出: [1,2,3,6,9,8,7,4,5]
示例 2:

输入:
[
  [1, 2, 3, 4],
  [5, 6, 7, 8],
  [9,10,11,12]
]
输出: [1,2,3,4,8,12,11,10,9,5,6,7]

y总搞得太绕了，我觉得我在剑指offer上写的比较直观

```c++
class Solution {
public:
    vector<int> spiralOrder(vector<vector<int>>& matrix) {
        vector<int> res;
        int row = matrix.size();
        if(row == 0) return res;
        int col = matrix[0].size();
        if(col == 0) return res;
        int left = 0;
        int right = col - 1;
        int up = 0;
        int down = row - 1;
        int i, j;
        while(left <= right && up <= down){
            for(i = up, j = left; i <= down && j <= right; ++j){
                res.push_back(matrix[i][j]);
            }
            ++up;
            for(i = up, j = right; i <= down && j >= left; ++i){
                res.push_back(matrix[i][j]);
            }
            --right;
            for(i = down, j = right; i >= up && j >= left; --j){
                res.push_back(matrix[i][j]);
            }
            --down;
            for(i = down, j = left; i >= up && j <= right; --i){
                res.push_back(matrix[i][j]);
            }
            ++left;
        }
        return res;
    }
};
```

### 299. 猜数字游戏

你正在和你的朋友玩 猜数字（Bulls and Cows）游戏：你写下一个数字让你的朋友猜。每次他猜测后，你给他一个提示，告诉他有多少位数字和确切位置都猜对了（称为“Bulls”, 公牛），有多少位数字猜对了但是位置不对（称为“Cows”, 奶牛）。你的朋友将会根据提示继续猜，直到猜出秘密数字。

请写出一个根据秘密数字和朋友的猜测数返回提示的函数，用 A 表示公牛，用 B 表示奶牛。

请注意秘密数字和朋友的猜测数都可能含有重复数字。

示例 1:

输入: secret = "1807", guess = "7810"

输出: "1A3B"

解释: 1 公牛和 3 奶牛。公牛是 8，奶牛是 0, 1 和 7。
示例 2:

输入: secret = "1123", guess = "0111"

输出: "1A1B"

解释: 朋友猜测数中的第一个 1 是公牛，第二个或第三个 1 可被视为奶牛。
说明: 你可以假设秘密数字和朋友的猜测数都只包含数字，并且它们的长度永远相等。

题目还是比较简单的，把所有猜对数字的个数加起来，再减去位置对了的个数，就等于位置没对的个数了。

上面示例2中，对于数字1，dictS[1]=2，dictG[1]=3，这时猜对的数字个数应该是min(2,3)=2，所以要有min

```c++
class Solution {
public:
    string getHint(string secret, string guess) {
        int len = secret.size();
        int dictS[10] = {0}; // 记录secret中每个数字出现了多少次，数字范围是0~9，所以直接用数组存储
        int dictG[10] = {0}; // C数组一定要初始化，不会默认为0的！
        int tempS = 0;
        int tempG = 0;
        int Bulls = 0;
        int Cows = 0;
        for(int i = 0; i < len; ++i){
            tempS = secret[i] - '0';
            tempG = guess[i] - '0';
            if(tempG == tempS) ++Bulls;
            ++dictS[tempS];
            ++dictG[tempG];
        }
        for(int i = 0; i < 10; ++i) Cows += min(dictS[i], dictG[i]); // 猜对数字的所有个数
        Cows -= Bulls;
        return to_string(Bulls) + "A" + to_string(Cows) + "B";
    }
};
```

### 481. 神奇字符串

神奇的字符串 S 只包含 '1' 和 '2'，并遵守以下规则：

字符串 S 是神奇的，因为串联字符 '1' 和 '2' 的连续出现次数会生成字符串 S 本身。

字符串 S 的前几个元素如下：S = “1221121221221121122 ......”

如果我们将 S 中连续的 1 和 2 进行分组，它将变成：

1 22 11 2 1 22 1 22 11 2 11 22 ......

并且每个组中 '1' 或 '2' 的出现次数分别是：

1 2 2 1 1 2 1 2 2 1 2 2 ......

你可以看到上面的出现次数就是 S 本身。

给定一个整数 N 作为输入，返回神奇字符串 S 中前 N 个数字中的 '1' 的数目。

注意：N 不会超过 100,000。

示例：

输入：6
输出：3
解释：神奇字符串 S 的前 6 个元素是 “12211”，它包含三个 1，因此返回 3。

理解题意：1对应1，22对应2，11对应2...

闫大神的枚举有点不好理解，在题解区看到下面的解答，感觉还不错

神奇字符串可以由自身简单生成，规则如下：
从头开始遍历，如果碰到1，则在字符串末尾添加一个与结尾字符串不同的字符，反之添加两个。
是很明显的快慢指针可以处理的题目。

```c++
class Solution {
public:
    int magicalString(int n) {
        if (n == 0) return 0; // 特判
        if (n <= 3) return 1;
        int fast = 2;
        string s = "122"; // 固定开头
        int count = 1; // 下面for循环从第三位开始，前两位”12“中已经包含了一个'1'
        for (int i = 2; i < n; i++) { // i就相当于slow慢指针
            if (s[i] == '2') {
                if (s[fast] == '2') {
                    s += "11";
                } else {
                    s += "22";
                }
                fast += 2;
            } else {
                count++; // 慢指针遍历的时候记录count
                if (s[fast] == '1') {
                    s += "2";
                } else {
                    s += "1";
                }
                fast += 1;
            }
        }
        return count;
    }
};
```

### 71. 简化路径

以 Unix 风格给出一个文件的绝对路径，你需要简化它。或者换句话说，将其转换为规范路径。

在 Unix 风格的文件系统中，一个点（.）表示当前目录本身；此外，两个点 （..） 表示将目录切换到上一级（指向父目录）；两者都可以是复杂相对路径的组成部分。更多信息请参阅：Linux / Unix中的绝对路径 vs 相对路径

请注意，返回的规范路径必须始终以斜杠 / 开头，并且两个目录名之间必须只有一个斜杠 /。最后一个目录名（如果存在）不能以 / 结尾。此外，规范路径必须是表示绝对路径的最短字符串。

示例 1：
输入："/home/"
输出："/home"
解释：注意，最后一个目录名后面没有斜杠。

示例 2：
输入："/../"
输出："/"
解释：从根目录向上一级是不可行的，因为根是你可以到达的最高级。

示例 3：
输入："/home//foo/"
输出："/home/foo"
解释：在规范路径中，多个连续斜杠需要用一个斜杠替换。

示例 4：
输入："/a/./b/../../c/"
输出："/c"

示例 5：
输入："/a/../../b/../c//.//"
输出："/c"

示例 6：
输入："/a//b////c/d//././/.."
输出："/a/b/c"

这题是对于字符串的处理，比较复杂，也可以用栈来做

```c++
class Solution {
public:
    string simplifyPath(string path) {
        path += '/'; // 一个小技巧，多加一个小斜杠，最后再删除它（如果不是根目录的话）
        string str = ""; // 记录两个'/'之间的临时字符串
        string ans = "";
        for(int i = 0; i < path.size(); ++i){
            cout << str << endl;
            if(ans.empty()){
                ans += path[i]; // 根目录
            }
            else if(path[i] != '/'){
                str += path[i];
            }
            else{
                if(str == ".."){
                    if(ans.size() > 1){             // 不能把根目录给pop了
                        ans.pop_back();             // pop掉末尾的'/'
                        while(ans.back() != '/'){   // 一直pop到上一个'/'为止
                            ans.pop_back();
                        }
                    }
                }
                else if(str != "" && str != "."){
                    ans += str + "/";
                }
                str = ""; // 临时字符串置空
            }
        }
        if(ans.size() > 1){
            ans.pop_back();
        }
        return ans;
    }
};
```

### 12. 整数转罗马数字

罗马数字包含以下七种字符： I， V， X， L，C，D 和 M。

字符          数值
I             1
V             5
X             10
L             50
C             100
D             500
M             1000

例如， 罗马数字 2 写做 II ，即为两个并列的 1。12 写做 XII ，即为 X + II 。 27 写做  XXVII, 即为 XX + V + II 。

通常情况下，罗马数字中小的数字在大的数字的右边。但也存在特例，例如 4 不写做 IIII，而是 IV。数字 1 在数字 5 的左边，所表示的数等于大数 5 减小数 1 得到的数值 4 。同样地，数字 9 表示为 IX。这个特殊的规则只适用于以下六种情况：

I 可以放在 V (5) 和 X (10) 的左边，来表示 4 和 9。
X 可以放在 L (50) 和 C (100) 的左边，来表示 40 和 90。
C 可以放在 D (500) 和 M (1000) 的左边，来表示 400 和 900。
给定一个整数，将其转为罗马数字。输入确保在 1 到 3999 的范围内。

示例 1:

输入: 3
输出: "III"
示例 2:

输入: 4
输出: "IV"
示例 3:

输入: 9
输出: "IX"
示例 4:

输入: 58
输出: "LVIII"
解释: L = 50, V = 5, III = 3.
示例 5:

输入: 1994
输出: "MCMXCIV"
解释: M = 1000, CM = 900, XC = 90, IV = 4.

解答：

因为这里的减法挺烦的，所以干脆把减法也当做新的符号。

我们可以将所有减法操作看做一个整体，当成一种新的单位。从大到小整理所有单位得到：

罗马数字 阿拉伯数字
M   1000
CM  900
D   500
CD  400
C   100
XC  90
L   50
XL  40
X   10
IX  9
V   5
IV  4
I   1

```c++
class Solution {
public:
    string intToRoman(int num) {
        int values[] = {1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1}; // 总共13位
        string reps[] = {"M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"}; // 总共13位
        string ans;
        int k;
        for(int i = 0; i < 13; ++i){
            while(num / values[i]){
                k = num / values[i];
                while(k--){
                    ans += reps[i];
                }
                num %= values[i];
            }
        }
        return ans;
    }
};
```

y总的while循环代码如下，我觉得一个个减挺慢的，所以用了除法，已AC

```c++
        for (int i = 0; i < 13; i ++ )
            while(num >= values[i])
            {
                num -= values[i];
                res += reps[i];
            }
```

时间复杂度分析：计算量与最终罗马数字的长度成正比，对于每一位阿拉伯数字，罗马数字最多用4个字母表示（比如VIII=8），所以罗马数字的长度和阿拉伯数字的长度是一个数量级的，而阿拉伯数字的长度是 O(logn)O(logn)，因此时间复杂度是 O(logn)O(logn)。

### 68. 文本左右对齐

这题又臭又长，就不写了。。。

### 序列和(牛客网)

给出一个正整数N和长度L，找出一段长度大于等于L的连续非负整数，他们的和恰好为N。答案可能有多个，我我们需要找出长度最小的那个。
例如 N = 18 L = 2：
5 + 6 + 7 = 18
3 + 4 + 5 + 6 = 18
都是满足要求的，但是我们输出更短的 5 6 7

输入描述:
输入数据包括一行： 两个正整数N(1 ≤ N ≤ 1000000000),L(2 ≤ L ≤ 100)

输出描述:
从小到大输出这段连续非负整数，以空格分隔，行末无空格。如果没有这样的序列或者找出的序列长度大于100，则输出No

观察发现，avg必须是x.0或者x.5，当avg=x.0时，长度必须是奇数，当avg=x.5时，长度必须是偶数，注意非负整数序列，再注意输出格式，这里最后一个数据后面不能有空格！

```c++
#include <iostream>
#include <algorithm>
#include <vector>
using namespace std;
int main()
{
    int N, L;
    double avg;
    cin >> N >> L;
    for (int len = L; len <= 100; ++len){
        avg = (double)N / len;
        if(avg*2 != int(avg*2)) continue; // 不是0.5的倍数
        if(len % 2 == 1 && avg == int(avg)){
            if(avg - len / 2 < 0) continue; // 题目要求必须是非负整数序列
            for (int num = avg - len / 2; num <= avg + len / 2; ++num){
                if(num == avg + len / 2){
                    cout << num;
                }
                else{
                    cout << num << " ";
                }
            }
            return 0;
        }
        if(len % 2 == 0 && avg != int(avg) && avg*2 == int(avg*2)){
            if(int(avg) - (len / 2 - 1) < 0) continue; // 题目要求必须是非负整数序列
            for (int num = int(avg) - (len / 2 - 1); num <= int(avg) + len / 2; ++num){
                if(num == int(avg) + len / 2){
                    cout << num;
                }
                else{
                    cout << num << " ";
                }
            }
            return 0;
        }
    }
    cout << "No" << endl;
    return 0;
}
```

## 哈希表专题with闫学灿

### 1. 两数之和

### 454. 四数之和II

前面两题都很简单，用哈希表，空间换取时间

### 560. 和为K的子数组

给定一个整数数组和一个整数 k，你需要找到该数组中和为 k 的连续的子数组的个数。

示例 1 :

输入:nums = [1,1,1], k = 2
输出: 2 , [1,1] 与 [1,1] 为两种不同的情况。
说明 :

数组的长度为 [1, 20,000]。
数组中元素的范围是 [-1000, 1000] ，且整数 k 的范围是 [-1e7, 1e7]。

题解：

- num1,num2,num3,num4，其中num2 + num3 = sum3 - sum1，所以可以用一次遍历搞定，每次都把当前值加入到**累加和**sum中

- 借助哈希表保存累加和sum及出现的次数。若累加和sum−k在哈希表中存在，则说明存在连续序列使得和为k。则之前的累加和中，sum−k出现的次数即为有多少种子序列使得累加和为sum−k。

- 初始化哈希表hhash={0:1}，表示累加和为0，出现了1次。初始化累加和sum=0。初始化结果count=0。

遍历数组：

- 更新累加和sum+=nums[i]

- 若sum−k存在于hash中，说明存在连续序列使得和为k。则令count+=hash[sum−k]，表示sum−k出现几次，就存在几种子序列使得和为k。

- 若sum存在于hash中，将其出现次数加一。若不存在，将其加入hash，出现次数置为1。但是因为代码上这两种分支没有区别

复杂度分析
时间复杂度：O(n)
空间复杂度：O(n)

为什么初始化：hash[0]=1，因为sum为0的次数还没遍历之前就算有一次了

举个例子，[1,1]，和为2，当遍历到i=1时，发现k-sum=2-2=0，所以找到之前存储的hash[0]=1，于是count=count+1=0+1=1，1就是正确答案

```c++
class Solution {
public:
    int subarraySum(vector<int>& nums, int k) {
        unordered_map<int, int> hash;
        hash[0] = 1; // 初始化：前缀和为0已经出现过一次了，所以初始化为1
        int count = 0;
        int sum = 0;  // 前缀和
        for(int i = 0; i < nums.size(); ++i){
            sum += nums[i];
            count += hash[sum-k]; // 之前没有出现过的key，初始化为0，所以相当于没有加count
            ++hash[sum];
        }
        return count;
    }
};
```

### 525. 连续数组

给定一个二进制数组, 找到含有相同数量的 0 和 1 的最长连续子数组（的长度）。

示例 1:

输入: [0,1]
输出: 2
说明: [0, 1] 是具有相同数量0和1的最长连续子数组。
示例 2:

输入: [0,1,0]
输出: 2
说明: [0, 1] (或 [1, 0]) 是具有相同数量0和1的最长连续子数组。

注意: 给定的二进制数组的长度不会超过50000。

题解：

这题是上题的变形，可以把0和1看做-1和1，那这样就是子数组的和是否为0

但要注意，这题的输出是最长子数组长度，所以哈希表记录的不是累加和的个数，而是累加和的下标，我们要找最长子数组，所以要找距离现在最远的下标

为什么初始化hash[0]=-1，因为要记录下标

举个例子，0,1，转换为-1,1，当遍历到i=1时，此时sum=-1+1=0，发现初始化的hash[0]=-1，于是i-hash[0]=1-(-1)=2，于是这就是我们的正确答案。可以看到为了得到子数组的长度，下标要从-1开始

```c++
class Solution {
public:
    int findMaxLength(vector<int>& nums) {
        unordered_map<int, int> hash;
        hash[0] = -1; // 初始化：累加和为0的下标为-1
        int res = 0;
        int sum = 0;
        for(int i = 0; i < nums.size(); ++i){
            sum += (nums[i] == 0 ? -1 : 1);     // 把0转换为-1
            if(hash.find(sum) != hash.end()){   // 因为目标和是0，sum-sum=0;
                // 找到之前累加和也为s的那个下标，若长度比已经记录的res更大，则更新之
                res = max(res, i - hash[sum]);
            }
            else{
                hash[sum] = i; // 之前没有出现过这个前缀和，那就把key=sum,value=i加入进去
            }
        }
        return res;
    }
};
```

### 187. 重复的DNA序列

所有 DNA 都由一系列缩写为 A，C，G 和 T 的核苷酸组成，例如：“ACGAATTCCG”。在研究 DNA 时，识别 DNA 中的重复序列有时会对研究非常有帮助。

编写一个函数来查找 DNA 分子中所有出现超过一次的 10 个字母长的序列（子串）。

示例：

输入：s = "AAAAACCCCCAAAAACCCCCCAAAAAGGGTTT"
输出：["AAAAACCCCC", "CCCCCAAAAA"]

```c++
class Solution {
public:
    vector<string> findRepeatedDnaSequences(string s) {
        unordered_map<string, int> hash;
        vector<string> res;
        string str;
        // 因为size()返回size_t（无符号整数），所以尽量不做减法，
        // 因为无符号整数的加减法会把其他操作数也转换为无符号整数，如果有负数的话会产生bug
        for(int i = 0; i + 10 <= s.size(); ++i){ // 长度为10，所以<=
            str = s.substr(i, 10); // substr(size_t pos, size_t n)
            if(hash[str]++ == 1) res.push_back(str);
        }
        return res;
    }
};
```

也可以不用哈希表，只需要记录一下即可

- 记录两者不一样的数量，包括不一样时第一个字符串中为A的数量，和不一样时第一个字符串为T的数量
- 分开记录
- 然后取这两个数量里min的那个，是这两位互相交换的情况
- 再取两者的差的abs，是直接替换的情况
- 两者和即为结果

```c++
string DNA1, DNA2;
cin >> DNA1 >> DNA2;
int countA = 0;
int countT = 0;
for(int i = 0; i < DNA1.size(); ++i){
    if(DNA1[i] != DNA2[i] && DNA1[i] == 'A'){
        ++countA;
    }
    if(DNA1[i] != DNA2[i] && DNA1[i] == 'T'){
        ++countT;
    }
}
int n1 = min(countA, countT);
int n2 = abs(countT, countA);
cout << n1 + n2;
```

### 347. 前 K 个高频元素

给定一个非空的整数数组，返回其中出现频率前 k 高的元素。

示例 1:

输入: nums = [1,1,1,2,2,3], k = 2
输出: [1,2]
示例 2:

输入: nums = [1], k = 1
输出: [1]
说明：

你可以假设给定的 k 总是合理的，且 1 ≤ k ≤ 数组中不相同的元素的个数。
你的算法的时间复杂度必须优于 O(n log n) , n 是数组的大小。

题解：

因为需要优于O(nlogn)，所以不能用快排。但可以用计数排序

(哈希表，计数排序) O(n)

首先用哈希表统计出所有数出现的次数。

由于所有数出现的次数都在 1 到 n 之间，所以我们可以用计数排序的思想，统计出次数最多的前 k 个元素的下界。然后将所有出现次数大于等于下界的数输出。

时间复杂度分析：用哈希表统计每个数出现次数的计算量是 O(n)，计数排序的计算量是 O(n)，最终用下界过滤结果的计算量也是 O(n)，所以总时间复杂度是 O(n)。

上面是y总的题解，我觉得这题用优秀队列（最大堆）会更好

```c++
class Solution {
public:
    vector<int> topKFrequent(vector<int>& nums, int k) {
        unordered_map<int,int> mp;
        priority_queue<pair<int,int> > pq; // 默认最大堆，默认比较pair.first，最小堆得加入仿函数greater<T>
        for(auto n:nums) mp[n]++;
        for(auto m:mp) pq.push(make_pair(m.second,m.first)); // 这样默认比较的就是出现次数（频率）了
        vector<int> res;
        for(int i=0;i<k;i++) {
            res.push_back(pq.top().second);
            pq.pop();
        }
        return res;
    }
};
```

### 350. 两个数组的交集 II

给定两个数组，编写一个函数来计算它们的交集。

示例 1:

输入: nums1 = [1,2,2,1], nums2 = [2,2]
输出: [2,2]
示例 2:

输入: nums1 = [4,9,5], nums2 = [9,4,9,8,4]
输出: [4,9]
说明：

输出结果中每个元素出现的次数，应与元素在两个数组中出现的次数一致。
我们可以不考虑输出结果的顺序。
进阶:

如果给定的数组已经排好序呢？你将如何优化你的算法？
如果 nums1 的大小比 nums2 小很多，哪种方法更优？
如果 nums2 的元素存储在磁盘上，磁盘内存是有限的，并且你不能一次加载所有的元素到内存中，你该怎么办？

题解：

(哈希表) O(n+m)

首先先将nums1存入哈希表中，注意这里要用`unordered_multiset<int>`，而不是`unordered_set<int>`，因为数组中含有重复元素。

然后遍历nums2，对于每个数 x，如果 x 出现在哈希表中，则将 x 输出，且从哈希表中删除一个 x。

时间复杂度分析：假设两个数组的长度分别是 n,m。将nums1存入哈希表的计算量是 O(n)，遍历nums2的计算量是 O(m)，所以总时间复杂度是 O(n+m)。

思考题：

问：如果给定的数组已经排好序，你可以怎样优化你的算法？
答：可以用双指针扫描。这样可以把空间复杂度降为 O(1)，但时间复杂度还是 O(n)；

问：如果数组nums1的长度小于数组nums2的长度，哪种算法更好？
答：可以把nums1存入哈希表，然后遍历nums2。这样可以使用更少的内存，但时空复杂度仍是 O(n)；

问：如果数组nums2存储在硬盘上，然而内存是有限的，你不能将整个数组都读入内存，该怎么做？
答：如果nums1可以存入内存，则可以将nums1存入哈希表，然后分块将nums2读入内存，进行查找；

问：如果两个数组都不能存入内存，怎么做？

答：可以先将两个数组分别排序，比如可以用外排序，然后用类似于双指针扫描的方法，将两个数组分块读入内存，进行查找。

```c++
class Solution {
public:
    vector<int> intersect(vector<int>& nums1, vector<int>& nums2) {
        if(nums1.size() > nums2.size()) swap(nums1, nums2); // 保证nums1长度更小
        unordered_multiset<int> hash;
        vector<int> res;
        for(auto &x : nums1){
            hash.insert(x);
        }
        for(auto &x : nums2){
            auto it = hash.find(x);
            if(it != hash.end()){
                hash.erase(it); // 必须传入迭代器，如果传入值的话，multiset会把所有的相同值都删除
                res.push_back(x);
            }
        }
        return res;
    }
};
```

### 706. 设计哈希映射

[LeetCode 706. Design HashMap by yxc](https://www.acwing.com/solution/LeetCode/content/443/)

不使用任何内建的哈希表库设计一个哈希映射

具体地说，你的设计应该包含以下的功能

put(key, value)：向哈希映射中插入(键,值)的数值对。如果键对应的值已经存在，更新这个值。
get(key)：返回给定的键所对应的值，如果映射中不包含这个键，返回-1。
remove(key)：如果映射中存在这个键，删除这个数值对。

示例：

MyHashMap hashMap = new MyHashMap();
hashMap.put(1, 1);
hashMap.put(2, 2);
hashMap.get(1);            // 返回 1
hashMap.get(3);            // 返回 -1 (未找到)
hashMap.put(2, 1);         // 更新已有的值
hashMap.get(2);            // 返回 1
hashMap.remove(2);         // 删除键为2的数据
hashMap.get(2);            // 返回 -1 (未找到)

注意：

所有的值都在 [1, 1000000]的范围内。
操作的总数目在[1, 10000]范围内。
不要使用内建的哈希库。

哈希表有开链法、开放寻址法，STL中一般用开链法，开链法需要消耗更多空间，但是开放寻址法在删除的时候得有额外操作（y总说开放寻址法更容易，但我咋觉得开链法更容易呢？）

哈希表的长度最好是质数，而且要离2的幂要远，大概是总数据量的两倍，所以y总选了20011这个质数作为哈希表长度

#### 开链法

思想很简单，在哈希表中的每个位置上，用一个链表来存储所有映射到该位置的元素。

对于put(key, value)操作，我们先求出key的哈希值，然后遍历该位置上的链表，如果链表中包含key，则更新其对应的value；如果链表中不包含key，则直接将（key，value）插入该链表中。

对于get(key)操作，求出key对应的哈希值后，遍历该位置上的链表，如果key在链表中，则返回其对应的value，否则返回-1。
对于remove(key)，求出key的哈希值后，遍历该位置上的链表，如果key在链表中，则将其删除。

时间复杂度分析：最坏情况下，所有key的哈希值都相同，且key互不相同，则所有操作的时间复杂度都是 O(n)。但最坏情况很难达到，每个操作的期望时间复杂度是 O(1)。

空间复杂度分析：一般情况下，初始的大数组开到总数据量的**两到三倍大小**即可，且所有链表的总长度是 O(n) 级别的，所以总空间复杂度是 O(n)。

```c++
class MyHashMap {
public:
    /** Initialize your data structure here. */
    const static int N = 20011;

    vector<list<pair<int,int>>> hash;

    MyHashMap() {
        hash = vector<list<pair<int,int>>>(N);
    }

    list<pair<int,int>>::iterator find(int key)
    {
        int t = key % N;
        auto it = hash[t].begin();
        for (; it != hash[t].end(); it ++ )
            if (it->first == key)
                break;
        return it;
    }

    /** value will always be non-negative. */
    void put(int key, int value) {
        int t = key % N;
        auto it = find(key);
        if (it == hash[t].end())
            hash[t].push_back(make_pair(key, value));
        else
            it->second = value;
    }

    /** Returns the value to which the specified key is mapped, or -1 if this map contains no mapping for the key */
    int get(int key) {
        auto it = find(key);
        if (it == hash[key % N].end())
            return -1;
        return it->second;
    }

    /** Removes the mapping of the specified value key if this map contains a mapping for the key */
    void remove(int key) {
        int t = key % N;
        auto it = find(key);
        if (it != hash[t].end())
            hash[t].erase(it);
    }
};

/**
 * Your MyHashMap object will be instantiated and called as such:
 * MyHashMap obj = new MyHashMap();
 * obj.put(key,value);
 * int param_2 = obj.get(key);
 * obj.remove(key);
 */
```

#### 开放寻址法

开放寻址法的基本思想是这样的：如果当前位置已经被占，则顺次查看下一个位置，直到找到一个空位置为止。

对于put(key, value)操作，求出key的哈希值后，顺次往后找，直到找到key或者找到一个空位置为止，然后将key放到该位置上，同时更新相应的value。

对于get(key)操作，求出key的哈希值后，顺次往后找，直到找到key或者-1为止（注意空位置有两种：-1和-2，这里找到-1才会停止），如果找到了key，则返回对应的value。

对于remove(key)操作，求出key的哈希值后，顺次往后找，直到找到key或者-1为止，如果找到了key，则将该位置的key改为-2，表示该数已被删除。（有可能之前的key放在了当前待删除值的后面，如果当前删除改key为-1，那么之前的key就没法找到了）

注意：当我们把一个key删除后，不能将其改成-1，而应该打上另一种标记。否则一个连续的链会从该位置断开，导致后面的数查询不到。

时间复杂度分析：最坏情况下，所有key的哈希值都相同，且key互不相同，则所有操作的时间复杂度都是 O(n)。但实际应用中最坏情况难以遇到，每种操作的期望时间复杂度是 O(1)。

空间复杂度分析：一般来说，初始大数组开到总数据量的两到三倍，就可以得到比较好的运行效率，空间复杂度是 O(n)。

```c++
class MyHashMap {
public:
    /** Initialize your data structure here. */
    const static int N = 20011;
    int hash_key[N], hash_value[N];

    MyHashMap() {
        memset(hash_key, -1, sizeof hash_key);
    }

    int find(int key)
    {
        int t = key % N;
        while (hash_key[t] != key && hash_key[t] != -1)
        {
            if ( ++t == N) t = 0;
        }
        return t;
    }

    /** value will always be non-negative. */
    void put(int key, int value) {
        int t = find(key);
        hash_key[t] = key;
        hash_value[t] = value;
    }

    /** Returns the value to which the specified key is mapped, or -1 if this map contains no mapping for the key */
    int get(int key) {
        int t = find(key);
        if (hash_key[t] == -1) return -1;
        return hash_value[t];
    }

    /** Removes the mapping of the specified value key if this map contains a mapping for the key */
    void remove(int key) {
        int t = find(key);
        if (hash_key[t] != -1)
            hash_key[t] = -2;
    }
};

/**
 * Your MyHashMap object will be instantiated and called as such:
 * MyHashMap obj = new MyHashMap();
 * obj.put(key,value);
 * int param_2 = obj.get(key);
 * obj.remove(key);
 */
```

### 652. 寻找重复的子树

给定一棵二叉树，返回所有重复的子树。对于同一类的重复子树，你只需要返回其中任意一棵的根结点即可。

两棵树重复是指它们具有相同的结构以及相同的结点值。

示例 1：

```shell
        1
       / \
      2   3
     /   / \
    4   2   4
       /
      4
```

下面是两个重复的子树：

   2
 /
4

和

4

因此，你需要以列表的形式返回上述重复子树的根结点。

题解：

(深度优先遍历，哈希表) O(n2)

使用 unordered_map 记录每个子树经过哈希后的数量，哈希方法可以用最简单的前序遍历，即 根,左子树,右子树 的方式递归构造。逗号和每个叶子结点下的空结点的位置需要保留。

若发现当前子树在哈希表第二次出现，则将该结点记入答案列表。

时间复杂度

每个结点仅遍历一次，unordered_map 单次操作的时间复杂度为 O(1)。

但遍历结点中，可能要拷贝当前字符串到答案，拷贝的时间复杂度为 O(n)，故总时间复杂度为 O(n2)。

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
    vector<TreeNode*> findDuplicateSubtrees(TreeNode* root) {
        unordered_map<string, int> hash;
        vector<TreeNode*> ans;
        dfs(root, hash, ans);
        return ans;
    }
    string dfs(TreeNode *r, unordered_map<string, int> &hash, vector<TreeNode*> &ans) {
        if (r == NULL)
            return "";
        string cur = "";
        cur += to_string(r -> val) + ",";
        cur += dfs(r -> left, hash, ans) + ",";
        cur += dfs(r -> right, hash, ans);
        hash[cur]++;
        if (hash[cur] == 2)
            ans.push_back(r);
        return cur;
    }
};
```

### 290. 单词规律

给定一种规律 pattern 和一个字符串 str ，判断 str 是否遵循相同的规律。

这里的 遵循 指完全匹配，例如， pattern 里的每个字母和字符串 str 中的每个非空单词之间存在着双向连接的对应规律。

示例1:
输入: pattern = "abba", str = "dog cat cat dog"
输出: true

示例 2:
输入:pattern = "abba", str = "dog cat cat fish"
输出: false

示例 3:
输入: pattern = "aaaa", str = "dog cat cat dog"
输出: false

示例 4:
输入: pattern = "abba", str = "dog dog dog dog"
输出: false

说明:
你可以假设 pattern 只包含小写字母， str 包含了由单个空格分隔的小写字母。

题解：

有点像离散数学中的**双射**概念

假设pattern有 n 个字母，str有 n 个单词。相当于给了我们 n 组字母和单词的对应关系，然后问字母和单词是否一一对应，即相同字母对应相同单词，且不同字母对应不同单词。不同字母对应不同单词，等价于相同单词对应相同字母。

所以我们可以用两个哈希表，分别存储单词对应的字母，以及字母对应的单词。然后从前往后扫描，判断相同元素对应的值，是否是相同的。

为了得到各单词，用stringstream非常方便！

时间复杂度分析：数组和单词仅被遍历一次，所以时间复杂度是线性的。假设str的长度是 L，那么总时间复杂度就是 O(L)。

```c++
class Solution {
public:
    bool wordPattern(string pattern, string str) {
        stringstream raw(str);
        vector<string> strs;
        string line;
        while (raw >> line) strs.push_back(line); // 与标准输入cin用法一样
        if (pattern.size() != strs.size()) return false;
        unordered_map<char, string> PS; // 双射，所以用两个哈希表，有任何一个映射不满足，则返回false
        unordered_map<string, char> SP;
        for (int i = 0; i < pattern.size(); i ++ )
        {
            if (PS.count(pattern[i]) == 0) PS[pattern[i]] = strs[i];
            if (SP.count(strs[i]) == 0) SP[strs[i]] = pattern[i];
            if (PS[pattern[i]] != strs[i]) return false;
            if (SP[strs[i]] != pattern[i]) return false;
        }
        return true;
    }
};
```

### 554. 砖墙

你的面前有一堵方形的、由多行砖块组成的砖墙。 这些砖块高度相同但是宽度不同。你现在要画一条自顶向下的、穿过最少砖块的垂线。

砖墙由行的列表表示。 每一行都是一个代表从左至右每块砖的宽度的整数列表。

如果你画的线只是从砖块的边缘经过，就不算穿过这块砖。你需要找出怎样画才能使这条线穿过的砖块数量最少，并且返回穿过的砖块数量。

你不能沿着墙的两个垂直边缘之一画线，这样显然是没有穿过一块砖的。

示例：

输入: [[1,2,2,1],
      [3,1,2],
      [1,3,2],
      [2,4],
      [3,1,2],
      [1,3,1,1]]

输出: 2

解释:

![brickwall](https://assets.leetcode-cn.com/aliyun-lc-upload/uploads/2018/10/12/brick_wall.png)

提示：

每一行砖块的宽度之和应该相等，并且不能超过 INT_MAX。
每一行砖块的数量在 [1,10,000] 范围内， 墙的高度在 [1,10,000] 范围内， 总的砖块数量不超过 20,000。

题解：

在这种方法中，我们使用哈希表 map 来保存记录 )(sum,count) ，这里 sum 是当前行累积的砖头宽度， count 是 sum 对应的穿过砖头数目。

我们来看一看过程是如何进行的。我们逐一遍历墙的每一行，对于每一块砖，我们将当前行遇到的所有砖头的宽度加起来得到 sum，如果这个 sum 在 map 中没有出线过，我们创建一个初始 count 值为 1 的相应条目。如果 sum 已经存在于哈希表中，我们只需要给对应的 countcount 加一。

这个过程的原理基于以下观察：我们在遍历同一行的时候不会遇到相同的 sum 两次。所以如果 sum 在遍历过程中遇到相同的值，说明一定存在别的行 sum 也是那些行的衔接处。所以对应的 count 值需要加一。

对于每一行，我们只考虑到倒数第二块砖头的 sum 值，因为最后一块砖头的右边界不是一个衔接处。

最后，我们从哈希表中找到最大的 count 值，用这个值求出垂直竖线穿过的最少砖块数。

时间复杂度： O(n)。我们只会遍历每一块完整的砖块一次， n 是墙的所有砖的总数。

空间复杂度： O(m)。 map 只包含最多 m 个记录，其中 m 是墙的宽度。

```c++
class Solution {
public:
    int leastBricks(vector<vector<int>>& wall) {
        if (wall.empty()) return 0;
        int rows = wall.size();
        unordered_map<int, int> hash;
        int sum = 0;
        int max_count = 0;
        for (int i = 0; i < rows; ++i) {
            sum = 0;
            for (int j = 0; j < wall[i].size() - 1; ++j) {
                sum += wall[i][j];
                ++hash[sum];
            }
        }
        for (auto& p : hash) {
            max_count = max(max_count, p.second);
        }
        return rows - max_count;
    }
};
```

### 149. 直线上最多的点数

给定一个二维平面，平面上有 n 个点，求最多有多少个点在同一条直线上。

示例 1:

输入: [[1,1],[2,2],[3,3]]
输出: 3
解释:
^
|
|        o
|     o
|  o  
+------------->
0  1  2  3  4
示例 2:

输入: [[1,1],[3,2],[5,3],[4,1],[2,3],[1,4]]
输出: 4
解释:
^
|
|  o
|     o        o
|        o
|  o        o
+------------------->
0  1  2  3  4  5  6

题解：

(哈希表) O(n2)

先枚举一个定点，然后将其它点按斜率分组，斜率指与定点连线的斜率，分组可以利用哈希表。
由于**一个定点加斜率可以唯一确定一条直线**，所以被分到同一组的点都在一条直线上。组中点数的最大值就是答案。

特殊情况：

1. 竖直直线不存在斜率，需要单独计数；
2. 与定点重合的点可以被分到所有组中，需要单独处理；
3. 另外，为了避免精度问题，此题中的斜率用 long double 存储。

时间复杂度分析：总共枚举 n 个定点，对于每个定点再枚举 n−1 个其余点，枚举后哈希表操作的时间复杂度是 O(1)，所以总时间复杂度是 O(n2)。

```c++
class Solution {
public:
    int maxPoints(vector<vector<int>>& points) {
        if(points.empty()) return 0;
        int res = 1;
        for(int i = 0; i < points.size(); ++i){
            unordered_map<long double, int> map;
            int duplicates = 0;
            int verticals = 1; // 竖直线不存在斜率，所以单独记录，单独比较
            // 先寻找与定点重合的点，用duplicates变量记录
            for(int j = i + 1; j < points.size(); ++j){
                if(points[i][0] == points[j][0]){
                    ++verticals;
                    if (points[i][1] == points[j][1]) ++duplicates; // 因为duplicates的存在，所以分为两个for循环
                }
            }
            // 再遍历其他点
            for(int j = i + 1; j < points.size(); ++j)
                if (points[i][0] != points[j][0]){
                    long double slope = (long double)(points[i][1] - points[j][1]) / (points[i][0] - points[j][0]); // double精度不够，而且要先把y1-y2转为long double，不然变成int/int
                    if (map[slope] == 0) map[slope] = 2;
                    else ++map[slope] ;
                    res = max(res, map[slope] + duplicates);
                }

            res = max(res, verticals);
        }
        return res;
    }
};
```

### 355. 设计推特

设计一个简化版的推特(Twitter)，可以让用户实现发送推文，关注/取消关注其他用户，能够看见关注人（包括自己）的最近十条推文。你的设计需要支持以下的几个功能：

1. postTweet(userId, tweetId): 创建一条新的推文
2. getNewsFeed(userId): 检索最近的十条推文。每个推文都必须是由此用户关注的人或者是用户自己发出的。推文必须按照时间顺序由最近的开始排序。
3. follow(followerId, followeeId): 关注一个用户
4. unfollow(followerId, followeeId): 取消关注一个用户

示例:

```c++
Twitter twitter = new Twitter();

// 用户1发送了一条新推文 (用户id = 1, 推文id = 5).
twitter.postTweet(1, 5);

// 用户1的获取推文应当返回一个列表，其中包含一个id为5的推文.
twitter.getNewsFeed(1);

// 用户1关注了用户2.
twitter.follow(1, 2);

// 用户2发送了一个新推文 (推文id = 6).
twitter.postTweet(2, 6);

// 用户1的获取推文应当返回一个列表，其中包含两个推文，id分别为 -> [6, 5].
// 推文id6应当在推文id5之前，因为它是在5之后发送的.
twitter.getNewsFeed(1);

// 用户1取消关注了用户2.
twitter.unfollow(1, 2);

// 用户1的获取推文应当返回一个列表，其中包含一个id为5的推文.
// 因为用户1已经不再关注用户2.
twitter.getNewsFeed(1);
```

数据结构：

1. 用`unordered_map<int, vector<pair<int,int>>> posts` 从一个用户映射到他发布的微博列表，其中`pair<int,int>`的first域存储发布的时间，second域存储发布微博的id；
2. 用`unordered_map<int, unordered_set<int>> follows` 从一个用户映射到他的关注列表；

对于所有操作：

1. `postTweet(userId, tweetId)`，首先用posts找到这个用户发布的微博列表，然后将tweetId插入该列表中；
2. `getNewsFeed(userId)`，首先用follows找到这个用户所有的关注，然后将他们发布的所有微博存入一个vector，最后将vector按时间顺序排序后输出前十个；
3. `follow(followerId, followeeId)`，首先用follows找到followerId的关注列表，然后将followeeId插入该列表；
4. `unfollow(followerId, followeeId)`，首先用follows找到followerId的关注列表，然后将followeeId从该列表中删除；

时间复杂度分析：

1. 对于`postTweet(userId, tweetId)`操作，只有一次哈希表查找操作和一次vector插入操作，时间复杂度是 O(1)；
2. 对于`getNewsFeed(userId)`操作，需要遍历他所关注的所有微博，再对所有微博排序，时间复杂度是 O(nlogn)；
3. 对于`follow(followerId, followeeId)`操作，只有一次哈希表查找操作，和一次哈希表插入操作，时间复杂度是 O(1)；
4. 对于`unfollow(followerId, followeeId)`操作，只有一次哈希表查找操作，和一次哈希表删除操作，时间复杂度是 O(1)；

y总的getNewsFeed用的是很暴力的做法，思考一下，这里其实需要k个人（包括自己与关注人）的最近推特，合起来之后再选择最近10条，这其实就是“合并k个有序链表”的问题，可以用priority_queue来做

```c++
class Twitter {
public:
    /** Initialize your data structure here. */
    unordered_map<int,vector<pair<int,int>>> posts; // userId : [pair<timestamp, tweetId>, ...]
    unordered_map<int,unordered_set<int>> follows;  // userId : set<userId, ...>
    int id = 0; // tweetId，单调递增，越大说明越新
    Twitter() {
    }

    /** Compose a new tweet. */
    void postTweet(int userId, int tweetId) {
        posts[userId].push_back(make_pair(id++, tweetId));
    }

    /** Retrieve the 10 most recent tweet ids in the user's news feed.
    Each item in the news feed must be posted by users who the user followed or by the user herself.
    Tweets must be ordered from most recent to least recent. */
    vector<int> getNewsFeed(int userId) {
        vector<int> res;
        priority_queue<pair<int, int>, vector<pair<int, int>>, less<pair<int, int>>> pq; // 因为默认最大堆，最后的less仿函数可以省略
        // 本用户的前十条最近微博
        for(auto &p : posts[userId]){
            pq.push(p); // pq默认比较pair的first，即timestamp
        }
        for(auto &userId : follows[userId]){
            for(auto &p : posts[userId]){
                pq.push(p);
            }
        }
        for(int i = 0; i < 10 && !pq.empty(); ++i){
            res.push_back(pq.top().second);
            pq.pop();
        }
        return res;
    }

    /** Follower follows a followee. If the operation is invalid, it should be a no-op. */
    void follow(int followerId, int followeeId) {
        if (followerId != followeeId)
            follows[followerId].insert(followeeId);
    }

    /** Follower unfollows a followee. If the operation is invalid, it should be a no-op. */
    void unfollow(int followerId, int followeeId) {
        follows[followerId].erase(followeeId);
    }
};

/**
 * Your Twitter object will be instantiated and called as such:
 * Twitter obj = new Twitter();
 * obj.postTweet(userId,tweetId);
 * vector<int> param_2 = obj.getNewsFeed(userId);
 * obj.follow(followerId,followeeId);
 * obj.unfollow(followerId,followeeId);
 */
```

### 128. 最长连续序列

hard题，就不看了hhh

## 贪心with闫学灿

贪心的证明比较复杂多变，可能需要数学归纳法等等

### 860. 柠檬水找零

在柠檬水摊上，每一杯柠檬水的售价为 5 美元。

顾客排队购买你的产品，（按账单 bills 支付的顺序）一次购买一杯。

每位顾客只买一杯柠檬水，然后向你付 5 美元、10 美元或 20 美元。你必须给每个顾客正确找零，也就是说净交易是每位顾客向你支付 5 美元。

注意，一开始你手头没有任何零钱。

如果你能给每位顾客正确找零，返回 true ，否则返回 false 。

示例 1：

输入：[5,5,5,10,20]
输出：true
解释：
前 3 位顾客那里，我们按顺序收取 3 张 5 美元的钞票。
第 4 位顾客那里，我们收取一张 10 美元的钞票，并返还 5 美元。
第 5 位顾客那里，我们找还一张 10 美元的钞票和一张 5 美元的钞票。
由于所有客户都得到了正确的找零，所以我们输出 true。
示例 2：

输入：[5,5,10]
输出：true
示例 3：

输入：[10,10]
输出：false
示例 4：

输入：[5,5,10,10,20]
输出：false
解释：
前 2 位顾客那里，我们按顺序收取 2 张 5 美元的钞票。
对于接下来的 2 位顾客，我们收取一张 10 美元的钞票，然后返还 5 美元。
对于最后一位顾客，我们无法退回 15 美元，因为我们现在只有两张 10 美元的钞票。
由于不是每位顾客都得到了正确的找零，所以答案是 false。

题解：

(贪心) O(n)

开两个变量记录手中 5 元和 10 元的数量。想象一下自己是卖家，找钱肯定先把大的找了，这就是贪心

- 收到 5 元，直接增加一张 5 元；
- 收到 10 元，如果没有 5 元了，则返回 false；
- 收到 20 元，则如果有 10 元的，并且也有至少一张 5 元的，则优先将 10 元配 5 元纸币的找回（因为 5 元的可以更灵活）；如果没有 10 元的，但 5 元的有三张，则直接找回三张 5 元的。否则，无法找零，返回 false。

时间复杂度：只需遍历一次数组，故时间复杂度为 O(n)。
空间复杂度：只需要常数个额外的变量，故空间复杂度为 O(1)。

```c++
class Solution {
public:
    bool lemonadeChange(vector<int>& bills) {
        int fives = 0;
        int tens = 0;
        for(auto &bill : bills){
            if(bill == 5){
                ++fives;
            }
            else if(bill == 10){
                if(fives > 0){
                    --fives;
                    ++tens;
                }
                else{
                    return false;
                }
            }
            else if(bill == 20){
                if(tens > 0 && fives > 0){
                    --tens;
                    --fives;
                }
                else if(fives >= 3){
                    fives -= 3;
                }
                else{
                    return false;
                }
            }
        }
        return true;
    }
};
```

### 392. 判断子序列

给定字符串 s 和 t ，判断 s 是否为 t 的子序列。

你可以认为 s 和 t 中仅包含英文小写字母。字符串 t 可能会很长（长度 ~= 500,000），而 s 是个短字符串（长度 <=100）。

字符串的一个子序列是原始字符串删除一些（也可以不删除）字符而不改变剩余字符相对位置形成的新字符串。（例如，"ace"是"abcde"的一个子序列，而"aec"不是）。

示例 1:
s = "abc", t = "ahbgdc"

返回 true.

示例 2:
s = "axc", t = "ahbgdc"

返回 false.

后续挑战 :

如果有大量输入的 S，称作S1, S2, ... , Sk 其中 k >= 10亿，你需要依次检查它们是否为 T 的子序列。在这种情况下，你会怎样改变代码？

#### 原题题解

(贪心) O(n)

在一个for loop里访问一遍长字符串的每一位，逐个寻找s的每一位。

时间复杂度O(n)O(n): 最多走一遍长字符串。

```c++
class Solution {
public:
    bool isSubsequence(string s, string t) {
        int lenS = s.size();
        int lenT = t.size();
        int i = 0;
        int j = 0;
        while(i < lenS && j < lenT){
            if(s[i] == t[j]){
                ++i;
                ++j;
            }
            else{
                ++j;
            }
        }
        if(i == lenS) return true;
        return false;
    }
};
```

#### 后续挑战

扫描一遍t串，做出26个有序的vector，第i个vector存储第i个字母在t串中出现的位置，然后利用二分去匹配s串。

扫描一遍t串，然后将每个字母的位置放入相应的26个字母的vector中（因为是按顺序扫描t串所以26个vector必定是有序的）

后面就扫描s串，s串是什么字符就对应到哪个字符的vector中去lower_bound二分，然后将代表位置的变量更新

方法一：

```c++
class Solution {
public:
    vector<int> v[26];
    bool isSubsequence(string s, string t) {
        for(int i=0;i<26;i++) v[i].clear();
        for(int i=0;i<t.length();i++)
            v[t[i]-'a'].push_back(i);
        int pos=0;
        for(auto c:s){
            if(!v[c-'a'].size())
                return false;
            else{
                auto it=lower_bound(v[c-'a'].begin(),v[c-'a'].end(),pos);
                if(it==v[c-'a'].end())
                    return false;
                else
                    pos=(*it)+1;
            }
        }
        return true;
    }
};
```

方法二：

直接打一个超大的表，表示t串的每个位置26个字母每个出现的下一个位置

根据yxc老师的思路开了一个a[26][500000],首先将整个表赋值成-1代表初始状态

然后还是去扫描t串，不过我是从后往前扫描，利用val[26]记住每个字母在后面出现的位置，然后每走到一个字符就更新val[26]中那个字符的值，再利用val[26]去给表赋值

打完表之后只要扫描s串然后查表就可以了，省去了上面算法中二分的时间

```c++
int a[26][600000];
int val[26];

class Solution {
public:
    bool isSubsequence(string s, string t) {
        memset(a,-1,sizeof(a));
        memset(val,-1,sizeof(val));
        for(int i=t.length()-1;i>=0;i--){
            val[t[i]-'a']=i;
            for(int j=0;j<26;j++)
                a[j][i]=val[j];
        }
        int pos=0;
        for(int i=0;i<s.length();i++){
            //cout << a[s[i]-'a'][pos] << endl;
            if(a[s[i]-'a'][pos]==-1)
                return false;
            else{
                pos=a[s[i]-'a'][pos];
                pos++;
            }
        }
        return true;
    }
};
```

### 455. 分发饼干

假设你是一位很棒的家长，想要给你的孩子们一些小饼干。但是，每个孩子最多只能给一块饼干。对每个孩子 i ，都有一个胃口值 gi ，这是能让孩子们满足胃口的饼干的最小尺寸；并且每块饼干 j ，都有一个尺寸 sj 。如果 sj >= gi ，我们可以将这个饼干 j 分配给孩子 i ，这个孩子会得到满足。你的目标是尽可能满足越多数量的孩子，并输出这个最大数值。

注意：

你可以假设胃口值为正。
一个小朋友最多只能拥有一块饼干。

示例 1:

输入: [1,2,3], [1,1]

输出: 1

解释:
你有三个孩子和两块小饼干，3个孩子的胃口值分别是：1,2,3。
虽然你有两块小饼干，由于他们的尺寸都是1，你只能让胃口值是1的孩子满足。
所以你应该输出1。
示例 2:

输入: [1,2], [1,2,3]

输出: 2

解释:
你有两个孩子和三块小饼干，2个孩子的胃口值分别是1,2。
你拥有的饼干数量和尺寸都足以让所有孩子满足。
所以你应该输出2.

题解：

贪心即可，两个数组先排序，双指针，这就是贪心的思想，发现自己写的和y总的几乎一模一样

```c++
class Solution {
public:
    int findContentChildren(vector<int>& g, vector<int>& s) {
        sort(g.begin(), g.end());
        sort(s.begin(), s.end());
        int count = 0;
        for(int i = 0, j = 0; i < g.size() && j < s.size(); ++j){
            if(g[i] <= s[j]){
                ++count;
                ++i;
            }
        }
        return count;
    }
};
```

### 55. 跳跃游戏

给定一个非负整数数组，你最初位于数组的第一个位置。

数组中的每个元素代表你在该位置可以跳跃的最大长度。

判断你是否能够到达最后一个位置。

示例 1:

输入: [2,3,1,1,4]
输出: true
解释: 我们可以先跳 1 步，从位置 0 到达 位置 1, 然后再从位置 1 跳 3 步到达最后一个位置。
示例 2:

输入: [3,2,1,0,4]
输出: false
解释: 无论怎样，你总会到达索引为 3 的位置。但该位置的最大跳跃长度是 0 ， 所以你永远不可能到达最后一个位置。

观察发现：如果这个数组有一些跳不到，那么数组肯定可以分为左右两部分，左边全是能跳到的，右边全是不能跳到的

观察又发现：如果这个数组全是正整数，则肯定可以全部跳完，之所有不能全部跳完，是因为出现了0，所以只需要判断能否跳过所有的即可

动态规划或者贪心或者回溯都可解决

#### 贪心

用一个变量dist记录前面可以跳到的最远距离（下标）是多少，如果最后dist能够大于最后一位的下标，则最后一位肯定能跳到

```c++
class Solution {
public:
    bool canJump(vector<int>& nums) {
        int dist = 0; // 记录之前最远能跳到的距离（下标）
        for(int i = 0; i <= dist && i < nums.size(); ++i){
            dist = max(dist, i + nums[i]); // 当前位必须能跳到才能更新
        }
        // 如果最后最远能跳到最远的距离大于数组长度，则最后一位肯定可以跳到
        // 注意size()返回无符号整形size_t，做减法的时候转为int是个好习惯，或者别让size_t做减法
        return dist >= (int)nums.size() - 1;
    }
};
```

#### 回溯

思路没错，但是超出时间限制，如果想AC，得加入一个标志来判断当前点是否被搜索过，相当于剪枝

```c++
class Solution {
public:
    bool canJump(vector<int>& nums) {
        bool flag = false;
        dfs(nums, 0, &flag);
        return flag;
    }
    void dfs(vector<int>& nums, int start, bool* flag){
        if(start >= nums.size() - 1){
            *flag = true;
            return;
        }
        for(int i = start + 1; i - start <= nums[start] && i < nums.size(); ++i){
            dfs(nums, i, flag);
        }
    }
};
```

#### 动态规划解法

或者反过来思考，从后往前遍历，如果当前点能跳到的最远距离大于前一个能到终点的下标，所以当前点可以被更新，最后看起点能否被更新即可

这种方法其实也属于贪心解法

```c++
class Solution {
public:
    bool canJump(vector<int>& nums) {
        int n = nums.size() - 1;
        for(int i = n - 1; i >= 0; --i){
            if(i + nums[i] >= n){
                n = i; // 更新当前点
            }
        }
        return n == 0; // 如果起点也能被更新，则说明起点能跳到终点
    }
};
```

### 45. 跳跃游戏 II

给定一个非负整数数组，你最初位于数组的第一个位置。

数组中的每个元素代表你在该位置可以跳跃的最大长度。

你的目标是使用最少的跳跃次数到达数组的最后一个位置。

示例:

输入: [2,3,1,1,4]
输出: 2
解释: 跳到最后一个位置的最小跳跃数是 2。
     从下标为 0 跳到下标为 1 的位置，跳 1 步，然后跳 3 步到达数组的最后一个位置。
说明:

假设你总是可以到达数组的最后一个位置。

#### dp的直观解法与优化剪枝

显然可以用动态规划，f[i]表示跳到当前位最少需要几次，但是我下面的代码超时了

```c++
class Solution {
public:
    int jump(vector<int>& nums) {
        // f[i]表示跳到当前位的最小步数
        // f[i] = min{f[j] + 1 | j + nums[j] >= i}
        // f[i]单调递增
        int len = nums.size();
        vector<int> f (len, INT_MAX);
        f[0] = 0;
        for(int i = 1; i < len; ++i){
            for(int j = 0; j < i; ++j){
                if(j + nums[j] >= i){
                    f[i] = f[j] + 1;
                    break; // 从左往右跳，第一个出现的，肯定是满足条件的最小的，所以可以提前结束
                }
            }
        }
        return f[len - 1];
    }
};
```

下面的dp代码没超时，做了剪枝和优化

```c++
class Solution {
public:
    int jump(vector<int>& nums) {
        // f[i]表示跳到当前位的最小步数
        // f[i] = min{f[j] + 1 | j + nums[j] >= i}
        // f[i]单调递增
        if(nums.size() == 1) return 0; // 特判
        int len = nums.size();
        int farthest = 0;
        vector<int> f (len, INT_MAX);
        f[0] = 0;
        for(int i = 0; i < len; ++i){
            if(i + nums[i] >= len - 1) return f[i] + 1; // 因为这题可以保证能跳到最后一格，所以这里可以提前结束，但是必须在开头对于size==1的情况下特判
            if(i + nums[i] < farthest) continue; // 剪枝
            for(int j = farthest + 1; j <= i + nums[i] && j < len; ++j){
                f[j] = min(f[j], f[i] + 1);
            }
            farthest = i + nums[i];
        }
        return f[len - 1];
    }
};
```

#### 直观的贪心

思路

- 如果某一个作为 起跳点 的格子可以跳跃的距离是 3，那么表示后面 3 个格子都可以作为 起跳点。

    可以对每一个能作为 起跳点 的格子都尝试跳一次，把 能跳到最远的距离 不断更新。

- 如果从这个 起跳点 起跳叫做第 1 次 跳跃，那么从后面 3 个格子起跳 都 可以叫做第 2 次 跳跃。

- 所以，从上一次 跳跃 的下一个格子开始，到现在 能跳到最远的距离，都 是这一次 跳跃 的 起跳点。

   对每一次 跳跃 用 for 循环来模拟。
   跳完一次之后，更新下一次 跳跃 的范围。

- 记录 跳跃 次数，如果跳到了终点，就得到了结果。

```c++
class Solution{
public:
    int jump(vector<int> &nums)
    {
        int steps = 0;
        int begin = 0;
        int end = 1;
        while (end < nums.size())
        {
            int temp = 0;
            for (int i = begin; i < end; i++)
            {
                temp = max(temp, i + nums[i]);
            }
            // 已经把第steps跳的所有格子遍历完了，所以去下一个区间
            begin = end;
            end = temp + 1;
            steps++;
        }
        return steps;
    }
};
```

优化:

从上面代码观察发现，其实被 while 包含的 for 循环中，i 是从头跑到尾的。只需要在一次 跳跃 完成时，更新下一次 能跳到最远的距离。并以此刻作为时机来更新 跳跃 次数。就可以在一次 for 循环中处理。

```c++
class Solution{
public:
    int jump(vector<int> &nums)
    {
        int steps = 0;
        int end = 0;
        int maxPos = 0;
        for (int i = 0; i < nums.size() - 1; i++)
        {
            maxPos = max(nums[i] + i, maxPos);
            if (i == end)
            {
                end = maxPos;
                steps++;
            }
        }
        return steps;
    }
};
```

### 376. 摆动序列

如果连续数字之间的差严格地在正数和负数之间交替，则数字序列称为摆动序列。第一个差（如果存在的话）可能是正数或负数。少于两个元素的序列也是摆动序列。

例如， [1,7,4,9,2,5] 是一个摆动序列，因为差值 (6,-3,5,-7,3) 是正负交替出现的。相反, [1,4,7,2,5] 和 [1,7,4,5,5] 不是摆动序列，第一个序列是因为它的前两个差值都是正数，第二个序列是因为它的最后一个差值为零。

给定一个整数序列，返回作为摆动序列的最长子序列的长度。 通过从原始序列中删除一些（也可以不删除）元素来获得子序列，剩下的元素保持其原始顺序。

示例 1:

输入: [1,7,4,9,2,5]
输出: 6
解释: 整个序列均为摆动序列。
示例 2:

输入: [1,17,5,10,13,15,10,5,16,8]
输出: 7
解释: 这个序列包含几个长度为 7 摆动序列，其中一个可为[1,17,10,13,10,16,8]。
示例 3:

输入: [1,2,3,4,5,6,7,8,9]
输出: 2
进阶:
你能否用 O(n) 时间复杂度完成此题?

贪心

先用unique删除重复元素，**unique的功能是去除相邻的重复元素(只保留一个)**,其实它并不真正把重复的元素删除，是把重复的元素移到后面去了，然后依然保存到了原数组中，然后返回去重后最后一个元素的地址，因为unique去除的是相邻的重复元素，所以一般用之前都会要排一下序。所以如果真正要删除，还要调用`erase(iter start, iter finish)`，就像下面代码那样使用

在一段连续上升（或下降）的线段中，只保留端点，这样可以得到最大子序列

```c++
class Solution {
public:
    int wiggleMaxLength(vector<int>& nums) {
        nums.erase(unique(nums.begin(), nums.end()), nums.end());
        if (nums.size() <= 2) return nums.size();
        int res = 2;
        for (int i = 1; i + 1 < nums.size(); i ++ )
            // 在一段连续上升（或下降）的线段中，只保留端点
            if (nums[i - 1] < nums[i] && nums[i] > nums[i + 1]
                || nums[i - 1] > nums[i] && nums[i] < nums[i + 1])
                res ++ ;
        return res;
    }
};
```

### 406. 根据身高重建队列

假设有打乱顺序的一群人站成一个队列。 每个人由一个整数对(h, k)表示，其中h是这个人的身高，k是排在这个人前面且身高大于或等于h的人数。 编写一个算法来重建这个队列。

注意：
总人数少于1100人。

示例

输入:
[[7,0], [4,4], [7,1], [5,0], [6,1], [5,2]]

输出:
[[5,0], [7,0], [5,2], [6,1], [4,4], [7,1]]

题目虽然没说，但是确保有答案且唯一

(贪心) O(n2)

思路：身高高的人只会看到比他高的人，所以当身高高的人固定好了位置，前面插入多少个矮的人都不会破坏高的人的条件限制。所以**应该先决定高的人的位置，再决定矮的人的位置**；高的人限制条件少，矮的人限制条件多。

先按身高从大到小排序，身高一样则按照k排序：身高大或k小意味着限制条件少，应该被优先考虑。

依次插入元素：由上一点，先进入res的元素不会被后进入的元素影响，因此每一次插入只需要考虑自己不需要考虑别人。当遍历到元素[a,b]的时候，比它大的元素已经进组，比它小的元素还没进组，那么它应该插到res的第b位，从而实现0到b-1的数字都比它大。

举例，输入是[[7,0], [4,4], [7,1], [5,0], [6,1], [5,2]]

排序后是[[7,0],[7,1],[6,1],[5,0],[5,2],[4,4]]

插入[7,0], res=[[7,0]]

插入[7,1], res=[[7,0],[7,1]]

插入[6,1], res=[[7,0],[6,1],[7,1]]

插入[5,0], res=[[5,0],[7,0],[6,1],[7,1]]

插入[5,2], res=[[5,0],[7,0],[5,2],[6,1],[7,1]]

插入[4,4], res=[[5,0],[7,0],[5,2],[6,1],[4,4],[7,1]]

最终答案是[[5,0], [7,0], [5,2], [6,1], [4,4], [7,1]]

```c++
class Solution {
public:
    vector<vector<int>> reconstructQueue(vector<vector<int>>& people) {
        // 定义仿函数，要从大到小排列，这样在输出ans的时候，大的优先排列
        // 定义大小，除了身高之外，还要看k，k越大的，说明限制越多，所以定义为更小
        auto comp = [](const vector<int>& a, const vector<int>& b){
            return a[0] > b[0] || (a[0] == b[0] && a[1] < b[1]);
        };
        sort(people.begin(), people.end(), comp);
        vector<vector<int>> ans;
        for(auto &p : people){
            // 当遍历到元素[a,b]的时候，比它大的元素已经进组，比它小的元素还没进组
            // 那么它应该插到res的第b位，从而实现0到b-1的数字都比它大。
            ans.insert(ans.begin()+p[1], p);
        }
        return ans;
    }
};
```

### 452. 用最少数量的箭引爆气球（经典）

在二维空间中有许多球形的气球。对于每个气球，提供的输入是水平方向上，气球直径的开始和结束坐标。由于它是水平的，所以y坐标并不重要，因此只要知道开始和结束的x坐标就足够了。开始坐标总是小于结束坐标。平面内最多存在104个气球。

一支弓箭可以沿着x轴从不同点完全垂直地射出。在坐标x处射出一支箭，若有一个气球的直径的开始和结束坐标为 xstart，xend， 且满足  xstart ≤ x ≤ xend，则该气球会被引爆。可以射出的弓箭的数量没有限制。 弓箭一旦被射出之后，可以无限地前进。我们想找到使得所有气球全部被引爆，所需的弓箭的最小数量。

Example:

输入:
[[10,16], [2,8], [1,6], [7,12]]

输出:
2

解释:
对于该样例，我们可以在x = 6（射爆[2,8],[1,6]两个气球）和 x = 11（射爆另外两个气球）。

(排序贪心) O(nlog⁡n)

此题可以考虑将区间求交集，最后必定是一些不重叠的独立的区间，独立的区间个数就是答案数。具体做法如下：

首先将区间按照右端点从小到大排序，设立end代表当前区间的右端点，刚开始在第一个区间的右端点射出一次，所以res初始为1

每当遇到一个新区间，若新区间的左端点大于end，则说明没有被射过，于是得在新区间的右端点射一次，更新end。

时间复杂度：对所有区间排序一次，遍历一次，故总时间复杂度为O(nlog⁡n)。

```c++
int findMinArrowShots(vector<vector<int>>& points) {
        if(points.size()==0) return 0;
        // 因为pair默认比较first的大小，所以要用仿函数来比较second的大小
        auto cmp=[](const vector<int>& a, const vector<int>& b){
            return a[1]<b[1];
        };
        // 将所有右端点排序，每次都射右端点，射完全部气球为止为止
        sort(points.begin(),points.end(),cmp);
        int res = 1;
        int end = points[0][1];
        for(int i = 1; i < points.size(); i++){
            // points[i][0] < end的气球都射完了
            if(points[i][0] > end){
                res++;
                end=points[i][1];
            }
        }
        return res;
    }
```

### 402. 移掉K位数字（经典）

给定一个以字符串表示的非负整数 num，移除这个数中的 k 位数字，使得剩下的数字最小。

注意:

num 的长度小于 10002 且 ≥ k。
num 不会包含任何前导零。

示例 1 :

输入: num = "1432219", k = 3
输出: "1219"
解释: 移除掉三个数字 4, 3, 和 2 形成一个新的最小的数字 1219。

示例 2 :

输入: num = "10200", k = 1
输出: "200"
解释: 移掉首位的 1 剩下的数字为 200. 注意输出不能有任何前导零。

示例 3 :

输入: num = "10", k = 2
输出: "0"
解释: 从原数字移除所有的数字，剩余为空就是0。

(贪心) O(n)

思路：尽可能让最高位小，最高位相同的情况下尽可能让次高位小，所以应该维护一个**非递减栈**。

构建一个非递减栈stk：从左往右遍历数字num，依次进栈；每个数字x进栈前检查是否比栈顶小，是的话弹掉栈顶，再加入；全部数字一共有k次机会弹栈顶（相当于，最多在这一步删掉k个数字）

如果k次(删数字的)机会没有用完，则弹出栈顶直到stk中剩余stk.size()−k个数字（相当于从后往前删除）

举例，在Example 1中，输入为 num = “1432219”, k = 3，输出为”1219”。

第一步，构造stk的步骤是, (stk=1,k=3) –> (stk=14,k=3) –> (stk=13,k=2) –> (stk=12,k=1) –> (stk=122,k=1) –> (stk=12,k=0) –> (stk=121,k=0) –> (stk=1219,k=0)

其实不需要stack，因为最后还需要pop和reverse，这里直接用string就好了，模拟栈的思想

```c++
class Solution {
public:
    string removeKdigits(string num, int k) {
        string res;
        for (auto x : num)
        {
            while (res.size() && res.back() > x && k)
            {
                res.pop_back();
                --k;
            }
            res.push_back(x); // res += c; 也可以
        }
        while(k--) res.pop_back(); // 还有k个要删除，从后删
        int i = 0;
        while (i < res.size() && res[i] == '0') i++; // 去除前导零
        if (i == res.size()) return "0"; // 0000的情况
        return res.substr(i); // 从第i位开始（直到末尾）返回子字符串
    }
};
```

### 134. 加油站（经典）

在一条环路上有 N 个加油站，其中第 i 个加油站有汽油 gas[i] 升。

你有一辆油箱容量无限的的汽车，从第 i 个加油站开往第 i+1 个加油站需要消耗汽油 cost[i] 升。你从其中的一个加油站出发，开始时油箱为空。

如果你可以绕环路行驶一周，则返回出发时加油站的编号，否则返回 -1。

说明:

如果题目有解，该答案即为唯一答案。
输入数组均为非空数组，且长度相同。
输入数组中的元素均为非负数。
示例 1:

输入:
gas  = [1,2,3,4,5]
cost = [3,4,5,1,2]

输出: 3

解释:
从 3 号加油站(索引为 3 处)出发，可获得 4 升汽油。此时油箱有 = 0 + 4 = 4 升汽油
开往 4 号加油站，此时油箱有 4 - 1 + 5 = 8 升汽油
开往 0 号加油站，此时油箱有 8 - 2 + 1 = 7 升汽油
开往 1 号加油站，此时油箱有 7 - 3 + 2 = 6 升汽油
开往 2 号加油站，此时油箱有 6 - 4 + 3 = 5 升汽油
开往 3 号加油站，你需要消耗 5 升汽油，正好足够你返回到 3 号加油站。
因此，3 可为起始索引。
示例 2:

输入:
gas  = [2,3,4]
cost = [3,4,3]

输出: -1

解释:
你不能从 0 号或 1 号加油站出发，因为没有足够的汽油可以让你行驶到下一个加油站。
我们从 2 号加油站出发，可以获得 4 升汽油。 此时油箱有 = 0 + 4 = 4 升汽油
开往 0 号加油站，此时油箱有 4 - 3 + 2 = 3 升汽油
开往 1 号加油站，此时油箱有 3 - 3 + 3 = 3 升汽油
你无法返回 2 号加油站，因为返程需要消耗 4 升汽油，但是你的油箱只有 3 升汽油。
因此，无论怎样，你都不可能绕环路行驶一周。

算法
(贪心，双指针移动) O(n)

首先用gas-cost求出每一段的真正花费sum，然后将sum数组扩展为2*n，使得sum[i] == sum[i+n]。

定义两个指针start和end，分别表示当前假设的起点，和在这个起点下能走到的终点，tot为当前油量。

如果发现tot < 0，即不能走到end时，需要不断往后移动start，使得tot能满足要求。请读者在这里进行简要思考，向后移动start并不会使得[start,end]之间出现油量为负的情况。

如果end - start + 1 == n，即找到了一个环形路线。

时间复杂度：一共2 * n个位置，每个位置最多遍历两次，故时间复杂度为O(n)O(n)。

暴力：枚举每个加油站，看能不能走完一圈，显然需要O(n^2)，竟然能AC。。

```c++
class Solution {
public:
    int canCompleteCircuit(vector<int>& gas, vector<int>& cost) {
        int n = gas.size();
        //考虑从每一个点出发
        for (int i = 0, j = 0; i < n; ++i) {
            int gas_left = 0;
            // 尝试走一圈
            for(j = 0; j < n; ++j){
                int k = (i + j) % n; // 有可能走一圈，所以要模n
                gas_left += gas[k] - cost[k]; // 当前在加油站k，补给gas[k]，到下一个加油站需要cost[k]
                if(gas_left < 0){
                    break; // 不足以支撑到第k个加油站
                }
            }
            if(j >= n){
                 return i; // 走了一圈了，所以当前加油站i是可行解（也是唯一解）
            }
        }
        //任何点都不可以
        return -1;
    }
};
```

优化：其实不用枚举所有加油站，如果发现发现当前加油站i，在j处失败（即到不了j+1），那么i的取值可以更新为j+1，即跳过i~j之间的加油站

因为观察发现：如果在i出发，在j处失败（即到不了j+1），假设k位于i与j之间，从i到达k时，肯定有gas_left>=0（不然到不了k），相当于有**遗产**，带有遗产都到不了j+1，那么从k**白手起家**，肯定也到不了j+1，所以可以跨越一大步

时间复杂度：O(n)

```c++
class Solution {
public:
    int canCompleteCircuit(vector<int>& gas, vector<int>& cost) {
        int n = gas.size();
        //考虑从每一个点出发
        for (int i = 0, j = 0; i < n; i += j + 1){
            int gas_left = 0;
            // 尝试走一圈
            for(j = 0; j < n; ++j){
                int k = (i + j) % n; // 有可能走一圈，所以要模n
                gas_left += gas[k] - cost[k]; // 当前在加油站k，补给gas[k]，到下一个加油站需要cost[k]
                if(gas_left < 0){
                    break; // 不足以支撑到第k个加油站
                }
            }
            if(j >= n){
                 return i; // 走了一圈了，所以当前加油站i是可行解（也是唯一解）
            }
            // else，在第`k=(i+j)%n`个加油站失败，所以下次从i=k+1开始
        }
        //任何点都不可以
        return -1;
    }
};
```

## 二分

转载自[力扣题解](https://leetcode-cn.com/problems/search-insert-position/solution/te-bie-hao-yong-de-er-fen-cha-fa-fa-mo-ban-python-/)

把待搜索的目标值留在最后判断，在循环体内不断地把不符合题目要求的子区间排除掉，在退出循环以后，因为只剩下 1 个数没有看到，它要么是目标元素，要么不是目标元素，单独判断即可。

这种思路也非常符合「二分」的名字，就是把「待搜索区间」分为「有目标元素的区间」和「不包含目标元素的区间」，排除掉「不包含目标元素的区间」的区间，剩下就是「有目标元素的区间」。

建议：

1、确定搜索区间初始化时候的左右边界，有时需要关注一下边界值。在初始化时，有时把搜索区间设置大一点没有关系，但是如果恰好把边界值排除在外，再怎么搜索都得不到结果。
2、无条件写上 `while (left < right)` ，表示退出循环的条件是 left == right，对于返回左右边界就不用思考了，因此此时它们的值相等；有的是`while(left <= right)`，其实是把待搜索区间“三分”，略微码放
3、先写**向下取整的中间数取法**，然后从如何把 mid 排除掉的角度思考 if 和 else 语句应该怎样写。记住：**在 if else 语句里面只要出现 left = mid 的时候，把去中间数行为改成上取整即可**。
4、根据 if else 里面写的情况，看看是否需要修改中间数下取整的行为。向下：`int mid = l + (r - l) / 2;`，向上：`int mid = l + (r - l + 1) / 2;`
5、退出循环的时候，一定有 left == right 成立。有些时候可以直接返回 left （或者 right，由于它们相等，后面都省略括弧）或者与 left 相关的数值，有些时候还须要再做一次判断，判断 left 与 right 是否是我们需要查找的元素，这一步叫“后处理”。

### 4. 寻找两个有序数组的中位数(hard)

给定两个大小为 m 和 n 的有序数组 nums1 和 nums2。

请你找出这两个有序数组的中位数，并且要求算法的时间复杂度为 O(log(m + n))。

你可以假设 nums1 和 nums2 不会同时为空。

示例 1:

nums1 = [1, 3]
nums2 = [2]

则中位数是 2.0
示例 2:

nums1 = [1, 2]
nums2 = [3, 4]

则中位数是 (2 + 3)/2 = 2.5

TODO

### 33.搜索旋转排序数组(medium, based on 153)

假设按照升序排序的数组在预先未知的某个点上进行了旋转。

( 例如，数组 [0,1,2,4,5,6,7] 可能变为 [4,5,6,7,0,1,2] )。

搜索一个给定的目标值，如果数组中存在这个目标值，则返回它的索引，否则返回 -1 。

你可以假设数组中不存在重复的元素。

你的算法时间复杂度必须是 O(log n) 级别。

示例 1:

输入: nums = [4,5,6,7,0,1,2], target = 0
输出: 4
示例 2:

输入: nums = [4,5,6,7,0,1,2], target = 3
输出: -1

 二分查找

一看到时间复杂度必须是O(logn)，立即联想到二分查找，普通的二分查找只能查找有序序列，这题的序列不是完全有序的，

先找到在哪里旋转的，这个用二分查找是O(logn)，然后再把原数组看成有序的（经过移位），再二分查找，这也是O(logn)，故总时间为O(logn)

花了两个小时独立完成，感觉对二分查找的理解又加深了，这里有些边界条件和测试用例挺烦人的，需要思考周全

```c++
class Solution {
public:
    int search(vector<int>& nums, int target) {
        int len = nums.size();
        if(len < 1) return -1;
        int low = 0, high = len - 1, i = len / 2;
        int rotateIndex = searchRotateIndex(nums, low, high); // [4,5,6,7,0,1,2], rotateIndex=4
        int rotateAmount = high - rotateIndex + 1;
        return binarySearch(nums, low - rotateAmount, high - rotateAmount, target);
    }

    // binary search, cost O(logn)
    int binarySearch(vector<int>& nums, int low, int high, int target){
        int i = low + (high - low) / 2;
        int len = nums.size();
        if(low == high && nums[i >= 0 ? i : i + len] != target) return -1;
        if(nums[i >= 0 ? i : i + len] == target) return i >= 0 ? i : i + len;
        if(nums[i >= 0 ? i : i + len] < target){
            return binarySearch(nums, i + 1, high, target);
        }
        else{
            return binarySearch(nums, low, i, target);
        }
        return -1;
    }
    // binary search, cost O(logn)
    int searchRotateIndex(vector<int>& nums, int low, int high){
        int i = low + (high - low) / 2;
        if(low == high) return low;
        if(i == low && nums[low] > nums[high]) return high;
        if(i > low && nums[i - 1] > nums[i]) return i;
        // rotatePoint < i, eg: [6,7,0,1,2], rotatePoint=2
        if(nums[i] < nums[low]){
            return searchRotateIndex(nums, low, i - 1);
        }
        // rotatePoint > i, eg: [4,5,6,7,0,1,2], rotatePoint=4
        else if(nums[i] > nums[high]){
            return searchRotateIndex(nums, i, high);
        }
        // cannot find rotatePoint
        return 0;
    }
};
```

196/196 cases passed (4 ms)
Your runtime beats 90.46 % of cpp submissions
Your memory usage beats 71.54 % of cpp submissions (9 MB)

二刷此题，感觉更加优雅了，findMinPos需要注意一下

```c++
class Solution {
public:
    int search(vector<int>& nums, int target) {
        if(nums.empty()) return -1;
        int len = nums.size();
        int pos = findMinPos(nums); // pos是最小元素
        cout << pos << endl;
        if(nums[len - 1] >= target){
            return binarySearch(nums, pos, len - 1, target);
        }
        return binarySearch(nums, 0, (pos + len - 1)%len, target); // 当pos=0时，要二分搜索整个数组，当pos>0时，要二分搜索[0,pos-1]，用这种写法可以兼顾两种情况

    }
    int findMinPos(vector<int> &nums){
        int l = 0, r = nums.size() - 1;
        while (l < r){
            // 当前区间是旋转的，缩小搜索区间
            int mid = l + (r - l) / 2; // 中间数向上取整
            if (nums[mid] <= nums[r]){ // 缩小搜索区间为[l,mid]，因为此题无重复元素，加不加等于均可
                r = mid;
            }
            else{
                l = mid + 1;
            }
        }
        return l;
    }
    int binarySearch(vector<int>& nums, int l, int r, int target){ // 直接套模板
        // [l,r]为有序区间
        while(l < r){
            int mid = l + (r - l) / 2;
            if(nums[mid] < target){ // 缩小搜索区间为[mid+1, r]
                l = mid + 1;
            }
            else{
                r = mid;
            }
        }
        if(nums[l] == target) return l;
        return -1;
    }
};
```

在极客时间上的数据结构与算法课程做的一些笔记

一、

1. 从前往后遍历找到分界下标，分成两个有序数组
2. 判断目标值在哪个有序数据范围内，做二分查找

二、

1. 找到最大值的下标 x;
2. 所有元素下标 +x 偏移，超过数组范围值的取模;
3. 利用偏移后的下标做二分查找;
4. 如果找到目标下标，再作 -x 偏移，就是目标值实际下标。

两种情况最高时耗都在查找分界点上，所以时间复杂度是 O(N)。复杂度有点高，能否优化呢?

三、我们发现循环数组存在一个性质：以数组中间点为分区，会将数组分成一个有序数组和一个循环有序数组。这种方法只需要O(2logn)=O(logn)

1. 如果首元素小于 mid，说明前半部分是有序的，后半部分是循环有序数组;
2. 如果首元素大于 mid，说明后半部分是有序的，前半部分是循环有序的数组;
3. 如果目标元素在有序数组范围中，使用二分查找;
4. 如果目标元素在循环有序数组中，设定数组边界后，使用以上方法继续查找。

### 34. 在排序数组中查找元素的第一个和最后一个位置(medium)

给定一个按照升序排列的整数数组 nums，和一个目标值 target。找出给定目标值在数组中的开始位置和结束位置。

你的算法时间复杂度必须是 O(log n) 级别。

如果数组中不存在目标值，返回 [-1, -1]。

示例 1:

输入: nums = [5,7,7,8,8,10], target = 8
输出: [3,4]
示例 2:

输入: nums = [5,7,7,8,8,10], target = 6
输出: [-1,-1]

第一次尝试，分为两次二分搜索，第一次找是否有对应值，找到开始对应值，如果存在，则进行第二次二分搜索，找到结束对应值

```c++
class Solution {
public:
    vector<int> searchRange(vector<int>& nums, int target) {
        if(nums.empty()) return {-1, -1};
        int len = nums.size();
        int l = 0, r = len - 1;
        int start = 0, finish = len -1;
        while(l < r){
            int mid = l + (r - l) / 2;
            if(nums[mid] < target){ // 缩小待搜索区间为[mid+1,r]
                l = mid + 1;
            }
            else if(nums[mid] == target && (mid == 0 || nums[mid] != nums[mid-1])){ // 找到开始位置了！
                start = mid;
                break;
            }
            else{
                r = mid; // 往左搜索
            }
            start = l;
        }
        if(nums[start] != target) return {-1, -1};
        l = start, r = len - 1;
        while(l < r){
            int mid = l + (r - l) / 2;
            if(nums[mid] > target){ // 缩小待搜索区间为[l,mid]
                r = mid;
            }
            else if(nums[mid] == target && (mid == len - 1 || nums[mid] != nums[mid+1])){ // 找到结束位置了！
                finish = mid;
                break;
            }
            else{
                l = mid + 1; // 往右搜索
            }
            finish = l;
        }
        return {start, finish};
    }
};
```

看了AcWing上的解答，其实在if-else中不需要第三个分支，只需要注意往左还是往右搜索即可

```c++
class Solution {
public:
    vector<int> searchRange(vector<int>& nums, int target) {
        if(nums.empty()) return {-1, -1};
        int len = nums.size();
        int l = 0, r = len - 1;
        int start = 0, finish = len -1;
        while(l < r){
            int mid = l + (r - l) / 2;
            if(nums[mid] < target){ // 缩小待搜索区间为[mid+1,r]
                l = mid + 1;
            }
            else{ // 这里也包含相等的情况，因为现在是找start，所以要收缩右边界
                r = mid;
            }
        }
        start = l;
        if(nums[start] != target) return {-1, -1};
        l = start, r = len - 1;
        while(l < r){
            int mid = l + (r - l + 1) / 2; // 因为出现l=mid，所以要中间数要向上取整
            if(nums[mid] > target){ // 缩小待搜索区间为[l,mid -1]
                r = mid - 1;
            }
            else{ // 这里也包含相等的情况，因为现在是找finish，所以要收缩左边界
                l = mid;
            }
        }
        finish = l;
        return {start, finish};
    }
};
```

### 35. 搜索插入位置(easy)

给定一个排序数组和一个目标值，在数组中找到目标值，并返回其索引。如果目标值不存在于数组中，返回它将会被按顺序插入的位置。

你可以假设数组中无重复元素。

示例 1:

输入: [1,3,5,6], 5
输出: 2
示例 2:

输入: [1,3,5,6], 2
输出: 1
示例 3:

输入: [1,3,5,6], 7
输出: 4
示例 4:

输入: [1,3,5,6], 0
输出: 0

```c++
class Solution {
public:
    int searchInsert(vector<int>& nums, int target) {
        if(nums.empty()) return 0;
        int n = nums.size();
        if(nums[0] >= target) return 0;
        if(nums[n - 1] < target) return n;
        int l = 0, r = n - 1;
        while(l < r){
            int mid = l + (r - l) / 2;
            if(nums[mid] < target){ // 中间数小于target，搜索区间是[mid+1, r]
                l = mid + 1;
            }
            else{
                r = mid;
            }
        }
        return l;
    }
};
```

### 69. x 的平方根(easy)

实现 int sqrt(int x) 函数。

计算并返回 x 的平方根，其中 x 是非负整数。

由于返回类型是整数，结果只保留整数的部分，小数部分将被舍去。

示例 1:

输入: 4
输出: 2
示例 2:

分析：这里的边界情况有点恶心，而且x有可能是INT_MAX，要注意一下溢出

y总的代码非常简洁，用到了二分的模板，1ll是long long型的1，是为了防止int溢出，因为出现了`left=mid`，所以中间值向上取整

```c++
class Solution {
public:
    int mySqrt(int x) {
        int l = 0, r = x;
        while(l < r){
            int mid = (l + 1ll + r) >> 1; // 中间值向上取整
            if(mid <= x / mid) l = mid; // 中间值平方小于等于x，待搜索区间为[mid, r]
            else r = mid - 1; // 中间值平方大于x，待搜索区间为[l, mid - 1]
        }
        return l;
    }
};
```

### 74. 搜索二维矩阵(easy)

编写一个高效的算法来判断 m x n 矩阵中，是否存在一个目标值。该矩阵具有如下特性：

每行中的整数从左到右按升序排列。
每行的第一个整数大于前一行的最后一个整数。
示例 1:

输入:
matrix = [
  [1,   3,  5,  7],
  [10, 11, 16, 20],
  [23, 30, 34, 50]
]
target = 3
输出: true
示例 2:

输入:
matrix = [
  [1,   3,  5,  7],
  [10, 11, 16, 20],
  [23, 30, 34, 50]
]
target = 13
输出: false

没啥好说的，把mid转化为矩阵坐标即可

```c++
class Solution {
public:
    bool searchMatrix(vector<vector<int>>& matrix, int target) {
        if(matrix.empty() || matrix[0].empty()) return false;
        int rows = matrix.size();
        int cols = matrix[0].size();
        int row, col, mid;
        int l = 0, r = rows * cols - 1;
        while(l < r){
            mid = l + (r - l) / 2;
            row = mid / cols;
            col = mid % cols;
            if(matrix[row][col] < target){ // 搜小搜索区间为[mid+1,r]
                l = mid + 1;
            }
            else{
                r = mid;
            }
        }
        row = l / cols;
        col = l % cols;
        if(matrix[row][col] != target) return false;
        return true;
    }
};
```

### 81. 搜索旋转排序数组 II(hard, based on 154)

假设按照升序排序的数组在预先未知的某个点上进行了旋转。

( 例如，数组 [0,0,1,2,2,5,6] 可能变为 [2,5,6,0,0,1,2] )。

编写一个函数来判断给定的目标值是否存在于数组中。若存在返回 true，否则返回 false。

示例 1:

输入: nums = [2,5,6,0,0,1,2], target = 0
输出: true
示例 2:

输入: nums = [2,5,6,0,0,1,2], target = 3
输出: false
进阶:

这是 搜索旋转排序数组 的延伸题目，本题中的 nums  可能包含重复元素。
这会影响到程序的时间复杂度吗？会有怎样的影响，为什么？

根据154题，先找到允许重复的旋转数组的最小值，然后再二分搜索

因为有可能出现nums[l]==nums[mid]==nums[r]，比如2,2,2,0,2,2，所以不能用以前的方法，必须先进行**预处理**将数组末尾与数组首项相同的元素去掉，这样数组左半部的元素就会严格大于nums.back()，二分时我们的初始边界保证nums[l]严格大于nums[r]或者数组是未被旋转过的。

极端情况，数组所有元素相等，时间复杂度退化为O(n)

```c++
class Solution {
public:
    // 最难判断的边界情况就是旋转点可能出现了若干次，它们在旋转数组头和尾
    bool search(vector<int>& nums, int target) {
        if(nums.empty()) return false;
        int len = nums.size();
        int t = len - 1;
        while(t > 0 && nums[0] == nums[t]) --t; // 消除与首元素相同的末尾的重复元素
        int pos = findMinPos(nums, 0, t); // 最小元素的最左位置（看成循环数组）
        if(nums[t] >= target){
            return binarySearch(nums, pos, t, target);
        }
        return binarySearch(nums, 0, (pos + len - 1)%len, target); // 当pos=0时，要二分搜索整个数组，当pos>0时，要二分搜索[0,pos-1]，用这种写法可以兼顾两种情况

    }
    int findMinPos(vector<int> &nums, int l, int r){
        while (l < r){
            // 当前区间是旋转的，缩小搜索区间
            int mid = l + (r - l) / 2; // 中间数向上取整
            if (nums[mid] <= nums[r]){ // 缩小搜索区间为[l,mid]
                r = mid;
            }
            else{
                l = mid + 1;
            }
        }
        return l;
    }
    bool binarySearch(vector<int>& nums, int l, int r, int target){ // 直接套模板
        // [l,r]为有序区间
        while(l < r){
            int mid = l + (r - l) / 2;
            if(nums[mid] < target){ // 缩小搜索区间为[mid+1, r]
                l = mid + 1;
            }
            else{
                r = mid;
            }
        }
        if(nums[l] == target) return true;
        return false;
    }
};
```

### 153. 寻找旋转排序数组中的最小值(medium)

假设按照升序排序的数组在预先未知的某个点上进行了旋转。

( 例如，数组 [0,1,2,4,5,6,7] 可能变为 [4,5,6,7,0,1,2] )。

请找出其中最小的元素。

你可以假设数组中不存在重复元素。

示例 1:

输入: [3,4,5,1,2]
输出: 1
示例 2:

输入: [4,5,6,7,0,1,2]
输出: 0

```c++
class Solution {
public:
    int findMin(vector<int>& nums) {
        if(nums.empty()) return 0;
        int l = 0, r = nums.size() - 1;
        while(l < r){
            int mid = l + (r - l) / 2;
            if(nums[mid] < nums[r]){ // 因为无重复元素，加不加等号均可
                r = mid;
            }
            else{
                l = mid + 1;
            }
        }
        return nums[l];
    }
};
```

### 154. 寻找旋转排序数组中的最小值 II(hard)

假设按照升序排序的数组在预先未知的某个点上进行了旋转。

( 例如，数组 [0,1,2,4,5,6,7] 可能变为 [4,5,6,7,0,1,2] )。

请找出其中最小的元素。

注意数组中可能存在重复的元素。

示例 1：

输入: [1,3,5]
输出: 1
示例 2：

输入: [2,2,2,0,1]
输出: 0
说明：

这道题是 寻找旋转排序数组中的最小值 的延伸题目。
允许重复会影响算法的时间复杂度吗？会如何影响，为什么？

转自y总

![lc154](../image/lc154.png)

图中水平的实线段表示相同元素。

我们发现除了最后水平的一段（黑色水平那段）之外，其余部分满足二分性质：竖直虚线左边的数满足 nums[i]≥nums[0] 并且 nums[i]>nums[n−1]，其中 nums[n−1] 是数组最后一个元素；而竖直虚线右边的数不满足这个条件。分界点就是整个数组的最小值。

所以我们先将最后水平的一段删除即可。

另外，不要忘记处理数组完全单调的特殊情况。

时间复杂度分析：二分的时间复杂度是 O(logn)，删除最后水平一段的时间复杂度最坏是 O(n)，所以总时间复杂度是 O(n)。

```c++
class Solution {
public:
    int findMin(vector<int>& nums) {
        int t = nums.size() - 1;
        while(t > 0 && nums[t] == nums[0]) --t;
        int l = 0, r = t;
        while(l < r){
            int mid = l + (r - l) / 2;
            if(nums[mid] <= nums[r]){
                r = mid;
            }
            else{
                l = mid + 1;
            }
        }
        return nums[l];
    }
};
```

### 162. 寻找峰值(easy)

题目描述
峰值定义为比左右相邻元素大的元素。

给定一个数组 nums，保证 nums[i] ≠ nums[i+1]，请找出该数组的峰值，并返回峰值的下标。

数组中可能包含多个峰值，只需返回任意一个即可。

假定 nums[-1] = nums[n] = -∞。

样例1
输入：nums = [1,2,3,1]
输出：2
解释：3是一个峰值，3的下标是2。

样例2
输入：nums = [1,2,1,3,5,6,4]
输出：1 或 5
解释：数组中有两个峰值：1或者5，返回任意一个即可。

算法
(二分) O(logn)

仔细分析我们会发现：

由于只需要返回任意一个峰值下标，所以题解可以非常简单。

发现规律：如果 nums[i-1] > nums[i]，可以知道 [0,i−1] 中一定包含一个峰值；

所以我们可以每次二分中点，通过判断 nums[i-1] 和 nums[i] 的大小关系，可以判断左右两边哪边一定有峰值，从而可以将检索区间缩小一半。

时间复杂度分析：二分检索，每次删掉一半元素，所以时间复杂度是 O(logn)。

```C++
class Solution {
public:
    int findPeakElement(vector<int>& nums) {
        int l = 0, r = nums.size() - 1;
        while (l < r){
            int mid = (l + r + 1) / 2;
            if (nums[mid] > nums[mid - 1]) l = mid;
            else r = mid - 1;
        }
        return l;
    }
};
```

对于mid的取舍，换一种思路也是可以的

```c++
class Solution {
public:
    int findPeakElement(vector<int>& nums) {
        int l = 0, r = nums.size() - 1;
        while(l < r){
            int mid = l + (r - l) / 2;
            if(nums[mid] < nums[mid + 1]){
                l = mid + 1;
            }
            else {
                r = mid;
            }
        }
        return l;
    }
};
```

AcWing 1452 的题目，寻找矩阵中的极小值

给定一个 n×n 的矩阵，矩阵中包含 n×n 个 互不相同 的整数。定义极小值：如果一个数的值比与它相邻的所有数字的值都小，则这个数值就被称为极小值。一个数的相邻数字是指其上下左右四个方向相邻的四个数字，另外注意，处于边界或角落的数的相邻数字可能少于四个。要求在 O(nlogn) 的时间复杂度之内找出任意一个极小值的位置，并输出它在第几行第几列。

思考：首先dfs肯定不行，还不如直接遍历，那有什么查找方法能比遍历更快，那就是**二分**！

![minOfMatrix](../image/minOfMatrix.png)

- 首先选取一列（二分就是中间列），遍历一遍，找到这列的最小值，设为V，然后考察左右，分为三种情况
- 如果V < L， V < R，则V就是一个极小值，返回即可
- 如果R < V（L < V同理），则右边肯定有解，所以范围缩小了一半，再继续二分，选取右边子矩阵的中间列，遍历一遍，找到这列的最小值，设为V'，回到第一步
 左右两边都有可能有解，只需要挑一个方向即可

注意：不能行列二分！看y总举的例子

![minOfMatrixEg](../image/minOfMatrixEg.png)

```c++
// Forward declaration of queryAPI.
// int query(int x, int y);
// return int means matrix[x][y].

class Solution {
public:
    vector<int> getMinimumValue(int n) {
        int cl = 0, cr = n - 1;
        while (cl <= cr){
            int cmid = cl + (cr - cl) / 2;
            int val = INT_MAX, idx = -1;
            for (int r = 0; r < n; ++r){
                int candi_val = query(r, cmid);
                if (candi_val < val){
                    val = candi_val;
                    idx = r;
                }
            }
            int l_val = cmid > 0 ? query(idx, cmid - 1) : INT_MAX; // 防止越界
            int r_val = cmid < n - 1 ? query(idx, cmid + 1) : INT_MAX; // 防止越界
            if (val < l_val && val < r_val) return {idx, cmid}; // 得到local min
            else if (l_val < r_val) cr = cmid - 1; // 左边小，往左走
            else cl = cmid + 1; // 右边小，往右走
        }
        return {0, 0}; //只是为了过编译 循环中一定已经得出解了
    }
};
```

### 275. H指数 II(easy)

给定一位研究者论文被引用次数的数组（被引用次数是非负整数），数组已经按照升序排列。编写一个方法，计算出研究者的 h 指数。

h 指数的定义: “h 代表“高引用次数”（high citations），一名科研人员的 h 指数是指他（她）的 （N 篇论文中）至多有 h 篇论文分别被引用了至少 h 次。（其余的 N - h 篇论文每篇被引用次数不多于 h 次。）"

示例:

输入: citations = [0,1,3,5,6]
输出: 3
解释: 给定数组表示研究者总共有 5 篇论文，每篇论文相应的被引用了 0, 1, 3, 5, 6 次。
     由于研究者有 3 篇论文每篇至少被引用了 3 次，其余两篇论文每篇被引用不多于 3 次，所以她的 h 指数是 3。

说明:

如果 h 有多有种可能的值 ，h 指数是其中最大的那个。

进阶：

这是 H指数 的延伸题目，本题中的 citations 数组是保证有序的。
你可以优化你的算法到对数时间复杂度吗？

算法
(二分) O(logn)
由于数组是从小到大排好序的，所以我们的任务是：
在数组中找一个最大的 h，使得后 h个数大于等于 h。

我们发现：如果 h 满足，则小于 h 的数都满足；如果 h 不满足，则大于 h 的数都不满足。所以具有二分性质。
直接二分即可。

时间复杂度分析：二分检索，只遍历 logn 个元素，所以时间复杂度是 O(logn)O。

```c++
class Solution {
public:
    int hIndex(vector<int>& citations) {
        if(citations.empty()) return 0;
        int n = citations.size();
        if(citations[n - 1] == 0) return 0; // 特判，有可能出现[0,0,...,0]的情况
        int l = 0, r = n - 1;
        while(l < r){
            int mid = l + (r - l) / 2;
            if(citations[mid] >= n - mid){
                r = mid;
            }
            else{
                l = mid + 1;
            }
        }
        return n - l;
    }
};
```

### 278.第一个错误的版本(easy)

你是产品经理，目前正在带领一个团队开发新的产品。不幸的是，你的产品的最新版本没有通过质量检测。由于每个版本都是基于之前的版本开发的，所以错误的版本之后的所有版本都是错的。

假设你有 `n` 个版本 `[1, 2, ..., n]`，你想找出导致之后所有版本出错的第一个错误的版本。

你可以通过调用 `bool isBadVersion(version)` 接口来判断版本号 `version` 是否在单元测试中出错。实现一个函数来查找第一个错误的版本。你应该尽量减少对调用 API 的次数。

**示例:**

```c++
给定 n = 5，并且 version = 4 是第一个错误的版本。

调用 isBadVersion(3) -> false
调用 isBadVersion(5) -> true
调用 isBadVersion(4) -> true

所以，4 是第一个错误的版本。
```

```c++
// The API isBadVersion is defined for you.
// bool isBadVersion(int version);

class Solution {
public:
    int firstBadVersion(int n) {
        int l = 1, r = n;
        while(l < r){
            int mid = l + (r - l) / 2;
            if(!isBadVersion(mid)){ // mid是好版本，可以排除，所以缩小搜索区间为[mid+1, r]
                l = mid + 1;
            }
            else{
                r = mid;
            }
        }
        return l;
    }
};
```

### 287. 寻找重复数(medium)

给定一个包含 n + 1 个整数的数组 nums，其数字都在 1 到 n 之间（包括 1 和 n），可知至少存在一个重复的整数。假设只有一个重复的整数，找出这个重复的数。

示例 1:

输入: [1,3,4,2,2]
输出: 2
示例 2:

输入: [3,1,3,4,2]
输出: 3
说明：

不能更改原数组（假设数组是只读的）。
只能使用额外的 O(1) 的空间。
时间复杂度小于 O(n2) 。
数组中只有一个重复的数字，但它可能不止重复出现一次。

算法1：二分查找，时间复杂度O(nlogn)

因为数组上下界都确定了，所以可以用二分搜索来确定该重复数字在哪

以 [1, 2, 2, 3, 4, 5, 6, 7] 为例，一共 8 个数，n + 1 = 8，n = 7，根据题目意思，每个数都在 1 和 7 之间。

例如：区间 [1, 7] 的中位数是 4，遍历整个数组，统计小于等于 4 的整数的个数，至多应该为 4 个。换句话说，整个数组里小于等于 4 的整数的个数如果严格大于 4 个，就说明重复的数存在于区间 [1, 4]，它的反面是：重复的数存在于区间 [5, 7]。

于是，二分法的思路是**先猜一个数**（有效范围 [left, right]里的中间数 mid），然后统计原始数组中小于等于这个中间数的元素的个数 cnt，如果 cnt 严格大于 mid，（注意我加了着重号的部分“小于等于”、“严格大于”）依然根据抽屉原理，重复元素就应该在区间 [left, mid] 里。

```c++
class Solution {
public:
    int findDuplicate(vector<int>& nums) {
        int n = nums.size() - 1;
        int l = 1, r = n;
        while(l < r){
            int mid = l + (r - l) / 2;
            if(countRange(nums, mid) > mid){
                r = mid;
            }
            else{
                l = mid + 1;
            }
        }
        return l;
    }
    int countRange(vector<int>& nums, int mid){ // 在nums中寻找满足x<=mid的x的个数
        int count = 0;
        for(int i = 0; i < nums.size(); ++i){
            if(nums[i] <= mid) ++count;
        }
        return count;
    }
};
```

算法2：循环检测，时间复杂度O(n)

[快慢指针的解释](https://leetcode-cn.com/problems/find-the-duplicate-number/solution/kuai-man-zhi-zhen-de-jie-shi-cong-damien_undoxie-d/)

有点类似于判断环的入口节点，这篇题解解释得很清楚了

```c++
class Solution {
public:
    int findDuplicate(vector<int>& nums) {
        int slow = 0;
        int fast = 0;
        while(true){
            slow = nums[slow];
            fast = nums[fast];
            fast = nums[fast];
            if(slow == fast) break;
        }
        int finder = slow;
        slow = 0;
        while(true){
            slow = nums[slow];
            finder = nums[finder];
            if(slow == finder) break;
        }
        return slow;
    }
};
```

### 374. 猜数字大小(easy≈)

我们正在玩一个猜数字游戏。 游戏规则如下：
我从 1 到 n 选择一个数字。 你需要猜我选择了哪个数字。
每次你猜错了，我会告诉你这个数字是大了还是小了。
你调用一个预先定义好的接口 guess(int num)，它会返回 3 个可能的结果（-1，1 或 0）：

-1 : 我的数字比较小
 1 : 我的数字比较大
 0 : 恭喜！你猜对了！
示例 :

输入: n = 10, pick = 6
输出: 6

语文题目，一次性AC无压力

```c++
/**
 * Forward declaration of guess API.
 * @param  num   your guess
 * @return       -1 if num is lower than the guess number
 *               1 if num is higher than the guess number
 *               otherwise return 0
 * int guess(int num);
 */

class Solution {
public:
    int guessNumber(int n) {
        int l = 1, r = n;
        while(l < r){
            int mid = l + (r - l) / 2;
            if(guess(mid) == -1){
                r = mid - 1;
            }
            else if(guess(mid) == 1){
                l = mid + 1;
            }
            else{
                return mid;
            }
        }
        return l;
    }
};
```

### 378. 有序矩阵中第K小的元素(medium)

给定一个 n x n 矩阵，其中每行和每列元素均按升序排序，找到矩阵中第k小的元素。
请注意，它是排序后的第 k 小元素，而不是第 k 个不同的元素。

示例:

matrix = [
   [ 1,  5,  9],
   [10, 11, 13],
   [12, 13, 15]
],
k = 8,

返回 13。

提示：
你可以假设 k 的值永远是有效的, 1 ≤ k ≤ n2 。

算法：二分法，算法时间复杂度为O(n * log(m)), 其中n = max(row, col)，代表矩阵行数和列数的最大值,
 m代表二分区间的长度，即矩阵最大值和最小值的差。

首先第k大数一定落在[l, r]中，其中l = matrix[0][0], r = matrix[row - 1][col - 1].
我们二分值域[l, r]区间，mid = (l + r) >> 1, 对于mid，我们检查矩阵中有多少元素**小于等于**mid，
记个数为cnt，那么有：

1、如果cnt < k, 那么[l, mid]中包含矩阵元素个数一定小于k，那么第k小元素一定不在[l, mid]
中，必定在[mid + 1, r]中，所以更新l = mid + 1.

2、否则cnt >= k，那么[l, mid]中包含矩阵元素个数就大于等于k，即第k小元素一定在[l,mid]区间中，
更新r = mid;

```c++
class Solution {
public:
    int kthSmallest(vector<vector<int>>& matrix, int k) {
        if(matrix.empty()|| matrix[0].empty()) return -1;
        int row = matrix.size(), col = matrix[0].size();
        int l = matrix[0][0], r = matrix[row-1][col-1];
        while(l < r){
            int mid = l + (r - l)/2;
            int cnt = 0;
            for(int i = 0; i < row; ++i){
                for(int j = 0; j < col && matrix[i][j] <= mid; ++j) cnt++;
                //既然每行数组是单增的，一个大于mid的数后面的数显然也大于mid，可忽略
                //另外一定要判断<=mid，而不是<mid  
            }
            if(cnt < k) l = mid + 1;
            else r = mid;
        }
        return l;
    }
};
```
