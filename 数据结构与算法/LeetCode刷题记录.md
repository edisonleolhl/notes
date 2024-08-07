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

### 9. 回文数(easy)

判断一个整数是否是回文数。回文数是指正序（从左向右）和倒序（从右向左）读都是一样的整数。

示例 1:

输入: 121
输出: true
示例 2:

输入: -121
输出: false
解释: 从左向右读, 为 -121 。 从右向左读, 为 121- 。因此它不是一个回文数。
示例 3:

输入: 10
输出: false
解释: 从右向左读, 为 01 。因此它不是一个回文数。
进阶:

你能不将整数转为字符串来解决这个问题吗？

```c++
class Solution {
public:
    bool isPalindrome(int x) {
        if (x < 0) return false;
        string s;
        while (x) {
            s += x % 10;
            x /= 10;
        }
        int n = s.size();
        for (int i = 0; i < (n+1) / 2; ++i) { // +1即可忽略奇偶
            if (s[i] != s[n-1-i]) return false;
        }
        return true;
    }
};
```

官方给出了不需要额外空间的解法，很简洁

注意返回语句：

1. 当数字长度为奇数时，我们可以通过 revertedNumber/10 去除处于中位的数字。
2. 例如，当输入为 12321 时，在 while 循环的末尾我们可以得到 x = 12，revertedNumber = 123，
3. 由于处于中位的数字不影响回文（它总是与自己相等），所以我们可以简单地将其去除。

```c++
class Solution {
public:
    bool isPalindrome(int x) {
        if (x < 0 || (x % 10 == 0 && x != 0)) return false;
        int revertedNumber = 0;
        while (x > revertedNumber) { // 一个从0出发，一个从最高位出发，计算到一半即可
            revertedNumber = revertedNumber * 10 + x % 10;
            x /= 10;
        }
        return x == revertedNumber || x == revertedNumber / 10;
    }
};
```

### 11.盛最多水的容器 @hot100

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

我们在由线段长度构成的数组中使用两个指针，一个放在开始，一个置于末尾。 在每一步中，计算矩形，更新 maxA，并将**指向较短线段的指针向较长线段那端移动一步**，两个指针相互靠近时，矩形的底是变小的，所以只有高变大才有可能面积变大，所以，让短的那个边向中间靠近，这个思想挺巧妙的，接下来证明，为什么这样移动不会错过更大的面积

```shell
1. 若暴力枚举，状态总共有C(n,2)个
2. 假设在状态S(i,j)下h[i]<h[j]，则i向内移动，变成S(i+1,j)，此时状态集合U:{S(i,i+1), S(i,i+2), ... S(i,j-1), S(i,j)}没有被计算到
3. 每个状态的高度<=h[i]，又因为h[i]<h[j]，所以每个状态的高度都＜h[j]，而又因为j-i是最宽的，所以这些状态既没有S(i,j)宽，也没有S(i,j)高，于是肯定不会是面积最大的
4. 所以这样的移动，不会错过最大面积
```

时间复杂度O(n)、空间复杂度O(1)

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

刷hot100，想到了类似于暴力解法的动态规划，超出时间了，而且这种暴力还不如之前的优雅

```c++
class Solution {
public:
    int maxArea(vector<int>& height) {
        if (height.empty()) return 0;
        // 以当前元素为左端点所能容纳的雨水体积最大值
        int len = height.size();
        vector<int> volumns(len, 0);
        for (int i = 1; i < len; ++i) {
            for (int j = 0; j < i; ++j) {
                // 以j为左端点，以i为右端点，所能容纳雨水体积
                int area = min(height[i], height[j]) * (i - j);
                volumns[j] = max(volumns[j], area);
            }
        }
        int max_area = 0;
        for (int volumn : volumns) {
            max_area = max(max_area, volumn);
        }
        return max_area;
    }
};
```

刷hot75，这应该是最简洁的

```c++
class Solution {
public:
    int maxArea(vector<int>& height) {
        int i = 0;
        int j = height.size() - 1;
        int area = 0;
        while (i < j) {
            area = max(area, min(height[i], height[j]) * (j-i));
            if (height[i] < height[j]) ++i;
            else --j;
        }
        return area;
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

刷hot100，上面的易读性不好，重写一下

```c++
class Solution {
public:
    vector<vector<int>> threeSum(vector<int>& nums) {
        sort(nums.begin(), nums.end());
        int len = nums.size();
        vector<vector<int>> res;
        int i = 0;
        while (i < len) { // 改为while(i < len - 2)能更快点
            if (nums[i] > 0) break; // 加这句能更快点
            // satisfy i != lo != hi
            int lo = i + 1;
            int hi = len - 1;
            while (lo < hi) {
                int sum = nums[i] + nums[lo] + nums[hi];
                if (sum == 0) {
                    res.push_back({nums[i], nums[lo], nums[hi]});
                    ++lo;
                    while (lo < hi && nums[lo] == nums[lo - 1]) {
                        // 固定了其中两个数，lo代表的数不能重复，否则三元组会重复
                        ++lo;
                    }
                    --hi;
                    while (lo < hi && nums[hi] == nums[hi+1]) {
                        // 固定了其中两个数，hi代表的数不能重复，否则三元组会重复
                        --hi;
                    }
                } else if (sum < 0) {
                    ++lo;
                } else {
                    --hi;
                }
            }
            ++i;
            while (i < len && nums[i] == nums[i-1]) ++i;
        }
        return res;
    }
};
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

### 1010. 总持续时间可被 60 整除的歌曲（Medium）

在歌曲列表中，第 i 首歌曲的持续时间为 time[i] 秒。

返回其总持续时间（以秒为单位）可被 60 整除的歌曲对的数量。形式上，我们希望下标数字 i 和 j 满足  i < j 且有 (time[i] + time[j]) % 60 == 0。

示例 1：

输入：time = [30,20,150,100,40]
输出：3
解释：这三对的总持续时间可被 60 整除：
(time[0] = 30, time[2] = 150): 总持续时间 180
(time[1] = 20, time[3] = 100): 总持续时间 120
(time[1] = 20, time[4] = 40): 总持续时间 60
示例 2：

输入：time = [60,60,60]
输出：3
解释：所有三对的总持续时间都是 120，可以被 60 整除。

提示：

1 <= time.length <= 6 * 104
1 <= time[i] <= 500

我写的，不够优雅，时空复杂度都偏高

```c++
class Solution {
public:
    int getPairNums(unordered_map<int, int> &hash, int duration) {
        int min = 60;
        int step = 1;
        int ans = 0;
        while (min * step < 1000) {
            if (hash.count(min*step-duration)) {
                ans += hash[min*step-duration];
            }
            ++step;
        }
        return ans;
    }

    int numPairsDivisibleBy60(vector<int>& time) {
        unordered_map<int, int> hash; // 长度为key的歌曲共有value首
        int ans = 0;
        for (int i = 0; i < time.size(); ++i) {
            ans += getPairNums(hash, time[i]);
            hash[time[i]]++;
        }
        return ans;
    }
};
```

不难得出，符合条件的两个数是模60意义下互为加法逆元的两个数。因为是加法群，可知逆元的唯一性，所以每个数的贡献就是之前出现的逆元数量。直接哈希表或者数组计数即可。
时间O(n)，空间O(U)，此处U=60。

遍历 time：

- 举例，如果 time[i]=1，那么需要知道左边有多少个模 60 余数是 59 的数。
- 举例，如果 time[i]=62，那么需要知道左边有多少个模 60 余数是 58 的数。
- 一般地，对于 time[i]，需要知道左边有多少个模 60 余数是 60−time[i] mod 60 的数。
- 特别地，如果 time[i] 模 60 的余数是 0，那么需要知道左边有多少个模 60 余数也是 0 的数。
- 这两种情况可以合并为：累加左边 (60−time[i] mod 60) mod 60 的出现次数。
- 代码实现时，用一个长为 60 的数组 cnt 维护 time[i] mod 60 的出现次数。

```c++
class Solution {
public:
    int numPairsDivisibleBy60(vector<int> &time) {
        int ans = 0, cnt[60]{};
        for (int t : time) {
            // 先查询 cnt，再更新 cnt，因为题目要求 i<j
            // 如果先更新，再查询，就把 i=j 的情况也考虑进去了
            ans += cnt[(60 - t % 60) % 60];
            cnt[t % 60]++;
        }
        return ans;
    }
};

作者：灵茶山艾府
链接：https://leetcode.cn/problems/pairs-of-songs-with-total-durations-divisible-by-60/solutions/2259343/liang-shu-zhi-he-de-ben-zhi-shi-shi-yao-bd0r1/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

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
                    if(nums[j] > nums[i - 1]) {
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
                    if(nums[j] > nums[i - 1]) {
                        swap(nums[j], nums[i - 1]); // 从右往左，第一个满足的就交换
                        reverse(nums.begin() + i, nums.end()); // i..end是降序的，所以要逆序变成升序的
                        swapFlag = true;
                        break;
                    }
                }
                break;
            }
        }
        if(!swapFlag){
            reverse(nums.begin(), nums.end()); // 如果之前没有reverse过，说明整个序列是降序的（最大的排列），直接逆转成最小的排列
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

### 41. 缺失的第一个正数(Hard) @hot100

给你一个未排序的整数数组 nums ，请你找出其中没有出现的最小的正整数。

请你实现时间复杂度为 O(n) 并且只使用常数级别额外空间的解决方案。

示例 1：

输入：nums = [1,2,0]
输出：3
示例 2：

输入：nums = [3,4,-1,1]
输出：2
示例 3：

输入：nums = [7,8,9,11,12]
输出：1

提示：

1 <= nums.length <= 5 * 105
-231 <= nums[i] <= 231 - 1

此题难点在于O(n)的时间复杂度，并且O(1)的额外空间，数组题目要求时间复杂度O(n)意味着只能遍历、双指针、快慢指针、滑动窗口等等，而O(1)的额外空间不能用数组、哈希表等等，但可以复用原数组，注意到数组下标的也是[0, 1, 2, ... N-1]，如果能把值为1~N的元素放到数组对应下标中，则问题迎刃而解，最后遍历一下看哪个位置不匹配即可

```c++
class Solution {
public:
    int firstMissingPositive(vector<int>& nums) {
        int len = nums.size();
        // 遍历一次数组把大于等于1的和小于数组大小的值放到原数组对应位置，然后再遍历一次数组查当前下标是否和值对应，如果不对应那这个下标就是答案，否则遍历完都没出现那么答案就是数组长度加1。
        for (int i = 0; i < len; ++i) {
            while (nums[i] >= 1 && nums[i] <= len && nums[i] != nums[nums[i] - 1]) {
                // 交换
                swap(nums[i], nums[nums[i] - 1]);
            }
        }
        // 此时1~len的正数都应该在自己的位置上了，nums[i]=i
        for (int i = 0; i < len; ++i) {
            if (i + 1 != nums[i]) {
                return i + 1;
            }
        }
        return len + 1;
    }
};
```

### 42.接雨水(Hard) @hot100

给定 n 个非负整数表示每个宽度为 1 的柱子的高度图，计算按此排列的柱子，下雨之后能接多少雨水。

上面是由数组 [0,1,0,2,1,0,1,3,2,1,2,1] 表示的高度图，在这种情况下，可以接 6 个单位的雨水（蓝色部分表示雨水）。 感谢 Marcos 贡献此图。

示例:

输入: [0,1,0,2,1,0,1,3,2,1,2,1]
输出: 6

暴力，对于数组中的每个元素，我们找出下雨后水能达到的最高位置，等于两边最大高度的较小值减去当前高度的值。O(n^2)时间复杂度

```c++
class Solution {
public:
    int trap(vector<int>& height){
        int ans = 0;
        int size = height.size();
        for (int i = 1; i < size - 1; i++) {
            int max_left = 0, max_right = 0;
            for (int j = i; j >= 0; j--) { //Search the left part for max bar size
                max_left = max(max_left, height[j]);
            }
            for (int j = i; j < size; j++) { //Search the right part for max bar size
                max_right = max(max_right, height[j]);
            }
            ans += min(max_left, max_right) - height[i];
        }
        return ans;
    }
};
```

DP，在暴力方法中，我们仅仅为了找到最大值每次都要向左和向右扫描一次。但是我们可以提前存储这个值。因此，可以通过动态编程解决。O(n)时间，O(n)空间

创建两个数组left_max与right_max，

left_max[i]记录着最左端到i-1这段区间的最高高度

right_max[i]记录着i+1到最右端这段区间的最高高度

则height[i]所能贡献的雨水量 tmp = min(left_max[i], right_max[i]) - hight[i]

最后ans += tmp

```c++
class Solution {
public:
    int trap(vector<int>& height){
        if (height.empty()) return 0;
        int ans = 0;
        int size = height.size();
        vector<int> left_max(size), right_max(size);
        left_max[0] = height[0];
        for (int i = 1; i < size; i++) {
            left_max[i] = max(height[i], left_max[i - 1]);
        }
        right_max[size - 1] = height[size - 1];
        for (int i = size - 2; i >= 0; i--) {
            right_max[i] = max(height[i], right_max[i + 1]);
        }
        for (int i = 1; i < size - 1; i++) {
            ans += min(left_max[i], right_max[i]) - height[i];
        }
        return ans;
    }
};
```

双指针法：**最优解法**，O(n)时间，O(1)空间

本题解的双指针先找到当前维护的左、右最大值中较小的那个，例 当前 i 处左边的最大值如果比右边的小，那么就可以不用考虑 i 处右边最大值的影响了，因为 i 处 右边真正的最大值绝对比左边的最大值要大，在不断遍历时，更新max_l和max_r以及返回值即可。例 [0,1,0,2,1,0,1,3,2,1,2,1]中i=2时，值为0，此时max_l一定为1，当前max_r如果为2，即便max_r不是真正的i右边的最大值，也可忽略右边最大值的影响，因为右边真正的最大值一定比左边真正的最大值大。

**刷hot100时，感觉与11相似，双指针最重要的是求证仅移动一个指针时，丢掉的状态一定不比当前状态好，这样就可以放心的丢弃**

```c++
class Solution {
public:
    int trap(vector<int>& height) {
        if (height.empty() || height.size() < 3) return 0;
        int ans = 0;
        int l_max = height[0], r_max = height[height.size()-1]; // 初始化
        int l = 1, r = height.size()-2;
        while (l <= r) {
            if (l_max < r_max) {
                if (height[l] < l_max) ans += l_max - height[l];
                else l_max = height[l];
                ++l;
            } else {
                if (height[r] < r_max) ans += r_max - height[r];
                else r_max = height[r];
                --r;
            }
        }
        return ans;
    }
};
```

单调递减栈，空间复杂度O(n)，时间复杂度O(n)

说到栈，我们肯定会想到括号匹配了。我们仔细观察蓝色的部分，可以和括号匹配类比下。每次匹配出一对括号（找到对应的一堵墙），就计算这两堵墙中的水。

我们用栈保存每堵墙。

当遍历墙的高度的时候，如果当前高度小于栈顶的墙高度，说明这里会有积水，我们将墙的高度的下标入栈。

如果当前高度大于栈顶的墙的高度，说明之前的积水到这里停下，我们可以计算下有多少积水了。计算完，就把当前的墙继续入栈，作为新的积水的墙。

总体的原则就是，

1. 当前高度小于等于栈顶高度，入栈，指针后移。
2. 当前高度大于栈顶高度，出栈，计算出当前墙和栈顶的墙之间水的多少，然后计算当前的高度和新栈的高度的关系，重复第 2 步。直到当前墙的高度不大于栈顶高度或者栈空，然后把当前墙入栈，指针后移。

```c++
class Solution {
public:
    int trap(vector<int>& height){
        int ans = 0;
        stack<int> st;
        for (int i = 0; i < height.size(); i++) {
            while (!st.empty() && height[st.top()] < height[i]) {
                int cur = st.top(); // 计算cur位置能接多少雨水
                st.pop();
                if (st.empty()) break;
                int l = st.top();
                int r = i;
                int h = min(height[r], height[l]) - height[cur]; // cur位置能储水高度
                ans += (r - l - 1) * h; // 面积
            }
            st.push(i);
        }
        return ans;
    }
};
```

### 48.旋转图像 @hot100

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

刷hut100时，在上面的方法有点优化，四个元素的循环移位，只需要三次交换即可

```c++
class Solution {
public:
    void rotate(vector<vector<int>>& matrix) {
        // matrix[i][j]旋转后到达matrix[j][n-i]
        int n = matrix.size();
        if (n == 0 || n == 1) return;
        for (int layer = 0; layer < n / 2; ++layer) {
            for (int k = layer; k < n - 1 - layer; ++k) {
                 // n - layer个元素，及其对应的三个方向的元素，循环换位，[i][j]→[j][n-1-i]
                 int i = layer, j = k;
                 swap(matrix[i][j], matrix[j][n-1-i]); // shan
                 swap(matrix[n-1-i][n-1-j], matrix[n-1-j][i]);
                 swap(matrix[i][j], matrix[n-1-i][n-1-j]); // 对角换
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

### 56. 合并区间 @hot100

给出一个区间的集合，请合并所有重叠的区间。

示例 1:

输入: [[1,3],[2,6],[8,10],[15,18]]
输出: [[1,6],[8,10],[15,18]]
解释: 区间 [1,3] 和 [2,6] 重叠, 将它们合并为 [1,6].
示例 2:

输入: [[1,4],[4,5]]
输出: [[1,5]]
解释: 区间 [1,4] 和 [4,5] 可被视为重叠区间。

如果我们按照区间的左端点排序，那么在排完序的列表中，可以合并的区间一定是连续的

我们用数组 merged 存储最终的答案。

首先，我们将列表中的区间按照左端点升序排序。然后我们将第一个区间加入 merged 数组中，并按顺序依次考虑之后的每个区间：

如果当前区间的左端点在数组 merged 中最后一个区间的右端点之后，那么它们不会重合，我们可以直接将这个区间加入数组 merged 的末尾；

否则，它们重合，我们需要用当前区间的右端点更新数组 merged 中最后一个区间的右端点，将其置为二者的较大值。

时间复杂度：O(nlogn)，其中 n 为区间的数量。除去排序的开销，我们只需要一次线性扫描，所以主要的时间开销是排序的 O(nlogn)。

空间复杂度：O(logn)，其中 n 为区间的数量。这里计算的是存储答案之外，使用的额外空间。O(logn) 即为排序所需要的空间复杂度。

**注意**：经测试，cmp只比较【0】、cmp先比较【0】再比较【1】、不用cmp，这三种方法都可以

```c++
class Solution {
public:
    vector<vector<int>> merge(vector<vector<int>>& intervals) {
        vector<vector<int>> ans;
        if (intervals.empty()) return ans;
        auto cmp = [] (vector<int> p1, vector<int> p2) {
            // return p1[0] < p2[0];
            if (p1[0] < p2[0]) return true;
            if (p1[0] > p2[0]) return false;
            return p1[1] < p2[1];
        };
        sort(intervals.begin(), intervals.end(), cmp); // 按区间头升序排列
        int size = intervals.size();
        for (int i = 0; i < size; ++i) {
            int l = intervals[i][0];
            int r = intervals[i][1];
            // 寻找当前结果区间的右端点
            while (i < size - 1 && r >= intervals[i+1][0]) {
                // 当前右端点大于或等于下一个区间的左端点，说明连起来
                r = max(r, intervals[i+1][1]);
                ++i;
            }
            // 遍历完所有区间，或者右端点不连续，输出当前区间
            ans.push_back({l, r});
        }
        return ans;
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

### 73. 矩阵置零 @hot100

给定一个 m x n 的矩阵，如果一个元素为 0 ，则将其所在行和列的所有元素都设为 0 。请使用 原地 算法。

示例 1：

输入：matrix = [[1,1,1],[1,0,1],[1,1,1]]
输出：[[1,0,1],[0,0,0],[1,0,1]]
示例 2：

输入：matrix = [[0,1,2,0],[3,4,5,2],[1,3,1,5]]
输出：[[0,0,0,0],[0,4,5,0],[0,3,1,0]]

提示：

m == matrix.length
n == matrix[0].length
1 <= m, n <= 200
-231 <= matrix[i][j] <= 231 - 1

进阶：

一个直观的解决方案是使用  O(mn) 的额外空间，但这并不是一个好的解决方案。
一个简单的改进方案是使用 O(m + n) 的额外空间，但这仍然不是最好的解决方案。
你能想出一个仅使用常量空间的解决方案吗？

自己想的，O(m+n)额外空间，直接AC了，用两个一位数组记录含零的行号和列号

```c++
class Solution {
public:
    void setZeroes(vector<vector<int>>& matrix) {
        int m = matrix.size();
        if (m == 0) return;
        int n = matrix[0].size();
        if (n == 0) return;
        vector<int> row_zeros (m, 1);
        vector<int> col_zeros (n, 1);
        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; ++j) {
                if (matrix[i][j] == 0) {
                    row_zeros[i] = 0;
                    col_zeros[j] = 0;
                }
            }
        }
        for (int i = 0; i < m; ++i) {
            if (row_zeros[i] == 0) {
                vector<int>(n, 0).swap(matrix[i]);
            }
        }
        for (int j = 0; j < n; ++j) {
            if (col_zeros[j] == 0) {
                for (int i = 0; i < m; ++i) {
                    matrix[i][j] = 0;
                }
            }
        }
    }
};
```

题解的方法是用第一行第一列来标记该行是否被置零了，但原来第一行第一列的信息会被覆盖，所以用两个标记变量标记他们原来是否需要置零，注意到行or列置零，第一行or第一列的对应元素会填入0，这既代表置零（因为置零的规则就是上下左右所有元素都置零），也代表标记（该行会被置零），第一次完整遍历用来更新第一行第一列，第二次完整遍历用来将第一行第一列之外的元素置零

```c++
class Solution {
public:
    void setZeroes(vector<vector<int>>& matrix) {
        int m = matrix.size();
        if (m == 0) return;
        int n = matrix[0].size();
        if (n == 0) return;
        bool row_flag = false;
        bool col_flag = false;
        for (int i = 0; i < m; ++i) {
            if (matrix[i][0] == 0) {
                col_flag = true;
            }
        }
        for (int j = 0; j < n; ++j) {
            if (matrix[0][j] == 0) {
                row_flag = true;
                break;
            }
        }
        // 从第二行第二列开始遍历
        for (int i = 1; i < m; ++i) {
            for (int j = 1; j < n; ++j) {
                if (matrix[i][j] == 0) {
                    matrix[i][0] = 0; // 用首列来代表该行是否会被置零
                    matrix[0][j] = 0; // 用首行来代表该列是否会被置零
                }
            }
        }
        // 除第一行第一列外，所有元素该置零的置零
        for (int i = 1; i < m; ++i) {
            for (int j = 1; j < n; ++j) {
                if (matrix[i][0] == 0 || matrix[0][j] == 0) {
                    matrix[i][j] = 0;
                }
            }
        }
        // 第一行第一列置零
        if (row_flag) {
            vector<int>(n, 0).swap(matrix[0]);
        }
        if (col_flag) {
            for (int i = 0; i < m; ++i) {
                matrix[i][0] = 0;
            }
        }
    }
};
```

### 75. 颜色分类(Medium) @hot100

给定一个包含红色、白色和蓝色，一共 n 个元素的数组，原地对它们进行排序，使得相同颜色的元素相邻，并按照红色、白色、蓝色顺序排列。

此题中，我们使用整数 0、 1 和 2 分别表示红色、白色和蓝色。

注意:
不能使用代码库中的排序函数来解决这道题。

示例:

输入: [2,0,2,1,1,0]
输出: [0,0,1,1,2,2]
进阶：

一个直观的解决方案是使用计数排序的两趟扫描算法。
首先，迭代计算出0、1 和 2 元素的个数，然后按照0、1、2的排序，重写当前数组。
你能想出一个仅使用常数空间的一趟扫描算法吗？

本问题被称为 荷兰国旗问题，最初由 Edsger W. Dijkstra提出。其主要思想是给每个数字设定一种颜色，并按照荷兰国旗颜色的顺序进行调整。

我们用三个指针（p0, p2 和curr）来分别追踪0的最右边界，2的最左边界和当前考虑的元素。

本解法的思路是沿着数组移动 curr 指针，

- 若nums[curr] = 0，则将其与 nums[p0]互换；换完之后的cur位置的元素肯定在正确的位置上，所以++cur，处理下一个元素
- 若 nums[curr] = 2 ，则与 nums[p2]互换。换完之后cur的位置有可能是0,1,2，所以不一定在正确的位置上，所以不能++cur，需要继续处理cur

```c++
class Solution {
public:
    void sortColors(vector<int>& nums) {
        int n = nums.size();
        int last_0 = -1; // 指示最后一个0的下标，初始指向-1，意思是没有0
        int first_2 = n; // 指向第一个-2的下标的，初始指向n，意思是没有2
        int cur = 0;
        while (cur < first_2) {
            if (nums[cur] == 0) {
                swap(nums[last_0+1], nums[cur]);
                ++last_0;
                ++cur;
            } else if (nums[cur] == 2) { // 从右边交换过来的元素还未确定（0,1,2都有可能，所以不能++cur）
                swap(nums[first_2-1], nums[cur]);
                --first_2;
            } else {
                ++cur;
            }
        }
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

### 136.只出现一次的数字(Easy) @hot100

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

### 169. 多数元素(Easy) @hot100

给定一个大小为 n 的数组 nums ，返回其中的多数元素。多数元素是指在数组中出现次数 大于 ⌊ n/2 ⌋ 的元素。

你可以假设数组是非空的，并且给定的数组总是存在多数元素。

示例 1：

输入：nums = [3,2,3]
输出：3
示例 2：

输入：nums = [2,2,1,1,1,2,2]
输出：2

提示：
n == nums.length
1 <= n <= 5 * 104
-109 <= nums[i] <= 109

进阶：尝试设计时间复杂度为 O(n)、空间复杂度为 O(1) 的算法解决此问题。

#### 摩尔投票

摩尔投票法，核心就是对拼消耗，多数元素肯定会留下来

- 假设投票是这样的，[A, C, A, A, B]，ABC 是指三个候选人。
- 第一张票与第二张票进行对坑，如果票不同则互相抵消掉；
- 接着第三票与第四票进行对坑，如果票相同，则增加这个候选人的可抵消票数；
- 这个候选人拿着可抵消票数与第五张票对坑，如果票不同，则互相抵消掉，即候选人的可抵消票数 -1。

但这不意味着这个候选人的票数一定能超过一半，例如 [A, B, C] 的抵消阶段，最后得到的结果是 [C,1]，C 候选人的票数也未能超过一半的票数。

如果最后得到的抵消票数不为 0 的话，那说明他可能希望的，这是我们需要一个阶段来验证这个候选人的票数是否超过一半——计数阶段。

所以摩尔投票法分为两个阶段：抵消阶段和计数阶段。

- 抵消阶段：两个不同投票进行对坑，并且同时抵消掉各一张票，如果两个投票相同，则累加可抵消的次数；
- 计数阶段：在抵消阶段最后得到的抵消计数只要不为 0，那这个候选人是有可能超过一半的票数的，为了验证，则需要遍历一次，统计票数，才可确定。

摩尔投票法还可以推广到更多情况

- 如果至多选一个代表，那他的票数至少要超过一半（⌊ 1/2 ⌋）的票数；
- 如果至多选两个代表，那他们的票数至少要超过 ⌊ 1/3 ⌋ 的票数；
- 如果至多选m个代表，那他们的票数至少要超过 ⌊ 1/(m+1) ⌋ 的票数。

#### 本题特殊情况

因为这题说了明确有解，所以只需要摩尔投票的抵消阶段，而不需要计数阶段！因为抵消完了之后留下来的一定是最后的解

候选人(cand_num)初始化为 nums[0]，票数 count 初始化为 1。 当遇到与 cand_num 相同的数，则票数 count = count + 1，否则票数 count = count - 1。 当票数 count 为 0 时，更换候选人，并将票数 count 重置为 1。 遍历完数组后，cand_num 即为最终答案。

为何这行得通呢？ 投票法是遇到相同的则 票数 + 1，遇到不同的则 票数 - 1。 且“多数元素”的个数 > ⌊ n/2 ⌋，其余元素的个数总和 <= ⌊ n/2 ⌋。 因此“多数元素”的个数 - 其余元素的个数总和 的结果 肯定 >= 1。 这就相当于每个 “多数元素” 和其他元素 两两相互抵消，抵消到最后肯定还剩余 至少1个 “多数元素”。

```c++
class Solution {
public:
    int majorityElement(vector<int>& nums) {
        int candidate = nums[0];
        int count = 1;
        for (int i = 1; i < nums.size(); ++i) {
            if (nums[i] == candidate) {
                ++count;
            } else if(--count < 0){ // candidate已经被对拼完了，选取下一个candidate
                candidate = nums[i];
                count = 1;
            }
        }
        return candidate;
    }
};
```

### 229. 多数元素 II(Medium)

给定一个大小为 n 的整数数组，找出其中所有出现超过 ⌊ n/3 ⌋ 次的元素。

示例 1：

输入：nums = [3,2,3]
输出：[3]
示例 2：

输入：nums = [1]
输出：[1]
示例 3：

输入：nums = [1,2]
输出：[1,2]

提示：

1 <= nums.length <= 5 * 104
-109 <= nums[i] <= 109

进阶：尝试设计时间复杂度为 O(n)、空间复杂度为 O(1)的算法解决此问题。

摩尔投票法分为两个阶段：抵消阶段和计数阶段。

抵消阶段：两个不同投票进行对坑，并且同时抵消掉各一张票，如果两个投票相同，则累加可抵消的次数；

计数阶段：在抵消阶段最后得到的抵消计数只要不为 0，那这个候选人是有可能超过一半的票数的，为了验证，则需要遍历一次，统计票数，才可确定。

解法：

如果存在 2 个次数大于 ⌊n/3⌋的元素，我们假设这两个不同的元素分别为 x 和 y，则此时我们一定可以把数组分成三部分：第一部分相同的 m 个元素 x，第二部分相同的 k 个元素 y，第三部分为 (n−m−k)/3组三个互不同的元素，我们知道三个互不同的元素会被抵消，因此最终只会剩下两个元素为 x 和 y。

- 我们每次检测当前元素是否为第一个选中的元素或者第二个选中的元素。
- 每次我们发现当前元素与已经选中的两个元素都不相同，则进行抵消一次。
- 如果存在最终选票大于 0 的元素，我们还需要再次统计已选中元素的次数,检查元素的次数是否大于 ⌊n/3⌋

```c++
class Solution {
public:
    vector<int> majorityElement(vector<int>& nums) {
        vector<int> ans;
        int element1 = 0;
        int element2 = 0;
        int vote1 = 0;
        int vote2 = 0;

        for (auto & num : nums) {
            if (vote1 > 0 && num == element1) { //如果该元素为第一个元素，则计数加1
                vote1++;
            } else if (vote2 > 0 && num == element2) { //如果该元素为第二个元素，则计数加1
                vote2++;
            } else if (vote1 == 0) { // 选择第一个元素
                element1 = num;
                vote1++;
            } else if (vote2 == 0) { // 选择第二个元素
                element2 = num;
                vote2++;
            } else { //如果三个元素均不相同，则相互抵消1次
                vote1--;
                vote2--;
            }
        }

        int cnt1 = 0;
        int cnt2 = 0;
        for (auto & num : nums) {
            if (vote1 > 0 && num == element1) {
                cnt1++;
            }
            if (vote2 > 0 && num == element2) {
                cnt2++;
            }
        }
        // 检测元素出现的次数是否满足要求
        if (vote1 > 0 && cnt1 > nums.size() / 3) {
            ans.push_back(element1);
        }
        if (vote2 > 0 && cnt2 > nums.size() / 3) {
            ans.push_back(element2);
        }

        return ans;
    }
};
```

### 189. 旋转数组（数组） @hot100

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
    void rotate(vector<int>& nums, int k) {
        int len = nums.size();
        k = k % len;
        if (len == 0 || len == 1 || k == 0 || k == len) return;
        for (int i = 0; i < (len - k)/2; ++i) {
            swap(nums[i], nums[len-k-i-1]);
        }
        for (int i = 0; i < k / 2; ++i) {
            swap(nums[len-k+i], nums[len-i-1]);
        }
        for (int i = 0; i < len / 2; ++i) {
            swap(nums[i], nums[len-i-1]);
        }
    }
};
```

刷hot100时，没想到两步翻转，方法是递归进去设值，但是有可能会鬼打墙，有些值遍历不到

```c++
// 错误代码
class Solution {
public:
    void rotate(vector<int>& nums, int k) {
        int len = nums.size();
        k = k % len;
        if (len == 0 || len == 1 || k == 0 || k == len) return;
        if (len % 2 == 0 && k == len / 2) {
            for (int i = 0; i < len / 2; ++i) {
                swap(nums[i], nums[i+len/2]);
            }
            return;
        }
        int tmp = 0;
        int dst_value = nums[len - k];
        int dst = 0;
        int count = len;
        while (count-- > 0) {
            tmp = nums[dst];
            nums[dst] = dst_value;
            dst_value = tmp;
            // dst_value将放入新dst位置，计算新dst位置
            dst = (dst + k) % len;
        }
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

### 231. 2的幂(Easy)

给定一个整数，编写一个函数来判断它是否是 2 的幂次方。

示例 1:

输入: 1
输出: true
解释: 20 = 1
示例 2:

输入: 16
输出: true
解释: 24 = 16
示例 3:

输入: 218
输出: false

```c++
class Solution {
public:
    bool isPowerOfTwo(int n) {
        return n > 0 && !(n & n-1);
    }
};
```

### 238. 除自身以外数组的乘积 @hot100

同剑指66题

给你一个长度为 n 的整数数组 nums，其中 n > 1，返回输出数组 output ，其中 output[i] 等于 nums 中除 nums[i] 之外其余各元素的乘积。

示例:

输入: [1,2,3,4]
输出: [24,12,8,6]

提示：题目数据保证数组之中任意元素的全部前缀元素和后缀（甚至是整个数组）的乘积都在 32 位整数范围内。

说明: 请不要使用除法，且在 O(n) 时间复杂度内完成此题。

进阶：
你可以在常数空间复杂度内完成这个题目吗？（ 出于对空间复杂度分析的目的，输出数组不被视为额外空间。）

构造L数组和R数组，需要O(n)额外空间

```c++
class Solution {
public:
    vector<int> productExceptSelf(vector<int>& nums) {
        int n = nums.size();
        vector<int> ans;
        if (nums.empty() || nums.size() == 1) return ans;
        vector<int> L(n, 1), R(n, 1); // L[i]代表的是序号i左侧所有数字的乘积，右侧
        for (int i = 1; i < n; ++i) {
            L[i] = L[i-1] * nums[i-1];
        }
        for (int i = n-2; i >= 0; --i) {
            R[i] = R[i+1] * nums[i+1];
        }
        for (int i = 0; i < n; ++i) {
            ans.push_back(L[i]*R[i]);
        }
        return ans;
    }
};
```

复用ans数组，O(1)额外空间，当前位置的结果就是它左部分的乘积再乘以它右部分的乘积。因此需要进行两次遍历，第一次遍历用于求左部分的乘积，第二次遍历在求右部分的乘积的同时，再将最后的计算结果一起求出来。

```c++
class Solution {
public:
    vector<int> productExceptSelf(vector<int>& nums) {
        int n = nums.size();
        vector<int> ans (n, 1); // L与R数组共用ans，额外空间为为O(1)
        if (nums.empty() || nums.size() == 1) return ans;
        for (int i = 1; i < n; ++i) { // 先把ans当L数组用
            ans[i] = ans[i-1] * nums[i-1]; // 第i位的左边乘积=第i-1位的左边乘积*第i-1位
        }
        int rightProduct = 1; // 因为nums[n-1]已经存储了L[n-1]了，所以这里第一次进入：ans[n-1]=L[n-1]*1
        for (int i = n-1; i >= 0; --i) {
            ans[i] *= rightProduct;
            rightProduct *= nums[i]; // 不能写成right_product = res[j] * nums[j]，因为res还存储了遍历L的结果
        }
        return ans;
    }
};
```

上述做法有移位，不好理解，刷top75时用这种写法更容易理解

```c++
class Solution {
public:
    vector<int> productExceptSelf(vector<int>& nums) {
        if (nums.empty()) return nums;
        int n = nums.size();
        vector<int> ans(n, 1);
        int left_product = 1;
        for (int i = 0 ; i < n; ++i) {
            left_product *= nums[i];
            ans[i] = left_product;
        }
        int right_product = 1;
        for (int j = n - 1; j > 0; --j) {
            ans[j] = ans[j - 1] * right_product;
            right_product *= nums[j];
        }
        ans[0] = right_product;
        return ans;
    }
};
```

### 240. 搜索二维矩阵 II @ho100

同剑指第24题

编写一个高效的算法来搜索 m x n 矩阵 matrix 中的一个目标值 target。该矩阵具有以下特性：

每行的元素从左到右升序排列。
每列的元素从上到下升序排列。
示例:

现有矩阵 matrix 如下：

[
  [1,   4,  7, 11, 15],
  [2,   5,  8, 12, 19],
  [3,   6,  9, 16, 22],
  [10, 13, 14, 17, 24],
  [18, 21, 23, 26, 30]
]
给定 target = 5，返回 true。

给定 target = 20，返回 false。

最高效的算法，时间O(n+m)，空间O(1)，类似于减治的思想，每次都缩小范围

- 选左上角，往右走和往下走都增大，不能选
- 选右下角，往上走和往左走都减小，不能选
- 选左下角，往右走增大，往上走减小，可选
- 选右上角，往下走增大，往左走减小，可选

```c++
class Solution {
public:
    bool searchMatrix(vector<vector<int>>& matrix, int target) {
        if (matrix.empty() || matrix[0].empty()) return false;
        int rows = matrix.size();
        int cols = matrix[0].size();
        int i = 0;
        int j = cols - 1;
        while (i < rows && j >= 0) {
            if (matrix[i][j] > target) --j;
            else if (matrix[i][j] < target) ++i;
            else return true;
        }
        return false;
    }
};
```

### 283.移动零 @hot100

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
            if(nums[i] != 0 && i != index){ // 说明有0值存在，那么nums[i]最后要么是0，要么是被后面的非零值填充，可以在这一步先填0节省操作
                nums[index] = nums[i];
                ++index;
                nums[i] = 0;
            }
            else if(nums[i] != 0 && i == index){ // 说明到目前为止都没有0，index+1
                ++index;
            }
        }
    }
};
```

刷hot100，只想到了操作稍多一点的做法，先遍历一遍，计算得到零的数量，然后快慢指针，其实不用先遍历的，因为只要判断当前i不等于j，就知道当前格子要么被后面的非零值覆盖，要么是零值填充，所以最佳答案是上面那种

```c++
class Solution {
public:
    void moveZeroes(vector<int>& nums) {
        int len = nums.size();
        int zero_num = 0;
        for (int num : nums) {
            if (num == 0) {
                zero_num++;
            }
        }
        if (zero_num == 0) {
            return;
        }
        for (int i = 0, j = 0; i < len; ++i) {
            if (nums[i] != 0) {
                nums[j] = nums[i];
                j++;
            }
            if (i >= len - zero_num) {
                nums[i] = 0;
            }
        }
    }
};
```

刷hot75时，也没想到最优方案：

```c++
class Solution {
public:
    void moveZeroes(vector<int>& nums) {
        if (nums.empty() || nums.size() == 1) return;
        int n = nums.size();
        int i = 0;
        int j = 0;
        while (i < n) {
            while (i < n && nums[i] != 0) ++i; // i为当前找到的0的序号
            if (i == n) return;
            j = i + 1;
            while (j < n && nums[j] == 0) ++j; // j为i之后第一个不为0的序号
            if (j == n) return;
            swap(nums[i], nums[j]);
            cout << i << ", " << nums[i] << endl;
            ++i;
        }
        return;
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

### 496. 下一个更大元素 I(Easy)

给定两个 没有重复元素 的数组 nums1 和 nums2 ，其中nums1 是 nums2 的子集。找到 nums1 中每个元素在 nums2 中的下一个比其大的值。

nums1 中数字 x 的下一个更大元素是指 x 在 nums2 中对应位置的右边的第一个比 x 大的元素。如果不存在，对应位置输出 -1 。

示例 1:

输入: nums1 = [4,1,2], nums2 = [1,3,4,2].
输出: [-1,3,-1]
解释:
    对于num1中的数字4，你无法在第二个数组中找到下一个更大的数字，因此输出 -1。
    对于num1中的数字1，第二个数组中数字1右边的下一个较大数字是 3。
    对于num1中的数字2，第二个数组中没有下一个更大的数字，因此输出 -1。
示例 2:

输入: nums1 = [2,4], nums2 = [1,2,3,4].
输出: [3,-1]
解释:
    对于 num1 中的数字 2 ，第二个数组中的下一个较大数字是 3 。
    对于 num1 中的数字 4 ，第二个数组中没有下一个更大的数字，因此输出 -1 。

提示：

nums1和nums2中所有元素是唯一的。
nums1和nums2 的数组大小都不超过1000。

哈希表+单调栈，很有意思的一道题

```c++
class Solution {
public:
    vector<int> nextGreaterElement(vector<int>& nums1, vector<int>& nums2) {
        vector<int> ans (nums1.size(), -1);
        unordered_map<int, int> map; // 记录nums1每个元素与其对应下标
        for (int i = 0; i < nums1.size(); ++i) {
            map[nums1[i]] = i;
        }
        stack<int> st; // mono decreasing stack
        for (int i = 0; i < nums2.size(); ++i) {
            while (!st.empty() && nums2[st.top()] < nums2[i]) {
                int cur = st.top();
                st.pop();
                if (map.count(nums2[cur])) ans[map[nums2[cur]]] = nums2[i];
            }
            st.push(i);
        }
        return ans;
    }
};
```

### 503. 下一个更大元素 II(Medium)

给定一个循环数组（最后一个元素的下一个元素是数组的第一个元素），输出每个元素的下一个更大元素。数字 x 的下一个更大的元素是按数组遍历顺序，这个数字之后的第一个比它更大的数，这意味着你应该循环地搜索它的下一个更大的数。如果不存在，则输出 -1。

示例 1:

输入: [1,2,1]
输出: [2,-1,2]
解释: 第一个 1 的下一个更大的数是 2；
数字 2 找不到下一个更大的数；
第二个 1 的下一个最大的数需要循环搜索，结果也是 2。
注意: 输入数组的长度不会超过 10000。

单调栈，循环两次即可保证每个元素之后的所有可能

```c++
class Solution {
public:
    vector<int> nextGreaterElements(vector<int>& nums) {
        if (nums.empty()) return {};
        vector<int> ans(nums.size(), -1);
        stack<int> st; // mono decreasing stack
        // search two rounds
        for (int k = 0; k < nums.size() * 2; ++k) {
            int i = k % nums.size();
            while (!st.empty() && nums[st.top()] < nums[i]) {
                int cur = st.top();
                st.pop();
                if (ans[cur] == -1) ans[cur] = nums[i];
            }
            st.push(i);
        }
        return ans;
    }
};
```

### 556. 下一个更大元素 III

给定一个32位正整数 n，你需要找到最小的32位整数，其与 n 中存在的位数完全相同，并且其值大于n。如果不存在这样的32位整数，则返回-1。

示例 1:

输入: 12
输出: 21
示例 2:

输入: 21
输出: -1

其实就是next permutation的翻版，我首先以为这个32位整数是需要考虑它的bit，没想到就是对于十进制的n做一次next permutation即可

注意，题目要求在32位正整数中寻找next permutation，所以要及时判断

```c++
class Solution {
public:
    int nextGreaterElement(int n) {
        if (n == 0x7fffffff) return -1;
        string s;
        while (n) {
            s = to_string(n % 10) + s;
            n /= 10;
        }
        if (!next_permutation(s.begin(), s.end())) return -1;
        long ans = 0;
        long base = 1;
        for (int i = s.size()-1; i >= 0; --i) {
            ans += (s[i] - '0') * base;
            base *= 10;
            if (ans > INT_MAX) return -1;
        }
        return ans;
    }
};
```

### 724. 寻找数组的中心下标

easy

给你一个整数数组 nums ，请计算数组的 中心下标 。

数组 中心下标 是数组的一个下标，其左侧所有元素相加的和等于右侧所有元素相加的和。

如果中心下标位于数组最左端，那么左侧数之和视为 0 ，因为在下标的左侧不存在元素。这一点对于中心下标位于数组最右端同样适用。

如果数组有多个中心下标，应该返回 最靠近左边 的那一个。如果数组不存在中心下标，返回 -1 。

```
示例 1：

输入：nums = [1, 7, 3, 6, 5, 6]
输出：3
解释：
中心下标是 3 。
左侧数之和 sum = nums[0] + nums[1] + nums[2] = 1 + 7 + 3 = 11 ，
右侧数之和 sum = nums[4] + nums[5] = 5 + 6 = 11 ，二者相等。
示例 2：

输入：nums = [1, 2, 3]
输出：-1
解释：
数组中不存在满足此条件的中心下标。
示例 3：

输入：nums = [2, 1, -1]
输出：0
解释：
中心下标是 0 。
左侧数之和 sum = 0 ，（下标 0 左侧不存在元素），
右侧数之和 sum = nums[1] + nums[2] = 1 + -1 = 0 。
 

提示：

1 <= nums.length <= 104
-1000 <= nums[i] <= 1000
```

左边前缀和和右边前缀和，最开始还用了额外数组空间，效率不高

```c++
class Solution {
public:
    int pivotIndex(vector<int>& nums) {
        if (nums.empty()) return -1;
        if (nums.size() == 1) return 0;
        int n = nums.size();
        vector<int> lsum(n, 0), rsum(n, 0);
        for (int i = 0; i < n; ++i) {
            if (i == 0) {
                lsum[i] = nums[i];
                rsum[n-i-1] = nums[n-i-1];
            } else {
                lsum[i] = lsum[i-1] + nums[i];
                rsum[n-i-1] = rsum[n-i] + nums[n-i-1];
            }
        }
        if (rsum[1] == 0) return 0;
        for (int i = 1; i < n-1; ++i) {
            if (lsum[i-1] == rsum[i+1]) return i;
        }
        if (lsum[n-2] == 0) return n-1;
        return -1;
    }
};
```

仔细数学推导，如果先计算sum，然后在从左往右遍历时记录前缀和，那么在任意第i位置时，如果左边（即sum ）等于右边（即total-nums[i]-sum），则i就是我们要找到的中点，方程变换一下即可得到条件2*sum=total-nums[i]，于是可以写出异常简洁的代码

```c++
class Solution {
public:
    int pivotIndex(vector<int>& nums) {
        int total = accumulate(nums.begin(), nums.end(), 0);
        int sum = 0;
        for (int i = 0; i < nums.size(); ++i) {
            if (2*sum + nums[i] == total) return i;
            sum += nums[i];
        }
        return -1;
    }
};
```

### 1207. 独一无二的出现次数

easy

给你一个整数数组 arr，请你帮忙统计数组中每个数的出现次数。

如果每个数的出现次数都是独一无二的，就返回 true；否则返回 false。

```
示例 1：

输入：arr = [1,2,2,1,1,3]
输出：true
解释：在该数组中，1 出现了 3 次，2 出现了 2 次，3 只出现了 1 次。没有两个数的出现次数相同。
示例 2：

输入：arr = [1,2]
输出：false
示例 3：

输入：arr = [-3,0,1,-3,1,1,1,-3,10,0]
输出：true
 

提示：

1 <= arr.length <= 1000
-1000 <= arr[i] <= 1000
```

哈希表秒了

```c++
class Solution {
public:
    bool uniqueOccurrences(vector<int>& arr) {
        unordered_map<int, int> table;
        unordered_set<int> cnt;
        for (int num : arr) {
            ++table[num];
        }
        for (auto p : table) {
            if (cnt.count(p.second)) return false;
            else cnt.insert(p.second);
        }
        return true;
    }
};
```

### 1657. 确定两个字符串是否接近

medium

如果可以使用以下操作从一个字符串得到另一个字符串，则认为两个字符串 接近 ：

操作 1：交换任意两个 现有 字符。
例如，abcde -> aecdb
操作 2：将一个 现有 字符的每次出现转换为另一个 现有 字符，并对另一个字符执行相同的操作。
例如，aacabb -> bbcbaa（所有 a 转化为 b ，而所有的 b 转换为 a ）
你可以根据需要对任意一个字符串多次使用这两种操作。

给你两个字符串，word1 和 word2 。如果 word1 和 word2 接近 ，就返回 true ；否则，返回 false 。

```
示例 1：

输入：word1 = "abc", word2 = "bca"
输出：true
解释：2 次操作从 word1 获得 word2 。
执行操作 1："abc" -> "acb"
执行操作 1："acb" -> "bca"
示例 2：

输入：word1 = "a", word2 = "aa"
输出：false
解释：不管执行多少次操作，都无法从 word1 得到 word2 ，反之亦然。
示例 3：

输入：word1 = "cabbba", word2 = "abbccc"
输出：true
解释：3 次操作从 word1 获得 word2 。
执行操作 1："cabbba" -> "caabbb"
执行操作 2："caabbb" -> "baaccc"
执行操作 2："baaccc" -> "abbccc"
提示：

1 <= word1.length, word2.length <= 105
word1 和 word2 仅包含小写英文字母
```

刷hot75时刷到，第一次尝试使用多个哈希表，略挫，但能ac

```c++
class Solution {
public:
    bool closeStrings(string word1, string word2) {
        int n = word1.length(), m = word2.length();
        if (n != m) return false;
        map<int, int> table1, table2; // ordered
        for (char &ch : word1) {
            ++table1[ch];
        }
        for (char & ch: word2) {
            ++table2[ch];
        }
        auto iter1 = table1.begin();
        auto iter2 = table2.begin();
        while (iter1 != table1.end() && iter2 != table2.end()) {
            if (iter1->first != iter2->first) return false; // 必须对现有字符转换，所以如果出现了另一个字符串中不存在的字符，则不合法
            if (iter1->second == iter2->second) {
                iter1 = table1.erase(iter1);
                iter2 = table2.erase(iter2);
            } else {
                ++iter1;;
                ++iter2;
            }
        }
        if (table1.empty() && table2.empty()) return true;
        unordered_map<int, int> cnt; // key: 某个字符的出现次数，value：这个出现次数的出现次数
        for (auto p : table1) {
            ++cnt[p.second];
        }
        for (auto p : table2) {
            if (cnt.count(p.second)) {
                --cnt[p.second];
                if (cnt[p.second] == 0) {
                    cnt.erase(p.second);
                }
            } else {
                return false;
            }
        }
        if (cnt.empty()) return true;
        return false;
    }
};
```

因为题目规定了是小写英文字母，所以可以使用长度为26的数组来代替哈希表，因为操作1可以忽略位置，所以用哈希表记录次数是可行的，而且对每个字母的出现次数可以先排序，当两个排序的出现次数数组相等，则说明合法，注意操作2必须对现有字符操作，所以还得特殊判断字符出现次数为0的case

```c++
class Solution {
public:
    bool closeStrings(string word1, string word2) {
        int n = word1.length(), m = word2.length();
        if (n != m) return false;
        vector<int> cnt1(26, 0), cnt2(26, 0); // 每个字符的出现次数
        for (char &ch : word1) ++cnt1[ch - 'a'];
        for (char &ch : word2) ++cnt2[ch - 'a'];
        for (int i = 0; i < 26; ++i) {
            if (cnt1[i] > 0 && cnt2[i] == 0 || cnt1[i] == 0 && cnt2[i] > 0) {
                return false; // 因为必须是现有字符对调，所以出现次数0的字符不可能匹配
            }
        }
        sort(cnt1.begin(), cnt1.end());
        sort(cnt2.begin(), cnt2.end());
        return cnt1 == cnt2;
    }
};
```

### 1679. K 和数对的最大数目

给你一个整数数组 nums 和一个整数 k 。

每一步操作中，你需要从数组中选出和为 k 的两个整数，并将它们移出数组。

返回你可以对数组执行的最大操作数。

```
示例 1：

输入：nums = [1,2,3,4], k = 5
输出：2
解释：开始时 nums = [1,2,3,4]：
- 移出 1 和 4 ，之后 nums = [2,3]
- 移出 2 和 3 ，之后 nums = []
不再有和为 5 的数对，因此最多执行 2 次操作。
示例 2：

输入：nums = [3,1,3,4,3], k = 6
输出：1
解释：开始时 nums = [3,1,3,4,3]：
- 移出前两个 3 ，之后nums = [1,4,3]
不再有和为 6 的数对，因此最多执行 1 次操作。
 

提示：

1 <= nums.length <= 105
1 <= nums[i] <= 109
1 <= k <= 109
```

两数之和进阶版

排序+双指针，时间复杂度Onlogn，空间复杂度Ologn

```c++
class Solution {
public:
    int maxOperations(vector<int>& nums, int k) {
        if (nums.empty() || nums.size() == 1) return 0;
        sort(nums.begin(), nums.end());
        int n = nums.size();
        if (nums[0] + nums[1] > k) return 0;
        if (nums[n-1] + nums[n-2] < k) return 0;
        int i = 0, j = n - 1;
        int op = 0;
        while (i < j) {
            if (nums[i] + nums[j] == k) {
                ++i;
                --j;
                ++op;
            } else if (nums[i] + nums[j] < k) {
                ++i;
            } else {
                --j;
            }
        }
        return op;
    }
};
```

哈希表，时间复杂度On，空间复杂度On

```c++
class Solution {
public:
    int maxOperations(vector<int>& nums, int k) {
        if (nums.empty() || nums.size() == 1) return 0;
        std::map<int, int> table; // key: k minus cur val, value:count
        int op = 0;
        for (int i = 0; i < nums.size(); ++i) {
            if (table.find(nums[i]) != table.end() && table[nums[i]] > 0) {
                --table[nums[i]];
                ++op;
            } else {
                ++table[k-nums[i]];
            }
        }
        return op;
    }
};
```

### 1732. 找到最高海拔

easy

有一个自行车手打算进行一场公路骑行，这条路线总共由 n + 1 个不同海拔的点组成。自行车手从海拔为 0 的点 0 开始骑行。

给你一个长度为 n 的整数数组 gain ，其中 gain[i] 是点 i 和点 i + 1 的 净海拔高度差（0 <= i < n）。请你返回 最高点的海拔 。

```
示例 1：

输入：gain = [-5,1,5,0,-7]
输出：1
解释：海拔高度依次为 [0,-5,-4,1,1,-6] 。最高海拔为 1 。
示例 2：

输入：gain = [-4,-3,-2,-1,4,3,2]
输出：0
解释：海拔高度依次为 [0,-4,-7,-9,-10,-6,-3,-1] 。最高海拔为 0 。
 

提示：

n == gain.length
1 <= n <= 100
-100 <= gain[i] <= 100
```

前缀和秒了，注意骑手从海拔0开始

```c++
class Solution {
public:
    int largestAltitude(vector<int>& gain) {
        int alt = 0;
        int ans = 0;
        for (int g : gain) {
            alt += g;
            ans = max(ans, alt);
        }
        return ans;
    }
};
```

### 2215. 找出两数组的不同

给你两个下标从 0 开始的整数数组 nums1 和 nums2 ，请你返回一个长度为 2 的列表 answer ，其中：

answer[0] 是 nums1 中所有 不 存在于 nums2 中的 不同 整数组成的列表。
answer[1] 是 nums2 中所有 不 存在于 nums1 中的 不同 整数组成的列表。
注意：列表中的整数可以按 任意 顺序返回。

```
示例 1：

输入：nums1 = [1,2,3], nums2 = [2,4,6]
输出：[[1,3],[4,6]]
解释：
对于 nums1 ，nums1[1] = 2 出现在 nums2 中下标 0 处，然而 nums1[0] = 1 和 nums1[2] = 3 没有出现在 nums2 中。因此，answer[0] = [1,3]。
对于 nums2 ，nums2[0] = 2 出现在 nums1 中下标 1 处，然而 nums2[1] = 4 和 nums2[2] = 6 没有出现在 nums2 中。因此，answer[1] = [4,6]。
示例 2：

输入：nums1 = [1,2,3,3], nums2 = [1,1,2,2]
输出：[[3],[]]
解释：
对于 nums1 ，nums1[2] 和 nums1[3] 没有出现在 nums2 中。由于 nums1[2] == nums1[3] ，二者的值只需要在 answer[0] 中出现一次，故 answer[0] = [3]。
nums2 中的每个整数都在 nums1 中出现，因此，answer[1] = [] 。 
 

提示：

1 <= nums1.length, nums2.length <= 1000
-1000 <= nums1[i], nums2[i] <= 1000
```

用哈希表可以直接秒

```c++
class Solution {
public:
    vector<vector<int>> findDifference(vector<int>& nums1, vector<int>& nums2) {
        vector<vector<int>> ans(2, vector<int>());
        unordered_set<int> s1, s2;
        for (int num : nums1) s1.insert(num);
        for (int num : nums2) s2.insert(num);
        for (int num : nums1) {
            if (!s2.count(num)) {
                ans[0].push_back(num);
                s2.insert(num);
            }
        }
        for (int num : nums2) {
            if (!s1.count(num)) {
                ans[1].push_back(num);
                s1.insert(num);
            }
        }
        return ans;
    }
};
```

思考了一下，可以先排序，然后双指针，注意要去重

```c++
class Solution {
public:
    vector<vector<int>> findDifference(vector<int>& nums1, vector<int>& nums2) {
        sort(nums1.begin(), nums1.end());
        sort(nums2.begin(), nums2.end());
        vector<vector<int>> ans(2, vector<int>());
        int i = 0, j = 0, n = nums1.size(), m = nums2.size();
        while (i < n && j < m) {
            while (i < n-1 && nums1[i] == nums1[i+1]) ++i;
            while (j < m-1 && nums2[j] == nums2[j+1]) ++j;
            if (nums1[i] == nums2[j]) {
                ++i;
                ++j;
            } else if (nums1[i] < nums2[j]) {
                ans[0].push_back(nums1[i]);
                ++i;
            } else {
                ans[1].push_back(nums2[j]);
                ++j;
            }
        }
        while (i < n) {
            if (ans[0].empty() || ans[0].back() != nums1[i]) ans[0].push_back(nums1[i]);
            ++i;
        }
        while (j < m) {
            if (ans[1].empty() || ans[1].back() != nums2[j]) ans[1].push_back(nums2[j]);
            ++j;
        }
        return ans;
    }
};
```

也可以调用std::unique算法把连续的同一元素只保留一个，但是要注意容器末尾的若干空穴是undefined的，需要手动erase

```c++
class Solution {
public:
    vector<vector<int>> findDifference(vector<int>& nums1, vector<int>& nums2) {
        sort(nums1.begin(), nums1.end());
        auto last = unique(nums1.begin(), nums1.end());
        nums1.erase(last, nums1.end()); // 删除末尾undefined的元素
        sort(nums2.begin(), nums2.end());
        auto last2 = unique(nums2.begin(), nums2.end());
        nums2.erase(last2, nums2.end()); // 删除末尾undefined的元素
        vector<vector<int>> ans(2, vector<int>());
        int i = 0, j = 0, n = nums1.size(), m = nums2.size();
        while (i < n && j < m) {
            if (nums1[i] == nums2[j]) {
                ++i;
                ++j;
            } else if (nums1[i] < nums2[j]) {
                ans[0].push_back(nums1[i]);
                ++i;
            } else {
                ans[1].push_back(nums2[j]);
                ++j;
            }
        }
        if (i < n) ans[0].insert(ans[0].end(), nums1.begin()+i, nums1.end());
        if (j < m) ans[1].insert(ans[1].end(), nums2.begin()+j, nums2.end());
        return ans;
    }
};
```

### 2352. 相等行列对 

medium

给你一个下标从 0 开始、大小为 n x n 的整数矩阵 grid ，返回满足 Ri 行和 Cj 列相等的行列对 (Ri, Cj) 的数目。

如果行和列以相同的顺序包含相同的元素（即相等的数组），则认为二者是相等的。

```
示例 1：

输入：grid = [[3,2,1],[1,7,6],[2,7,7]]
输出：1
解释：存在一对相等行列对：
- (第 2 行，第 1 列)：[2,7,7]
示例 2：

输入：grid = [[3,1,2,2],[1,4,4,5],[2,4,2,2],[2,4,2,2]]
输出：3
解释：存在三对相等行列对：
- (第 0 行，第 0 列)：[3,1,2,2]
- (第 2 行, 第 2 列)：[2,4,2,2]
- (第 3 行, 第 2 列)：[2,4,2,2]
 

提示：

n == grid.length == grid[i].length
1 <= n <= 200
1 <= grid[i][j] <= 105
```

想的是先用哈希表存每行的和，value是同一个和的行序号，然后再遍历每列，若之前存过该和，则依次和map.value里的行序号进行比较，虽然能过，但还是有点慢

```c++
class Solution {
    bool isRowEqualCol(vector<vector<int>>& grid, int n, int x, int y) {
        for (int i = 0; i < n; ++i) {
            if (grid[x][i] != grid[i][y]) return false;
        }
        return true;
    }
public:
    int equalPairs(vector<vector<int>>& grid) {
        if (grid.empty()) return 0;
        int n = grid.size();
        if (n == 1) return 1;
        unordered_map<int, vector<int>> sum_index; // key:某行的sum，value：行sum=key的行序号
        int sum = 0;
        for (int i = 0; i < n; ++i) {
            sum = 0;
            for (int j = 0; j < n; ++j) {
                sum += grid[i][j];
            }
            sum_index[sum].push_back(i);
        }
        int ans = 0;
        for (int j = 0; j < n; ++j) {
            sum = 0;
            for (int i = 0; i < n; ++i) {
                sum += grid[i][j];
            }
            if (sum_index.count(sum)) {
                for (int i = 0; i < sum_index[sum].size(); ++i) {
                    if (isRowEqualCol(grid, n, sum_index[sum][i], j)) ++ans;
                }
            }
        }
        return ans;
    }
};
```

其实这里可以取巧，每行可以拼接成字符串（严谨考虑，每个元素之间用逗号分割），这样就成了唯一key，后面遍历每列时可以很快找到，这样能下降一个数量级的时间复杂度

```c++
class Solution {
public:
    int equalPairs(vector<vector<int>>& grid) {
        if (grid.empty()) return 0;
        int n = grid.size();
        if (n == 1) return 1;
        unordered_map<string, int> str_cnt; // key:某行拼接成字符串，value：相同字符串出现次数
        string str;
        for (int i = 0; i < n; ++i) {
            str = "";
            for (int j = 0; j < n; ++j) {
                str += to_string(grid[i][j]) + ",";
            }
            ++str_cnt[str];
        }
        int ans = 0;
        for (int j = 0; j < n; ++j) {
            str = "";
            for (int i = 0; i < n; ++i) {
                str += to_string(grid[i][j]) + ",";
            }
            if (str_cnt.count(str)) {
                ans += str_cnt[str];
            }
        }
        return ans;
    }
};
```

这题还可以用前缀树来做，最开始想到了，但是看到100000有点犯怵，其实next指针不用开数组，开哈希表就行了，注意构建时需要在节点处记录次数

```c++
class Solution {
    struct Tree {
        unordered_map<int, Tree*> next;
        int visit; // 访问次数
        Tree() : visit(1) {}
    };
public:
    int equalPairs(vector<vector<int>>& grid) {
        if (grid.empty()) return 0;
        int n = grid.size();
        if (n == 1) return 1;
        Tree *root = new Tree();
        Tree *cur = root;
        for (int i = 0; i < n; ++i) { // 先遍历每行
            cur = root;
            for (int j = 0; j < n; ++j) {
                int num = grid[i][j];
                if (!cur->next.count(num)) {
                    cur->next.insert({num, new Tree()});
                } else {
                    ++(cur->next[num]->visit); // 注意有可能有相同的前缀，需要记录次数
                }
                cur = cur->next[num];
            }
        }
        int ans = 0;
        for (int j = 0; j < n; ++j) { // 再遍历每列
            cur = root;
            for (int i = 0; i < n; ++i) {
                int num = grid[i][j];
                if (!cur->next.count(num)) break; // 前缀不匹配，该列不合法
                if (i == n - 1) ans += cur->next[num]->visit;
                cur = cur->next[num];
            }
        }
        return ans;
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

```c++
class Solution {
public:
    // 构建next数组：时间复杂度O(m)，next[i] 表示 P[0] ~ P[i] 这一个子串，使得 前k个字符恰等于后k个字符 的最大的k
    vector<int> buildNext(string haystack, string needle) {
        vector<int> next(needle.size()+1); // 因为最后会超出范围，多加一个长度，反正最后的元素不会用到
        int i = 1; // next[0]必然是0，所以从1开始求
        int now = 0;
        while (i < needle.size()) {
            if (needle[i] == needle[now]) { // 匹配，向右扩展一位
                now++;
                next[i] = now;
                i++;
            } else if (now != 0) {
                now = next[now-1]; // 不匹配，缩小now
            } else {
                i++;
                next[i] = now; // now已经为0，无法再缩小，所以next[i] = 0
            }
        }
        return next;
    }
    int strStr(string haystack, string needle) {
        vector<int> next = buildNext(haystack, needle);
        int tar = 0; // 主串匹配位置
        int pos = 0; // 模式串匹配位置
        while (tar < haystack.size()) {
            if (haystack[tar] == needle[pos]) {
                tar++;
                pos++;
            } else if (pos != 0) { // 根据前缀数组移动标尺
                pos = next[pos - 1];
            } else { // 不匹配且pos=0，则直接移动标尺
                tar++;
            }
            if (pos == needle.size()) {
                return tar - pos; // 匹配成功，输出主串上匹配的起点
            }
        }
        return -1;
    }
};
```

缺陷：现实中，中间内容与前缀相同的单词、词汇并不多见，而长句更是除了排比句之外就很少见了，因此，在花费时间空间生成了有限状态机之后，很有可能会出现一直都是重置状态而很少降价状态的情况出现。对于长句而言，状态机所占用的空间是巨大的，而并不高效，相反纯暴力解法对于短 pattern 串。而言，总体运行时间却并不比它慢

参考连接： [http://www.ruanyifeng.com/blog/2013/05/Knuth%E2%80%93Morris%E2%80%93Pratt_algorithm.html](http://www.ruanyifeng.com/blog/2013/05/Knuth–Morris–Pratt_algorithm.html)

 字符串匹配算法——BM算法

时间复杂度：最差与KMP算法一样O(M+N)，最好是O(N)

参考链接：[阮一峰的一篇博客](http://www.ruanyifeng.com/blog/2013/05/boyer-moore_string_search_algorithm.html)

 字符串匹配算法——Sunday算法

最坏情况：O(nm)
平均情况：O(n)

### 32.最长有效括号(Hard) @hot100

给定一个只包含 '(' 和 ')' 的字符串，找出最长的包含有效括号的子串的长度。

示例 1:

输入: "(()"
输出: 2
解释: 最长有效括号子串为 "()"
示例 2:

输入: ")()())"
输出: 4
解释: 最长有效括号子串为 "()()"

暴力法一次AC了，O(n^2)事件，O(n)空间，枚举每个`(`，计算最大长度，right>left时不满足，直接break

```c++
class Solution {
public:
    int longestValidParentheses(string s) {
        int n = s.size();
        int ans = 0;
        for (int i = 0; i < n; ++i) {
            if (s[i] == ')') {
                continue;
            }
            int left = 1;
            int right = 0;
            for (int j = i + 1; j < n; ++j) {
                if (s[j] == '(') left++;
                else right++;
                if (right > left) break;
                if (left == right) ans = max(ans, j - i + 1);
            }
        }
        return ans;
    }
};
```

贪心法：仔细观察暴力法，当right>left时即可放弃之前的答案，重新寻找新的最长

在此方法中，我们利用两个计数器 left 和 right 。首先，我们从左到右遍历字符串，对于遇到的每个 ‘(’，我们增加 left 计数器，对于遇到的每个 ‘)’ ，我们增加 right 计数器。每当 left 计数器与 right 计数器相等时，我们计算当前有效字符串的长度，并且记录目前为止找到的最长子字符串。当 right 计数器比 left 计数器大时，我们将 left 和 right 计数器同时变回 0。

这样的做法贪心地考虑了以当前字符下标结尾的有效括号长度，每次当右括号数量多于左括号数量的时候之前的字符我们都扔掉不再考虑，重新从下一个字符开始计算，但这样会漏掉一种情况，就是遍历的时候左括号的数量始终大于右括号的数量，即 (() ，这种时候最长有效括号是求不出来的。

解决的方法也很简单，我们只需要从右往左遍历用类似的方法计算即可，只是这个时候判断条件反了过来：

当 left 计数器比 right 计数器大时，我们将 left 和 right 计数器同时变回 0
当 left 计数器与 right 计数器相等时，我们计算当前有效字符串的长度，并且记录目前为止找到的最长子字符串
这样我们就能涵盖所有情况从而求解出答案。

```c++
class Solution {
public:
    int longestValidParentheses(string s) {
        int n = s.size();
        int ans = 0;
        int left = 0;
        int right = 0;
        for (int i = 0; i < n; ++i) {
            if (s[i] == '(') left++;
            else right++;
            if (right > left) left = 0, right = 0;
            else if (left == right) ans = max(ans, 2 * right);
        }
        left = right = 0;
        for (int i = n - 1; i >=0; --i) {
            if (s[i] == ')') right++;
            else left++;
            if (right < left) left = 0, right = 0;
            else if (left == right) ans = max(ans, 2 * right);
        }
        return ans;
    }
};
```

利用栈，O(n)时间，O(n)空间

具体做法是我们始终保持栈底元素为当前已经遍历过的元素中「最后一个没有被匹配的右括号的下标」，这样的做法主要是考虑了边界条件的处理，栈里其他元素维护左括号的下标：

- 对于遇到的每个 ‘(’ ，我们将它的下标放入栈中
- 对于遇到的每个 ‘)’ ，我们先弹出栈顶元素表示匹配了当前右括号：
  - 如果栈为空，说明当前的右括号是一个没有被匹配的右括号，我们将其下标放入栈中来更新我们之前提到的「最后一个没有被匹配的右括号的下标」
  - 如果栈不为空，当前右括号的下标减去栈顶元素即为「以该右括号为结尾的最长有效括号的长度」

我们从前往后遍历字符串并更新答案即可。

需要注意的是，如果一开始栈为空，第一个字符为左括号的时候我们会将其放入栈中，这样就不满足提及的「最后一个没有被匹配的右括号的下标」，为了保持统一，我们在一开始的时候往栈中放入一个值为 -1 的元素。

```c++
class Solution {
public:
    int longestValidParentheses(string s) {
        int ans = 0;
        stack<int> st; // 保持栈底元素为最后一个没有被匹配的右括号的下标
        st.push(-1);
        for (int i = 0; i < s.length(); i++) {
            if (s[i] == '(') {
                st.push(i);
            } else {
                st.pop();
                if (st.empty()) {
                    st.push(i);
                } else {
                    ans = max(ans, i - st.top());
                }
            }
        }
        return ans;
    }
};
```

动态规划

```c++
class Solution {
public:
    int longestValidParentheses(string s) {
        int n = s.size();
        vector<int> dp(n, 0);
        // dp[i]表示是以i结尾的合法子串的长度，若s[i]='('，则dp[i]=0
        // 当s[i] = ')'时:
        // dp[i] = dp[i-2] + 2, if s[i-1] = '('
        // dp[i] = dp[i-1] + dp[i-dp[i-1]-2] + 2  , if s[i-1] = ')' and s[i-dp[i-1]-1] = '('
        int maxVal = 0;
        for(int i = 1; i < n; i++) {
            if (s[i] == '(') {
                continue;
            }
            if (s[i - 1] == '(') {
                dp[i] = 2;
                if (i - 2 >= 0) {
                    dp[i] = dp[i] + dp[i - 2];
                }
            } else if (dp[i - 1] > 0) { // s[i - 1] == ')'
                if ((i - dp[i - 1] - 1) >= 0 && s[i - dp[i - 1] - 1] == '(') {
                    dp[i] = dp[i - 1] + 2; // 前一个`)`形成的最长合法序列长度
                    if ((i - dp[i - 1] - 2) >= 0) { // 可能与之前的合法子序列连起来！
                        dp[i] = dp[i] + dp[i - dp[i - 1] - 2];
                    }
                }
            }
            maxVal = max(maxVal, dp[i]);
        }
        return maxVal;
    }
};

```

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

### 43. 字符串相乘(Medium)

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

第一次尝试，基于字符串各位相乘再想加，写了个又臭又长的代码，有很多次string的拷贝，速度和内存都很差

```c++
class Solution {
public:
    string multiply(string num1, string num2) {
        if (num1.size() == 1 && num1[0] == '0' || num2.size() == 1 && num2[0] == '0') return "0";
        string ans = "0";
        string surfix = "";
        for (int i = num1.size()-1; i >= 0; --i) {
            if (num1[i] == 0) continue;
            ans = add(ans, singleMultiply(num1[i], num2) + surfix);
            surfix += "0";
        }
        return ans;
    }
    string singleMultiply(char ch, string num) {
        int single = ch - '0';
        int carry = 0;
        int product = 0;
        string ans = "";
        for (int i = num.size()-1; i >= 0; --i) {
            product = (num[i] - '0') * single + carry;
            ans = string(1, (product % 10) + '0') + ans;
            carry = product / 10;
        }
        if (carry) ans = string(1, carry + '0') + ans;
        return ans;
    }
    string add(string num1, string num2) {
        int len1 = num1.size();
        int len2 = num2.size();
        int len = max(len1, len2);
        if (len1 > len2) {
            int diff = len1 - len2;
            while (diff--) {
                num2 = "0" + num2;
            }
        } else {
            int diff = len2 - len1;
            while (diff--) {
                num1 = "0" + num1;
            }
        }
        string ans = "";
        int carry = 0;
        int sum = 0;
        for (int i = len-1; i >= 0; --i) {
            sum = num1[i] - '0' + num2[i] - '0' + carry;
            ans = string(1, (sum % 10) + '0') + ans;
            carry = sum / 10;
        }
        if (carry) ans = string(1, '1') + ans;
        return ans;
    }
};
```

优化：竖式运算，对于 a 的第 i 位 和 b 的第 j 位相乘的结果存储在 c[i + j] 上，即 c[i + j] += a[i] * b[j]，注意有可能进位，进位不需要一直往下走，可以暂存超过10的数，因为后面还是会计算到那的

```c++
class Solution {
public:
    string multiply(string num1, string num2) {
        int n1 = num1.size();
        int n2 = num2.size();
        string res(n1+n2,'0');
        for(int i = n2-1; i >= 0; i--){
            for(int j = n1-1; j>=0; j--){
                int temp= (res[i+j+1]-'0') + (num1[j]-'0') * (num2[i]-'0');
                res[i+j+1] = temp%10+'0';//当前位
                res[i+j] += temp/10; //前一位加上进位，res[i+j]已经初始化为'0'，加上int类型自动转化为char，所以此处不加'0'
            }
        }
        for (int i = 0; i < n1+n2; i++){
            if(res[i] != '0') return res.substr(i);
        }
        return "0";
    }
};
```

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

### 151. 翻转字符串里的单词

给定一个字符串，逐个翻转字符串中的每个单词。

示例 1：

输入: "the sky is blue"
输出: "blue is sky the"
示例 2：

输入: "  hello world!  "
输出: "world! hello"
解释: 输入字符串可以在前面或者后面包含多余的空格，但是反转后的字符不能包括。
示例 3：

输入: "a good   example"
输出: "example good a"
解释: 如果两个单词间有多余的空格，将反转后单词间的空格减少到只含一个。

说明：

无空格字符构成一个单词。
输入字符串可以在前面或者后面包含多余的空格，但是反转后的字符不能包括。
如果两个单词间有多余的空格，将反转后单词间的空格减少到只含一个。

进阶：

请选用 C 语言的用户尝试使用 O(1) 额外空间复杂度的原地解法。

```c++
class Solution {
public:
    string reverseWords(string s) {
        // 反转整个字符串
        reverse(s.begin(), s.end());

        int n = s.size();
        int idx = 0;
        for (int start = 0; start < n; ++start) {
            if (s[start] != ' ') {
                // 填一个空白字符然后将idx移动到下一个单词的开头位置
                if (idx != 0) s[idx++] = ' ';

                // 循环遍历至单词的末尾
                int end = start;
                while (end < n && s[end] != ' ') s[idx++] = s[end++];

                // 反转整个单词
                reverse(s.begin() + idx - (end - start), s.begin() + idx);

                // 更新start，去找下一个单词
                start = end;
            }
        }
        s.erase(s.begin() + idx, s.end());
        return s;
    }
};
```

由于双端队列支持从队列头部插入的方法，因此我们可以沿着字符串一个一个单词处理，然后将单词压入队列的头部，再将队列转成字符串即可。

```c++
class Solution {
public:
    string reverseWords(string s) {
        int left = 0, right = s.size() - 1;
        // 去掉字符串开头的空白字符
        while (left <= right && s[left] == ' ') ++left;
        // 去掉字符串末尾的空白字符
        while (left <= right && s[right] == ' ') --right;
        deque<string> d;
        string word;
        while (left <= right) {
            char c = s[left];
            if (word.size() && c == ' ') {
                d.push_front(move(word)); // 单词结束，push到队列的头部
                word = "";
            }
            else if (c != ' ') { // 构造单词
                word += c;
            }
            ++left;
        }
        d.push_front(move(word)); // move 更快，也不用手动再置空word
        string ans;
        while (!d.empty()) {
            ans += d.front();
            d.pop_front();
            if (!d.empty()) ans += ' ';
        }
        return ans;
    }
};
```

不用额外空间的

```c++
class Solution {
public:
    string reverseWords(string s) {
        if (s.empty() || s.length() == 1) return s;
        // remove prefix '0'
        int i = 0;
        while (i < s.length() && s[i] == ' ') ++i;
        s.erase(s.begin(), s.begin() + i);
        // remove suffix '0'
        int j = s.length() - 1;
        while (j > 0 && s[j] == ' ') --j;
        s.erase(s.begin() + j + 1, s.end());

        i = 0;
        while (i < s.length()) {
            // now i points to first char of the word
            int word_begin = i;
            while (i < s.length() && s[i] != ' ') ++i;
            std::reverse(s.begin() + word_begin, s.begin() + i); // reverse the word
            if (i < s.length()) {
                // found '0', because already removed suffix '0', now just need to delete duplicate '0'
                ++i;
                int delete_begin = i;
                while (i < s.length() && s[i] == ' ') ++i;
                s.erase(s.begin() + delete_begin, s.begin() + i);
                i = delete_begin;
            }
        }
        std::reverse(s.begin(), s.end()); 
        return s;
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

### 316. 去除重复字母(Hard)

同力扣1081题

给你一个仅包含小写字母的字符串，请你去除字符串中重复的字母，使得每个字母只出现一次。需保证返回结果的字典序最小（要求不能打乱其他字符的相对位置）。

示例 1:

输入: "bcabc"
输出: "abc"
示例 2:

输入: "cbacdcbc"
输出: "acdb"

观察示例 1：bcabc。

单调栈

1、遍历字符串里的字符，如果读到的字符的 ASCII 值是升序，依次存到一个栈中；
2、如果读到的字符在栈中已经存在，这个字符我们不需要；
3、如果读到的 ASCII 值比栈顶元素严格小，看看栈顶元素在后面是否还会出现，如果还会出现，则舍弃栈顶元素，而选择后出现的那个字符，这样得到的字典序更小。

因为需要判断读到的字符在栈中是否已经存在，因此可以使用哈希表，又因为题目中说，字符只会出现小写字母，用一个布尔数组也是可以的，注意在出栈入栈的时候，需要同步更新一下这个布尔数组。

又因为要判断栈顶元素在后面是否会被遍历到，因此我们需要先遍历一次字符，存一下这个字符最后出现的位置，就能判断栈顶元素在后面是否会被遍历到。

```c++
class Solution {
public:
    string removeDuplicateLetters(string s) {
        size_t size = s.size();
        if (size < 2) return s;
        bool used[26]; // 在栈中这个字母是否存在
        for (bool &i : used) {
            i = false;
        }
        int lastAppearIndex[26]; // 每个字母在字符串中最后出现的位置
        for (int i = 0; i < size; i++) {
            lastAppearIndex[s[i] - 'a'] = i;
        }
        stack<char> st; // mono increasing stack
        for (int i = 0; i < size; i++) {
            if (used[s[i] - 'a']) continue;
            while (!st.empty() && st.top() > s[i] && lastAppearIndex[st.top() - 'a'] >= i) {
                char top = st.top();
                st.pop();
                used[top - 'a'] = false;
            }
            st.push(s[i]);
            used[s[i] - 'a'] = true;
        }
        string ans;
        while (!st.empty()) {
            ans += st.top();
            st.pop();
        }
        reverse(ans.begin(), ans.end());
        return ans;
    }
};
```

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

### 345. 反转字符串中的元音字母

给你一个字符串 s ，仅反转字符串中的所有元音字母，并返回结果字符串。

元音字母包括 'a'、'e'、'i'、'o'、'u'，且可能以大小写两种形式出现不止一次。

```
示例 1：

输入：s = "hello"
输出："holle"
示例 2：

输入：s = "leetcode"
输出："leotcede"
 

提示：

1 <= s.length <= 3 * 105
s 由 可打印的 ASCII 字符组成
```

双指针秒了

```c++
class Solution {
    bool isVowel(char c) {
        return c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u'
                || c == 'A' || c == 'E' || c == 'I' || c == 'O' || c == 'U';
    }
public:
    string reverseVowels(string s) {
        int i = 0, j = s.length() - 1;
        if (s.empty() || s.length() == 1) return s;
        while (i < j) {
            while (!isVowel(s[i]) && i < j) ++i;
            while (!isVowel(s[j]) && i < j) --j;
            if (i < j) swap(s[i++], s[j--]);
        }
        return s;
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

### 443. 压缩字符串

给你一个字符数组 chars ，请使用下述算法压缩：

从一个空字符串 s 开始。对于 chars 中的每组 连续重复字符 ：

如果这一组长度为 1 ，则将字符追加到 s 中。
否则，需要向 s 追加字符，后跟这一组的长度。
压缩后得到的字符串 s 不应该直接返回 ，需要转储到字符数组 chars 中。需要注意的是，如果组长度为 10 或 10 以上，则在 chars 数组中会被拆分为多个字符。

请在 修改完输入数组后 ，返回该数组的新长度。

你必须设计并实现一个只使用常量额外空间的算法来解决此问题。

```
示例 1：

输入：chars = ["a","a","b","b","c","c","c"]
输出：返回 6 ，输入数组的前 6 个字符应该是：["a","2","b","2","c","3"]
解释："aa" 被 "a2" 替代。"bb" 被 "b2" 替代。"ccc" 被 "c3" 替代。
示例 2：

输入：chars = ["a"]
输出：返回 1 ，输入数组的前 1 个字符应该是：["a"]
解释：唯一的组是“a”，它保持未压缩，因为它是一个字符。
示例 3：

输入：chars = ["a","b","b","b","b","b","b","b","b","b","b","b","b"]
输出：返回 4 ，输入数组的前 4 个字符应该是：["a","b","1","2"]。
解释：由于字符 "a" 不重复，所以不会被压缩。"bbbbbbbbbbbb" 被 “b12” 替代。
 

提示：

1 <= chars.length <= 2000
chars[i] 可以是小写英文字母、大写英文字母、数字或符号
```

一看就是双指针，刷hot75的时候刷到了，是正确做法，但是调试了一会，rep可以用右边界-左边界来代替，没必要维护rep的更新

```c++
class Solution {
public:

    int compress(vector<char>& chars) {
        int n = chars.size();
        if (n == 0 || n == 1) return n;
        int i = 0; // 表示当前就地修改的数组序号
        int j = 0; // 表示当前遍历序号
        int rep = 1; // 表示当前字符的出现次数
        int rep_l = 0; // 表示rep在数组中存放的首位
        while (j < n) {
            while (j < n - 1 && chars[j] == chars[j+1]) {
                ++rep;
                ++j;
            }
            chars[i] = chars[j];
            ++i;
            if (rep > 1) {
                rep_l = i;
                while (rep > 0) {
                    chars[i] = '0' + rep % 10;
                    ++i;
                    rep /= 10;
                }
                if (i - rep_l > 1) std::reverse(chars.begin() + rep_l, chars.begin() + i);
            }
            rep = 1; 
            ++j;
        }
        return i;
    }
};
```

### 557. 反转字符串中的单词 III(Easy)

给定一个字符串，你需要反转字符串中每个单词的字符顺序，同时仍保留空格和单词的初始顺序。

示例 1:

输入: "Let's take LeetCode contest"
输出: "s'teL ekat edoCteeL tsetnoc"
注意：在字符串中，每个单词由单个空格分隔，并且字符串中不会有任何额外的空格。

很简单，一次AC了

```c++
class Solution {
public:
    string reverseWords(string s) {
        if (s.empty()) return s;
        int n = s.size();
        int idx = 0;
        int start = 0;
        for (; idx < n; ++idx) {
            if (s[idx] == ' ') {
                reverse(s.begin() + start, s.begin() + idx);
                start = idx + 1; // 下个单词的起点
            }
        }
        reverse(s.begin() + start, s.begin() + idx);
        return s;
    }
};
```

### 1071. 字符串的最大公因子

对于字符串 s 和 t，只有在 s = t + t + t + ... + t + t（t 自身连接 1 次或多次）时，我们才认定 “t 能除尽 s”。

给定两个字符串 str1 和 str2 。返回 最长字符串 x，要求满足 x 能除尽 str1 且 x 能除尽 str2 。

```
示例 1：

输入：str1 = "ABCABC", str2 = "ABC"
输出："ABC"
示例 2：

输入：str1 = "ABABAB", str2 = "ABAB"
输出："AB"
示例 3：

输入：str1 = "LEET", str2 = "CODE"
输出：""
 

提示：

1 <= str1.length, str2.length <= 1000
str1 和 str2 由大写英文字母组成
```

最大公约数，联想到辗转相除法，和普通数字不同，这里的字符串必须保证子串相同，比如

```
str1 = t+t+t+... +t
str2 = t+t+...+t
```

可以找出规律，两个字符串相同长度内必须相同才有可能合法，较长那的字符串的后面那截子串又可以作为下一轮比较的输入，以此类推，取出后面那截子串的操作，就有点像gcd算法取出余数作为下一轮的输入，如果最终str1=str2，则合法，找到的str1则为最大公约数

```c++
class Solution {
public:
    string gcdOfStrings(string str1, string str2) {
        if (str1.empty() || str2.empty()) return "";
        // 模拟gcd算法求最大公约数，辗转相除法
        if (str1.length() < str2.length()) swap(str1, str2); // 保证每次str2都更短
        while (!str2.empty()) {
            int common_len = str2.length();
            if (str1.substr(0, common_len) != str2) return ""; // common_len长度内，两者相等才合法
            str1 = str1.substr(common_len); // 取出长串后面那一截子串，作为下个输入
            if (str1.length() < str2.length()) swap(str1, str2);  // 保证每次str2都更短
        }
        // 如果最终合法，则最后一次循环的str1=str2，后面一截子串为空
        return str1;
    }
};
```

看了题解，可以用数学角度思考一下，

1. 如果str1+str2 != str2+str1，无解
2. 在有解的情况，解的长度就是gcd(str1, str2)，这里证明还是有点复杂的，还是看上面自己想的解法吧  

```c++
class Solution {
public:
    string gcdOfStrings(string str1, string str2) {
        if (str1 + str2 != str2 + str1) return "";
        return str1.substr(0, __gcd((int)str1.length(), (int)str2.length())); // __gcd() 为c++自带的求最大公约数的函数
    }
};

作者：力扣官方题解
链接：https://leetcode.cn/problems/greatest-common-divisor-of-strings/solutions/143956/zi-fu-chuan-de-zui-da-gong-yin-zi-by-leetcode-solu/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```


### 1768. 交替合并字符串

给你两个字符串 word1 和 word2 。请你从 word1 开始，通过交替添加字母来合并字符串。如果一个字符串比另一个字符串长，就将多出来的字母追加到合并后字符串的末尾。

返回 合并后的字符串 。

```
示例 1：

输入：word1 = "abc", word2 = "pqr"
输出："apbqcr"
解释：字符串合并情况如下所示：
word1：  a   b   c
word2：    p   q   r
合并后：  a p b q c r
示例 2：

输入：word1 = "ab", word2 = "pqrs"
输出："apbqrs"
解释：注意，word2 比 word1 长，"rs" 需要追加到合并后字符串的末尾。
word1：  a   b 
word2：    p   q   r   s
合并后：  a p b q   r   s
示例 3：

输入：word1 = "abcd", word2 = "pq"
输出："apbqcd"
解释：注意，word1 比 word2 长，"cd" 需要追加到合并后字符串的末尾。
word1：  a   b   c   d
word2：    p   q 
合并后：  a p b q c   d


提示：

1 <= word1.length, word2.length <= 100
word1 和 word2 由小写英文字母组成
```

简单题，简单做，第一次尝试，先把共同长度构造出来，再添加到末尾

```c++
class Solution {
public:
    string mergeAlternately(string word1, string word2) {
        string ans;
        if (word1.empty()) return word2;
        if (word2.empty()) return word1;
        int len1 = word1.length();
        int len2 = word2.length();
        int min_len = min(len1, len2);
        for (int i = 0; i < min_len; ++i) {
            ans += word1[i];
            ans += word1[i];
        }
        for (int i = 0; i < min_len; ++i) {
            ans[2*i+1] = word2[i];
        }
        if (len1 > min_len) ans += word1.substr(min_len);
        if (len2 > min_len) ans += word2.substr(min_len);
        return ans;
    }
};
```

后面发现双指针更优

```c++
class Solution {
public:
    string mergeAlternately(string word1, string word2) {
        // 双指针，精髓是退出循环
        int i = 0, j = 0;
        int len1 = word1.length();
        int len2 = word2.length();
        string ans;
        while (i < len1 || j < len2) {
            if (i < len1) ans += word1[i++];
            if (j < len2) ans += word2[j++];
        }
        return ans;
    }
};
```





## 前缀树

### 208. 实现 Trie (前缀树)

实现一个 Trie (前缀树)，包含 insert, search, 和 startsWith 这三个操作。

示例:

Trie trie = new Trie();

trie.insert("apple");
trie.search("apple");   // 返回 true
trie.search("app");     // 返回 false
trie.startsWith("app"); // 返回 true
trie.insert("app");
trie.search("app");     // 返回 true
说明:

你可以假设所有的输入都是由小写字母 a-z 构成的。
保证所有输入均为非空字符串。

前缀树模板

```c++
class Trie {
public:
    Trie() {}

    void insert(string word) {
        auto root = this;
        for (const char &w : word) {
            if (!root->next[w-'a']) root->next[w-'a'] = new Trie();
            root = root->next[w-'a'];
        }
        root->is_string = true; // 最后一个节点的标记
    }

    bool search(string word) {
        auto root = this;
        for (const char &w : word) {
            if (!root->next[w-'a']) return false;
            root = root->next[w-'a'];
        }
        return root->is_string;
    }

    bool startsWith(string prefix) {
        auto root = this;
        for (const char &w : prefix) {
            if (!root->next[w-'a']) return false;
            root = root->next[w-'a'];
        }
        return true;
    }
private:
    Trie* next[26] = {nullptr};
    bool is_string = false;
};

/**
 * Your Trie object will be instantiated and called as such:
 * Trie* obj = new Trie();
 * obj->insert(word);
 * bool param_2 = obj->search(word);
 * bool param_3 = obj->startsWith(prefix);
 */
 ```

### 211. 添加与搜索单词 - 数据结构设计(Medium)

设计一个支持以下两种操作的数据结构：

void addWord(word)
bool search(word)
search(word) 可以搜索文字或正则表达式字符串，字符串只包含字母 . 或 a-z 。 . 可以表示任何一个字母。

示例:

addWord("bad")
addWord("dad")
addWord("mad")
search("pad") -> false
search("bad") -> true
search(".ad") -> true
search("b..") -> true
说明:

你可以假设所有单词都是由小写字母 a-z 组成的。

前缀树+回溯

主要难点在于search函数，其中有可能出现"."，这就需要遍历前缀树的next数组，尝试下层的每个可行节点。

下层的每个可行节点，继续调用search函数，但是传入的参数是word的substr。

在search函数开头会判断word的大小，如果为空，则说明到头了，返回当前节点的is_string变量。

```c++
class WordDictionary {
public:
    WordDictionary() {}

    /** Adds a word into the data structure. */
    void addWord(string word) {
        WordDictionary *root = this;
        for (const char &w : word) {
            if (!root->next[w-'a']) root->next[w-'a'] = new WordDictionary;
            root = root->next[w-'a'];
        }
        root->is_string = true;
    }

    /** Returns if the word is in the data structure. A word could contain the dot character '.' to represent any one letter. */
    bool search(string word) {
        WordDictionary *root = this;
        int n = word.size();
        if (n == 0) return root->is_string;
        for (int i = 0; i < n; ++i) {
            if (word[i] == '.') {
                // 尝试下层的每个可行节点
                for (int j = 0; j < 26; ++j) {
                    if (root->next[j] && root->next[j]->search(word.substr(i+1))) {
                        return true;
                    }
                }
                // 走到这一步说明肯定是无效的
                return false;
            } else {
                if (!root->next[word[i]-'a']) return false;
                root = root->next[word[i]-'a'];
            }
        }
        return root->is_string;
    }
private:
    WordDictionary* next[26] = {nullptr};
    bool is_string = false;
};

/**
 * Your WordDictionary object will be instantiated and called as such:
 * WordDictionary* obj = new WordDictionary();
 * obj->addWord(word);
 * bool param_2 = obj->search(word);
 */
 ```

### 212. 单词搜索 II(Hard)

给定一个二维网格 board 和一个字典中的单词列表 words，找出所有同时在二维网格和字典中出现的单词。

单词必须按照字母顺序，通过相邻的单元格内的字母构成，其中“相邻”单元格是那些水平相邻或垂直相邻的单元格。同一个单元格内的字母在一个单词中不允许被重复使用。

示例:

输入:
words = ["oath","pea","eat","rain"] and board =
[
  ['o','a','a','n'],
  ['e','t','a','e'],
  ['i','h','k','r'],
  ['i','f','l','v']
]

输出: ["eat","oath"]
说明:
你可以假设所有输入都由小写字母 a-z 组成。

提示:

你需要优化回溯算法以通过更大数据量的测试。你能否早点停止回溯？
如果当前单词不存在于所有单词的前缀中，则可以立即停止回溯。什么样的数据结构可以有效地执行这样的操作？散列表是否可行？为什么？ 前缀树如何？如果你想学习如何实现一个基本的前缀树，请先查看这个问题： 实现Trie（前缀树）。

前缀树+dfs，一种结合稍微紧密的写法，不需要visited数组，注意一些细节，比如去重，比如一个单词内不允许重复使用同一个单元格

```c++
class Trie {
public:
    void insert(const string &word) {
        Trie* root = this;
        for (const char &w : word) {
            if (!root->next[w-'a']) root->next[w-'a'] = new Trie();
            root = root->next[w-'a'];
        }
        root->is_string = true;
        root->word = word;
    }
public:
    Trie* next[26] = {nullptr};
    string word = "";
    bool is_string;
};
class Solution {
public:
    vector<string> res;
    void dfs(vector<vector<char>>& board, Trie *root, int rows, int cols, int i, int j) {
        if (root->is_string) {
            root->is_string = 0; // 去重
            res.push_back(root->word);
        }
        if (i < 0 || j < 0 || i >= rows || j >= cols) return;
        if (board[i][j] == '#') return;
        if (root->next[board[i][j]-'a'] == nullptr) return; // 判断当前字符串是否是某一单词的前缀
        root = root->next[board[i][j]-'a'];
        char cur = board[i][j];
        board[i][j] = '#'; // 当前节点已访问，下面的dfs不能再访问它，因为同一个单元格在一个单词中不允许被重复使用
        dfs(board, root, rows, cols, i-1, j);
        dfs(board, root, rows, cols, i+1, j);
        dfs(board, root, rows, cols, i, j-1);
        dfs(board, root, rows, cols, i, j+1);
        board[i][j] = cur; // 复原当前节点
    }
    vector<string> findWords(vector<vector<char>>& board, vector<string>& words) {
        if (board.empty() || board[0].empty() || words.empty()) return res;
        int rows = board.size();
        int cols = board[0].size();
        Trie *trie = new Trie();
        for (const string &word : words) trie->insert(word);
        for (int i = 0; i < rows; ++i) {
            for (int j = 0; j < cols; ++j) {
                dfs(board, trie, rows, cols, i, j);
            }
        }
        return res;
    }
};
```

### 336. 回文对(Hard)

给定一组唯一的单词， 找出所有不同 的索引对(i, j)，使得列表中的两个单词， words[i] + words[j] ，可拼接成回文串。

示例 1:

输入: ["abcd","dcba","lls","s","sssll"]
输出: [[0,1],[1,0],[3,2],[2,4]]
解释: 可拼接成的回文串为 ["dcbaabcd","abcddcba","slls","llssssll"]
示例 2:

输入: ["bat","tab","cat"]
输出: [[0,1],[1,0]]
解释: 可拼接成的回文串为 ["battab","tabbat"]

本题使用**hashmap代替手动实现前缀树**，建立hashmap用来存放<单词，下标>，建立set表用来存放单词单词（方便马拉车算法用的），换言之，本题使用的**前缀树+马拉车算法**。

题解：

第一步：将<单词，下标>存放在hashmap中（使用hashmap代替前缀树），将单词的长度存放在set中。

第二步：遍历单词数组，将遍历的到的单词先进行反转：

1）第一种情况：单词数组中存在两个长度相等且互为回文的单词。比如：abcd和dcba，当我们遍历到abcd时，将其反转为dcba，然后我们判断dcba是否在map中，并且dcba的下标要和abcd的下标不一致。（因为类似bb这种单个字符重复的字符串，在反转之后得到的字符串的下标任然是它自己。）
2）第二种情况：单词数组中两个长度不一的单词构造回文对。比如abcdd、dbc或aabcd、bcd，先说abcdd、dbc，abcdd反转后得到的字符串为ddabc，那我们就需要在set表中找到长度为3的单词，然后截掉长度为3的子字符串后判断剩下的dd是否回文，并且还需要判断长度为3的字符串abc是否在map表中。然后我们再说说aabcd、bcd，aabcd反转后得到的字符串为bcdaa，那我们也需要在set表中找到长度为3的单词，截掉长度为3的子字符串后判断剩下的aa是否回文，并且还需要判断长度为3的字符串bcd是否在map表中。

```c++
class Solution {
public:
    vector<vector<int>> palindromePairs(vector<string>& words) {
        if(words.empty())return {};
        vector<vector<int>> result;
        unordered_map<string,int> m; // 单词->下标
        set<int> s; // 记录单词的长度，红黑树升序

        //第一次遍历：建立map表和set表
        for (int i=0;i<words.size();++i) {
            m[words[i]]=i;
            s.insert(words[i].size());
        }

        //第二次遍历：寻找回文对
        for (int i = 0; i < words.size(); ++i) {
            string word = words[i];
            int size = word.size();
            reverse(word.begin(),word.end()); //反转单词
            //第一种情况：回文对就是两个长度相等的单词互为反转字符串,比如abcd与dcba,但是要排除bb这种反转后依旧是自己的字符串
            if(m.count(word) != 0 && m[word] != i) result.push_back({i, m[word]});
            //第二种情况：回文对是两个长度不一的单词，比如lls,反转后为sll,我们在set中找到长度为1的单词，减去长度1的后ll是否为回文对
            auto a=s.find(size);
            for(auto it = s.begin(); it!=a; ++it){
                int d = *it;//set中长度为d的单词
                //处理str=回文对+字母，比如ddcba,我们找到长度为3的单词，就判断dd是否回文，然后判断减去dd后的cba是否在map中
                if(isValid(word, 0, size-d-1) && m.count(word.substr(size-d)))
                    result.push_back({i,m[word.substr(size-d)]});
                //处理str=字母+回文对，比如bcdaa,我们找到长度为3的单词，就判断aa是否回文，然后就判断减去aa后的bcd是否在map中
                if(isValid(word, d, size-1) && m.count(word.substr(0, d)))
                    result.push_back({m[word.substr(0, d)], i});
            }
        }
        return result;
    }

    bool isValid(string word,int left,int right) { //判断word是否为回文对
        while(left<right){
            if(word[left++]!=word[right--])
                return false;
        }
        return true;
    }
};
```

### 421. 数组中两个数的最大异或值(Medium)

给定一个非空数组，数组中元素为 a0, a1, a2, … , an-1，其中 0 ≤ ai < 231 。

找到 ai 和aj 最大的异或 (XOR) 运算结果，其中0 ≤ i,  j < n 。

你能在O(n)的时间解决这个问题吗？

示例:

输入: [3, 10, 5, 25, 2, 8]

输出: 28

解释: 最大的结果是 5 ^ 25 = 28.

首先把所有num存进前缀树中，高位放前缀树的高层，低位放前缀树的低层，然后对于每一个num，从前缀树中寻找和它异或后最大的值。

寻找过程如下：

- 若num当前位为1，则看前缀树在本层有没有0的指针，若有则走0，这样才能在当前位异或取到1
- 若num当前位为0，则看前指数在本层有没有1的指针，若有则走1，，这样才能在当前位异或取到1

```c++
class Trie {
public:
    Trie() {}
    void insert(int num) {
        auto root = this;
        for (int i = 31; i >= 0; --i) {
            int bit = num >> i & 1;
            if (!root->next[bit]) root->next[bit] = new Trie();
            root = root->next[bit];
        }
        root->value = num;
    }

public:
    Trie* next[2] = {nullptr};
    int value = -1; // 最底层节点存储32位长度的路径
};
class Solution {
public:
    int findMaximumXOR(vector<int>& nums) {
        int res = 0;
        Trie *trie = new Trie();
        Trie *cur = trie;
        for (int &num : nums) trie->insert(num);
        // 逐一访问每个数的32位
        // 贪心：从高位开始，若当前位为1，则看有没有本位为0的，若有则优先走这条路
        // 贪心策略：走与本位异或后为1的路
        for (int &num : nums) {
            cur = trie;
            for (int i = 31; i >= 0; --i) {
                int bit = num >> i & 1;
                if (bit == 0) {
                    if (cur->next[1]) {
                        cur = cur->next[1];
                    } else {
                        cur = cur->next[0];
                    }
                } else {
                    if (cur->next[0]) {
                        cur = cur->next[0];
                    } else {
                        cur = cur->next[1];
                    }
                }
            }
            int temp = cur->value;
            res = max(res, temp ^ num);
        }
        return res;
    }
};
```

### 472. 连接词(Hard)

给定一个不含重复单词的列表，编写一个程序，返回给定单词列表中所有的连接词。

连接词的定义为：一个字符串完全是由至少两个给定数组中的单词组成的。

示例:

输入: ["cat","cats","catsdogcats","dog","dogcatsdog","hippopotamuses","rat","ratcatdogcat"]

输出: ["catsdogcats","dogcatsdog","ratcatdogcat"]

解释: "catsdogcats"由"cats", "dog" 和 "cats"组成;
     "dogcatsdog"由"dog", "cats"和"dog"组成;
     "ratcatdogcat"由"rat", "cat", "dog"和"cat"组成。
说明:

给定数组的元素总数不超过 10000。
给定数组中元素的长度总和不超过 600000。
所有输入字符串只包含小写字母。
不需要考虑答案输出的顺序。

主要利用前缀树解题，先建树，然后进行搜索操作。
这里简单讲解一下搜索单词，例如寻找catsdogcats，当i为2时，我们在前缀树发现cat是一个子单词，然后开始search(sdogcats)，然而发现这个并不是子单词，那就证明以cat作为分界词就错了。我们继续for循环，然后匹配到cats时，在递归匹配dogcats，直到for循环结束！

```c++
class Trie {
public:
    Trie() {}

    void insert(string &word) {
        auto root = this;
        for (const char &w : word) {
            if (!root->next[w-'a']) root->next[w-'a'] = new Trie();
            root = root->next[w-'a'];
        }
        root->is_string = true; // 最后一个节点的标记
    }

    // param: index指示word的下标
    // param: count表示当前已匹配的小字符串数目
    bool search(string &word, int index, int count){
        Trie *root = this;
        for(int i = index; i < word.size(); ++i){
            if(root->next[word[i]-'a'] == nullptr) return false; // word的某个字符不在前缀树中
            root = root->next[word[i]-'a'];
            if(root->is_string){ //到达某个单词尾
                if(i == word.size() - 1) return count >= 1; //count的数量至少为2才是连接词，也就是说走到终点时count必须大于等于1
                // 当前位的字符已匹配，所以i+1
                // 当前已匹配一个单词，所以count+1
                // 进入下一层时，已经有count个的单词是已匹配的小字符串了
                // 继续匹配下一个小字符串，递归层层返回为true，说明已找到连接词，返回true
                // 若返回false，则以当前位结尾的小字符串不能构成word的一部分，继续探索前缀树，看更低层的小字符串能否构成word的一部分
                if(search(word, i+1, count+1)) return true;
            }
        }
        return false;
    }

private:
    Trie* next[26] = {nullptr};
    bool is_string = false;
};
class Solution {
public:
    vector<string> findAllConcatenatedWordsInADict(vector<string>& words) {
        vector<string> res;
        Trie *trie = new Trie();
        for (string &word : words) trie->insert(word);
        for (string &word : words) {
            if (trie->search(word, 0, 0)) { // 判断当前word是否是连接词
                res.push_back(word);
            }
        }
        return res;
    }
};
```

### 648. 单词替换(Medium)

在英语中，我们有一个叫做 词根(root)的概念，它可以跟着其他一些词组成另一个较长的单词——我们称这个词为 继承词(successor)。例如，词根an，跟随着单词 other(其他)，可以形成新的单词 another(另一个)。

现在，给定一个由许多词根组成的词典和一个句子。你需要将句子中的所有继承词用词根替换掉。如果继承词有许多可以形成它的词根，则用最短的词根替换它。

你需要输出替换之后的句子。

示例：

输入：dict(词典) = ["cat", "bat", "rat"] sentence(句子) = "the cattle was rattled by the battery"
输出："the cat was rat by the bat"

提示：

输入只包含小写字母。
1 <= dict.length <= 1000
1 <= dict[i].length <= 100
1 <= 句中词语数 <= 1000
1 <= 句中词语长度 <= 1000

```c++
class Trie {
public:
    Trie() {}

    void insert(string word) {
        auto root = this;
        for (const char &w : word) {
            if (!root->next[w-'a']) root->next[w-'a'] = new Trie();
            root = root->next[w-'a'];
        }
        root->is_string = true; // 最后一个节点的标记
    }

public:
    Trie* next[26] = {nullptr};
    bool is_string = false;
};
class Solution {
public:
    string replaceWords(vector<string>& dict, string sentence) {
        Trie *trie = new Trie();
        Trie *cur = trie;
        for (string &root : dict) trie->insert(root);
        string res;
        for (int i = 0; i < sentence.size(); ++i)  {
            if (sentence[i] == ' ') continue;
            cur = trie;
            string word_root;
            int j = i; // i指示一个单词的左端点，j往右扩展，直到这个单词的右端点后的空格或到句子结束
            while (j < sentence.size() && sentence[j] != ' ') {
                if (cur->is_string) {
                    word_root = sentence.substr(i, j - i);
                    break;
                } else if (!cur->next[sentence[j]-'a']) {
                    break;
                } else {
                    cur = cur->next[sentence[j]-'a'];
                }
                ++j;
            }
            while (j < sentence.size() && sentence[j] != ' ') ++j;
            if (word_root.empty()) {
                res += " " + sentence.substr(i, j - i);
            } else {
                res += " " + word_root;
            }
            i = j;
        }
        return res.substr(1); // 去掉第0位的空格
    }
};
```

更快的解法是不用前缀树，只需要一一对比dict中各词根即可

```c++
class Solution {
public:
    string replaceWords(vector<string>& dict, string sentence) {
        istringstream line(sentence);
        string word, result = "";
        while(line >> word){
            int i = 0;
            for(; i < dict.size(); ++i) {
                //找到前缀词，将前缀词加到result中
                if(dict[i][0] == word[0] && word.substr(0, dict[i].size()) == dict[i]) {
                    result += dict[i] + " ";
                    break;
                }
            }
            //没有找到前缀词，将原有的单词添加到result中
            if(i == dict.size()) result += word +" ";
        }
        if(result.size() > 0) result.resize(result.size() - 1); //删除最后一个空格
        return result;
    }
};
```

但是这个题解通过125/126，没通过的case如下：

```shell
  vector<string> A = {"catt", "cat","bat", "rat"};
  string str = "the cattle was rattled by the battery";

Answer:
    the catt was rat by the bat

Expected Answer:
    the cat was rat by the bat
```

解决办法：在开头对dict按string长度升序排列

```c++
        auto cmp = [](string &s1, string &s2) {
            return s1.size() < s2.size();
        };
        sort(dict.begin(), dict.end(), cmp); // 排序，优先匹配词根cat而不是词根catt
```

### 676. 实现一个魔法字典(Medium)

实现一个带有buildDict, 以及 search方法的魔法字典。

对于buildDict方法，你将被给定一串不重复的单词来构建一个字典。

对于search方法，你将被给定一个单词，并且判定能否只将这个单词中一个字母换成另一个字母，使得所形成的新单词存在于你构建的字典中。

示例 1:

Input: buildDict(["hello", "leetcode"]), Output: Null
Input: search("hello"), Output: False
Input: search("hhllo"), Output: True
Input: search("hell"), Output: False
Input: search("leetcoded"), Output: False
注意:

你可以假设所有输入都是小写字母 a-z。
为了便于竞赛，测试所用的数据量很小。你可以在竞赛结束后，考虑更高效的算法。
请记住重置MagicDictionary类中声明的类变量，因为静态/类变量会在多个测试用例中保留。 请参阅这里了解更多详情。

自己尝试前缀树，用布尔变量记录是否改变过，首先写出了一版有bug的代码，可以通过一部分case，但是如果魔法字典中是hello,hallo，输入hello返回false（因为匹配了hello），但其实是可以匹配hallo的，应该返回true

```c++
class MagicDictionary {
public:
    /** Initialize your data structure here. */
    MagicDictionary() {}

    /** Build a dictionary through a list of words */
    void buildDict(vector<string> dict) {
        for (string &word : dict) {
            auto root = this;
            for (const char &w : word) {
                if (!root->next[w-'a']) root->next[w-'a'] = new MagicDictionary();
                root = root->next[w-'a'];
            }
            root->is_string = true;
        }
    }

    /** Returns if there is any word in the MagicDictionary that equals to the given word after modifying exactly one character */
    bool search(string word) {
        return searchHelper(word, 0, this, false);
    }

    bool searchHelper(string &word, int index, MagicDictionary* root, bool isModified) {
        for (int i = index; i < word.size(); ++i) {
            if (!root->next[word[i]-'a']) {
                if (isModified) return false;
                else {
                    for (int j = 0; j < 26; ++j) {
                        if (root->next[j]) {
                            if (searchHelper(word, i+1, root->next[j], true)) {
                                return true;
                            }
                        }
                    }
                    return false;
                }
            }
            root = root->next[word[i]-'a'];
        }
        return isModified && root->is_string;
    }
private:
    MagicDictionary* next[26] = {nullptr};
    bool is_string = false;
};
```

优化后的代码，AC了

```c++
struct Trie{
    bool is_string=false;
    Trie *next[26]={nullptr};
};
class MagicDictionary {
private:
    Trie *root;
public:
    /** Initialize your data structure here. */
    MagicDictionary() {
        root=new Trie();
    }

    /** Build a dictionary through a list of words */
    void buildDict(vector<string> dict) {
        for(const auto& word:dict){
            Trie* note=root;
            for(const auto& w:word){
                if(note->next[w-'a']==nullptr)note->next[w-'a']=new Trie();
                note=note->next[w-'a'];
            }
            note->is_string=true;
        }
    }

    /** Returns if there is any word in the trie that equals to the given word after modifying exactly one character */
    bool search(string word) {
        return dfs(word,root,0,false);
    }

    bool dfs(string word,Trie* note,int index,bool isMod)
    {
        if(note==nullptr)return false;
        //此时搜索完成，note也指向单词尾端，单个字符也替换了
        if(word.size()==index)return isMod&&note->is_string;
        for(int i=0;i<26;++i){//搜索note的26个节点,若遍历完26个节点依旧没有找到节点字符与index对象的字符相等或idMod为true已替换一个字符了，则直接返回false了
            if(note->next[i]!=nullptr){//找到一个节点值
                if(i+'a'==word[index]){//找到的节点字符与index对应的字符相等，继续匹配下一个字符
                    if(dfs(word,note->next[i],index+1,isMod))return true;
                }
                //如果'a'+i!=word[index],则使用替换字母的机会（在此之前替换字母的机会是没有使用的，因为只能使用一次）
                else if(isMod==false&&dfs(word,note->next[i],index+1,true))
                    return true;
            }
        }
        return false;
    }
};
```

### 677. 键值映射(Medium)

实现一个 MapSum 类里的两个方法，insert 和 sum。

对于方法 insert，你将得到一对（字符串，整数）的键值对。字符串表示键，整数表示值。如果键已经存在，那么原来的键值对将被替代成新的键值对。

对于方法 sum，你将得到一个表示前缀的字符串，你需要返回所有以该前缀开头的键的值的总和。

示例 1:

输入: insert("apple", 3), 输出: Null
输入: sum("ap"), 输出: 3
输入: insert("app", 2), 输出: Null
输入: sum("ap"), 输出: 5

```c++
struct Trie {
    Trie* next[256] = {nullptr};
    bool is_string = false;
    int val = 0;
};
class MapSum {
public:
    Trie *trie;
    /** Initialize your data structure here. */
    MapSum() {
        trie = new Trie();
    }

    void insert(string key, int val) {
        auto root = trie;
        for (const char &w : key) {
            if (!root->next[w]) root->next[w] = new Trie();
            root = root->next[w];
        }
        root->is_string = true;
        root->val = val;
    }

    int sum(string prefix) {
        int res = 0;
        auto root = trie;
        for (const char &w : prefix) {
            if (!root->next[w]) return 0;
            root = root->next[w];
        }
        dfs(root, res);
        return  res;
    }

    void dfs(Trie *root, int &res) {
        if (root->is_string) res += root->val;
        for (int i = 0; i < 256; ++i) {
            if (root->next[i]) {
                dfs(root->next[i], res);
            }
        }
    }
};

/**
 * Your MapSum object will be instantiated and called as such:
 * MapSum* obj = new MapSum();
 * obj->insert(key,val);
 * int param_2 = obj->sum(prefix);
 */
```

还有一种很妙的方法，利用map来代替前缀树，利用红黑树升序的特点查找前缀

```c++
class MapSum{
private:
    map<string, int> record;
public:
    MapSum() {}

    void insert(string key, int val) {
        record[key]=val;
    }

    int sum(string prefix) {
        int result = 0;
        for(auto iter : record){
            string str = iter.first;
            if(str.find(prefix) == 0) // prefix是str的前缀
                result += iter.second;
        }
        return result;
    }
};
```

### 692. 前K个高频单词(Medium)

给一非空的单词列表，返回前 k 个出现次数最多的单词。

返回的答案应该按单词出现频率由高到低排序。如果不同的单词有相同出现频率，按字母顺序排序。

示例 1：

输入: ["i", "love", "leetcode", "i", "love", "coding"], k = 2
输出: ["i", "love"]
解析: "i" 和 "love" 为出现次数最多的两个单词，均为2次。
    注意，按字母顺序 "i" 在 "love" 之前。

示例 2：

输入: ["the", "day", "is", "sunny", "the", "the", "the", "sunny", "is", "is"], k = 4
输出: ["the", "is", "sunny", "day"]
解析: "the", "is", "sunny" 和 "day" 是出现次数最多的四个单词，
    出现次数依次为 4, 3, 2 和 1 次。

注意：

假定 k 总为有效值， 1 ≤ k ≤ 集合元素数。
输入的单词均由小写字母组成。

扩展练习：

尝试以 O(n log k) 时间复杂度和 O(n) 空间复杂度解决。

第一次尝试，感觉可以用map<string, int>， 然后对map的value进行排序。map虽然可以自定义比较规则，但只能比较key，不能比较value，而且sort泛型算法要求顺序容奇而不是关联容奇。所以只能把map的pair存储到一个vector，再调用sort对vector进行排序，自定义排序规则即可。

时间复杂度O(nlogn)，空间复杂度O(n)

```c++
class Solution {
public:
    vector<string> topKFrequent(vector<string>& words, int k) {
        vector<string> res;
        if (words.empty() || k < 1) return res;
        map<string, int> map;
        for (const string &word : words) {
            ++map[word];
        }
        vector<pair<string, int>> vec(map.begin(), map.end());
        auto cmp = [](const pair<string, int> &p1, const pair<string, int> &p2) {
            if (p1.second != p2.second) return p1.second > p2.second;
            return p1.first < p2.first;
            // return p1.first.compare(p2.first) < 0; // 也可以
        };
        sort(vec.begin(), vec.end(), cmp);
        for (auto it = vec.begin(); it != vec.end() && it != vec.begin() + k; ++it) {
            res.push_back(it->first);
        }
        return res;
    }
};
```

仔细想想，刚才把pair放进vector，再对vector进行了排序，这需要O(nlogn)的时间，这可以用最小堆的思想，维护一个大小为k的最小堆即可。这题挺考验STL功底的，还挺有意思的。

```c++
class Solution {
public:
    struct Compare {
        bool operator() (const pair<string, int> &p1, const pair<string, int> &p2) {
            if (p1.second != p2.second) return p1.second > p2.second;
            return p1.first < p2.first;
            // return p1.first.compare(p2.first) < 0; // 也可以
        };
    };
    vector<string> topKFrequent(vector<string>& words, int k) {
        map<string, int> map;
        for (const string &word : words) {
            ++map[word];
        }
        // 维护一个最小堆
        priority_queue<pair<string, int>, vector<pair<string, int>>, Compare> pq;
        auto it = map.begin();
        for (int cnt = 0; it != map.end() && cnt != k; ++it, ++cnt) {
            pq.push(*it);
        }
        Compare cmp;
        for (; it != map.end(); ++it) {
            if (cmp(*it, pq.top())) { // 新元素比最小堆的堆顶要『大』
                pq.pop();
                pq.push(*it);
            }
        }
        vector<string> res;
        int n = min(k, (int)map.size());
        res.resize(n);
        for (int i = n - 1; i >= 0; --i) {
            res[i] = pq.top().first;
            pq.pop();
        }
        return res;
    }
};
```

### 720. 词典中最长的单词(Easy)

给出一个字符串数组words组成的一本英语词典。从中找出最长的一个单词，该单词是由words词典中其他单词逐步添加一个字母组成。若其中有多个可行的答案，则返回答案中字典序最小的单词。

若无答案，则返回空字符串。

示例 1：

输入：
words = ["w","wo","wor","worl", "world"]
输出："world"
解释：
单词"world"可由"w", "wo", "wor", 和 "worl"添加一个字母组成。
示例 2：

输入：
words = ["a", "banana", "app", "appl", "ap", "apply", "apple"]
输出："apple"
解释：
"apply"和"apple"都能由词典中的单词组成。但是"apple"的字典序小于"apply"。

提示：

所有输入的字符串都只包含小写字母。
words数组长度范围为[1,1000]。
words[i]的长度范围为[1,30]。

```c++
class Trie {
public:
    void insert(string &word) {
       auto root = this;
       for (const char &w : word) {
           if (!root->next[w-'a']) root->next[w-'a'] = new Trie();
           root = root->next[w-'a'];
       }
       root->is_string = true;
       root->str = word;
    }
    Trie* next[26] = {nullptr};
    bool is_string = false;
    string str;
};
class Solution {
public:
    string ans = "";
    void dfs(Trie *trie) {
        if (!trie->is_string) return;
        if (trie->str.size() > ans.size()) ans = trie->str;
        else if(trie->str.size() == ans.size() && trie->str < ans) ans = trie->str; // 字典序更小
        for (int i = 0; i < 26; ++i) {
            if (trie->next[i]) dfs(trie->next[i]);
        }
    }
    string longestWord(vector<string>& words) {
        Trie *trie = new Trie();
        for (string &word : words) trie->insert(word);
        for (int i = 0; i < 26; ++i) {
            if (trie->next[i]) dfs(trie->next[i]);
        }
        return ans;
    }
};
```

### 745. 前缀和后缀搜索(Hard)

给定多个 words，words[i] 的权重为 i 。

设计一个类 WordFilter 实现函数WordFilter.f(String prefix, String suffix)。这个函数将返回具有前缀 prefix 和后缀suffix 的词的最大权重。如果没有这样的词，返回 -1。

例子:

输入:
WordFilter(["apple"])
WordFilter.f("a", "e") // 返回 0
WordFilter.f("b", "") // 返回 -1
注意:

words的长度在[1, 15000]之间。
对于每个测试用例，最多会有words.length次对WordFilter.f的调用。
words[i]的长度在[1, 10]之间。
prefix, suffix的长度在[0, 10]之前。
words[i]和prefix, suffix只包含小写字母。

首次尝试，构造前缀树和后缀树，根据前缀和后缀搜寻所有有有可能的word及其weight，再根据哈希表判重，最后输出最大的weight。

但是超时了

```c++
class PreTrie {
public:
    void insert(string &word, int weight) {
        auto root = this;
        for (char &w : word) {
            if (!root->pre_next[w-'a']) root->pre_next[w-'a'] = new PreTrie();
            root = root->pre_next[w-'a'];
        }
        root->pre_is_string = true;
        root->pre_str = word;
        root->weight = weight;
    }
    vector<pair<string, int>> searchPrefix(string &word) {
        vector<pair<string, int>> res;
        auto root = this;
        for (char &w : word) {
            if (!root->pre_next[w-'a']) return res;
            root = root->pre_next[w-'a'];
        }
        dfs(root, res);
        return res;
    }
    void dfs(PreTrie *root, vector<pair<string, int>> &res) {
        if (root->pre_is_string) {
            res.push_back({root->pre_str, root->weight});
        }
        for (int i = 0; i < 26; ++i) {
            if (root->pre_next[i]) dfs(root->pre_next[i], res);
        }
    }
public:
    PreTrie* pre_next[26] = {nullptr};
    bool pre_is_string = false;
    string pre_str = "";
    int weight = -1;
};
class SufTrie {
public:
    void insert(string &word, int weight) {
        auto root = this;
        for (char &w : word) {
            if (!root->suf_next[w-'a']) root->suf_next[w-'a'] = new SufTrie();
            root = root->suf_next[w-'a'];
        }
        root->suf_is_string = true;
        root->suf_str = word;
        root->weight = weight;
    }
    vector<pair<string, int>> searchSuffix(string &word) {
        vector<pair<string, int>> res;
        auto root = this;
        for (char &w : word) {
            if (!root->suf_next[w-'a']) return res;
            root = root->suf_next[w-'a'];
        }
        dfs(root, res);
        return res;
    }
    void dfs(SufTrie *root, vector<pair<string, int>> &res) {
        if (root->suf_is_string) {
            string tmp = root->suf_str;
            reverse(tmp.begin(), tmp.end());
            res.push_back({tmp, root->weight});
        }
        for (int i = 0; i < 26; ++i) {
            if (root->suf_next[i]) dfs(root->suf_next[i], res);
        }
    }
public:
    SufTrie* suf_next[26] = {nullptr};
    bool suf_is_string = false;
    string suf_str = "";
    int weight = -1;
};
class WordFilter {
public:
    PreTrie *pre_trie;
    SufTrie *suf_trie;
    WordFilter(vector<string>& words) {
        pre_trie = new PreTrie();
        suf_trie = new SufTrie();
        for (int i = 0; i < words.size(); ++i) {
            string tmp = words[i];
            reverse(tmp.begin(), tmp.end());
            pre_trie->insert(words[i], i);
            suf_trie->insert(tmp, i);
        }
    }

    int f(string prefix, string suffix) {
        reverse(suffix.begin(), suffix.end());
        vector<pair<string, int>> res1 = pre_trie->searchPrefix(prefix); // 前缀匹配的所有单词及其权重
        vector<pair<string, int>> res2 = suf_trie->searchSuffix(suffix); // 后缀匹配的所有单词及其权重
        // 找出同时匹配的单词及其权重
        // 利用哈希表快速判定是否同时存在
        unordered_map<string, int> map;
        for (auto &p : res1) {
            map[p.first] = p.second;
        }
        vector<pair<string, int>> satisfied;
        for (auto &p : res2) {
            if (map.count(p.first)) {
                satisfied.push_back(p);
            }
        }
        int ans = -1;
        for (auto &p : satisfied) {
            ans = max(ans, p.second);
        }
        return ans;
    }
};
```

优化：

- 可以利用指针，而不用拷贝vector
- 哈希表判重逻辑太慢了，只需要找到两个vector交集的最大权重即可
- 可以在前缀/后缀树中的每一个节点都保存`vector<int>`数组，保持着到该层为前缀的所有word的权重，因为权重是输入数组的下标，所以越大的权重越晚压入，本身就是升序的
- 只需要定义一个Trie类即可，创建Trie类对象时再决定是前缀树还是后缀树

```c++
class Trie{
private:
    vector<int> subs;
    Trie* next[26] = {nullptr};
public:
    Trie(){}
    //插入单词
    void insert(string& word,int i){
        Trie* root=this;
        for(const auto& w:word){
            if(root->next[w-'a']==nullptr)root->next[w-'a']=new Trie();
            root=root->next[w-'a'];
            // 在构造前缀/后缀树时，直接把当前word的权重存入每一个节点的vector中
            // 根据push_back顺序，越大权重的会越晚压入
            root->subs.push_back(i);
        }
    }

    vector<int>* startsWith(string& prefix){
        Trie* root=this;
        for(const auto& p:prefix){
            if(root->next[p-'a']==nullptr)return nullptr;
            root=root->next[p-'a'];
        }
        return &root->subs; // 前缀/后缀搜寻完，返回当前节点的权重数组，代表着匹配到的单词的所有权重可能
    }
};
class WordFilter {
private:
    Trie* pre;//建立前缀树
    Trie* suf;//建立后缀树
    int size=0;
public:
    WordFilter(vector<string>& words) {
        pre=new Trie();suf=new Trie();
        for(int i=0;i<words.size();++i){
            pre->insert(words[i],i);
            string temp=words[i];//正向插入单词到前缀树
            reverse(temp.begin(),temp.end());
            suf->insert(temp,i);//反向插入单词到后缀树
        }
        int size=words.size()-1;
    }

    int f(string prefix, string suffix) {
        //前缀字符串和后缀字符串都为空，最大权重就是words的大小了
        if(prefix.empty()&&suffix.empty())return size;
        vector<int>* v1=pre->startsWith(prefix);
        reverse(suffix.begin(),suffix.end());
        vector<int>* v2=suf->startsWith(suffix);
        if(v1==nullptr||v2==nullptr)return -1;//前缀或后缀有一个为空，就表示没有这样的单词
        if(prefix.size()==0)return *(v2->end()-1);//前缀字符串为空，返回后缀字典树中的最大权重
        if(suffix.size()==0)return *(v1->end()-1);//后缀字符串为空，返回前缀字典树中的最大权重
        auto it1=v1->end()-1;
        auto it2=v2->end()-1;
        while(it1>=v1->begin()&&it2>=v2->begin())//查找的时候排除边缘条件后对比权值就行
        {
            if(*it1==*it2)return *it1;
            if(*it1>*it2)it1--;
            else it2--;
        }
        return -1;
    }
};
```

### 1023. 驼峰式匹配(Medium)

如果我们可以将小写字母插入模式串 pattern 得到待查询项 query，那么待查询项与给定模式串匹配。（我们可以在任何位置插入每个字符，也可以插入 0 个字符。）

给定待查询列表 queries，和模式串 pattern，返回由布尔值组成的答案列表 answer。只有在待查项 queries[i] 与模式串 pattern 匹配时， answer[i] 才为 true，否则为 false。

示例 1：

输入：queries = ["FooBar","FooBarTest","FootBall","FrameBuffer","ForceFeedBack"], pattern = "FB"
输出：[true,false,true,true,false]
示例：
"FooBar" 可以这样生成："F" + "oo" + "B" + "ar"。
"FootBall" 可以这样生成："F" + "oot" + "B" + "all".
"FrameBuffer" 可以这样生成："F" + "rame" + "B" + "uffer".
示例 2：

输入：queries = ["FooBar","FooBarTest","FootBall","FrameBuffer","ForceFeedBack"], pattern = "FoBa"
输出：[true,false,true,false,false]
解释：
"FooBar" 可以这样生成："Fo" + "o" + "Ba" + "r".
"FootBall" 可以这样生成："Fo" + "ot" + "Ba" + "ll".
示例 3：

输出：queries = ["FooBar","FooBarTest","FootBall","FrameBuffer","ForceFeedBack"], pattern = "FoBaT"
输入：[false,true,false,false,false]
解释：
"FooBarTest" 可以这样生成："Fo" + "o" + "Ba" + "r" + "T" + "est".

提示：

1 <= queries.length <= 100
1 <= queries[i].length <= 100
1 <= pattern.length <= 100
所有字符串都仅由大写和小写英文字母组成。

直接匹配就好了，双指针法，不需要前缀树

```c++
class Solution {
public:
    bool match(string &query, string &pattern) {
        int i = 0, j = 0;
        while (i < query.size()) {
            if (j < pattern.size() && query[i] == pattern[j]) ++i, ++j;
            else if (query[i] >= 'A' && query[i] <= 'Z') break; // 有不匹配的大写字母
            else ++i; // 可以插入小写字母
        }
        if (i >= query.size() && j >= pattern.size()) return true; // 两者同时到头才是匹配
        return false;
    }
    vector<bool> camelMatch(vector<string>& queries, string pattern) {
        vector<bool> res;
        for (string &query : queries) {
            res.push_back(match(query, pattern));
        }
        return res;
    }
};
```

前缀树思路

- 将 patternpattern 插入字典树，标记出末尾字符
- 对 queriesqueries 中的每个字符串，逐个字符进行匹配
- 若小写字母不能匹配，直接忽略
- 若大写字母不能匹配，返回 falsefalse
- 最后检查是否到达末尾

### 1032. 字符流(Hard)

按下述要求实现 StreamChecker 类：

StreamChecker(words)：构造函数，用给定的字词初始化数据结构。
query(letter)：如果存在某些 k >= 1，可以用查询的最后 k个字符（按从旧到新顺序，包括刚刚查询的字母）拼写出给定字词表中的某一字词时，返回 true。否则，返回 false。

示例：

StreamChecker streamChecker = new StreamChecker(["cd","f","kl"]); // 初始化字典
streamChecker.query('a');          // 返回 false
streamChecker.query('b');          // 返回 false
streamChecker.query('c');          // 返回 false
streamChecker.query('d');          // 返回 true，因为 'cd' 在字词表中
streamChecker.query('e');          // 返回 false
streamChecker.query('f');          // 返回 true，因为 'f' 在字词表中
streamChecker.query('g');          // 返回 false
streamChecker.query('h');          // 返回 false
streamChecker.query('i');          // 返回 false
streamChecker.query('j');          // 返回 false
streamChecker.query('k');          // 返回 false
streamChecker.query('l');          // 返回 true，因为 'kl' 在字词表中。

提示：

1 <= words.length <= 2000
1 <= words[i].length <= 2000
字词只包含小写英文字母。
待查项只包含小写英文字母。
待查项最多 40000 个。

解题思路：

1）从words中提取word，将word反向，建立后缀树。
2）在查询的时候，我们将每个字符保存在一个字符串中，每次每个字符都插入到该字符串的首部。然后我们直接在后缀树中查找该字符串的最短前缀能否表示成一个字符串就行了。

AC发现时间很慢。。

```c++
class Trie{
private:
    bool is_string = false;
    Trie* next[26] = {nullptr};
public:
    Trie(){}
    void insert(string &word) {
        Trie* root = this;
        for (const auto &w : word){
            if (!root->next[w-'a']) root->next[w-'a'] = new Trie();
            root = root->next[w-'a'];
        }
        root->is_string = true;
    }
    bool startsWith(string &word) {
        Trie* root = this;
        for (const auto &w : word) {
            if (root->next[w-'a'] != nullptr) {
                root = root->next[w-'a'];
                if (root->is_string) return true;
            } else {
                return false;
            }
        }
        return false;
    }
};
class StreamChecker {
public:
    Trie* trie;
    string word;
    StreamChecker(vector<string>& words) {
        trie = new Trie();
        for (string &word : words) {
            reverse(word.begin(), word.end());
            trie->insert(word);
        }
    }

    bool query(char letter) {
        word.insert(word.begin(), letter);
        return trie->startsWith(word);
    }
};

/**
 * Your StreamChecker object will be instantiated and called as such:
 * StreamChecker* obj = new StreamChecker(words);
 * bool param_1 = obj->query(letter);
 */
```

优化：

- 每次加入letter时，加在string的前面，这很耗时，改为加在后面，在内部startsWith搜索时反向搜索即可
- 同理，在构建后缀树时，在内部insert时反向插入即可
- 时间从1680ms（击败5%）优化到了548ms（击败85%）

```c++
class Trie{
private:
    bool is_string = false;
    Trie* next[26] = {nullptr};
public:
    Trie(){}
    void insert(string &word) {
        Trie* root = this;
        for (int i = word.size()-1; i >= 0; --i){
            if (!root->next[word[i]-'a']) root->next[word[i]-'a'] = new Trie();
            root = root->next[word[i]-'a'];
        }
        root->is_string = true;
    }
    bool startsWith(string &word) {
        Trie* root = this;
        for (int i = word.size()-1; i >= 0; --i) {
            if (root->next[word[i]-'a'] != nullptr) {
                root = root->next[word[i]-'a'];
                if (root->is_string) return true;
            } else {
                return false;
            }
        }
        return false;
    }
};
class StreamChecker {
public:
    Trie* trie;
    string word;
    StreamChecker(vector<string>& words) {
        trie = new Trie();
        for (string &word : words) {
            trie->insert(word);
        }
    }

    bool query(char letter) {
        word += letter;
        return trie->startsWith(word); // 在内部反向搜索
    }
};

/**
 * Your StreamChecker object will be instantiated and called as such:
 * StreamChecker* obj = new StreamChecker(words);
 * bool param_1 = obj->query(letter);
 */
 ```

## 滑动窗口

### 76. 最小覆盖子串(Hard)

给你一个字符串 S、一个字符串 T 。请你设计一种算法，可以在 O(n) 的时间复杂度内，从字符串 S 里面找出：包含 T 所有字符的最小子串。

示例：

输入：S = "ADOBECODEBANC", T = "ABC"
输出："BANC"

提示：

如果 S 中不存这样的子串，则返回空字符串 ""。
如果 S 中存在这样的子串，我们保证它是唯一的答案。

[滑动窗口通用思想](https://leetcode-cn.com/problems/minimum-window-substring/solution/hua-dong-chuang-kou-suan-fa-tong-yong-si-xiang-by-/)

把索引左闭右开区间 [left, right) 称为一个「窗口」。

- 如果一个字符进入窗口，应该增加 window 计数器；
- 如果一个字符将移出窗口的时候，应该减少 window 计数器；
- 当 valid 满足 need 时应该收缩窗口；
- 应该在收缩窗口的时候更新最终结果。

```c++
class Solution {
public:
    string minWindow(string s, string t) {
        unordered_map<char, int> need, window;
        for(char &c : t) ++need[c];
        int l = 0, r = 0;
        int len = INT_MAX;
        int start;
        int valid = 0; // 记录在滑动窗口内有多少个满足出现次数的字符
        char c, d;
        while (r < s.size()) {
            // 将右端点加入
            if (need.count(s[r])) {
                ++window[s[r]];
                if (need[s[r]] == window[s[r]]) {
                    ++valid;
                }
            }
            ++r;
            while (valid == need.size()) { // 窗口符合条件，可以收缩左侧边界了
                if (r - l < len) {
                    start = l;
                    len = r -l;
                }
                if (need.count(s[l])) { // 如果收缩的左端点是需要的，则更新目前窗口与valid
                    if (need[s[l]] == window[s[l]]) {
                        --valid;
                    }
                    --window[s[l]];
                }
                ++l;
            }
        }
        return len == INT_MAX ? "" : s.substr(start, len); // substr接收一个起始值和长度值作为参数
    }
};
```

刷hot100 更容易理解


### 239. 滑动窗口最大值(Hard) @hot100

同力扣59-1

给定一个数组 nums，有一个大小为 k 的滑动窗口从数组的最左侧移动到数组的最右侧。你只可以看到在滑动窗口内的 k 个数字。滑动窗口每次只向右移动一位。

返回滑动窗口中的最大值。

进阶：

你能在线性时间复杂度内解决此题吗？

示例:

输入: nums = [1,3,-1,-3,5,3,6,7], 和 k = 3
输出: [3,3,5,5,6,7]
解释:

  滑动窗口的位置                最大值
---------------               -----
[1  3  -1] -3  5  3  6  7       3
 1 [3  -1  -3] 5  3  6  7       3
 1  3 [-1  -3  5] 3  6  7       5
 1  3  -1 [-3  5  3] 6  7       5
 1  3  -1  -3 [5  3  6] 7       6
 1  3  -1  -3  5 [3  6  7]      7

提示：

1 <= nums.length <= 10^5
-10^4 <= nums[i] <= 10^4
1 <= k <= nums.length

优化：时间复杂度为O(n)，空间复杂度为O(1)，用到了双端队列（STL容器deque）

1. 窗口向右滑动的过程实际上就是将处于窗口的第一个数字删除，同时在窗口的末尾添加一个新的数字，这就可以用双向队列来模拟，每次把尾部的数字弹出，再把新的数字压入到头部，然后找队列中最大的元素即可。
2. 为了更快地找到最大的元素，我们可以在队列中只保留那些可能成为窗口最大元素的数字，去掉那些不可能成为窗口中最大元素的数字。考虑这样一个情况，如果队列中进来一个较大的数字，那么队列中比这个数更小的数字就不可能再成为窗口中最大的元素了，因为这个大的数字是后进来的，一定会比之前早进入窗口的小的数字要晚离开窗口，那么那些早进入且比较小的数字就“永无出头之日”，所以就可以弹出队列。
3. 于是我们维护一个**双向单调队列**，队列放的是元素的下标。我们假设该双端队列的队头是整个队列的最大元素所在下标，至队尾下标代表的元素值依次降低。初始时单调队列为空。随着对数组的遍历过程中，每次插入元素前，首先需要看队头是否还能留在队列中，如果当前下标距离队头下标超过了k，则应该出队。同时需要维护队列的单调性，如果nums[i]大于或等于队尾元素下标所对应的值，则当前队尾再也不可能充当某个滑动窗口的最大值了，故需要队尾出队，直至队列为空或者队尾不小于nums[i]。
4. 始终保持队中元素从队头到队尾单调递减。依次遍历一遍数组，每次队头就是每个滑动窗口的最大值所在下标。

```c++
class Solution {
public:
    vector<int> maxSlidingWindow(vector<int>& nums, int k) {
        vector<int> res;
        deque<int> dq; // 双向单调递增队列，存放的是元素的下标
        for (int i = 0; i < k; ++i) {
            while (!dq.empty() && nums[i] > nums[dq.back()]) {
                dq.pop_back();
            }
            dq.push_back(i);
        }
        res.push_back(nums[dq.front()]);
        for (int i = k; i < nums.size(); ++i) {
            // 每滑动一次，就更新下当前队头的有效性
            if (!dq.empty() && i - dq.front() >= k) { // 左侧元素滑出
                dq.pop_front();
            }
            // 找到合适的位置插入新元素，因为新元素更新，所以可以直接排除掉那些又老又小的元素
            while (!dq.empty() && nums[i] > nums[dq.back()]) { // 右侧元素滑入
                dq.pop_back();
            }
            dq.push_back(i);
            res.push_back(nums[dq.front()]);
        }
        return res;
    }
};
```

刷hot100时，想到了用最大堆来做，最坏情况时间复杂度O(nlogn)，最坏情况下数组单调递增，最终最大堆包含全部元素，因为每次放入最大度耗时O(logn)，所以整体O(nlogn)，空间复杂度O(n)，

```c++
class Solution {
public:
    struct stru{
        int value;
        int offset;
        stru(int value, int offset) : value(value), offset(offset) {}
    };
    struct myCompare {
        bool operator()(const stru &lhs, const stru &rhs) {
            return lhs.value < rhs.value;
        }
    };
    vector<int> maxSlidingWindow(vector<int>& nums, int k) {
        auto myLambdaCompare = [](const stru &lhs, const stru &rhs){
            return lhs.value < rhs.value;
        };
        priority_queue<stru, vector<stru>, myCompare> pq;
        // priority_queue<stru, vector<stru>, decltype(myLambdaCompare)> pq(myLambdaCompare);
        vector<int> res;
        for (int i = 0; i < nums.size(); ++i) {
            if (i < k - 1) {
                pq.push(stru(nums[i], i));
                continue;
            }
            pq.push(stru(nums[i], i));
            while (!pq.empty() && i - pq.top().offset >= k) {
                pq.pop();
            }
            res.push_back(pq.top().value);
        }
        return res;
    }
};
```

### 340.至多包含k个不同字符的最长子串(Hard)

这题需要会员，找了个题解

[LeetCode 340. 至多包含 K 个不同字符的最长子串（滑动窗口）](https://blog.csdn.net/qq_21201267/article/details/107399576)

哈希map对字符计数

维持哈希map的size<=k，计数为0时，删除 key

```c++
int func(string s, int k) {
    unordered_map<char, int> m;
    int maxLen = 0;
    int i = 0; // 快指针
    int j = 0; // 慢指针
    while (i < s.size()) {
        if (m.size() <= k) m[s[i]]++;
        while (m.size() > k) { // 当前区间不满足『至多包含k个不同字符』
            if (--m[s[j]] == 0) {
                m.erase(s[j]);
            }
            ++j; // 慢指针左移
        }
        maxLen = max(maxLen, i - j + 1);
        ++i; // 快指针左移
    }
    return maxLen;
}
```

### 424. 替换后的最长重复字符(Medium)

给你一个仅由大写英文字母组成的字符串，你可以将任意位置上的字符替换成另外的字符，总共可最多替换 k 次。在执行上述操作后，找到包含重复字母的最长子串的长度。

注意:
字符串长度 和 k 不会超过 104。

示例 1:

输入:
s = "ABAB", k = 2

输出:
4

解释:
用两个'A'替换为两个'B',反之亦然。
示例 2:

输入:
s = "AABABBA", k = 1

输出:
4

解释:
将中间的一个'A'替换为'B',字符串变为 "AABBBBA"。
子串 "BBBB" 有最长重复字母, 答案为 4。

滑动窗口，这题关键是maxCount的理解。不需要保存每一个窗口内的字母出现的最大值，因为字母一定是从右边新添的字符里出现，而且只有当窗口内出现了比历史更多的字母数时，答案才会更新，也就是maxCnt不需要是实时的最大字母数。

```c++
class Solution {
public:
    int characterReplacement(string s, int k) {
        unordered_map<char, int> window;
        int res = 0;
        int l = 0, r = 0;
        char c, d;
        int maxCount = 0;
        while (r < s.size()) {
            c = s[r];
            ++r;
            ++window[c];
            maxCount = max(maxCount, window[c]);
            while (maxCount + k < r-l) {
                d = s[l];
                ++l;
                --window[d];
            }
            res = max(res, r-l);
        }
        return res;
    }
};
```

### 438. 找到字符串中所有字母异位词(Medium,based on 567) @hot100

给定一个字符串 s 和一个非空字符串 p，找到 s 中所有是 p 的字母异位词的子串，返回这些子串的起始索引。

字符串只包含小写英文字母，并且字符串 s 和 p 的长度都不超过 20100。

说明：

字母异位词指字母相同，但排列不同的字符串。
不考虑答案输出的顺序。
示例 1:

输入:
s: "cbaebabacd" p: "abc"

输出:
[0, 6]

解释:
起始索引等于 0 的子串是 "cba", 它是 "abc" 的字母异位词。
起始索引等于 6 的子串是 "bac", 它是 "abc" 的字母异位词。
 示例 2:

输入:
s: "abab" p: "ab"

输出:
[0, 1, 2]

解释:
起始索引等于 0 的子串是 "ab", 它是 "ab" 的字母异位词。
起始索引等于 1 的子串是 "ba", 它是 "ab" 的字母异位词。
起始索引等于 2 的子串是 "ab", 它是 "ab" 的字母异位词。

相当于，输入一个串 S，一个串 T，找到 S 中所有 T 的排列，返回它们的起始索引。

滑动窗口，参考力扣567题

```c++
class Solution {
public:
    vector<int> findAnagrams(string s, string p) {
        vector<int> res;
        unordered_map<char, int> need, window;
        for (char c : p) need[c]++;
        int l = 0, r = 0;
        int valid = 0;
        char ch;
        while (r < s.size()) {
            // 无脑算入右端点
            ch = s[r];
            if (need.count(ch)) { // 进入窗口的数据更新
                window[ch]++;
                if (need[ch] == window[ch]) {
                    valid++;
                }
            }
            // 右端点扩张
            r++;
            while (r - l >= p.size()) {
                // 缩小窗口
                // 先判断当前是否符合题解
                if (valid == need.size()) { // 窗口符合条件
                    res.push_back(l);
                }
                ch = s[l];
                if (need.count(ch)) { // 移出窗口的数据更新
                    if (window[ch] == need[ch]) {
                        valid--;
                    }
                    window[ch]--; // 得和进入窗口时反着来
                }
                l++;
            }
        }
        return res;
    }
};
```

hot100，用桶来算，比较直观，但while里的for循环可能有点超时，
时间
20 ms
击败
41.7%
内存
8.3 MB
击败
99.26%

```c++
class Solution {
public:
    vector<int> findAnagrams(string s, string p) {
        if (p.size() > s.size()) return {};
        int pos[128] = {0};
        for (auto &ch : p) {
            pos[ch]++;
        }
        int p_len = p.size();
        int len = s.size();
        int l = 0;
        int r = 0;
        while (r < p_len) {
            --pos[s[r]];
            ++r;
        }
        --r;
        vector<int> res;
        while (r < len) {
            bool is_same = true;
            for (int i = 0; i < 128; ++i) {
                if (pos[i] != 0) {
                    is_same = false;
                    break;
                }
            }
            if (is_same) {
                res.push_back(l);
            }
            ++l;
            ++r;
            ++pos[s[l-1]];
            --pos[s[r]];
        }
        return res;
    }
};
```

### 480. 滑动窗口中位数(Hard)

中位数是有序序列最中间的那个数。如果序列的大小是偶数，则没有最中间的数；此时中位数是最中间的两个数的平均数。

例如：

[2,3,4]，中位数是 3
[2,3]，中位数是 (2 + 3) / 2 = 2.5
给你一个数组 nums，有一个大小为 k 的窗口从最左端滑动到最右端。窗口中有 k 个数，每次窗口向右移动 1 位。你的任务是找出每次窗口移动后得到的新窗口中元素的中位数，并输出由它们组成的数组。

示例：

给出 nums = [1,3,-1,-3,5,3,6,7]，以及 k = 3。

窗口位置                      中位数
---------------               -----
[1  3  -1] -3  5  3  6  7       1
 1 [3  -1  -3] 5  3  6  7      -1
 1  3 [-1  -3  5] 3  6  7      -1
 1  3  -1 [-3  5  3] 6  7       3
 1  3  -1  -3 [5  3  6] 7       5
 1  3  -1  -3  5 [3  6  7]      6
 因此，返回该滑动窗口的中位数数组 [1,-1,-1,3,5,6]。

类似剑指的数据流中位数，或者用multiset

todo

### 567. 字符串的排列(Medium,based on 76)

给定两个字符串 s1 和 s2，写一个函数来判断 s2 是否包含 s1 的排列。

换句话说，第一个字符串的排列之一是第二个字符串的子串。

示例1:

输入: s1 = "ab" s2 = "eidbaooo"
输出: True
解释: s2 包含 s1 的排列之一 ("ba").

示例2:

输入: s1= "ab" s2 = "eidboaoo"
输出: False

注意：

输入的字符串只包含小写字母
两个字符串的长度都在 [1, 10,000] 之间

滑动窗口，相当给你一个 S 和一个 T，请问你 S 中是否存在一个子串，包含 T 中所有字符且不包含其他字符？

对于这道题的解法代码，基本上和力扣76题最小覆盖子串一模一样，只需要改变两个地方：

1、本题移动 left 缩小窗口的时机是窗口大小大于 t.size() 时，应为排列嘛，显然长度应该是一样的。

2、当发现 valid == need.size() 时，就说明窗口中就是一个合法的排列，所以立即返回 true。

至于如何处理窗口的扩大和缩小，和最小覆盖子串完全相同。

```c++
class Solution {
public:
    bool checkInclusion(string s1, string s2) {
        bool res = false;
        unordered_map<char, int> need, window;
        for (char c : s1) need[c]++;
        int l = 0, r = 0;
        int valid = 0;
        char ch;
        while (r < s2.size()) {
            ch = s2[r];
            ++r;
            if (need.count(ch)) {
                ++window[ch];
                if (window[ch] == need[ch]) {
                    ++valid;
                }
            }
            // 判断左侧窗口是否要收缩
            while (r - l >= s1.size()) { // 窗口大小大于s1时，肯定要收缩，因为排列肯定是长度一样的
                if (valid == need.size()) {
                    return true;
                }
                ch = s2[l];
                ++l;
                if (need.count(ch)) {
                    if (window[ch] == need[ch]) {
                        --valid;
                    }
                    --window[ch];
                }
            }
        }
        return res;
    }
};
```

### 643. 子数组最大平均数 I

给你一个由 n 个元素组成的整数数组 nums 和一个整数 k 。

请你找出平均数最大且 长度为 k 的连续子数组，并输出该最大平均数。

任何误差小于 10-5 的答案都将被视为正确答案。

```
示例 1：

输入：nums = [1,12,-5,-6,50,3], k = 4
输出：12.75
解释：最大平均数 (12-5-6+50)/4 = 51/4 = 12.75
示例 2：

输入：nums = [5], k = 1
输出：5.00000

提示：

n == nums.length
1 <= k <= n <= 105
-104 <= nums[i] <= 104
```

双指针，注意间隔

```c++
class Solution {
public:
    double findMaxAverage(vector<int>& nums, int k) {
        int n = nums.size();
        int max_sum = std::accumulate(nums.begin(), nums.begin() + k, 0);
        int cur_sum = max_sum;
        for (int i = 0, j = k; j < n;) {
            cur_sum = cur_sum + nums[j] - nums[i];
            max_sum = max(max_sum, cur_sum);
             ++i;
             ++j;
        }
        return (double)max_sum / k;
    }
};
```

### 978. 最长湍流子数组(Medium)

当 A 的子数组 A[i], A[i+1], ..., A[j] 满足下列条件时，我们称其为湍流子数组：

若 i <= k < j，当 k 为奇数时， A[k] > A[k+1]，且当 k 为偶数时，A[k] < A[k+1]；
或 若 i <= k < j，当 k 为偶数时，A[k] > A[k+1] ，且当 k 为奇数时， A[k] < A[k+1]。
也就是说，如果比较符号在子数组中的每个相邻元素对之间翻转，则该子数组是湍流子数组。

返回 A 的最大湍流子数组的长度。

示例 1：

输入：[9,4,2,10,7,8,8,1,9]
输出：5
解释：(A[1] > A[2] < A[3] > A[4] < A[5])
示例 2：

输入：[4,8,12,16]
输出：2
示例 3：

输入：[100]
输出：1

提示：

1 <= A.length <= 40000
0 <= A[i] <= 10^9

题解：

显然，我们只需要关注相邻两个数字之间的符号就可以了。 如果用 -1, 0, 1 代表比较符的话（分别对应 <、 =、 >），那么我们的目标就是在符号序列中找到一个最长的元素交替子序列 1, -1, 1, -1, ...（从 1 或者 -1 开始都可以）。

这些交替的比较符会形成若干个连续的块 。我们知道何时一个块会结束：当已经到符号序列末尾的时候或者当序列元素不再交替的时候。

举一个例子，假设给定数组为 A = [9,4,2,10,7,8,8,1,9]。那么符号序列就是 [1,1,-1,1,-1,0,-1,1]。它可以被划分成的块为 [1], [1,-1,1,-1], [0], [-1,1]。

算法

从左往右扫描这个数组，如果我们扫描到了一个块的末尾（不再交替或者符号序列已经结束），那么就记录下这个块的答案并将其作为一个候选答案，然后设置下一个元素（如果有的话）为下一个块的开头。

```c++
class Solution {
public:
    int compare(int a,int b){
        return (a>b) ? 1 : (a == b) ? 0 : -1;
    }
    int maxTurbulenceSize(vector<int>& A) {
        if (A.empty()) return 0;
        int l = 0, r = 1, res = 1;
        int flag;
        while (r < A.size()) {
            flag = compare(A[r-1], A[r]);
            if (r == A.size()-1 || flag*compare(A[r], A[r+1]) != -1) {
                if (flag != 0) res = max(res, r - l + 1);
                l = r;
            }
            ++r;
        }
        return res;
    }
};
```

### 992. K 个不同整数的子数组(Hard)

给定一个正整数数组 A，如果 A 的某个子数组中不同整数的个数恰好为 K，则称 A 的这个连续、不一定独立的子数组为好子数组。

（例如，[1,2,3,1,2] 中有 3 个不同的整数：1，2，以及 3。）

返回 A 中好子数组的数目。

示例 1：

输入：A = [1,2,1,2,3], K = 2
输出：7
解释：恰好由 2 个不同整数组成的子数组：[1,2], [2,1], [1,2], [2,3], [1,2,1], [2,1,2], [1,2,1,2].
示例 2：

输入：A = [1,2,1,3,4], K = 3
输出：3
解释：恰好由 3 个不同整数组成的子数组：[1,2,1,3], [2,1,3], [1,3,4].

提示：

1 <= A.length <= 20000
1 <= A[i] <= A.length
1 <= K <= A.length

这题需要还原左边界，感觉很巧

```c++
class Solution {
public:
    int subarraysWithKDistinct(vector<int>& A, int K) {
        unordered_map<int, int> window;
        int l = 0, r = 0;
        int res = 0;
        int c, d;
        int temp;
        while (r < A.size()) {
            c = A[r];
            ++r;
            ++window[c];
            while (window.size() > K) {
                d = A[l];
                ++l;
                --window[d];
                if (window[d] == 0) window.erase(d);
            }
            temp = l;
            while (window.size() == K) {
                ++res; // 当前连续子数组满足不同整数的个数恰好位K
                cout << "temp: " << l << ", r:" << r << endl;
                d = A[temp];
                ++temp;
                --window[d];
                if (window[d] == 0) window.erase(d);
            }
            while (temp > l) { //还原子数组
                ++window[A[temp-1]];
                --temp;
            }
        }
        return res;
    }
};
```

### 995. K 连续位的最小翻转次数(Hard)

在仅包含 0 和 1 的数组 A 中，一次 K 位翻转包括选择一个长度为 K 的（连续）子数组，同时将子数组中的每个 0 更改为 1，而每个 1 更改为 0。

返回所需的 K 位翻转的次数，以便数组没有值为 0 的元素。如果不可能，返回 -1。

示例 1：

输入：A = [0,1,0], K = 1
输出：2
解释：先翻转 A[0]，然后翻转 A[2]。
示例 2：

输入：A = [1,1,0], K = 2
输出：-1
解释：无论我们怎样翻转大小为 2 的子数组，我们都不能使数组变为 [1,1,1]。
示例 3：

输入：A = [0,0,0,1,0,1,1,0], K = 3
输出：3
解释：
翻转 A[0],A[1],A[2]: A变成 [1,1,1,1,0,1,1,0]
翻转 A[4],A[5],A[6]: A变成 [1,1,1,1,1,0,0,0]
翻转 A[5],A[6],A[7]: A变成 [1,1,1,1,1,1,1,1]

这题是真的难。。看到一个很巧的解法

题解：首先我们可以知道，对于每个位置而言，**只有初始状态和总共被反转了多少次决定了自己最终的状态**。另一方面，我们知道每一个长度为K的区间，最多只会被反转一次，因为两次反转后对最终结果没有影响。基于此，我们从前往后遍历数组，如果遇到一个0，我们将当前位置开始的长度为k区间的区间反转。如果遇到0时，剩下的区间长度不足K说明我们没有办法完成反转。但是如果我们每次反转当前区间时，将区间内每个数都取反，时间复杂度是O(n*k)的，这样是不够快的。因为我们需要优化一下，我们再考虑每个位置上的元素，**他只会被前面K - 1个元素是否被反转所影响**，所以我们只需要知道前面k - 1个元素总共反转了多少次(更进一步的说我们只关系反转次数的奇偶性)。

我们使用一个队列保存i前面k - 1个位置有多少元素被反转了。

如果队列长度为奇数，那么当前位置的1被变成0了需要反转，如果为偶数，说明当前位置的0还是0，需要反转。

如果最后k - 1个位置还有0的话说明失败。否则将i加入队列，更新答案。

时间复杂度：每个元素最多被进入队列和出队列一次，所以总的时间复杂度为O(n)O(n)的。

```c++
class Solution {
public:
    int minKBitFlips(vector<int>& A, int K) {
        int n = A.size();
        int res = 0;
        queue<int> q;
        for (int i = 0 ; i < n; i ++) {
            while (!q.empty() && q.front() + K <= i) q.pop();
            if (A[i] == q.size() % 2) {
                if(i + K > n) return -1;
                q.push(i);
                res ++;
            }
        }
        return res;
    }
};
```

### 1004. 最大连续1的个数 III(Medium,based on 1208)

给定一个由若干 0 和 1 组成的数组 A，我们最多可以将 K 个值从 0 变成 1 。

返回仅包含 1 的最长（连续）子数组的长度。

示例 1：

输入：A = [1,1,1,0,0,0,1,1,1,1,0], K = 2
输出：6
解释：
[1,1,1,0,0,1,1,1,1,1,1]
粗体数字从 0 翻转到 1，最长的子数组长度为 6。
示例 2：

输入：A = [0,0,1,1,0,0,1,1,1,0,1,1,0,0,0,1,1,1,1], K = 3
输出：10
解释：
[0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,1,1,1,1]
粗体数字从 0 翻转到 1，最长的子数组长度为 10。

提示：

1 <= A.length <= 20000
0 <= K <= A.length
A[i] 为 0 或 1

滑动窗口，其实就是对于1208的稍微修改，这题还是把它放在字符串专题吧，因为跟数字关系不大，0和1看成两个字符

```c++
class Solution {
public:
    int longestOnes(vector<int>& A, int K) {
        int l = 0, r = 0;
        int res = 0;
        int c;
        while (r < A.size()) {
            c = A[r];
            ++r;
            if (c == 0) --K;
            while (K < 0) {
                c = A[l];
                ++l;
                if (c == 0) ++K;
            }
            res = max(res, r-l);
        }
        return res;
    }
};
```

### 1052. 爱生气的书店老板

今天，书店老板有一家店打算试营业 customers.length 分钟。每分钟都有一些顾客（customers[i]）会进入书店，所有这些顾客都会在那一分钟结束后离开。

在某些时候，书店老板会生气。 如果书店老板在第 i 分钟生气，那么 grumpy[i] = 1，否则 grumpy[i] = 0。 当书店老板生气时，那一分钟的顾客就会不满意，不生气则他们是满意的。

书店老板知道一个秘密技巧，能抑制自己的情绪，可以让自己连续 X 分钟不生气，但却只能使用一次。

请你返回这一天营业下来，最多有多少客户能够感到满意的数量。

示例：

输入：customers = [1,0,1,2,1,1,7,5], grumpy = [0,1,0,1,0,1,0,1], X = 3
输出：16
解释：
书店老板在最后 3 分钟保持冷静。
感到满意的最大客户数量 = 1 + 1 + 1 + 1 + 7 + 5 = 16.

提示：

1 <= X <= customers.length == grumpy.length <= 20000
0 <= customers[i] <= 1000
0 <= grumpy[i] <= 1

维护一个长度为X的窗口，只需要一次遍历，每次遍历要计算总顾客数量以及不满意的数量，并且更新当前最大能挽救的顾客数量，最后做个简单的运算即可

```c++
class Solution {
public:
    int maxSatisfied(vector<int>& customers, vector<int>& grumpy, int X) {
        if (customers.empty() || grumpy.empty()) return 0;
        int res = 0;
        int total = 0; // 总顾客数量
        int unsatisfied = 0; // 若不挽救，总共有多少个顾客不满意
        int max_save_cnt = 0; // 最多能挽救多少个顾客
        int save_cnt = 0; // 当前窗口能挽救多少个顾客
        for (int i = 0; i < customers.size(); ++i) {
            total += customers[i];
            if (grumpy[i] == 1) {
                unsatisfied += customers[i];
                save_cnt += customers[i];
            }
            if (i - X >= 0 && grumpy[i-X] == 1) {
                save_cnt -= customers[i-X];
            }
            max_save_cnt = max(max_save_cnt, save_cnt);
        }
        res = total - unsatisfied + max_save_cnt;
        return res;
    }
};
```

### 1081. 不同字符的最小子序列

同力扣316题

### 1208. 尽可能使字符串相等(Medium)

给你两个长度相同的字符串，s 和 t。

将 s 中的第 i 个字符变到 t 中的第 i 个字符需要 |s[i] - t[i]| 的开销（开销可能为 0），也就是两个字符的 ASCII 码值的差的绝对值。

用于变更字符串的最大预算是 maxCost。在转化字符串时，总开销应当小于等于该预算，这也意味着字符串的转化可能是不完全的。

如果你可以将 s 的子字符串转化为它在 t 中对应的子字符串，则返回可以转化的最大长度。

如果 s 中没有子字符串可以转化成 t 中对应的子字符串，则返回 0。

示例 1：

输入：s = "abcd", t = "bcdf", cost = 3
输出：3
解释：s 中的 "abc" 可以变为 "bcd"。开销为 3，所以最大长度为 3。
示例 2：

输入：s = "abcd", t = "cdef", cost = 3
输出：1
解释：s 中的任一字符要想变成 t 中对应的字符，其开销都是 2。因此，最大长度为 1。
示例 3：

输入：s = "abcd", t = "acde", cost = 0
输出：1
解释：你无法作出任何改动，所以最大长度为 1。

提示：

1 <= s.length, t.length <= 10^5
0 <= maxCost <= 10^6
s 和 t 都只含小写英文字母。

这题看着很麻烦，但是可以直接用**滑动窗口**一把梭

```c++
class Solution {
public:
    int equalSubstring(string s, string t, int maxCost) {
        int l = 0, r = 0;
        int res = 0;
        int cost = 0;
        char c, d;
        while (r < s.size()) {
            c = s[r], d = t[r];
            ++r;
            cost += abs(c-d);
            while (cost > maxCost) {
                c = s[l], d = t[l];
                ++l;
                cost -= abs(c-d);
            }
            res = max(res, r-l);
        }
        return res;
    }
};
```

### 1004. 最大连续1的个数 III

medium

给定一个二进制数组 nums 和一个整数 k，如果可以翻转最多 k 个 0 ，则返回 数组中连续 1 的最大个数 。

```
示例 1：

输入：nums = [1,1,1,0,0,0,1,1,1,1,0], K = 2
输出：6
解释：[1,1,1,0,0,1,1,1,1,1,1]
粗体数字从 0 翻转到 1，最长的子数组长度为 6。
示例 2：

输入：nums = [0,0,1,1,0,0,1,1,1,0,1,1,0,0,0,1,1,1,1], K = 3
输出：10
解释：[0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,1,1,1,1]
粗体数字从 0 翻转到 1，最长的子数组长度为 10。
 

提示：

1 <= nums.length <= 105
nums[i] 不是 0 就是 1
0 <= k <= nums.length
```

hot75刷到的，因为在滑动窗口章节里，自然想到用滑动窗口来做，最开始想的方法就是要去记录翻转的次数，还要考虑k为0的特殊情况，虽然AC，但挺丑陋的，不推荐

```c++
class Solution {
public:
    int longestOnes(vector<int>& nums, int k) {
        if (nums.empty()) return 0;
        int ans = 0;
        int n = nums.size();
        int l = 0; // 滑动窗口的左边界
        int r = 0; // 滑动窗口的右边界
        if (k == 0) {
            while (l < n && nums[l] == 0) ++l;
            if (l == n) return 0;
            r = l;
        }
        int reverse = 0; // 滑动窗口内的翻转次数
        while (r < n) {
            while (r < n && (nums[r] == 1 || reverse < k)) {
                if (nums[r] == 0 && reverse < k) ++reverse; // 翻转
                ++r;
            }
            ans = max(ans, r-l);
            if (r == n) return ans;
            while (l < r && (nums[l] == 1 || reverse > 0)) {
                if (nums[l] == 0 && reverse > 0) {
                    --reverse; // 恢复翻转次数
                    ++l;
                    break; // 继续尝试扩展右边界
                }
                ++l;
            }
            if (l == r) {
                ++l;
                ++r;
            }
        }
        return ans;
    }
};
```

看了官方题解，简洁很多，思路：

1. 因为只含0、1，把0反过来用1表示，那么滑动窗口内的0就可以两个“反”前缀和之差来表示，很巧妙！    
1. 滑动窗口：先尝试扩大右边界，直到不合法，再收缩左边界，这样也能解决k=0和初始值的问题

```c++
class Solution {
public:
    int longestOnes(vector<int>& nums, int k) {
        if (nums.empty()) return 0;
        int ans = 0;
        int n = nums.size();
        int l = 0; // 滑动窗口的左边界
        int r = 0; // 滑动窗口的右边界
        int lsum = 1 - nums[l]; // 0到l的前缀和
        int rsum = 1 - nums[r]; // 0到r的前缀和
        for (;r < n; ++r) {
            rsum += 1 - nums[r]; // 右边界不断扩展，直到不合法
            while (lsum < rsum - k) { // 目前不合法，需要收缩左边界
                lsum += 1 - nums[l];
                ++l;
            }
            ans = max(ans, r - l + 1);
        }
        return ans;
    }
};
```

### 1456. 定长子串中元音的最大数目

给你字符串 s 和整数 k 。

请返回字符串 s 中长度为 k 的单个子字符串中可能包含的最大元音字母数。

英文中的 元音字母 为（a, e, i, o, u）。

```
示例 1：

输入：s = "abciiidef", k = 3
输出：3
解释：子字符串 "iii" 包含 3 个元音字母。
示例 2：

输入：s = "aeiou", k = 2
输出：2
解释：任意长度为 2 的子字符串都包含 2 个元音字母。
示例 3：

输入：s = "leetcode", k = 3
输出：2
解释："lee"、"eet" 和 "ode" 都包含 2 个元音字母。
示例 4：

输入：s = "rhythms", k = 4
输出：0
解释：字符串 s 中不含任何元音字母。
示例 5：

输入：s = "tryhard", k = 4
输出：1
 

提示：

1 <= s.length <= 10^5
s 由小写英文字母组成
1 <= k <= s.length
```

典型的滑动窗口，easy秒了

```c++
class Solution {
public:
    bool isVowel(char &ch) {
        return ch == 'a' || ch == 'e' || ch == 'i' || ch == 'o' || ch == 'u';
    }
    int maxVowels(string s, int k) {
        if (k < 1 || s.empty()) return 0;
        int n = s.length();
        int cur_cnt = 0;
        for (int i = 0; i < k; ++i) {
            if (isVowel(s[i])) ++cur_cnt;
        }
        int max_cnt = cur_cnt;
        for (int i = k; i < n; ++i) {
            if (isVowel(s[i])) ++cur_cnt;
            if (isVowel(s[i-k])) --cur_cnt;
            max_cnt = max(max_cnt, cur_cnt);
        }
        return max_cnt;
    }
};
```

### 1493. 删掉一个元素以后全为 1 的最长子数组

medium

给你一个二进制数组 nums ，你需要从中删掉一个元素。

请你在删掉元素的结果数组中，返回最长的且只包含 1 的非空子数组的长度。

如果不存在这样的子数组，请返回 0 。

```
提示 1：

输入：nums = [1,1,0,1]
输出：3
解释：删掉位置 2 的数后，[1,1,1] 包含 3 个 1 。
示例 2：

输入：nums = [0,1,1,1,0,1,1,0,1]
输出：5
解释：删掉位置 4 的数字后，[0,1,1,1,1,1,0,1] 的最长全 1 子数组为 [1,1,1,1,1] 。
示例 3：

输入：nums = [1,1,1]
输出：2
解释：你必须要删除一个元素。
 

提示：

1 <= nums.length <= 105
nums[i] 要么是 0 要么是 1 。
```

```c++
class Solution {
public:
    int longestSubarray(vector<int>& nums) {
        if (nums.empty() || nums.size() == 1) return 0;
        int l = 0;
        int n = nums.size();
        int ans = 0;
        int del = -1;
        for (int r = 0; r < n; ++r) {
            if (nums[r] == 0) {
                if (del != -1) l = del + 1; // 收缩左区间
                del = r; // 记录删除序号
            }
            ans = max(ans, r - l);
        }
        return ans;
    }
};
```

完全是1004的特殊case，同样的代码，带入k=1以及ans最后-1即可ac

```c++
class Solution {
public:
    int longestSubarray(vector<int>& nums) {
        int k = 1;
        if (nums.empty()) return 0;
        int ans = 0;
        int n = nums.size();
        int l = 0; // 滑动窗口的左边界
        int r = 0; // 滑动窗口的右边界
        int lsum = 1 - nums[l]; // 0到l的前缀和
        int rsum = 1 - nums[r]; // 0到r的前缀和
        for (;r < n; ++r) {
            rsum += 1 - nums[r]; // 右边界不断扩展，直到不合法
            while (lsum < rsum - k) { // 目前不合法，需要收缩左边界
                lsum += 1 - nums[l];
                ++l;
            }
            ans = max(ans, r - l + 1);
        }
        return ans-1; // 因为求的是删除了0的子序列长度
    }
};
```

自己在刷hot75时没有用上面这套代码，也不错，而且在收缩左区间时还加速了

```c++
class Solution {
public:
    int longestSubarray(vector<int>& nums) {
        if (nums.empty() || nums.size() == 1) return 0;
        int l = 0;
        int n = nums.size();
        int ans = 0;
        int del = -1;
        for (int r = 0; r < n; ++r) {
            if (nums[r] == 0) {
                if (del != -1) l = del + 1; // 收缩左区间
                del = r; // 记录删除序号
            }
            ans = max(ans, r - l);
        }
        return ans;
    }
};
```

## 链表

一定要画图！

### 2.两数相加(Medium) @hot100

给出两个 非空 的链表用来表示两个非负的整数。其中，它们各自的位数是按照 逆序 的方式存储的，并且它们的每个节点只能存储 一位 数字。

如果，我们将这两个数相加起来，则会返回一个新的链表来表示它们的和。

您可以假设除了数字 0 之外，这两个数都不会以 0 开头。

示例：

输入：(2 -> 4 -> 3) + (5 -> 6 -> 4)
输出：7 -> 0 -> 8
原因：342 + 465 = 807

第一次尝试，还行

```c++
class Solution {
public:
    ListNode* addTwoNumbers(ListNode* l1, ListNode* l2) {
        ListNode* dummy = new ListNode(-1);
        ListNode* pre = dummy;
        ListNode* cur;
        int carry = 0;
        int tmp = 0;
        while (l1 && l2) {
            tmp = l1->val + l2->val + carry;
            if (tmp >= 10) carry = 1;
            else carry = 0;
            tmp %= 10;
            cur = new ListNode(tmp);
            pre->next = cur;
            pre = cur;
            l1 = l1->next;
            l2 = l2->next;
        }
        while (l1) {
            tmp = l1->val + carry;
            if (tmp >= 10) carry = 1;
            else carry = 0;
            tmp %= 10;
            cur = new ListNode(tmp);
            pre->next = cur;
            pre = cur;
            l1 = l1->next;
        }
        while (l2) {
            tmp = l2->val + carry;
            if (tmp >= 10) carry = 1;
            else carry = 0;
            tmp %= 10;
            cur = new ListNode(tmp);
            pre->next = cur;
            pre = cur;
            l2 = l2->next;
        }
        if (carry == 1) {
            cur = new ListNode(1);
            pre->next = cur;
        }
        return dummy->next;
    }
};
```

是这个思路没错，但是其实可以省略为一个while循环，如果l1或l2为空，补0即可

```c++
class Solution {
public:
    ListNode* addTwoNumbers(ListNode* l1, ListNode* l2) {
        ListNode* dummy = new ListNode(-1);
        ListNode* pre = dummy;
        ListNode* cur;
        int carry = 0;
        int tmp = 0;
        while (l1 || l2) {
            tmp = (l1 != nullptr ? l1->val : 0) +
                    (l2 != nullptr ? l2->val : 0) + carry;
            if (tmp >= 10) carry = 1;
            else carry = 0;
            tmp %= 10;
            cur = new ListNode(tmp);
            pre->next = cur;
            pre = cur;
            l1 = l1 != nullptr ? l1->next : nullptr;
            l2 = l2 != nullptr ? l2->next : nullptr;
        }
        if (carry == 1) {
            cur = new ListNode(1);
            pre->next = cur;
        }
        return dummy->next;
    }
};
```

### 19.删除链表的倒数第N个节点(easy) @hot100

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
        ListNode *toBeDeleted = slow->next;
        slow->next = slow->next->next;
        delete toBeDeleted;
        ListNode *newHead = dummy->next;
        delete dummy;
        return newHead;
    }
};
```

### 21.合并两个有序链表 @hot100

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
        ListNode *res = dummy->next;
        delete dummy; // 别忘了删除哑结点！！！
        return res;
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

### 23. 合并k个有序链表 @hot100

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
时间
16 ms
击败
95.28%
内存
13 MB
击败
55.65%

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

### 24. 两两交换链表中的节点(medium) @hot100

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

刷hot100，这种比较好理解

```c++
class Solution {
public:
    ListNode* swapPairs(ListNode* head) {
        if (!head || !head->next) return head;
        ListNode *dummy = new ListNode();
        dummy->next = head;
        ListNode *pre = dummy;
        ListNode *cur = dummy->next;
        while (cur && cur->next) {
            ListNode *cur_next = cur->next;
            ListNode *cur_next_next = cur->next->next;
            pre->next = cur_next;
            cur_next->next = cur;
            cur->next = cur_next_next; // 防止断链
            // 前进两个节点
            pre = pre->next->next; // cur已交换，用pre来前进不容易出错
            cur = pre->next;
        }
        ListNode *new_head = dummy->next;
        delete dummy;
        return new_head;
    }
};
```

### 25. K 个一组翻转链表(Hard) @hot100

给你一个链表，每 k 个节点一组进行翻转，请你返回翻转后的链表。

k 是一个正整数，它的值小于或等于链表的长度。

如果节点总数不是 k 的整数倍，那么请将最后剩余的节点保持原有顺序。

示例：

给你这个链表：1->2->3->4->5

当 k = 2 时，应当返回: 2->1->4->3->5

当 k = 3 时，应当返回: 3->2->1->4->5

说明：

你的算法只能使用常数的额外空间。
你不能只是单纯的改变节点内部的值，而是需要实际进行节点交换。

[官方题解](https://leetcode-cn.com/problems/reverse-nodes-in-k-group/solution/k-ge-yi-zu-fan-zhuan-lian-biao-by-leetcode-solutio/)

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
    ListNode* reverseKGroup(ListNode* head, int k) {
        ListNode* cur = head;
        ListNode* dummy = new ListNode(-1);
        dummy->next = head;
        ListNode* pre = dummy; // dummy节点是上一组的尾节点
        ListNode* tail;
        while(cur != nullptr){
            tail = pre; // 上一组的尾节点
            for (int i = 0; i < k; ++i) {
                tail = tail->next;
                if(!tail) {
                    return dummy->next;
                }
            }
            ListNode* next = tail->next; // 下一组的头节点
            pair<ListNode*, ListNode*> pair = myReverse(cur, tail);
            pre->next = pair.first; // 拼接回原链表
            pair.second->next = next; // 拼接回原链表
            pre = pair.second;
            cur = pair.second->next; // 下一组的头结点
        }
        return dummy->next;
    }

    // 翻转一个子链表，并且返回新的头与尾
    pair<ListNode*, ListNode*> myReverse(ListNode* head, ListNode* tail) {
        ListNode* prev = tail->next;
        ListNode* p = head;
        while (prev != tail) {
            ListNode* nex = p->next;
            p->next = prev;
            prev = p;
            p = nex;
        }
        return {tail, head};
    }
};
```

刷hot100时，没有想到这么优雅的，每次遍历都反转，然后再去判断最后的是否需要恢复，但没有AC(48 / 62 个通过的测试用例)，败在了[1,2], 2的输入上

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode() : val(0), next(nullptr) {}
 *     ListNode(int x) : val(x), next(nullptr) {}
 *     ListNode(int x, ListNode *next) : val(x), next(next) {}
 * };
 */
class Solution {
public:
    ListNode *reverseKGroup(ListNode *head, int k) {
    if (!head || !head->next || k == 1)
        return head;
    ListNode *dummy = new ListNode(-1);
    dummy->next = head;
    ListNode *last_tail = dummy;
    ListNode *tmp_head = head;
    ListNode *pre = tmp_head;
    ListNode *cur = pre->next;
    int cnt = k;
    while (cur) {
        --cnt;
        if (cnt == 0) {
        // 此时cur到达下一头结点，pre到达当前尾节点
        last_tail->next = pre;
        tmp_head->next = cur;
        // 更新
        last_tail = tmp_head;
        tmp_head = cur;
        pre = tmp_head;
        cur = tmp_head->next;
        cnt = k;
        } else {
        // 翻转并前进
        ListNode *tmp = cur->next;
        cur->next = pre;
        pre = cur;
        cur = tmp;
        }
    }
    if (cnt != k) {
        // 说明最后剩余节点被逆转了，反转回来
        cur = pre->next;
        pre->next = nullptr; // 尾节点后面置空
        while (tmp_head != cur) {
        ListNode *tmp = cur->next;
        cur->next = pre;
        pre = cur;
        cur = tmp;
        }
    }
    ListNode *new_head = dummy->next;
    delete dummy;
    return new_head;
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

### 138. 复制带随机指针的链表(medium) @hot100

给你一个长度为 n 的链表，每个节点包含一个额外增加的随机指针 random ，该指针可以指向链表中的任何节点或空节点。

构造这个链表的 深拷贝。 深拷贝应该正好由 n 个 全新 节点组成，其中每个新节点的值都设为其对应的原节点的值。新节点的 next 指针和 random 指针也都应指向复制链表中的新节点，并使原链表和复制链表中的这些指针能够表示相同的链表状态。复制链表中的指针都不应指向原链表中的节点 。

例如，如果原链表中有 X 和 Y 两个节点，其中 X.random --> Y 。那么在复制链表中对应的两个节点 x 和 y ，同样有 x.random --> y 。

返回复制链表的头节点。

用一个由 n 个节点组成的链表来表示输入/输出中的链表。每个节点用一个 [val, random_index] 表示：

val：一个表示 Node.val 的整数。
random_index：随机指针指向的节点索引（范围从 0 到 n-1）；如果不指向任何节点，则为  null 。
你的代码 只 接受原链表的头节点 head 作为传入参数。

自己想的思路：首先构造链表，然后想办法构造random指针，想到了哈希表，key是指针，value是当前节点的偏移量，两个链表指针无法比较，但是偏移量是一致的，额外空间复杂度O(n)，时间复杂度O(1)

时间
12 ms
击败
33.64%
内存
11.1 MB
击败
38.97%

```c++
class Solution {
public:
    Node* copyRandomList(Node* head) {
        if (!head) return nullptr;
        unordered_map<Node*, int> hash; // 老链表对应的offset
        vector<Node*> vec; // 新链表数组存储
        Node *cur = head;
        Node *new_head = new Node(head->val);
        Node *new_cur = new_head;
        int offset = 0;
        while (cur) {
            hash[cur] = offset;
            vec.push_back(new_cur);
            ++offset;
            cur = cur->next;
            if (cur) {
                new_cur->next = new Node(cur->val);
                new_cur = new_cur->next;
            }
        }
        unordered_map<int, vector<int>> map; // 第offset(int)个，被xxx(vector<int>)指向
        offset  = 0;
        cur = head;
        while (cur) {
            if (cur->random) {
                int target_offset = hash[cur->random];
                map[target_offset].push_back(offset);
            }
            ++offset;
            cur = cur->next;
        }
        for (auto it = map.begin(); it != map.end(); ++it) {
            for (int i = 0; i < it->second.size(); ++i) {
                vec[it->second[i]]->random = vec[it->first];
            }
        }
        return new_head;
    }
};
```

看了官方题解，有更优雅的做法，空间复杂度O(1)，时间复杂度O(n)，总共只需要三次遍历！

我们首先将该链表中每一个节点拆分为两个相连的节点，例如对于链表 A→B→C，拆分成A->A'->B->B'->C->C'，其中X'即为待生成的深拷贝链表，这样，每个原节点X的随机指针所指向的节点Y，其后继节点Y'一定是X'的随机指针指向的，非常巧妙！最后分离两个链表即可，注意需要处理随机指针为空的情况
时间
4 ms
击败
97.87%
内存
11.1 MB
击败
35.74%

```c++
/*
// Definition for a Node.
class Node {
public:
    int val;
    Node* next;
    Node* random;
    
    Node(int _val) {
        val = _val;
        next = NULL;
        random = NULL;
    }
};
*/

class Solution {
public:
    Node* copyRandomList(Node* head) {
        if (!head) return nullptr;
        for (Node *cur = head; cur != nullptr; cur = cur->next->next) {
            Node *nodeNew = new Node(cur->val);
            nodeNew->next = cur->next;
            cur->next = nodeNew;
        }
        for (Node *cur = head; cur != nullptr; cur = cur->next->next) {
            if (cur->random) {
                cur->next->random = cur->random->next;
            }
        }
        Node *new_head = head->next;
        for (Node *cur = head; cur != nullptr; cur = cur->next) { // 注意这里缩短了步进
            Node *copied_cur = cur->next;
            Node *next_cur = cur->next->next;
            cur->next = next_cur;
            if (!next_cur) {
                break;
            }
            copied_cur->next = next_cur->next;
        }
        return new_head;
    }
};
```

### 141.环形链表(easy) @hot100

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

二刷，还没上个简洁，记住，while循环里面不用判断slow是否为空，如果链表没环，肯定是fast先到尾

### 142. 环形链表 II(mdium) @hot100

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

刷hot100，更加优雅了，用纸币画一下很快就能找到规律

```c++
class Solution {
public:
    ListNode *detectCycle(ListNode *head) {
        if (!head) return head;
        ListNode *slow = head;
        ListNode *fast = head;
        while (fast && fast->next) {
            slow = slow->next;
            fast = fast->next->next;
            if (slow == fast) {
                break;
            }
        }
        if (!fast || !fast->next) {
            return nullptr;
        }
        // 有环，此时slow==fast
        slow = head;
        while (slow != fast)  {
            slow = slow->next;
            fast = fast->next; // fast降低步长，与slow的新交点即为环的入口
        }
        return slow;
    }
};
```

### 143. 重排链表(Medium)

给定一个单链表 L：L0→L1→…→Ln-1→Ln ，
将其重新排列后变为： L0→Ln→L1→Ln-1→L2→Ln-2→…

你不能只是单纯的改变节点内部的值，而是需要实际的进行节点交换。

示例 1:

给定链表 1->2->3->4, 重新排列为 1->4->2->3.
示例 2:

给定链表 1->2->3->4->5, 重新排列为 1->5->2->4->3.

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode() : val(0), next(nullptr) {}
 *     ListNode(int x) : val(x), next(nullptr) {}
 *     ListNode(int x, ListNode *next) : val(x), next(next) {}
 * };
 */
class Solution {
public:
    void reorderList(ListNode* head) {
        if (!head) return;
        ListNode* cur = head;
        ListNode* rev = nullptr;
        ListNode* next;
        ListNode* rev_next;
        int len = 0;
        while (cur) {
            rev_next = new ListNode(cur->val, rev);
            cur = cur->next;
            rev = rev_next;
            ++len;
        }
        // 此时rev指向反转的头部
        cur = head;
        int k = len / 2;
        while (k--) {
            next = cur->next; // 保存，防止断链
            rev_next = rev->next; // 保存，防止断链
            cur->next = rev;
            if (k==0 && (len & 1) == 0) rev->next = nullptr; // 偶数长度，则最后一个元素是反转链表的
            else rev->next = next;
            cur = next;
            rev = rev_next;
            if (k == 0 && (len & 1) == 1) cur->next = nullptr; // 奇数长度，则最后一个元素是原链表的
        }
        // TODO：有内存泄漏问题
    }
};
```

### 148. 排序链表(medium) @hot100

在 O(n log n) 时间复杂度和常数级空间复杂度下，对链表进行排序。

示例 1:

输入: 4->2->1->3
输出: 1->2->3->4
示例 2:

输入: -1->5->3->4->0
输出: -1->0->3->4->5

若不要求常数级空间复杂度，可以使用std::multimap来解决，但这样不符合题意

```c++
class Solution {
public:
    ListNode* sortList(ListNode* head) {
        if (!head || !head->next) return head;
        std::multimap<int, ListNode*> hash;
        ListNode *cur = head;
        while (cur) {
            hash.insert(pair<int, ListNode*>(cur->val, cur));
            cur = cur->next;;
        }
        ListNode *dummy = new ListNode();
        ListNode *pre = dummy;
        for (const auto &p : hash) {
            pre->next = p.second;
            pre = p.second;
        }
        pre->next = nullptr;
        ListNode *new_head = dummy->next;
        delete dummy;
        return new_head;
    }
};
```

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

刷hot100时，也想到了快排，不过快排需要递归，仍然需要O(logn)的栈空间，并且在一个大输入面前超时了，不过感觉我这种写法比y总的更容易记

```c++
class Solution {
public:
    ListNode* sortList(ListNode* head) {
        return innerSortList(head, nullptr);
    }

    // 对[head, tail)区间里的链表节点进行排序，返回头节点，并且确保这个子链表最后指向tail节点
    ListNode* innerSortList(ListNode *head, ListNode *tail) {
        if (!head || !head->next || head == tail) return head;
        ListNode *pivot = head;
        ListNode *new_head = head;
        ListNode *pre = head;
        ListNode *cur = head->next;
        while (cur && cur != tail) {
            if (cur->val < pivot->val) {
                pre->next = cur->next;
                cur->next = new_head;
                new_head = cur;
                cur = pre->next;
            } else {
                pre = cur;
                cur = cur->next;
            }
        }
        new_head = innerSortList(new_head, pivot);
        pivot->next = innerSortList(pivot->next, tail);
        return new_head;
    }
};
```

归并排序的时间复杂度也只需要O(nlogn)，用迭代方式可以实现额外空间复杂度为O(1)，此时是（从底至顶直接合并）

TODO

### 160. 相交链表(easy) @hot100

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
        // 跳出循环有两种情况，找到交点了，或者没有交点，到达末尾的nullptr，两者会同时到达nullptr的，所以仍然可以用p != q判断
        // 为nullptr，则说明不相交，输出nullptr，否则输出相交节点
        return p;
    }
};
```

二刷，想到了双指针，但是实现代码时还是多此一举地把长度计算出来，y总

### 206.反转链表(easy) @hot100

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
        return p; // 不会断链，因为返回的是p，p还是原来指向的顺序
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

hot75时三刷，也用了一个辅助函数，纯粹为了递归而递归

```c++
class Solution {
    ListNode *new_head;
public:
    ListNode* reverseList(ListNode* head) {
        if (!head) return nullptr;
        ListNode* tail = helper(head);
        tail->next = nullptr; // 去除 死循环
        return new_head;
    }
    ListNode *helper(ListNode *head) {
        if (!head->next) {
            new_head = head;
            return head;
        }
        helper(head->next)->next = head; // 翻转后头变成尾
        return head;
    }
};
```

### 234.回文链表(easy) @hot100

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

刷hot100时想到了类似快慢指针的比较，不过多了一次遍历取size的操作，上面方法巧在使用快慢指针一次遍历即可定位中点

```c++
class Solution {
public:
    bool isPalindrome(ListNode* head) {
        if (!head) return false;
        if (!head->next) return true;
        ListNode *cur = head;
        int len = 0;
        while (cur) {
            cur = cur->next;
            ++len;
        }
        int step = len / 2;
        cur = head;
        while (step-- > 1) {
            cur = cur->next;
        }
        ListNode *right_head = cur->next;
        if (len % 2 == 1) {
            right_head = right_head->next;
        }
        cur->next = nullptr;
        ListNode *left_head = reverse(head);
        while (left_head && right_head) {
            if (left_head->val != right_head->val) {
                return false;
            }
            left_head = left_head->next;
            right_head = right_head->next;
        }
        return true;
    }
    
    //  return new head
    ListNode* reverse(ListNode* head) {
        if (!head || !head->next) return head;
        ListNode *pre = nullptr;
        ListNode *cur = head;
        while (cur) {
            ListNode *next = cur->next;
            cur->next = pre;
            pre = cur;
            cur = next;
        }
        return pre;
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

### 328. 奇偶链表

medium

给定单链表的头节点 head ，将所有索引为奇数的节点和索引为偶数的节点分别组合在一起，然后返回重新排序的列表。

第一个节点的索引被认为是 奇数 ， 第二个节点的索引为 偶数 ，以此类推。

请注意，偶数组和奇数组内部的相对顺序应该与输入时保持一致。

你必须在 O(1) 的额外空间复杂度和 O(n) 的时间复杂度下解决这个问题。

```

示例 1:

输入: head = [1,2,3,4,5]
输出: [1,3,5,2,4]
示例 2:



输入: head = [2,1,3,5,6,4,7]
输出: [2,3,6,7,1,5,4]
 

提示:

n ==  链表中的节点数
0 <= n <= 104
-106 <= Node.val <= 106
```

没啥好说的，双指针遍历，同样要注意奇偶情况，还要把odd_tail和even_head连接起来

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode() : val(0), next(nullptr) {}
 *     ListNode(int x) : val(x), next(nullptr) {}
 *     ListNode(int x, ListNode *next) : val(x), next(next) {}
 * };
 */
class Solution {
public:
    ListNode* oddEvenList(ListNode* head) {
        if (!head || !head->next) return head;
        ListNode* odd = head;
        ListNode* odd_tail = head;
        ListNode* even = head->next;
        ListNode* even_head = head->next;
        while (odd && even) {
            odd_tail = odd;
            odd->next = even->next;
            if (even->next) even->next = even->next->next;
            odd = odd->next;
            even = even->next;
        }
        if (odd) {
            odd_tail = odd;
        }
        odd_tail->next = even_head;
        return head;
    }
};
```

### 2095. 删除链表的中间节点

medium

给你一个链表的头节点 head 。删除 链表的 中间节点 ，并返回修改后的链表的头节点 head 。

长度为 n 链表的中间节点是从头数起第 ⌊n / 2⌋ 个节点（下标从 0 开始），其中 ⌊x⌋ 表示小于或等于 x 的最大整数。

对于 n = 1、2、3、4 和 5 的情况，中间节点的下标分别是 0、1、1、2 和 2 。
 
```
示例 1：

输入：head = [1,3,4,7,1,2,6]
输出：[1,3,4,1,2,6]
解释：
上图表示给出的链表。节点的下标分别标注在每个节点的下方。
由于 n = 7 ，值为 7 的节点 3 是中间节点，用红色标注。
返回结果为移除节点后的新链表。 
示例 2：



输入：head = [1,2,3,4]
输出：[1,2,4]
解释：
上图表示给出的链表。
对于 n = 4 ，值为 3 的节点 2 是中间节点，用红色标注。
示例 3：



输入：head = [2,1]
输出：[2]
解释：
上图表示给出的链表。
对于 n = 2 ，值为 1 的节点 1 是中间节点，用红色标注。
值为 2 的节点 0 是移除节点 1 后剩下的唯一一个节点。
 

提示：

链表中节点的数目在范围 [1, 105] 内
1 <= Node.val <= 105
```


快慢指针，注意边界情况，按照思维定式用了dummy节点，其实后面发现不用dummy更方便

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode() : val(0), next(nullptr) {}
 *     ListNode(int x) : val(x), next(nullptr) {}
 *     ListNode(int x, ListNode *next) : val(x), next(next) {}
 * };
 */
class Solution {
public:
    ListNode* deleteMiddle(ListNode* head) {
        if (!head || !(head->next)) return nullptr;
        // 快慢指针，先画图，发现增加一个dummy节点更方便
        // 而且当链表长度为偶数时，当快指针指向最后一个节点，此时慢指针指向中间节点前一个节点
        // 为奇数时，快指针会指向最后一个节点后面一个不存在的节点，此时慢指针正好指向中间节点
        ListNode *dummy = new ListNode(-1);
        dummy->next = head;
        ListNode *slow = head;
        ListNode *fast = head->next;
        ListNode *slow_pre = dummy;
        while (fast && fast->next) {
            slow_pre = slow;
            slow = slow->next;
            fast = fast->next->next;a
        }
        if (!fast) {
            // 奇数情况
            slow_pre->next = slow->next;
            delete slow;
        } else {
            // 偶数情况
            ListNode *mid = slow->next;
            slow->next = mid->next;
            delete mid;
        }
        ListNode *new_head = dummy->next;
        delete dummy;
        return new_head;
    }
};
```

后来看了题解，其实不用dummy更方便。。。看来以后碰到链表的题目还是要先画图

```c++
class Solution {
public:
    ListNode* deleteMiddle(ListNode* head) {
        if (!head || !(head->next)) return nullptr;
        ListNode *slow = head;
        ListNode *fast = head;
        ListNode *slow_pre = head;
        while (fast && fast->next) {
            slow_pre = slow;
            slow = slow->next;
            fast = fast->next->next;
        }
        slow_pre->next = slow->next;
        delete slow;
        return head;
    }
};
```

### 2130. 链表最大孪生和

在一个大小为 n 且 n 为 偶数 的链表中，对于 0 <= i <= (n / 2) - 1 的 i ，第 i 个节点（下标从 0 开始）的孪生节点为第 (n-1-i) 个节点 。

比方说，n = 4 那么节点 0 是节点 3 的孪生节点，节点 1 是节点 2 的孪生节点。这是长度为 n = 4 的链表中所有的孪生节点。
孪生和 定义为一个节点和它孪生节点两者值之和。

给你一个长度为偶数的链表的头节点 head ，请你返回链表的 最大孪生和 。

```
示例 1：

输入：head = [5,4,2,1]
输出：6
解释：
节点 0 和节点 1 分别是节点 3 和 2 的孪生节点。孪生和都为 6 。
链表中没有其他孪生节点。
所以，链表的最大孪生和是 6 。
示例 2：

输入：head = [4,2,2,3]
输出：7
解释：
链表中的孪生节点为：
- 节点 0 是节点 3 的孪生节点，孪生和为 4 + 3 = 7 。
- 节点 1 是节点 2 的孪生节点，孪生和为 2 + 2 = 4 。
所以，最大孪生和为 max(7, 4) = 7 。
示例 3：

输入：head = [1,100000]
输出：100001
解释：
链表中只有一对孪生节点，孪生和为 1 + 100000 = 100001 。
 

提示：

链表的节点数目是 [2, 105] 中的 偶数 。
1 <= Node.val <= 105
```

看了下输入，感觉可以直接数组，确实可以ac

```c++
class Solution {
public:
    int pairSum(ListNode* head) {
        if (!head) return 0;
        vector<int> vec;
        while (head) {
            vec.push_back(head->val);
            head = head->next;
        }
        int n = vec.size();
        int ans = INT_MIN;
        for (int i = 0; i < n / 2; ++i) {
            ans = max(ans, vec[i]+vec[n-1-i]);
        }
        return ans;
    }
};
```

当然这题本意肯定是用遍历的方法，没说不能修改原链表，那就可以把链表后面一半翻转，分为两个链表，再一次遍历求最大孪生和

```c++
class Solution {
    // 翻转链表，返回新链表头
    ListNode *reverseList(ListNode *head) {
        if (!head || !head->next) return head;
        ListNode *pre = head;
        ListNode *cur = head->next;
        ListNode *nxt = head->next->next;
        pre->next = nullptr; // 尾节点断联
        while (cur) {
            nxt = cur->next;
            cur->next = pre;
            pre = cur;
            cur = nxt;
        }
        return pre;
    }
public:
    int pairSum(ListNode* head) {
        if (!head) return 0;
        if (head->next && !head->next->next) return head->val + head->next->val;
        ListNode *slow = head;
        ListNode *fast = head->next;
        while (fast && fast->next) {
            slow = slow->next;
            fast = fast->next->next;
        }
        // if (fast && !fast->next) { // 因为是偶数，肯定命中
        ListNode* new_head = reverseList(slow->next);
        slow->next = nullptr;
        int ans = INT_MIN;
        while (head && new_head) { // 此时两个链表同长度
            ans = max(ans, head->val + new_head->val);
            head = head->next;
            new_head = new_head->next;
        }
        return ans;
    }
};
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

二刷，直接从后往前构造，比以前的版本写得更加简洁易懂，所以删掉之前版本

```c++
class Solution {
public:
    void merge(vector<int>& nums1, int m, vector<int>& nums2, int n) {
        nums1.resize(m + n); // 其实力扣的用例保证了长度，后面的元素都是0
        int i = m - 1;
        int j = n - 1;
        int k = m + n - 1;
        while (i >= 0 && j >= 0) {
            if (nums1[i] > nums2[j]) {
                nums1[k--] = nums1[i--];
            } else {
                nums1[k--] = nums2[j--];
            }
        }
        while (i >= 0) {
            nums1[k--] = nums1[i--];
        }
        while (j >= 0) {
            nums1[k--] = nums2[j--];
        }
    }
};
```

### 94. 二叉树的中序遍历(medium) @hot100

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
                s.push(cur); // 只会在这里压栈
                cur = cur->left;
            }
            cur = s.top(); // 2)
            s.pop(); // 当前节点及左子树处理完毕，出栈
            res.push_back(cur->val);
            cur = cur->right;
        }
        return res;
    }
};
```

刷hot100，直接递归，一把AC

```c++
class Solution {
public:
    vector<int> inorderTraversal(TreeNode* root) {
        if (!root) return {};
        vector<int> left;
        vector<int> right;
        if (root->left) left = inorderTraversal(root->left);
        if (root->right) right = inorderTraversal(root->right);
        vector<int> res = left;
        res.push_back(root->val);
        res.insert(res.end(), right.begin(), right.end());
        return res;
    }
};
```

用迭代的方式，发现会陷入死循环，问题出在cur->left又压入栈了

```c++
vector<int> inorderTraversal(TreeNode *root) {
  if (!root)
    return {};
  if (!root->left && !root->right)
    return {root->val};
  vector<int> res;
  stack<TreeNode *> st;
  st.push(root);
  while (!st.empty()) {
    TreeNode *cur = st.top();
    if (!cur) { // 可能会把nullptr压入栈
      st.pop();
    } else if (cur->left) {
      st.push(cur->left);
    } else {
      res.push_back(cur->val);
      st.pop();
      if (cur->right) {
        st.push(cur->right);
      }
    }
  }
  return res;
}
```

官方题解介绍了莫里斯遍历，是不需要借助栈的迭代解法，额外空间复杂度O(1)，但是会修改原结构

Morris 遍历算法整体步骤如下（假设当前遍历到的节点为 x）：

1. 如果 x 无左孩子，先将 x 的值加入答案数组，再访问 x 的右孩子，即 x=x.right
2. 如果 x 有左孩子，则找到 x 左子树上最右的节点（即左子树中序遍历的最后一个节点，x 在中序遍历中的前驱节点），我们记为 predecessor。根据 predecessor 的右孩子是否为空，进行如下操作。
    1. 如果 predecessor 的右孩子为空，则将其右孩子指向 x，然后访问 x 的左孩子，即 x=x.left
    2. 如果 predecessor 的右孩子不为空，则此时其右孩子指向 x，说明我们已经遍历完 x 的左子树，我们将 predecessor 的右孩子置空，将 x 的值加入答案数组，然后访问 x 的右孩子，即 x=x.right
3. 重复上述操作，直至访问完整棵树。

实现的一个难点在于，在后续的遍历时，cur=cur->right后，cur的predecessor->right可能会指向cur自身，所以会引起死循环，故cur找predecessor时需要排除这一情况，而这一情况也是左子树遍历完成的标志，

```c++
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode() : val(0), left(nullptr), right(nullptr) {}
 *     TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
 *     TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
 * };
 */
class Solution {
public:
    vector<int> inorderTraversal(TreeNode* root) {
        // Moris Traversal
        if (!root) return {};
        vector<int> res;
        TreeNode *cur = root;
        while (cur) {
            if (!cur->left) {
                res.push_back(cur->val);
                cur = cur->right;
            } else {
                // 找到中序遍历中cur的前驱，应该位于左子树的最右边
                TreeNode *predecessor = cur->left;
                while (predecessor->right && predecessor->right != cur) { // 第二个条件不能少，否则会越过cur
                    predecessor = predecessor->right;
                }
                if (!predecessor->right) {
                    // 找到了，指向cur
                    predecessor->right = cur;
                    cur = cur->left;
                } else {
                    // 说明左子树已经遍历完了，断链，防止下次找predecessor时出现死循环
                    res.push_back(cur->val);
                    predecessor->right = nullptr;
                    cur = cur->right; // 这一步，即可能访问真正的右子树，也可能回到某个父辈
                }
            }
        }
        return res;
    }
};
```

### 98.验证二叉搜索树(medium) @hot100

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

二刷

```c++
class Solution {
public:
    bool isValidBST(TreeNode* root) {
        if (!root) return true;
        long long pre_val = (long long)INT_MIN - 1;
        return inorder(root, pre_val);
    }
    bool inorder(TreeNode* root, long long &pre_val) {
        if (!root) return true;
        if (!inorder(root->left, pre_val)) return false;
        if (root->val <= pre_val) return false;
        else pre_val = root->val;
        if (!inorder(root->right, pre_val)) return false;
        return true;
    }
};
```

刷hot100，用到了vector存储中序遍历的结果，但只需要比较前一个元素与当前元素即可

```c++
class Solution {
public:
    bool isValidBST(TreeNode* root) {
        vector<int> vec;
        stack<TreeNode*> st;
        TreeNode *cur = root;
        while (cur || !st.empty()) {
            while (cur) {
                st.push(cur);
                cur = cur->left;
            }
            cur = st.top();
            st.pop();
            vec.push_back(cur->val);
            cur = cur->right;
        }
        for (int i = 1; i < vec.size(); ++i) {
            if (vec[i] <= vec[i-1]) return false;
        }
        return true;
    }
};
```

### 99. 恢复二叉搜索树(Hard)

二叉搜索树中的两个节点被错误地交换。

请在不改变其结构的情况下，恢复这棵树。

示例 1:

输入: [1,3,null,null,2]

   1
  /
 3
  \
   2

输出: [3,1,null,null,2]

   3
  /
 1
  \
   2
示例 2:

输入: [3,1,4,null,null,2]

  3
 / \
1   4
   /
  2

输出: [2,1,4,null,null,3]

  2
 / \
1   4
   /
  3
进阶:

使用 O(n) 空间复杂度的解法很容易实现。
你能想出一个只使用常数空间的解决方案吗？

解法一：排序，空间复杂度O(n)

按照二叉搜索树的性质我们可以发现，用中序遍历来变遍历整棵树，合法的情况应该是从小到大排序的。因此，我们可以将中序遍历的结果和从小到大排序后的结果做对比，这样就可以找到出错的两个节点，交换他们的值即可。

```c++
class Solution {
public:
    void inorder(TreeNode* root, vector<pair<int, TreeNode*>>& v){
        if(root == nullptr) return;
        inorder(root->left, v);
        v.push_back({root->val, root});
        inorder(root->right, v);
    }
    void recoverTree(TreeNode* root) {
        vector<pair<int, TreeNode*>> sorted, unsorted;
        inorder(root, sorted);
        unsorted = sorted;
        sort(sorted.begin(), sorted.end());
        int len = sorted.size();
        vector<TreeNode*> tt;
        for(int i = 0; i<len; i++)
            if(sorted[i].first != unsorted[i].first)
                tt.push_back(sorted[i].second);
        swap(tt[0]->val,tt[1]->val);
    }
};
```

解法一变形：显式中序遍历，空间复杂度O(n)

不需要排序，BST的中序遍历是递增的，找到两个违反这个规则的节点即可，从左到右，第一个违反递增规律的取左边节点，第二个违反递增规律的取右边节点

```c++
class Solution {
public:
    void inorder(TreeNode* root, vector<pair<int, TreeNode*>>& v){
        if(root == nullptr) return;
        inorder(root->left, v);
        v.push_back({root->val, root});
        inorder(root->right, v);
    }
    void recoverTree(TreeNode* root) {
        vector<pair<int, TreeNode*>> vec;
        inorder(root, vec);
        int len = vec.size();
        TreeNode* n1 = nullptr;
        TreeNode* n2 = nullptr;
        for(int i = 0; i < len - 1; ++i) {
            if (vec[i + 1].first < vec[i].first) {
                if (!n1) {
                    n1 = vec[i].second; // 第一个违反递增规律的取左边节点
                }
                n2 = vec[i + 1].second; // 第二个违反递增规律的取右边节点（有可能只有一个违反规律的pair
            }
        }
        swap(n1->val, n2->val);
    }
};
```

解法二：隐式中序遍历，空间复杂度O(H)，需要用到栈，取决于二叉树的高度

我们只关心中序遍历的值序列中每个相邻的位置的大小关系是否满足条件，且错误交换后最多两个位置不满足条件，因此在中序遍历的过程我们只需要维护当前中序遍历到的最后一个节点 pred，然后在遍历到下一个节点的时候，看两个节点的值是否满足前者小于后者即可，如果不满足说明找到了一个交换的节点，且在找到两次以后就可以终止遍历。

```c++
class Solution {
public:
    void recoverTree(TreeNode* root) {
        TreeNode* n1 = nullptr;
        TreeNode* n2 = nullptr;
        TreeNode* pre = nullptr;
        stack<TreeNode*> st;
        TreeNode* cur = root;
        while (cur || !st.empty()) {
            while (cur) {
                st.push(cur);
                cur = cur->left;
            }
            cur = st.top();
            st.pop();
            if (pre && pre->val > cur->val) {
                n2 = cur;
                if (!n1) {
                    n1 = pre;
                } else {
                    break;
                }
            }
            pre = cur;
            cur = cur->right;
        }
        swap(n1->val, n2->val);
    }
};
```

方法三：Morris 中序遍历，不需要栈，空间复杂度O(1)

Morris 遍历算法整体步骤如下（假设当前遍历到的节点为 x）：

- 如果 x 无左孩子，则访问 x 的右孩子，即 x = x.right。
- 如果 x 有左孩子，则找到 x 左子树上最右的节点（即左子树中序遍历的最后一个节点，x 在中序遍历中的前驱节点），我们记为 predecessor。根据 predecessor 的右孩子是否为空，进行如下操作。
  - 如果 predecessor 的右孩子为空，则将其右孩子指向 x，然后访问 x 的左孩子，即 x=x.left。
  - 如果 predecessor 的右孩子不为空，则此时其右孩子指向 x，说明我们已经遍历完 x 的左子树，我们将 predecessor 的右孩子置空，然后访问 x 的右孩子，即 x = x.right。
- 重复上述操作，直至访问完整棵树。

其实整个过程我们就多做一步：将当前节点左子树中最右边的节点指向它，这样在左子树遍历完成后我们通过这个指向走回了 x，且能再通过这个知晓我们已经遍历完成了左子树，而不用再通过栈来维护，省去了栈的空间复杂度。

```c++
class Solution {
public:
    void recoverTree(TreeNode* root) {
        TreeNode *x = nullptr, *y = nullptr, *pred = nullptr, *predecessor = nullptr;
        while (root != nullptr) {
            if (root->left != nullptr) {
                // predecessor 节点就是当前 root 节点向左走一步，然后一直向右走至无法走为止
                predecessor = root->left;
                while (predecessor->right != nullptr && predecessor->right != root) {
                    predecessor = predecessor->right;
                }
                // 增加的一步：让 predecessor 的右指针指向 root，继续遍历左子树
                if (predecessor->right == nullptr) {
                    predecessor->right = root;
                    root = root->left;
                }
                // 说明左子树已经访问完了，我们需要断开链接
                else {
                    if (pred != nullptr && root->val < pred->val) {
                        y = root;
                        if (x == nullptr) {
                            x = pred;
                        }
                    }
                    pred = root;
                    predecessor->right = nullptr;
                    root = root->right;
                }
            }
            // 如果没有左孩子，则直接访问右孩子
            else {
                if (pred != nullptr && root->val < pred->val) {
                    y = root;
                    if (x == nullptr) {
                        x = pred;
                    }
                }
                pred = root;
                root = root->right;
            }
        }
        swap(x->val, y->val);
    }
};
```

### 100. 相同的树(Easy)

给定两个二叉树，编写一个函数来检验它们是否相同。

如果两个树在结构上相同，并且节点具有相同的值，则认为它们是相同的。

示例 1:

输入:       1         1
          / \       / \
         2   3     2   3
        [1,2,3],   [1,2,3]

输出: true
示例 2:

输入:      1          1
          /           \
         2             2
        [1,2],     [1,null,2]

输出: false
示例 3:

输入:       1         1
          / \       / \
         2   1     1   2
        [1,2,1],   [1,1,2]

输出: false

easy，一次性a了

```c++
class Solution {
public:
    bool isSameTree(TreeNode* p, TreeNode* q) {
        if (!p && !q) return true;
        if (!p || !q) return false;
        if (p->val != q->val) return false;
        return isSameTree(p->left, q->left) && isSameTree(p->right, q->right);
    }
};
```

### 101.对称二叉树(medium,based on 98) @hot100

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
        return isSym(root->left, root->right);
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

刷hot100时，没想到要双管齐下，这样无法保证高层的是否相等

```c++
    bool isSymmetric(TreeNode* root) {
        if (!root || (!root->left && !root->right)) return true;
        if (root->left && root->right) {
            if (root->left->val != root->right->val) {
                return false;
            }
        } else {
            return false;
        }
        return isSymmetric(root->left) && isSymmetric(root->right);
    }
```

### 102.二叉树的层次遍历(medium) @hot100

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

第一次尝试，BFS+层数记录（二刷时，还是用的这种方法，看来很直观）

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

跟y总有点像的，自己的解法，感觉容易写出来

```c++
class Solution {
public:
    vector<vector<int>> levelOrder(TreeNode* root) {
        vector<vector<int>> res;
        if (!root) return res;
        vector<int> layer;
        queue<TreeNode*> q;
        q.push(root);
        int sz = 1;
        while (!q.empty()) {
            TreeNode *cur = q.front();
            q.pop();
            if (cur->left) q.push(cur->left);
            if (cur->right) q.push(cur->right);
            layer.push_back(cur->val);
            if (--sz == 0) {
                res.push_back(layer);
                vector<int>().swap(layer);
                sz = q.size();
                layer.reserve(sz);
            }
        }
        return res;
    }
};
```

### 103.二叉树的锯齿形排列

同牛客32-3

给定一个二叉树，返回其节点值的锯齿形层次遍历。（即先从左往右，再从右往左进行下一层遍历，以此类推，层与层之间交替进行）。

算是二刷了，还不错，这个解法比较简洁，最外层循环每次会处理同一层所有节点再进入第二层，用size很巧妙

```c++
class Solution {
public:
    vector<vector<int>> zigzagLevelOrder(TreeNode* root) {
        vector<vector<int>> ans;
        if (!root) return ans;
        deque<TreeNode*> dq;
        dq.push_back(root);
        bool l2r = true;
        TreeNode* cur;
        vector<int> tmp;
        while (!dq.empty()) {
            int size = dq.size();
            if (l2r) {
                while (size--) {
                    cur = dq.front();
                    tmp.push_back(cur->val);
                    dq.pop_front();
                    if (cur->left) dq.push_back(cur->left);
                    if (cur->right) dq.push_back(cur->right);
                }
            } else {
                while (size--) {
                    cur = dq.back();
                    tmp.push_back(cur->val);
                    dq.pop_back();
                    if (cur->right) dq.push_front(cur->right);
                    if (cur->left) dq.push_front(cur->left);
                }
            }
            l2r = (l2r == true) ? false : true;
            ans.push_back(tmp);
            tmp.clear();
        }
        return ans;
    }
};
```

### 104.二叉树的最大深度 @hot100

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

最简洁的是两行搞定（当然也可以压缩成一行，不过没必要）

```c++
class Solution {
public:
    int maxDepth(TreeNode* root) {
        if (!root) return 0;
        return max(maxDepth(root->left), maxDepth(root->right)) + 1;
    }
};
```

 这题还可以用非递归的DFS解决，但需要栈这种数据结构，也可以使用广度优先搜索（BFS），但需要队列这种数据结构

非递归的DFS，中序遍历，参考94.的代码

```c++
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode() : val(0), left(nullptr), right(nullptr) {}
 *     TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
 *     TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
 * };
 */
class Solution {
public:
    int maxDepth(TreeNode* root) {
        if (!root) return 0;
        stack<pair<TreeNode*, int>> st;
        int res = 1;
        int cur_depth = 1;
        TreeNode *cur = root;
        while (cur || !st.empty()) {
            while (cur) {
                st.push(pair<TreeNode*, int>(cur, cur_depth));
                cur = cur->left;
                ++cur_depth;
            }
            cur = st.top().first;
            cur_depth = st.top().second;
            res = max(res, cur_depth);
            st.pop();
            cur = cur->right;
            ++cur_depth;
        }
        return res;
    }
};
```

非递归的BFS，用queue，每一层缓存一下q.size()，即可决定啥时候到下一层

```c++
class Solution {
public:
    int maxDepth(TreeNode* root) {
        if (!root) return 0;
        queue<TreeNode*> q;
        int res = 0;
        q.push(root);
        int sz = 1;
        while (!q.empty()) {
            TreeNode *cur = q.front();
            if (cur->left) q.push(cur->left);
            if (cur->right) q.push(cur->right);
            q.pop();
            if (--sz == 0) {
                sz = q.size();
                ++res;
            }
        }
        return res;
    }
};
```

如果不用sz变量，就需要入队列时同时加入layer信息

```c++
class Solution {
public:
    int maxDepth(TreeNode* root) {
        if (!root) return 0;
        queue<pair<TreeNode*, int>> q; // treenode 与 其layer
        q.push({root, 1});
        int ans = 0;
        while (!q.empty()) {
            int cur_layer = q.front().second;
            if (q.front().first->left) q.push({q.front().first->left, cur_layer+1});
            if (q.front().first->right) q.push({q.front().first->right, cur_layer+1});
            q.pop();
            ans = max(ans, cur_layer);
        }
        return ans;
    }
};
```

官方题解用了嵌套的while循环，执行流是一样的，都好理解

```c++
class Solution {
public:
    int maxDepth(TreeNode* root) {
        if (root == nullptr) return 0;
        queue<TreeNode*> Q;
        Q.push(root);
        int ans = 0;
        while (!Q.empty()) {
            int sz = Q.size();
            while (sz > 0) {
                TreeNode* node = Q.front();Q.pop();
                if (node->left) Q.push(node->left);
                if (node->right) Q.push(node->right);
                sz -= 1;
            }
            ans += 1;
        } 
        return ans;
    }
};
```

### 105. 从前序与中序遍历序列构造二叉树(medium) @hot100

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

AC代码：

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
    TreeNode* buildTree(vector<int>& preorder, vector<int>& inorder) {
        if (preorder.empty() || inorder.empty()) return nullptr;
        return helper(
            preorder.begin(), preorder.end() - 1, inorder.begin(), inorder.end() - 1);
    }
    TreeNode* helper(vector<int>::iterator pre_first, vector<int>::iterator pre_last, vector<int>::iterator in_first, vector<int>::iterator in_last) {
        TreeNode* root = new TreeNode(*pre_first);
        if (in_first == in_last) return root; // 这里用inorder或者preorder判断均可
        auto root_inorder = find(in_first, in_last, root->val);
        int left_subtree_size = root_inorder - in_first;
        if (left_subtree_size > 0) {
            root->left = helper(pre_first + 1, pre_first + left_subtree_size,
                                in_first, root_inorder - 1);
        }
        if (root_inorder != in_last) {
            root->right = helper(pre_first + left_subtree_size + 1, pre_last,
                                root_inorder + 1, in_last);
        }
        return root;
    }
};
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

二刷，还行

```c++
class Solution {
public:
    TreeNode* buildTree(vector<int>& preorder, vector<int>& inorder) {
        if (preorder.empty() || inorder.empty()) return nullptr;
        return helper(preorder, inorder, 0, preorder.size()-1, 0, inorder.size()-1);
    }
    TreeNode* helper(vector<int>& preorder, vector<int>& inorder, int pre_l, int pre_r, int in_l, int in_r) {
        if (pre_l > pre_r || in_l > in_r) return nullptr;
        int root_val = preorder[pre_l];
        TreeNode* root = new TreeNode(root_val); // 当前节点
        auto it = find(inorder.begin(), inorder.end(), root_val);
        int left_subtree_size = it - (inorder.begin() + in_l);
        root->left = helper(preorder, inorder, pre_l+1, pre_l+left_subtree_size, in_l, in_l+left_subtree_size-1);
        root->right = helper(preorder, inorder, pre_l+left_subtree_size+1, pre_r, in_l+left_subtree_size+1, in_r);
        return root;
    }
};
```

刷hot100，差不多，一些边界点的处理要小心

```c++
class Solution {
public:
    TreeNode* buildTree(vector<int>& preorder, vector<int>& inorder) {
        if (preorder.empty() || inorder.empty()) return nullptr;
        int pre_index = 0;
        return helper(preorder, &pre_index, inorder, 0, inorder.size());
    }

    // 先序遍历的节点，在中序遍历的中间，可以划分为左子树与右子树
    // 左闭右开区间，[in_begin, in_end)
    TreeNode *helper(vector<int> &preorder, int *pre_index, vector<int> &inorder, int in_begin, int in_end) {
        if (in_begin == in_end) {
            return new TreeNode(inorder[in_begin]);
        }
        auto it = find(inorder.begin() + in_begin, inorder.begin() + in_end, preorder[*pre_index]);
        if (it == inorder.end()) return nullptr;
        int root_index = it - inorder.begin();
        TreeNode *root = new TreeNode(inorder[root_index]);
        if (root_index > in_begin) { // 有左子树
            (*pre_index)++;
            root->left = helper(preorder, pre_index, inorder, in_begin, root_index);
        }
        if (root_index < in_end - 1) { // 有右子树
            (*pre_index)++;
            root->right = helper(preorder, pre_index, inorder, root_index + 1, in_end);
        }
        return root;
    }
};
```

### 106. 从中序与后序遍历序列构造二叉树(medium)

[从中序与后序遍历序列构造二叉树](https://leetcode-cn.com/problems/construct-binary-tree-from-inorder-and-postorder-traversal/)

根据一棵树的中序遍历与后序遍历构造二叉树。

注意:
你可以假设树中没有重复的元素。

例如，给出

中序遍历 inorder = [9,3,15,20,7]
后序遍历 postorder = [9,15,7,20,3]
返回如下的二叉树：

```shell
    3
   / \
  9  20
    /  \
   15   7
```

AC代码，和上题差不多，没用哈希表存储中序遍历的下标，

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
    TreeNode* buildTree(vector<int>& inorder, vector<int>& postorder) {
        if (inorder.empty() || postorder.empty()) return nullptr;
        return helper(inorder.begin(), inorder.end() - 1, postorder.begin(), postorder.end() - 1);
    }
    TreeNode* helper(vector<int>::iterator in_first, vector<int>::iterator in_last, vector<int>::iterator post_first, vector<int>::iterator post_last) {
        TreeNode* root = new TreeNode(*post_last);
        if (post_first == post_last) return root;
        auto root_inorder = find(in_first, in_last, root->val);
        int left_len = root_inorder - in_first;
        if (left_len > 0) {
            root->left = helper(in_first, root_inorder - 1,
                                post_first, post_first + left_len - 1);
        }
        if (left_len < in_last - in_first) {
            root->right = helper(root_inorder + 1, in_last,
                                post_first + left_len, post_last - 1);
        }
        return root;
    }
};
```

### 107. 二叉树的层次遍历 II(Easy)

给定一个二叉树，返回其节点值自底向上的层次遍历。 （即按从叶子节点所在层到根节点所在的层，逐层从左向右遍历）

例如：
给定二叉树 [3,9,20,null,null,15,7],

```c++
    3
   / \
  9  20
    /  \
   15   7
```

返回其自底向上的层次遍历为：

[
  [15,7],
  [9,20],
  [3]
]

直接bfs层序遍历，最后再reverse一下

```c++
class Solution {
public:
    vector<vector<int>> levelOrderBottom(TreeNode* root) {
        vector<vector<int>> ans;
        if (!root) return ans;
        queue<TreeNode*> q;
        TreeNode* cur;
        q.push(root);
        while (!q.empty()) {
            int len = q.size();
            vector<int> level;
            while (len--) {
                cur = q.front();
                q.pop();
                level.push_back(cur->val);
                if (cur->left) q.push(cur->left);
                if (cur->right) q.push(cur->right);
            }
            if (!level.empty()) ans.push_back(level);
        }
        reverse(ans.begin(), ans.end());
        return ans;
    }
};
```

### 108.将有序数组转换为二叉搜索树(Easy) @hot100

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

2020.7.16二刷，一次性AC，15min？有进步

三刷，速度提上来了

刷hot100，主函数可以省略构造步骤，第一次进入也可以交给辅助函数去做

```c++
class Solution {
public:
    TreeNode* sortedArrayToBST(vector<int>& nums) {
        if (nums.empty()) return nullptr;
        // 根节点的左子树是左边区间的中点，根节点右子树是右边区间的中点
        int len = nums.size();
        int mid = len / 2;
        TreeNode *root = new TreeNode(nums[mid]);
        root->left = buildBST(nums, 0, mid - 1);
        root->right = buildBST(nums, mid + 1, len - 1);
        return root;
    }

    TreeNode* buildBST(vector<int> &nums, int begin, int end) {
        if (begin > end) return nullptr;
        int mid = begin + (end - begin) / 2;
        TreeNode *root = new TreeNode(nums[mid]);
        root->left = buildBST(nums, begin, mid - 1);
        root->right = buildBST(nums, mid + 1, end);
        return root;
    }
};
```

### 109. 有序链表转换二叉搜索树(Medium,based on 108)

给定一个单链表，其中的元素按升序排序，将其转换为高度平衡的二叉搜索树。

本题中，一个高度平衡二叉树是指一个二叉树每个节点 的左右两个子树的高度差的绝对值不超过 1。

示例:

给定的有序链表： [-10, -3, 0, 5, 9],

一个可能的答案是：[0, -3, 9, -10, null, 5], 它可以表示下面这个高度平衡二叉搜索树：

```c++
      0
     / \
   -3   9
   /   /
 -10  5
```

从根节点开始递归构造节点，每次取数组中间的val作为当前节点的val值

这个做法其实就跟108是一样的，也可以使用快慢指针法，不借用数组

```c++
class Solution {
public:
    TreeNode* sortedListToBST(ListNode* head) {
        if (!head) return nullptr;
        vector<int> vec;
        ListNode* cur = head;
        while (cur) {
            vec.push_back(cur->val);
            cur = cur->next;
        }
        int len = vec.size();
        TreeNode* root = new TreeNode(vec[len / 2]);
        root->left = dfs(vec, 0, len / 2 - 1);
        root->right = dfs(vec, len / 2 + 1, len - 1);
        return root;
    }
    TreeNode* dfs(vector<int>& vec, int l, int r) { // 闭区间
        if (l > r) return nullptr;
        TreeNode* root = new TreeNode(vec[(l + r) / 2]);
        root->left = dfs(vec, l, (l + r) / 2 - 1);
        root->right = dfs(vec, (l + r) / 2 + 1, r);
        return root;
    }
};
```

### 110. 平衡二叉树

同剑指55-2

给定一个二叉树，判断它是否是高度平衡的二叉树。

本题中，一棵高度平衡二叉树定义为：

一个二叉树每个节点 的左右两个子树的高度差的绝对值不超过1。

```c++
class Solution {
public:
    bool isBalanced(TreeNode* root) {
        return recursion(root, 0).first;
    }
    pair<bool, int> recursion(TreeNode* root, int hight) { // 返回：当前节点是否平衡 and 当前节点最大高度
        if (root == nullptr) return {true, hight-1}; // 空节点肯定是平衡的，不贡献深度
        pair<bool, int> left = recursion(root->left, hight+1);
        pair<bool, int> right = recursion(root->right, hight+1);
        bool flag = left.first && right.first && abs(left.second-right.second) <= 1; // 左右节点都平衡，且左右子树最大高度差不超过1，当前节点才平衡
        int max_hight = max(left.second, right.second);
        return {flag, max_hight};
    }
};
```

### 111. 二叉树的最小深度(Easy)

给定一个二叉树，找出其最小深度。

最小深度是从根节点到最近叶子节点的最短路径上的节点数量。

说明: 叶子节点是指没有子节点的节点。

示例:

给定二叉树 [3,9,20,null,null,15,7],

```c++
    3
   / \
  9  20
    /  \
   15   7
```

返回它的最小深度  2.

简单题，直接用bfs

```c++
class Solution {
public:
    int minDepth(TreeNode* root) {
        // bfs
        if (!root) return 0;
        int ans = 0;
        queue<TreeNode*> q;
        TreeNode* cur;
        q.push(root);
        while (!q.empty()) {
            int len = q.size();
            ++ans;
            while (len--) {
                cur = q.front();
                q.pop();
                if (cur->left) q.push(cur->left);
                if (cur->right) q.push(cur->right);
                if (!cur->left && !cur->right) return ans;
            }
        }
        return ans;
    }
};
```

### 112. 路径总和(Easy)

给定一个二叉树和一个目标和，判断该树中是否存在根节点到叶子节点的路径，这条路径上所有节点值相加等于目标和。

说明: 叶子节点是指没有子节点的节点。

示例:
给定如下二叉树，以及目标和 sum = 22，

```c++
              5
             / \
            4   8
           /   / \
          11  13  4
         /  \      \
        7    2      1
```

返回 true, 因为存在目标和为 22 的根节点到叶子节点的路径 5->4->11->2。

简单题，直接递归

```c++
class Solution {
public:
    bool hasPathSum(TreeNode* root, int sum) {
        if (!root) return false;
        sum -= root->val;
        if (!root->left && !root->right) {
            if (sum == 0) {
                return true;
            } else {
                return false;
            }
        }
        return (root->left && hasPathSum(root->left, sum)) ||
                (root->right && hasPathSum(root->right, sum));
    }
};
```

### 113. 路径总和 II(Medium)

给定一个二叉树和一个目标和，找到所有从根节点到叶子节点路径总和等于给定目标和的路径。

说明: 叶子节点是指没有子节点的节点。

自己想的，可以看到path是拷贝赋值，很影响性能，应该改为通用回溯模板

```c++
class Solution {
public:
    vector<vector<int>> ans;
    vector<vector<int>> pathSum(TreeNode* root, int sum) {
        if (!root) return ans;
        vector<int> path;
        helper(root, path, 0, sum);
        return ans;
    }
    void helper(TreeNode* root, vector<int> path, int cur, int sum) {
        if (!root) return;
        path.push_back(root->val);
        cur += root->val;
        if (!root->left && !root->right && cur == sum) {
            ans.push_back(path);
            return;
        }
        helper(root->left, path, cur, sum);
        helper(root->right, path, cur, sum);
    }
};
```

题解区找的优秀代码，用了回溯模板，最后还原path，效率很高，接近双百了

```c++
class Solution {
public:
    vector<vector<int>> res;
    vector<int> temp; //防止反复初始化数组
    void dfs (TreeNode* root,int sum) {
        if (!root) return;
        int resum = sum - root->val;
        temp.push_back(root->val);
        if (resum == 0 && !root->left && !root->right) {
            res.push_back(temp); //找到答案
            temp.pop_back();
            return;
        }
        dfs(root->left, resum);
        dfs(root->right, resum);
        temp.pop_back(); //回溯，还原path
    }
    vector<vector<int>> pathSum(TreeNode* root, int sum) {
        dfs(root,sum);
        return res;
    }
};
```

### 114. 二叉树展开为链表(Medium) @hot100

给定一个二叉树，原地将它展开为一个单链表。

例如，给定二叉树

.   1
   / \
  2   5
 / \   \
3   4   6
将其展开为：

1
 \
  2
   \
    3
     \
      4
       \
        5
         \
          6

第一次尝试，用栈前序遍历，因为访问过的节点的左右儿子会压入栈中，所以可以放心修改它

```c++
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode() : val(0), left(nullptr), right(nullptr) {}
 *     TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
 *     TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
 * };
 */
class Solution {
public:
    void flatten(TreeNode* root) {
        if (!root) return;
        stack<TreeNode*> st;
        st.push(root);
        TreeNode* cur;
        TreeNode* pre = new TreeNode();
        while (!st.empty()) {
            cur = st.top();
            st.pop();
            pre->right = cur;
            pre->left = nullptr;
            pre = cur;
            if (cur->right) st.push(cur->right);
            if (cur->left) st.push(cur->left);
        }
    }
};
```

在评论区看到一个很妙的方法，空间复杂度为O(1)

1、判断左子树是否为空，若为空则直接往右走，若不为空则2
2、将当前节点root的右子树接到当前root节点的左孩子节点的最右下边的孩子节点
3、将当前节点root的左子树接到右子树上，并将左节点置为NULL。

```c++
class Solution {
public:
    void flatten(TreeNode* root) {
        if (!root) return;
        TreeNode* l;
        TreeNode* cur = root;
        while (cur){ // 每次循环会把cur的左子树处理掉
            if (cur->left) {
                l = cur->left;
                while(l->right) l = l->right; // 找到左儿子最右端的叶子节点
                l->right = cur->right; // 叶子节点的后继是当前节点的右儿子
                cur->right = cur->left; // 移过去
                cur->left = nullptr;
            }
            cur = cur->right;
        }
    }
};
```

### 116. 填充每个节点的下一个右侧节点指针(Medium)

给定一个完美二叉树，其所有叶子节点都在同一层，每个父节点都有两个子节点。二叉树定义如下：

```c++
struct Node {
  int val;
  Node *left;
  Node *right;
  Node *next;
}
```

填充它的每个 next 指针，让这个指针指向其下一个右侧节点。如果找不到下一个右侧节点，则将 next 指针设置为 NULL。

初始状态下，所有 next 指针都被设置为 NULL。

pre+bfs，一次性ac

```c++
class Solution {
public:
    Node* connect(Node* root) {
        if (!root) return nullptr;
        queue<Node*> q;
        q.push(root);
        Node* cur;
        while (!q.empty()) {
            int len = q.size();
            Node* level_pre = nullptr;
            while (len--) {
                cur = q.front();
                q.pop();
                if (!level_pre) {
                    level_pre = cur;
                } else {
                    level_pre->next = cur;
                    level_pre = cur;
                }
                if (cur->left) q.push(cur->left);
                if (cur->right) q.push(cur->right);
            }
        }
        return root;
    }
};
```

拉链法，利用递归，因为给定了完美二叉树

- 如果右边结点是亲兄弟结点，则在遍历到父节点的时候就root->left->next = root->right;；
- 如果右边结点是堂兄弟结点，则在遍历到父节点的时候（此时父节点的next指针已经指向了右边的兄弟节点），通过父节点的next指针与右边结点相接： root->right->next = root->next->left;

```c++
class Solution {
public:
    Node* connect(Node* root) {
        if (!root) return nullptr;
        if (root->left) root->left->next = root->right;
        if (root->next && root->right) root->right->next = root->next->left;
        connect(root->left);
        connect(root->right);
        return root;
    }
};
```

### 117. 填充每个节点的下一个右侧节点指针 II(Medium, based on 116)

给定一个二叉树

```c++
struct Node {
  int val;
  Node *left;
  Node *right;
  Node *next;
}
```

填充它的每个 next 指针，让这个指针指向其下一个右侧节点。如果找不到下一个右侧节点，则将 next 指针设置为 NULL。

初始状态下，所有 next 指针都被设置为 NULL。

进阶：

你只能使用常量级额外空间。
使用递归解题也符合要求，本题中递归程序占用的栈空间不算做额外的空间复杂度。

借助队列的bfs版本就不看了，因为需要常量级额外空间

对于任意一次递归，只考虑如何设置**子节点**的 next 属性,分为三种情况：

- 没有子节点：直接返回
- 有一个子节点：将这个子节点的 next 属性设置为同层的下一个节点，即为 root.next 的最左边的一个节点，如果 root.next 没有子节点，则考虑 root.next.next，依次类推
- 有两个节点：左子节点指向右子节点，然后右子节点同第二种情况的做法

注意递归的顺序需要从右到左

```c++
class Solution {
public:
    Node* connect(Node* root) {
        // 每次递归设置root的左右儿子节点的next属性
        if (!root || (!root->left && !root->right)) return root; // 如果root没有儿子，则直接返回
        if (root->left && root->right) root->left->next = root->right; // root有两个儿子，先设置左儿子的next
        Node* child = root->right ? root->right : root->left;
        Node* head = root->next;
        while (head && (!head->left && !head->right)) { // 找到与root同级的具有儿子的节点
            head = head->next;
        }
        child->next = head ? (head->left ? head->left : head->right) : nullptr;
        connect(root->right); // 先递归右边
        connect(root->left);
        return root;
    }
};
```

### 124. 二叉树中的最大路径和(hard, based on 543) @hot100

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

左右子树能向当前节点『贡献』的最大路径最少是0，比如如果左子树贡献了负数，当前节点可以不选左子树，于是可以取max。

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

刷hot100，略微繁琐点，思路是一样的，优雅解法的“左右子树可以贡献0”很巧妙，省去了很多ifelse

时间
16 ms
击败
96.9%
内存
27.1 MB
击败
23.38%

```c++
class Solution {
public:
    int maxPathSum(TreeNode* root) {
        int max_sum = INT_MIN;
        helper(root, &max_sum);
        return max_sum;
    }

    // return：经过当前节点的、向下路径的最大值（可能只包含当前节点本身
    int helper(TreeNode *root, int *max_sum) {
        if (!root) return 0;
        *max_sum = max(*max_sum, root->val);
        int left_max_sum = helper(root->left, max_sum);
        int right_max_sum = helper(root->right, max_sum);
        if (left_max_sum <= 0 && right_max_sum <= 0) {
            return root->val;
        }
        int child_max_sum = max(left_max_sum, right_max_sum);
        if (left_max_sum >= 0 && right_max_sum >= 0) {
            *max_sum = max(*max_sum, root->val + left_max_sum + right_max_sum);
        } else if (left_max_sum >= 0) {
            *max_sum = max(*max_sum, root->val + left_max_sum);
        } else if (right_max_sum >= 0) {
            *max_sum = max(*max_sum, root->val + right_max_sum);
        }
        return root->val + child_max_sum;
    }
};
```

### 144. 二叉树的前序遍历(Medium)

递归

```c++
class Solution {
public:
    vector<int> preorderTraversal(TreeNode* root) {
        vector<int> ans;
        dfs(root, ans);
        return ans;
    }
    void dfs(TreeNode* root, vector<int>& ans) {
        if (!root) return;
        ans.push_back(root->val);
        dfs(root->left, ans);
        dfs(root->right, ans);
    }
};
```

迭代

```c++
class Solution {
public:
    vector<int> preorderTraversal(TreeNode* root) {
        vector<int> ans;
        if (!root) return ans;
        stack<TreeNode*> st;
        st.push(root);
        TreeNode* cur;
        while (!st.empty()) {
            cur = st.top();
            st.pop();
            ans.push_back(cur->val);
            if (cur->right) st.push(cur->right);
            if (cur->left) st.push(cur->left);
        }
        return ans;
    }
};
```

### 145. 二叉树的后序遍历(Hard) @hot100

迭代比较难写，

容易想到的就是先写个迭代的先序遍历，最后再把vector reverse

如果跟这中序遍历的迭代写法的思路，可以用个isVisited备忘录记录所有访问过的节点，如果当前节点被访问过，则可以输出

```c++
class Solution {
public:
    vector<int> postorderTraversal(TreeNode* root) {
        vector<int> ans;
        if (!root) return ans;
        stack<TreeNode*> st;
        TreeNode* cur = root;
        unordered_map<TreeNode*, bool> isVisited;
        while (cur || !st.empty()) {
            while (cur) {
                st.push(cur);
                cur = cur->left;
            }
            cur = st.top();
            if (isVisited.count(cur)) {
                ans.push_back(cur->val);
                st.pop();
                cur = nullptr;
                continue;
            }
            else {
                isVisited[cur] = true;
            }
            cur = cur->right;
        }
        return ans;
    }
};
```

下面的解法最妙，直接记录pre访问节点即可，记着吧

- 要保证根结点在左孩子和右孩子访问之后才能访问，因此对于任一结点P，先将其入栈。
- 如果P不存在左孩子和右孩子，则可以直接访问它；
- 或者P存在左孩子或者右孩子，但是其左孩子和右孩子都已被访问过了，则同样可以直接访问该结点。因为访问顺序一定是：左（如果有的话）-右（如果有的话）-根。
- 若非上述两种情况，则将P的右孩子和左孩子依次入栈，这样就保证了每次取栈顶元素的时候，左孩子在右孩子前面被访问，左孩子和右孩子都在根结点前面被访问。

```c++
class Solution {
public:
    vector<int> postorderTraversal(TreeNode *root){
        vector<int> ans;
        if (root == nullptr) return ans;
        stack<TreeNode *> s;
        TreeNode *cur;
        TreeNode *pre = nullptr;
        s.push(root);
        while (!s.empty()){
            cur = s.top();
            if ((!cur->left && !cur->right) ||
                (pre && (pre == cur->left || pre == cur->right))) {
                ans.push_back(cur->val);
                pre = cur; // 记录上次处理的节点
                s.pop();
            } else {
                if (cur->right) s.push(cur->right);
                if (cur->left) s.push(cur->left);
            }
        }
        return ans;
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

二刷，跟标准答案不太一样，先用中序遍历把整棵树遍历下来，然后转换为双向链表，感觉只有这样，hasNext与next方法的时间复杂度才是O(1)

```c++
class BSTIterator {
public:
    TreeNode* cur  = new TreeNode(INT_MIN);
    BSTIterator(TreeNode* root)  {
        if (!root) return;
        vector<TreeNode*> inorder;
        inorderTraversal(root, inorder);
        for (int i = 0; i < inorder.size()-1; ++i) {
            inorder[i]->right = inorder[i+1];
            inorder[i+1]->left = inorder[i];
        }
        cur->right = inorder.front();
    }
    void inorderTraversal(TreeNode* root, vector<TreeNode*> &inorder) {
        if (!root) return;
        inorderTraversal(root->left, inorder);
        inorder.push_back(root);
        inorderTraversal(root->right, inorder);
    }

    /** @return the next smallest number */
    int next() {
        cur = cur->right;
        return cur->val;
    }

    /** @return whether we have a next smallest number */
    bool hasNext() {
        if (cur->right) return true;
        return false;
    }
};
```

### 199. 二叉树的右视图(Medium) @hot100

给定一棵二叉树，想象自己站在它的右侧，按照从顶部到底部的顺序，返回从右侧所能看到的节点值。

示例:

输入: [1,2,3,null,5,null,4]
输出: [1, 3, 4]
解释:

   1            <---
 /   \
2     3         <---
 \     \
  5     4       <---

bfs，记录层数，很简单了

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
    vector<int> rightSideView(TreeNode* root) {
        vector<int> ans;
        if (root == nullptr) return ans;
        queue<pair<TreeNode*, int>> q;
        q.push({root, 0});
        TreeNode* node;
        int cur_layer;
        int last_layer = -1; // 上一层初始是-1
        while (!q.empty()) {
            node = q.front().first;
            cur_layer = q.front().second;
            q.pop();
            if (cur_layer > last_layer) {
                ans.push_back(node->val);
            }
            if (node->right) {
                q.push({node->right, cur_layer+1});
            }
            if (node->left) {
                q.push({node->left, cur_layer+1});
            }
            last_layer = cur_layer;
        }
        return ans;
    }
};
```

刷hot100，不需要记录层数，层序遍历的应用，巧用queue.size()换层

```c++
class Solution {
public:
    vector<int> rightSideView(TreeNode* root) {
        if (!root) return {};
        // 层序遍历的应用
        vector<int> res;
        queue<TreeNode*> q;
        q.push(root);
        int sz = 1;
        TreeNode *cur = root;
        while (!q.empty()) {
            cur = q.front();
            q.pop();
            if (cur->left) q.push(cur->left);
            if (cur->right) q.push(cur->right); // 注意顺序，右视图，right后入队列
            if (--sz == 0) {
                // 到达该层末尾，当前节点即为该层最右节点
                res.push_back(cur->val);
                sz = q.size();
            }
        }
        return res;
    }
};
```

### 226. 翻转二叉树 @hot100

给你一棵二叉树的根节点 root ，翻转这棵二叉树，并返回其根节点。

```c++
class Solution {
public:
    TreeNode* invertTree(TreeNode* root) {
        if (!root) return nullptr;
        TreeNode *left = root->left;
        root->left = root->right;
        root->right = left;
        invertTree(root->left);
        invertTree(root->right);
        return root;
    }
};
```

迭代写法，参考145的后序遍历

```c++
class Solution {
public:
    TreeNode* invertTree(TreeNode* root) {
        if (!root) return root;
        stack<TreeNode*> st;
        st.push(root);
        TreeNode *cur = nullptr;
        TreeNode *pre = nullptr;
        while (!st.empty()) {
            cur = st.top();
            if ((!cur->left && !cur->right) ||
                (pre && (pre == cur->left || pre == cur->right))) {
                TreeNode *left = cur->left;
                cur->left = cur->right;
                cur->right = left;
                pre = cur; // 记录上次处理的节点
                st.pop();
            } else {
                if (cur->right) st.push(cur->right);
                if (cur->left) st.push(cur->left);
            }
        }
        return root;
    }
};
```

### 230. 二叉搜索树中第K小的元素(Medium) @hot100

给定一个二叉搜索树，编写一个函数 kthSmallest 来查找其中第 k 个最小的元素。

说明：
你可以假设 k 总是有效的，1 ≤ k ≤ 二叉搜索树元素个数。

示例 1:

输入: root = [3,1,4,null,2], k = 1
   3
  / \
 1   4
  \
   2
输出: 1
示例 2:

输入: root = [5,3,6,2,4,null,null,1], k = 3
       5
      / \
     3   6
    / \
   2   4
  /
 1
输出: 3
进阶：
如果二叉搜索树经常被修改（插入/删除操作）并且你需要频繁地查找第 k 小的值，你将如何优化 kthSmallest 函数？

```c++
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode() : val(0), left(nullptr), right(nullptr) {}
 *     TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
 *     TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
 * };
 */
class Solution {
public:
    int kthSmallest(TreeNode* root, int k) {
        priority_queue<int> pq; // 默认最大堆
        stack<TreeNode*> st;
        st.push(root);
        TreeNode* cur;
        while (!st.empty()) {
            cur = st.top();
            st.pop();
            if (pq.size() < k) pq.push(cur->val);
            else {
                if (cur->val < pq.top()) {
                    pq.push(cur->val);
                    pq.pop();
                }
            }
            if (cur->right) st.push(cur->right);
            if (cur->left) st.push(cur->left);
        }
        return pq.top();
    }
    // TODO: 进阶
};
```

还用到了优先队列（最大堆），不是很优雅，其实直接改为中序遍历即可，BST的中序遍历就是升序的

```c++
class Solution {
public:
    int kthSmallest(TreeNode* root, int k) {
        stack<TreeNode*> st;
         int res;
         int n = 0;
         TreeNode* cur = root;
         while(cur || !st.empty()){
            while(cur){
                st.push(cur);
                cur=cur->left;
            }
            cur = st.top();
            st.pop();
            n++;
            if(n == k) return cur->val;
            cur = cur->right;
         }
         return 0;
    }
};
```

(/在题解区看到进阶的讨论，感觉有点复杂，就先不看了)❎

二刷

```c++
class Solution {
public:
    int kthSmallest(TreeNode* root, int k) {
        stack<TreeNode*> st;
        TreeNode* cur = root;
        while (cur || !st.empty()) {
            while(cur) {
                st.push(cur); // 如果有左孩子，则压栈
                cur = cur->left;
            }
            cur = st.top();
            st.pop();
            if (--k == 0) return cur->val;
            cur = cur->right;
        }
        return 0; // never reach
    }
};
```

刷hot100，递归写法

```c++
class Solution {
public:
    bool find = false;
    int kthSmallest(TreeNode* root, int k) {
        // 中序遍历，第k个即为第k小元素
        if (!root) return 0;
        int cnt = k;
        bool find;
        return helper(root, &cnt);

    }
    int helper(TreeNode* root, int *k) {
        if (!root) return 0;
        int res = helper(root->left, k);
        if (find) return res;
        // 当前节点
        --(*k);
        if (*k == 0) {
            find = true;
            return root->val;
        }
        res = helper(root->right, k);
        if (find) {
            return res;
        }
        return 0;
    }
};
```

如果经常插入和删除，频繁查找第k小会比较麻烦，可以考虑在遍历时维护该节点的左子树的节点个数，右子树的节点个数，当要找第k小时，先判断左子树节点个数，若小于k，则k肯定在右子树里面，这样就可以剪枝了

### 235. 二叉搜索树的最近公共祖先(Medium)

给定一个二叉搜索树, 找到该树中两个指定节点的最近公共祖先。

百度百科中最近公共祖先的定义为：“对于有根树 T 的两个结点 p、q，最近公共祖先表示为一个结点 x，满足 x 是 p、q 的祖先且 x 的深度尽可能大（一个节点也可以是它自己的祖先）。”

例如，给定如下二叉搜索树:  root = [6,2,8,0,4,7,9,null,null,3,5]

示例 1:

输入: root = [6,2,8,0,4,7,9,null,null,3,5], p = 2, q = 8
输出: 6
解释: 节点 2 和节点 8 的最近公共祖先是 6。
示例 2:

输入: root = [6,2,8,0,4,7,9,null,null,3,5], p = 2, q = 4
输出: 2
解释: 节点 2 和节点 4 的最近公共祖先是 2, 因为根据定义最近公共祖先节点可以为节点本身。

说明:

所有节点的值都是唯一的。
p、q 为不同节点且均存在于给定的二叉搜索树中。

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
    TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
        if (p == root || q == root) return root;
        if (p->val > q->val) swap(p, q); // 确保p指向较小的节点
        if (p->val < root->val && q->val > root->val) return root;
        if (p->val < root->val && q->val < root->val) return lowestCommonAncestor(root->left, p, q);
        else return lowestCommonAncestor(root->right, p, q);
        return nullptr; // never reached
    }
};
```

二刷，直接做成236题的题解了，完全没用到BST的性质

```c++
class Solution {
public:
    TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
        if (!root || root == p || root == q) return root;
        auto l = lowestCommonAncestor(root->left, p, q);
        auto r = lowestCommonAncestor(root->right, p, q);
        if (!l && !r) return nullptr;
        if (!l) return r;
        if (!r) return l;
        return root;
    }
};
```

用到BST性质的二刷，感觉比一刷的代码还有优雅一点

```c++
class Solution {
public:
    TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
        if (!root) return root;
        if (p->val > q->val) swap(p, q);
        if (root->val > p->val && root->val > q->val) return lowestCommonAncestor(root->left, p, q);
        if (root->val < p->val && root->val < q->val) return lowestCommonAncestor(root->right, p, q);
        return root;
    }
};
```

### 236. 二叉树的最近公共祖先(medium) @hot100

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

考虑到祖先可以为自身，那么递归退出条件可以直接是判断当前节点与p、q，而不用理会当前节点的子节点中是否包含pq，因为递归函数的返回值即表示找到的p或q，又表示已找到的公共祖先，非常巧妙

为什么这样能求得最小的公共祖先？因为当子节点计算出来公共祖先后，父节点只需要返回内层递归的函数返回值即可，所以不会修改已计算得到的公共祖先，所以最后得到的一定是最小的

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
        return root; // p和q在两侧
    }
};
```

```c++
class Solution {
public:
    TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
        if(root == nullptr || root == p || root == q) return root;
        TreeNode *left = lowestCommonAncestor(root->left, p, q);
        TreeNode *right = lowestCommonAncestor(root->right, p, q);
        if (left && right) return root;
        if (left) return left; // 与上面的答案是一致的
        if (right) return right;
        return nullptr;
    }
};
```

二刷的代码，好不简洁啊。。

```c++
class Solution {
public:
    TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
        if (!root || !p || !q) return nullptr;
        return helper(root, p, q).first;
    }
    pair<TreeNode*, pair<bool, bool>> helper(TreeNode* root, TreeNode* p, TreeNode* q) {
        if (root == nullptr) return {nullptr, {false, false}};
        bool p_bool = false;
        bool q_bool = false;
        auto triple = helper(root->left, p, q);
        bool p_bool_l = triple.second.first;
        bool q_bool_l = triple.second.second;
        if (p_bool_l && q_bool_l) {
            return {triple.first, {true, true}};
        }
        triple = helper(root->right, p, q);
        bool p_bool_r = triple.second.first;
        bool q_bool_r = triple.second.second;
        if (p_bool_r && q_bool_r) {
            return {triple.first, {true, true}};
        }
        if (root == p) p_bool = true;
        if (root == q) q_bool = true;
        p_bool = p_bool || p_bool_l || p_bool_r;
        q_bool = q_bool || q_bool_l || q_bool_r;
        return {root, {p_bool, q_bool}};
    }
};
```

刷hot100，还是没有之前的最佳答案简洁

时间
16 ms
击败
68.54%
内存
13.9 MB
击败
47.61%

```c++
class Solution {
public:
    TreeNode *ans = nullptr;
    TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
        if (!root) return nullptr;
        if (p == q) return p;
        helper(root, p, q);
        return ans;
    }
    TreeNode* helper(TreeNode* root, TreeNode* p, TreeNode* q) {
        if (!root || ans) return nullptr;
        TreeNode* left_find = helper(root->left, p, q);
        TreeNode* right_find = helper(root->right, p, q);
        if (left_find && right_find) {
            ans = root;
            return nullptr;
        } else if (!left_find && !right_find) {
            // 左右子树都找不到
            if (root == p || root == q) {
                return root == p ? p : q;
            }
            return nullptr;
        } else {
            // 左右子树找到一个
            if (root == p || root == q) {
                ans = root;
                return nullptr;
            } else {
                return left_find != nullptr ? left_find : right_find;
            }
        }
        return nullptr;
    }
};
```

刷hot75，仍然不简洁

```c++
class Solution {
public:
    TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
        if (!root || !p || !q) return nullptr;
        bool left_found = false;
        bool right_found = false;
        return dfs(root, p, q, left_found, right_found, true);
    }
    TreeNode *dfs(TreeNode *root, TreeNode *p, TreeNode *q, bool &left_found, bool &right_found, bool is_from_left) {
        if (!root) return nullptr;
        bool l_found = false;
        bool r_found = false;
        TreeNode *left_ans = dfs(root->left, p, q, l_found, r_found, true);
        if (left_ans) return left_ans;
        left_found = l_found || r_found;
        l_found = false;
        r_found = false;
        TreeNode *right_ans = dfs(root->right, p, q, l_found, r_found, false);
        if (right_ans) return right_ans;
        right_found = l_found || r_found;
        if (left_found && right_found) return root;
        if ((root == p || root == q) && (left_found || right_found)) return root;
        if (root == p || root == q) {
            if (is_from_left) left_found = true;
            else right_found = true;
        }
        return nullptr;
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

### 437. 路径总和 III @hot100

给定一个二叉树，它的每个结点都存放着一个整数值。

找出路径和等于给定数值的路径总数。

路径不需要从根节点开始，也不需要在叶子节点结束，但是路径方向必须是向下的（只能从父节点到子节点）。

二叉树不超过1000个节点，且节点数值范围是 [-1000000,1000000] 的整数。

dfs

先序递归遍历每个节点

以每个节点作为起始节点DFS寻找满足条件的路径

时间
16 ms
击败
78.93%
内存
15.5 MB
击败
76.81%

```c++
class Solution {
public:
    int ans = 0;
    void dfs(TreeNode* root, long long sum){
        if(!root) return;
        sum -= root->val;
        if(sum == 0) ans++;
        dfs(root->left, sum);
        dfs(root->right, sum);
    }
    int pathSum(TreeNode* root, int sum) {
        if(!root) return ans;
        dfs(root, sum);
        pathSum(root->left, sum); // 将每个节点作为根节点执行dfs
        pathSum(root->right, sum); // 将每个节点作为根节点执行dfs
        return ans;
    }
};
```

上述做法会多次访问子节点，刷hot100时想到了前缀和的思想，用一个数组存储之前的前缀和，因为路径向下，数组size就是当前层数，力扣有大整数的输入，所以用long long64位存储

(理论上来说比上述快，但是力扣跑出来比上述做法还慢。。)

时间
24 ms
击败
50.37%
内存
15.8 MB
击败
52.53%

```c++
class Solution {
public:
    int pathSum(TreeNode* root, int targetSum) {
        if (!root) return 0;
        vector<long long> sums = {root->val};
        long long layer = 0;
        return helper(root, sums, layer + 1, targetSum);
    }

    int helper(TreeNode* root, vector<long long> &sums, int layer, int targetSum) {
        if (!root) return 0;
        // 计算：以当前节点为路径的终点，路径之和==target的路径数目
        if (sums.size() < layer + 1) sums.resize(layer + 1);
        sums[layer] = sums[layer - 1] + root->val;
        int ans = 0;
        for (int i = 0; i < layer; ++i) {
            if (sums[layer] - sums[i] == targetSum) {
                ans++;
            }
        }
        ans += helper(root->left, sums, layer + 1, targetSum);
        ans += helper(root->right, sums, layer + 1, targetSum);
        return ans;
    }
};
```

刷hot75时又碰到了，看题解发现有人用unordered_map，确实可以，不用在遍历前缀和数组查找了，时间可以更快，注意为了解决从根节点开始的边界情况，最开始初始化哈希表前缀和为0的次数为1

```c++
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode() : val(0), left(nullptr), right(nullptr) {}
 *     TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
 *     TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
 * };
 */
class Solution {
public:
    int pathSum(TreeNode* root, int targetSum) {
        if (!root) return 0;
        // dfs+前缀和
        unordered_map<long long, int> pre_sums; // 前缀和数组,value为出现次数
        pre_sums[0] = 1; // 从根节点开始，所以前缀和为0出现了1次
        return dfs(root, targetSum, pre_sums, 0);
    }
    int dfs(TreeNode *root, int targetSum, unordered_map<long long, int> &pre_sums, long long cur_sum) {
        if (!root) return 0;
        cur_sum += root->val;
        int ans = 0; // ans为以当前节点为终点的合法路径数目
        if (pre_sums.count(cur_sum - targetSum)) ans += pre_sums[cur_sum - targetSum];
        ++pre_sums[cur_sum];
        ans += dfs(root->left, targetSum, pre_sums, cur_sum);
        ans += dfs(root->right, targetSum, pre_sums, cur_sum);
        --pre_sums[cur_sum]; // 恢复现场, cur_sum参数是值传递，不用恢复
        return ans;
    }
};
```

### 450. 删除二叉搜索树中的节点

给定一个二叉搜索树的根节点 root 和一个值 key，删除二叉搜索树中的 key 对应的节点，并保证二叉搜索树的性质不变。返回二叉搜索树（有可能被更新）的根节点的引用。

一般来说，删除节点可分为两个步骤：

首先找到需要删除的节点；
如果找到了，删除它。

```
示例 1:

输入：root = [5,3,6,2,4,null,7], key = 3
输出：[5,4,6,2,null,null,7]
解释：给定需要删除的节点值是 3，所以我们首先找到 3 这个节点，然后删除它。
一个正确的答案是 [5,4,6,2,null,null,7], 如下图所示。
另一个正确答案是 [5,2,6,null,4,null,7]。


示例 2:

输入: root = [5,3,6,2,4,null,7], key = 0
输出: [5,3,6,2,4,null,7]
解释: 二叉树不包含值为 0 的节点
示例 3:

输入: root = [], key = 0
输出: []
 

提示:

节点数的范围 [0, 104].
-105 <= Node.val <= 105
节点值唯一
root 是合法的二叉搜索树
-105 <= key <= 105
 

进阶： 要求算法时间复杂度为 O(h)，h 为树的高度。
```

这题挺难的，整了个把小时还没ac，直接看答案好了

解法一，直接构造中序遍历的数组，然后删除对应元素，最后再根据数组构建BST，虽然不符合题意但是也能work 

解法二，首先根据BST特性递归找到待删除节点，为了保持BST性质，需要对其子树重排，很显然要用递归来实现，有以下几种情况：

1. 待删除节点为孩子，直接删除即可
2. 待删除节点只有左孩子，此时可以将它的左子树作为新的子树，返回左孩子（作为递归调用栈的孩子拼接，很巧妙）
3. 待删除节点只有右孩子，此时可以将它的右子树作为新的子树，返回右孩子
4. 待删除节点有左右孩子，可以选择左子树的最右孩子，或者右子树的最左孩子作为替换，要保证不断连、不成环（我也是在这里卡了很久）

在代码实现上，我们可以先寻找 successor，再删除它。successor 是 root 的右子树中的最小节点，可以先找到 root 的右子节点，再不停地往左子节点寻找，直到找到一个不存在左子节点的节点，这个节点即为 successor。然后递归地在 root.right 调用 deleteNode 来删除 successor。因为 successor 没有左子节点，因此这一步递归调用不会再次步入这一种情况。然后将 successor 更新为新的 root 并返回。

作者：力扣官方题解
链接：https://leetcode.cn/problems/delete-node-in-a-bst/solutions/1529700/shan-chu-er-cha-sou-suo-shu-zhong-de-jie-n6vo/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

```c++
class Solution {
public:
    TreeNode* deleteNode(TreeNode* root, int key) {
        if (root == nullptr) {
            return nullptr;
        }
        if (root->val > key) {
            root->left = deleteNode(root->left, key);
            return root;
        }
        if (root->val < key) {
            root->right = deleteNode(root->right, key);
            return root;
        }
        if (root->val == key) {
            if (!root->left && !root->right) {
                return nullptr;
            }
            if (!root->right) {
                return root->left;
            }
            if (!root->left) {
                return root->right;
            }
            TreeNode *successor = root->right;
            while (successor->left) {
                successor = successor->left;
            }
            root->right = deleteNode(root->right, successor->val);
            successor->right = root->right;
            successor->left = root->left;
            return successor;
        }
        return root;
    }
};
```

还有一种解法是把左子树拼接到右子树上，但是这样会让树越来越高，好处是非常好理解

根据二叉搜索树的性质

如果目标节点大于当前节点值，则去右子树中删除；
如果目标节点小于当前节点值，则去左子树中删除；
如果目标节点就是当前节点，分为以下三种情况：
其无左子：其右子顶替其位置，删除了该节点；
其无右子：其左子顶替其位置，删除了该节点；
其左右子节点都有：其左子树转移到其右子树的最左节点的左子树上，然后右子树顶替其位置，由此删除了该节点。

```c++
class Solution {
public:
    TreeNode* deleteNode(TreeNode* root, int key) 
    {
        if (root == nullptr)    return nullptr;
        if (key > root->val)    root->right = deleteNode(root->right, key);     // 去右子树删除
        else if (key < root->val)    root->left = deleteNode(root->left, key);  // 去左子树删除
        else    // 当前节点就是要删除的节点
        {
            if (! root->left)   return root->right; // 情况1，欲删除节点无左子
            if (! root->right)  return root->left;  // 情况2，欲删除节点无右子
            TreeNode* node = root->right;           // 情况3，欲删除节点左右子都有 
            while (node->left)          // 寻找欲删除节点右子树的最左节点
                node = node->left;
            node->left = root->left;    // 将欲删除节点的左子树成为其右子树的最左节点的左子树
            root = root->right;         // 欲删除节点的右子顶替其位置，节点被删除
        }
        return root;    
    }
};

作者：Terry
链接：https://leetcode.cn/problems/delete-node-in-a-bst/solutions/582561/miao-dong-jiu-wan-shi-liao-by-terry2020-tc0o/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

### 501. 二叉搜索树中的众数(Medium)

给定一个有相同值的二叉搜索树（BST），找出 BST 中的所有众数（出现频率最高的元素）。

假定 BST 有如下定义：

结点左子树中所含结点的值小于等于当前结点的值
结点右子树中所含结点的值大于等于当前结点的值
左子树和右子树都是二叉搜索树
例如：
给定 BST [1,null,2,2],

   1
    \
     2
    /
   2
返回[2].

提示：如果众数超过1个，不需考虑输出顺序

进阶：你可以不使用额外的空间吗？（假设由递归产生的隐式调用栈的开销不被计算在内）

思路：二叉搜索树的中序遍历是一个升序序列，逐个比对当前结点(root)值与前驱结点（pre)值。更新当前节点值出现次数(curTimes，初始化为1)及最大出现次数(maxTimes)，更新规则：若curTimes=maxTimes,将root->val添加到结果向量(res)中；若curTimes>maxTimes,清空res,将root->val添加到res,并更新maxTimes为curTimes。

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
    vector<int> findMode(TreeNode* root) {
        if (!root) return {};
        vector<int> res;
        int cnt = 0;
        int max_cnt = 0;
        int pre = root->val;
        inorderTraversal(root, res, pre, cnt, max_cnt);
        return res;
    }
    void inorderTraversal(TreeNode* root, vector<int> &res, int &pre, int &cnt, int &max_cnt) {
        if (!root) return;
        inorderTraversal(root->left, res, pre, cnt, max_cnt);
        if (root->val == pre) {
            ++cnt;
        }
        else {
            pre = root->val;
            cnt = 1;
        }
        if (cnt > max_cnt) {
            res.clear();
            res.push_back(root->val);
            max_cnt = cnt;
        } else if (cnt == max_cnt && ((!res.empty() && root->val != res.back()) || res.empty())) {
            res.push_back(root->val);
        }
        inorderTraversal(root->right, res, pre, cnt, max_cnt);
    }
};
```

### 530. 二叉搜索树的最小绝对差(Easy)

同783题

给你一棵所有节点为非负值的二叉搜索树，请你计算树中任意两节点的差的绝对值的最小值。

示例：

输入：

   1
    \
     3
    /
   2

输出：
1

解释：
最小绝对差为 1，其中 2 和 1 的差的绝对值为 1（或者 2 和 3）。

提示：

树中至少有 2 个节点。

中序遍历一把梭，记录一下pre就好了，当然第一次进入循环时是没有pre的，pre不太好设置初始值，可能会溢出

```c++
class Solution {
public:
    int getMinimumDifference(TreeNode* root) {
        int res = INT_MAX;
        stack<TreeNode*> st;
        int pre = INT_MIN;
        TreeNode* cur = root;
        bool first = true;
        while (cur || !st.empty()) {
            while (cur) {
                st.push(cur);
                cur = cur->left;
            }
            cur = st.top();
            st.pop();
            if (first) {
                first = false;
            } else {
                res = min(res, abs(pre - cur->val));
            }
            pre = cur->val;
            cur = cur->right;
        }
        return res;
    }
};
```

### 543. 二叉树的直径(medium) @hot100

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

刷hot100，思路和之前的递归差不多

```c++
class Solution {
public:
    int diameterOfBinaryTree(TreeNode* root) {
        int diameter = 0;
        depthOfCurrentNode(root, &diameter);
        return diameter;
    }

    int depthOfCurrentNode(TreeNode *root, int *diameter) {
        if (!root) return 0;
        int left_depth = depthOfCurrentNode(root->left, diameter);
        int right_depth = depthOfCurrentNode(root->right, diameter);
        int cur_depth = max(left_depth, right_depth) + 1;
        int cur_diameter = left_depth + right_depth;
        *diameter = max(*diameter, cur_diameter);
        return cur_depth;
    }
};
```

### 700. 二叉搜索树中的搜索

easy

给定二叉搜索树（BST）的根节点 root 和一个整数值 val。

你需要在 BST 中找到节点值等于 val 的节点。 返回以该节点为根的子树。 如果节点不存在，则返回 null 。

```
示例 1:

输入：root = [4,2,7,1,3], val = 2
输出：[2,1,3]
示例 2:


输入：root = [4,2,7,1,3], val = 5
输出：[]
 

提示：

树中节点数在 [1, 5000] 范围内
1 <= Node.val <= 107
root 是二叉搜索树
1 <= val <= 107
```

简单题，根据BST性质递归

```c++
class Solution {
public:
    TreeNode* searchBST(TreeNode* root, int val) {
        if (!root) return root;
        if (root->val == val) return root;
        if (root->val > val) return searchBST(root->left, val);
        return searchBST(root->right, val);
    }
};
```

### 783. 二叉搜索树节点最小距离(Easy)

给定一个二叉搜索树的根节点 root，返回树中任意两节点的差的最小值。

同530题

### 872. 叶子相似的树

easy

请考虑一棵二叉树上所有的叶子，这些叶子的值按从左到右的顺序排列形成一个 叶值序列 。


举个例子，如上图所示，给定一棵叶值序列为 (6, 7, 4, 9, 8) 的树。

如果有两棵二叉树的叶值序列是相同，那么我们就认为它们是 叶相似 的。

如果给定的两个根结点分别为 root1 和 root2 的树是叶相似的，则返回 true；否则返回 false 。

```
示例 1：


输入：root1 = [3,5,1,6,2,9,8,null,null,7,4], root2 = [3,5,1,6,7,4,2,null,null,null,null,null,null,9,8]
输出：true
示例 2：


输入：root1 = [1,2,3], root2 = [1,3,2]
输出：false
 

提示：

给定的两棵树结点数在 [1, 200] 范围内
给定的两棵树上的值在 [0, 200] 范围内
```

用先序遍历，两个数组存下来比较即可

```c++
class Solution {
    void preOrder(TreeNode* root, int k) {
        if (!root) return;
        if (!root->left && !root->right) leaf[k].push_back(root->val);
        preOrder(root->left, k);
        preOrder(root->right, k);
    }
    vector<vector<int>> leaf;
public:
    bool leafSimilar(TreeNode* root1, TreeNode* root2) {
        leaf.resize(2);
        preOrder(root1, 0);
        preOrder(root2, 1);
        if (leaf[0].size() == leaf[1].size() && leaf[0] == leaf[1]) return true;
        return false;
    }
};
```

### 958. 二叉树的完全性检验(Medium)

给定一个二叉树，确定它是否是一个完全二叉树。

百度百科中对完全二叉树的定义如下：

若设二叉树的深度为 h，除第 h 层外，其它各层 (1～h-1) 的结点数都达到最大个数，第 h 层所有的结点都连续集中在最左边，这就是完全二叉树。（注：第 h 层可能包含 1~ 2h 个节点。）

第一次尝试，思路就是层序遍历，第一次出现叶子节点，后面应该都是叶子节点，看了一圈题解区，我这种想法应该是最优雅的

```c++
class Solution {
public:
    bool isCompleteTree(TreeNode* root) {
        if (!root) return true;
        queue<TreeNode*> q;
        q.push(root);
        TreeNode* cur;
        while (!q.empty()) {
            cur = q.front();
            q.pop();
            if (!cur) break; // 第一次出现叶子节点，直接break
            q.push(cur->left);
            q.push(cur->right);
        }
        while (!q.empty()) {
            if (q.front() != nullptr) {
                return false;
            }
            q.pop();
        }
        return true;
    }
};
```

### 1161. 最大层内元素和

给你一个二叉树的根节点 root。设根节点位于二叉树的第 1 层，而根节点的子节点位于第 2 层，依此类推。

请返回层内元素之和 最大 的那几层（可能只有一层）的层号，并返回其中 最小 的那个。

 
```
示例 1：

输入：root = [1,7,0,7,-8,null,null]
输出：2
解释：
第 1 层各元素之和为 1，
第 2 层各元素之和为 7 + 0 = 7，
第 3 层各元素之和为 7 + -8 = -1，
所以我们返回第 2 层的层号，它的层内元素之和最大。
示例 2：

输入：root = [989,null,10250,98693,-89388,null,null,null,-32127]
输出：2
 

提示：

树中的节点数在 [1, 104]范围内
-105 <= Node.val <= 105
```

和199. 二叉树的右视图一样，巧用q.size来换层，注意最大值的更新，每层开始时layer_sum需置零

```c++
class Solution {
public:
    int maxLevelSum(TreeNode* root) {
        if (!root) return 0;
        queue<TreeNode *> q;
        q.push(root);
        int sz = q.size();
        int ans = 0;
        int max_sum = INT_MIN;
        int layer_sum = 0;
        int layer = 1;
        while (!q.empty()) {
            TreeNode *cur = q.front();
            layer_sum += cur->val;
            if (cur->left) q.push(cur->left);
            if (cur->right) q.push(cur->right);
            q.pop();
            if (--sz == 0) {
                sz = q.size();
                if (layer_sum > max_sum) {
                    max_sum = layer_sum;
                    ans = layer;
                }
                layer_sum = 0;
                ++layer;
            }
        }
        return ans;
    }
};
```

### 1305. 两棵二叉搜索树中的所有元素(Medium)

给你 root1 和 root2 这两棵二叉搜索树。

请你返回一个列表，其中包含 两棵树 中的所有整数并按 升序 排序。.

示例 1：

输入：root1 = [2,1,4], root2 = [1,0,3]
输出：[0,1,1,2,3,4]
示例 2：

输入：root1 = [0,-10,10], root2 = [5,1,7,0,2]
输出：[-10,0,0,1,2,5,7,10]
示例 3：

输入：root1 = [], root2 = [5,1,7,0,2]
输出：[0,1,2,5,7]
示例 4：

输入：root1 = [0,-10,10], root2 = []
输出：[-10,0,10]
示例 5：

输入：root1 = [1,null,8], root2 = [8,1]
输出：[1,1,8,8]

提示：

每棵树最多有 5000 个节点。
每个节点的值在 [-10^5, 10^5] 之间。

```c++
class Solution {
public:
    vector<int> getAllElements(TreeNode* root1, TreeNode* root2) {
        vector<int> res;
        helper(root1, res);
        helper(root2, res);
        sort(res.begin(), res.end());
        return  res;
    }
    void helper(TreeNode* root, vector<int>& result){
        if(root == nullptr) return;
        result.push_back(root->val);
        helper(root->left, result);
        helper(root->right, result);
    }
};
```

### 1372. 二叉树中的最长交错路径

medium

给你一棵以 root 为根的二叉树，二叉树中的交错路径定义如下：

选择二叉树中 任意 节点和一个方向（左或者右）。
如果前进方向为右，那么移动到当前节点的的右子节点，否则移动到它的左子节点。
改变前进方向：左变右或者右变左。
重复第二步和第三步，直到你在树中无法继续移动。
交错路径的长度定义为：访问过的节点数目 - 1（单个节点的路径长度为 0 ）。

请你返回给定树中最长 交错路径 的长度。
 
```
示例 1：

输入：root = [1,null,1,1,1,null,null,1,1,null,1,null,null,null,1,null,1]
输出：3
解释：蓝色节点为树中最长交错路径（右 -> 左 -> 右）。
示例 2：

输入：root = [1,1,1,null,1,null,null,1,1,null,1]
输出：4
解释：蓝色节点为树中最长交错路径（左 -> 右 -> 左 -> 右）。
示例 3：

输入：root = [1]
输出：0
 

提示：

每棵树最多有 50000 个节点。
每个节点的值在 [1, 100] 之间。
```

仍然是dfs，不过容易写错，得调试一会才通

```c++
class Solution {
public:
    int longestZigZag(TreeNode* root) {
        if (!root || !root->left && !root->right) return 0;
        return max(dfs(root->left, true, 1), dfs(root->right, false, 1)); // 初始长度为1
    }
    int dfs(TreeNode *root, bool is_from_left, int last_len) {
        if (!root) return 0;
        int ans = last_len;
        if (is_from_left) {
            ans = max(ans, dfs(root->left, true, 1)); // 同方向，长度归1
            ans = max(ans, dfs(root->right, false, last_len+1));
        } else {
            ans = max(ans, dfs(root->left, true, last_len+1));
            ans = max(ans, dfs(root->right, false, 1)); // 同方向，长度归1
        }
        return ans;
    }
};
```

### 1448. 统计二叉树中好节点的数目

medium

给你一棵根为 root 的二叉树，请你返回二叉树中好节点的数目。

「好节点」X 定义为：从根到该节点 X 所经过的节点中，没有任何节点的值大于 X 的值。

```
示例 1：

输入：root = [3,1,4,3,null,1,5]
输出：4
解释：图中蓝色节点为好节点。
根节点 (3) 永远是个好节点。
节点 4 -> (3,4) 是路径中的最大值。
节点 5 -> (3,4,5) 是路径中的最大值。
节点 3 -> (3,1,3) 是路径中的最大值。
示例 2：



输入：root = [3,3,null,4,2]
输出：3
解释：节点 2 -> (3, 3, 2) 不是好节点，因为 "3" 比它大。
示例 3：

输入：root = [1]
输出：1
解释：根节点是好节点。
 

提示：

二叉树中节点数目范围是 [1, 10^5] 。
每个节点权值的范围是 [-10^4, 10^4] 。
```

dfs一把梭，感觉应该是easy难度

```c++
class Solution {
    int ans;
public:
    int goodNodes(TreeNode* root) {
        if (!root->left && !root->right) return 1;
        dfs(root, root->val);
        return ans;
    }
    void dfs(TreeNode* root, int upper_max) {
        if (!root) return;
        if (root->val >= upper_max) {
            ++ans;
            upper_max = root->val;
        }
        dfs(root->left, upper_max);
        dfs(root->right, upper_max);
    }
};
```

## 动态规划

### 思路

李煜东著《算法竞赛进阶指南》，摘录如下：：

为了保证计算子问题能够按照顺序、不重复地进行，动态规划要求已经求解的子问题不受后续阶段的影响。这个条件也被叫做「无后效性」。换言之，动态规划对状态空间的遍历构成一张有向无环图，遍历就是该有向无环图的一个拓扑序。有向无环图中的节点对应问题中的「状态」，图中的边则对应状态之间的「转移」，转移的选取就是动态规划中的「决策」。

我的解释：

「有向无环图」「拓扑序」表示了每一个子问题只求解一次，以后求解问题的过程不会修改以前求解的子问题的结果；

作者：liweiwei1419
链接：https://leetcode.cn/problems/maximum-subarray/solutions/9058/dong-tai-gui-hua-fen-zhi-fa-python-dai-ma-java-dai/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

### 背包

https://leetcode.cn/problems/partition-equal-subset-sum/solutions/13059/0-1-bei-bao-wen-ti-xiang-jie-zhen-dui-ben-ti-de-yo/

### 3. 无重复字符的最长子串(Medium) @hot100

同剑指第48题，

给定一个字符串，请你找出其中不含有重复字符的 最长子串 的长度。

示例 1:

输入: "abcabcbb"
输出: 3
解释: 因为无重复字符的最长子串是 "abc"，所以其长度为 3。
示例 2:

输入: "bbbbb"
输出: 1
解释: 因为无重复字符的最长子串是 "b"，所以其长度为 1。
示例 3:

输入: "pwwkew"
输出: 3
解释: 因为无重复字符的最长子串是 "wke"，所以其长度为 3。
     请注意，你的答案必须是 子串 的长

动态规划：

定义dp[i]表示以第i个字符结尾的不包含重复字符的子字符串的最长长度，我们从左到右逐一扫描字符串每个字符，如果第i个字符之前没出现过，则f(i)=f(i-1)+1，如果第i个字符之前出现过，找到最近那个，与i的距离为d。

如果d小于等于f(i-1)，则此时第i个字符上次出现在f(i-1)对应的最长子字符串中，因此f(i)=d，同时这也意味着在第i个字符出现两次所夹的字符串中再也没有其他重复的字符了

如果d大于f(i-1)，则此时第i个字符上次出现在f(i-1)对应的最长子字符串之前，因此仍然有f(i)=f(i-1)+1

```c++
class Solution {
public:
    int lengthOfLongestSubstring(string s) {
        if (s.empty()) return 0;
        if (s.size() == 1) return 1;
        unordered_map<char, int> table; // record char last apear
        table[s[0]] = 0;
        int longest = 0;
        int size = s.size();
        // dp[i]表示以第i个字符结尾的不包含重复字符的子字符串的最长长度
        vector<int> vec(size, 1);
        for (int i = 1; i < size; ++i) {
            if (table.find(s[i]) == table.end() || i - table[s[i]] > vec[i-1]) {
                // 第i位元素结尾的最长子串可以接在后面，所以长度+1
                vec[i] = vec[i-1] + 1;
            } else {
                vec[i] = i - table[s[i]];
            }
            table[s[i]] = i;
            longest = vec[i] > longest ? vec[i] : longest;
        }
        return longest;
    }
};
```

因为f(i)只与f(i-1)有关，于是只需要一个变量即可，将空间复杂度下降为O(1)

```c++
class Solution {
public:
    int lengthOfLongestSubstring(string s) {
        if (s.empty()) return 0;
        if (s.size() == 1) return 1;
        unordered_map<char, int> table; // record char last apear
        table[s[0]] = 0;
        int longest = 0;
        int size = s.size();
        // dp[i]表示以第i个字符结尾的不包含重复字符的子字符串的最长长度
        int cur = 1;
        for (int i = 1; i < size; ++i) {
            if (table.find(s[i]) == table.end() || i - table[s[i]] > cur) {
                ++cur;
            } else {
                cur = i - table[s[i]];
            }
            table[s[i]] = i;
            longest = cur > longest ? cur : longest;
        }
        return longest;
    }
};
```

刷hot100时，错误地把dp[i]当做目前为止最长的子串长度，导致一直AC不了，一直以为是边界出错，最后发现原来是状态表示出错了

```c++
class Solution {
public:
    int lengthOfLongestSubstring(string s) {
        if (s.empty()) return 0;
        int len = s.size();
        unordered_map<char, int> hash; // 记录字符最后出现的坐标
        hash[s[0]] = 0;
        int cur_max_len = 1; // 遍历到第i位时，目前已知的最长子串长度，第1位作为初始值
        for (int i = 1; i < len; ++i) {
            auto iter = hash.find(s[i]);
            hash[s[i]] = i;
            if (iter == hash.end() || i - iter->second > cur_max_len) {
                ++cur_max_len;
            }
            if (iter != hash.end() && i - iter->second < cur_max_len){
                // 当前字符与上次出现的位置之差，比目前的最长子串长度还小，所以需要跳跃
                int skip = cur_max_len - (i - iter->second);
                while (skip-- > 0) {
                    ++i;
                    hash[s[i]] = i;
                }
            // } else {
            //     hash[s[i]] = i;
            }
        }
        return cur_max_len;
    }
};
```

这题也可以用滑动窗口做

1. 我们使用两个指针表示字符串中的某个子串（或窗口）的左右边界，其中左指针代表着上文中「枚举子串的起始位置」，
2. 在每一步的操作中，我们会将左指针向右移动一格，表示 我们开始枚举下一个字符作为起始位置，然后我们可以不断地向右移动右指针，但需要保证这两个指针对应的子串中没有重复的字符。在移动结束后，这个子串就对应着 以左指针开始的，不包含重复字符的最长子串。我们记录下这个子串的长度
3. 在枚举结束后，我们找到的最长的子串的长度即为答案

因为字符是优先的，哈希表可以优化成桶， int pos[128]={0};

```c++
class Solution {
public:
    int lengthOfLongestSubstring(string s) {
        if (s.empty()) return 0;
        int len = s.size();
        unordered_map<char, int> hash; // 记录当前窗口中字符出现的次数
        int l = 0; // l是窗口左端点
        int r = 1; // r是窗口右端点
        ++hash[s[0]]; // 窗口初始化[0,1]
        int res = 1;
        while (r < len) {
            // 此时r加入，判断r是否有重复，收缩左端点
            ++hash[s[r]];
            while (hash[s[r]] > 1) {
                --hash[s[l]];
                ++l;
            }
            // 此时是个不重复子串，记录下来
            res = max(res, r - l + 1);
            ++r;
        }
        return res;
    }
};
```

### 5.最长回文子串(Medium)

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

刷hot100时，直接构造2*n-1的遍历点，i为偶数，就是以字符为中心向两边扩散，i为奇数，就是以两个相邻字符为中心向两边扩散

```c++
class Solution {
public:
    string longestPalindrome(string s) {
        int n = s.size();
        int ans = 0;
        int begin = 0;
        int end = 0;
        // 总共有2n-1个位置，其中n个位置是以当前字符为中心的，n-1是相邻字符中间的位置
        for (int i = 0; i < 2 * n - 1; ++i) {
            if (i % 2 == 0) {
                int mid_index = i / 2; 
                int tmp = 0;
                while (mid_index - tmp >= 0 && mid_index + tmp < n && s[mid_index - tmp] == s[mid_index + tmp]) {
                    if (2 * tmp + 1 > end - begin) {
                        end = mid_index + tmp;
                        begin = mid_index - tmp;
                    }
                    ++tmp;
                }
            } else {
                int left_index = i / 2;
                int right_index = (i + 1) / 2;
                int tmp = 0;
                while (left_index - tmp >= 0 && right_index + tmp < n && s[left_index - tmp] == s[right_index + tmp]) {
                    if (2 * tmp + 2 > end - begin) {
                        end = right_index + tmp;
                        begin = left_index - tmp;
                    }
                    ++tmp;
                }
            }
        }
        return s.substr(begin, end - begin + 1);
    }
};
```

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

根据状态转移方程：p[i][j]=p[i+1][j-1]&&s[i]==s[j]，如果从二维矩阵的视角，当前值取决于i+1与j-1，所以遍历时要先计算下一行(i+1)的前一个元素(j-1)

- 比如：dp[0][3]取决于dp[1][2]，如果是两层for循环先行后列，都是从小到大遍历，则此时dp[1][2]还没计算，是初始化的false，所以dp[0][3]肯定也是false
- 解决方法是反向遍历行，正向遍历列；或者先遍历列，再遍历行

先遍历列，再遍历行

```c++
// // 二维矩阵的遍历顺序，按照数字从小到大
// 1 5 9  13
// 2 6 10 14
// 3 7 11 15
// 4 8 12 16

// // 又因为 i <= j ，所以实际只会遍历右上角

// 1 2 4 7
// x 3 5 8
// x x 6 9
// x x x 10

class Solution {
public:
    string longestPalindrome(string s) {
        // dp[i][j] 表示从i到j是否是回文子串，假设i <= j，且当i==j时，dp[i][j]=true
        // dp[i][j] = dp[i+1][j-1] && s[i] == s[j]
        int n = s.size();
        vector<vector<bool>> dp(n, vector<bool>(n, false));
        int begin = 0;
        int maxLen = 1;
        for (int r = 1; r < n; ++r) { // 先遍历列，再遍历行，保证先计算子问题
            for (int l = 0; l < r; ++l) {
                if (s[r] != s[l]) {
                    continue;
                }
                dp[l][r] = r - l <= 2 || dp[l+1][r-1];
                if (dp[l][r] && r + 1 - l > maxLen) {
                    begin = l;
                    maxLen = r + 1 - l;
                }
            }
        }
        return s.substr(begin,  maxLen);
    }
};
```

或者反向遍历行，正向遍历列

```c++
// 二维矩阵的遍历顺序，按照数字从小到大
// i <= j ，所以实际只会遍历右上角

// 7 8 9 10
// x 4 5 6
// x x 2 3
// x x x 1

class Solution {
public:
    string longestPalindrome(string s) {
        // dp[i][j] 表示从i到j是否是回文子串，假设i <= j，且当i==j时，dp[i][j]=true
        // dp[i][j] = dp[i+1][j-1] && s[i] == s[j]
        int n = s.size();
        vector<vector<bool>> dp(n, vector<bool>(n, false));
        int begin = 0;
        int maxLen = 1;
        for (int l = n - 2; l >= 0; --l) { // 先反向遍历行，再遍历列，保证先计算子问题
            for (int r = l + 1; r < n; ++r) {
                if (s[r] != s[l]) {
                    continue;
                }
                dp[l][r] = r - l <= 2 || dp[l+1][r-1];
                if (dp[l][r] && r + 1 - l > maxLen) {
                    begin = l;
                    maxLen = r + 1 - l;
                }
            }
        }
        return s.substr(begin,  maxLen);
    }
};
```

103/103 cases passed (496 ms)
Your runtime beats 6.83 % of cpp submissions
Your memory usage beats 39.16 % of cpp submissions (18.8 MB)

还有一个复杂度为 O(n)O(n) 的 Manacher（马拉车） 算法。然而本算法十分复杂，一般不作为面试内容。

[Manacher's Algorithm 马拉车算法](https://www.cnblogs.com/grandyang/p/4475985.html)

### 53.最大子数组/最大连续子序列/最大子段和 @hot100

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

hot100，想到了前缀和，其实感觉最后做出来和dp有点像

```c++
class Solution {
public:
    int maxSubArray(vector<int>& nums) {
        if (nums.size() == 1) return nums[0];
        int len = nums.size();
        int sum = 0; // 前缀和
        int prev_min = 0; // 之前的前缀和最小值，还未遍历时，前缀和为0
        int max_sub_sum = INT_MIN;
        for (int i = 0; i < len; ++i) {
            sum += nums[i];
            // 最大和的连续子数组，可能是是前一状态，也可能是单独当前元素组成子数组，
            max_sub_sum = max(nums[i], max(max_sub_sum, sum - prev_min));
            prev_min = min(prev_min, sum);
        }
        return max_sub_sum;
    }
};
```

202/202 cases passed (12 ms)
Your runtime beats 46.05 % of cpp submissions
Your memory usage beats 81.66 % of cpp submissions (9.2 MB)

二刷，修改后更简洁的代码

```c++
class Solution {
public:
    int maxSubArray(vector<int>& nums) {
        // dp[i]是以第i为结尾的连续子数组的最大和
        // dp[i]=max(dp[i-1]+nums[i], nums[i])
        // dp[i]只与dp[i-1]有关，所以用滚动变量
        int len = nums.size();
        int sum = nums[0];
        int max_sum = nums[0]; // 初始化第一个，因为子数组肯定要元素，然后从第二个开始遍历
        for (int i = 1; i < len; ++i) {
            // 仔细看状态转移方程，只需要判别dp[i-1]
            if (sum > 0) sum += nums[i];
            else sum = max(sum, nums[i]);
            max_sum = max(max_sum, sum);
        }
        return max_sum;
    }
};
```

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

### 152. 乘积最大子数组/最大子数组积/最大子段积(Medium) @hot100

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
        // 因为负负得正，所以还要维护最小值，最小值若为负数，可能在后面会变成正数
        // dp[i]表示以i结尾的最大乘积
        // max_dp[i] = MAX(max_dp[i-1]*nums[i], min_dp[i-1]*nums[i], nums[i])
        // min_dp[i] = MIN(max_dp[i-1]*nums[i], min_dp[i-1]*nums[i], nums[i])
        // dp只与前一状态有关，所以只需要维护两个变量即可
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
            ans = max(ans,  );
        }
        return ans;
    }
};
```

### 62. 不同路径(Medium) @hot100

一个机器人位于一个 m x n 网格的左上角 （起始点在下图中标记为“Start” ）。

机器人每次只能向下或者向右移动一步。机器人试图达到网格的右下角（在下图中标记为“Finish”）。

问总共有多少条不同的路径？

dp

```c++
class Solution {
public:
    int uniquePaths(int m, int n) {
        // dp[i][j] 到达i，j的不同路径
        // dp[i][j] = dp[i-1][j] + dp[i][j-1]
        vector<vector<int>> dp(m, vector<int>(n, 1));
        for (int i = 1; i < m; ++i) {
            for (int j = 1; j < n; ++j) {
                dp[i][j] = dp[i-1][j] + dp[i][j-1];
            }
        }
        return dp[m-1][n-1];
    }
};
```

二维数组可以压缩成一维滚动数组，因为当前dp[i]只与dp[i-1]有关，从左至右遍历

```c++
class Solution {
public:
    int uniquePaths(int m, int n) {
        // dp[i][j] 表示到达i，j的不同路径
        // dp[i][j] = dp[i-1][j] + dp[i][j-1]
        vector<int> dp(n, 1);
        for (int i = 1; i < m; ++i) {
            for (int j = 1; j < n; ++j) {
                dp[j] = dp[j] + dp[j-1];
            }
        }
        return dp[n-1];
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

### 64. 最小路径和(Medium) @hot100

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

### 70.爬楼梯(Easy) @hot100

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

稍微优化一下，改成线性的尾递归，可以通过，这是从左往右的递归，是线性的

```c++
class Solution {
public:
    int climbStairs(int n) {
        if (n == 1 || n == 2) return n;
        // dp[i] = dp[i-1] + dp[i-2]
        return helper(n, 1, 2, 3);
    }
    int helper(int n, int a, int b, int cur) {
        if (n == cur) {
            return a + b;
        }
        return helper(n, b, a+b, ++cur);
    }

};
```

时间复杂度：O(n)，树形递归的大小可以达到 n。
空间复杂度：O(n)，递归树的深度可以达到 n。

### 89. 格雷编码(Medium)

格雷编码是一个二进制数字系统，在该系统中，两个连续的数值仅有一个位数的差异。

给定一个代表编码总位数的非负整数 n，打印其格雷编码序列。即使有多个不同答案，你也只需要返回其中一种。

格雷编码序列必须以 0 开头。

示例 1:

输入: 2
输出: [0,1,3,2]
解释:
00 - 0
01 - 1
11 - 3
10 - 2

对于给定的 n，其格雷编码序列并不唯一。
例如，[0,2,3,1] 也是一个有效的格雷编码序列。

00 - 0
10 - 2
11 - 3
01 - 1
示例 2:

输入: 0
输出: [0]
解释: 我们定义格雷编码序列必须以 0 开头。
     给定编码总位数为 n 的格雷编码序列，其长度为 2n。当 n = 0 时，长度为 20 = 1。
     因此，当 n = 0 时，其格雷编码序列为 [0]。

```c++
// n = 0, [0]
// n = 1, [0,1] //新的元素1，为0+2^0
// n = 2, [0,1,3,2] // 新的元素[3,2]为[0,1]->[1,0]后分别加上2^1
// n = 3, [0,1,3,2,6,7,5,4] // 新的元素[6,7,5,4]为[0,1,3,2]->[2,3,1,0]后分别加上2^2->[6,7,5,4]
class Solution {
public:
    vector<int> grayCode(int n) {
        int shift = 1;
        vector<int> ans {0};
        for (int i = 0; i < n; ++i){
            for(int j = shift-1; j >= 0; --j){ //倒序遍历，并且加上一个值添加到结果中
                ans.push_back(ans[j] + shift);
            }
            shift <<= 1; //要加的数
        }
        return ans;
    }
};
```

### 118. 杨辉三角(Easy) @hot100

给定一个非负整数 numRows，生成杨辉三角的前 numRows 行。

在杨辉三角中，每个数是它左上方和右上方的数的和。

直接一把梭

```c++
class Solution {
public:
    vector<vector<int>> generate(int numRows) {
        if (numRows == 0) return {};
        if (numRows == 1) return {{1}};
        vector<vector<int>> ans;
        ans.push_back({1});
        ans.push_back({1, 1});
        for (int i = 2; i < numRows; ++i) { // 从第三行开始
            ans.push_back(vector<int>(i+1, 1));
            for (int j = 1; j <= i - 1; ++j) { // 填充level的中间数字
                ans[i][j] = ans[i-1][j-1] + ans[i-1][j];
            }
        }
        return ans;
    }
};
```

### 119. 杨辉三角 II(Easy)

给定一个非负索引 k，其中 k ≤ 33，返回杨辉三角的第 k 行。

在杨辉三角中，每个数是它左上方和右上方的数的和。

示例:

输入: 3
输出: [1,3,3,1]
进阶：

你可以优化你的算法到 O(k) 空间复杂度吗？

暴力构造

```c++
class Solution {
public:
    vector<int> getRow(int rowIndex) {
        if (rowIndex == 0) return {1};
        if (rowIndex == 1) return {1, 1};
        vector<vector<int>> ans;
        ans.push_back({1});
        ans.push_back({1, 1});
        for (int i = 2; i < rowIndex+1; ++i) { // 从第三行开始
            ans.push_back(vector<int>(i+1, 1));
            for (int j = 1; j <= i - 1; ++j) { // 填充level的中间数字
                ans[i][j] = ans[i-1][j-1] + ans[i-1][j];
            }
        }
        return ans[rowIndex];
    }
};
```

二维压缩成一维，画个图就好理解，特别是对应位置相加

```c++
class Solution {
public:
    vector<int> getRow(int rowIndex) {
        vector<int> kRows(rowIndex+1);
        for(int i = 0; i <= rowIndex; i++) { //利用前一行求后一行，第K行要循环K遍{
            kRows[i] = 1; //行末尾为1，第一次进入时行尾也是行首，后面不会更新行首了，行首永为1
            for(int j = i; j > 1; j--) { //每一行的更新过程
                    kRows[j-1] = kRows[j-2] + kRows[j-1];
            }
        }
        return kRows;
    }
};
```

然而，符合时间复杂度为O(k)的，只有二项式定理，因为c++下标从0开始，所以第k项其实是第k-1个下标，可以知道Cn k+1 = (n-k)/(k-1) * Cn k

[纯C 0ms 二项式解题 简单易懂](https://leetcode-cn.com/problems/pascals-triangle-ii/solution/chun-c-0ms-er-xiang-shi-jie-ti-jian-dan-yi-dong-by/)

```c++
class Solution {
public:
    vector<int> getRow(int rowIndex) {
        vector<int> res(rowIndex+1, 1);
        for(int i = 1; i <= rowIndex; ++i) {
            res[i] = (long long)res[i - 1] * (rowIndex - i + 1) / i;
        }
        return res;
    }
};
```

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

为了最后得到结果方便，从下往上计算，最后得到dp[0]即为最小结果（如果是从上往下，最后一层还得再遍历一次）

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

### 121.买卖股票的最佳时机(Easy) @hot100

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

二刷时，直接用变量解决了，记录一下之前扫描过的最低价格即可，如果当前价格低于之前最低价格，则更新最低价格

```c++
class Solution {
public:
    int maxProfit(vector<int>& prices) {
        if (prices.empty()) return 0;
        int size = prices.size();
        int max_profit = 0;
        int pre_min = prices[0];
        for (int i = 1; i < size; ++i) {
            if (prices[i] < pre_min) {
                pre_min = prices[i];
                continue;
            }
            if (prices[i] - pre_min > max_profit) {
                max_profit = prices[i] - pre_min;
            }
        }
        return max_profit;
    }
};
```

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

情况1：由于包含了根节点，所以不能选择左右儿子节点，这种情况的最大值为：当前节点 + 左儿子情况2 + 右情况2

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

### 322. 零钱兑换(Medium) @hot100 @背包

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

二刷，看答案有了更容易理解的解法

定义 F(i) 为组成金额 i 所需最少的硬币数量，假设在计算 F(i) 之前，我们已经计算出 F(0) ~ F(i−1) 的答案。 则 F(i) 对应的转移方程应为 F(i) = min F(i-cj) + 1

例子1：假设

coins = [1, 2, 5], amount = 11
则，当 i==0i==0 时无法用硬币组成，为 0 。当 i<0i<0 时，忽略 F(i)F(i)

F(i) 最小硬币数量
F(0)=0 //金额为0不能由硬币组成
F(1)=1 //F(1)=min(F(1-1),F(1-2),F(1-5))+1=1F(1)=min(F(1−1),F(1−2),F(1−5))+1=1
F(2)=1 //F(2)=min(F(2-1),F(2-2),F(2-5))+1=1F(2)=min(F(2−1),F(2−2),F(2−5))+1=1
F(3)=2 //F(3)=min(F(3-1),F(3-2),F(3-5))+1=2F(3)=min(F(3−1),F(3−2),F(3−5))+1=2
F(4)=2 //F(4)=min(F(4-1),F(4-2),F(4-5))+1=2F(4)=min(F(4−1),F(4−2),F(4−5))+1=2
...=...
F(11)=3 //F(11)=min(F(11-1),F(11-2),F(11-5))+1=3F(11)=min(F(11−1),F(11−2),F(11−5))+1=3

```c++
class Solution {
public:
    int coinChange(vector<int>& coins, int amount) {
        vector<int> dp(amount+1, amount+1); // 初始化成amount+1，是为了代替INT_MAX可能越界的问题，组成amount价值，肯定不会超过amount的硬币的，等价于INT_MAX
        dp[0] = 0;
        for (int i = 1; i <= amount; ++i) {
            for (int j = 0; j < coins.size(); ++j) {
                if (i >= coins[j]) {
                    dp[i] = min(dp[i], dp[i - coins[j]] + 1);
                }
            }
        }
        return dp[amount] > amount ? -1 : dp[amount];
    }
};
```

### 279. 完全平方数 @背包

给你一个整数 n ，返回 和为 n 的完全平方数的最少数量 。

完全平方数 是一个整数，其值等于另一个整数的平方；换句话说，其值等于一个整数自乘的积。例如，1、4、9 和 16 都是完全平方数，而 3 和 11 不是。

示例 1：

输入：n = 12
输出：3
解释：12 = 4 + 4 + 4
示例 2：

输入：n = 13
输出：2
解释：13 = 4 + 9

提示：

1 <= n <= 104

其实这题与零钱兑换很像，完全平方数就是硬币面额，这题要求最少的完全平方数数量，其实就跟最少得硬币数量是一样的

定义：dp[i]等于和为i的最少数量完全平方数的和，dp[1] = 1, dp[2] = 2(1+1), dp[3] = 3(1+1+1+1), dp[4] = 1(2^2), dp[5] = 2(2^2+1)

状态转移方程：这些数必然落在区间 [1,n]，我们可以枚举这些数，假设当前枚举到 j，那么我们还需要取若干数的平方，构成 i−j^2。此时我们发现该子问题和原问题类似，只是规模变小了。这符合了动态规划的要求，于是我们可以写出状态转移方程。

dp[i]=min(dp[i−k1],dp[i−k2],....dp[i−ki]) + 1

初始化：定义dp[0] = 0，虽然没有意义，但是在后面遇到k^2 = i的时候使用dp[i - k^2] = 0便于操作，然后从1开始往后递推即可

时间复杂度O(n根号n)，空间复杂度O(n)

```c++
class Solution {
public:
    int numSquares(int n) {
        vector<int> f(n + 1);
        for (int i = 1; i <= n; i++) {
            int minn = INT_MAX;
            for (int j = 1; j * j <= i; j++) {
                minn = min(minn, f[i - j * j]); // 枚举每个可能的dp[i-k1]
            }
            f[i] = minn + 1; // i = i - j^2 + j^2，所以dp[i] = dp[i-k] + 1
        }
        return f[n];
    }
};
```

### 139. 单词拆分(Medium) @hot100 @背包

给你一个字符串 s 和一个字符串列表 wordDict 作为字典。请你判断是否可以利用字典中出现的单词拼接出 s 。

注意：不要求字典中出现的单词全部都使用，并且字典中的单词可以重复使用。

示例 1：

输入: s = "leetcode", wordDict = ["leet", "code"]
输出: true
解释: 返回 true 因为 "leetcode" 可以由 "leet" 和 "code" 拼接成。
示例 2：

输入: s = "applepenapple", wordDict = ["apple", "pen"]
输出: true
解释: 返回 true 因为 "applepenapple" 可以由 "apple" "pen" "apple" 拼接成。
     注意，你可以重复使用字典中的单词。
示例 3：

输入: s = "catsandog", wordDict = ["cats", "dog", "sand", "and", "cat"]
输出: false
 
提示：

1 <= s.length <= 300
1 <= wordDict.length <= 1000
1 <= wordDict[i].length <= 20
s 和 wordDict[i] 仅有小写英文字母组成
wordDict 中的所有字符串 互不相同

刷hot100时，第一次尝试用回溯，从左到右依次尝试所有word，但是力扣给了个大输入，超时了，看讨论区，需要记忆化回溯，原始代码重复求解了很多状态，造成超时

```c++
class Solution {
public:
    int shortest = INT_MAX;
    set<string> hash;
    bool wordBreak(string s, vector<string>& wordDict) {
        for (string &word : wordDict) {
            shortest = min(shortest, (int)word.size());
            hash.insert(word);
        }
        int n = s.size();
        return backtrace(s, wordDict, 0, n);
    }

    bool backtrace(string &s, vector<string>& wordDict, int k, int n) {
        if (n == k) return true; // 拼到尾部了，拼接成功
        if (n - k  < shortest) return false; // 剩余长度小于wordDict最短字符串，肯定无法拼接出来，直接返回false
        for (string &word : wordDict) {
            if (word.size() > n - k) continue;
            if (word == s.substr(k, word.size())) {
                if (backtrace(s, wordDict, k + word.size(), n)) {
                    return true;
                }
            }
        }
        return false;
    }
};
```

记忆化回溯，AC

```c++
class Solution {
public:
    int shortest = INT_MAX;
    set<string> hash;
    vector<bool> visited;
    bool wordBreak(string s, vector<string>& wordDict) {
        for (string &word : wordDict) {
            shortest = min(shortest, (int)word.size());
            hash.insert(word);
        }
        int n = s.size();
        visited.resize(n + 1, false);
        return backtrace(s, wordDict, 0, n);
    }

    bool backtrace(string &s, vector<string>& wordDict, int k, int n) {
        if (n == k) return true; // 拼到尾部了，拼接成功
        if (n - k  < shortest) return false; // 剩余长度小于wordDict最短字符串，肯定无法拼接出来，直接返回false
        for (string &word : wordDict) {
            if (word.size() > n - k) continue;
            if (visited[k + word.size()]) continue; // 记忆化回溯，减少重复计算，访问过的肯定是不成功的
            if (word == s.substr(k, word.size())) {
                if (backtrace(s, wordDict, k + word.size(), n)) {
                    return true;
                }
                visited[k + word.size()] = true; // 记忆结果，因为为true直接返回了
            }
        }
        return false;
    }
};
```

dp，时间复杂度O(n^2)，空间复杂度O(n)

```c++
class Solution {
public:
    bool wordBreak(string s, vector<string>& wordDict) {
        // dp[i] = dp[i-k1] || dp[i-k2] || dp[i-k3] .... 
        // 字符串s从0到第i位，是否能够拼接出来，取决于它之前若干个状态是否能够拼接出来，用逻辑或计算
        // dp[i-k1]表示的是s[k1, i] ∈ wordDict
        if (wordDict.size() == 0) return false;
        int shortest = INT_MAX;
        int n = s.size();
        vector<bool> dp(n, false);
        for (string &word : wordDict) {
            int word_len = word.size();
            shortest = min(shortest, word_len);
            if (word == s.substr(0, word_len)) {
                dp[word_len-1] = true; // 初始化dp，从0下标开始，等于word的子串的末尾，记为可到达
            }
        }
        for (int i = shortest; i < n; ++i) {
            for (string &word : wordDict) {
                int word_len = word.size();
                if (i >= word_len && dp[i - word_len] == true) {
                    if (word == s.substr(i - word_len + 1, word_len)) {
                        dp[i] = true;
                        continue;
                    }
                }
            }
        }
        return dp[n-1];
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

### 416. 分割等和子集(Medium) @hot100 @背包

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

如果你能想到这个地方，再配上我们之前讲的 01 背包问题 的解法，那么这道题目就可以直接套解法了

状态定义：dp[i][j]表示从数组的 [0, i] 这个子区间内挑选一些正整数，每个数只能用一次，使得这些数的和恰好等于 j。

状态转移方程：很多时候，状态转移方程思考的角度是「分类讨论」，对于「0-1 背包问题」而言就是「当前考虑到的数字选与不选」。

- 不选择 nums[i]，如果在 [0, i - 1] 这个子区间内已经有一部分元素，使得它们的和为 j ，那么 dp[i][j] = true；
- 选择 nums[i]，如果在 [0, i - 1] 这个子区间内就得找到一部分元素，使得它们的和为 j - nums[i]。

状态转移方程：

```shell
dp[i][j] = dp[i - 1][j] or dp[i - 1][j - nums[i]]
```

```c++
class Solution {
public:
    bool canPartition(vector<int>& nums) {
        int sum = accumulate(nums.begin(), nums.end(), 0);
        if (sum % 2 == 1) return false;
        // 01背包问题，从一些数字中选择，使得和为target
        // dp[i][j]表示0..i能否组成和为j
        // dp[i][j] = dp[i-1][j] || dp[i-1][j-nums[i]] 分别对应不选当前nums[i]、和选当前nums[i]

        int target = sum / 2;
        int n = nums.size();
        vector<vector<bool>> dp(n, vector<bool>(target + 1, false));
        
        // 初始化第0行，只有这两个是true，代表在第0行，要么选第0个，要么不选第0个，所构成的背包价值：nums[0] or 0
        dp[0][0] = true;
        if (nums[0] <= target) {
            dp[0][nums[0]] = true;
        }

        for (int i = 1; i < n; ++i) {
            for (int j = 0; j <= target; ++j) {
                dp[i][j] = dp[i-1][j]; // 不选第i个
                if (j >= nums[i]) {
                    dp[i][j] = dp[i][j] | dp[i-1][j-nums[i]]; // 选第i个
                }
            }
        }
        return dp[n-1][target];
    }
};
```

二维数组压缩：

可以看到，上面的dp[i]只与dp[i-1]有关，所以可以将二维dp数组压缩成一维，滚动数组的概念，dp[j] = dp[j] | dp[j - nums[i]] 实际上是用的 i - 1 层 dp[j] 和 dp[j - nums[i]] 得出的。 因此，如果顺序遍历的话， dp[j - num[i]] 会首先被更新成新的值， 然后再算 dp[j] = dp[j] | dp[j - nums[i]] 就不对了， 所以要逆序遍历。

```c++
class Solution {
public:
    bool canPartition(vector<int>& nums) {
        int sum = accumulate(nums.begin(), nums.end(), 0);
        if (sum % 2 == 1) return false;
        // 01背包问题，从一些数字中选择，使得和为target
        // dp[i][j]表示0..i能否组成和为j
        // dp[i][j] = dp[i-1][j] || dp[i-1][j-nums[i]] 分别对应不选当前nums[i]、和选当前nums[i]

        int target = sum / 2;
        int n = nums.size();
        vector<bool> dp(target + 1, false);
        
        // 初始化第0行，只有这两个是true，代表在第0行，要么选第0个，要么不选第0个，所构成的背包价值：nums[0] or 0
        dp[0] = true;
        if (nums[0] <= target) {
            dp[nums[0]] = true;
        }

        for (int i = 1; i < n; ++i) {
            for (int j = target; j >= nums[i]; --j) { // 压缩成一维滚动数组后，原来二维做法中的if判断：j>=nums[i]变成了循环终止条件，相当于剪枝了
                // dp[i][j] = dp[i-1][j]; // 不选第i个，一位数组，就等于自身，不需要写代码了
                // if (j >= nums[i]) {
                    dp[j] = dp[j] | dp[j-nums[i]]; // 选第i个
                // }
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

(第二种状态定义) O(nm)，反向求解

f[i, j]表示用j个鸡蛋测量i次能测量的高度的最大值

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

leetcode ac

```c++
class Solution {
public:
    // k个鸡蛋，n层楼，问最坏情况需要多少次尝试
    int superEggDrop(int k, int n) {
        vector<vector<int>> f(n+1, vector<int>(k+1, 0));
        for (int i = 1; i <= n; i ++ ) {
            for (int j = 1; j <= k; j ++ )
                f[i][j] = f[i - 1][j] + f[i - 1][j - 1] + 1;    // 没碎 + 碎了 + 1（第k层）
            if (f[i][k] >= n) {                                 // 已经能测量出n层了，可以提前终止
                return i;
            }
        }
        // never runs here
        return k;
    }
};
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

### 300. 最长上升子序列(Medium) @hot100

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
        if (nums.empty()) return 0;
        int size = nums.size();
        vector<int> dp(size, 1); // 以nums[i]结尾的最长上升子序列
        int longest = 1;
        for (int i = 1; i < size; ++i) {
            for (int j = i - 1; j >= 0; --j) {
                if (nums[i] > nums[j]) {
                    // 如果nums[j] < nums[i]，则dp[i] = dp[j] + 1，遍历所有j<i的情况，取max
                    dp[i] = max(dp[i], dp[j] + 1);
                }
            }
            longest = max(longest, dp[i]);
        }
        return longest;
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

> 为什么要更新长度更少的子序列的最小值？**贪心**
> 这一步的意义，在于记录最小序列，代表了一种“最可能性”
例如[0,4,12,2,3,5]中，当判断到 nums[i] = 2时，d={0,4,12}，此时根据这个原则，会将4替换为2，即d更新为d={0,2,12}，虽然此时不会影响最长升序子序列的长度，但是这一步保存了之后有数字可以和{0,2}组成更长的升序子序列的可能性。例如，该数组的最长升序子序列为 {0,2,3,5}，刚好0,2}是这个子序列的前缀，也正是因为我们将 4 替换为了2，所以才保留了这种可能性，否则，遇到3时，将忽略这个数，从而计算错误。

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

二刷时，第二个思路还是做不出，第一个O(n^2)的解法倒是搞出来了，就记第一个吧

### 1143. 最长公共子序列(Medium) @hot100

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

定义：

dp[i][j]表示text1[0:i]和text2[0:j]的最长公共子序列的长度。

状态转移方程：

dp[i][j]=dp[i-1][j-1]+1; //text1[i-1]==text2[j-1]
dp[i][j]=max(dp[i-1][j],dp[i][j-1]); //text1[i-1]!=text2[j-1]

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
                if(word1[i-1] == word2[j-1]) dp[i][j] = dp[i-1][j-1];
                else dp[i][j] = min(min(dp[i-1][j]+1, dp[i][j-1]+1), dp[i-1][j-1]+1);
            }
        }
        return dp[n][m];
    }
};
```

## 设计

### 146. LRU缓存设计(Medium) @hot100

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

双向链表（存储）+哈希表+pair（存储key和value）

二刷时优化了一下逻辑，更好理解了

```c++
class LRUCache
{
public:
    typedef list<pair<int, int>> List;
    typedef list<pair<int, int>>::iterator ListIter;
    LRUCache(int capacity){
        capacity_ = capacity;
    }

    int get(int key){
        if (map.find(key) == map.end()){
            return -1;
        }
        int val = map[key]->second;
        doubleLinkedList.erase(map[key]); // 根据iter删除
        doubleLinkedList.push_front({key, val});
        map[key] = doubleLinkedList.begin();
        return map[key]->second;
    }

    void put(int key, int value){
        if (map.find(key) == map.end()){
            if (capacity_ == doubleLinkedList.size()){
                map.erase(doubleLinkedList.back().first); // 根据key删除
                doubleLinkedList.pop_back();
            }
            doubleLinkedList.push_front({key, value});
            map[key] = doubleLinkedList.begin();
        }
        else{
            doubleLinkedList.erase(map[key]); // 一定要在前面
            doubleLinkedList.push_front({key, value}); // 否则会erase刚删除的
            map[key] = doubleLinkedList.begin();
        }
    }

    int capacity_;
    List doubleLinkedList;
    unordered_map<int, ListIter> map;
};
```

刷hot100时，根据之前的笔记，用了更优雅的方法，在get方法中调用put方法

```c++
class LRUCache {
public:
    LRUCache(int capacity) {
        capacity_ = capacity;
    }
    
    int get(int key) {
        if (hash.count(key)) {
            int val = hash[key]->second;
            put(key, val);
            return val;
        }
        return -1;
    }
    
    void put(int key, int value) {
        if (hash.count(key)) { // 存在，先删除
            hot_list.erase(hash[key]);
        }
        if (hot_list.size() >= capacity_) { // 逐出最后元素
            hash.erase(hot_list.back().first);
            hot_list.pop_back();
        }
        // 更新最热kv
        hot_list.push_front(pair<int, int>(key, value));
        hash[key] = hot_list.begin();
    }
private:
    int capacity_;
    list<pair<int, int>> hot_list;
    unordered_map<int, list<pair<int, int>>::iterator> hash; // key -> host_list node
};

/**
 * Your LRUCache object will be instantiated and called as such:
 * LRUCache* obj = new LRUCache(capacity);
 * int param_1 = obj->get(key);
 * obj->put(key,value);
 */
```

### 225. 用队列实现栈

使用队列实现栈的下列操作：

push(x) -- 元素 x 入栈
pop() -- 移除栈顶元素
top() -- 获取栈顶元素
empty() -- 返回栈是否为空
注意:

你只能使用队列的基本操作-- 也就是 push to back, peek/pop from front, size, 和 is empty 这些操作是合法的。
你所使用的语言也许不支持队列。 你可以使用 list 或者 deque（双端队列）来模拟一个队列 , 只要是标准的队列操作即可。
你可以假设所有操作都是有效的（例如, 对一个空的栈不会调用 pop 或者 top 操作）。

想了一会，仿照用两个栈实现队列的思路，插入O(n)，弹出O(1)

```c++
class MyStack {
public:
    /** Initialize your data structure here. */
    MyStack() {

    }

    /** Push element x onto stack. */
    void push(int x) {
        if (q1.empty()) {
            q1.push(x);
            while (!q2.empty()) {
                q1.push(q2.front());
                q2.pop();
            }
        } else {
            q2.push(x);
            while (!q1.empty()) {
                q2.push(q1.front());
                q1.pop();
            }
        }
    }

    /** Removes the element on top of the stack and returns that element. */
    int pop() {
        if (!q1.empty()) {
            int front = q1.front();
            q1.pop();
            return front;
        } else {
            int front = q2.front();
            q2.pop();
            return front;
        }
    }

    /** Get the top element. */
    int top() {
        if (!q1.empty()) {
            return q1.front();
        } else {
            return q2.front();
        }
    }

    /** Returns whether the stack is empty. */
    bool empty() {
        return q1.empty() && q2.empty();
    }
    queue<int> q1, q2;
};

/**
 * Your MyStack object will be instantiated and called as such:
 * MyStack* obj = new MyStack();
 * obj->push(x);
 * int param_2 = obj->pop();
 * int param_3 = obj->top();
 * bool param_4 = obj->empty();
 */
```

看力扣评论区，才发现可以用单队列，贼简单，只要保持插入时的新元素在队列头部即可

```c++
class MyStack {
public:
    /** Initialize your data structure here. */
    MyStack() {

    }

    /** Push element x onto stack. */
    void push(int x) {
        int len = q.size();
        q.push(x);
        for (int i = 0; i < len; ++i) {
            q.push(q.front());
            q.pop();
        }
    }

    /** Removes the element on top of the stack and returns that element. */
    int pop() {
        int front = q.front();
        q.pop();
        return front;
    }

    /** Get the top element. */
    int top() {
        return q.front();
    }

    /** Returns whether the stack is empty. */
    bool empty() {
        return q.empty();
    }
    queue<int> q;
};
```

### 232. 用栈实现队列

使用栈实现队列的下列操作：

push(x) -- 将一个元素放入队列的尾部。
pop() -- 从队列首部移除元素。
peek() -- 返回队列首部的元素。
empty() -- 返回队列是否为空。

说明:

你只能使用标准的栈操作 -- 也就是只有 push to top, peek/pop from top, size, 和 is empty 操作是合法的。
你所使用的语言也许不支持栈。你可以使用 list 或者 deque（双端队列）来模拟一个栈，只要是标准的栈操作即可。
假设所有操作都是有效的 （例如，一个空的队列不会调用 pop 或者 peek 操作）。

```c++
class MyQueue {
public:
    /** Initialize your data structure here. */
    MyQueue() {

    }

    /** Push element x to the back of queue. */
    void push(int x) {
        stack1.push(x);
    }

    /** Removes the element from in front of queue and returns that element. */
    int pop() {
        if (stack2.empty()) {
            while (!stack1.empty()) {
                stack2.push(stack1.top());
                stack1.pop();
            }
        }
        int top = stack2.top();
        stack2.pop();
        return top;
    }

    /** Get the front element. */
    int peek() {
        if (stack2.empty()) {
            while (!stack1.empty()) {
                stack2.push(stack1.top());
                stack1.pop();
            }
        }
        return stack2.top();
    }

    /** Returns whether the queue is empty. */
    bool empty() {
        return stack1.empty() && stack2.empty();
    }
    stack<int> stack1;
    stack<int> stack2;
};

/**
 * Your MyQueue object will be instantiated and called as such:
 * MyQueue* obj = new MyQueue();
 * obj->push(x);
 * int param_2 = obj->pop();
 * int param_3 = obj->peek();
 * bool param_4 = obj->empty();
 */
```

### 460. LFU(Hard)

请你为 最不经常使用（LFU）缓存算法设计并实现数据结构。它应该支持以下操作：get 和 put。

get(key) - 如果键存在于缓存中，则获取键的值（总是正数），否则返回 -1。
put(key, value) - 如果键已存在，则变更其值；如果键不存在，请插入键值对。当缓存达到其容量时，则应该在插入新项之前，使最不经常使用的项无效。在此问题中，当存在平局（即两个或更多个键具有相同使用频率）时，应该去除最久未使用的键。
「项的使用次数」就是自插入该项以来对其调用 get 和 put 函数的次数之和。使用次数会在对应项被移除后置为 0 。

进阶：你是否可以在 O(1) 时间复杂度内执行两项操作？

双哈希表+链表

我们定义两个哈希表，第一个 freq_table 以频率 freq 为索引，每个索引存放一个双向链表，这个链表里存放所有使用频率为 freq 的缓存，缓存里存放三个信息，分别为键 key，值 value，以及使用频率 freq。第二个 key_table 以键值 key 为索引，每个索引存放对应缓存在 freq_table 中链表里的内存地址，这样我们就能利用两个哈希表来使得两个操作的时间复杂度均为 O(1)O(1)。同时需要记录一个当前缓存最少使用的频率 minFreq，这是为了删除操作服务的。

对于 get(key) 操作，我们能通过索引 key 在 key_table 中找到缓存在 freq_table 中的链表的内存地址，如果不存在直接返回 -1，否则我们能获取到对应缓存的相关信息，这样我们就能知道缓存的键值还有使用频率，直接返回 key 对应的值即可。

但是我们注意到 get 操作后这个缓存的使用频率加一了，所以我们需要更新缓存在哈希表 freq_table 中的位置。已知这个缓存的键 key，值 value，以及使用频率 freq，那么该缓存应该存放到 freq_table 中 freq + 1 索引下的链表中。所以我们在当前链表中 O(1)O(1) 删除该缓存对应的节点，根据情况更新 minFreq 值，然后将其O(1)O(1) 插入到 freq + 1 索引下的链表头完成更新。这其中的操作复杂度均为 O(1)O(1)。你可能会疑惑更新的时候为什么是插入到链表头，这其实是为了保证缓存在当前链表中从链表头到链表尾的插入时间是有序的，为下面的删除操作服务。

对于 put(key, value) 操作，我们先通过索引 key在 key_table 中查看是否有对应的缓存，如果有的话，其实操作等价于 get(key) 操作，唯一的区别就是我们需要将当前的缓存里的值更新为 value。如果没有的话，相当于是新加入的缓存，如果缓存已经到达容量，需要先删除最近最少使用的缓存，再进行插入。

先考虑插入，由于是新插入的，所以缓存的使用频率一定是 1，所以我们将缓存的信息插入到 freq_table 中 1 索引下的列表头即可，同时更新 key_table[key] 的信息，以及更新 minFreq = 1。

那么剩下的就是删除操作了，由于我们实时维护了 minFreq，所以我们能够知道 freq_table 里目前最少使用频率的索引，同时因为我们保证了链表中从链表头到链表尾的插入时间是有序的，所以 freq_table[minFreq] 的链表中链表尾的节点即为使用频率最小且插入时间最早的节点，我们删除它同时根据情况更新 minFreq ，整个时间复杂度均为 O(1)O(1)。

```c++
// 缓存的节点信息
struct Node {
    int key, val, freq;
    Node(int _key,int _val,int _freq): key(_key), val(_val), freq(_freq){}
};
class LFUCache {
    int minfreq, capacity;
    unordered_map<int, list<Node>::iterator> key_table; // 指向freq_table的list
    unordered_map<int, list<Node>> freq_table;
public:
    LFUCache(int _capacity) {
        minfreq = 0;
        capacity = _capacity;
        key_table.clear();
        freq_table.clear();
    }
    int get(int key) {
        if (capacity == 0) return -1;
        auto it = key_table.find(key);
        if (it == key_table.end()) return -1;
        auto node = it -> second;
        int val = node -> val, freq = node -> freq;
        freq_table[freq].erase(node);
        // 如果当前链表为空，我们需要在哈希表中删除，且更新minFreq
        if (freq_table[freq].size() == 0) {
            freq_table.erase(freq);
            if (minfreq == freq) minfreq += 1;
        }
        // 插入到 freq + 1 中
        freq_table[freq + 1].push_front(Node(key, val, freq + 1));
        key_table[key] = freq_table[freq + 1].begin();
        return val;
    }
    void put(int key, int value) {
        if (capacity == 0) return;
        auto it = key_table.find(key);
        if (it == key_table.end()) {
            // 缓存已满，需要进行删除操作
            if (key_table.size() == capacity) {
                // 通过 minFreq 拿到 freq_table[minFreq] 链表的末尾节点
                auto it2 = freq_table[minfreq].back();
                key_table.erase(it2.key);
                freq_table[minfreq].pop_back();
                if (freq_table[minfreq].size() == 0) {
                    freq_table.erase(minfreq);
                }
            }
            freq_table[1].push_front(Node(key, value, 1));
            key_table[key] = freq_table[1].begin();
            minfreq = 1;
        } else {
            // 与 get 操作基本一致，除了需要更新缓存的值
            auto node = it -> second;
            int freq = node -> freq;
            freq_table[freq].erase(node);
            if (freq_table[freq].size() == 0) {
                freq_table.erase(freq);
                if (minfreq == freq) minfreq += 1;
            }
            freq_table[freq + 1].push_front(Node(key, value, freq + 1));
            key_table[key] = freq_table[freq + 1].begin();
        }
    }
};
```

### 1206. 设计跳表(Hard)

不使用任何库函数，设计一个 跳表 。

跳表 是在 O(log(n)) 时间内完成增加、删除、搜索操作的数据结构。跳表相比于树堆与红黑树，其功能与性能相当，并且跳表的代码长度相较下更短，其设计思想与链表相似。

例如，一个跳表包含 [30, 40, 50, 60, 70, 90] ，然后增加 80、45 到跳表中，以下图的方式操作：

Artyom Kalinin [CC BY-SA 3.0], via Wikimedia Commons

跳表中有很多层，每一层是一个短的链表。在第一层的作用下，增加、删除和搜索操作的时间复杂度不超过 O(n)。跳表的每一个操作的平均时间复杂度是 O(log(n))，空间复杂度是 O(n)。

了解更多 : https://en.wikipedia.org/wiki/Skip_list

在本题中，你的设计应该要包含这些函数：

bool search(int target) : 返回target是否存在于跳表中。
void add(int num): 插入一个元素到跳表。
bool erase(int num): 在跳表中删除一个值，如果 num 不存在，直接返回false. 如果存在多个 num ，删除其中任意一个即可。
注意，跳表中可能存在多个相同的值，你的代码需要处理这种情况。

示例 1:

```shell
输入
["Skiplist", "add", "add", "add", "search", "add", "search", "erase", "erase", "search"]
[[], [1], [2], [3], [0], [4], [1], [0], [1], [1]]
输出
[null, null, null, null, false, null, true, false, true, false]

解释
Skiplist skiplist = new Skiplist();
skiplist.add(1);
skiplist.add(2);
skiplist.add(3);
skiplist.search(0);   // 返回 false
skiplist.add(4);
skiplist.search(1);   // 返回 true
skiplist.erase(0);    // 返回 false，0 不在跳表中
skiplist.erase(1);    // 返回 true
skiplist.search(1);   // 返回 false，1 已被擦除
```

提示:

0 <= num, target <= 2 * 104
调用search, add,  erase操作次数不大于 5 * 104 

这个答案好记，用一个find辅助函数

```c++
class Skiplist {
public:
    static const int level = 8; // 层数，经验值 8，太大浪费空间，因为每一个节点都要存在每一层的 next，层数越多节点数越多

    // 定义跳表节点
    struct Node {
        int val; // 节点值
        vector<Node*> next; // 记录节点在每一层的 next，next[i] 表示当前节点第 i 层的 next

        Node(int _val) : val(_val) { // 构造函数
            next.resize(level, NULL); // 初始化 next 数组的大小和层数 level 相同，初始值都指向 NULL
        }
    } *head; // 定义头节点 head

    Skiplist() {
        head = new Node(-1); // 初始化一个不存在的节点值 -1
    }

    ~Skiplist() {
        delete head; // 析构函数删除 head
    }

    // 辅助函数：找到每一层 i 小于目标值 target 的最大节点 pre[i]，最后 pre 中存的就是每一层小于 target 的最大节点
    void find(int target, vector<Node*>& pre) {
        auto p = head; // 从头节点开始遍历每一层
        for (int i = level - 1; i >= 0; i -- ) { // 从上层往下层找
            while (p->next[i] && p->next[i]->val < target) p = p->next[i]; // 如果当前层 i 的 next 不为空，且它的值小于 target，则 p 往后走指向这一层 p 的 next
            pre[i] = p; // 退出 while 时说明找到了第 i 层小于 target 的最大节点就是 p
        }
    }
    
    // 从跳表中查找 target
    bool search(int target) {
        vector<Node*> pre(level);
        find(target, pre); // 先找到每一层 i 小于目标值 target 的最大节点 pre[i]
        
        auto p = pre[0]->next[0]; // 因为最下层【0】的节点是全的，所以只需要判断 target 是否在第 0 层即可，而 pre[0] 正好就是小于 target 的最大节点，如果 pre[0]->next[0] 的值不是 target 说明没有这个元素
        return p && p->val == target;
    }
    
    // 向跳表中插入元素 num
    void add(int num) {
        vector<Node*> pre(level);
        find(num, pre); // 先找到每一层 i 小于目标值 target 的最大节点 pre[i]

        auto p = new Node(num); // 创建要插入的新节点
        for (int i = 0; i < level; i ++ ) { // 遍历每一层，从下往上插入新节点
            p->next[i] = pre[i]->next[i]; // 这两步就是单链表的插入
            pre[i]->next[i] = p;
            if (rand() % 2) break; // 每一层有 50% 的概率不插入新节点
        }
    }
    
    // 从跳表中删除 num
    bool erase(int num) {
        vector<Node*> pre(level);
        find(num, pre); // 先找到每一层 i 小于目标值 target 的最大节点 pre[i]

        // 先判断 num 是否存在，不存在直接返回 false
        // 第 0 层存储的是全部节点，所以只需要判断 pre[0]->next[0]（第 0 层小于 num 的最大节点的在第 0 层的 next） 是不是 num 即可
        auto p = pre[0]->next[0];
        if (!p || p->val != num) return false;

        // 否则删除每一层的 num，如果 pre[i]->next[i] == p 说明第 i 层存在 p
        for (int i = 0; i < level && pre[i]->next[i] == p; i ++ ) {
            pre[i]->next[i] = p->next[i]; // 单链表删除
        }

        delete p; // 删除节点 p，防止内存泄漏

        return true;
    }
};

/**
 * Your Skiplist object will be instantiated and called as such:
 * Skiplist* obj = new Skiplist();
 * bool param_1 = obj->search(target);
 * obj->add(num);
 * bool param_3 = obj->erase(num);
 */

作者：tonngw
链接：https://leetcode.cn/problems/design-skiplist/solutions/1699167/by-tonngw-ls2k/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

## 图论

### 207. 课程表(Medium) @hot100

你这个学期必须选修 numCourses 门课程，记为 0 到 numCourses - 1 。

在选修某些课程之前需要一些先修课程。 先修课程按数组 prerequisites 给出，其中 prerequisites[i] = [ai, bi] ，表示如果要学习课程 ai 则 必须 先学习课程  bi 。

例如，先修课程对 [0, 1] 表示：想要学习课程 0 ，你需要先完成课程 1 。
请你判断是否可能完成所有课程的学习？如果可以，返回 true ；否则，返回 false 。

示例 1：

输入：numCourses = 2, prerequisites = [[1,0]]
输出：true
解释：总共有 2 门课程。学习课程 1 之前，你需要完成课程 0 。这是可能的。
示例 2：

输入：numCourses = 2, prerequisites = [[1,0],[0,1]]
输出：false
解释：总共有 2 门课程。学习课程 1 之前，你需要先完成​课程 0 ；并且学习课程 0 之前，你还应先完成课程 1 。这是不可能的。

提示：

1 <= numCourses <= 105
0 <= prerequisites.length <= 5000
prerequisites[i].length == 2
0 <= ai, bi < numCourses
prerequisites[i] 中的所有课程对 互不相同

**方法一：拓扑排序——广度优先搜索（从入度思考(从前往后排序)**

每门课程相当于是节点，依赖关系是边，二者构成了一个有向图。

入度：每个课程节点的入度数量等于其先修课程的数量；
出度：每个课程节点的出度数量等于其指向的后续课程数量；

> 要想学习一门课程，必须先学习完其所有的先修课程，所以只有当一个课程节点的入度为零时，其才是一个可以学习的自由课程。因此要想学完所有的课程，就看能否找到一个满足依赖关系的学习顺序。

拓扑排序即是将一个无环有向图转换为线性排序的过程。

拓扑序列算法思想:

- 从有向图中选取一个没有前驱(即入度为0)的顶点，并输出之;
- 从有向图中删去此顶点以及所有以它为尾的弧;
- 重复上述两步，直至图空，或者图不空但找不到无前驱的顶点为止。

广度优先遍历有向图需要的准备：

- 入度数组：课号 0 到 numCourses 作为索引，通过遍历先决条件表求出对应的初始入度
- 邻接表：二维数组adjacency，记录每门课程的后续课程有哪些。
- 辅助队列：存放入度为零的课程节点（可自由学习的课程）
- 入队：当某个课程的入度为零，则可被自由学习；
- 出队：已经学习了的课程数加一，其所有后续课程的入度减一；

结果判定：因为队列是先入先出，所以出队的顺序即是学习课程的拓扑排序。如果出队的次数count等于课程总数，则证明可以完成所有课程的学习。

时间复杂度: O(n+m)，其中 n 为课程数，m 为先修课程的要求数。这其实就是对图进行广度优先搜索的时间复杂度。

空间复杂度: O(n+m)。题目中是以列表形式给出的先修课程关系，为了对图进行广度优先搜索，我们需要存储成邻接表的形式，空间复杂度为 O(n+m)。在广度优先搜索的过程中，我们需要最多 O(n) 的队列空间（迭代）进行广度优先搜索。因此总空间复杂度为 O(n+m)。

```c++
class Solution {
public:
    bool canFinish(int numCourses, vector<vector<int>>& prerequisites) {
        int n = prerequisites.size();
        if (n == 0) return true; // 没有依赖关系，必然能完成所有课程的学习
        vector<int> indegree(numCourses);           // 每个节点的入度
        vector<vector<int> > adjacency(numCourses); // 邻接矩阵：先修课程-->(后续课程集合)
        queue<int> q;                            // 辅助队列，存放入度为0的节点
        // 统计所有节点的入度，构建邻接矩阵
        for (int i = 0; i < n; i++) {
            indegree[prerequisites[i][0]]++;
            adjacency[prerequisites[i][1]].push_back(prerequisites[i][0]);
        }
        // 将所有入度为0的节点加入队列，入度为0的节点意味着没有先修课程的自由课程
        for (int i = 0; i < numCourses; i++) {
            if (indegree[i] == 0) q.push(i);
        }
        int count = 0;                              // 已学的课程数
        while (!q.empty()) {
            int visited = q.front();             // 当前学习的课程
            count++;
            q.pop();                             // 学完，出队
            // 将刚学完的课程的所有后续课程的入度减一
            for (int i = 0; i < adjacency[visited].size(); i++) {
                indegree[adjacency[visited][i]]--;
                // 如果有后续课程的入度减为零了，则其变为了自由课程，加入队列
                if (indegree[adjacency[visited][i]] == 0)
                    q.push(adjacency[visited][i]);
            }
        }
        // 如果学完的课程数=课程总数则返回true，否则返回false
        return count == numCourses;
    }
};
```

**方法二：拓扑排序-深度优先搜索（ 从出度思考(从后往前排序)， 出度为0的节点在拓扑排序中一定排在后面, 然后删除和该节点对应的边, 迭代寻找出度为0的节点。**

思路：我们可以将深度优先搜索的流程与拓扑排序的求解联系起来，用一个栈来存储所有已经搜索完成的节点。

对于一个节点 u，如果它的所有相邻节点都已经搜索完成，那么在搜索回溯到 u 的时候，u 本身也会变成一个已经搜索完成的节点。这里的「相邻节点」指的是从 u 出发通过一条有向边可以到达的所有节点。

假设我们当前搜索到了节点 u，如果它的所有相邻节点都已经搜索完成，那么这些节点都已经在栈中了，此时我们就可以把 u 入栈。可以发现，如果我们从栈顶往栈底的顺序看，由于 u 处于栈顶的位置，那么 u 出现在所有 u 的相邻节点的前面。因此对于 u 这个节点而言，它是满足拓扑排序的要求的。

这样以来，我们对图进行一遍深度优先搜索。当每个节点进行回溯的时候，我们把该节点放入栈中。最终从栈顶到栈底的序列就是一种拓扑排序。

算法

对于图中的任意一个节点，它在搜索的过程中有三种状态，即：

- 「未搜索」：我们还没有搜索到这个节点；
- 「搜索中」：我们搜索过这个节点，但还没有回溯到该节点，即该节点还没有入栈，还有相邻的节点没有搜索完成）；
- 「已完成」：我们搜索过并且回溯过这个节点，即该节点已经入栈，并且所有该节点的相邻节点都出现在栈的更底部的位置，满足拓扑排序的要求。

通过上述的三种状态，我们就可以给出使用深度优先搜索得到拓扑排序的算法流程，在每一轮的搜索搜索开始时，我们任取一个「未搜索」的节点开始进行深度优先搜索。

我们将当前搜索的节点 u 标记为「搜索中」，遍历该节点的每一个相邻节点 v：

- 如果 v 为「未搜索」，那么我们开始搜索 v，待搜索完成回溯到 u；
- 如果 v 为「搜索中」，那么我们就找到了图中的一个环，因此是不存在拓扑排序的；
- 如果 v 为「已完成」，那么说明 v 已经在栈中了，而 u 还不在栈中，因此 u 无论何时入栈都不会影响到 (u,v) 之前的拓扑关系，以及不用进行任何操作。

当 u 的所有相邻节点都为「已完成」时，我们将 u 放入栈中，并将其标记为「已完成」。

在整个深度优先搜索的过程结束后，如果我们没有找到图中的环，那么栈中存储这所有的 n 个节点，**从栈顶到栈底的顺序即为一种拓扑排序**。

```c++
class Solution {
private:
    vector<vector<int>> edges; // edges[i]表示第i个课程的后序课程数组
    vector<int> visited;
    bool valid = true;

public:
    void dfs(int u) {
        visited[u] = 1; // 1表示搜索中
        for (int v: edges[u]) { // 搜索u的后续课程，u->v
            if (visited[v] == 0) {
                dfs(v);
                if (!valid) {
                    return;
                }
            } else if (visited[v] == 1) { // 不满足拓扑排序，有环！
                valid = false;
                return;
            }
        }
        visited[u] = 2; // 2表示搜索完成
    }

    bool canFinish(int numCourses, vector<vector<int>>& prerequisites) {
        edges.resize(numCourses);
        visited.resize(numCourses); // 初始化成0，表示未搜索
        for (const auto& pre: prerequisites) {
            edges[pre[1]].push_back(pre[0]); 
        }
        for (int i = 0; i < numCourses && valid; ++i) { // valid提前结束
            if (!visited[i]) {
                dfs(i);
            }
        }
        return valid;
    }
};
```

刷hot100时刷到，想着用简单的dfs做，但是没法判断成环，下面是错误代码

```c++
class Solution {
public:
    struct Node {
        int val;
        vector<Node*> pres; // 代表当前课程的先修课程
        Node(int v) : val(v), pres(vector<Node*>()) {}
    };
    bool canFinish(int numCourses, vector<vector<int>>& prerequisites) {
        if (prerequisites.empty()) return true;
        map<int, Node*> nodes;
        for (int i = 0; i < numCourses; ++i) {
            Node* node = new Node(i);
            nodes[i] = node;
        }
        for (const auto &pre : prerequisites) {
            nodes[pre[0]]->pres.push_back(nodes[pre[1]]);
        }
        for (auto it = nodes.begin(); it != nodes.end(); ++it) {
            if (!it->second->pres.empty()) { // 该课程有先修课程，dfs判断是否会回到自身
                bool hasCycle = curNodeHasCycle(numCourses, it->second, nodes);
                if (hasCycle) return false;
            }
        }
        return true;
    }

    bool curNodeHasCycle(int numCourses, Node* root, const map<int, Node*> &nodes) {
        set<Node*> visited;
        stack<Node*> st;
        st.push(root);
        while (!st.empty()) {
            Node* cur = st.top();
            st.pop();
            if (visited.count(cur)) { // 以为这样判断就可以不成环了，但是没注意有很多种路径从A到B，所以确实可能会多次访问
                return true;
            }
            visited.insert(cur);
            if (!cur->pres.empty()) {
                int n = cur->pres.size();
                for (int i = 0; i < n; ++i) {
                    st.push(cur->pres[i]);
                }
            }
        }
        return false;
    }
};
```

### 208. 实现 Trie (前缀树)(Medium) @hot100

Trie（发音类似 "try"）或者说 前缀树 是一种树形数据结构，用于高效地存储和检索字符串数据集中的键。这一数据结构有相当多的应用情景，例如自动补完和拼写检查。

请你实现 Trie 类：

Trie() 初始化前缀树对象。
void insert(String word) 向前缀树中插入字符串 word 。
boolean search(String word) 如果字符串 word 在前缀树中，返回 true（即，在检索之前已经插入）；否则，返回 false 。
boolean startsWith(String prefix) 如果之前已经插入的字符串 word 的前缀之一为 prefix ，返回 true ；否则，返回 false 。

示例：

输入
["Trie", "insert", "search", "search", "startsWith", "insert", "search"]
[[], ["apple"], ["apple"], ["app"], ["app"], ["app"], ["app"]]
输出
[null, null, true, false, true, null, true]

解释
Trie trie = new Trie();
trie.insert("apple");
trie.search("apple");   // 返回 True
trie.search("app");     // 返回 False
trie.startsWith("app"); // 返回 True
trie.insert("app");
trie.search("app");     // 返回 True

提示：

1 <= word.length, prefix.length <= 2000
word 和 prefix 仅由小写英文字母组成
insert、search 和 startsWith 调用次数 总计 不超过 3 * 104 次

刷hot100时，AC了，自己构建树，这里只有26个小写英文字母，ends与vals貌似可以省略，vals用nexts来代替即可

时间
48 ms
击败
87.8%
内存
44.1 MB
击败
57.58%

```c++
class Trie {
public:
    struct Alphabet {
        bool ends[26]; // 记录当前小写英文字母是否是插入字符串的最后一个字符
        bool vals[26]; // 记录当前字符是否存在于插入字符串
        Alphabet *nexts[26];
        Alphabet() {
            for (int t = 0; t < 26; ++t) {
                ends[t] = false;
                vals[t] = false;
                nexts[t] = nullptr;
            }
        }
    };
    Trie() {
        alphabet = new Alphabet;
        for (int i = 0; i < 26; ++i) {
            alphabet->ends[i] = false;
            alphabet->vals[i] = false;
            alphabet->nexts[i] = nullptr;
        }
    }
    
    void insert(string word) {
        Alphabet *cur = alphabet;
        int n = word.size();
        for (int i = 0; i < n; ++i) {
            int alpha_index = word[i] - 'a';
            cur->vals[alpha_index] = true;
            if (i == n - 1) {
                cur->ends[alpha_index] = true; // 结尾字符
            } else if (cur->nexts[alpha_index] == nullptr) { // 初始化下一层
                cur->nexts[alpha_index] = new Alphabet;
            }
            cur = cur->nexts[alpha_index];
        }
    }
    
    bool search(string word) {
        Alphabet *cur = alphabet;
        int n = word.size();
        for (int i = 0; i < n; ++i) {
            int alpha_index = word[i] - 'a';
            if (cur->vals[alpha_index] == false) return false;
            if (i == n - 1){
                if (cur->ends[alpha_index] == false) {
                    return false;
                }
            } else if (cur->nexts[alpha_index] == nullptr){
                return false;
            }
            cur = cur->nexts[alpha_index];
        }
        return true;
    }
    
    bool startsWith(string prefix) {
        Alphabet *cur = alphabet;
        int n = prefix.size();
        for (int i = 0; i < n; ++i) {
            int alpha_index = prefix[i] - 'a';
            if (cur->vals[alpha_index] == false) return false;
            if (i != n - 1 && cur->nexts[alpha_index] == nullptr) return false;
            cur = cur->nexts[alpha_index];
        }
        return true;
    }
private:
    Alphabet *alphabet;
};

/**
 * Your Trie object will be instantiated and called as such:
 * Trie* obj = new Trie();
 * obj->insert(word);
 * bool param_2 = obj->search(word);
 * bool param_3 = obj->startsWith(prefix);
 */
```

官方题解有更优雅的解法，Trie本身就是一个节点

```c++
class Trie {
private:
    vector<Trie*> children;
    bool isEnd;

    Trie* searchPrefix(string prefix) {
        Trie* node = this;
        for (char ch : prefix) {
            ch -= 'a';
            if (node->children[ch] == nullptr) {
                return nullptr;
            }
            node = node->children[ch];
        }
        return node;
    }

public:
    Trie() : children(26), isEnd(false) {}

    void insert(string word) {
        Trie* node = this;
        for (char ch : word) {
            ch -= 'a';
            if (node->children[ch] == nullptr) {
                node->children[ch] = new Trie();
            }
            node = node->children[ch];
        }
        node->isEnd = true;
    }

    bool search(string word) {
        Trie* node = this->searchPrefix(word);
        return node != nullptr && node->isEnd;
    }

    bool startsWith(string prefix) {
        return this->searchPrefix(prefix) != nullptr;
    }
};

作者：力扣官方题解
链接：https://leetcode.cn/problems/implement-trie-prefix-tree/solutions/717239/shi-xian-trie-qian-zhui-shu-by-leetcode-ti500/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

### 1263. 推箱子（Hard

「推箱子」是一款风靡全球的益智小游戏，玩家需要将箱子推到仓库中的目标位置。

游戏地图用大小为 m x n 的网格 grid 表示，其中每个元素可以是墙、地板或者是箱子。

现在你将作为玩家参与游戏，按规则将箱子 'B' 移动到目标位置 'T' ：

玩家用字符 'S' 表示，只要他在地板上，就可以在网格中向上、下、左、右四个方向移动。
地板用字符 '.' 表示，意味着可以自由行走。
墙用字符 '#' 表示，意味着障碍物，不能通行。 
箱子仅有一个，用字符 'B' 表示。相应地，网格上有一个目标位置 'T'。
玩家需要站在箱子旁边，然后沿着箱子的方向进行移动，此时箱子会被移动到相邻的地板单元格。记作一次「推动」。
玩家无法越过箱子。
返回将箱子推到目标位置的最小 推动 次数，如果无法做到，请返回 -1。

输入：grid = [["#","#","#","#","#","#"],
             ["#","T","#","#","#","#"],
             ["#",".",".","B",".","#"],
             ["#",".","#","#",".","#"],
             ["#",".",".",".","S","#"],
             ["#","#","#","#","#","#"]]
输出：3
解释：我们只需要返回推箱子的次数。
示例 2：

输入：grid = [["#","#","#","#","#","#"],
             ["#","T","#","#","#","#"],
             ["#",".",".","B",".","#"],
             ["#","#","#","#",".","#"],
             ["#",".",".",".","S","#"],
             ["#","#","#","#","#","#"]]
输出：-1
示例 3：

输入：grid = [["#","#","#","#","#","#"],
             ["#","T",".",".","#","#"],
             ["#",".","#","B",".","#"],
             ["#",".",".",".",".","#"],
             ["#",".",".",".","S","#"],
             ["#","#","#","#","#","#"]]
输出：5
解释：向下、向左、向左、向上再向上。

提示：

m == grid.length
n == grid[i].length
1 <= m, n <= 20
grid 仅包含字符 '.', '#',  'S' , 'T', 以及 'B'。
grid 中 'S', 'B' 和 'T' 各只能出现一个。

直接看题解吧

由题意可知，目标位置固定时，将箱子推到目标位置的最小推动次数与箱子位置和玩家位置相关。我们把箱子位置和玩家位置当成一个状态，那么状态的转移主要由玩家向上、下、左、右四个方向移动触发（如果玩家移动后的位置与箱子位置重叠，那么箱子也相应的作出同样的移动，即一次“推动”）。我们把状态看成有向图的节点，状态的转移看成有向图的边，对应的边长与是否推动箱子有关（推动箱子时，边长为 1，否则为 0）。将箱子推到目标位置对应多个状态，这些状态中箱子位置等于目标位置。因此问题可以转化为：给定一个有向图，边长为 0 或 1，求某一节点到符合条件的任一节点的最短路径。边权非负时，可以使用textDijkstra 算法求解，但是本题的边权限定在 0 与 1 之间，可以应用时间复杂度更优的 01-广度优先搜索算法

- 他是用人的视角去bfs的，如果人能站在箱子处，那就移动箱子到对应方向的下一格，除非越界或者撞墙
- q和q1其实是两种状态，分别代表着，箱子推之前，箱子推之后，把q遍历完之后，再去下一层，也就是q1的状态去搜索

```c++
class Solution {
public:
    int minPushBox(vector<vector<char>>& grid) {
        int m = grid.size(), n = grid[0].size();
        int sx, sy, bx, by; // 玩家、箱子的初始位置
        for (int x = 0; x < m; x++) {
            for (int y = 0; y < n; y++) {
                if (grid[x][y] == 'S') {
                    sx = x;
                    sy = y;
                } else if (grid[x][y] == 'B') {
                    bx = x;
                    by = y;
                }
            }
        }

        auto ok = [&](int x, int y) -> bool { // 不越界且不在墙上
            return x >= 0 && x < m && y >= 0 && y < n && grid[x][y] != '#';
        };
        vector<int> d = {0, -1, 0, 1, 0};

        vector<vector<int>> dp(m * n, vector<int>(m * n, INT_MAX));
        queue<pair<int, int>> q;
        dp[sx * n + sy][bx * n + by] = 0; // 初始状态的推动次数为 0
        q.push({sx * n + sy, bx * n + by});
        while (!q.empty()) {
            queue<pair<int, int>> q1;
            while (!q.empty()) {
                auto [s1, b1] = q.front();
                q.pop();
                int sx1 = s1 / n, sy1 = s1 % n, bx1 = b1 / n, by1 = b1 % n;
                if (grid[bx1][by1] == 'T') { // 箱子已被推到目标处
                    return dp[s1][b1];
                }
                for (int i = 0; i < 4; i++) { // 玩家向四个方向移动到另一个状态
                    int sx2 = sx1 + d[i], sy2 = sy1 + d[i + 1], s2 = sx2*n+sy2;
                    if (!ok(sx2, sy2)) { // 玩家位置不合法
                        continue;
                    }
                    if (bx1 == sx2 && by1 == sy2) { // 推动箱子
                        int bx2 = bx1 + d[i], by2 = by1 + d[i + 1], b2 = bx2*n+by2;
                        if (!ok(bx2, by2) || dp[s2][b2] <= dp[s1][b1] + 1) { // 箱子位置不合法 或 状态已访问
                            continue;
                        }
                        dp[s2][b2] = dp[s1][b1] + 1;
                        q1.push({s2, b2});
                    } else {
                        if (dp[s2][b1] <= dp[s1][b1]) { // 状态已访问
                            continue;
                        }
                        dp[s2][b1] = dp[s1][b1];
                        q.push({s2, b1});
                    }
                }
            }
            q.swap(q1);
        }
        return -1;
    }
};

作者：力扣官方题解
链接：https://leetcode.cn/problems/minimum-moves-to-move-a-box-to-their-target-location/solutions/2260041/tui-xiang-zi-by-leetcode-solution-spzi/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

## DFS&回溯with闫学灿

回溯法 采用试错的思想，它尝试分步的去解决一个问题。在分步解决问题的过程中，当它通过尝试发现现有的分步答案不能得到有效的正确的解答的时候，它将取消上一步甚至是上几步的计算，再通过其它的可能的分步解答再次尝试寻找问题的答案。回溯法通常用最简单的递归方法来实现，在反复重复上述的步骤后可能出现两种情况：

找到一个可能存在的正确的答案；
在尝试了所有可能的分步方法后宣告该问题没有答案。

作者：liweiwei1419
链接：https://leetcode.cn/problems/permutations/solutions/9914/hui-su-suan-fa-python-dai-ma-java-dai-ma-by-liweiw/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

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

### 10. 正则表达式匹配

同剑指19题

给你一个字符串 s 和一个字符规律 p，请你来实现一个支持 '.' 和 '*' 的正则表达式匹配。

'.' 匹配任意单个字符
'*' 匹配零个或多个前面的那一个元素
所谓匹配，是要涵盖 整个 字符串 s的，而不是部分字符串。

说明:

s 可能为空，且只包含从 a-z 的小写字母。
p 可能为空，且只包含从 a-z 的小写字母，以及字符 . 和 *。
示例 1:

输入:
s = "aa"
p = "a"
输出: false
解释: "a" 无法匹配 "aa" 整个字符串。
示例 2:

输入:
s = "aa"
p = "a*"
输出: true
解释: 因为 '*' 代表可以匹配零个或多个前面的那一个元素, 在这里前面的元素就是 'a'。因此，字符串 "aa" 可被视为 'a' 重复了一次。
示例 3:

输入:
s = "ab"
p = ".*"
输出: true
解释: ".*" 表示可匹配零个或多个（'*'）任意字符（'.'）。
示例 4:

输入:
s = "aab"
p = "c*a*b"
输出: true
解释: 因为 '*' 表示零个或多个，这里 'c' 为 0 个, 'a' 被重复一次。因此可以匹配字符串 "aab"。
示例 5:

输入:
s = "mississippi"
p = "mis*is*p*."
输出: false

```c++
class Solution {
public:
    int n, m;
    bool isMatch(string s, string p) {
        n = s.size();
        m = p.size();
        return helper(s, p, 0, 0);
    }
    bool helper(string &s, string &p, int i, int j) {
        if (i == n && j == m) return true;
        if (j == m) return false;
        if (j == m-1 || p[j+1] != '*') {
            if ((i < n && p[j] == '.') || (s[i] == p[j])) {
                return helper(s, p, i+1, j+1);
            }
        } else { // p[j+1]是'*'
            if ((i < n && p[j] == '.') || (s[i] == p[j])) {
                return helper(s, p, i, j+2) // 'x*'匹配零个
                        || helper(s, p, i+1, j); // 'x*'吃掉这个字符，后移
                            // || helper(s, p, i+1, j+2) // 'x*'匹配一个 ，是冗余的，可以用i+1再j+2这两步得到，加上就会超时！
            }
            else {
                return helper(s, p, i, j+2); // '*'匹配零个
            }
        }
        return false; // never reached
    }
};
```

### 17. 电话号码的字母组合(Medium) @hot100

给定一个仅包含数字 2-9 的字符串，返回所有它能表示的字母组合。

给出数字到字母的映射如下（与电话按键相同）。注意 1 不对应任何字母。

示例:

输入："23"
输出：["ad", "ae", "af", "bd", "be", "bf", "cd", "ce", "cf"].

```c++
class Solution {
public:
    vector<string> ans;
    int n;
    unordered_map<char, string> map;
    vector<string> letterCombinations(string digits) {
        if (digits.empty()) return ans;
        n = digits.size();
        map['2'] = "abc";
        map['3'] = "def";
        map['4'] = "ghi";
        map['5'] = "jkl";
        map['6'] = "mno";
        map['7'] = "pqrs";
        map['8'] = "tuv";
        map['9'] = "wxyz";
        string path;
        dfs(digits, path, 0);
        return ans;
    }
    void dfs(string &digits, string &path, int k) {
        if (k == n) {
            ans.push_back(path);
            return;
        }
        for (char &ch : map[digits[k]]) {
            path.push_back(ch);
            dfs(digits, path, k+1);
            path.pop_back();
        }
    }
};
```

刷hot100，思路差不多，把k给省略了，电话表盘用的是固定数组来存储而不是map

时间
4 ms
击败
34.1%
内存
6.6 MB
击败
7.99%

```c++
class Solution {
public:
    char tel[8][4] = {
        {'a', 'b', 'c'},
        {'d', 'e', 'f'},
        {'g', 'h', 'i'},
        {'j', 'k', 'l'},
        {'m', 'n', 'o'},
        {'p', 'q', 'r', 's'},
        {'t', 'u', 'v'},
        {'w', 'x', 'y', 'z'}
    };
    vector<string> res;
    vector<string> letterCombinations(string digits) {
        if (digits.empty()) return {};
        string cur;
        dfs(digits, cur);
        return res;
    }
    
    void dfs(string digits, string cur) {
        if (cur.size() == digits.size()) {
            res.push_back(cur);
            return;
        }
        int index = digits[cur.size()] - '2';
        for (int i = 0; i < 4; ++i) {
            if (tel[index][i] == 0) break; // 有些数字只对应了三个字母，第四个位置初始化为0
            cur.push_back(tel[index][i]);
            dfs(digits, cur);
            cur.pop_back();
        }
    }
};
```

### 22. 括号生成(Medium) @hot100

数字 n 代表生成括号的对数，请你设计一个函数，用于能够生成所有可能的并且 有效的 括号组合。

示例：

输入：n = 3
输出：[
       "((()))",
       "(()())",
       "(())()",
       "()(())",
       "()()()"
     ]

回溯模板一把梭

```c++
class Solution {
public:
    vector<string> ans;
    vector<string> generateParenthesis(int n) {
        if (n <= 0) return ans;
        string path = "(";
        dfs(path, 1, 0, n);
        return ans;
    }
    void dfs(string &path, int leftQuoteNum, int rightQuoteNum, int n) {
        if (leftQuoteNum == rightQuoteNum && leftQuoteNum == n) {
            ans.push_back(path);
            return;
        }
        if (leftQuoteNum > rightQuoteNum) {
            path.push_back(')');
            dfs(path, leftQuoteNum, rightQuoteNum+1, n);
            path.pop_back();
        }
        if (leftQuoteNum < n) {
            path.push_back('(');
            dfs(path, leftQuoteNum+1, rightQuoteNum, n);
            path.pop_back();
        }
    }
};
```

刷hot100，用到了栈，但是仔细一想，不是一定需要栈的，用上述方法更优雅，思路是完全一样的，甚至两个if都是一样的

时间
4 ms
击败
67.58%
内存
11.2 MB
击败
64.10%

```c++
class Solution {
public:
    vector<string> res;
    vector<string> generateParenthesis(int n) {
        if (n == 1) return {"()"};
        stack<char> st; // st仅保存左括号，右括号用来"抵消"左括号，出栈
        string cur;
        dfs(st, cur, n);
        return res;
    }
    void dfs(stack<char> &st, string &cur, int n) {
        if (st.empty() && n == 0) {
            res.push_back(cur);
            return;
        }
        if (n != 0) {
            st.push('(');
            cur.push_back('(');
            dfs(st, cur, n-1);
            st.pop();
            cur.pop_back();
        }
        if (!st.empty()){
            st.pop();
            cur.push_back(')');
            dfs(st, cur, n);
            st.push('(');
            cur.pop_back();
        }
    }
};
```

看讨论区，有人用动态规划，解题思路：任何一个有n对有效的括号一定可以写成(a)b这种形式，其中a，b加起来具有n - 1个括号对，a, b为有效的括号序列，且a b可以为空，然后分别枚举a b即可

递推公式： dp[i] = "(" + dp[k] + ")" + dp[i - 1 - k]

作者：ChickenCC
链接：https://leetcode.cn/problems/generate-parentheses/solutions/2215237/di-tui-dong-tai-gui-hua-by-sunqao-zk68/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

时间
4 ms
击败
67.58%
内存
7.3 MB
击败
90.88%

```c++
class Solution {
public:
    vector<string> generateParenthesis(int n) {
        //这里dp[i]表示的是i对括号形成的一堆合法的括号序列
        vector<vector<string>> dp(n + 1);
        dp[1].push_back("()");
        dp[0].push_back("");
        for(int i = 2; i <= n; i ++) { // 从dp[2]开始计算
            for(int j = 0; j < i; j ++) {// j从0开始枚举
                for(auto &s1: dp[j]){
                    string s4 = "(" + s1;
                    for(auto &s2 : dp[i - 1 - j]){
                        string s3 = s4 + ")" + s2;
                        dp[i].push_back(s3);
                    }
                }
            }
        }
        return dp[n];
    }
};
```

### 39. 组合总和(Medium) @hot100

给定一个无重复元素的数组 candidates 和一个目标数 target ，找出 candidates 中所有可以使数字和为 target 的组合。

candidates 中的数字可以无限制重复被选取。

说明：

所有数字（包括 target）都是正整数。
解集不能包含重复的组合。
示例 1：

输入：candidates = [2,3,6,7], target = 7,
所求解集为：
[
  [7],
  [2,2,3]
]
示例 2：

输入：candidates = [2,3,5], target = 8,
所求解集为：
[
  [2,2,2,2],
  [2,3,3],
  [3,5]
]

提示：

1 <= candidates.length <= 30
1 <= candidates[i] <= 200
candidate 中的每个元素都是独一无二的。
1 <= target <= 500

第一次尝试，dfs+剪枝，但是有重复，比如：

[2,3,6,7]
7
输出
[[2,2,3],[2,3,2],[3,2,2],[7]]
预期结果
[[2,2,3],[7]]

```c++
class Solution {
public:
    vector<vector<int>> ans;
    vector<vector<int>> combinationSum(vector<int>& candidates, int target) {
        vector<int> path;
        int pre = 0; // 为了不重复
        dfs(candidates, path, 0, target);
        return ans;
    }
    void dfs(vector<int>& candidates, vector<int>& path, int sum, int target) {
        if (sum == target) {
            ans.push_back(path);
            return;
        }
        if (sum > target) return;
        for (int & candidate : candidates) {
            path.push_back(candidate);
            dfs(candidates, path, sum+candidate, target);
            path.pop_back();
        }
    }
};
```

重复的原因是在较深层的结点值考虑了之前考虑过的元素，因此我们需要设置“下一轮搜索的起点”即可

在搜索的时候，需要设置搜索起点的下标 begin ，由于一个数可以使用多次，下一层的结点从这个搜索起点开始搜索；

剪枝：

- 如果一个数位搜索起点都不能搜索到结果，那么比它还大的数肯定搜索不到结果，基于这个想法，我们可以对输入数组进行排序，以减少搜索的分支；
- 排序是为了提高搜索速度，非必要；
- 搜索问题一般复杂度较高，能剪枝就尽量需要剪枝。把候选数组排个序，遇到一个较大的数，如果以这个数为起点都搜索不到结果，后面的数就更搜索不到结果了。

时间
4 ms
击败
88.53%
内存
10.7 MB
击败
46.96%

```c++
class Solution {
public:
    vector<vector<int>> ans;
    vector<vector<int>> combinationSum(vector<int>& candidates, int target) {
        sort(candidates.begin(), candidates.end());
        vector<int> path;
        dfs(candidates, path, 0, 0, target);
        return ans;
    }
    void dfs(vector<int>& candidates, vector<int>& path, int start, int sum, int target) {
        if (sum == target) {
            ans.push_back(path);
            return;
        }
        if (sum > target) return; // 剪枝
        for (int i = start; i < candidates.size(); ++i) { // i可从start开始，可以重复选择当前元素；i不从0开始，代表[0, start-1]已全排列完，所以不会有重复解
            path.push_back(candidates[i]);
            dfs(candidates, path, i, sum+candidates[i], target);
            path.pop_back();
        }
    }
};
```

刷hot100，用了比较慢的回溯法，为了避免重复输出相同的解，用set来存储，并且在准备输出可行解时，将其排序，判断是否已存在

时间
152 ms
击败
5.16%
内存
18.5 MB
击败
10.15%

```c++
class Solution {
public:
    vector<vector<int>> res;
    set<vector<int>> hashmap;
    vector<vector<int>> combinationSum(vector<int>& candidates, int target) {
        vector<int> cur;
        dfs(candidates, target, 0, cur);
        return res;
    }

    void dfs(vector<int> &candidates, int target, int sum, vector<int> &cur) {
        if (sum > target) return; // 因为candidates>=2，所以不能无穷递归下去
        if (sum == target) {
            vector<int> sorted = cur;
            sort(sorted.begin(), sorted.end());
            if (hashmap.count(sorted)) { // 已经计算，直接返回
                return;
            }
            res.push_back(sorted);
            hashmap.insert(sorted);
            return;
        }
        for (int i = 0; i < candidates.size(); ++i) { // 
            cur.push_back(candidates[i]);
            sum += candidates[i];
            dfs(candidates, target, sum, cur);
            cur.pop_back();
            sum -= candidates[i];
        }
    }
};
```

### 46. 全排列(Medium) @hot100

给定一个 没有重复 数字的序列，返回其所有可能的全排列。

示例:

输入: [1,2,3]
输出:
[
  [1,2,3],
  [1,3,2],
  [2,1,3],
  [2,3,1],
  [3,1,2],
  [3,2,1]
]

没啥好说的，dfs模板一把梭，这里修改了nums数组，并且swap与撤销操作很巧妙

时间
0 ms
击败
100%
内存
7.6 MB
击败
71.33%

```c++
class Solution {
public:
    vector<vector<int>> ans;
    vector<vector<int>> permute(vector<int>& nums) {
        dfs(nums, 0);
        return ans;
    }
    void dfs(vector<int> &nums, int k) {
        if (nums.size() == k) {
            ans.push_back(nums);
            return;
        }
        // [0, k-1]的元素已完成排列，剩下[k, len-1]的元素需要进行全排列
        for (int i = k; i < nums.size(); ++i) {
            swap(nums[k], nums[i]); // 第k个元素可能是剩下[k, len-1]的元素，交换元素来完成不同可能
            dfs(nums, k+1);
            swap(nums[k], nums[i]); // 撤销操作，保证不乱
        }
    }
};
```

刷hot100，dfs

时间
12 ms
击败
3.61%
内存
8 MB
击败
16.94%

```c++
class Solution {
public:
    vector<vector<int>> res;
    vector<vector<int>> permute(vector<int>& nums) {
        if (nums.empty()) return {{}};
        vector<int> cur;
        set<int> visited;
        for (int i = 0; i < nums.size(); ++i) {
            dfs(cur, nums[i], visited, nums);
        }
        return res;
    }

    void dfs(vector<int> &cur, int val, set<int> &visited, vector<int> &nums) {
        if(visited.count(val)) return;
        cur.push_back(val);
        if (cur.size() == nums.size()) {
            res.push_back(cur);
            cur.pop_back();
            return;
        }
        visited.insert(val);
        for (int i = 0; i < nums.size(); ++i) {
            dfs(cur, nums[i], visited, nums);
        }
        visited.erase(val);
        cur.pop_back();
    }
};
```

### 51. N皇后(Hard) @hot100

按照国际象棋的规则，皇后可以攻击与之处在同一行或同一列或同一斜线上的棋子。

n 皇后问题 研究的是如何将 n 个皇后放置在 n×n 的棋盘上，并且使皇后彼此之间不能相互攻击。

给你一个整数 n ，返回所有不同的 n 皇后问题 的解决方案。

每一种解法包含一个不同的 n 皇后问题 的棋子放置方案，该方案中 'Q' 和 '.' 分别代表了皇后和空位。

示例 1：

输入：n = 4
输出：[[".Q..","...Q","Q...","..Q."],["..Q.","Q...","...Q",".Q.."]]
解释：如上图所示，4 皇后问题存在两个不同的解法。
示例 2：

输入：n = 1
输出：[["Q"]]

提示：

1 <= n <= 9

刷hot100时的答案，

时间
0 ms
击败
100%
内存
7.4 MB
击败
32.24%

```c++
class Solution {
public:
    vector<vector<string>> res;
    vector<vector<string>> solveNQueens(int n) {
        if (n == 0) return res;
        if (n == 1) return {{"Q"}};
        vector<string> cur;
        vector<pair<int, int>> queen_pos;
        dfs(cur, queen_pos, 0, n);
        return res;
    }
    void dfs(vector<string> &cur, vector<pair<int, int>> &queen_pos, int k, int n) {
        if (k == n) {
            res.push_back(cur);
        }
        for (int i = 0; i < n; ++i) { // n皇后的行肯定不同
            if (underAttack(cur, queen_pos, k, i)) continue;
            string row (n, '.');
            row[i] = 'Q';
            queen_pos.push_back({k, i});
            cur.push_back(row);
            dfs(cur, queen_pos, k+1, n);
            queen_pos.pop_back();
            cur.pop_back();
        }
    }
    bool underAttack(vector<string> &cur, vector<pair<int, int>> &queen_pos, int row, int col) {
        for (const auto &p : queen_pos) {
            if (abs(row - p.first) == abs(col - p.second)) { // 斜线攻击
                return true;
            }
            if (col == p.second) { // 竖线攻击
                return true;
            }
        }
        return false;
    }
};
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

### 78. 子集(Medium) @hot100

给定一组不含重复元素的整数数组 nums，返回该数组所有可能的子集（幂集）。

说明：解集不能包含重复的子集。

示例:

输入: nums = [1,2,3]
输出:
[
  [3],
  [1],
  [2],
  [1,2,3],
  [1,3],
  [2,3],
  [1,2],
  []
]

回溯法，当前节点可选可不选，时间复杂度O(n x 2^n)：一共是2^n个状态，每个状态要用O(n)来构造子集，空间复杂度O(n)：临时数组代价是O(n)，递归的栈空间是O(n)

也可以用位运算的做法来实现迭代版本

时间
8 ms
击败
5.39%
内存
7 MB
击败
42.28%

```c++
class Solution {
public:
    vector<vector<int>> ans;
    vector<vector<int>> subsets(vector<int>& nums) {
        // 对于每个元素，选或者不选，共有2^n种可能
        if (nums.empty()) return ans;
        int n = nums.size();
        vector<int> path;
        dfs(nums, path, 0, n);
        return ans;
    }
    void dfs(vector<int>& nums, vector<int>& path, int k, int n) {
        if (k == n) {
            ans.push_back(path);
            return;
        }
        path.push_back(nums[k]); // pick
        dfs(nums, path, k+1, n);
        path.pop_back();  // not pick
        dfs(nums, path, k+1, n);
    }
};
```

刷hot100，感觉这种写法更容易记忆，与46.全排列很像，比如1，2,3要选子集大小为2的，首先选取1，另一个元素可以选2和3，然后选取2，此时另一个元素只能选3，再选取3，另一个元素不存在了，就像锦标赛，子集有多大，for循环就有多少层，用代码表示不现实（子集为2的要写双层for循环，子集为3的要写三层for循环....），所以用递归的dfs

时间
0 ms
击败
100%
内存
7 MB
击败
57.61%

```c++
class Solution {
public:
    vector<vector<int>> res = {{}};
    vector<vector<int>> subsets(vector<int>& nums) {
        if (nums.empty()) return res;
        vector<int> subset;
        for (int i = 0; i < nums.size(); ++i) {
            dfs(nums, subset, i);
        }
        return res;
    }
    void dfs(vector<int> &nums, vector<int> &subset, int index) {
        subset.push_back(nums[index]); // 加入当前节点
        res.push_back(subset);
        for (int i = index + 1; i < nums.size(); ++i) {
            dfs(nums, subset, i);
        }
        subset.pop_back(); // 撤销操作
    }
};
```

看讨论区，有人用动态规划的思想，dp[i]表示前i个数的解集，dp[i] = dp[i - 1] + collections(i)。其中，collections(i)表示把dp[i-1]的所有子集都加上第i个数形成的子集。

时间复杂度：i=0，j=[0,0],i=1,j=[0,1],i=2,j=[0,1,2,3]，。。。可知是2^n，又因为构造子集复制需要O(n)，所以总时间复杂度是O(n*2^n)

空间复杂度：O(n)，用于额外数组

时间
0 ms
击败
100%
内存
7 MB
击败
34.67%

```c++
class Solution {
public:
    vector<vector<int>> subsets(vector<int>& nums) {
        vector<vector<int>> res = {{}}; // 初始subsets含有空集
        for (int i = 0; i < nums.size(); ++i) {
            int last_size = res.size(); // 记录dp[i-1]的subsets个数
            for (int j = 0; j < last_size; ++j) {
                vector<int> tmp = res[j];
                tmp.push_back(nums[i]); // dp[i-1]的每个subsets都加上当前节点nums[i]
                res.push_back(tmp);
            }
        }
        return res;
    }
};
```

### 79. 单词搜索(Medium) @hot100

[LeetCode 79. 单词搜索](https://leetcode-cn.com/problems/word-search/)

给定一个二维网格和一个单词，找出该单词是否存在于网格中。

单词必须按照字母顺序，通过相邻的单元格内的字母构成，其中“相邻”单元格是那些水平相邻或垂直相邻的单元格。同一个单元格内的字母不允许被重复使用。

示例:

board =
[
  ['A','B','C','E'],
  ['S','F','C','S'],
  ['A','D','E','E']
]

给定 word = "ABCCED", 返回 true
给定 word = "SEE", 返回 true
给定 word = "ABCB", 返回 false

提示：

board 和 word 中只包含大写和小写英文字母。
1 <= board.length <= 200
1 <= board[i].length <= 200
1 <= word.length <= 10^3

```c++
class Solution {
public:
    bool exist(vector<vector<char>>& matrix, string str) {
        if (matrix.empty() || matrix[0].empty()) return false;
        int rows = matrix.size();
        int cols = matrix[0].size();
        if (rows * cols < str.size()) return false;
        vector<vector<bool>> is_visited(rows, vector<bool>(cols, false));
        for (int i = 0; i < rows; ++i) {
            for (int j = 0; j < cols; ++j) {
                if (matrix[i][j] == str[0]) {
                    if (dfs(matrix, is_visited, i, j, rows, cols, str, 0)) return true;
                }
            }
        }
        return false;
    }
    bool dfs(vector<vector<char>>& matrix, vector<vector<bool>>& is_visited,
            int i, int j, int rows, int cols, string &str, int step) {
        if (step == str.size() - 1) {
            if (matrix[i][j] == str[str.size() - 1]) return true;
            else return false;
        }
        if (matrix[i][j] != str[step]) return false;
        is_visited[i][j] = true;
        bool flag = false;
        if (!flag && i > 0 && !is_visited[i-1][j]) flag |= dfs(matrix, is_visited, i-1, j, rows, cols, str, step+1);
        if (!flag && i < rows-1 && !is_visited[i+1][j]) flag |= dfs(matrix, is_visited, i+1, j, rows, cols, str, step+1);
        if (!flag && j > 0 && !is_visited[i][j-1]) flag |= dfs(matrix, is_visited, i, j-1, rows, cols, str, step+1);
        if (!flag && j < cols-1 && !is_visited[i][j+1]) flag |= dfs(matrix, is_visited, i, j+1, rows, cols, str, step+1);
        if (!flag) {
            is_visited[i][j] = false;
            return false;
        }
        return true;
    }
};
```

如果没有【已访问的格子不能再访问】的限制，则不需要visited数组了

```c++
bool dfs(vector<vector<char>> &board, string &word, int wordIndex, int x, int y) {
    if (board[x][y] != word[wordIndex]) {
        return false;
    }
    if (word.size() - 1 == wordIndex) {
        return true;
    }
    wordIndex++;
    if ((x > 0 && dfs(board, word, wordIndex, x - 1, y))
        || (y > 0 && dfs(board, word, wordIndex, x, y - 1))
        || (x < board.size() - 1 && dfs(board, word, wordIndex, x + 1, y))
        || (y < board[0].size() - 1 && dfs(board, word, wordIndex, x, y + 1))
        ) {
        return true;
    }
    return false;
}
bool exist(vector<vector<char>> &board, string word) {
    for (int i = 0; i < board.size(); ++i) {
        for (int j = 0; j < board[0].size(); ++j) {
            if (dfs(board, word, 0, i, j)) {
                return true;
            }
        }
    }
    return false;
}
```

刷hot100，看起来更容易理解，这题的简单之处在于只需要返回bool，所以在dfs函数中只要符合条件，直接return true即可

时间
276 ms
击败
90.77%
内存
8.1 MB
击败
8.57%

```c++
class Solution {
public:

    bool exist(vector<vector<char>>& board, string word) {
        int m = board.size();
        if (m == 0) return false;
        int n = board[0].size();
        if (n == 0) return false;
        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; ++j) {
                vector<vector<bool>> visited (m, vector<bool>(n, false));
                if (dfs(board, i, j, word, 0, visited)) {
                    return true;
                }
            }
        }
        return false;
    }
    bool dfs(vector<vector<char>> &board, int i, int j, string &word, int k, vector<vector<bool>> &visited) {
        if (board[i][j] != word[k] || visited[i][j] == true) return false;
        if (k == word.size() - 1) return true;
        visited[i][j] = true;
        if (i > 0 && dfs(board, i - 1, j, word, k + 1, visited)) return true;
        if (j > 0 && dfs(board, i, j - 1, word, k + 1, visited)) return true;
        if (i < board.size() - 1 && dfs(board, i + 1, j, word, k + 1, visited)) return true;
        if (j < board[0].size() - 1 && dfs(board, i, j + 1, word, k + 1, visited)) return true;
        visited[i][j] = false; // 当前节点遍历完，撤销访问状态，以便后续其他节点能遍历到这个节点
        return false;
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

### 131. 分割回文串(Medium) @hot100

给你一个字符串 s，请你将 s 分割成一些子串，使每个子串都是 回文串 。返回 s 所有可能的分割方案。

回文串 是正着读和反着读都一样的字符串。

示例 1：

输入：s = "aab"
输出：[["a","a","b"],["aa","b"]]
示例 2：

输入：s = "a"
输出：[["a"]]

提示：

1 <= s.length <= 16
s 仅由小写英文字母组成

刷hot100第一次刷到，直接回溯法，注意下一个可能状态是从当前状态开始的可能回文串，所以自定义一个判断回文串的函数，注意一下dfs的int k的边界即可

时间复杂度：O(n*2^n)，每个位置可拆分，也可以不拆分，所以是2^n，判断回文子串需要O(n)，乘起来

空间复杂度：O(n)，递归调用栈的高度为n，所以栈空间O(n)，辅助数组O(n)，记起来

时间
104 ms
击败
80.51%
内存
73.9 MB
击败
69.82%

```c++
class Solution {
public:
    vector<vector<string>> res;
    vector<vector<string>> partition(string s) {
        if (s.empty()) return res;
        if (s.size() == 1) return {{s}};
        vector<string> cur;
        dfs(s, cur, 0);
        return res;
    }
    void dfs(string &s, vector<string> &cur, int k) {
        if (k == s.size()) {
            res.push_back(cur);
            return;
        }
        for (int i = k; i < s.size(); ++i) {
            if (isSym(s, k, i)) {
                string sub;
                sub.assign(s.begin() + k, s.begin() + i + 1);
                cur.push_back(sub);
                dfs(s, cur, i + 1);
                cur.pop_back();
            }
        }
    }
    bool isSym(string &s, int l, int r) {
        if (l == r) return true;
        for (int i = 0; i <= (r - l) / 2; ++i) {
            if (s[l + i] != s[r - i]) {
                return false;
            }
        }
        return true;
    }
};
```

看官方题解，我这种做法还可以优化，因为在判断isSym的时候，其实有多次重复计算，所以可以先预处理，dp[i, j]表示i到j的子串是否回文，在dfs的时候直接读dp[i,j]即可，动态规划的状态转移方程为：`dp[i][j]=dp[i+1][j-1] && s[i]==s[j]`

时间复杂度：O(n*2^n)，每个位置可拆分，也可以不拆分，所以是2^n，判断回文子串需要O(n)，乘起来，预处理需要O(n^2)，渐进意义下小于`O(n*2^n)`，所以最后就是`O(n*2^n)`

空间复杂度：O(n^2)，因为需要预处理需要n^2的空间

时间
100 ms
击败
86.42%
内存
74 MB
击败
50.33%

```c++
class Solution {
public:
    vector<vector<string>> res;
    vector<vector<bool>> dp;
    vector<vector<string>> partition(string s) {
        if (s.empty()) return res;
        int n = s.size();
        if (n == 1) return {{s}};
        dp.assign(n, vector<bool>(n, true)); // 初始化全是true，其实只需要对角线上的dp[i][j]=true即可，这里全部初始化为true也没关系，因为后面还会更新s[i]==s[j]的
        for (int i = n - 1; i >= 0; --i) {
            for (int j = i + 1; j < n; ++j) {
                dp[i][j] = s[i] == s[j] && dp[i+1][j-1];
            }
        }
        vector<string> cur;
        dfs(s, cur, 0);
        return res;
    }
    void dfs(string &s, vector<string> &cur, int k) {
        if (k == s.size()) {
            res.push_back(cur);
            return;
        }
        for (int i = k; i < s.size(); ++i) {
            if (dp[k][i]) {
                string sub;
                sub.assign(s.begin() + k, s.begin() + i + 1);
                cur.push_back(sub);
                dfs(s, cur, i + 1);
                cur.pop_back();
            }
        }
    }
};
```

因为dp[i][j]从dp[i+1][j-1]而来，所以预处理时每次遍历要扩大范围，不能是i从0到n-1 && j从0到n-1，这样i的范围是在缩小的，除了上面的做法，还可以反过来，其实就是求矩阵的上三角或者下三角，另一个三角是对称的

```c++
        for (int r = 0; r < n; ++r) {
            for (int l = 0; l < r; ++l) {
                dp[l][r] = s[l] == s[r] && dp[l+1][r-1];
            }
        }
```

判断回文子串，还可以用中心扩散的方法

```c++
        dp.assign(n, vector<bool>(n, false));
        for (int i = 0; i < n; ++i) {
            pre(s, i, i);
            pre(s, i, i + 1);
        }

        void pre(string &s, int l, int r) {
            while (l >= 0 && r <= s.size() - 1 && s[l] == s[r]) {
                dp[l][r] = true;
                --l;
                ++r;
            }
        }
```

### 200. 岛屿数量(medium) @hot100

给你一个由 '1'（陆地）和 '0'（水）组成的的二维网格，请你计算网格中岛屿的数量。

岛屿总是被水包围，并且每座岛屿只能由水平方向和/或竖直方向上相邻的陆地连接形成。

此外，你可以假设该网格的四条边均被水包围。

示例 1：

输入：grid = [
  ["1","1","1","1","0"],
  ["1","1","0","1","0"],
  ["1","1","0","0","0"],
  ["0","0","0","0","0"]
]
输出：1
示例 2：

输入：grid = [
  ["1","1","0","0","0"],
  ["1","1","0","0","0"],
  ["0","0","1","0","0"],
  ["0","0","0","1","1"]
]
输出：3

提示：

m == grid.length
n == grid[i].length
1 <= m, n <= 300
`grid[i][j]` 的值为 '0' 或 '1'

dfs一把梭

小贴士：

在一些题解中，可能会把「已遍历过的陆地格子」标记为和海洋格子一样的 0，美其名曰「陆地沉没方法」，即遍历完一个陆地格子就让陆地「沉没」为海洋。这种方法看似很巧妙，但实际上有很大隐患，因为这样我们就无法区分「海洋格子」和「已遍历过的陆地格子」了。如果题目更复杂一点，这很容易出 bug。

作者：nettee
链接：https://leetcode.cn/problems/number-of-islands/solutions/211211/dao-yu-lei-wen-ti-de-tong-yong-jie-fa-dfs-bian-li-/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

时间
24 ms
击败
98.20%
内存
11.9 MB
击败
81.17%

```c++
class Solution {
public:
    int numIslands(vector<vector<char>>& grid) {
        if (grid.empty()) return 0;
        if (grid[0].empty()) return 0;
        int m = grid.size();
        int n = grid[0].size();
        int res = 0;
        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; ++j) {
                if (grid[i][j] == '1') {
                    dfs(grid, i, j, m, n);
                    ++res;
                }
            }
        }
        return res;
    }

    void dfs(vector<vector<char>> &grid, int i, int j, int m, int n) {
        if (i < 0 || i > m - 1 || j < 0 || j > n - 1) return;
        if (grid[i][j] != '1') return;
        grid[i][j] = '0';
        dfs(grid, i+1, j, m, n);
        dfs(grid, i-1, j, m, n);
        dfs(grid, i, j+1, m, n);
        dfs(grid, i, j-1, m, n);
    }
};
```

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

### 399. 除法求值

medium

给你一个变量对数组 equations 和一个实数值数组 values 作为已知条件，其中 equations[i] = [Ai, Bi] 和 values[i] 共同表示等式 Ai / Bi = values[i] 。每个 Ai 或 Bi 是一个表示单个变量的字符串。

另有一些以数组 queries 表示的问题，其中 queries[j] = [Cj, Dj] 表示第 j 个问题，请你根据已知条件找出 Cj / Dj = ? 的结果作为答案。

返回 所有问题的答案 。如果存在某个无法确定的答案，则用 -1.0 替代这个答案。如果问题中出现了给定的已知条件中没有出现的字符串，也需要用 -1.0 替代这个答案。

注意：输入总是有效的。你可以假设除法运算中不会出现除数为 0 的情况，且不存在任何矛盾的结果。

注意：未在等式列表中出现的变量是未定义的，因此无法确定它们的答案。

```
示例 1：

输入：equations = [["a","b"],["b","c"]], values = [2.0,3.0], queries = [["a","c"],["b","a"],["a","e"],["a","a"],["x","x"]]
输出：[6.00000,0.50000,-1.00000,1.00000,-1.00000]
解释：
条件：a / b = 2.0, b / c = 3.0
问题：a / c = ?, b / a = ?, a / e = ?, a / a = ?, x / x = ?
结果：[6.0, 0.5, -1.0, 1.0, -1.0 ]
注意：x 是未定义的 => -1.0
示例 2：

输入：equations = [["a","b"],["b","c"],["bc","cd"]], values = [1.5,2.5,5.0], queries = [["a","c"],["c","b"],["bc","cd"],["cd","bc"]]
输出：[3.75000,0.40000,5.00000,0.20000]
示例 3：

输入：equations = [["a","b"]], values = [0.5], queries = [["a","b"],["b","a"],["a","c"],["x","y"]]
输出：[0.50000,2.00000,-1.00000,-1.00000]
 

提示：

1 <= equations.length <= 20
equations[i].length == 2
1 <= Ai.length, Bi.length <= 5
values.length == equations.length
0.0 < values[i] <= 20.0
1 <= queries.length <= 20
queries[i].length == 2
1 <= Cj.length, Dj.length <= 5
Ai, Bi, Cj, Dj 由小写英文字母与数字组成
```

不要被吓到了，实际上不难，把整个想象成一个图，要算两者之商，就是从图中从A点到B的路径开销

```c++
 class Solution {
public:
    vector<double> calcEquation(vector<vector<string>>& equations, vector<double>& values, vector<vector<string>>& queries) {
        // 其实就是寻找变量X到变量Y的路径，每条路径的值要累乘起来
        unordered_map<string, vector<pair<string, double>>> table; // key：变量x，value：变量y以及路径开销
        unordered_map<string, bool> visited;
        int n = equations.size();
        for (int i = 0; i < n; ++i) {
            table[equations[i][0]].push_back({equations[i][1], values[i]});
            table[equations[i][1]].push_back({equations[i][0], 1.0 / values[i]});
            visited[equations[i][0]] = false;
            visited[equations[i][1]] = false;
            // cout << equations[i][0] << ".push " << equations[i][1] <<","<<  to_string(values[i]) << endl;
            // cout << equations[i][1] << ".push " << equations[i][0] <<","<< to_string(1.0 / values[i]) << endl;
        }

        int m = queries.size();
        vector<double> ans;
        for (int i = 0; i < m; ++i) {
            string c = queries[i][0];
            string d = queries[i][1];
            if (table.count(c) == 0 || table.count(d) == 0) {
                ans.push_back(-1.0);
            } else if (c == d) {
                ans.push_back(1.0);
            } else {
                // 寻找变量c到变量d的路径
                double cur_val = 1, ans_val = -1.0;
                unordered_map<string, bool> vis = visited;
                dfs(table, vis, c, d, cur_val, ans_val);
                ans.push_back(ans_val);
            }
        }
        return ans;
    }
    void dfs(unordered_map<string, vector<pair<string, double>>> &table, unordered_map<string, bool> &vis, string &cur, string &dst, double cur_val, double &ans_val) { // 目的是cur=dst
        vis[cur] = true;
        for (auto &p : table[cur]) {
            if (p.first == dst) {
                ans_val = cur_val * p.second;
                return;
            } else if (!vis[p.first]) {
                dfs(table, vis, p.first, dst, cur_val * p.second, ans_val);
            }
        }
    }
};
```

还有优化空间，利用并查集压缩路径，最开始打表后，以后每次查询时，都可以让路径变得更短，即树的高度变矮，有利于后续查找

### 547. 省份数量

medium

有 n 个城市，其中一些彼此相连，另一些没有相连。如果城市 a 与城市 b 直接相连，且城市 b 与城市 c 直接相连，那么城市 a 与城市 c 间接相连。

省份 是一组直接或间接相连的城市，组内不含其他没有相连的城市。

给你一个 n x n 的矩阵 isConnected ，其中 isConnected[i][j] = 1 表示第 i 个城市和第 j 个城市直接相连，而 isConnected[i][j] = 0 表示二者不直接相连。

返回矩阵中 省份 的数量。

```
示例 1：

输入：isConnected = [[1,1,0],[1,1,0],[0,0,1]]
输出：2
示例 2：


输入：isConnected = [[1,0,0],[0,1,0],[0,0,1]]
输出：3
 

提示：

1 <= n <= 200
n == isConnected.length
n == isConnected[i].length
isConnected[i][j] 为 1 或 0
isConnected[i][i] == 1
isConnected[i][j] == isConnected[j][i]
```

其实题干里说的什么直接连通间接连通不用管，只要能连通的就是一个省份，不连通的就属于两个省份，很容易想到用dfs来做，反过来想，先假设所有城市都独立，然后尝试搜索所有连通城市

```c++
class Solution {
public:
    int findCircleNum(vector<vector<int>>& isConnected) {
        if (isConnected.empty() || isConnected[0].empty()) return 0;
        int n = isConnected.size();
        if (n == 1) return 1;
        vector<bool> visited(n, false);
        int province = n; // 初始所有城市独立，dfs寻找连通城市
        for (int i = 0; i < n; ++i) {
            if (!visited[i]) dfs(isConnected, visited, n, i, province, true);
        }
        return province;
    }
    void dfs(vector<vector<int>> &isConnected, vector<bool> &visited, int n, int city, int &province, bool is_start_city) {
        if (visited[city]) return;
        if (!is_start_city) --province; // 如果不是起点城市，也没有被访问过，则说明该城市是被连通的，则省份-1
        visited[city] = true;
        for (int i = 0; i < n; ++i) {
            if (city != i && isConnected[city][i] == 1) {
                dfs(isConnected, visited, n, i, province, false);
            }
        }
    }
};
```

也可以在主函数中从零开始计算province

```c++
    void dfs(vector<vector<int>>& isConnected, vector<int>& visited, int cities, int i) {
        for (int j = 0; j < cities; j++) {
            if (isConnected[i][j] == 1 && !visited[j]) {
                visited[j] = 1;
                dfs(isConnected, visited, cities, j);
            }
        }
    }

    int findCircleNum(vector<vector<int>>& isConnected) {
        int cities = isConnected.size();
        vector<int> visited(cities);
        int provinces = 0;
        for (int i = 0; i < cities; i++) {
            if (!visited[i]) {
                dfs(isConnected, visited, cities, i);
                provinces++;
            }
        }
        return provinces;
    }
```

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

### 841. 钥匙和房间

medium

有 n 个房间，房间按从 0 到 n - 1 编号。最初，除 0 号房间外的其余所有房间都被锁住。你的目标是进入所有的房间。然而，你不能在没有获得钥匙的时候进入锁住的房间。

当你进入一个房间，你可能会在里面找到一套不同的钥匙，每把钥匙上都有对应的房间号，即表示钥匙可以打开的房间。你可以拿上所有钥匙去解锁其他房间。

给你一个数组 rooms 其中 rooms[i] 是你进入 i 号房间可以获得的钥匙集合。如果能进入 所有 房间返回 true，否则返回 false。

```
示例 1：

输入：rooms = [[1],[2],[3],[]]
输出：true
解释：
我们从 0 号房间开始，拿到钥匙 1。
之后我们去 1 号房间，拿到钥匙 2。
然后我们去 2 号房间，拿到钥匙 3。
最后我们去了 3 号房间。
由于我们能够进入每个房间，我们返回 true。
示例 2：

输入：rooms = [[1,3],[3,0,1],[2],[0]]
输出：false
解释：我们不能进入 2 号房间。
 

提示：

n == rooms.length
2 <= n <= 1000
0 <= rooms[i].length <= 1000
1 <= sum(rooms[i].length) <= 3000
0 <= rooms[i][j] < n
所有 rooms[i] 的值 互不相同
```

dfs一把梭，注意别死循环，可以用一个变量记录已开拓房间数量，最后与n对比是否相等即可，不用最后遍历visited数组

```c++
class Solution {
public:
    bool canVisitAllRooms(vector<vector<int>>& rooms) {
        int n = rooms.size();
        vector<bool> visited(n, false);
        dfs(rooms, visited, n, 0);
        bool ans = true;
        for (bool v : visited) {
            if (v == false) return false;
        }
        return true;
    }

    void dfs(vector<vector<int>> &rooms, vector<bool> &visited, int n, int room_num) {
        if (room_num < 0 || room_num > n - 1) return;
        if (visited[room_num]) return;
        visited[room_num] = true;
        for (int r : rooms[room_num]) {
            dfs(rooms, visited, n, r);
        }
    }
};
```

也可以用队列模拟bfs，注意入队列时视为已访问

```c++
class Solution {
public:
    bool canVisitAllRooms(vector<vector<int>>& rooms) {
        int n = rooms.size();
        // 队列模拟bfs
        queue<int> q;
        q.push(0);
        vector<bool> visited(n, false);
        visited[0] = true;
        int visit = 1;
        while (!q.empty()) {
            int room_num = q.front();
            q.pop();
            for (int r : rooms[room_num]) {
                if (!visited[r]) { // 加进队列的时候救人位已访问，否则有可能多次加入队列，造成多次加入
                    q.push(r);
                    ++visit;
                    visited[r] = true;
                }
            }
        }
        return visit == n;
    }
};
```

同样也可以用栈模拟dfs

```c++
class Solution {
public:
    bool canVisitAllRooms(vector<vector<int>>& rooms) {
        int n = rooms.size();
        // 栈模拟dfs
        stack<int> st;
        st.push(0);
        vector<bool> visited(n, false);
        visited[0] = true;
        int visit = 1;
        while (!st.empty()) {
            int room_num = st.top();
            st.pop();
            for (int r : rooms[room_num]) {
                if (!visited[r]) { // 加进队列的时候救人位已访问，否则有可能多次加入队列，造成多次加入
                    st.push(r);
                    ++visit;
                    visited[r] = true;
                }
            }
        }
        return visit == n;
    }
};
```

### 994. 腐烂的橘子(Medium) @hot100

在给定的 m x n 网格 grid 中，每个单元格可以有以下三个值之一：

值 0 代表空单元格；
值 1 代表新鲜橘子；
值 2 代表腐烂的橘子。
每分钟，腐烂的橘子 周围 4 个方向上相邻 的新鲜橘子都会腐烂。

返回 直到单元格中没有新鲜橘子为止所必须经过的最小分钟数。如果不可能，返回 -1 。

示例 1：

输入：grid = [[2,1,1],[1,1,0],[0,1,1]]
输出：4
示例 2：

输入：grid = [[2,1,1],[0,1,1],[1,0,1]]
输出：-1
解释：左下角的橘子（第 2 行， 第 0 列）永远不会腐烂，因为腐烂只会发生在 4 个正向上。
示例 3：

输入：grid = [[0,2]]
输出：0
解释：因为 0 分钟时已经没有新鲜橘子了，所以答案就是 0 。

提示：

m == grid.length
n == grid[i].length
1 <= m, n <= 10
`grid[i][j]` 仅为 0、1 或 2

刷hot100时第一次刷到，debug了很久（大于一小时）才AC，cur+2的处理是为了与原grid中的初始腐化橘子（值为2）进行区分，`ending[i][j] != INT_MAX && ending[i][j] > 2`的{i, j}肯定是新鲜橘子后面被腐化了

时间
4 ms
击败
91.11%
内存
14.9 MB
击败
5.9%

```c++
class Solution {
public:
    int orangesRotting(vector<vector<int>>& grid) {
        if (grid.empty()) return -1;
        int m = grid.size();
        if (grid[0].empty()) return -1;
        int n = grid[0].size();
        vector<vector<int>> ending = grid;
        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; ++j) {
                if (ending[i][j] == 1) {
                    ending[i][j] = INT_MAX; // 初始化新鲜橘子的最终状态，ending[i][j]表示这个新鲜橘子需要腐化的时间分钟数
                }
            }
        }
        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; ++j) {
                if (grid[i][j] == 2) {
                    vector<vector<int>> visited = grid;
                    dfs(grid, i, j, m, n, 0, true, ending);
                }
            }
        }
        int ans = 0;
        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; ++j) {
                if (ending[i][j] == INT_MAX) {
                    return -1;
                } else if (ending[i][j] > 2) {
                    ans = max(ans, ending[i][j] - 2);
                }
            }
        }
        return ans;
    }

    void dfs(vector<vector<int>> &grid, int i, int j, int m, int n, int cur, bool is_first, vector<vector<int>> &ending) {
        if (i < 0 || j < 0 || i > m - 1 || j > n - 1) return;
        if (grid[i][j] == 0) return;
        if (grid[i][j] == 2 && is_first == false) return;
        if (grid[i][j] == 1) {
            if (ending[i][j] <= 2 + cur) return; // 之前遍历能获得更快的腐化速度，所以此次遍历可直接结束
            ++cur;
            ending[i][j] = 2 + cur; // 更新当前新鲜橘子的最小分钟数（用大于3的值x表示该橘子腐化的最小分钟数(x-2)
        }
        // 腐化橘子不用判断，从腐化橘子出发，它们附近的新鲜橘子肯定能获得最快的腐坏速度
        dfs(grid, i+1, j, m, n, cur, false, ending);
        dfs(grid, i, j+1, m, n, cur, false, ending);
        dfs(grid, i-1, j, m, n, cur, false, ending);
        dfs(grid, i, j-1, m, n, cur, false, ending);
    }
};
```

查看官方题解，这题适合用BFS，因为每次腐化都是旁边一层，所以用BFS更好

回到题目中，假设图中只有一个腐烂的橘子，它每分钟向外拓展，腐烂上下左右相邻的新鲜橘子，那么下一分钟，就是这些被腐烂的橘子再向外拓展腐烂相邻的新鲜橘子，这与广度优先搜索的过程均一一对应，上下左右相邻的新鲜橘子就是该腐烂橘子尝试访问的同一层的节点，路径长度就是新鲜橘子被腐烂的时间。我们记录下每个新鲜橘子被腐烂的时间，最后如果单元格中没有新鲜橘子，腐烂所有新鲜橘子所必须经过的最小分钟数就是新鲜橘子被腐烂的时间的最大值。

以上是基于图中只有一个腐烂的橘子的情况，可实际题目中腐烂的橘子数不止一个，看似与广度优先搜索有所区别，不能直接套用，但其实有两个方向的思路。

一个是耗时比较大且不推荐的做法：我们对每个腐烂橘子为起点都进行一次广度优先搜索，时间复杂度需要在原先广度优先搜索遍历的时间复杂度上再乘以腐烂橘子数，这在整个网格范围变大的时候十分耗时

更好的做法是：多源广度优先搜索

思路：观察到对于所有的腐烂橘子，其实它们在广度优先搜索上是等价于同一层的节点的。

假设这些腐烂橘子刚开始是新鲜的，而有一个腐烂橘子(我们令其为超级源点)会在下一秒把这些橘子都变腐烂，而这个腐烂橘子刚开始在的时间是 −1 ，那么按照广度优先搜索的算法，下一分钟也就是第 000 分钟的时候，这个腐烂橘子会把它们都变成腐烂橘子，然后继续向外拓展，所以其实这些腐烂橘子是同一层的节点。那么在广度优先搜索的时候，我们将这些腐烂橘子都放进队列里进行广度优先搜索即可，最后每个新鲜橘子被腐烂的最短时间 `dis[x][y]` 其实是以这个超级源点的腐烂橘子为起点的广度优先搜索得到的结果。

为了确认是否所有新鲜橘子都被腐烂，可以记录一个变量 cnt 表示当前网格中的新鲜橘子数，广度优先搜索的时候如果有新鲜橘子被腐烂，则 cnt-=1 ，最后搜索结束时如果 cnt 大于 000 ，说明有新鲜橘子没被腐烂，返回 −1 ，否则返回所有新鲜橘子被腐烂的时间的最大值即可，也可以在广度优先搜索的过程中把已腐烂的新鲜橘子的值由 1 改为 2，最后看网格中是否由值为 1 即新鲜的橘子即可。

时间
12 ms
击败
21.24%
内存
12.8 MB
击败
35.26%

```c++
class Solution {
public:
    int orangesRotting(vector<vector<int>>& grid) {
        int m = grid.size();
        if (m == 0) return 0;
        int n = grid[0].size();
        if (n == 0) return 0;
        vector<pair<int, int>> rots;
        queue<pair<int, int>> q;
        int cnt = 0;
        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; ++j) {
                if (grid[i][j] == 2) {
                    q.push({i ,j}); // 开局先把腐烂橘子压入队列
                }
                if (grid[i][j] == 1){
                    ++cnt;
                }
            }
        }
        if (cnt == 0) return 0;
        int sz = q.size();
        int cur = 0;
        int ans = 0;
        while (!q.empty()) {
            pair<int, int> p = q.front();
            int i = p.first;
            int j = p.second;
            q.pop();
            // 只需判断新鲜橘子，腐化橘子由它们自身为起点进行扩张肯定更快
            if (grid[i][j] == 1) {
                --cnt;
                ans = cur; // 因为是一层层遍历，越后遍历到的，肯定是越晚腐化的
                grid[i][j] = 2; //这里会修改原数组，如果不能修改，得用一个标记数组
            }
            if (i - 1 >= 0 && grid[i-1][j] == 1) q.push({i-1, j});
            if (i + 1 <= m - 1 && grid[i+1][j] == 1) q.push({i+1, j});
            if (j - 1 >= 0 && grid[i][j-1] == 1) q.push({i, j-1});
            if (j + 1 <= n - 1 && grid[i][j+1] == 1) q.push({i, j+1});
            if (--sz == 0) { // 到下一层了，时间+1
                ++cur;
                sz = q.size();
            }
        }
        return cnt == 0 ? ans : -1; // 新鲜橘子没有全部腐化就返回-1
    }
};
```

刷hot75时，最开始没想到多源bfs，看了上面的思路，重新写了一下，用了dx[4]、dy[4]数组

```c++
class Solution {
public:
    int orangesRotting(vector<vector<int>>& grid) {
        int m = grid.size();
        int n = grid[0].size();
        int dx[4] = {-1, 0, 1, 0};
        int dy[4] = {0, -1, 0, 1};
        int ans = 0;
        int fresh = 0;
        queue<pair<int, int>> q;
        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; ++j) {
                if (grid[i][j] == 1) ++fresh;
                else if (grid[i][j] == 2) q.push({i, j});
            }
        }
        if (fresh == 0) return 0; // 没有新鲜橘子
        int step = 0;
        int sz = q.size();
        while (!q.empty()) {
            auto p = q.front();
            q.pop();
            int row = p.first, col = p.second;
            cout << row << ", " << col << ", " << sz << ", " << step << endl;
            if (step > 0) { // step=0时是初始状态的若干个腐烂橘子
                --fresh; // 新鲜橘子减少
                ans = step; // 因为是多源bfs，当前节点先访问到，肯定就是最小访问步数
            }
            // 从腐烂橘子扩散到新鲜橘子，为了防止多次入队列，入队列时就需要将其腐烂，因为bfs，所以先入队列的肯定不晚于后入队列的
            for (int i = 0; i < 4; ++i) {
                int new_row = row + dx[i];
                int new_col = col + dy[i];
                if (new_row < 0 || new_col < 0 || new_row > m-1 || new_col > n-1 || grid[new_row][new_col] != 1)
                    continue;
                q.push({new_row, new_col});
                grid[new_row][new_col] = 2;
            }
            if (--sz == 0) {
                sz = q.size();
                ++step;
            }
        }
        return fresh == 0 ? ans : -1;
    }
};
```

### 1020. 飞地的数量(Medium)

给出一个二维数组 A，每个单元格为 0（代表海）或 1（代表陆地）。

移动是指在陆地上从一个地方走到另一个地方（朝四个方向之一）或离开网格的边界。

返回网格中无法在任意次数的移动中离开网格边界的陆地单元格的数量。

示例 1：

输入：[[0,0,0,0],[1,0,1,0],[0,1,1,0],[0,0,0,0]]
输出：3
解释：
有三个 1 被 0 包围。一个 1 没有被包围，因为它在边界上。
示例 2：

输入：[[0,1,1,0],[0,0,1,0],[0,0,1,0],[0,0,0,0]]
输出：0
解释：
所有 1 都在边界上或可以到达边界。

提示：

1 <= A.length <= 500
1 <= A[i].length <= 500
0 <= A[i][j] <= 1
所有行的大小都相同

注意dfs的起点是从四周往中间探索，如果碰到0就返回，目的是为了找到所有与外界相连的陆地，将其“染色”（设为-1），最后遍历整个地图即可指导没有被染色的陆地，它们就是孤立的

如果题目要求不能改变输入数组，则需要再开一个同等大小的数组来染色

```c++
class Solution {
public:
    void dfs(vector<vector<int>>& A, int i, int j) {
        if (i < 0 || j < 0 || i >= A.size() || j >= A[0].size()) return;
        if (A[i][j] == 1) A[i][j] = -1;
        else return; // 找不到连接的陆地，直接返回
        dfs(A, i-1, j);
        dfs(A, i+1, j);
        dfs(A, i, j-1);
        dfs(A, i, j+1);
        return;
    }
    int numEnclaves(vector<vector<int>>& A) {
        if (A.empty() || A[0].empty()) return 0;
        int rows = A.size();
        int cols = A[0].size();
        int res = 0;
        for (int i = 0; i < rows; ++i) {
            for (int j = 0; j < cols; ++j) {
                if (i == 0 || j == 0 || i == rows-1 || j == cols-1) {
                    dfs(A, i, j);
                }
            }
        }
        for (int i = 0; i < rows; ++i) {
            for (int j = 0; j < cols; ++j) {
                if (A[i][j] == 1) {
                    ++res;
                }
            }
        }
        return res;
    }
};
```

### 1034. 边框着色(Medium)

给出一个二维整数网格 grid，网格中的每个值表示该位置处的网格块的颜色。

只有当两个网格块的颜色相同，而且在四个方向中任意一个方向上相邻时，它们属于同一连通分量。

连通分量的边界是指连通分量中的所有与不在分量中的正方形相邻（四个方向上）的所有正方形，或者在网格的边界上（第一行/列或最后一行/列）的所有正方形。

给出位于 (r0, c0) 的网格块和颜色 color，使用指定颜色 color 为所给网格块的连通分量的边界进行着色，并返回最终的网格 grid 。

示例 1：

输入：grid = [[1,1],[1,2]], r0 = 0, c0 = 0, color = 3
输出：[[3, 3], [3, 2]]
示例 2：

输入：grid = [[1,2,2],[2,3,2]], r0 = 0, c0 = 1, color = 3
输出：[[1, 3, 3], [2, 3, 3]]
示例 3：

输入：grid = [[1,1,1],[1,1,1],[1,1,1]], r0 = 1, c0 = 1, color = 2
输出：[[2, 2, 2], [2, 1, 2], [2, 2, 2]]

提示：

1 <= grid.length <= 50
1 <= grid[0].length <= 50
1 <= grid[i][j] <= 1000
0 <= r0 < grid.length
0 <= c0 < grid[0].length
1 <= color <= 1000

关键是如何确定边界，边界是四周以及非四周且上下左右方向上存在不为old_color的格子

下面的代码不是最优的，但很容易理解

```c++
class Solution {
public:
    void dfs(vector<vector<int>>& res, vector<vector<int>>& visisted, int old_color, int i, int j, int color) {
        if (i < 0 || j < 0 || i >= res.size() || j >= res[0].size()) return;
        if (visisted[i][j] || res[i][j] != old_color) return; //此节点已遍历过/此节点不符合要求
        visisted[i][j] = 1;
        if (i == 0 || j == 0 || i == res.size()-1 || j == res[0].size()-1) res[i][j] = color;
        if (i >= 1 && res[i-1][j] != old_color && visisted[i-1][j] == 0)  res[i][j] = color;
        if (j >= 1 && res[i][j-1] != old_color && visisted[i][j-1] == 0)  res[i][j] = color;
        if (i < res.size()-1 && res[i+1][j] != old_color && visisted[i+1][j] == 0)  res[i][j] = color;
        if (j < res[0].size()-1 && res[i][j+1] != old_color && visisted[i][j+1] == 0)  res[i][j] = color;
        dfs(res, visisted, old_color, i-1, j, color);
        dfs(res, visisted, old_color, i+1, j, color);
        dfs(res, visisted, old_color, i, j-1, color);
        dfs(res, visisted, old_color, i, j+1, color);
        return;
    }
    vector<vector<int>> colorBorder(vector<vector<int>>& grid, int r0, int c0, int color) {
        vector<vector<int>> res;
        if (grid.empty() || grid[0].empty()) return res;
        int rows = grid.size();
        int cols = grid[0].size();
        vector<vector<int>> visisted(rows, vector<int>(cols, 0));
        for (auto &vec : grid) res.emplace_back(vec);
        dfs(res, visisted, grid[r0][c0], r0, c0, color);
        return res;
    }
};
```

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

### 1466. 重新规划路线

medium

n 座城市，从 0 到 n-1 编号，其间共有 n-1 条路线。因此，要想在两座不同城市之间旅行只有唯一一条路线可供选择（路线网形成一颗树）。去年，交通运输部决定重新规划路线，以改变交通拥堵的状况。

路线用 connections 表示，其中 connections[i] = [a, b] 表示从城市 a 到 b 的一条有向路线。

今年，城市 0 将会举办一场大型比赛，很多游客都想前往城市 0 。

请你帮助重新规划路线方向，使每个城市都可以访问城市 0 。返回需要变更方向的最小路线数。

题目数据 保证 每个城市在重新规划路线方向后都能到达城市 0 。
 
```
示例 1：

输入：n = 6, connections = [[0,1],[1,3],[2,3],[4,0],[4,5]]
输出：3
解释：更改以红色显示的路线的方向，使每个城市都可以到达城市 0 。
示例 2：

输入：n = 5, connections = [[1,0],[1,2],[3,2],[3,4]]
输出：2
解释：更改以红色显示的路线的方向，使每个城市都可以到达城市 0 。
示例 3：

输入：n = 3, connections = [[1,0],[2,0]]
输出：0
 

提示：

2 <= n <= 5 * 10^4
connections.length == n-1
connections[i].length == 2
0 <= connections[i][0], connections[i][1] <= n-1
connections[i][0] != connections[i][1]
```

不要看到题目好像很复杂就犯怵，其实所有城市不会成环，是个树，城市0在其中一个节点上，我们可以从城市0开始反向搜索所有城市，遇到需要调转方向的就把reverse_op+1即可，直接一把ac

```c++
class Solution {
public:
    int minReorder(int n, vector<vector<int>>& connections) {
        // 根据题意，不会出现环，要么是一根线，要么是一棵树，城市0可能在其中任意节点
        unordered_map<int, vector<pair<int, bool>>> adj; // key: 城市i，value：直连的城市j以及是否正向
        for (auto &v : connections) {
            adj[v[0]].push_back({v[1], true});
            adj[v[1]].push_back({v[0], false});
        }
        vector<bool> visited(n, false);
        int reverse_op = 0;
        queue<int> q;
        q.push(0); // 从城市0出发，反过来搜索
        while (!q.empty()) {
            int city = q.front();
            q.pop();
            visited[city] = true;
            for (auto &p : adj[city]) {
                if (visited[p.first]) continue;
                if (p.second) ++reverse_op; // 正向是true，才需要反向
                q.push(p.first);
            }
        }
        return reverse_op;
    }
};
```

### 1926. 迷宫中离入口最近的出口

medium

给你一个 m x n 的迷宫矩阵 maze （下标从 0 开始），矩阵中有空格子（用 '.' 表示）和墙（用 '+' 表示）。同时给你迷宫的入口 entrance ，用 entrance = [entrancerow, entrancecol] 表示你一开始所在格子的行和列。

每一步操作，你可以往 上，下，左 或者 右 移动一个格子。你不能进入墙所在的格子，你也不能离开迷宫。你的目标是找到离 entrance 最近 的出口。出口 的含义是 maze 边界 上的 空格子。entrance 格子 不算 出口。

请你返回从 entrance 到最近出口的最短路径的 步数 ，如果不存在这样的路径，请你返回 -1 。

```
示例 1：


输入：maze = [["+","+",".","+"],[".",".",".","+"],["+","+","+","."]], entrance = [1,2]
输出：1
解释：总共有 3 个出口，分别位于 (1,0)，(0,2) 和 (2,3) 。
一开始，你在入口格子 (1,2) 处。
- 你可以往左移动 2 步到达 (1,0) 。
- 你可以往上移动 1 步到达 (0,2) 。
从入口处没法到达 (2,3) 。
所以，最近的出口是 (0,2) ，距离为 1 步。
示例 2：

输入：maze = [["+","+","+"],[".",".","."],["+","+","+"]], entrance = [1,0]
输出：2
解释：迷宫中只有 1 个出口，在 (1,2) 处。
(1,0) 不算出口，因为它是入口格子。
初始时，你在入口与格子 (1,0) 处。
- 你可以往右移动 2 步到达 (1,2) 处。
所以，最近的出口为 (1,2) ，距离为 2 步。
示例 3：


输入：maze = [[".","+"]], entrance = [0,0]
输出：-1
解释：这个迷宫中没有出口。
 

提示：

maze.length == m
maze[i].length == n
1 <= m, n <= 100
maze[i][j] 要么是 '.' ，要么是 '+' 。
entrance.length == 2
0 <= entrancerow < m
0 <= entrancecol < n
entrance 一定是空格子。
```

最开始想用深搜的，但是超时了

```c++
class Solution {
public:
    int nearestExit(vector<vector<char>>& maze, vector<int>& entrance) {
        if (maze.empty() || maze[0].empty()) return 0;
        int m = maze.size();
        int n = maze[0].size();
        int min_step = -1;
        vector<vector<int>> visited(m, vector<int>(n, INT_MAX));
        dfs(maze, visited, entrance[0], entrance[1], 0, min_step);
        return min_step;
    }
    void dfs(vector<vector<char>> &maze, vector<vector<int>> &visited, int row, int col, int step, int &min_step) {
        int m = maze.size();
        int n = maze[0].size();
        if (row < 0 || row >= m || col < 0 || col >= n) return;
        if (step >= visited[row][col]) return;
        if (maze[row][col] == '+') return;
        if (step > 0 && (row == 0 || row == m-1 || col == 0 || col == n-1)) { // entrance不算出口，所以step=0时不能更新min_step
            if (min_step == -1) min_step = step;
            else min_step = min(min_step, step);
        }
        visited[row][col] = step;
        ++step;
        // maze[row][col] = '+';
        dfs(maze, visited, row-1, col, step, min_step);
        dfs(maze, visited, row+1, col, step, min_step);
        dfs(maze, visited, row, col-1, step, min_step);
        dfs(maze, visited, row, col+1, step, min_step);
    }
};
```

因为题目要求最短路径步数，所以用广搜更合适，核心思想是从entrance一步步扩散出去，第一次遇到出口就可以结束了，最开始写的版本还是会超时，看了答案，因为在入队列时没有给孩子节点visited标记，导致可能会重复入队列

```c++
class Solution {
public:
    int nearestExit(vector<vector<char>>& maze, vector<int>& entrance) {
        if (maze.empty() || maze[0].empty()) return 0;
        int m = maze.size();
        int n = maze[0].size();
        vector<vector<bool>> visited(m, vector<bool>(n, false));
        int step = 0;
        queue<pair<int, int>> q;
        q.push({entrance[0], entrance[1]});
        int sz = q.size();
        while (!q.empty()) {
            pair<int, int> p = q.front();
            q.pop();
            int row = p.first, col = p.second;
            visited[row][col] = true;
            if (step > 0 && (row == 0 || row == m-1 || col == 0 || col == n-1)) { // entrance不算出口，所以step=0时不能更新min_step
                return step; // 因为是广搜，所以先搜到的出口一定是最近的
            }
            // 往四周扩散，广搜，入队列
            if (row > 0 && maze[row-1][col] == '.' && !visited[row-1][col]) q.push({row-1, col});
            if (col > 0 && maze[row][col-1] == '.' && !visited[row][col-1]) q.push({row, col-1});
            if (row < m-1 && maze[row+1][col] == '.' && !visited[row+1][col]) q.push({row+1, col});
            if (col < n-1 && maze[row][col+1] == '.' && !visited[row][col+1]) q.push({row, col+1});

            // 当前节点是该层最后一个节点，step+1
            if (--sz == 0) {
                sz = q.size();
                ++step;
            }
        }
        return -1;
    }
};
```

修改为下面这样就可以ac了

```c++
class Solution {
public:
    int nearestExit(vector<vector<char>>& maze, vector<int>& entrance) {
        if (maze.empty() || maze[0].empty()) return 0;
        int m = maze.size();
        int n = maze[0].size();
        vector<vector<bool>> visited(m, vector<bool>(n, false));
        int step = 0;
        queue<pair<int, int>> q;
        q.push({entrance[0], entrance[1]});
        int sz = q.size();
        while (!q.empty()) {
            pair<int, int> p = q.front();
            q.pop();
            int row = p.first, col = p.second;
            visited[row][col] = true;
            if (step > 0 && (row == 0 || row == m-1 || col == 0 || col == n-1)) { // entrance不算出口，所以step=0时不能更新min_step
                return step; // 因为是广搜，所以先搜到的出口一定是最近的
            }
            // 往四周扩散，广搜，入队列
            if (row > 0 && maze[row-1][col] == '.' && !visited[row-1][col]) {
                q.push({row-1, col});
                visited[row-1][col] = true;
            }
            if (col > 0 && maze[row][col-1] == '.' && !visited[row][col-1]) {
                q.push({row, col-1});
                visited[row][col-1] = true;
            }
            if (row < m-1 && maze[row+1][col] == '.' && !visited[row+1][col]) {
                q.push({row+1, col});
                visited[row+1][col] = true;
            }
            if (col < n-1 && maze[row][col+1] == '.' && !visited[row][col+1]) {
                q.push({row, col+1});
                visited[row][col+1] = true;
            }

            // 当前节点是该层最后一个节点，step+1
            if (--sz == 0) {
                sz = q.size();
                ++step;
            }
        }
        return -1;
    }
};
```

看了官方解答，直接复用maze数组，走过的格子就标记成'+'，这样也可以避免回环和重复入队列

```c++
class Solution {
public:
    int nearestExit(vector<vector<char>>& maze, vector<int>& entrance) {
        if (maze.empty() || maze[0].empty()) return 0;
        int m = maze.size();
        int n = maze[0].size();
        int step = 0;
        queue<pair<int, int>> q;
        q.push({entrance[0], entrance[1]});
        maze[entrance[0]][entrance[1]] = '+';
        int sz = q.size();
        while (!q.empty()) {
            pair<int, int> p = q.front();
            q.pop();
            int row = p.first, col = p.second;
            if (step > 0 && (row == 0 || row == m-1 || col == 0 || col == n-1)) { // entrance不算出口，所以step=0时不能更新min_step
                return step; // 因为是广搜，所以先搜到的出口一定是最近的
            }
            // 往四周扩散，广搜，入队列
            if (row > 0 && maze[row-1][col] == '.') {
                q.push({row-1, col});
                maze[row-1][col] = '+';
            }
            if (col > 0 && maze[row][col-1] == '.') {
                q.push({row, col-1});
                maze[row][col-1] = '+';
            }
            if (row < m-1 && maze[row+1][col] == '.') {
                q.push({row+1, col});
                maze[row+1][col] = '+';
            }
            if (col < n-1 && maze[row][col+1] == '.') {
                q.push({row, col+1});
                maze[row][col+1] = '+';
            }

            // 当前节点是该层最后一个节点，step+1
            if (--sz == 0) {
                sz = q.size();
                ++step;
            }
        }
        return -1;
    }
};
```

## 模拟

### 6. N 字形变换(Medium)

将一个给定字符串 s 根据给定的行数 numRows ，以从上往下、从左到右进行 Z 字形排列。

比如输入字符串为 "PAYPALISHIRING" 行数为 3 时，排列如下：

P   A   H   N
A P L S I I G
Y   I   R
之后，你的输出需要从左往右逐行读取，产生出一个新的字符串，比如："PAHNAPLSIIGYIR"。

请你实现这个将字符串进行指定行数变换的函数：

string convert(string s, int numRows);

示例 1：

输入：s = "PAYPALISHIRING", numRows = 3
输出："PAHNAPLSIIGYIR"
示例 2：
输入：s = "PAYPALISHIRING", numRows = 4
输出："PINALSIGYAHRPI"
解释：
P     I    N
A   L S  I G
Y A   H R
P     I
示例 3：

输入：s = "A", numRows = 1
输出："A"

提示：

1 <= s.length <= 1000
s 由英文字母（小写和大写）、',' 和 '.' 组成
1 <= numRows <= 1000

题目理解：

- 字符串 s 是以 Z 字形为顺序存储的字符串，目标是按行打印。
- 设 numRows 行字符串分别为 s1s2s3...sn，则容易发现：按顺序遍历字符串 s 时，每个字符 c 在 Z 字形中对应的 行索引 先从 s1增大至 sn，再从 sn减小至 s1…… 如此反复。
- 因此，解决方案为：模拟这个行索引的变化，在遍历 s 中把每个字符填到正确的行 res[i] 。
- 算法流程： 按顺序遍历字符串 s；
  - res[i] += c： 把每个字符 c 填入对应行 si
  - i += flag： 更新当前字符 c 对应的行索引；
  - flag = - flag： 在达到 ZZZ 字形转折点时，执行反向。

复杂度分析：
时间复杂度 O(N) ：遍历一遍字符串 s；
空间复杂度 O(N) ：各行字符串共占用 O(N) 额外空间。

```c++
class Solution {
public:
    string convert(string s, int numRows) {
        if (numRows < 2) return s;
        int n = s.size();
        vector<string> rows(numRows);
        int flag = -1;
        int row = 0;
        for (int i = 0; i < n; ++i) {
            rows[row] += s[i];
            if (row == 0 || row == numRows - 1) {
                flag = -flag;
            }
            row += flag;
        }
        string ans;
        for (string &row : rows) {
            ans += row;
        }
        return ans;
    }
};
```

### 190.颠倒二进制位(Easy)

颠倒给定的 32 位无符号整数的二进制位

示例 1：

输入: 00000010100101000001111010011100
输出: 00111001011110000010100101000000
解释: 输入的二进制串 00000010100101000001111010011100 表示无符号整数 43261596，
     因此返回 964176192，其二进制表示形式为 00111001011110000010100101000000。
示例 2：

输入：11111111111111111111111111111101
输出：10111111111111111111111111111111
解释：输入的二进制串 11111111111111111111111111111101 表示无符号整数 4294967293，
     因此返回 3221225471 其二进制表示形式为 10111111111111111111111111111111 。

提示：

请注意，在某些语言（如 Java）中，没有无符号整数类型。在这种情况下，输入和输出都将被指定为有符号整数类型，并且不应影响您的实现，因为无论整数是有符号的还是无符号的，其内部的二进制表示形式都是相同的。
在 Java 中，编译器使用二进制补码记法来表示有符号整数。因此，在上面的 示例 2 中，输入表示有符号整数 -3，输出表示有符号整数 -1073741825。

这题本身不是很难，一个while循环即可搞定，一次AC，时间复杂度O(logN)

```c++
class Solution {
public:
    uint32_t reverseBits(uint32_t n) {
        uint32_t ans = 0;
        for (int i = 1; i <= 32; ++i) {
            int bit = n & 1;
            ans |= bit << (32 - i);
            n >>= 1;
        }
        return ans;
    }
};
```

思考，如何不用循环做呢？

可以考虑分治方法，既然知道 int 值一共32位，那么可以采用分治思想，反转左右16位，然后反转每个16位中的左右8位，依次类推，最后反转2位，反转后合并即可，同时可以利用位运算在原地反转。JDK中的Integer.bitCount()函数也是使用类似的方法。

0xff00ff00 表示 1111 1111 0000 0000 _ 1111 1111 0000 0000

0x00ff00ff 表示 0000 0000 1111 1111 _ 0000 0000 1111 1111

0xf0f0f0f0 表示 1111 0000 1111 0000 _ 1111 0000 1111 0000

0x0f0f0f0f 表示 0000 1111 0000 1111 _ 0000 1111 0000 1111

0xcccccccc 表示 1100 1100 1100 1100 _ 1100 1100 1100 1100

0x33333333 表示 0011 0011 0011 0011 _ 0011 0011 0011 0011

0xaaaaaaaa 表示 1010 1010 1010 1010 _ 1010 1010 1010 1010

0x55555555 表示 0101 0101 0101 0101 _ 0101 0101 0101 0101

```c++
class Solution {
public:
    uint32_t reverseBits(uint32_t n) {
        n = (n >> 16) | (n << 16); // 32位中16位和16位翻转
        n = ((n & 0xff00ff00) >> 8) | ((n & 0x00ff00ff) << 8); // 16位中8位和8位翻转
        n = ((n & 0xf0f0f0f0) >> 4) | ((n & 0x0f0f0f0f) << 4); // 8位中4位和4位翻转
        n = ((n & 0xcccccccc) >> 2) | ((n & 0x33333333) << 2); // 4位中2位和2位翻转
        n = ((n & 0xaaaaaaaa) >> 1) | ((n & 0x55555555) << 1); // 2位中1位和1位翻转
        return n;
    }
};
```

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

### 43.字符串相乘

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

### 54. 螺旋矩阵 @hot100

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

刷hot100，直接A了，定义方向，在遍历时不管当前方向，遍历到到该方向最大值时，改变方向

```c++
class Solution {
public:
    vector<int> spiralOrder(vector<vector<int>>& matrix) {
        vector<vector<int>> direction = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}}; // →↓←↑
        int m = matrix.size();
        if (m == 1) return matrix[0];
        if (m == 0) return {};
        int n = matrix[0].size();
        vector<int> res;
        int cur_dir = 0;
        int i = 0;
        int j = 0;
        int count = m*n;
        int max_index_right = n - 1;
        int max_index_down = m - 1;
        int max_index_left = 0;
        int max_index_up = 1;
        while (count-- > 0) {
            res.push_back(matrix[i][j]);
            if (cur_dir == 0 && j == max_index_right) {
                max_index_right--;
                cur_dir = (cur_dir + 1) % 4;
            } else if (cur_dir == 1 && i == max_index_down) {
                max_index_down--;
                cur_dir = (cur_dir + 1) % 4;
            } else if ( cur_dir == 2 && j == max_index_left) {
                max_index_left++;
                cur_dir = (cur_dir + 1) % 4;
            } else if (cur_dir == 3 && i == max_index_up) {
                max_index_up++;
                cur_dir = (cur_dir + 1) % 4;
            }
            i = i + direction[cur_dir][0];
            j = j + direction[cur_dir][1];
        }
        return res;
    }
};
```

### 59. 螺旋矩阵 II(Medium)

给定一个正整数 n，生成一个包含 1 到 n2 所有元素，且元素按顺时针顺序螺旋排列的正方形矩阵。

示例:

输入: 3
输出:
[
 [ 1, 2, 3 ],
 [ 8, 9, 4 ],
 [ 7, 6, 5 ]
]

没啥好说的，就是刚

```c++
class Solution {
public:
    vector<vector<int>> generateMatrix(int n) {
        vector<vector<int>> ans(n, vector<int>(n, 0));
        int i = 0;
        int j = 0;
        int loop = 0;
        int num = 1;
        while (true) {
            while (j <= n-1-loop) ans[i][j++] = num++;
            --j;
            ++i;
            while (i <= n-1-loop) ans[i++][j] = num++;
            --i;
            --j;
            while (j >= loop) ans[i][j--] = num++;
            ++j;
            --i;
            ++loop;
            while (i >= loop) ans[i--][j] = num++;
            ++i;
            ++j;
            if (n*n+1 == num) break;
        }
        return ans;
    }
};
```

### 292. Nim 游戏

你和你的朋友，两个人一起玩 Nim 游戏：桌子上有一堆石头，每次你们轮流拿掉 1 - 3 块石头。 拿掉最后一块石头的人就是获胜者。你作为先手。

你们是聪明人，每一步都是最优解。 编写一个函数，来判断你是否可以在给定石头数量的情况下赢得游戏。

示例:

输入: 4
输出: false
解释: 如果堆中有 4 块石头，那么你永远不会赢得比赛；
     因为无论你拿走 1 块、2 块 还是 3 块石头，最后一块石头总是会被你的朋友拿走。

```c++
class Solution {
public:
    bool canWinNim(int n) {
        // n=4x, x为自然数，必输
        // n=4x+1，可先取一个，然后每轮跟随对手决策保证每轮减少4个，自己可以拿最后一个
        // n=4x+2, 4x+3同理
        if (n % 4 == 0) return false;
        return true;
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

### 1037. 有效的回旋镖(Easy)

回旋镖定义为一组三个点，这些点各不相同且不在一条直线上。

给出平面上三个点组成的列表，判断这些点是否可以构成回旋镖。

示例 1：

输入：[[1,1],[2,3],[3,2]]
输出：true
示例 2：

输入：[[1,1],[2,2],[3,3]]
输出：false

提示：

points.length == 3
points[i].length == 2
0 <= points[i][j] <= 100

注意浮点数最好不要用等号比较

```c++
class Solution {
public:
    bool isBoomerang(vector<vector<int>>& points) {
        double dx1 = points[1][0] - points[0][0];
        double dy1 = points[1][1] - points[0][1];
        double k1;
        if (dx1 == 0) {
            k1 = dy1 > 0 ? 101 : -101;
        } else {
            k1 = dy1 / dx1;
        }
        double dx2 = points[2][0] - points[0][0];
        double dy2 = points[2][1] - points[0][1];
        double k2;
        if (dx2 == 0) {
            k2 = dy2 > 0 ? 101 : -101;
        } else {
            k2 = dy2 / dx2;
        }
        if ((dx1 == 0 && dy1 == 0) || (dx2 == 0 && dy2 == 0)) return false;
        if (abs(k1 - k2) < 0.0001) return false;
        return true;
    }
};
```

### 1046. 最后一块石头的重量

有一堆石头，每块石头的重量都是正整数。

每一回合，从中选出两块 最重的 石头，然后将它们一起粉碎。假设石头的重量分别为 x 和 y，且 x <= y。那么粉碎的可能结果如下：

如果 x == y，那么两块石头都会被完全粉碎；
如果 x != y，那么重量为 x 的石头将会完全粉碎，而重量为 y 的石头新重量为 y-x。
最后，最多只会剩下一块石头。返回此石头的重量。如果没有石头剩下，就返回 0。

示例：

输入：[2,7,4,1,8,1]
输出：1
解释：
先选出 7 和 8，得到 1，所以数组转换为 [2,4,1,1,1]，
再选出 2 和 4，得到 2，所以数组转换为 [2,1,1,1]，
接着是 2 和 1，得到 1，所以数组转换为 [1,1,1]，
最后选出 1 和 1，得到 0，最终数组转换为 [1]，这就是最后剩下那块石头的重量。

优先队列（最大堆）一把整，一次性AC了

```c++
class Solution {
public:
    int lastStoneWeight(vector<int>& stones) {
        priority_queue<int> dq;
        for (int &val : stones) dq.push(val);
        int x, y, diff;
        while (dq.size() >= 2) {
            x = dq.top();
            dq.pop();
            y = dq.top();
            dq.pop();
            diff = x - y;
            if (diff != 0) dq.push(diff);
        }
        if (!dq.empty()) return dq.top();
        return 0;
    }
};
```

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

### 49. 字母异位词分组 #hot 100

给定一个字符串数组，将字母异位词组合在一起。字母异位词指字母相同，但排列不同的字符串。

示例:

输入: ["eat", "tea", "tan", "ate", "nat", "bat"]
输出:
[
  ["ate","eat","tea"],
  ["nat","tan"],
  ["bat"]
]
说明：

所有输入均为小写字母。
不考虑答案输出的顺序。

哈希表，每个str排序后会作为相同的key，存入一个`map<string, vector<string>>`中，

```c++
class Solution {
public:
    vector<vector<string>> groupAnagrams(vector<string>& strs) {
        vector<vector<string>> ans;
        unordered_map<string, vector<string>> m;
        for (const string& s : strs) {
            string t = s; // t为单词的按顺序排列，作为key值
            sort(t.begin(),t.end());
            m[t].push_back(s);   // m[t]为异位词构成的vector
        }
        for (const auto& n : m)
            ans.push_back(n.second);
        return ans;
    }
};
```

最开始想的是这些字符串能否映射到唯一哈希上，26个小写字母，因为长度是100，所以相邻字母的哈希值跃迁是100，比如a代表1，b代表100，c代表1000，但这样一个字符串的哈希值太大了，所以没想通

于是，第一次尝试，很挫的写法，直接暴力

时间
1348 ms
击败
5.5%
内存
30.5 MB
击败
5%

```c++
class Solution {
public:
struct Combine {
  vector<int> strIndex;
  vector<int> alphaVec;
};
vector<vector<string>> groupAnagrams(vector<string> &strs) {
  vector<vector<string>> res;
  if (strs.size() == 1) {
    return {strs};
  }
  Combine combine = {{0}, vector<int>(26, 0)};
  for (int j = 0; j < strs[0].size(); ++j) {
    combine.alphaVec[strs[0][j] - 'a']++;
  }
  vector<Combine> combines = {combine};

  for (int i = 1; i < strs.size(); ++i) {
    vector<int> vec = vector<int>(26, 0);
    for (int j = 0; j < strs[i].size(); ++j) {
      vec[strs[i][j] - 'a']++;
    }
    bool currentHasAnagramsBefore = false;
    for (auto &combine : combines) {
      bool isSame = true;
      for (int k = 0; k < 26; ++k) {
        if (combine.alphaVec[k] != vec[k]) {
          isSame = false;
          break;
        }
      }
      if (isSame) {
        combine.strIndex.push_back(i);
        currentHasAnagramsBefore = true;
        break;
      }
    }
    if (!currentHasAnagramsBefore) {
      Combine newCombine;
      newCombine.strIndex = {i};
      newCombine.alphaVec = vec;
      combines.push_back(newCombine);
    }
  }
  for (auto &combine : combines) {
    vector<string> anagrams;
    for (int strIndex : combine.strIndex) {
      anagrams.push_back(strs[strIndex]);
    }
    res.push_back(anagrams);
  }
  return res;
}
};
```

自定义映射，好像是最慢的。。

首先初始化 key = "0#0#0#0#0#"，数字分别代表 abcde 出现的次数，# 用来分割。

这样的话，"abb" 就映射到了 "1#2#0#0#0"。

"cdc" 就映射到了 "0#0#2#1#0"。

"dcc" 就映射到了 "0#0#2#1#0"。

```c++
class Solution {
public:
    vector<vector<string>> groupAnagrams(vector<string>& strs) {
        vector<vector<string>> ans;
        unordered_map<string, vector<string>> m;
        for (int i = 0; i < strs.size(); i++) {
            vector<int> num(26, 0); //记录每个字符的次数
            for (int j = 0; j < strs[i].size(); j++) {
                num[strs[i][j] - 'a']++;
            }
            string key = ""; //转成 0#2#2# 类似的形式
            for (int j = 0; j < num.size(); j++) {
                key = key + to_string(num[j]) + '#';
            }
            if (m.count(key)) {
                m[key].push_back(strs[i]);
            } else {
                vector<string> temp;
                temp.push_back(strs[i]);
                m[key] = temp;
            }
        }
        for (const auto& p : m) {
            ans.push_back(p.second);
        }
        return ans;
    }
};
```

最优解法，**算术基本定理**，又称为正整数的唯一分解定理，即：每个大于1的自然数，要么本身就是质数，要么可以写为2个以上的质数的积，而且这些质因子按大小排列之后，写法仅有一种方式。我们把每个字符串都映射到一个正数上。

用一个数组存储质数 prime = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103}。然后每个字符串的字符减去 ' a ' ，然后取到 prime 中对应的质数。把它们累乘。

例如 abc ，就对应 'a' - 'a'， 'b' - 'a'， 'c' - 'a'，即 0, 1, 2，也就是对应素数 2 3 5，然后相乘 `2 * 3 * 5 = 30`，就把 "abc" 映射到了 30。

时间复杂度O(n*K) K是字符串最大长度，空间复杂度O(NK) ，用来存储结果，但这种方法有一定局限性，累乘可能会溢出，不过需要字符串长度很长才行，力扣OJ里没有这么刁难的case

时间
20 ms
击败
98.77%
内存
18.1 MB
击败
92.55%

```c++
class Solution {
public:
    vector<vector<string>> groupAnagrams(vector<string>& strs) {
        vector<vector<string>> res;
        unordered_map<double, vector<string>> m;
        double a[26] = {2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101};
        for (const string& s : strs) {
            double t = 1;
            for (char c : s) t *= a[c - 'a'];
            m[t].push_back(s);
        }
        for(auto& n : m)
            res.push_back(n.second);
        return res;
    }
};
```

### 325. 和为k的最长子数组(Meiudm)

描述：给了一个数组，一个数字k，问数组中子序列中，相加等于k的最长子序列的长度。

Input: nums = [1, -1, 5, -2, 3], k = 3
Output: 4
Explanation: The subarray [1, -1, 5, -2] sums to 3 and is the longest.

Input: nums = [-2, -1, 2, 1], k = 1
Output: 2
Explanation: The subarray [-1, 2] sums to 1 and is the longest.

使用一个字典，建立到当前位置的元素累加和与元素位置的一个映射，即dict：sum -> i。然后在寻找最长子数组的过程时，就是找k-sum是否作为key存在于字典当中。代码如下

```c++
class Solution {
    int masSubArrayLen(vector<int> nums, int k) {
        int res = 0;
        if (nums.empty()) return res;
        unordered_map<int, int> map;
        map[0] = -1;
        int sum = 0;
        for (int i = 0; i < nums.size(); ++i) {
            sum += val;
            if (map.count(sum - k)) {
                res = max(res, i - map[sum-k]);
            }
            if (map.count(sum)) {
                map[sum] = i;
            }
        }
        return res;
    }
};
```

### 454. 四数之和II

前面两题都很简单，用哈希表，空间换取时间

### 560. 和为K的子数组 @hot100

给定一个整数数组和一个整数 k，你需要找到该数组中和为 k 的连续的子数组的个数。

示例 1 :

输入:nums = [1,1,1], k = 2
输出: 2 , [1,1] 与 [1,1] 为两种不同的情况。
说明 :

数组的长度为 [1, 20,000]。
数组中元素的范围是 [-1000, 1000] ，且整数 k 的范围是 [-1e7, 1e7]。

题解：

- 所以可以用一次遍历搞定，每次都把当前值加入到**累加和**sum中

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

为什么不用dp数组：因为状态转换方程：sum[i] = sum[i-1] = nums[i]，遍历时，sum只与前一个sum状态有关，所以直接省略成单变量

举个例子，[1,1]，和为2，当遍历到i=1时，发现k-sum=2-2=0，所以找到之前存储的hash[0]=1，于是count=count+1=0+1=1，1就是正确答案

```c++
class Solution {
public:
    int subarraySum(vector<int>& nums, int k) {
        // key前缀和，value出现次数，前缀和为0还没开始遍历就有1次了，所以初始化为1
        unordered_map<int, int> hash;
        hash[0] = 1;
        int count = 0;
        int sum = 0;  // 前缀和
        for(int i = 0; i < nums.size(); ++i){
            sum += nums[i];
            // 求下标j到i的子数组和为k，条件可转换为sum[i] - sum[j-1] == k
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

### 347. 前 K 个高频元素 (Medium) @hot100

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

上面是y总的题解，我觉得这题用优先队列（最大堆）会更好

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

如果堆中不允许存放多余元素，那么我们就维护一个最大大小为k的最小堆，当还有元素，与堆顶最小值判断，大于就加入，然后把堆顶最小值pop，这样最后最小堆的所有元素即为答案

```c++
class Solution {
public:
    static bool cmp(pair<int, int>& m, pair<int, int>& n) {
        return m.second > n.second;
    }

    vector<int> topKFrequent(vector<int>& nums, int k) {
        unordered_map<int, int> occurrences;
        for (auto& v : nums) {
            occurrences[v]++;
        }

        // pair 的第一个元素代表数组的值，第二个元素代表了该值出现的次数
        priority_queue<pair<int, int>, vector<pair<int, int>>, decltype(&cmp)> q(cmp);
        for (auto& [num, count] : occurrences) {
            if (q.size() == k) {
                if (q.top().second < count) {
                    q.pop();
                    q.emplace(num, count);
                }
            } else {
                q.emplace(num, count);
            }
        }
        vector<int> ret;
        while (!q.empty()) {
            ret.emplace_back(q.top().first);
            q.pop();
        }
        return ret;
    }
};

作者：力扣官方题解
链接：https://leetcode.cn/problems/top-k-frequent-elements/solutions/402568/qian-k-ge-gao-pin-yuan-su-by-leetcode-solution/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

用了排序，时间复杂度为O(nlogn)，没有满足题目进阶要求的优于O(nlogn)

```c++
class Solution {
public:
    static bool myComp(pair<int, int> &a, pair<int, int> &b) {
        return a.second > b.second;
    }
    vector<int> topKFrequent(vector<int>& nums, int k) {
        map<int, int> freq;
        for (int num : nums) {
            ++freq[num];
        }
        vector<pair<int, int>> vec (freq.begin(), freq.end());
        sort(vec.begin(), vec.end(), myComp); // 用了排序，时间复杂度为O(nlogn)，没有满足题目进阶要求的优于
        vector<int> res(k, 0);
        for (int i = 0; i < k; ++i) {
            res[i] = vec[i].first;
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

### 128. 最长连续序列(Hard) @hot100

hard题，就不看了hhh(改为中等题了)

刷字节top题碰到了，还是看答案弄懂它吧

先将所有元素存储到哈希表，时间复杂度为 O(N);
对每一个元素进行查表，向上向下分别查找，找到所有相邻元素，并将找到的元素标记为已访问。
查找完毕之后，更新结果。
由于：每次查找都将找到的相邻元素标记为已访问，之后如果访问到该元素，发现为已访问就跳过。
所以：尽管 for 里面有 while 循环，但实际时间复杂度还是O (N)。

```c++
class Solution {
public:
    int longestConsecutive(vector<int>& nums) {
        unordered_set<int> set;
        int cur_len = 0;
        int max_len = 0;
        for (const int& num : nums) set.insert(num);
        for (const int& num : nums) {
            if (set.count(num-1)) {
                continue; // 当前num是之前出现的数字+1，肯定在num-1的while循环中计算过，可跳过
            }
            int cur_len = 1; // num-1不存在，num作为起点，计算连续序列的长度
            int i = 1;
            while (set.count(num+i)) {
                ++cur_len;
                ++i;
            }
            max_len = max(max_len, cur_len);
        }
        return max_len;
    }
};
```

刷hot100时刷到了，

自己想的是用char数组，但是超时了

思路：用一个大数组存储最小数和最小数之间的所有，最后遍历大数组，取最长的出现的序列，满足O(n)要求，但是这个例子运行超时了“[0,1,2,4,8,5,6,7,9,3,55,88,77,99,999999999]”

```c++
class Solution {
public:
    int longestConsecutive(vector<int>& nums) {
        if (nums.empty()) return 0;
        if (nums.size() == 1) return 1;
        int max_ = INT_MIN;
        int min_ = INT_MAX;
        for (auto num : nums) {
            max_ = max(max_, num);
            min_ = min(min_, num);
        }
        long len = (long)(max_ - min_ + 1);
        vector<char> a (len, 0);
        for (auto num : nums) {
            a[num - min_] = 1;
        }
        int max_len = 1;
        int begin = -1;
        int cur_len = 0;
        for (int i = 0; i < len; ++i) {
            if (a[i] != 1) {
                begin = -1;
            } else {
                if (begin == -1){
                    begin = i;
                }
                cur_len = i - begin + 1;
                max_len = max(max_len, cur_len);
            }
        }
        return max_len;
    }
};
```

并查集，路径压缩加速union（merge）操作，平衡化可做可不做

```c++
class Solution {
public:
    vector<int> fa;
    vector<int> size; // 每个节点作为根节点时连通分量中的节点数
    int find(int x) {
        if (x != fa[x]) {
            fa[x] = find(fa[x]); // 路径压缩
        }
        return fa[x];
    }

    void merge(int p, int q) {
        int a = find(p);
        int b = find(q);
        if (a == b) return;
        if (size[a] <= size[b]) { // 平衡化
            fa[a] = b;
            size[b] += size[a];
        } else {
            fa[b] = a;
            size[a] += size[b];
        }
    }

    int getMaxConnected() {
        int ans = INT_MIN;
        for (int i = 0; i < fa.size(); ++i) {
            if (i == fa[i]) {
                ans = max(ans, size[i]);
            }
        }
        return ans;
    }
    
    int longestConsecutive(vector<int>& nums) {
        if (nums.empty()) return 0;
        // 初始化UF
        int n = nums.size();
        fa.resize(n);
        size.resize(n);
        for (int i = 0; i < n; ++i) {
            fa[i] = i;
            size[i] = 1;
        }

        unordered_map<int, int> hashmap;
        for (int i = 0; i < n; ++i) {
            if (hashmap.count(nums[i])) continue; // 当前值已经计算
            if (hashmap.count(nums[i] - 1)) {
                merge(i, hashmap[nums[i] - 1]); // 将当前值与-1值连通
            }
            if (hashmap.count(nums[i] + 1)) {
                merge(i, hashmap[nums[i] + 1]); // 将当前值与+1值连通
            }
            hashmap[nums[i]] = i;
        }
        return getMaxConnected();
    }
};
```


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

根据yxc老师的思路开了一个a[26][500000],首先将整个表赋值成-1代表初始状态，a[i][j]表示字符串t中、位置在第j号元素之后的、字母`'a'+i`的出现序号

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
        for(int i=t.length()-1;i>=0;i--){ // 先打表，对于大数据量可以提前打表用空间换时间
            val[t[i]-'a']=i;
            for(int j=0;j<26;j++)
                a[j][i]=val[j];
        }
        int pos=0;
        for(int i=0;i<s.length();i++){
            //cout << a[s[i]-'a'][pos] << endl;
            if(a[s[i]-'a'][pos]==-1) // 表示a[j][j]找不到这样的序号，说明t无法匹配
                return false;
            else{
                pos=a[s[i]-'a'][pos]; // 说明能找到，直接跳转到下一个字符出现的位置
                pos++; // s[i]与t[pos]相等，于是继续寻找：pos+1，i在for循环里+1
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

### 55. 跳跃游戏 @hot100

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

动态规划或者贪心或者回溯都可解决,

动态规划：dp[i]记录nums[i]之前所能到达的最远距离，dp[i] = max(dp[i-1], i + nums[i])，空间优化可以将dp[i]变为dp

直接一次遍历即可，用一个变量记录当前能够跳到的最远距离，如果当前位置超过了最远距离，则失败

```c++
class Solution {
public:
    bool canJump(vector<int>& nums) {
        int n = nums.size();
        if (n == 1) return true;
        if (nums[0] == 0) return false;
        int range = 0; // 初始时，只能到达下标0
        for (int i = 0; i < n; ++i) {
            if (i > range) {
                return false;
            } else {
                range = max(range, i + nums[i]);
            }
        }
        return true;
    }
};
```

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

回溯：从终点（末位置）开始试探回溯。不只是终点，对于任意的一个点i，我们可以遍历[0,i-1]中的点j，如果有nums[j] >= i-j，那么就能够从点i到达点j，随之进一步考察j能否被[0,j-1]中的点到达。如果中途出现不可到达点，则回溯到上一层（离终点较近）的点。

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

与直观解法的差别：直观解法关注的是当前格子能跳多远，并以此更新后面的跳数，而贪心法尝试从最少步数开始，一步步地向最远段扩展

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

刷hot100时的写法，也很好理解，区别在于steps算不算

```c++
class Solution {
public:
    int jump(vector<int>& nums) {
        int n = nums.size();
        if (n == 1) return 0;
        int step = 1; // 从第1跳开始，计算第i跳的最远距离
        int end = 0; // 前1跳的最远距离
        int farthest = 0; // 在第i跳时，更新下一跳的最远距离
        int i = 0;
        while (end < n) {
            farthest = max(farthest, i + nums[i]);
            if (farthest >= n - 1) {
                return step;
            }
            if (i == end) {
                ++step;
                end = farthest;
            }
            ++i;
        }
        return step;
    }
};
```

### 334. 递增的三元子序列

给你一个整数数组 nums ，判断这个数组中是否存在长度为 3 的递增子序列。

如果存在这样的三元组下标 (i, j, k) 且满足 i < j < k ，使得 nums[i] < nums[j] < nums[k] ，返回 true ；否则，返回 false 。


```
示例 1：

输入：nums = [1,2,3,4,5]
输出：true
解释：任何 i < j < k 的三元组都满足题意
示例 2：

输入：nums = [5,4,3,2,1]
输出：false
解释：不存在满足题意的三元组
示例 3：

输入：nums = [2,1,5,0,4,6]
输出：true
解释：三元组 (3, 4, 5) 满足题意，因为 nums[3] == 0 < nums[4] == 4 < nums[5] == 6
 

提示：

1 <= nums.length <= 5 * 105
-231 <= nums[i] <= 231 - 1
 

进阶：你能实现时间复杂度为 O(n) ，空间复杂度为 O(1) 的解决方案吗？
```

若要求空间复杂度为O1，则只能通过遍历，而且还不能嵌套循环，否则时间复杂度达不到O1，想了很久，贪心可解，从左到右遍历，维护变量p和q，在保证`nums[p]<nums[q]`的前提下，使得`nums[q]`越小越好，注意在遍历过程有可能会遇到更小的数，此时要暂存起来

```c++
class Solution {
public:
    bool increasingTriplet(vector<int>& nums) {
        if (nums.size() < 3) return false;
        int n = nums.size();
        int p = 0;
        while (p < n - 2) {
            if (nums[p] >= nums[p+1]) ++p;
            else break;
        }
        if (p == n - 2) return false; // 递减序列，肯定无解
        int cur_min_index = p; // 从左往右遍历，记录到目前为止最小值的序号
        int q = p + 1; // 贪心：维持nums[p] < num[q]
        for (int i = p + 2; i < n; ++i) {
            if (nums[i] < nums[cur_min_index]) cur_min_index = i;
            if (nums[i] > nums[q]) return true;
            if (nums[i] > nums[cur_min_index] && nums[i] < nums[q]) {
                // 尝试在遍历中更新p和q，使得nums[q]更小，也就是三元中的mid元素越小越好，这样更有可能凑成递增的三元子序列
                p = cur_min_index;
                q = i;
            }
        }
        return false;
    }
};
```

后来看了题解，可以不用中间变量暂存

```
首先，新建两个变量 small 和 mid ，分别用来保存题目要我们求的长度为 3 的递增子序列的最小值和中间值。

接着，我们遍历数组，每遇到一个数字，我们将它和 small 和 mid 相比，若小于等于 small ，则替换 small；否则，若小于等于 mid，则替换 mid；否则，若大于 mid，则说明我们找到了长度为 3 的递增数组！

上面的求解过程中有个问题：当已经找到了长度为 2 的递增序列，这时又来了一个比 small 还小的数字，为什么可以直接替换 small 呢，这样 small 和 mid 在原数组中并不是按照索引递增的关系呀？

Trick 就在这里了！假如当前的 small 和 mid 为 [3, 5]，这时又来了个 1。假如我们不将 small 替换为 1，那么，当下一个数字是 2，后面再接上一个 3 的时候，我们就没有办法发现这个 [1,2,3] 的递增数组了！也就是说，我们替换最小值，是为了后续能够更好地更新中间值！

另外，即使我们更新了 small ，这个 small 在 mid 后面，没有严格遵守递增顺序，但它隐含着的真相是，有一个比 small 大比 mid 小的前·最小值出现在 mid 之前。因此，当后续出现比 mid 大的值的时候，我们一样可以通过当前 small 和 mid 推断的确存在着长度为 3 的递增序列。 所以，这样的替换并不会干扰我们后续的计算！



作者：正直清澈方欣欣
链接：https://leetcode.cn/problems/increasing-triplet-subsequence/solutions/66089/c-xian-xing-shi-jian-fu-za-du-xiang-xi-jie-xi-da-b/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

```c++
class Solution {
public:
    bool increasingTriplet(vector<int>& nums) {
        int len = nums.size();
        if (len < 3) return false;
        int low = INT_MAX, mid = INT_MAX;
        for (auto num : nums) {
            if (num <= low) {
                low = num; // 更新最小值
            } else if (num <= mid) {
                mid = num; // 更新中间值
            }  else if (num > mid) {
                return true; // 找到！
            }
        }
        return false;   
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

### 605. 种花问题

假设有一个很长的花坛，一部分地块种植了花，另一部分却没有。可是，花不能种植在相邻的地块上，它们会争夺水源，两者都会死去。

给你一个整数数组 flowerbed 表示花坛，由若干 0 和 1 组成，其中 0 表示没种植花，1 表示种植了花。另有一个数 n ，能否在不打破种植规则的情况下种入 n 朵花？能则返回 true ，不能则返回 false 。

```
示例 1：

输入：flowerbed = [1,0,0,0,1], n = 1
输出：true
示例 2：

输入：flowerbed = [1,0,0,0,1], n = 2
输出：false
 

提示：

1 <= flowerbed.length <= 2 * 104
flowerbed[i] 为 0 或 1
flowerbed 中不存在相邻的两朵花
0 <= n <= flowerbed.length
```

时间On，空间O1

```c++
class Solution {
public:
    bool canPlaceFlowers(vector<int>& flowerbed, int n) {
        // 计算最大种花数量
        // 可以把整个数组想象成被1分割开的全0子区间，现在要求的就是这些全0子区间里面最多能种多少
        // 形象解释：小便池问题:P
        int size = flowerbed.size();
        int flower = 0;
        int avail = 1; // 开头不用考虑左边，所以相当于-1位置有个空花坛
        for (int i = 0; i < size; ++i) {
            if (flowerbed[i] == 1) {
                // 结算一段区间能种几朵花
                if (avail > 0) flower += (avail-1) / 2;
                avail = 0;
            } else {
                ++avail;
            }
        }
        ++avail; // 结束不用考虑右边，相当于size位置有个空花坛
        flower += (avail-1) / 2;
        return flower >= n;
    }
};
```

### 649. Dota2 参议院

medium

Dota2 的世界里有两个阵营：Radiant（天辉）和 Dire（夜魇）

Dota2 参议院由来自两派的参议员组成。现在参议院希望对一个 Dota2 游戏里的改变作出决定。他们以一个基于轮为过程的投票进行。在每一轮中，每一位参议员都可以行使两项权利中的 一 项：

禁止一名参议员的权利：参议员可以让另一位参议员在这一轮和随后的几轮中丧失 所有的权利 。
宣布胜利：如果参议员发现有权利投票的参议员都是 同一个阵营的 ，他可以宣布胜利并决定在游戏中的有关变化。
给你一个字符串 senate 代表每个参议员的阵营。字母 'R' 和 'D'分别代表了 Radiant（天辉）和 Dire（夜魇）。然后，如果有 n 个参议员，给定字符串的大小将是 n。

以轮为基础的过程从给定顺序的第一个参议员开始到最后一个参议员结束。这一过程将持续到投票结束。所有失去权利的参议员将在过程中被跳过。

假设每一位参议员都足够聪明，会为自己的政党做出最好的策略，你需要预测哪一方最终会宣布胜利并在 Dota2 游戏中决定改变。输出应该是 "Radiant" 或 "Dire" 。

```
示例 1：

输入：senate = "RD"
输出："Radiant"
解释：
第 1 轮时，第一个参议员来自 Radiant 阵营，他可以使用第一项权利让第二个参议员失去所有权利。
这一轮中，第二个参议员将会被跳过，因为他的权利被禁止了。
第 2 轮时，第一个参议员可以宣布胜利，因为他是唯一一个有投票权的人。
示例 2：

输入：senate = "RDD"
输出："Dire"
解释：
第 1 轮时，第一个来自 Radiant 阵营的参议员可以使用第一项权利禁止第二个参议员的权利。
这一轮中，第二个来自 Dire 阵营的参议员会将被跳过，因为他的权利被禁止了。
这一轮中，第三个来自 Dire 阵营的参议员可以使用他的第一项权利禁止第一个参议员的权利。
因此在第二轮只剩下第三个参议员拥有投票的权利,于是他可以宣布胜利
 

提示：

n == senate.length
1 <= n <= 104
senate[i] 为 'R' 或 'D'
```

刷hot75 这道题是个贪心的好题目，我最开始想着是如果能够行使否决权，要先否决之前的敌人，这样是不对的，因为之前的敌人否决权已用过（否则当前人直接被否决了，都没法行使否决权），之前的敌人再行使否决权时一定是比后面的敌人行使否决权更晚，所以如果否决了之前的敌人，那么如果后面有敌人出现，一名同盟就会丧失权利，这样就得不偿失了。

当时也没想到用队列，直接用变量记录记录两个阵营的否决权次数，并就地删除被否决的元素，其实效率不高

```c++
class Solution {
public:
    string predictPartyVictory(string senate) {
        if (senate.size() == 1) return senate == "D" ? "Dire" : "Radiant";
        int n = senate.length();
        vector<char> party = {'R', 'D'};
        vector<int> deny_cnt(2, 0);
        vector<int> last_round_deny_cnt(2, 0);
        int index = 0;
        while (true) {
            for (int i = 0; i < party.size(); ++i) {
                if (senate[index] == party[i]) {
                    if (deny_cnt[1-i] > 0) { // 对手有否决权，当前餐议员被禁止
                        --deny_cnt[1-i];
                        senate.erase(senate.begin() + index); // 就地删除该元素，index正好指向下一个
                    } else {
                        ++deny_cnt[i];
                        ++index;
                    }
                }
            }
            if (index == senate.length()) { // 重新循环
                // 如果这一轮deny_cnt的增加正好等于长度，则说明当前只剩单一阵营了
                if (deny_cnt[0] - last_round_deny_cnt[0] == senate.length()) return "Radiant";
                if (deny_cnt[1] - last_round_deny_cnt[1] == senate.length()) return "Dire";
                last_round_deny_cnt[0] = deny_cnt[0];
                last_round_deny_cnt[1] = deny_cnt[1];
                index = 0;
            }
        }
        return "Radiant"; // never runs here
    }
};
```

还是用队列效率很高，注意队列头行使否决权后下一轮还可以继续否决敌人，所以要+n插入队尾，这个很巧妙

```c++
class Solution {
public:
    string predictPartyVictory(string senate) {
        if (senate.size() == 1) return senate == "D" ? "Dire" : "Radiant";
        int n = senate.length();
        queue<int> qr, qd; // 因为有先后顺序，所以两个队列存的是序号
        for (int i = 0; i < n; ++i) {
            if (senate[i] == 'R') qr.push(i);
            else qd.push(i);
        }
        // 贪心+模拟
        while (!qr.empty() && !qd.empty()) {
            if (qr.front() < qd.front()) {
                qd.pop(); // front就是我们要找的最近的r和d，贪心的思想，会否决后面最近的敌人
                int next = qr.front() + n;; // qr.front()已使用否决权，所以下一次轮到它使用时要更晚，统一+n
                qr.pop();
                qr.push(next);
            }
            else { // 因为存的是序号，所以不会出现相等情况
                qr.pop();
                int next = qd.front() + n;; // qd.front()已使用否决权，所以下一次轮到它使用时要更晚，统一+n
                qd.pop();
                qd.push(next);
            }
        }
        if (!qr.empty()) return "Radiant";
        return "Dire";
    }
};
```

### 763. 划分字母区间(Medium) @hot100

给你一个字符串 s 。我们要把这个字符串划分为尽可能多的片段，同一字母最多出现在一个片段中。

注意，划分结果需要满足：将所有划分结果按顺序连接，得到的字符串仍然是 s 。

返回一个表示每个字符串片段的长度的列表。

示例 1：
输入：s = "ababcbacadefegdehijhklij"
输出：[9,7,8]
解释：
划分结果为 "ababcbaca"、"defegde"、"hijhklij" 。
每个字母最多出现在一个片段中。
像 "ababcbacadefegde", "hijhklij" 这样的划分是错误的，因为划分的片段数较少。 
示例 2：

输入：s = "eccbbbbdec"
输出：[10]

提示：

1 <= s.length <= 500
s 仅由小写英文字母组成

刷hot100时直接AC了

```c++
class Solution {
public:
    vector<int> partitionLabels(string s) {
        // 贪心，从左往右，第1个元素得在片段里，然后找最后一个元素的位置，这期间遍历到的每个元素，都得去找它最后的位置
        // 直到到达这样的一个i，i的左边所有元素的最后一个位置出现在i之前，即可划分出来
        // 然后继续划分剩余子串
        unordered_map<char, int> pos; // 记录每个字符的最后一次出现位置
        for (int i = 0; i < s.size(); ++i) {
            pos[s[i]] = i; // 更新最后一次出现位置
        }
        vector<int> res;
        int begin = 0, end = 0;
        for (int i = 0; i < s.size(); ++i) {
            end = max(end, pos[s[i]]);  
            if (i == end) { // 当前片段以当前字符结束
                res.push_back(end - begin + 1);
                begin = i + 1;
            }
        }
        return res;

    }
};
```

### 1167. 连接棒材的最低费用  （哈夫曼编码）

题目描述

为了装修新房，你需要加工一些长度为正整数的棒材sticks。
如果要将长度分别为X和Y的两根棒材连接在一起，你需要支付X+Y的费用。由于施工需要，你必须将所有棒材连
接成一根。

返回你把所有棒材sticks连成一根所需要的最低费用。注意你可以任意选择棒材连接的顺序。

示例1：

输入：sticks=[2,4,3]
输出：14
解释：先将2和3连接成5，花费5；再将5和4连接成9；总花费为14。

示例2：

输入：sticks=[1,8,3,5]
输出：30
提示：

```bash
1 < sticks.length <1044
1 <= sticks[i] <=10^4
```

题意：直接贪心就好了，每次找最便宜的两根木头，注意stl的运用

```c++
//贪心+哈夫曼编码
//时间复杂度0(nlongn)空间复杂度0(n)
class Solution {
public:
    int connectsticks(vector<int>&sticks){
        multiset<int, less<int>> m; // 最小堆
        for(int n : sticks) m.insert(n);
        int ret 0;
        while (m.size() > 1){
            //取出当前最小的两个数
            int a = *m.begin();
            m.erase(m.begin());
            int b = *m.begin();
            m.erase(m.begin());
            ret += a + b;
            m.insert(a+b);
        }
        return ret;
    }
};
```

### 1431. 拥有最多糖果的孩子

给你一个数组 candies 和一个整数 extraCandies ，其中 candies[i] 代表第 i 个孩子拥有的糖果数目。

对每一个孩子，检查是否存在一种方案，将额外的 extraCandies 个糖果分配给孩子们之后，此孩子有 最多 的糖果。注意，允许有多个孩子同时拥有 最多 的糖果数目。

```
示例 1：

输入：candies = [2,3,5,1,3], extraCandies = 3
输出：[true,true,true,false,true] 
解释：
孩子 1 有 2 个糖果，如果他得到所有额外的糖果（3个），那么他总共有 5 个糖果，他将成为拥有最多糖果的孩子。
孩子 2 有 3 个糖果，如果他得到至少 2 个额外糖果，那么他将成为拥有最多糖果的孩子。
孩子 3 有 5 个糖果，他已经是拥有最多糖果的孩子。
孩子 4 有 1 个糖果，即使他得到所有额外的糖果，他也只有 4 个糖果，无法成为拥有糖果最多的孩子。
孩子 5 有 3 个糖果，如果他得到至少 2 个额外糖果，那么他将成为拥有最多糖果的孩子。
示例 2：

输入：candies = [4,2,1,1,2], extraCandies = 1
输出：[true,false,false,false,false] 
解释：只有 1 个额外糖果，所以不管额外糖果给谁，只有孩子 1 可以成为拥有糖果最多的孩子。
示例 3：

输入：candies = [12,1,12], extraCandies = 10
输出：[true,false,true]
 

提示：

2 <= candies.length <= 100
1 <= candies[i] <= 100
1 <= extraCandies <= 50
```

简单的贪心

```c++
class Solution {
public:
    vector<bool> kidsWithCandies(vector<int>& candies, int extraCandies) {
        vector<bool> ans;
        int max_candies = 0;
        for (const auto &c : candies) {
            max_candies = max(max_candies, c);
        }
        for (const auto &c : candies) {
            ans.push_back(max_candies - c <= extraCandies);
        }
        return ans;
    }
};
```

## 二分

转载自[力扣题解](https://leetcode-cn.com/problems/search-insert-position/solution/te-bie-hao-yong-de-er-fen-cha-fa-fa-mo-ban-python-/)

二分查找重点概括：

- 写成 while(left < right) ，退出循环的时候有 left == right 成立，好处是：不用判断应该返回 left 还是 right；
- 区间 [left..right] 划分只有以下两种情况：
  - 分成 [left..mid] 和 [mid + 1..right]，分别对应 right = mid 和 left = mid + 1；
  - 分成 [left..mid - 1] 和 [mid..right]，分别对应 right = mid - 1 和 left = mid，这种情况下。需要将 int mid = (left + right) / 2 改成 int mid = (left + right + 1) / 2，否则会出现死循环，这一点不用记，出现死循环的时候，把 left 和 right 的值打印出来看一下就很清楚了；
- 退出循环 left == right，如果可以确定区间 [left..right] 一定有解，直接返回 left 就可以，否则还需要对 left 这个位置单独做一次判断；
始终保持不变的是：在区间 [left..right] 里查找目标元素。

二分查找思路：

- 把待搜索的目标值留在最后判断，在循环体内不断地把不符合题目要求的子区间排除掉，在退出循环以后，因为只剩下 1 个数没有看到，它要么是目标元素，要么不是目标元素，单独判断即可。
- 这种思路也非常符合「二分」的名字，就是把「待搜索区间」分为「有目标元素的区间」和「不包含目标元素的区间」，排除掉「不包含目标元素的区间」的区间，剩下就是「有目标元素的区间」。

建议：

1、确定搜索区间初始化时候的左右边界，有时需要关注一下边界值。在初始化时，有时把搜索区间设置大一点没有关系，但是如果恰好把边界值排除在外，再怎么搜索都得不到结果。
2、无条件写上 `while (left < right)` ，表示退出循环的条件是 left == right，对于返回左右边界就不用思考了，因此此时它们的值相等；有的是`while(left <= right)`，其实是把待搜索区间“三分”，略微麻烦
3、先写**向下取整的中间数取法**，然后从如何把 mid 排除掉的角度思考 if 和 else 语句应该怎样写。记住：**在 if else 语句里面只要出现 left = mid 的时候，把取中间数行为改成上取整即可**。
4、根据 if else 里面写的情况，看看是否需要修改中间数下取整的行为。向下：`int mid = l + (r - l) / 2;`，向上：`int mid = l + (r - l + 1) / 2;`
5、退出循环的时候，一定有 left == right 成立。有些时候可以直接返回 left （或者 right，由于它们相等，后面都省略括弧）或者与 left 相关的数值，有些时候还须要再做一次判断，判断 left 与 right 是否是我们需要查找的元素，这一步叫“后处理”。

[整数二分算法模板 —— 模板](https://www.acwing.com/blog/content/277/)

```c++
bool check(int x) {/* ... */} // 检查x是否满足某种性质

// 区间[l, r]被划分成[l, mid]和[mid + 1, r]时使用：
int bsearch_1(int l, int r)
{
    while (l < r)
    {
        int mid = l + r >> 1;
        if (check(mid)) r = mid;    // check()判断mid是否满足性质
        else l = mid + 1;
    }
    return l;
}
// 区间[l, r]被划分成[l, mid - 1]和[mid, r]时使用：
int bsearch_2(int l, int r)
{
    while (l < r)
    {
        int mid = l + r + 1 >> 1;
        if (check(mid)) l = mid;
        else r = mid - 1;
    }
    return l;
}
```

### 4. 寻找两个有序数组的中位数(hard) @hot100

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

刷hot100，暂时只能想到借用一个数组存下来

时间
16 ms
击败
97.6%
内存
87.5 MB
击败
21.63%

```c++
class Solution {
public:
    double findMedianSortedArrays(vector<int>& nums1, vector<int>& nums2) {
        int m = nums1.size();
        int n = nums2.size();
        vector<int> nums(m + n);
        for (int i = 0, j = 0, k = 0; k < m + n; ++k) {
            if (j == n) {
                nums[k] = nums1[i++];
            } else if (i == m) {
                nums[k] = nums2[j++];
            } else if (nums1[i] < nums2[j]) {
                nums[k] = nums1[i++];
            } else {
                nums[k] = nums2[j++];
            }
        }
        int mid = (m + n) / 2;
        if ((m + n) % 2 == 0) {
            return (double) (nums[mid] + nums[mid-1]) / 2;
        }
        return nums[mid];
    }
};
```

实际上，不用专门申请辅助数组，因为长度已知，只需要用一个从零开始的指针，走到(m+n)/2的中点即可，这里注意奇偶的情况

但此时还达不到O(logn)的时间复杂度，只能用二分查找，找中位数，其实就是找第k大的数。我们一次遍历就相当于去掉不可能是中位数的一个值，也就是一个一个排除。由于数列是有序的，其实我们完全可以一半儿一半儿的排除。假设我们要找第 k 小数，我们可以每次循环排除掉 k/2 个数。

1. 假设有， A[1] ，A[2] ，A[3]，A[k/2] ... ，B[1]，B[2]，B[3]，B[k/2] ... ，如果 `A[k/2]<B[k/2]` ，那么A[1]，A[2]，A[3]，A[k/2]都不可能是第 k 小的数字。更特别的情况，假设B[1]...B[k/2-1]都比A[k/2]小，因为A[k/2]只大于A[1]..A[k/2-1]以及B[1]..B[k/2-1]，这里一共是k-2个，所以A[k/2]最大也就是第k-1大的元素。
2. 于是，排除掉了A[1]..A[k/2]，这些元素都不可能是第k大元素，排除掉后，A数组减少k/2个元素，下一步是寻找第(k-k/2)个元素，比较的是B[1]..B[(k-k/2)/2]与A[k/2+1]..A[k/2+(k-k/2)/2]
3. 重复上面的步骤，AorB数组会减少掉k/4个元素，下一步就是寻找第(k-k/2-k/4)大的元素
4. 重复上面步骤，直到寻找第1大的元素，此时
5. 有可能出现k/2（或者后面的k/4,k/8...）大于数组剩余长度，此时只需要把原先指向k/2的指针指向数组末尾即可

时间复杂度O(log(m+n))，每次循环都会排除k/2个数，空间复杂度O(1)

```c++
class Solution {
public:
    int getKthElement(const vector<int>& nums1, const vector<int>& nums2, int k) {
        /* 主要思路：要找到第 k (k>1) 小的元素，那么就取 pivot1 = nums1[k/2-1] 和 pivot2 = nums2[k/2-1] 进行比较
         * 这里的 "/" 表示整除
         * nums1 中小于等于 pivot1 的元素有 nums1[0 .. k/2-2] 共计 k/2-1 个
         * nums2 中小于等于 pivot2 的元素有 nums2[0 .. k/2-2] 共计 k/2-1 个
         * 取 pivot = min(pivot1, pivot2)，两个数组中小于等于 pivot 的元素共计不会超过 (k/2-1) + (k/2-1) <= k-2 个
         * 这样 pivot 本身最大也只能是第 k-1 小的元素
         * 如果 pivot = pivot1，那么 nums1[0 .. k/2-1] 都不可能是第 k 小的元素。把这些元素全部 "删除"，剩下的作为新的 nums1 数组
         * 如果 pivot = pivot2，那么 nums2[0 .. k/2-1] 都不可能是第 k 小的元素。把这些元素全部 "删除"，剩下的作为新的 nums2 数组
         * 由于我们 "删除" 了一些元素（这些元素都比第 k 小的元素要小），因此需要修改 k 的值，减去删除的数的个数
         */

        int m = nums1.size();
        int n = nums2.size();
        int index1 = 0, index2 = 0;
        while (true) {
            // 边界情况
            if (index1 == m) {
                return nums2[index2 + k - 1]; // 此时只需要找nums2剩余数组的第k大的数，比如第1大的数，就是剩余数组的头元素，故下标=1
            }
            if (index2 == n) {
                return nums1[index1 + k - 1];
            }
            if (k == 1) {
                return min(nums1[index1], nums2[index2]);
            }

            // 正常情况
            int newIndex1 = min(index1 + k / 2 - 1, m - 1); // 不能超出数组
            int newIndex2 = min(index2 + k / 2 - 1, n - 1); // 不能超出数组
            int pivot1 = nums1[newIndex1];
            int pivot2 = nums2[newIndex2];
            if (pivot1 <= pivot2) {
                k -= newIndex1 - index1 + 1; // 比如数组1,2,3,4，index1=0，newIndex1=2，此时会把1、2、3都删除，所以第k大变成第k-(newIndex1-index1+1)大
                index1 = newIndex1 + 1;
            }
            else {
                k -= newIndex2 - index2 + 1;
                index2 = newIndex2 + 1;
            }
        }
    }

    double findMedianSortedArrays(vector<int>& nums1, vector<int>& nums2) {
        int totalLength = nums1.size() + nums2.size();
        if (totalLength % 2 == 1) { 
            return getKthElement(nums1, nums2, (totalLength + 1) / 2); // 比如1,2,3,4,5，k为第3大
        }
        else {
            return (getKthElement(nums1, nums2, totalLength / 2) + getKthElement(nums1, nums2, totalLength / 2 + 1)) / 2.0; // 比如1,2,3,4,5,6，k为第3大和第4大的平均值
        }
        // 也可以去掉if-else语句，将奇偶情况合并
        // return (getKthElement(nums1, nums2, (totalLength + 1) / 2) + getKthElement(nums1, nums2, (totalLength  + 2)/ 2)) / 2.0; // 将奇偶的情况合并，如果是奇数，会求两次
    }
};
```

看题解还有更快的，时间复杂度只需要O(log(min(m,n)))

一个长度为 m 的数组，有 0 到 m 总共 m + 1 个位置可以切。我们把数组 A 和数组 B 分别在 i 和 j 进行切割。将 i 的左边和 j 的左边组合成「左半部分」，将 i 的右边和 j 的右边组合成「右半部分」。

当 A 数组和 B 数组的总长度是偶数时，如果我们能够保证

- 左半部分的长度等于右半部分
  - i + j = m - i  + n - j  , 也就是 j = ( m + n ) / 2 - i
- 左半部分最大的值小于等于右半部分最小的值
  - max ( A [ i - 1 ] , B [ j - 1 ]）） <= min ( A [ i ] , B [ j ]））
- 那么，中位数就可以表示如下
  - （左半部分最大值 + 右半部分最小值 ）/ 2：（max ( A [ i - 1 ] , B [  j  - 1 ]）+ min ( A [ i ] , B [ j ]）） /  2

当 A 数组和 B 数组的总长度是奇数时，如果我们能够保证

- 左半部分的长度比右半部分大 1
  - i + j = m - i  + n - j  + 1也就是 j = ( m + n + 1) / 2 - i
- 左半部分最大的值小于等于右半部分最小的值
  - max ( A [ i - 1 ] , B [ j - 1 ]）） <= min ( A [ i ] , B [ j ]））
- 那么，中位数就是
  - 左半部分最大值，也就是左半部比右半部分多出的那一个数：max ( A [ i - 1 ] , B [  j - 1 ]）

上边的第一个条件我们其实可以合并为 j = (m+n+1)/2-i，因为如果m+n是偶数，(m+n)/2 == (m+n+1)/2，int向下取整

上边的第二个条件是一样的，因为`A[i-1]<A[i] && B[i-1]<B[i]`，所以只需要保证B [ j - 1 ] < = A [ i ] 和 A [ i - 1 ] <= B [ j ]，所以我们分两种情况讨论：

1. B [ j - 1 ] > A [ i ]，并且为了不越界，要保证 j != 0，i != m，很明显，此时需要增加i，幸运的是 j = ( m + n + 1) / 2 - i，i的增大，j会随之减少
2. A [ i - 1 ] > B [ j ]，并且为了不越界，要保证 i != 0，j != n，和上面反过来，减少i，j会随之增大
3. 边界情况：当 i = 0, 或者 j = 0，也就是切在了最前边。此时左半部分当 j = 0 时，最大的值就是 A [ i - 1 ] ；当 i = 0 时 最大的值就是 B [ j - 1] 。右半部分最小值和之前一样。
4. 边界情况：当 i = m 或者 j = n，也就是切在了最后边。此时左半部分最大值和之前一样。右半部分当 j = n 时，最小值就是 A [ i ] ；当 i = m 时，最小值就是B [ j ] 。

ok，以上就是所有思路了，可以看到我们是通过不断地寻找i的切点，j会随之变化，从而寻找最后的解，因为原始数组有序，所以i的切点可以用二分来查找

时间
16 ms
击败
97.6%
内存
87.2 MB
击败
42%

```c++
class Solution {
public:
    double findMedianSortedArrays(vector<int>& nums1, vector<int>& nums2) {
        if (nums1.size() > nums2.size()) {
            return findMedianSortedArrays(nums2, nums1); // 确保nums1是更少的数组
        }
        int m = nums1.size();
        int n = nums2.size();
        int left = 0, right = m;
        while (left <= right) {
            // 前一部分包含 nums1[0 .. i-1] 和 nums2[0 .. j-1]
            // 后一部分包含 nums1[i .. m-1] 和 nums2[j .. n-1]
            int i = (left + right) / 2; // i也代表了二分钟mid的含义
            int j = (m + n + 1) / 2 - i; // 条件一，j随i变化
            if (j != 0 && i != m && nums2[j-1] > nums1[i]){ // i 需要增大
                left = i + 1; 
            } else if (i != 0 && j != n && nums1[i-1] > nums2[j]) { // i 需要减小
                right = i - 1; 
            } else { // 达到要求，并且将边界条件列出来单独考虑
                int maxLeft = 0;
                if (i == 0) { maxLeft = nums2[j-1]; }
                else if (j == 0) { maxLeft = nums1[i-1]; }
                else { maxLeft = max(nums1[i-1], nums2[j-1]); }
                if ( (m + n) % 2 == 1 ) { return maxLeft; } // 奇数的话不需要考虑右半部分

                int minRight = 0;
                if (i == m) { minRight = nums2[j]; }
                else if (j == n) { minRight = nums1[i]; }
                else { minRight = min(nums2[j], nums1[i]); }

                return (maxLeft + minRight) / 2.0; //如果是偶数的话返回结果
            }
        }
        return 0.0; // never runs here
    }
};
```

官方题解用了一个证明，感觉比较麻烦，找到最大的i，使得A[i-1]<=B[j]成立，这样的i，也能使得B[j-1]<=A[i]，证明：i+1不满足，代入，即A[i]<=B[j]不成立，即A[i]>B[j]>=B[j-1]，故`B[j-1]<A[i]`，条件甚至更强。

既然是找最大的i，那么就在满足A[i-1]<=B[j]时继续收缩左边，直到循环退出

```c++
class Solution {
public:
    double findMedianSortedArrays(vector<int>& nums1, vector<int>& nums2) {
        if (nums1.size() > nums2.size()) {
            return findMedianSortedArrays(nums2, nums1);
        }
        
        int m = nums1.size();
        int n = nums2.size();
        int left = 0, right = m;
        // median1：前一部分的最大值
        // median2：后一部分的最小值
        int median1 = 0, median2 = 0;

        while (left <= right) {
            // 前一部分包含 nums1[0 .. i-1] 和 nums2[0 .. j-1]
            // 后一部分包含 nums1[i .. m-1] 和 nums2[j .. n-1]
            int i = (left + right) / 2;
            int j = (m + n + 1) / 2 - i;

            // nums_im1, nums_i, nums_jm1, nums_j 分别表示 nums1[i-1], nums1[i], nums2[j-1], nums2[j]
            int nums_im1 = (i == 0 ? INT_MIN : nums1[i - 1]);
            int nums_i = (i == m ? INT_MAX : nums1[i]);
            int nums_jm1 = (j == 0 ? INT_MIN : nums2[j - 1]);
            int nums_j = (j == n ? INT_MAX : nums2[j]);

            if (nums_im1 <= nums_j) {
                median1 = max(nums_im1, nums_jm1);
                median2 = min(nums_i, nums_j);
                left = i + 1;
            } else {
                right = i - 1;
            }
        }

        return (m + n) % 2 == 0 ? (median1 + median2) / 2.0 : median1;
    }
};
```

### 33.搜索旋转排序数组(medium, based on 153) @hot100

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
            int mid = l + (r - l) / 2; // 中间数向下取整
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

刷hot100，啪一下很快啊

时间
0 ms
击败
100%
内存
10.8 MB
击败
24.41%

```c++
class Solution {
public:
    int search(vector<int>& nums, int target) {
        if (nums.empty()) return -1;
        int n = nums.size();
        int mid = 0, l = 0, r = n - 1;
        while (l < r) { // 寻找最小值（旋转前的头元素）
            mid = l + (r - l) / 2; // 因为左边收缩包括了mid，所以可以向下取整，不会死循环
            if (nums[mid] > nums[r]) { // 最小值肯定在(mid, r]中，所以可以放心收缩[l, mid]
                l = mid + 1;
            } else {
                r = mid;
            }
        }
        // 此时nums[l]即为最小值
        // int append = l; // 右边接上append个元素，旋转回去，此时[l, l + n - 1]为有序数组
        r = l + n - 1;
        while (l < r) {
            mid = l + (r - l) / 2;
            int offset = mid % n;
            if (nums[offset] < target) {
                l = mid + 1;
            } else {
                r = mid;
            }
        }
        if (nums[l % n] == target) {
            return l % n;
        }
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

### 34. 在排序数组中查找元素的第一个和最后一个位置(medium) @hot100

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

看了AcWing上的解答，其实在if-else中不需要第三个分支，只需要注意往左还是往右搜索即可，推荐这种解法

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

刷hot100，用了三次循环，第一次找是否存在target，第二次找target的lower_bound，第三次找target的upper_bound

```c++
class Solution {
public:
    vector<int> searchRange(vector<int>& nums, int target) {
        if (nums.empty()) return {-1, -1};
        int n = nums.size();
        if (nums[0] > target || nums[n-1] < target) return {-1, -1};
        int mid = 0, l = 0, r = n - 1;
        while (l <= r) {
            mid = l + (r - l) / 2;
            if (nums[mid] < target) {
                l = mid + 1;
            } else if (nums[mid] > target){
                r = mid - 1;
            } else {
                break;
            }
        }
        if (nums[mid] != target ) return {-1, -1}; // 找不到target，直接返回
        vector<int> res;
        l = 0, r = mid;
        while (l < r) {
            mid = l + (r - l) / 2;
            if (nums[mid] < target) {
                l = mid + 1;
            } else if (nums[mid] > target || (mid > 0 && nums[mid-1] == target)){
                r = mid - 1;
            } else {
                res.push_back(mid);
                break;
            }
        }
        if (res.empty()) res.push_back(l);
        l = mid, r = n - 1;
        while (l < r) {
            mid = l + (r - l) / 2;
            if (nums[mid] > target) {
                r = mid - 1;
            } else if (nums[mid] < target || (mid < n - 1 && nums[mid+1] == target)){
                l = mid + 1;
            } else {
                res.push_back(mid);
                break;
            }
        }
        if (res.size() != 2) res.push_back(l);
        return res;
    }
};
```

### 35. 搜索插入位置(easy) @hot100

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

刷hot100，这种写法貌似更容易理解，甚至不用判断nums[0]与nums[n-1]，不过得仔细判断，有些题解是不会输出待插入位置的

```c++
class Solution {
public:
    int searchInsert(vector<int>& nums, int target) {
        int l = 0;
        int r = nums.size() - 1;
        while (l <= r) {
            int mid = l + (r - l) / 2;
            if (nums[mid] == target) {
                return mid;
            } else if (nums[mid] > target) {
                r = mid - 1;
            } else {
                l = mid + 1;
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

牛顿法

```c++
class Solution {
public:
    int mySqrt(int x) {
        if (x < 1) return 0;
        if (x >= 1 && x < 4) return 1;
        double tmp = (double)x;
        int l = x;
        int r = x;
        while (!(x / l >= l && x / r <= r)) {
            tmp = 0.5 * (tmp + x /tmp);
            l = (int)floor(tmp);
            r = (int)ceil(tmp);
            cout << l << " " << tmp << " " << r << endl;
        }
        return l;
    }
};
```

### 74. 搜索二维矩阵(easy) @hot100

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
        int l = 0, r = rows * cols - 1; // 直接将二维矩阵打平（flaten）
        while(l < r){
            mid = l + (r - l) / 2; // 因为左边收缩时把mid也收缩了，所以mid可以向下取整
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

刷hot100，用了两个循环，注意搜索行时，边界的收缩情况要小心

时间
0 ms
击败
100%
内存
9.2 MB
击败
56.14%

```c++
class Solution {
public:
    bool searchMatrix(vector<vector<int>>& matrix, int target) {
        int m = matrix.size();
        if (m == 0) return false;
        int n = matrix[0].size();
        if (n == 0) return false;
        if (matrix[0][0] > target || matrix[m-1][n-1] < target) return false;
        int l = 0, r = m - 1;
        while (l < r) {
            int mid = l + (r - l) / 2 + 1; // 因为边界收缩时l=mid，为防止死循环，mid向上取整
            if (matrix[mid][0] == target) return true;
            else if (matrix[mid][0] > target) r = mid - 1; // 当前行首元素大于target，则可以把当前行以及之后行都排除掉
            else l = mid; // 当前行首元素小于target，则可以把之前行都排除掉
        }
        if (matrix[l][0] == target) return true;
        int row = l;
        l = 0, r = n - 1;
        while (l < r) {
            int mid = l + (r - l) / 2;
            if (matrix[row][mid] < target) {
                l = mid + 1;
            } else {
                r = mid;
            }
        }
        if (matrix[row][l] == target) {
            return true;
        }
        return false;
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

### 153. 寻找旋转排序数组中的最小值(medium) @hot100

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

比33.搜索旋转排序数组还简单，是33题的子问题

时间
0 ms
击败
100%
内存
9.8 MB
击败
79.58%

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

### 287. 寻找重复数(medium) @hot100

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

**算法1：二分查找，时间复杂度O(nlogn)**

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

**算法2：循环检测，时间复杂度O(n)**

[快慢指针的解释](https://leetcode-cn.com/problems/find-the-duplicate-number/solution/kuai-man-zhi-zhen-de-jie-shi-cong-damien_undoxie-d/)

有点类似于判断环的入口节点，这篇题解解释得很清楚了

我们对 nums 数组建图，每个位置 连一条 i→nums[i] 的边。由于存在的重复的数字 target，因此 target 这个位置一定有起码两条指向它的边，因此整张图一定存在环，且我们要找到的 target 就是这个环的入口，那么整个问题就等价于 142. 环形链表 II。

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
            if(slow == fast) break; // 找到快慢指针的相遇点
        }
        int finder = slow;
        slow = 0; // 第三个指针从起点开始
        while(true){
            slow = nums[slow];
            finder = nums[finder];
            if(slow == finder) break; // 这时相遇点就是环的入口
        }
        return slow;
    }
};
```

算法3：位运算（很难想到）

简单来说，把数字转为二进制，那么其实只需要关注1的个数及位数。具体到第i位，我们统计nums数组中二进制展开后第i位为1的数为x个，数字[1,n]这nnn个数二进制展开后第i位为1的数有y个，那么很显然只有x>y的情况下，重复的数的第i位为1。

分别把[1,n]和数组数字的所有位为1统计出来，然后按位还原，即可得到这个重复的数。

```c++
class Solution {
public:
    int findDuplicate(vector<int>& nums) {
        int n = nums.size(), ans = 0;
        int bit_max = 31; // 确定二进制下最高位是多少
        while (!((n - 1) >> bit_max)) {
            bit_max -= 1;
        }
        for (int bit = 0; bit <= bit_max; ++bit) {
            int x = 0, y = 0;
            for (int i = 0; i < n; ++i) {
                if (nums[i] & (1 << bit)) {
                    x += 1;
                }
                if (i >= 1 && (i & (1 << bit))) {
                    y += 1;
                }
            }
            if (x > y) {
                ans |= 1 << bit; // 组装ans的第bit位
            }
        }
        return ans;
    }
};
```

刷hot100时，想到了另一种做法，看注释，但是这题不满足题意，因为会修改数组！

```c++
class Solution {
public:
    int findDuplicate(vector<int>& nums) {
        // 从左往右遍历，到第i位时，将nums[i]与nums[nums[i]]调换，直到nums[i] = i
        // 如果在后面的遍历中，发现nums[i] < i，说明当前元素已经在前面正确的放置过1次了，所以是重复的
        for (int i = 1; i <= nums.size(); ++i) {
            if (nums[i-1] < i ) return nums[i-1];
            while (nums[i-1] != i) { // 有可能会出现死循环，比如[3,1,3,4,2]，3与3无限调换
                if (nums[i-1] == nums[nums[i-1]-1]) return nums[i-1]; // 破解死循环，直接if输出解
                swap(nums[i-1], nums[nums[i-1]-1]);
            }
        }
        return 0; // never runs here
    }
};
```

### 367. 有效的完全平方数

给定一个正整数 num，编写一个函数，如果 num 是一个完全平方数，则返回 True，否则返回 False。

说明：不要使用任何内置的库函数，如  sqrt。

最快的是用一个公式：1+3+5+7+ ... + (2n-1) = n^2

```c++
class Solution
{
public:
    bool isPerfectSquare(int num) {
        int num1 = 1;
        while(num > 0) {
            num -= num1;
            num1 += 2;
        }
        return num == 0;
    }
};
```

也可以用二分法或牛顿法不断减小平方根的范围，最后判断离平方根最近的整数，其平方是否等于num来判断num是否是完全平方数

```c++
class Solution {
public:
    bool isPerfectSquare(int num) {
        if (num <= 1) return true;
        int l = 1, h = num / 2;
        while (l < h) {
            int mid = l + (h - l >> 1);
            if (mid >= num / mid) { // mid * mid >= num
                h = mid;
            } else {
                l = mid + 1;
            }
        }
        return (long)l * l == num;
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

### 875. 爱吃香蕉的珂珂

珂珂喜欢吃香蕉。这里有 n 堆香蕉，第 i 堆中有 piles[i] 根香蕉。警卫已经离开了，将在 h 小时后回来。

珂珂可以决定她吃香蕉的速度 k （单位：根/小时）。每个小时，她将会选择一堆香蕉，从中吃掉 k 根。如果这堆香蕉少于 k 根，她将吃掉这堆的所有香蕉，然后这一小时内不会再吃更多的香蕉。  

珂珂喜欢慢慢吃，但仍然想在警卫回来前吃掉所有的香蕉。

返回她可以在 h 小时内吃掉所有香蕉的最小速度 k（k 为整数）。

```
示例 1：

输入：piles = [3,6,7,11], h = 8
输出：4
示例 2：

输入：piles = [30,11,23,4,20], h = 5
输出：30
示例 3：

输入：piles = [30,11,23,4,20], h = 6
输出：23
 

提示：

1 <= piles.length <= 104
piles.length <= h <= 109
1 <= piles[i] <= 109
```

思路见注释

```c++
class Solution {
public:
    bool isSpeedEnough(vector<int>& piles, long long k, int h) {
        int hour = 0;
        for (int pile : piles) {
            if(pile % k == 0) hour += pile / k;
            else hour += pile / k + 1;
        }
        return hour <= h;
    }
    int minEatingSpeed(vector<int>& piles, int h) {
        int n = piles.size();
        // 提示可知n<=h，先对香蕉堆排序
        // 如果h非常大，那么珂珂每小时啃一根就行了，这是最小值
        // 假设n==h，则珂珂必须每个小时就要搞定一堆香蕉，h个小时搞定n个香蕉堆所以其速度至少得是max(piles[i])
        // 假设n==h-1，则其速度至少是max(piles[i])的一半，但是又必须在n-1个小时内搞定前n-1个香蕉堆，所以速度至少是max(max(piles[i])/2, second_max(piles[i]))
        // 这样无法找到规律，尝试枚举
        ranges::sort(piles);
        if (n == h) return piles[n-1];
        long long low = 1, high = piles[n-1];
        while (low < high) {
            cout << low << ", " << high << endl;
            long long mid = (long long)low + (high - low) / 2;
            if (isSpeedEnough(piles, mid, h)) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return low;
    }
};
```

### 2300. 咒语和药水的成功对数

medium

给你两个正整数数组 spells 和 potions ，长度分别为 n 和 m ，其中 spells[i] 表示第 i 个咒语的能量强度，potions[j] 表示第 j 瓶药水的能量强度。

同时给你一个整数 success 。一个咒语和药水的能量强度 相乘 如果 大于等于 success ，那么它们视为一对 成功 的组合。

请你返回一个长度为 n 的整数数组 pairs，其中 pairs[i] 是能跟第 i 个咒语成功组合的 药水 数目。

```
示例 1：

输入：spells = [5,1,3], potions = [1,2,3,4,5], success = 7
输出：[4,0,3]
解释：
- 第 0 个咒语：5 * [1,2,3,4,5] = [5,10,15,20,25] 。总共 4 个成功组合。
- 第 1 个咒语：1 * [1,2,3,4,5] = [1,2,3,4,5] 。总共 0 个成功组合。
- 第 2 个咒语：3 * [1,2,3,4,5] = [3,6,9,12,15] 。总共 3 个成功组合。
所以返回 [4,0,3] 。
示例 2：

输入：spells = [3,1,2], potions = [8,5,8], success = 16
输出：[2,0,2]
解释：
- 第 0 个咒语：3 * [8,5,8] = [24,15,24] 。总共 2 个成功组合。
- 第 1 个咒语：1 * [8,5,8] = [8,5,8] 。总共 0 个成功组合。
- 第 2 个咒语：2 * [8,5,8] = [16,10,16] 。总共 2 个成功组合。
所以返回 [2,0,2] 。
 

提示：

n == spells.length
m == potions.length
1 <= n, m <= 105
1 <= spells[i], potions[i] <= 105
1 <= success <= 1010
```
因为只需要知道数量，所以可以先对potions排序，然后遍历spells，对于其中每个咒语在potions二分查找，找到第一个乘积大于等于success的即可

```c++
class Solution {
public:
    vector<int> successfulPairs(vector<int>& spells, vector<int>& potions, long long success) {
        int n = spells.size();
        int m = potions.size();
        vector<int> pairs(n, 0);
        ranges::sort(potions);
        for (int i = 0; i < n; ++i) {
            if ((long long)spells[i] * potions[0] >= success) {
                pairs[i] = m;
                continue;
            } else if ((long long)spells[i] * potions[m-1] < success) {
                pairs[i] = 0;
                continue;
            }
            // 目的是找到第一个大于等于success的序号
            int low = 0, high = m-1;
            while (low < high) {
                int mid = low + (high - low) / 2;
                // cout << "i=" << i << ", mid=" << mid << endl;
                if ((long long)spells[i]*potions[mid] < success) {
                    low = mid + 1;
                } else {
                    high = mid; // 有可能mid是最终答案，所以不能收缩mid
                }
            }
            pairs[i] = m - low;
        }
        return pairs;
    }
};
```

## 栈

单调栈的理解：https://leetcode.cn/problems/largest-rectangle-in-histogram/solutions/142012/bao-li-jie-fa-zhan-by-liweiwei1419/

单调栈有时加前置哨兵和后置哨兵

- 头部的0是为了不用判断栈是否为空, 因为题目中都是非负整数, 所以没有数会比0小, 即0一直会在栈底，同时也是为了记住left的值
- 尾部的0是为了压出最后已经形成的单调栈的, 比如说示例: 2,1,5,6,2,3遍历完之后单调栈[1,2,3],然后如果没有尾部0, 我们就会像weiwei哥第一段代码那样子, 最后考虑单调栈是否为空,做一个额外的判断,写很多类似的逻辑代码, 加入了尾部0, 就可以把遍历完单调栈[1,2,3]给压出来.

### 20. 有效的括号(easy) @hot100

给定一个只包括 '('，')'，'{'，'}'，'['，']' 的字符串，判断字符串是否有效。

有效字符串需满足：

左括号必须用相同类型的右括号闭合。
左括号必须以正确的顺序闭合。
注意空字符串可被认为是有效字符串。

示例 1:

输入: "()"
输出: true
示例 2:

输入: "()[]{}"
输出: true
示例 3:

输入: "(]"
输出: false
示例 4:

输入: "([)]"
输出: false
示例 5:

输入: "{[]}"
输出: true

```c++
class Solution {
public:
    bool isValid(string s) {
        if (s.empty()) return true;
        stack<char> st;
        if (!isLeftQuote(s[0])) {
            return false;
        }
        st.push(s[0]);
        for (int i = 1; i < s.size(); ++i) {
            if (isLeftQuote(s[i])) st.push(s[i]);
            else if (!st.empty() && isMatch(st.top(), s[i])) st.pop();
            else return false;
        }
        if (!st.empty()) return false;
        return true;
    }
    bool isLeftQuote(char ch) {
        if (ch == '(' || ch == '[' || ch == '{') {
            return true;
        } else {
            return false;
        }
    }
    bool isMatch(char ch1, char ch2) {
        if (ch1 == '[' && ch2 == ']') return true;
        if (ch1 == '{' && ch2 == '}') return true;
        if (ch1 == '(' && ch2 == ')') return true;
        return false;
    }
};
```

刷hot100，直接A了

```c++
class Solution {
public:
    bool isValid(string s) {
        if (s.empty()) return true;
        stack<char> st;
        for (int i = 0; i < s.size(); ++i) {
            if (s[i] == '(' || s[i] == '[' || s[i] == '{') {
                st.push(s[i]);
            } else if (s[i] == ')') {
                if (st.empty() || st.top() != '(') {
                    return false;
                }
                st.pop();
            } else if (s[i] == ']') {
                if (st.empty() || st.top() != '[') {
                    return false;
                }
                st.pop();
            } else if (s[i] == '}') {
                if (st.empty() || st.top() != '{') {
                    return false;
                }
                st.pop();
            }
        }
        return st.empty();
    }
};
```

还有个优化，在最开始判断长度，如果为奇数，肯定不是有效的，直接返回false

```c++
        if (n % 2 == 1) {
            return false;
        }
```

### 42. 接雨水(Hard) @hot100

已有题解

### 84. 柱状图中最大的矩形(Hard) @hot100

给定 n 个非负整数，用来表示柱状图中各个柱子的高度。每个柱子彼此相邻，且宽度为 1 。

求在该柱状图中，能够勾勒出来的矩形的最大面积。

以上是柱状图的示例，其中每个柱子的宽度为 1，给定的高度为 [2,1,5,6,2,3]。

图中阴影部分为所能勾勒出的最大矩形面积，其面积为 10 个单位。

示例:

输入: [2,1,5,6,2,3]
输出: 10

无论枚举柱子的高度还是宽度，暴力都会超时

[单调栈解法](https://leetcode-cn.com/problems/largest-rectangle-in-histogram/solution/84-by-ikaruga/)

单调栈分为单调递增栈和单调递减栈

1. 单调递增栈即栈内元素保持单调递增的栈
1. 同理单调递减栈即栈内元素保持单调递减的栈

操作规则（下面都以单调递增栈为例）

1. 如果新的元素比栈顶元素大，就入栈
2. 如果新的元素较小，那就一直把栈内元素弹出来，直到栈顶比新元素小

加入这样一个规则之后，会有什么效果

1. 栈内的元素是递增的
2. 当元素出栈时，说明这个新元素是出栈元素向后找第一个比其小的元素
    > 举个例子，[2,1,5,6,2,3]，现在索引在 6 ，栈里是 1 5 6 。接下来新元素是 2 ，那么 6 需要出栈。当 6 出栈时，右边 2 代表是 6 右边第一个比 6 小的元素。
3. 当元素出栈后，说明新栈顶元素是出栈元素向前找第一个比其小的元素。
    > 当 6 出栈时，5 成为新的栈顶，那么 5 就是 6 左边第一个比 6 小的元素。

单调递增栈的模板代码：

```c++
stack<int> st;
for(int i = 0; i < nums.size(); i++)
{
    while (!st.empty() && st.top() > nums[i]) {
        st.pop();
    }
    st.push(nums[i]);
}
```

**为什么这题要用单调栈？**

因为遍历高度与宽度的时间复杂度是O(n^2)，所以选择遍历每个高度，是要以当前高度为基准，寻找最大的宽度 组成最大的矩形面积那就是要找左边第一个小于当前高度的下标left，再找右边第一个小于当前高度的下标right 那宽度就是这两个下标之间的距离了 但是要排除这两个下标 所以是right-left-1 用单调栈就可以很方便确定这两个边界了

思路

1. 对于一个高度，如果能得到向左和向右的边界
2. 那么就能对每个高度求一次面积
3. 遍历所有高度，即可得出最大面积
4. 使用单调栈，在出栈操作时，计算出栈元素的前后边界并计算面积

为了简便，在前后都插入了0，这是哨兵，以为我们要找每个柱子的左右边界，如果不加哨兵，第一个柱子不好计算左边界，最后一个柱子不好计算右边界，

- 因为没有在heights前加0，不能保证stack不为空，所以left的值就需要赋初始值0
- 在最后加0可以保证矩形高度都是递增的特殊情况下ans也能进行计算

因为函数入参是引用，为了不修改原数组，新建了vec

每一个位置只会入栈一次（在枚举到它时），并且最多出栈一次。因此当我们从左向右/总右向左遍历数组时，对栈的操作的次数就为O(n)，所以总的时间复杂度就为O(n)

```c++
class Solution {
public:
    int largestRectangleArea(vector<int>& heights) {
        stack<int> st;
        vector<int> vec(heights.begin(), heights.end());
        vec.insert(vec.begin(), 0);
        vec.push_back(0);
        int ans = 0;
        for (int i = 0; i < vec.size(); ++i) {
            while (!st.empty() && vec[st.top()] > vec[i]) { // 此时栈顶元素需要出栈，开始计算以它为高的矩形最大面积
                int cur = st.top();
                st.pop();
                int left = st.top() + 1; // 查找左边界：st.top()是第一个比cur低的柱子，[left, cur-1]这部分的柱子肯定比cur高，因为是单调栈，如果其中的柱子比cur低，肯定在栈顶！所以cur的左边界（含）是st.top()+1
                int right = i - 1; // 查找右边界：i是第一个比cur低的柱子，所以cur的右边界（含）是i-1
                ans = max(ans, (right - left + 1) * vec[cur]); // 左右边界是闭区间，所以宽度+1
            }
            st.push(i);
        }
        return ans;
    }
};
```

刷hot100时，想着用双指针，首先求出`dp[i][j]`，它表示i到j的最小高度，然后双指针依次变化，但是这种解法会把最优解给跳过，比如[4,2,0,3,2,4,3,4]最后输出4，实际是10，比如[4,2,1,3,2,4,3,4]，最后输出8，实际是10，这题与接雨水还不太一样，每次移动指针，并不能保证最优解不在这里面

```c++
class Solution {
public:
    int largestRectangleArea(vector<int>& heights) {
        // 第i个柱子到第j个柱子形成的矩形面积 S[i,j] = (j-i+1) * min{ i<=x<=j | height[x]}
        // 最后答案 res = max{ 0<=i<=j<=n-1 | S[i,j]}
        int n = heights.size();
        if (n == 1) return heights[0];
        vector<int> mono_incs(n, 0); // 升序，里面的元素是原heights升序后的下标
        for (int i = 1; i < n; ++i) {
            mono_incs[i] = i;
        }
        auto myComp = [&heights](int index1, int index2) {
            return heights[index1] < heights[index2];
        };
        sort(mono_incs.begin(), mono_incs.end(), myComp);
        // dp[i][j]的意义是从下标i到j的最低的柱子的下标
        vector<vector<int>> dp (n, vector<int>(n, 0));
        for (int i = 0; i < n; ++i) {
            for (int j = i; j < n; ++j) {
                for (int k = 0; k < n; ++k) { // mono升序，所以从0开始，找到第一个符合要求的，即为这段区间最低柱子
                    if (i <= mono_incs[k] && mono_incs[k] <= j) {
                        dp[i][j] = mono_incs[k];
                        break;
                    }
                }
            }
        }
        int l = 0, r = n - 1;
        int res = 0;
        while (l <= r) {
            int s = (r - l + 1) * heights[dp[l][r]];
            res = max(res, s);
            if (heights[l] < heights[r]) {
                ++l;
            } else {
                --r;
            }
        }
        return res;
    }
};
```

### 155. 最小栈 (Medium) @hot100

设计一个支持 push ，pop ，top 操作，并能在常数时间内检索到最小元素的栈。

push(x) —— 将元素 x 推入栈中。
pop() —— 删除栈顶的元素。
top() —— 获取栈顶元素。
getMin() —— 检索栈中的最小元素。

两个栈模拟，其中一个正常push和pop，另外一个每次压入元素前先比较一下与栈顶元素的大小，若小于才压入，若不小于则压入与栈顶一样的元素，保证两个栈同等高度，辅助栈是同步的，缺点是保存不必要的元素

```c++
class MinStack {
public:
    /** initialize your data structure here. */
    stack<int> s1, s2;
    MinStack() {}

    void push(int x) {
        if (s1.empty() && s2.empty()) {
            s1.push(x);
            s2.push(x);
        } else {
            s1.push(x);
            if (s2.top() > x) {
                s2.push(x);
            } else {
                s2.push(s2.top());
            }
        }
    }
    void pop() {
        s1.pop();
        s2.pop();
    }
    int top() {
        return s1.top();
    }
    int getMin() {
        return s2.top();
    }
};

/**
 * Your MinStack object will be instantiated and called as such:
 * MinStack* obj = new MinStack();
 * obj->push(x);
 * obj->pop();
 * int param_3 = obj->top();
 * int param_4 = obj->getMin();
 */
```

刷hot100，换了种思路，也是两个栈，其中栈2当压入元素比当前元素小于等于时才压入，pop时，若st1pop元素等于当前st2栈顶元素，则st2也pop，这种也是不同步的栈，辅助栈只存必要元素

```c++
class MinStack {
public:
    stack<int> st1;
    stack<int> st2;
    MinStack() {}
    void push(int val) {
        st1.push(val);
        if (st2.empty() || val <= st2.top()) {
            st2.push(val);
        }
    }
    void pop() {
        // if (st1.empty()) throw new exception("pop empty stack");
        int t = st1.top();
        st1.pop();
        if (st2.top() == t) {
            st2.pop();
        }
    }
    int top() {
        return st1.top();
    }
    int getMin() {
        return st2.top();
    }
};
```

### 316. 去除重复字母(Medium)

给你一个字符串 s ，请你去除字符串中重复的字母，使得每个字母只出现一次。需保证 返回结果的字典序最小（要求不能打乱其他字符的相对位置）。

示例 1：

输入：s = "bcabc"
输出："abc"
示例 2：

输入：s = "cbacdcbc"
输出："acdb"

提示：

1 <= s.length <= 104
s 由小写英文字母组成

**解法：贪心+单调栈**

实际上，题解需满足三个条件：

要求一、要去重。

要求二、去重字符串中的字符顺序不能打乱 s 中字符出现的相对顺序。

要求三、在所有符合上一条要求的去重字符串中，字典序最小的作为最终结果。

去重很简答，搞个长度为26的标记数组或者哈希表都可以，不能打乱顺序也很简单，按顺序遍历即可，难点是要求三，比如：s = "babc"，如果仅按照普通遍历，会输出"bac"，但其实答案是"abc"，字典序更小，如何找到字典序更小的解？答案就是贪心，当第一次遍历到x时，比x大的都弹出来，然后以x作为起点，这就可以用单调递减栈来实现

但是有可能出现错误答案：s = "bcac"，会输出"ac"，因为在压栈a时，把b给弹出来了，a后面没有b了，所以不能弹b，故出栈时还需要该字母剩余出现次数，这里用freq哈希表记录，预处理生成所有字母的出现次数，遍历字符串时，对应字母的频次-1，表明后面还有x-1个该元素

```c++
class Solution {
public:
    string removeDuplicateLetters(string s) {
        map<char, int> freq; // 统计各字符的频次
        for (char &i : s) {
            freq[i] += 1;
        }
        vector<char> res; // 用一个向量作为栈
        for (char & c:s) {
            if (!count(res.begin(), res.end(), c)) {
                while (!res.empty() && c < res.back() && freq[res.back()] > 0) {
                    res.pop_back();
                }
                res.push_back(c);
            }
            freq[c]--; // 当前字符的频次-1
        }
        string ans(res.begin(), res.end());
        return ans;
    }
};
```

用stack来做，还需要用一个数据结构来存放stack中目前去重的字母种类，这里用set来统计，因为stack得一个个pop，且不好搜索，所以这题没必要一定要用stack，可以用vector甚至是string来模拟栈

时间
4 ms
击败
60.82%
内存
6.9 MB
击败
8.83%

```c++
class Solution {
public:
    string removeDuplicateLetters(string s) {
        map<char, int> freq;
        for (char &ch : s) {
            freq[ch]++;
        }
        set<char> cur_letters; // 记录当前栈中的去重元素
        stack<char> st;
        for (int i = 0; i < s.size(); ++i) {
            if (!cur_letters.count(s[i])) { // 该字母之前没出现过，入栈，并尝试将小于它的字母出栈
                while (!st.empty() && st.top() > s[i] && freq[st.top()] > 0) {
                    char ch = st.top();
                    st.pop();
                    cur_letters.erase(ch);
                }
                st.push(s[i]);
                cur_letters.insert(s[i]);
            }
            freq[s[i]]--;
        }
        string res;
        while (!st.empty()) {
            char ch = st.top();
            st.pop();
            res = string(1, ch).append(res);
        }
        return res;
    }
};
```

用string来模拟栈，可以巧妙地使用string本身的函数，非常简洁，注意不能写成`!st.find(s[i])`

```c++
class Solution {
public:
    string removeDuplicateLetters(string s) {
        map<char, int> freq;
        for (char &ch : s) {
            freq[ch]++;
        }
        string st;
        for (int i = 0; i < s.size(); ++i) {
            if (st.find(s[i]) == string::npos) { // 该字母之前没出现过，入栈，并尝试将小于它的字母出栈
                while (!st.empty() && st.back() > s[i] && freq[st.back()] > 0) {
                    char ch = st.back();
                    st.pop_back();
                }
                st.push_back(s[i]);
            }
            freq[s[i]]--;
        }
        return st;
    }
};
```

### 394. 字符串解码(Medium) @hot100

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

刷字节top时碰到了，只用了一个栈，没有用逆波兰式那样把操作数和操作符号分开存放，代码略微繁琐，但也能接受，时间空间复杂度都是O(n)

```c++
class Solution {
public:
    string decodeString(string s) {
        string ans;
        string tmp;
        string tmp_single;
        stack<string> st;
        for (char & ch : s) {
            if (ch >= '0' && ch <= '9') {// 数字有可能不止一位，要与前面出现的数字组合起来
                if (!st.empty() && isNum(st.top())) {
                    tmp = st.top();
                    st.pop();
                    st.push(tmp+ch);
                } else {
                    st.push(string(1, ch));
                }
                continue;
            }
            if (ch == ']') {
                tmp = "";
                while (!st.empty() && st.top()[0] != '[') {
                    tmp = st.top() + tmp;
                    st.pop();
                    cout << tmp << endl;
                }
                if (!st.empty()) {
                    st.pop(); // 弹出'['
                    int k = 1;
                    if (!st.empty() && isNum(st.top())) { // 检测'['之前的数字
                        k = stoi(st.top());
                        st.pop();
                    }
                    tmp_single = tmp;
                    tmp = "";
                    while (k-- > 0){
                        tmp += tmp_single;
                    }
                }
                cout << tmp << endl;
                st.push(tmp);
            } else {
                st.push(string(1, ch)); // '['也会push进去
            }
        }
        while (!st.empty()) { // 这时栈里只剩字母
            ans = st.top() + ans;
            st.pop();
        }
        return ans;
    }

    bool isNum(string str) {
        if (str[0] >= '0' && str[0] <= '9') return true;
        return false;
    }
};
```

刷hot100，用的`stack<char>`，代码直观点，在while循环中，最外层的if-else只管区分`]`与否，不是`]`的直接压栈，是`]`的话，就pop前面一段字符串，先组建tmp子串，再查找`[`前面的times，解码后再压回去

时间
0 ms
击败
100%
内存
6.4 MB
击败
53%

```c++
class Solution {
public:
    string decodeString(string s) {
        stack<char> st;
        int i = 0;
        int n = s.size();
        while (i < n) {
            if (s[i] == ']') {
                string tmp;
                while (st.top() != '[') {
                    tmp.append(string(1, st.top())); // char to string, 使用string的构造函数string(int count, char ch)
                    st.pop();
                }
                st.pop(); // 将`[`pop
                reverse(tmp.begin(), tmp.end());
                int times = 0;
                int tens = 1;
                while (!st.empty() && st.top() - '0' <= 9) { // 根据题意，`[`前面肯定有数字
                    times += (st.top() - '0') * tens;
                    tens *= 10;
                    st.pop();
                }
                string decoded_tmp;
                for (int i = 0; i < times; ++i) {
                    decoded_tmp.append(tmp);
                }
                for (const char &ch : decoded_tmp) {
                    st.push(ch); // 解码后压栈
                }
            } else {
                st.push(s[i]); // 其他情况只管压栈
            }
            ++i;
        }
        string decoded;
        while (!st.empty()) {
            decoded.append(string(1, st.top()));
            st.pop();
        }
        reverse(decoded.begin(), decoded.end());
        return decoded;
    }
};
```

刷hot75时，想到了用两个栈，感觉比上面的直观

```c++
class Solution {
public:
    string decodeString(string s) {
        int n = s.length();
        if (n == 0 || n == 1) return s;
        stack<int> times;
        stack<string> st;
        int i = 0;
        while (i < n) {
            if (isdigit(s[i])) {
                string num;
                while (i < n && isdigit(s[i])) {
                    num += s[i];
                    ++i;
                }
                int time = stoi(num);
                times.push(time);
            } else if (s[i] == ']') { // 因为输入肯定合法，所以此时去找'['
                string cur;
                while (!st.empty() && st.top() != "[") {
                    cur = st.top() + cur;
                    st.pop();
                }
                if (st.top() == "[") st.pop();
                string decoded_cur;
                for (int j = 0; j < times.top(); ++j) { // 再找'['前的数字
                    decoded_cur += cur;
                }
                times.pop();
                st.push(decoded_cur); // 组合成新的字符串压栈
                ++i;
            } else {
                st.push({s[i]});
                ++i;
            }
        }
        string ans;
        while (!st.empty()) {
            ans = st.top() + ans;
            st.pop();
        }
        return ans;
    }
};
```

看官方题解，用到了递归法，从左向右解析字符串：

- 如果当前位置为数字位，那么后面一定包含一个用方括号表示的字符串，即属于这种情况：k[...]：
  - 我们可以先解析出一个数字，然后解析到了左括号，递归向下解析后面的内容，遇到对应的右括号就返回，此时我们可以根据解析出的数字 x 解析出的括号里的字符串 s’ 构造出一个新的字符串 x × s‘
  - 我们把 k[...] 解析结束后，再次调用递归函数，解析右括号右边的内容。实现上可以用一个全局指针后移实现
- 如果当前位置是字母位，那么我们直接解析当前这个字母，然后递归向下解析这个字母后面的内容。

时间复杂度O(n)，空间复杂度是栈空间，极端情况下需要n次递归，所以是O(n)

```c++
class Solution {
public:
    string src; 
    size_t ptr; // 全局指针，getString函数从ptr开始解析

    int getDigits() {
        int ret = 0;
        while (ptr < src.size() && isdigit(src[ptr])) {
            ret = ret * 10 + src[ptr++] - '0';
        }
        return ret;
    }

    string getString() {
        if (ptr == src.size() || src[ptr] == ']') {
            return "";
        }
        char cur = src[ptr];
        int repTime = 1;
        string ret;
        if (isdigit(cur)) {
            repTime = getDigits(); 
            ++ptr; // 由题可知，数字后面紧跟左括号，过滤左括号
            string str = getString(); // 递归调用，解析[]中间的String
            ++ptr; // 过滤右括号
            while (repTime--) ret += str; // 构造字符串
        } else if (isalpha(cur)) {
            ret = string(1, src[ptr++]); // 当前字母遍历完，指针后移
        }
        
        return ret + getString(); // 此时指针指向后面一个字符，递归处理
    }

    string decodeString(string s) {
        src = s;
        ptr = 0;
        return getString();
    }
};
```

### 402. 移掉 K 位数字(Medium)

给你一个以字符串表示的非负整数 num 和一个整数 k ，移除这个数中的 k 位数字，使得剩下的数字最小。请你以字符串形式返回这个最小的数字。

示例 1 ：

输入：num = "1432219", k = 3
输出："1219"
解释：移除掉三个数字 4, 3, 和 2 形成一个新的最小的数字 1219 。
示例 2 ：

输入：num = "10200", k = 1
输出："200"
解释：移掉首位的 1 剩下的数字为 200. 注意输出不能有任何前导零。
示例 3 ：

输入：num = "10", k = 2
输出："0"
解释：从原数字移除所有的数字，剩余为空就是 0 。

提示：

1 <= k <= num.length <= 105
num 仅由若干位数字（0 - 9）组成
除了 0 本身之外，num 不含任何前导零

贪心+单调栈，与316.去除重复字母很像

若要使得剩下的数字最小，需要保证靠前的数字尽可能小。

用一个栈维护当前的答案序列，栈中的元素代表截止到当前位置，删除不超过 k 次个数字后，所能得到的最小整数。因此，对于每个数字，如果该数字小于栈顶元素，我们就不断地弹出栈顶元素，直到

- 栈为空
- 或者新的栈顶元素不大于当前数字
- 或者我们已经删除了 k 位数字

上述步骤结束后我们还需要针对一些情况做额外的处理：

- 如果我们删除了 m 个数字且 `m<k`，这种情况下我们需要从序列尾部删除额外的 k−m 个数字。
- 如果最终的数字序列存在前导零，我们要删去前导零。(前导零是最后删除的，不计入上面的k)
- 如果最终数字序列为空，我们应该返回 0。

最终，从栈底到栈顶的答案序列即为最小数。

考虑到实现方便，直接用string模拟栈

```c++
class Solution {
public:
    string removeKdigits(string num, int k) {
        // 维护单调递增栈，当栈顶元素出栈时，判断剩余元素是否满足k的大小
        int n = num.size();
        if (k == n) return "0";
        string st;
        for (int i = 0; i < n; ++i) {
            while (!st.empty() && st.back() > num[i] && k > 0) {
                st.pop_back();
                --k;
            }
            st.push_back(num[i]);
        }
        // 还有k个需要删除，从末尾删
        if (st.size() <= k) return {"0"};
        st.erase(st.end() - k, st.end());
        
        int i = 0;
        while (i < st.size() - 1) { // 保留最后的0
            if (st[i] != '0') {
                break; // 去除前导零
            }
            ++i;
        }
        string res(st.begin() + i, st.end());
        return res;
    }
};
```

### 496. 下一个更大元素 I

nums1 中数字 x 的 下一个更大元素 是指 x 在 nums2 中对应位置 右侧 的 第一个 比 x 大的元素。

给你两个 没有重复元素 的数组 nums1 和 nums2 ，下标从 0 开始计数，其中nums1 是 nums2 的子集。

对于每个 0 <= i < nums1.length ，找出满足 nums1[i] == nums2[j] 的下标 j ，并且在 nums2 确定 nums2[j] 的 下一个更大元素 。如果不存在下一个更大元素，那么本次查询的答案是 -1 。

返回一个长度为 nums1.length 的数组 ans 作为答案，满足 ans[i] 是如上所述的 下一个更大元素 。

示例 1：

输入：nums1 = [4,1,2], nums2 = [1,3,4,2].
输出：[-1,3,-1]
解释：nums1 中每个值的下一个更大元素如下所述：

- 4 ，用加粗斜体标识，nums2 = [1,3,4,2]。不存在下一个更大元素，所以答案是 -1 。
- 1 ，用加粗斜体标识，nums2 = [1,3,4,2]。下一个更大元素是 3 。
- 2 ，用加粗斜体标识，nums2 = [1,3,4,2]。不存在下一个更大元素，所以答案是 -1 。

示例 2：

输入：nums1 = [2,4], nums2 = [1,2,3,4].
输出：[3,-1]
解释：nums1 中每个值的下一个更大元素如下所述：

- 2 ，用加粗斜体标识，nums2 = [1,2,3,4]。下一个更大元素是 3 。
- 4 ，用加粗斜体标识，nums2 = [1,2,3,4]。不存在下一个更大元素，所以答案是 -1 。

提示：

1 <= nums1.length <= nums2.length <= 1000
0 <= nums1[i], nums2[i] <= 104
nums1和nums2中所有整数 互不相同
nums1 中的所有整数同样出现在 nums2 中

进阶：你可以设计一个时间复杂度为 O(nums1.length + nums2.length) 的解决方案吗？

单调栈，用一个哈希表存储，空间复杂度O(num2.size())，时间复杂度O(nums1.size()+nums2.size())

```c++
class Solution {
public:
    vector<int> nextGreaterElement(vector<int>& nums1, vector<int>& nums2) {
        unordered_map<int, int> hash; // key=nums[i]，val=nums[i]的下一个更大元素
        stack<int> st; // 构建单调递减栈
        int n2 = nums2.size();
        for (int i = 0; i < n2; ++i) {
            while (!st.empty() && nums2[st.top()] < nums2[i]) {
                int cur = st.top(); // 处理cur的下一个更大元素
                st.pop();
                hash[nums2[cur]] = nums2[i]; // nums2[cur]的下一个更大元素是nums2[i]
            }
            st.push(i);
        }
        int n1 = nums1.size();
        vector<int> res(n1, -1);
        for (int i = 0; i < n1; ++i) {
            if (hash.count(nums1[i])) {
                res[i] = hash[nums1[i]];
            }
        }
        return res;
    }
};
```

### 581. 最短无序连续子数组(Medium)

给你一个整数数组 nums ，你需要找出一个 连续子数组 ，如果对这个子数组进行升序排序，那么整个数组都会变为升序排序。

请你找出符合题意的 最短 子数组，并输出它的长度。

示例 1：

输入：nums = [2,6,4,8,10,9,15]
输出：5
解释：你只需要对 [6, 4, 8, 10, 9] 进行升序排序，那么整个表都会变为升序排序。
示例 2：

输入：nums = [1,2,3,4]
输出：0
示例 3：

输入：nums = [1]
输出：0

提示：

1 <= nums.length <= 104
-105 <= nums[i] <= 105

进阶：你可以设计一个时间复杂度为 O(n) 的解决方案吗？

差点放弃了，用了两个单调栈，第一次找到最右端，第二次找到最左端，时间复杂度O(n)，空间复杂度O(n)

```c++
class Solution {
public:
    int findUnsortedSubarray(vector<int>& nums) {
        // 0~i-1升序，i~j最小值大于nums[i-1]，i~j最大值小于nums[j+1]，j+1~n-1升序
        nums.insert(nums.begin(), INT_MIN); // 哨兵
        int n = nums.size();
        vector<int> st; // 维护单调递减栈，栈中元素是对应nums的下标
        st.push_back(0); // 哨兵
        int r = -1;
        for (int i = 1; i < n; ++i) {
            while (!st.empty() && nums[st.back()] < nums[i]) {
                st.pop_back();
            }
            if (!st.empty() && nums[st.back()] == nums[i] && nums[st.front()] == nums[i]) { // 与之前的最大值相等，且当前值等于栈底的最大值，不压栈，保持最早的offset
                continue;
            }
            st.push_back(i);
            if (st.size() >= 2) {
                r = max(r, st.back());
            }
        }
        if (r == -1) return 0; // 根本没有逆序对，返回0
        nums.erase(nums.begin());
        nums.push_back(INT_MAX); // 哨兵
        n = nums.size();
        st.clear(); // 此时维护单调递增栈
        st.push_back(n-1);
        int l = n;
        for (int i = n - 2; i >= 0; --i) {
            while (!st.empty() && nums[st.back()] > nums[i]) {
                st.pop_back();
            }
            if (!st.empty() && nums[st.back()] == nums[i] && nums[st.front()] == nums[i]) { // 与之前的最大值相等，且当前值等于栈底的最大值，不压栈，保持最早的offset
                continue;
            }
            st.push_back(i);
            if (st.size() >= 2) {
                l = min(l, st.back());
            }
        }
        return r - l;
    }
};
```

时间复杂度O(nlogn)，可以用排序，因为0~i-1升序，i~j最小值大于nums[i-1]，i~j最大值小于nums[j+1]，j+1~n-1升序，我们只需对原数组排序，再与原数组比较，找到最长的前缀相同，找到最长的后缀相同，中间的即为最短的连续子数组

再优化一下，我们可以假设把这个数组分成三段，左段和右段是标准的升序数组，中段数组虽是无序的，但满足最小值大于左段的最大值，最大值小于右段的最小值。

那么我们目标就很明确了，找中段的左右边界，我们分别定义为begin 和 end; 分两头开始遍历:

- 从左到右维护一个最大值max,在进入右段之前，那么遍历到的nums[i]都是小于max的，我们要求的end就是遍历中最后一个小于max元素的位置；
- 同理，从右到左维护一个最小值min，在进入左段之前，那么遍历到的nums[i]也都是大于min的，要求的begin也就是最后一个大于min元素的位置。

时间复杂度O(n)，空间复杂度O(1)
```c++
class Solution {
public:
    int findUnsortedSubarray(vector<int>& nums) {
        //一段中间有无序序列、其余部分有序的数组满足
        //max和min并非数组中的最大最小值，而是我们路途中遇到的最大最小值
        //从左往右走，max值一定会连续增加；若不增加，说明这一段无序
            //max初始值为nums[0]，因为我们是从左往右走
        //从右往左走，min值一定会连续降低；若不降低，说明这一段无序
            //min初始值为nums[len-1]，因为我们是从右往左走
        //因此，我们可以两次遍历，从而找出无序的左右边界
        //第一次： 正序遍历，找到最后一个值小于我们连续更新的max值的位置
        //第二次： 逆序遍历，找到最后一个值大于我们连续更新的min值的位置
        int len = nums.size();
        
        // 找end
        int max = nums[0];
        int end = -1; // end为-1，表示这个数组没有无序字段
        for (int i = 0; i < len; ++i) {
            if (nums[i] < max) { //逆序了
                end = i;
            } else {
                max = nums[i];
            }
        }

        //找begin
        int min = nums[len - 1];
        int begin = 0; //begin为0，是为了与end初始值为-1联动
        for (int i = len - 1; i >= 0; --i) {
            if (nums[i] > min) { // 逆序了
                begin = i;
            } else {
                min = nums[i];
            }
        }

        return end - begin + 1;// 从index i 到index j，就是有j - i + 1个数字的
    }
};
```

### 735. 小行星碰撞

medium

给定一个整数数组 asteroids，表示在同一行的小行星。

对于数组中的每一个元素，其绝对值表示小行星的大小，正负表示小行星的移动方向（正表示向右移动，负表示向左移动）。每一颗小行星以相同的速度移动。

找出碰撞后剩下的所有小行星。碰撞规则：两个小行星相互碰撞，较小的小行星会爆炸。如果两颗小行星大小相同，则两颗小行星都会爆炸。两颗移动方向相同的小行星，永远不会发生碰撞。

```
示例 1：

输入：asteroids = [5,10,-5]
输出：[5,10]
解释：10 和 -5 碰撞后只剩下 10 。 5 和 10 永远不会发生碰撞。
示例 2：

输入：asteroids = [8,-8]
输出：[]
解释：8 和 -8 碰撞后，两者都发生爆炸。
示例 3：

输入：asteroids = [10,2,-5]
输出：[10]
解释：2 和 -5 发生碰撞后剩下 -5 。10 和 -5 发生碰撞后剩下 10 。
 

提示：

2 <= asteroids.length <= 104
-1000 <= asteroids[i] <= 1000
asteroids[i] != 0
```

挺有意思的一道题，调试了好一会，注意[-2,-1,1,2]这种的输出仍然为[-2,-1,1,2]，因为开头的负数往左边走，末尾的正数往右边走，不会碰撞，所以有些边界情况需要考虑清楚

```c++
class Solution {
public:
    vector<int> asteroidCollision(vector<int>& asteroids) {
        if (asteroids.empty() || asteroids.size() == 1)
            return asteroids;
        int n = asteroids.size();
        vector<int> ans;
        stack<int> st;
        for (int i = 0; i < n; ++i) {
            bool add = true;
            if (asteroids[i] < 0) { // 大于0，往右边，可以直接压栈，不需要进入判断
                while (!st.empty()) {
                    if (st.top() < 0) {
                        break;
                    } else if (st.top() == -asteroids[i]) {
                        st.pop();
                        add = false;
                        break;
                    } else if (st.top() > -asteroids[i]) {
                        add = false;
                        break;
                    } else {
                        st.pop();
                    }
                }
            }
            if (add) st.push(asteroids[i]);
        }
        while (!st.empty()) {
            ans.push_back(st.top());
            st.pop();
        }
        reverse(ans.begin(), ans.end());
        return ans;
    }
};
```

### 739. 每日温度(Medium) @hot100

请根据每日 气温 列表，重新生成一个列表。对应位置的输出为：要想观测到更高的气温，至少需要等待的天数。如果气温在这之后都不会升高，请在该位置用 0 来代替。

例如，给定一个列表 temperatures = [73, 74, 75, 71, 69, 72, 76, 73]，你的输出应该是 [1, 1, 4, 2, 1, 1, 0, 0]。

提示：气温 列表长度的范围是 [1, 30000]。每个气温的值的均为华氏度，都是在 [30, 100] 范围内的整数。

单调栈模板解决"下一个更大/更小元素"一类问题。  一定要注意：入栈的是索引，比较的时候比的是数值。

复习单调栈的绝佳例题，ans初始化都是0，所以最后不用管st里面还有没有元素，时空复杂度都是O(n)

```c++
class Solution {
public:
    vector<int> dailyTemperatures(vector<int>& T) {
        if (T.empty()) return {};
        vector<int> ans(T.size(), 0);
        stack<int> st; // mono decreasing stack
        for (int i = 0; i < T.size(); ++i) {
            while (!st.empty() && T[st.top()] < T[i]) {
                int cur = st.top();
                st.pop();
                ans[cur] = i - cur;
            }
            st.push(i);
        }
        return ans;
    }
};
```

刷hot100，用了pair，其实不需要的，有index就知道temperatures[index]的值，所以只需要index即可

```c++
class Solution {
public:
    vector<int> dailyTemperatures(vector<int>& temperatures) {
        if (temperatures.empty()) return {};
        int n = temperatures.size();
        if (n == 1) return {0};
        vector<int> res (n, 0);
        stack<pair<int, int>> st; // 栈中存放暂未找到下一个更高温度的pair={temperatures[i], i}
        for (int i = 0; i < n; ++i) {
            while (!st.empty() && temperatures[i] > st.top().first) {
                res[st.top().second] = i - st.top().second; // 间隔几天
                st.pop();
            }
            st.push({temperatures[i], i});
        }
        return res;
    }
};
```

### 901. 股票价格跨度(Medium)

设计一个算法收集某些股票的每日报价，并返回该股票当日价格的 跨度 。

当日股票价格的 跨度 被定义为股票价格小于或等于今天价格的最大连续日数（从今天开始往回数，包括今天）。

例如，如果未来 7 天股票的价格是 [100,80,60,70,60,75,85]，那么股票跨度将是 [1,1,1,2,1,4,6] 。

实现 StockSpanner 类：

StockSpanner() 初始化类对象。
int next(int price) 给出今天的股价 price ，返回该股票当日价格的 跨度 。

示例：

输入：
["StockSpanner", "next", "next", "next", "next", "next", "next", "next"]
[[], [100], [80], [60], [70], [60], [75], [85]]
输出：
[null, 1, 1, 1, 2, 1, 4, 6]

解释：
StockSpanner stockSpanner = new StockSpanner();
stockSpanner.next(100); // 返回 1
stockSpanner.next(80);  // 返回 1
stockSpanner.next(60);  // 返回 1
stockSpanner.next(70);  // 返回 2
stockSpanner.next(60);  // 返回 1
stockSpanner.next(75);  // 返回 4 ，因为截至今天的最后 4 个股价 (包括今天的股价 75) 都小于或等于今天的股价。
stockSpanner.next(85);  // 返回 6

提示：

1 <= price <= 105
最多调用 next 方法 104 次

单调栈，本质上是找前一个大于自身的下标，单调递减栈

```c++
class StockSpanner {
public:
    stack<int> st; // 单调递减栈，元素是其对应stocks数组的下标
    vector<int> stocks = {0};
    int cur = 0; // 永远指向当前操作结束后stocks数组最后一位元素的
    StockSpanner() {
        st.push(0); // 前置哨兵，对应stocks的下标0
    }
    int next(int price) {
        ++cur;
        while (!st.empty() && stocks[st.top()] <= price) {
            st.pop();
        }
        int earliest = st.empty() ? 0 : st.top();
        st.push(cur);
        stocks.push_back(price);
        return cur - earliest;
    }
};

/**
 * Your StockSpanner object will be instantiated and called as such:
 * StockSpanner* obj = new StockSpanner();
 * int param_1 = obj->next(price);
 */
```

### 1081. 不同字符的最小子序列(Medium)

返回 s 字典序最小的子序列，该子序列包含 s 的所有不同字符，且只包含一次。

注意：该题与 316 https://leetcode.com/problems/remove-duplicate-letters/ 相同

示例 1：

输入：s = "bcabc"
输出："abc"
示例 2：

输入：s = "cbacdcbc"
输出："acdb"

提示：

1 <= s.length <= 1000
s 由小写英文字母组成

题解同316

### 2390. 从字符串中移除星号

medium

给你一个包含若干星号 * 的字符串 s 。

在一步操作中，你可以：

选中 s 中的一个星号。
移除星号 左侧 最近的那个 非星号 字符，并移除该星号自身。
返回移除 所有 星号之后的字符串。

注意：

生成的输入保证总是可以执行题面中描述的操作。
可以证明结果字符串是唯一的。

```
示例 1：

输入：s = "leet**cod*e"
输出："lecoe"
解释：从左到右执行移除操作：
- 距离第 1 个星号最近的字符是 "leet**cod*e" 中的 't' ，s 变为 "lee*cod*e" 。
- 距离第 2 个星号最近的字符是 "lee*cod*e" 中的 'e' ，s 变为 "lecod*e" 。
- 距离第 3 个星号最近的字符是 "lecod*e" 中的 'd' ，s 变为 "lecoe" 。
不存在其他星号，返回 "lecoe" 。
示例 2：

输入：s = "erase*****"
输出：""
解释：整个字符串都会被移除，所以返回空字符串。
 

提示：

1 <= s.length <= 105
s 由小写英文字母和星号 * 组成
s 可以执行上述操作
```

其实算easy，先来个从右往左一次遍历的解法，最后把ans翻转即可

```c++
class Solution {
public:
    string removeStars(string s) {
        if (s.empty()) return s;
        int n = s.length();
        string ans;
        int star = 0;
        for (int i = n-1; i >= 0; --i) {
            if (s[i] == '*') ++star;
            else if (star > 0) --star;
            else ans += s[i];
        }
        reverse(ans.begin(), ans.end());
        return ans;
    }
};
```

这题也可以从左往右，用栈来实现，但空间复杂度明显上面解法gengh哦

```c++
class Solution {
public:
    string removeStars(string s) {
        if (s.empty()) return s;
        int n = s.length();
        stack<char> st;
        for (int i = 0; i < n; ++i) {
            if (s[i] == '*') {
                if (!st.empty()) st.pop();
            }
            else st.push(s[i]);
        }
        string ans;
        while (!st.empty()) {
            ans += st.top();
            st.pop();
        }
        reverse(ans.begin(), ans.end());
        return ans;
    }
};
```

还有一种原地修改的，双指针，第一个指针指向已确定好区间的末尾，最后resize一下数组即可

```c++
class Solution {
public:
    string removeStars(string s) {
        if (s.empty()) return s;
        int n = s.length();
        int last = -1; // 若有*，则删除last位置的元素，然后--last
        for (int i = 0; i < n; ++i) {
            if (s[i] == '*') {
                if (last != -1) --last;
            } else {
                s[++last] = s[i];
            }
        }
        s.resize(last+1);
        return s;
    }
};
```

## 队列

### 933. 最近的请求次数

easy

写一个 RecentCounter 类来计算特定时间范围内最近的请求。

请你实现 RecentCounter 类：

RecentCounter() 初始化计数器，请求数为 0 。
int ping(int t) 在时间 t 添加一个新请求，其中 t 表示以毫秒为单位的某个时间，并返回过去 3000 毫秒内发生的所有请求数（包括新请求）。确切地说，返回在 [t-3000, t] 内发生的请求数。
保证 每次对 ping 的调用都使用比之前更大的 t 值。

```
示例 1：

输入：
["RecentCounter", "ping", "ping", "ping", "ping"]
[[], [1], [100], [3001], [3002]]
输出：
[null, 1, 2, 3, 3]

解释：
RecentCounter recentCounter = new RecentCounter();
recentCounter.ping(1);     // requests = [1]，范围是 [-2999,1]，返回 1
recentCounter.ping(100);   // requests = [1, 100]，范围是 [-2900,100]，返回 2
recentCounter.ping(3001);  // requests = [1, 100, 3001]，范围是 [1,3001]，返回 3
recentCounter.ping(3002);  // requests = [1, 100, 3001, 3002]，范围是 [2,3002]，返回 3
 

提示：

1 <= t <= 109
保证每次对 ping 调用所使用的 t 值都 严格递增
至多调用 ping 方法 104 次
```

hot75最开始只想到了暴力，太挫了

```c++
class RecentCounter {
    vector<int> ping_holder;
public:
    RecentCounter() {

    }
    
    int ping(int t) {
        ping_holder.push_back(t);
        int n = ping_holder.size();
        int ans = 0;
        for (int i = n-1; i >= 0; --i) {
            if (t - 3000 <= ping_holder[i]) ++ans;
        }
        return ans;
    }
};
```

用队列可以直接秒

```c++
class RecentCounter {
    queue<int> q;
public:
    RecentCounter() { }
    
    int ping(int t) {
        q.push(t);
        while (!q.empty() && q.front() < t - 3000) q.pop();
        return q.size();
    }
};
```

若对时间有严格要求，可以用数组+二分，因为t是严格递增，正好满足要求，为了缩小二分范围，还可以用指针l指示队列的头元素，左边更早的元素都已过期

```c++
class RecentCounter {
    vector<int> vec;
    int l; // 队列头元素，之前的元素都已过期
public:
    RecentCounter() : l(0) {}
    
    int ping(int t) {
        vec.push_back(t);
        int n = vec.size()-1;
        int r = n;
        int num = t - 3000;
        if (vec[l] >= num) return n - l + 1; // 待搜索区间左端点小于待搜索值，整个区间都是合法解
        while (l < r) {
            int mid = (r - l) / 2 + l;
            if (vec[mid] == num) {
                l = mid;
                break; // 因为严格递增，所以没有连续相等情况
            } else if (vec[mid] < num) {
                l = mid + 1;
            } else {
                r = mid; // 注意收缩条件
            }
        }
        return n-l+1;
    }
};

/**
 * Your RecentCounter object will be instantiated and called as such:
 * RecentCounter* obj = new RecentCounter();
 * int param_1 = obj->ping(t);
 */
```

## 堆

C++的堆用priority_queue实现，默认比较函数是less，默认构造大根堆/最大堆，可以传入自定义的比较函数，当传入自定义的比较函数时，存放元素的容器也必须显式指定，一般用`vector<T>`

有三种方法传入自定义的比较函数

```c++
// 1. 直接使用stl已有的比较函数
priority_queue<int, vector<int>, greater<int>> pq; // 小根堆
priority_queue<pair<int, int>,vector<pair<int, int>>,greater<pair<int, int>>> q; // 小根堆

// 2. 自定义结构体，并重载operator()函数调用符
struct myComp{
    bool operator()(int a, int b) {
        return a > b;
    }
};
priority_queue<int, vector<int>, myComp> pq; // 构建最小堆

// 3. lambda表示式
auto lambdaComp = [] (int a, int b) {
    return a > b;
};
priority_queue<int, vector<int>, decltype(lambdaComp)> pq(lambdaComp); // 构建最小堆，decltype、pq(lambda)不能省略

bool (*lambdaComp)(int, int) = [] (int a, int b) {
    return a > b;
};
priority_queue<int, vector<int>, decltype(lambdaComp)> pq(lambdaComp); // 构建最小堆
```

### 215.数组中的第K个最大元素(Medium) @hot100

在未排序的数组中找到第 k 个最大的元素。请注意，你需要找的是数组排序后的第 k 个最大的元素，而不是第 k 个不同的元素。

示例 1:

输入: [3,2,1,5,6,4] 和 k = 2
输出: 5
示例 2:

输入: [3,2,3,1,2,4,5,5,6] 和 k = 4
输出: 4
说明:

提示：

1 <= k <= nums.length <= 105
-104 <= nums[i] <= 104

因为时间复杂度要求O(n)，基本上只能线性遍历，无法嵌套遍历，借助小根堆（最小堆）

```c++
class Solution {
public:
    int findKthLargest(vector<int>& nums, int k) {
        priority_queue<int, vector<int>, greater<int>> pq; // 小根堆
        for (int i = 0; i < nums.size(); ++i) {
            pq.push(nums[i]);
            if (pq.size() > k) {
                pq.pop();
            }
        }
        return pq.top();
    }
};
```

大根堆，得多遍历一下

```c++
class Solution {
public:
    int findKthLargest(vector<int>& nums, int k) {
        priority_queue<int> pq;
        for (int i = 0; i < nums.size(); ++i) {
            pq.push(nums[i]);
        }
        for (int i = 0; i < k - 1; ++i) {
            pq.pop();
        }
        return pq.top();
    }
};
```

快速选择，找到个很容易理解（背诵）的模板，它直接取最左端为pivot，在数组有序时效率很差，不过对于模板来说，这份代码很工整

```c++
class Solution {
public:
    int findKthLargest(vector<int>& nums, int k) {
        if (nums.empty()) return 0;
        int left = 0, right = nums.size() - 1;
        while (true) {
            int position = partition(nums, left, right);
            if (position == k - 1) return nums[position]; //每一轮返回当前pivot的最终位置，它的位置就是第几大的，如果刚好是第K大的数
            else if (position > k - 1) right = position - 1; //二分的思想
            else left = position + 1;
        }
    }

    int partition(vector<int>& nums, int left, int right) {
        int pivot = left;
        int l = left + 1; //记住这里l是left + 1
        int r = right;
        while (l <= r) {
            while (l <= r && nums[l] >= nums[pivot]) l++; //从左边找到第一个小于nums[pivot]的数
            while (l <= r && nums[r] <= nums[pivot]) r--; //从右边找到第一个大于nums[pivot]的数
            if (l <= r && nums[l] < nums[pivot] && nums[r] > nums[pivot]) {
                swap(nums[l++], nums[r--]);
            }
        }
        swap(nums[pivot], nums[r]); //交换pivot到它所属的最终位置，也就是在r的位置，因为此时r的左边都比r大，右边都比r小
        return r; //返回最终pivot的位置
    }
};
```

刷hot75时刷到了，

```c++
class Solution {
public:
    int findKthLargest(vector<int>& nums, int k) {
        int n = nums.size();
        return partition(nums, k, 0, n-1);
    }
    int partition(vector<int> &nums, int k, int low, int high) { // 每次partition都会把大于nums[pivot]的元素挪到pivot前面，小于的挪到pivot后面
        if (low >= high) return nums[low];
        int pivot = low;
        int i = pivot+1;
        int j = high;
        while (i < j) {
            while (i < j && nums[i] > nums[pivot]) ++i; // 找到比pivot位置还要小的元素
            while (i < j && nums[j] < nums[pivot]) --j; // 找到比pivot位置还要大的元素
            swap(nums[i], nums[j]);
            if (i < j) {
                ++i;
                --j;
            }
        }
        int new_pivot = pivot;
        if (nums[i] > nums[pivot]) {
            swap(nums[i], nums[pivot]);
            new_pivot = i;
        } else if (i > pivot) {
            swap(nums[pivot], nums[i-1]);
            new_pivot = i-1;
        }
        if (k > new_pivot+1) return partition(nums, k, new_pivot+1, high);
        else if (k < new_pivot+1) return partition(nums, k, low, new_pivot-1);
        return nums[new_pivot];
    }
};
```

### 295. 数据流的中位数(Hard) @hot100

中位数是有序整数列表中的中间值。如果列表的大小是偶数，则没有中间值，中位数是两个中间值的平均值。

例如 arr = [2,3,4] 的中位数是 3 。
例如 arr = [2,3] 的中位数是 (2 + 3) / 2 = 2.5 。
实现 MedianFinder 类:

MedianFinder() 初始化 MedianFinder 对象。

void addNum(int num) 将数据流中的整数 num 添加到数据结构中。

double findMedian() 返回到目前为止所有元素的中位数。与实际答案相差 10-5 以内的答案将被接受。

示例 1：

输入
["MedianFinder", "addNum", "addNum", "findMedian", "addNum", "findMedian"]
[[], [1], [2], [], [3], []]
输出
[null, null, null, 1.5, null, 2.0]

解释
MedianFinder medianFinder = new MedianFinder();
medianFinder.addNum(1);    // arr = [1]
medianFinder.addNum(2);    // arr = [1, 2]
medianFinder.findMedian(); // 返回 1.5 ((1 + 2) / 2)
medianFinder.addNum(3);    // arr[1, 2, 3]
medianFinder.findMedian(); // return 2.0
提示:

-105 <= num <= 105
在调用 findMedian 之前，数据结构中至少有一个元素
最多 5 * 104 次调用 addNum 和 findMedian

剑指offer上的原题，用最大堆和最小堆辅助，数据流遍历时，保持最小堆的最小值大于最大堆的最大值，并且保证最小堆的大小要么等于最大堆大小，要么多1，findMedian函数只需要去查看两个堆的堆顶即可知道中位数是多少

```c++
class MedianFinder {
public:
    priority_queue<int> max_heap; // 大根堆的最大值小于小根堆的最小值
    priority_queue<int, vector<int>, greater<int>> min_heap; // 保证小根堆.size() = 大根堆.size() 或+1
    MedianFinder() {
    }
    
    void addNum(int num) {
        if (min_heap.empty()) {
            min_heap.push(num);
            return;
        }
        if (min_heap.top() < num){
            min_heap.push(num);
        } else {
            max_heap.push(num);
        }
        if (min_heap.size() < max_heap.size()) {
            int tmp = max_heap.top();
            max_heap.pop();
            min_heap.push(tmp);
        } else if (min_heap.size() > max_heap.size() + 1) {
            int tmp = min_heap.top();
            min_heap.pop();
            max_heap.push(tmp);
        }
    }
    
    double findMedian() {
        if (max_heap.size() == min_heap.size()) {
            return (double)(max_heap.top() + min_heap.top()) / 2.0;
        }
        return min_heap.top();
    }
};

/**
 * Your MedianFinder object will be instantiated and called as such:
 * MedianFinder* obj = new MedianFinder();
 * obj->addNum(num);
 * double param_2 = obj->findMedian();
 */

```

### 2336. 无限集中的最小数字

medium

现有一个包含所有正整数的集合 [1, 2, 3, 4, 5, ...] 。

实现 SmallestInfiniteSet 类：

SmallestInfiniteSet() 初始化 SmallestInfiniteSet 对象以包含 所有 正整数。
int popSmallest() 移除 并返回该无限集中的最小整数。
void addBack(int num) 如果正整数 num 不 存在于无限集中，则将一个 num 添加 到该无限集最后。
 
```
示例：

输入
["SmallestInfiniteSet", "addBack", "popSmallest", "popSmallest", "popSmallest", "addBack", "popSmallest", "popSmallest", "popSmallest"]
[[], [2], [], [], [], [1], [], [], []]
输出
[null, null, 1, 2, 3, null, 1, 4, 5]

解释
SmallestInfiniteSet smallestInfiniteSet = new SmallestInfiniteSet();
smallestInfiniteSet.addBack(2);    // 2 已经在集合中，所以不做任何变更。
smallestInfiniteSet.popSmallest(); // 返回 1 ，因为 1 是最小的整数，并将其从集合中移除。
smallestInfiniteSet.popSmallest(); // 返回 2 ，并将其从集合中移除。
smallestInfiniteSet.popSmallest(); // 返回 3 ，并将其从集合中移除。
smallestInfiniteSet.addBack(1);    // 将 1 添加到该集合中。
smallestInfiniteSet.popSmallest(); // 返回 1 ，因为 1 在上一步中被添加到集合中，
                                   // 且 1 是最小的整数，并将其从集合中移除。
smallestInfiniteSet.popSmallest(); // 返回 4 ，并将其从集合中移除。
smallestInfiniteSet.popSmallest(); // 返回 5 ，并将其从集合中移除。
 

提示：

1 <= num <= 1000
最多调用 popSmallest 和 addBack 方法 共计 1000 次
```

最开始想错了，把1000个元素都加进了小根堆，其实仔细读题，不需要实际构造，只需要保存目前已删除过的最大数字thres即可

```c++
class SmallestInfiniteSet {
    int thres = 0; // 记录目前删除过的最大数字
    set<int> s; // set是从小到大的有序集合，记录pop过又被加进来的数字，如果再被pop则删除
public:
    SmallestInfiniteSet() {}
    
    int popSmallest() {
        if (s.empty()) {
            thres++;
            return thres;
        }
        int smallest = *s.begin();
        s.erase(s.begin());
        return smallest;
    }
    
    void addBack(int num) {
        if (num > thres) return;
        s.insert(num); // set不允许重复key，所以不需要关心num是否之前已添加（很巧妙）
    }
};

/**
 * Your SmallestInfiniteSet object will be instantiated and called as such:
 * SmallestInfiniteSet* obj = new SmallestInfiniteSet();
 * int param_1 = obj->popSmallest();
 * obj->addBack(num);
 */
```

### 2542. 最大子序列的分数

medium

给你两个下标从 0 开始的整数数组 nums1 和 nums2 ，两者长度都是 n ，再给你一个正整数 k 。你必须从 nums1 中选一个长度为 k 的 子序列 对应的下标。

对于选择的下标 i0 ，i1 ，...， ik - 1 ，你的 分数 定义如下：

nums1 中下标对应元素求和，乘以 nums2 中下标对应元素的 最小值 。
用公式表示： (nums1[i0] + nums1[i1] +...+ nums1[ik - 1]) * min(nums2[i0] , nums2[i1], ... ,nums2[ik - 1]) 。
请你返回 最大 可能的分数。

一个数组的 子序列 下标是集合 {0, 1, ..., n-1} 中删除若干元素得到的剩余集合，也可以不删除任何元素。

```
示例 1：

输入：nums1 = [1,3,3,2], nums2 = [2,1,3,4], k = 3
输出：12
解释：
四个可能的子序列分数为：
- 选择下标 0 ，1 和 2 ，得到分数 (1+3+3) * min(2,1,3) = 7 。
- 选择下标 0 ，1 和 3 ，得到分数 (1+3+2) * min(2,1,4) = 6 。
- 选择下标 0 ，2 和 3 ，得到分数 (1+3+2) * min(2,3,4) = 12 。
- 选择下标 1 ，2 和 3 ，得到分数 (3+3+2) * min(1,3,4) = 8 。
所以最大分数为 12 。
示例 2：

输入：nums1 = [4,2,3,1,1], nums2 = [7,5,10,9,6], k = 1
输出：30
解释：
选择下标 2 最优：nums1[2] * nums2[2] = 3 * 10 = 30 是最大可能分数。
 

提示：

n == nums1.length == nums2.length
1 <= n <= 105
0 <= nums1[i], nums2[j] <= 105
1 <= k <= n
```

反悔贪心 A*B
有约束，多维求最佳常用的一种方式。其中 A 可以是 除法/加法等，B 为单个元素（最大/最小值）

让 B 保持和题目最佳渐远的方式变化，比如题目要最大值，那么就降序
每次移除 A 中的最差结果，换一个更好的结果，也就是在 B 变差的情况下，A需要变好，才能让答案更优
比较获得最优解
方法：优先队列
按照 nums2 降序排序，使得 nums2 变差
收集 k 个元素，比较获得最优解
超过 k 个时，提出一个和最小的进行替换

作者：钰娘娘丿-曱-乀
链接：https://leetcode.cn/problems/maximum-subsequence-score/solutions/2103910/yu-niang-niang-2542-zui-da-zi-xu-lie-de-vdxv6/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

把 nums1和 nums2组合起来，按照 nums2[i] 从大到小排序。枚举 nums2[i] 作为序列的最小值，那么 nums1就只能在下标 ≤i 的数中选了。要选最大的 k 个数。

根据 703. 数据流中的第 K 大元素，这可以用一个大小固定为 k 的最小堆来做，如果当前元素大于堆顶，就替换堆顶，这样可以让堆中元素之和变大。

```c++
class Solution {
public:
    long long maxScore(vector<int> &nums1, vector<int> &nums2, int k) {
        int n = nums1.size();
        vector<int> ids(n);
        iota(ids.begin(), ids.end(), 0); // fill the vector from 0 in sequance 
        // 对下标排序，不影响原数组的顺序
        ranges::sort(ids, [&](int i, int j) { return nums2[i] > nums2[j]; }); // ranges::sort since C++20

        priority_queue<int, vector<int>, greater<>> pq; // 小根堆
        long long sum = 0;
        for (int i = 0; i < k; i++) {
            sum += nums1[ids[i]];
            pq.push(nums1[ids[i]]);
        }

        long long ans = sum * nums2[ids[k - 1]];
        for (int i = k; i < n; i++) { // 因为此时nums2已有序，所以每次枚举nums2[i]作为序列最小值，nums1只能在下标<=i的数中选，要选最大的k个数，自然用小根堆
            int x = nums1[ids[i]];
            if (x > pq.top()) {
                sum += x - pq.top();
                pq.pop();
                pq.push(x);
                ans = max(ans, sum * nums2[ids[i]]);
            }
        }
        return ans;
    }
};

// 作者：灵茶山艾府
// 链接：https://leetcode.cn/problems/maximum-subsequence-score/solutions/2073033/zhuan-huan-wen-ti-zui-xiao-dui-by-endles-9t8t/
// 来源：力扣（LeetCode）
// 著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

### 2462. 雇佣 K 位工人的总代价

medium

给你一个下标从 0 开始的整数数组 costs ，其中 costs[i] 是雇佣第 i 位工人的代价。

同时给你两个整数 k 和 candidates 。我们想根据以下规则恰好雇佣 k 位工人：

总共进行 k 轮雇佣，且每一轮恰好雇佣一位工人。
在每一轮雇佣中，从最前面 candidates 和最后面 candidates 人中选出代价最小的一位工人，如果有多位代价相同且最小的工人，选择下标更小的一位工人。
比方说，costs = [3,2,7,7,1,2] 且 candidates = 2 ，第一轮雇佣中，我们选择第 4 位工人，因为他的代价最小 [3,2,7,7,1,2] 。
第二轮雇佣，我们选择第 1 位工人，因为他们的代价与第 4 位工人一样都是最小代价，而且下标更小，[3,2,7,7,2] 。注意每一轮雇佣后，剩余工人的下标可能会发生变化。
如果剩余员工数目不足 candidates 人，那么下一轮雇佣他们中代价最小的一人，如果有多位代价相同且最小的工人，选择下标更小的一位工人。
一位工人只能被选择一次。
返回雇佣恰好 k 位工人的总代价。

```
示例 1：

输入：costs = [17,12,10,2,7,2,11,20,8], k = 3, candidates = 4
输出：11
解释：我们总共雇佣 3 位工人。总代价一开始为 0 。
- 第一轮雇佣，我们从 [17,12,10,2,7,2,11,20,8] 中选择。最小代价是 2 ，有两位工人，我们选择下标更小的一位工人，即第 3 位工人。总代价是 0 + 2 = 2 。
- 第二轮雇佣，我们从 [17,12,10,7,2,11,20,8] 中选择。最小代价是 2 ，下标为 4 ，总代价是 2 + 2 = 4 。
- 第三轮雇佣，我们从 [17,12,10,7,11,20,8] 中选择，最小代价是 7 ，下标为 3 ，总代价是 4 + 7 = 11 。注意下标为 3 的工人同时在最前面和最后面 4 位工人中。
总雇佣代价是 11 。
示例 2：

输入：costs = [1,2,4,1], k = 3, candidates = 3
输出：4
解释：我们总共雇佣 3 位工人。总代价一开始为 0 。
- 第一轮雇佣，我们从 [1,2,4,1] 中选择。最小代价为 1 ，有两位工人，我们选择下标更小的一位工人，即第 0 位工人，总代价是 0 + 1 = 1 。注意，下标为 1 和 2 的工人同时在最前面和最后面 3 位工人中。
- 第二轮雇佣，我们从 [2,4,1] 中选择。最小代价为 1 ，下标为 2 ，总代价是 1 + 1 = 2 。
- 第三轮雇佣，少于 3 位工人，我们从剩余工人 [2,4] 中选择。最小代价是 2 ，下标为 0 。总代价为 2 + 2 = 4 。
总雇佣代价是 4 。
 

提示：

1 <= costs.length <= 105 
1 <= costs[i] <= 105
1 <= k, candidates <= costs.length
```

思路不难，用小根堆，但是需要考虑细致，如果n很大，则把前candidates个和后candidates个元素入堆，然后维持左边界和右边界，在迭代中每次判断是从哪边扩展，注意扩张到整个数组（即左边界=右边界）时，停止入堆，堆中现有元素依次pop即可

```c++
class Solution {
public:
struct cmp {
    bool operator()(pair<int, int> a, pair<int, int> b) {
        if (a.first > b.first) return true;
        if (a.first == b.first) return a.second > b.second;
        return false;
    }
};
    long long totalCost(vector<int>& costs, int k, int candidates) {
        if (k < 1) return 0;
        int n = costs.size();
        // 每次都要找最小的，所以用小根堆
        priority_queue<pair<int, int>, vector<pair<int, int>>, cmp> pq;
        int left_expand = -1; 
        int right_expand = -1;
        int expand_cnt = 0;
        if (n >= 2 * candidates) {
            for (int i = 0; i < candidates; ++i) {
                pq.push({costs[i], i});
                pq.push({costs[n-1-i], n-1-i});
            }
            left_expand = candidates-1; // [0, left_expand]
            right_expand = n-candidates; // [right_expand, n-1]
            expand_cnt = n - 2 * candidates;
        } else {
            for (int i = 0; i < n; ++i) {
                pq.push({costs[i], i});
            }
        }
        long long cost = 0;
        while (--k >= 0) {
            auto p = pq.top();
            pq.pop();
            cost += p.first;
            if (expand_cnt > 0) {
                --expand_cnt;
                if (p.second <= left_expand) {
                    ++left_expand;
                    pq.push({costs[left_expand], left_expand});
                } else {
                    --right_expand;
                    pq.push({costs[right_expand], right_expand});
                }
            }
        }
        return cost;
    }
};
```

也可以用两个最小堆，分别维护前面和后面

```c++
class Solution {
public:
    long long totalCost(vector<int>& costs, int k, int candidates) {
        int n = costs.size();
        if (candidates * 2 + k > n) {
            ranges::nth_element(costs, costs.begin() + k);
            return accumulate(costs.begin(), costs.begin() + k, 0LL);
        }

        priority_queue<int, vector<int>, greater<>> pre, suf;
        for (int i = 0; i < candidates; i++) {
            pre.push(costs[i]);
            suf.push(costs[n - 1 - i]);
        }

        long long ans = 0;
        int i = candidates, j = n - 1 - candidates;
        while (k--) {
            if (pre.top() <= suf.top()) {
                ans += pre.top();
                pre.pop();
                pre.push(costs[i++]);
            } else {
                ans += suf.top();
                suf.pop();
                suf.push(costs[j--]);
            }
        }
        return ans;
    }
};

// 作者：灵茶山艾府
// 链接：https://leetcode.cn/problems/total-cost-to-hire-k-workers/solutions/1951938/liang-ge-zui-xiao-dui-mo-ni-by-endlessch-nagm/
// 来源：力扣（LeetCode）
// 著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```