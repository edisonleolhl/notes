# GridLayout详解+计算器实现 #
---
> ### android:layout_columnWeight 
> ### android:layout_rowWeight
> ### 只能在API21以上使用！！！ ###

### GridLayout简介 ###
GridLayout顾名思义网格布局，是Android4.0(API 14)新增的布局控件
是将将布局划分为行、列和单元格，也都支持一个控件在行、列上都有交错排列

### TableLayout属性详解 ###
1. 行列数
    - 在TableLayout中行数是由开发员指定的，列数是根据TableRow中最大元素个数确定的。
    - 在GridLayout中就非常方便了，使用如下属性直接指定
        
            android:rowCount="7"  
            android:columnCount="4"
2. 布局方向
    - 首先它与LinearLayout布局一样，也分为水平和垂直两种方式，默认是水平布局，一个控件挨着一个控件从左到右依次排列，但是通过指定android:columnCount设置列数的属性后，控件会自动换行进行排列。
    - 如果设置为垂直方向布局，控件则是从上到下依次排列，但是通过指定android:rowCount设置行数的属性后，控件会自动换列进行排列。
    
3. 单元格属性

        android:layout_column  指定该单元格在第几列显示
        android:layout_row 指定该单元格在第几行显示
        android:layout_columnSpan  指定该单元格占据的列数
        android:layout_rowSpan 指定该单元格占据的行数
        android:layout_gravity 指定该单元格在容器中的位置
        android:layout_columnWeight（API21加入）列权重
        android:layout_rowWeight（API21加入）   行权重

4. 关于平均分配行、列问题
    
    为每一个希望平均分配的行或列分别指定

            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
    
    
    
    
5. 关于占据多行或多列时填满问题
        
        使用android:layout_gravity="fill"

# 计算器代码实现 #
---

### 布局文件 ###
    <?xml version="1.0" encoding="utf-8"?>
    <LinearLayout xmlns:android="http://schemas.android.com/apk/res/    android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
        >

    <TextView
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:text="0"
        android:gravity="center_vertical|end"
        android:textSize="50sp"
        android:id="@+id/resultText" />

    <GridLayout
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="3"
        android:id="@+id/tableLayout"
        android:rowCount="5"
        android:columnCount="4"
        >

        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="C"
            android:textSize="50sp"/>
        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="+/-"
            android:textSize="50sp"/>
        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="%"
            android:textSize="50sp"/>
        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="÷"
            android:textSize="50sp"/>

        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="7"
            android:textSize="50sp"/>
        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="8"
            android:textSize="50sp"/>
        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="9"
            android:textSize="50sp"/>
        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="x"
            android:textSize="50sp"/>

        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="4"
            android:textSize="50sp"/>
        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="5"
            android:textSize="50sp"/>
        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="6"
            android:textSize="50sp"/>
        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="—"
            android:textSize="50sp"/>

        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="1"
            android:textSize="50sp"/>
        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="2"
            android:textSize="50sp"/>
        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="3"
            android:textSize="50sp"/>
        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="+"
            android:textSize="50sp"/>

        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="0"
            android:layout_columnSpan="2"
            android:textSize="50sp"/>
        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="."
            android:textSize="50sp"/>
        <Button
            android:layout_width="0dp"
            android:layout_height="0dp"
            android:layout_columnWeight="1"
            android:layout_rowWeight="1"
            android:text="="
            android:textSize="50sp"/>
    </GridLayout>
    </LinearLayout>

### 效果图 ###
![](http://upload-images.jianshu.io/upload_images/2106579-b0ed74232c30ac8d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
