Iso7z

http://www.tc4shell.com/en/7zip/iso7z/
Copyright (C) 2018-2020 Dec Software.

Iso7z is a small plugin for the popular 7-Zip archiver. 7-Zip with Iso7z can
quickly extract files from a disc image without mounting it. It supports disc
images created in different applications.

List of formats that can be opened in 7-Zip with Iso7z:

    CCD/IMG - disc images created with CloneCD
    CDI - disc images created with DiscJuggler
    CHD (v4) - images used by MAME
    CSO
    CUE/BIN
    ECM - disc images compressed with ECM Tool
    GDI
    ISZ – disc images created with UltraISO
    MDS/MDF - disc images created with Alcohol 120%
    NRG - disc images created with Nero Burning ROM
    ZiSofs files

The plugin also contains a special codec RawSplitter that enables 7-Zip to
efficiently pack uncompressed raw disc images (CCD/IMG, CDI, CUE/BIN, GDI,
MDS/MDF, or NRG) into 7z archives. Moreover, RawSplitter can slightly improve
the compression of DAT files from Video CD discs (such files are usually named
AVSEQxx.DAT and have the RIFF and CDXA signatures at the beginning of the file).

INSTALLATION

To install the plugin into the 7-Zip installation folder, you need to create the
"Formats" subfolder. After that, copy Iso7z.64.dll or Iso7z.32.dll (depending on
your 7-Zip edition) to that subfolder. If you do that, each time you launch
7-Zip, it will automatically find Iso7z and use it when opening files of the
supported formats.

USING

When you open a disc image in 7-Zip, each track will be represented as a file
whose type depends on the track type. An audio track will be represented as a
WAV file, which you can play in any audio player. A track containing ISO9660
file system data will be represented as an ISO file. Iso7z also supports
multi-session disc images; each session’s track will be represented as an ISO
file. If an ISO9660 file system cannot be represented as an ISO file (for
example, if a CD-ROM XA disc image contains files recorded in the Mode2/Form2
format), the track will be represented as a folder containing correctly decoded
Mode2/Form2 files.

If Iso7z can’t open your disk images or opens them incorrectly, please send an
email about that issue to support@tc4shell.com

USING THE RAWSPLITTER CODEC

THE PRINCIPLE OF COMPRESSION

A raw disc image contains payload and housekeeping data (synchronization bytes,
ECC and EDC checksums, etc.).

Most of the housekeeping data can be removed when packing the disc image into an
archive, and then easily restored when unpacking the disc image from the
archive. For example, in case of a disc with 2368-byte Mode1 sectors, you can
remove 304 bytes from each sector to reduce the amount of data by 12.84 percent.
For example, 800 MB can be reduced to 700 MB just by removing the housekeeping
data. The same applies to a disc with 2352-byte Mode2/Form1 sectors: You can
remove 304 bytes from each sector. In case of a disc with 2352-byte Mode2/Form2
sectors, you can remove 28 bytes from each sector. However, the compression
ratio of disc images with Mode2 sectors is mostly not as good, because some
headers cannot be restored automatically, so you have to store additional data
to be able to restore the headers when unpacking the image from the archive.

The payload can be of two types: audio data or data files. These two data types
are completely different, so it's highly reasonable to use different methods
when compressing them.

RawSplitter performs all the above optimizations when compressing data. That is,
it removes the housekeeping data and passes the payload according to its type to
the suitable codec for packing. In most cases, this approach can significantly
improve the compression ratio of raw disc images.

DATA PACKING

It is not always possible to correctly recognize the content of a raw disc image
without performing a comprehensive analysis, especially if it contains tracks of
different types. For that reason, if you want to use the RawSplitter codec, you
need to install the Smart7z plugin, too. Smart7z intellectually packs different
files into 7z archives. Smart7z and RawSplitter perform a comprehensive analysis
of the files being packed, so that RawSplitter knows exactly what kind of data
it is packing and can select optimal compression parameters. We also recommend
that you install the WavPack7z plugin, which enables 7-Zip to pack audio files
using the highly efficient WavPack compression algorithm. In that case,
WavPack7z will be used to compress audio tracks. When used together, the three
plugins can achieve the best compression ratio. If the WavPack7z plugin is not
installed, the LZMA2 algorithm and the Delta filter will be used for audio
compression.

If you have installed the Smart7z plugin, you can select the Smart7z format in
the 7-Zip file packing dialog box. Select that format and click the OK button,
and 7-Zip will start analyzing and packing the files you selected. It's very
simple.

An important note: When packing disc images that have an index file (CCD/IMG,
CUE/BIN, GDI, or MDS/MDF), you need to pack not only the disc image files, but
also index files, so that RawSplitter can analyze them.

An important note: If the disc has only tracks with 2048-byte sectors (that is,
tracks without any housekeeping data), using the RawSplitter codec will not
improve the compression ratio. When packing such disc images, it is advisable to
use, for example, the LZMA2 method.
