# 保存文件（Saving Files）#
---
https://developer.android.com/training/basics/data-storage/files.html
##选择内部存储或者外部存储
所有 Android 设备都有两个文件存储区域：“内部”和“外部”存储。这些名称在 Android 早期产生，当时大多数设备都提供内置的非易失性内存（内部存储），以及移动存储介质，比如微型 SD 卡（外部存储）。一些设备将永久性存储空间划分为“内部”和“外部”分区，即便没有移动存储介质，也始终有两个存储空间，并且无论外部存储设备是否可移动，API 的行为均一致。以下列表汇总了关于各个存储空间的实际信息。

内部存储：

- 它始终可用。
- 默认情况下只有您的应用可以访问此处保存的文件。
- 当用户卸载您的应用时，系统会从内部存储中删除您的应用的所有文件。

    当您希望确保用户或其他应用均无法访问您的文件时，内部存储是最佳选择。

外部存储：

- 它并非始终可用，因为用户可采用 USB 存储的形式装载外部存储，并在某些情况下会从设备中将其删除。
- 它是全局可读的，因此此处保存的文件可能不受您控制地被读取。
- 当用户卸载您的应用时，只有在您通过 getExternalFilesDir() 将您的应用的文件保存在目录中时，系统才会从此处删除您的应用的文件。

    对于无需访问限制以及您希望与其他应用共享或允许用户使用电脑访问的文件，外部存储是最佳位置。

> 尽管应用默认安装在内部存储中，但您可在您的宣示说明中指定 android:installLocation 属性，这样您的应用便可安装在在外部存储中。 当 APK 非常大且它们的外部存储空间大于内部存储时，用户更青睐这个选择。 如需了解详细信息，请参阅应用安装位置。

## 获取外部存储的权限 ##
要向外部存储写入信息，您必须在您的宣示说明文件中请求 WRITE_EXTERNAL_STORAGE 权限。

    <manifest ...>
        <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    ...
    </manifest>
> **注意**： 目前，所有应用都可以读取外部存储，而无需特别的权限。 但这在将来版本中会进行更改。如果您的应用需要读取外部存储（但不向其写入信息），那么您将需要声明 READ_EXTERNAL_STORAGE 权限。 要确保您的应用继续正常工作，您应在更改生效前声明此权限。

    <manifest ...>
        <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    ...
    </manifest>
但是，如果您的应用使用 WRITE_EXTERNAL_STORAGE 权限，那么它也隐含读取外部存储的权限。
您无需任何权限，即可在内部存储中保存文件。 您的应用始终具有在其内部存储目录中进行读写的权限。

## ﻿将文件保存在内部存储中 ##
在内部存储中保存文件时，您可以通过调用以下两种方法之一获取作为 File 的相应目录：

getFilesDir()
返回表示您的应用的内部目录的 File 。
getCacheDir()
返回表示您的应用临时缓存文件的内部目录的 File 。 务必删除所有不再需要的文件并对在指定时间您使用的内存量实现合理大小限制，比如，1MB。 如果在系统即将耗尽存储，它会在不进行警告的情况下删除您的缓存文件。

要在这些目录之一中新建文件，您可以使用 File() 构造函数，传递指定您的内部存储目录的上述方法之一所提供的 File 。例如：

    File file = new File(context.getFilesDir(), filename);
或者，您可以调用 openFileOutput() 获取写入到内部目录中的文件FileOutputStream 。例如，此处显示如何向文件写入一些文本：
    
    String filename = "myfile";
    String string = "Hello world!";
    FileOutputStream outputStream;
    
    try {
      outputStream = openFileOutput(filename, Context.MODE_PRIVATE);
      outputStream.write(string.getBytes());
      outputStream.close();
    } catch (Exception e) {
      e.printStackTrace();
    }
或者，如果您需要缓存某些文件，您应改用 createTempFile()。例如，以下方法从 URL 提取文件名并在您的应用的内部缓存目录中以该名称创建文件：

    public File getTempFile(Context context, String url) {
        File file;
        try {
            String fileName = Uri.parse(url).getLastPathSegment();
            file = File.createTempFile(fileName, null, context.getCacheDir());
        catch (IOException e) {
            // Error while creating file
        }
        return file;
    }
> 注意： 您的应用的内部存储设备目录由您的应用在Android 文件系统特定位置中的软件包名称指定。在技术上，如果您将文件模式设置为可读，另一个应用可以读取您的内部文件。 但是，另一个应用也需要知道您的应用的软件包名称和文件名。 其他应用无法浏览您的内部目录并且没有读写权限，除非您明确将文件设置为可读或可写。 只要您为内部存储上的文件使用 MODE_PRIVATE， 其他应用便从不会访问它们。

## 将文件保存在外部存储中 ##
由于外部存储可能不可用—比如，当用户已将存储装载到电脑或已移除提供外部存储的 SD 卡时—因此，在访问它之前，您应始终确认其容量。 您可以通过调用 getExternalStorageState() 查询外部存储状态。 如果返回的状态为 MEDIA_MOUNTED，那么您可以对您的文件进行读写。 例如，以下方法对于确定存储可用性非常有用：

    /* Checks if external storage is available for read and write */
    public boolean isExternalStorageWritable() {
        String state = Environment.getExternalStorageState();
        if (Environment.MEDIA_MOUNTED.equals(state)) {
            return true;
        }
        return false;
    }
    
    /* Checks if external storage is available to at least read */
    public boolean isExternalStorageReadable() {
        String state = Environment.getExternalStorageState();
        if (Environment.MEDIA_MOUNTED.equals(state) ||
            Environment.MEDIA_MOUNTED_READ_ONLY.equals(state)) {
            return true;
        }
        return false;
    }
尽管外部存储可被用户和其他应用进行修改，但您可在此处保存两类文件：

公共文件
应供其他应用和用户自由使用的文件。 当用户卸载您的应用时，用户应仍可以使用这些文件。
例如，您的应用拍摄的照片或其他已下载的文件。

私有文件
本属于您的应用且应在用户卸载您的应用时删除的文件。尽管这些文件在技术上可被用户和其他应用访问（因为它们在外部存储上），它们是实际上不向您的应用之外的用户提供值的文件。当用户卸载您的应用时，系统会删除应用外部专用目录中的所有文件。
例如，您的应用下载的其他资源或临时介质文件。

如果您要使用外部存储上的公共文件，请使用 getExternalStoragePublicDirectory() 方法获取表示外部存储上相应目录的 File 。该方法使用指定 您想要保存以便它们可以与其他公共文件在逻辑上组织在一起的文件类型的参数，比如 DIRECTORY_MUSIC 或 DIRECTORY_PICTURES。 例如：

    public File getAlbumStorageDir(String albumName) {
        // Get the directory for the user's public pictures directory. 
        File file = new File(Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_PICTURES), albumName);
        if (!file.mkdirs()) {
            Log.e(LOG_TAG, "Directory not created");
        }
        return file;
    }
如果您要保存您的应用专用文件，您可以通过调用 getExternalFilesDir() 获取相应的目录并向其传递指示您想要的目录类型的名称。 通过这种方法创建的各个目录将添加至封装您的应用的所有外部存储文件的父目录，当用户卸载您的应用时，系统会删除这些文件。

例如，您可以使用以下方法来创建个人相册的目录：

    public File getAlbumStorageDir(Context context, String albumName) {
        // Get the directory for the app's private pictures directory. 
        File file = new File(context.getExternalFilesDir(
                Environment.DIRECTORY_PICTURES), albumName);
        if (!file.mkdirs()) {
            Log.e(LOG_TAG, "Directory not created");
        }
        return file;
    }
如果没有适合您文件的预定义子目录名称，您可以改为调用 getExternalFilesDir() 并传递 null。这将返回外部存储上您的应用的专用目录 的根目录。

切记，getExternalFilesDir() 在用户卸载您的应用时删除的目录内创建目录。如果您正保存的文件应在用户卸载您的应用后仍然可用—比如，当您的应用是照相机并且用户要保留照片时—您应改用 getExternalStoragePublicDirectory()。

无论您对于共享的文件使用 getExternalStoragePublicDirectory() 还是对您的应用专用文件使用 getExternalFilesDir() ，您使用诸如 DIRECTORY_PICTURES 的 API 常数提供的目录名称非常重要。 这些目录名称可确保系统正确处理文件。 例如，保存在 DIRECTORY_RINGTONES 中的文件由系统介质扫描程序归类为铃声，而不是音乐。

## 查询可用空间 ##
如果您事先知道您将保存的数据量，您可以查出是否有足够的可用空间，而无需调用 getFreeSpace() 或 getTotalSpace() 引起 IOException 。 这些方法分别提供目前的可用空间和存储卷中的总空间。 此信息也可用来避免填充存储卷以致超出特定阈值。

但是，系统并不保证您可以写入与 getFreeSpace() 指示的一样多的字节。如果返回的数字比您要保存的数据大小大出几 MB，或如果文件系统所占空间不到 90%，则可安全继续操作。否则，您可能不应写入存储。

>注意：保存您的文件之前，您无需检查可用空间量。 您可以尝试立刻写入文件，然后在 IOException 出现时将其捕获。 如果您不知道所需的确切空间量，您可能需要这样做。 例如，如果在保存文件之前通过将 PNG 图像转换成JPEG 更改了文件的编码，您事先将不知道文件的大小。

## 删除文件 ##
您应始终删除不再需要的文件。删除文件最直接的方法是让打开的文件参考自行调用 delete()。

    myFile.delete();
如果文件保存在内部存储中，您还可以请求 Context 通过调用 deleteFile() 来定位和删除文件：

    myContext.deleteFile(fileName);

> 注意：当用户卸载您的应用时，Android 系统会删除以下各项：
- 您保存在内部存储中的所有文件
- 您使用 getExternalFilesDir() 保存在外部存储中的所有文件。
但是，您应手动删除使用 getCacheDir() 定期创建的所有缓存文件并且定期删除不再需要的其他文件。
